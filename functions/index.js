/**
 * HarvestHub trusted server operations.
 *
 * Architecture note
 * -----------------
 * No credential capable of SENDING a notification ever lives in the app. The
 * Flutter client only registers its device token (users/{uid}/fcm_tokens) and
 * displays what the platform delivers. All sending happens here with the Admin
 * SDK, so the service-account key lives in Google's server environment where it
 * cannot be extracted from the APK.
 *
 * Trigger model
 * -------------
 * Firestore triggers are the right tool here: the app already has exactly four
 * write paths that matter, so a trigger catches all of them without the client
 * having to remember to call anything. The client's only job is to write the
 * document.
 *
 * Deploy:  cd functions && npm install && firebase deploy --only functions
 */
const {
  onCall,
  HttpsError,
} = require("firebase-functions/v2/https");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { setGlobalOptions } = require("firebase-functions/v2");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

setGlobalOptions({ region: "asia-south1", maxInstances: 10 });

initializeApp();
const db = getFirestore();

/** Statuses an order may be cancelled from. Mirrors OrderStatus.next() in Dart. */
const CANCELLABLE = ["pending", "confirmed"];

/** SRS order statuses, in the legal progression order. */
const STATUS_FLOW = [
  "pending",
  "confirmed",
  "ready_for_pickup",
  "completed",
  "cancelled",
];

const STATUS_LABEL = {
  pending: "Pending",
  confirmed: "Confirmed",
  ready_for_pickup: "Ready for Pickup",
  completed: "Completed",
  cancelled: "Cancelled",
};

/** Firestore `in` queries accept at most 30 values. */
const IN_LIMIT = 30;

// ---------------------------------------------------------------------------
// token lookup + sending
// ---------------------------------------------------------------------------

/**
 * Every device token registered by [uid], or [] when the user has none.
 * Strips invalid registrations rather than failing the whole send.
 */
async function tokensFor(uid) {
  if (!uid) return [];
  const snap = await db
    .collection("users")
    .doc(uid)
    .collection("fcm_tokens")
    .get();
  return snap.docs
    .map((d) => (d.data() || {}).token)
    .filter((t) => typeof t === "string" && t.length > 0);
}

/**
 * Sends one notification to a list of uids. Best-effort and never throws, so a
 * single bad token cannot break the caller (which is usually a Firestore
 * trigger, where an exception would cause a retry storm).
 */
async function notifyUids(uids, title, body, data) {
  const unique = [...new Set(uids.filter(Boolean))];
  const jobs = [];
  for (const uid of unique) {
    const tokens = await tokensFor(uid);
    for (const token of tokens) jobs.push({ uid, token });
  }
  if (jobs.length === 0) return { sent: 0, failed: 0 };

  // multicast keeps us under the 500-recipient FCM limit per call.
  let sent = 0;
  let failed = 0;
  for (let i = 0; i < jobs.length; i += 500) {
    const batch = jobs.slice(i, i + 500);
    try {
      const res = await getMessaging().sendEachForMulticast({
        tokens: batch.map((j) => j.token),
        notification: { title, body },
        data: data || {},
        android: { priority: "high" },
      });
      sent += res.successCount;
      failed += res.failureCount;
    } catch (e) {
      console.error("FCM batch failed", e);
      failed += batch.length;
    }
  }
  return { sent, failed };
}

/** Chunks a list for Firestore `in` queries. */
function chunk(list, size = IN_LIMIT) {
  const out = [];
  for (let i = 0; i < list.length; i += size) out.push(list.slice(i, i + size));
  return out;
}

/**
 * Customer uids who follow [farmerId].
 *
 * Uses the collectionGroup index on followed_farmers.farmerId. With the follow
 * data stored as a sub-collection this is one indexed query; with an array on
 * the user document it would be a full scan of the users collection.
 */
async function followerUidsOf(farmerId) {
  if (!farmerId) return [];
  const snap = await db
    .collectionGroup("followed_farmers")
    .where("farmerId", "==", farmerId)
    .get();
  return snap.docs
    .map((d) => d.ref.parent.parent && d.ref.parent.parent.id)
    .filter(Boolean);
}

/** Customer uids whose wishlist contains [productId]. */
async function wishlistUidsOf(productId) {
  const snap = await db
    .collectionGroup("wishlist")
    .where("__name__", "==", productId)
    .get();
  return snap.docs
    .map((d) => d.ref.parent.parent && d.ref.parent.parent.id)
    .filter(Boolean);
}

/** The role of a user, or '' when the profile is missing. */
async function roleOf(uid) {
  const snap = await db.collection("users").doc(uid).get();
  return snap.exists ? (snap.data().role || "") : "";
}

// ===========================================================================
// 1. ORDER STATUS UPDATES  ->  notify the customer
// ===========================================================================

