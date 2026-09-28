import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_shimmer.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomizedCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final String? errorImage;
  final Color? color;

  const CustomizedCachedImage(
      {required this.imageUrl,
      this.height = 77,
      this.width = 77,
      this.errorImage,
      super.key,
      this.color});

  @override
  Widget build(BuildContext context) {
    return imageUrl == null || imageUrl!.isEmpty
        ? Image.asset(
            errorImage!.isNotEmpty ? errorImage! : AppIcons.icApp,
            height: height,
            width: width,
            fit: BoxFit.cover,
          )
        : CachedNetworkImage(
            imageUrl: imageUrl ?? '',
            height: height,
            width: width,
            color: color,
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return CustomizedShimmerScreen(
                child: Container(
                  height: height,
                  width: width,
                  color: AppColors.primary,
                ),
              );
            },
            errorWidget: (context, url, error) {
              return Image.asset(
                // errorImage ?? '',
                errorImage ?? AppIcons.icApp,
                height: height,
                width: width,
                fit: BoxFit.cover,
              );
            },
          );
  }
}
