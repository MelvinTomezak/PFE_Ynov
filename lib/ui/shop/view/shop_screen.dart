import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/load_status.dart';
import '../../../data/models/product.dart';
import '../../common/error_state.dart';
import '../viewmodel/shop_viewmodel.dart';

/// Écran « Boutique » : catalogue du merchandising STYMA.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopViewModel()..load(),
      child: const _ShopView(),
    );
  }
}

class _ShopView extends StatelessWidget {
  const _ShopView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopViewModel>();

    switch (vm.status) {
      case LoadStatus.loading:
      case LoadStatus.idle:
        return const Center(child: CircularProgressIndicator());
      case LoadStatus.error:
        return ErrorState(
          message: vm.errorMessage!,
          onRetry: () => context.read<ShopViewModel>().load(),
        );
      case LoadStatus.success:
        if (vm.products.isEmpty) {
          return const Center(child: Text('La boutique est vide.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemCount: vm.products.length,
          itemBuilder: (context, index) =>
              _ProductCard(product: vm.products[index]),
        );
    }
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ProductDetail(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _ProductImage(imageUrl: product.imageUrl)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.category!,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Image du produit (ou repli dégradé si aucune image).
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  const _ProductImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
      );
    }
    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.neonGradient),
      child: const Icon(Icons.checkroom, size: 44, color: Colors.white),
    );
  }
}

/// Fiche détail affichée dans un panneau glissant.
class _ProductDetail extends StatelessWidget {
  final Product product;
  const _ProductDetail({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: _ProductImage(imageUrl: product.imageUrl),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            product.formattedPrice,
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (product.description != null) ...[
            const SizedBox(height: 12),
            Text(
              product.description!,
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.5),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Boutique bientôt disponible.')),
                );
              },
              child: const Text('Ajouter au panier'),
            ),
          ),
        ],
      ),
    );
  }
}
