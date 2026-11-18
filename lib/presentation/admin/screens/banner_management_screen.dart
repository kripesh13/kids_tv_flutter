import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/banner_model.dart';
import '../../providers/banners_provider.dart';
import '../dialogs/banner_form_dialog.dart';

class BannerManagementScreen extends ConsumerWidget {
  const BannerManagementScreen({super.key});

  void _openDialog(BuildContext context, WidgetRef ref, [BannerModel? banner]) {
    showDialog(
      context: context,
      builder: (ctx) => BannerFormDialog(
        initialBanner: banner,
        onSave: (saved) {
          ref.read(bannersProvider.notifier).saveBanner(saved);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(banner == null ? 'Banner created!' : 'Banner updated!')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(bannersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Featured Banners Manager', style: AppTypography.headlineLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Banner'),
              onPressed: () => _openDialog(context, ref),
            ),
          ),
        ],
      ),
      body: bannersAsync.when(
        data: (banners) {
          if (banners.isEmpty) {
            return const Center(child: Text('No banners found. Create one above!'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: banners.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 140,
                          height: 80,
                          child: CachedNetworkImage(
                            imageUrl: banner.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(color: AppColors.primary),
                            errorWidget: (_, _, _) => Container(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(banner.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            if (banner.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(banner.subtitle!,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            ],
                            const SizedBox(height: 4),
                            Text('Action: ${banner.actionType.label} • Target: ${banner.actionTarget}',
                                style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                            onPressed: () => _openDialog(context, ref, banner),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () {
                              ref.read(bannersProvider.notifier).deleteBanner(banner.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
