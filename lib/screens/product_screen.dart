import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import 'package:store_management/l10n/app_localizations.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ProductController>().loadProducts();
      }
    });
  }

  void _filterProducts(String query) {
    final products = context.read<ProductController>().products;
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = products;
      } else {
        _filteredProducts = products.where((p) {
          return p.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToAddProduct() {
    Navigator.pushNamed(context, '/add-product').then((_) {
      if (mounted) {
        context.read<ProductController>().loadProducts();
      }
    });
  }

  void _deleteProduct(Product product) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final String txtCancel = isAr ? 'إلغاء' : 'Annuler';
    final String txtConfirm =
        isAr ? 'هل أنت متأكد من حذف' : 'Confirmer la suppression de';
    final String txtDeleted =
        isAr ? 'تم حذف المنتج بنجاح' : 'Produit supprimé avec succès';

    showDialog(
      context: context,
      barrierDismissible: !_isDeleting,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.delete),
          content: Text('$txtConfirm ${product.name} ?'),
          actions: [
            TextButton(
              onPressed: _isDeleting ? null : () => Navigator.pop(ctx),
              child: Text(txtCancel),
            ),
            TextButton(
              onPressed: _isDeleting
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      setState(() => _isDeleting = true);
                      try {
                        await context
                            .read<ProductController>()
                            .deleteProduct(product.id!);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(txtDeleted),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Erreur lors de la suppression sur le serveur.'),
                            backgroundColor: Color(0xFFBA1A1A),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _isDeleting = false);
                      }
                    },
              child: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>().products;
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final String txtSearch =
        isAr ? 'بحث عن منتج...' : 'Rechercher un produit...';
    final String txtTitle = isAr ? 'إدارة المخزون' : l10n.products;

    if (_searchController.text.isEmpty) {
      _filteredProducts = products;
    } else {
      _filteredProducts = products.where((p) {
        return p.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _isDeleting
          ? PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: const LinearProgressIndicator(color: Color(0xFF4361ee)),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: const Color(0xFF4361ee),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar avec titre dynamique ──────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF8F9FA),
            expandedHeight: 100,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchController.text.isEmpty
                          ? txtTitle
                          : (isAr
                              ? 'نتائج البحث عن: "${_searchController.text}"'
                              : 'Résultats pour: "${_searchController.text}"'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Barre de recherche ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: _filterProducts,
                decoration: InputDecoration(
                  hintText: txtSearch,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

          // ── Grille premium 2 colonnes ───────────────────────────────────
          _filteredProducts.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildProductCard(_filteredProducts[index]),
                      childCount: _filteredProducts.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361ee).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Color(0xFF4361ee),
                    size: 24,
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: _isDeleting ? null : () => _deleteProduct(product),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.quantity}: ${product.quantity}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.price,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${product.price.toStringAsFixed(0)} MRU',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4361ee),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Color(0xFF4361ee),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noProducts,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(l10n.addProduct),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navigateToAddProduct,
            child: Text(l10n.addProduct),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
