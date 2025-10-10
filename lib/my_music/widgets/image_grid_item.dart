import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicxy/services/analytics_helper.dart';

class ImageGridItem extends StatelessWidget {
  final Uint8List imageBytes;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onDownload;

  const ImageGridItem({
    super.key,
    required this.imageBytes,
    required this.index,
    required this.onTap,
    required this.onDelete,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AnalyticsHelper.logButtonTap('image_grid_item_tap_$index',
            screenName: 'MyImagesScreen');
        onTap();
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onDownload != null)
                  _GlassyIconButton(
                    icon: Icons.download,
                    onTap: () {
                      AnalyticsHelper.logButtonTap(
                          'image_grid_item_download_$index',
                          screenName: 'MyImagesScreen');
                      onDownload!();
                    },
                  ),
                if (onDownload != null) const SizedBox(width: 8),
                _GlassyIconButton(
                  icon: Icons.delete_outline,
                  onTap: () {
                    AnalyticsHelper.logButtonTap(
                        'image_grid_item_delete_$index',
                        screenName: 'MyImagesScreen');
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassyIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
