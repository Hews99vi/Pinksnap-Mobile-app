import 'package:cloud_firestore/cloud_firestore.dart';

/// One-time script to fix products with categoryKey='HOODIES' to 'HOODIE'
/// 
/// Run this from main.dart temporarily or via a button in admin panel
Future<void> fixHoodiesCategoryKey() async {
  final firestore = FirebaseFirestore.instance;
  final productsRef = firestore.collection('products');
  
  print('🔍 Searching for products with categoryKey="HOODIES"...');
  
  try {
    // Query products with incorrect categoryKey
    final querySnapshot = await productsRef
        .where('categoryKey', isEqualTo: 'HOODIES')
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      print('✅ No products found with categoryKey="HOODIES". All good!');
      return;
    }
    
    print('📝 Found ${querySnapshot.docs.length} product(s) to fix');
    
    // Update each product
    final batch = firestore.batch();
    for (var doc in querySnapshot.docs) {
      final productName = doc.data()['name'] ?? 'Unknown';
      print('   Fixing: $productName (${doc.id})');
      batch.update(doc.reference, {'categoryKey': 'HOODIE'});
    }
    
    // Commit all updates
    await batch.commit();
    
    print('✅ Successfully updated ${querySnapshot.docs.length} product(s)');
    print('   All products now have categoryKey="HOODIE"');
    
  } catch (e) {
    print('❌ Error fixing products: $e');
    rethrow;
  }
}