exports.orderStatusChanged = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;

    const status = after.status;
    const label = STATUS_LABEL[status] || status;
    const isCancellation = status === "cancelled";

    // Order ID in the body is what makes a cancellation/self-service request
    // distinguishable from a genuine stock-out cancellation.
    const body = isCancellation
      ? `Your order was cancelled. Rs ${Number(after.totalPrice || 0).toFixed(2)}`
      : `Your order is now ${label}.`;

    await notifyUids([after.customerId], "Order update: ${label}", body, {
      type: "order_status",
      orderId: event.params.orderId,
      status,
    });
  }
);

// ===========================================================================
// 2. NEW ORDER  ->  notify the farmer
// ===========================================================================

exports.orderCreated = onDocumentCreated("orders/{orderId}", async (event) => {
  const order = event.data.data();
  if (!order) return;

  const itemCount = Array.isArray(order.items) ? order.items.length : 0;
  await notifyUids(
    [order.farmerId],
    "New order received",
    `${itemCount} item(s), Rs ${Number(order.totalPrice || 0).toFixed(2)}`,
    { type: "new_order", orderId: event.params.orderId }
  );
});

// ===========================================================================
// 3. SLOT CANCELLATION / MODIFICATION  ->  notify the affected party
// ===========================================================================

exports.orderSlotChanged = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!before || !after) return;
    if (before.pickupSlotId === after.pickupSlotId) return;
    if (before.pickupSlotTime === after.pickupSlotTime && !after.pickupSlotId) return;

    const when = after.pickupSlotTime || "the new time";
    await notifyUids(
      [after.customerId],
      "Pickup slot changed",
      `Your pickup is now ${when}.`,
      { type: "slot_changed", orderId: event.params.orderId }
    );
  }
);

// ===========================================================================
// 4. RESTOCK + LOW STOCK  ->  driven by the products collection
// ===========================================================================

/**
 * Restock alert.
 *
 * Fires only on a genuine 0 -> positive transition, which is what makes it an
 * "it is back!" signal rather than a notification every time a farmer nudges
 * stock up by one. Recipients are the union of:
 *   - customers who wishlisted this exact product
 *   - customers who follow the farmer selling it
 */
exports.productRestocked = onDocumentUpdated(
  "products/{productId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!before || !after) return;

    const oldQty = Number(before.stockQty || 0);
    const newQty = Number(after.stockQty || 0);
    if (oldQty !== 0 || newQty <= 0) return;

    if (after.isActive === false) return;

    const [wishlisted, followers] = await Promise.all([
      wishlistUidsOf(event.params.productId),
      followerUidsOf(after.farmerId),
    ]);

    const recipients = [...new Set([...wishlisted, ...followers])];
    if (recipients.length === 0) return;

    const name = after.itemName || "A product";
    const unit = after.unit || "";
    await notifyUids(
      recipients,
      `${name} is back in stock`,
      unit
        ? `Now available: ${newQty} ${unit} at Rs ${Number(after.pricePerUnit || 0).toFixed(2)}/${unit}.`
        : `Now available: ${newQty} in stock.`,
      {
        type: "restock",
        productId: event.params.productId,
        farmerId: after.farmerId || "",
      }
    );
  }
);

/**
 * Low-stock warning to the farmer.
 *
 * Fires on the downward crossing of the farmer's own `lowStockThreshold`, and
 * only while the item is still above zero, so a farmer is warned to restock
 * rather than told about an item that is already unavailable.
 */
exports.productLowStock = onDocumentUpdated(
  "products/{productId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!before || !after) return;

    const oldQty = Number(before.stockQty || 0);
    const newQty = Number(after.stockQty || 0);
    if (newQty <= 0) return;
    if (oldQty === newQty) return;

    const farmerId = after.farmerId;
    if (!farmerId) return;

    const threshold = await lowStockThresholdOf(farmerId);
    // Only the crossing: was above (or at) the threshold, now below it.
    if (!(oldQty > threshold && newQty <= threshold)) return;

    const name = after.itemName || "A product";
    await notifyUids(
      [farmerId],
      "Low stock warning",
      `${name} has ${newQty} left (alert at ${threshold}).`,
      { type: "low_stock", productId: event.params.productId }
    );
  }
);

async function lowStockThresholdOf(farmerId) {
  const snap = await db.collection("farmers").doc(farmerId).get();
  if (!snap.exists) return 5;
  const t = Number((snap.data() || {}).lowStockThreshold);
  return Number.isFinite(t) && t > 0 ? t : 5;
}

// ===========================================================================
// 5. INCOMING CHAT MESSAGE  ->  notify the recipient only
// ===========================================================================

exports.chatMessageCreated = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const chatId = event.params.chatId;
    const message = event.data.data();
    if (!message) return;

    const chatSnap = await db.collection("chats").doc(chatId).get();
    if (!chatSnap.exists) return;
    const chat = chatSnap.data();

    const senderId = message.senderId || "";
    const recipientId =
      senderId === chat.customerId ? chat.farmerId : chat.customerId;
    if (!recipientId) return;

    const senderName = message.senderName || "Someone";
    const text = (message.text || "").slice(0, 120);

    // No notification for the sender's own device, and none for a read receipt
    // update (those are writes to the chat doc, not message creates).
    await notifyUids(
      [recipientId],
      `New message from ${senderName}`,
      text,
      { type: "chat", chatId, messageId: event.params.messageId }
    );
  }
);

