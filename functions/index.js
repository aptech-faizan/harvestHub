/**
 * HarvestHub trusted server operations.
 *
 * Why this exists
 * ---------------
 * Cancelling an order is a *compensating* transaction: it must set the order to
 * 'cancelled', give the stock back to products/{id}, and free capacity on
 * pickup_slots/{id}. Firestore security rules cannot verify that a stock
 * increment is legitimate, so they cannot safely let a customer write to
 * products. Granting that access would let any signed-in user set any stock
 * level.
 *
 * firestore.rules therefore permits a customer to move their own order to
 * 'cancelled' but NOT to write the compensating documents. Until this function
 * is deployed, a customer-initiated cancel is rejected by the rules; a farmer or
 * admin cancel still works because those roles may write products and slots.
 *
 * Deploy:  cd functions && npm install && firebase deploy --only functions
 */
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

/** Statuses an order may be cancelled from. Mirrors OrderStatus.next() in Dart. */
const CANCELLABLE = ["pending", "confirmed"];

exports.cancelOrder = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Please log in first.");
  }

  const orderId = request.data?.orderId;
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

      // ---- authorisation + state machine ----
      const callerDoc = await tx.get(db.collection("users").doc(uid));
      const role = callerDoc.exists ? callerDoc.data().role : null;
      const isAdmin = role === "admin";
      const isOwningFarmer = order.farmerId === uid;
      const isOwningCustomer = order.customerId === uid;

      if (!isAdmin && !isOwningFarmer && !isOwningCustomer) {
        throw new HttpsError(
          "permission-denied",
          "Aap is order ko cancel nahi kar sakte."
        );
      }
      if (isOwningCustomer && !isAdmin) {
        // A customer may only cancel while it is still cancellable.
        if (!CANCELLABLE.includes(status)) {
          throw new HttpsError(
            "failed-precondition",
            "Sirf pending ya confirmed order cancel ho sakta hai."
          );
        }
      } else if (!CANCELLABLE.includes(status)) {
        throw new HttpsError(
          "failed-precondition",
          "Sirf pending ya confirmed order cancel ho sakta hai."
        );
      }

      const slotId = order.pickupSlotId || "";
      const slotRef = slotId
        ? db.collection("pickup_slots").doc(slotId)
        : null;
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
        const stock = Number(snap.data().stockQty || 0);
        let giveBack = 0;
        for (const item of items) {
          if (item && item.productId === pid) {
            giveBack += Number(item.qty || 0);
          }
        }
        if (giveBack > 0) {
          tx.update(productRefs[pid], { stockQty: stock + giveBack });
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
