import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category Migration Tool
//
// Step-by-step:
//   1. Fetch all documents from 'categories' collection
//   2. Find "Fruits" (Title Case) and "fruits" (lowercase) documents
//   3. Find all products whose categoryId == lowercase doc ID
//   4. Batch-update those products to point at Title Case doc ID
//   5. Delete the lowercase "fruits" document
//
// Run: flutter run -t lib/migrate_category.dart
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MigrationApp());
}

class MigrationApp extends StatelessWidget {
  const MigrationApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Category Migration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const MigrationScreen(),
    );
  }
}

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});
  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  final _db = FirebaseFirestore.instance;
  final List<String> _log = [];
  bool _running = false;
  bool _done = false;

  void _addLog(String msg) {
    setState(() => _log.add(msg));
  }

  Future<void> _runMigration() async {
    setState(() {
      _running = true;
      _log.clear();
      _done = false;
    });

    try {
      // ── Step 1: Fetch all categories ────────────────────────────────────
      _addLog('📂 Step 1: categories collection fetch kar raha hoon...');
      final catSnap = await _db.collection('categories').get();
      _addLog('   Total category documents: ${catSnap.docs.length}');

      for (final doc in catSnap.docs) {
        final name = doc.data()['name'] ?? '';
        _addLog('   ID: "${doc.id}"  →  name: "$name"');
      }

      // ── Step 2: Identify Title-Case and lowercase duplicates ─────────────
      _addLog('\n🔍 Step 2: "Fruits" aur "fruits" documents dhundh raha hoon...');

      QueryDocumentSnapshot<Map<String, dynamic>>? titleCaseDoc;
      QueryDocumentSnapshot<Map<String, dynamic>>? lowercaseDoc;

      for (final doc in catSnap.docs) {
        final name = (doc.data()['name'] ?? '').toString();
        if (name == 'Fruits') titleCaseDoc = doc;
        if (name == 'fruits') lowercaseDoc = doc;
      }

      if (titleCaseDoc == null) {
        _addLog('❌ ERROR: "Fruits" (Title Case) document nahi mila! Migration abort.');
        return;
      }
      _addLog('   ✅ "Fruits" document ID: "${titleCaseDoc.id}"');

      if (lowercaseDoc == null) {
        _addLog('   ℹ️  "fruits" (lowercase) document nahi mila.');
        _addLog('   → Ya to already delete ho chuka hai, ya kabhi tha hi nahi.');
        _addLog('\n✅ Koi migration zaroorat nahi. Kaam khatam!');
        return;
      }
      _addLog('   ⚠️  "fruits" duplicate document ID: "${lowercaseDoc.id}"');

      // ── Step 3: Products query — kitne lowercase ID se linked hain ───────
      _addLog('\n📦 Step 3: Products query — categoryId == "${lowercaseDoc.id}"');
      final productsSnap = await _db
          .collection('products')
          .where('categoryId', isEqualTo: lowercaseDoc.id)
          .get();

      _addLog('   Match karne wale products: ${productsSnap.docs.length}');
      for (final p in productsSnap.docs) {
        final name = p.data()['itemName'] ?? 'Unknown';
        _addLog('   → Product ID: "${p.id}"  itemName: "$name"');
      }

      // ── Step 4: Batch update — re-link to Title Case doc ─────────────────
      if (productsSnap.docs.isNotEmpty) {
        _addLog('\n🔄 Step 4: Batch update — ${productsSnap.docs.length} products ko re-link kar raha hoon...');

        // Firestore batch max 500 writes — yahan products chhote hain
        final batch = _db.batch();
        for (final p in productsSnap.docs) {
          batch.update(p.reference, {
            'categoryId': titleCaseDoc.id,
            'categoryName': 'Fruits', // consistency ke liye
          });
          _addLog('   ✏️  Updating "${p.data()['itemName']}" → categoryId: "${titleCaseDoc.id}"');
        }
        await batch.commit();
        _addLog('   ✅ Batch commit successful — ${productsSnap.docs.length} products re-linked!');
      } else {
        _addLog('\n✅ Step 4: Koi product lowercase ID se linked nahi tha — update ki zaroorat nahi.');
      }

      // ── Step 5: Verify then delete ────────────────────────────────────────
      _addLog('\n🔎 Step 5: Delete se pehle verify...');
      final verifySnap = await _db
          .collection('products')
          .where('categoryId', isEqualTo: lowercaseDoc.id)
          .get();

      if (verifySnap.docs.isNotEmpty) {
        _addLog('❌ ERROR: ${verifySnap.docs.length} products abhi bhi lowercase ID se linked hain!');
        _addLog('   Delete abort. Manually check karo.');
        return;
      }

      _addLog('   ✅ Verify passed — koi product lowercase ID se linked nahi.');
      _addLog('\n🗑️  "fruits" document delete kar raha hoon (ID: "${lowercaseDoc.id}")...');
      await _db.collection('categories').doc(lowercaseDoc.id).delete();
      _addLog('   ✅ DELETE successful!');

      // ── Final Summary ─────────────────────────────────────────────────────
      _addLog('\n══════════════════════════════════════════════');
      _addLog('✅ MIGRATION COMPLETE');
      _addLog('   Keep kiya:  "${titleCaseDoc.id}" → name: "Fruits"');
      _addLog('   Delete kiya: "${lowercaseDoc.id}" → name: "fruits"');
      _addLog('   Re-linked products: ${productsSnap.docs.length}');
      _addLog('══════════════════════════════════════════════');

      setState(() => _done = true);
    } catch (e, st) {
      _addLog('\n❌ EXCEPTION: $e');
      _addLog('   StackTrace: $st');
    } finally {
      setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Migration Tool'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning banner
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('Migration Tool',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800)),
                    ]),
                    const SizedBox(height: 4),
                    const Text(
                      'Ye tool "fruits" (lowercase) category ke products ko\n'
                      '"Fruits" (Title Case) se re-link karega, phir duplicate delete karega.\n'
                      'Ek baar chalao — dobara chalane par safely no-op ho jata hai.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _running ? null : _runMigration,
              icon: _running
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_arrow),
              label: Text(_running
                  ? 'Migration chal rahi hai...'
                  : _done
                      ? '✅ Migration Complete — Dobara chalao?'
                      : 'Migration Shuru Karo'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _done ? Colors.green : Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            // Log output
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: _log.isEmpty
                    ? const Center(
                        child: Text('Log yahan dikhega...',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _log.length,
                        itemBuilder: (_, i) {
                          final line = _log[i];
                          Color color = Colors.grey.shade300;
                          if (line.contains('✅')) color = Colors.greenAccent;
                          if (line.contains('❌')) color = Colors.redAccent;
                          if (line.contains('⚠️')) color = Colors.amberAccent;
                          if (line.contains('🔄') || line.contains('✏️')) {
                            color = Colors.lightBlueAccent;
                          }
                          return Text(line,
                              style:
                                  TextStyle(color: color, fontSize: 12, fontFamily: 'monospace'));
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