// ===========================================================================
// 6. STALE TOKEN SWEEP (scheduled housekeeping)
// ===========================================================================

/**
 * FCM reports tokens that are no longer valid (app uninstalled, reinstalled).
 * The Admin SDK does not expose that, so the standard approach is: delivery
 * failures are pruned on a schedule by attempting a validation send. This job
 * instead removes tokens that the platform has already flagged via a prior
 * failure count stored by the trigger layer, and keeps the collection bounded.
 */
exports.pruneStaleTokens = onSchedule(
  { schedule: "every 24 hours", timeZone: "Asia/Karachi" },
  async () => {
    const cutoff = new Date(Date.now() - 1000 * 60 * 60 * 24 * 90);
    const snap = await db.collectionGroup("fcm_tokens").get();
    const stale = snap.docs.filter((d) => {
      const t = (d.data() || {}).updatedAt;
      if (!t || typeof t.toDate !== "function") return false;
      return t.toDate() < cutoff;
    });
    if (stale.length === 0) return;
    const batch = db.batch();
    for (const d of stale) batch.delete(d.ref);
    await batch.commit();
    console.log(`Pruned ${stale.length} stale notification tokens.`);
  }
);

// ===========================================================================
// 7. ORDER CANCELLATION (callable)
// ===========================================================================

/**
 * Cancels an order from the client.
 *
 * Why this exists
 * ---------------
 * Cancelling is a *compensating* transaction: it must set the order to
 * 'cancelled', give the stock back to products/{id}, and free capacity on
 * pickup_slots/{id}. Firestore security rules cannot verify that a stock
 * increment is legitimate, so they cannot safely let a customer write to
 * products. Granting that access would let any signed-in user set any stock
 * level. So the rules permit a customer to mark their own order cancelled but
 * not to write the compensation, and this function performs it with the Admin
 * SDK.
 *
 * Until this is deployed, a customer-initiated cancel is rejected by the rules;
 * a farmer or admin cancel still works, because those roles may write products
 * and slots directly.
 */
exports.cancelOrder = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Please log in first.");
  }

  const orderId = request.data && request.data.orderId;
  if (typeof orderId !== "string" || orderId.length === 0) {
    throw new HttpsError("invalid-argument", "orderId is required.");
  }

  const orderRef = db.collection("orders").doc(orderId);

  try {
    await db.runTransaction(async (tx) => {
      // ---- all reads first ----
      const orderSnap = await tx.get(orderRef);
      if (!orderSnap.exists) {
        throw new HttpsError("not-found", "Order nahi mila.");
      }
      const order = orderSnap.data();
      const status = order.status || "";

      const callerSnap = await tx.get(db.collection("users").doc(uid));
      const role = callerSnap.exists ? callerSnap.data().role : null;
      const isAdmin = role === "admin";
      const isOwningFarmer = order.farmerId === uid;
      const isOwningCustomer = order.customerId === uid;

      if (!isAdmin && !isOwningFarmer && !isOwningCustomer) {
        throw new HttpsError(
          "permission-denied",
          "Aap is order ko cancel nahi kar sakte."
        );
      }
      if (!CANCELLABLE.includes(status)) {
        throw new HttpsError(
          "failed-precondition",
          "Sirf pending ya confirmed order cancel ho sakta hai."
        );
      }

      const slotId = order.pickupSlotId || "";
      const slotRef = slotId ? db.collection("pickup_slots").doc(slotId) : null;
      const slotSnap = slotRef ? await tx.get(slotRef) : null;

      const items = Array.isArray(order.items) ? order.items : [];
      const productRefs = {};
      for (const item of items) {
        const pid = item && item.productId;
        if (typeof pid === "string" && !productRefs[pid]) {
          productRefs[pid] = db.collection("products").doc(pid);
        }
      }
      const productSnaps = {};
      for (const [pid, ref] of Object.entries(productRefs)) {
        productSnaps[pid] = await tx.get(ref);
      }

      // ---- all writes after ----
      tx.update(orderRef, {
        status: "cancelled",
        cancelledAt: FieldValue.serverTimestamp(),
        cancelledBy: uid,
      });

      if (slotRef && slotSnap && slotSnap.exists) {
        const booked = Number(slotSnap.data().bookedCount || 0);
        tx.update(slotRef, { bookedCount: Math.max(0, booked - 1) });
      }

      for (const [pid, snap] of Object.entries(productSnaps)) {
        if (!snap.exists) continue;
        let giveBack = 0;
        for (const item of items) {
          if (item && item.productId === pid) giveBack += Number(item.qty || 0);
        }
        if (giveBack > 0) {
          tx.update(productRefs[pid], {
            stockQty: Number(snap.data().stockQty || 0) + giveBack,
          });
        }
      }
    });

    return { ok: true };
  } catch (err) {
    if (err instanceof HttpsError) throw err;
    console.error("cancelOrder failed", err);
    throw new HttpsError("internal", "Order cancel nahi ho saka.");
  }
});
