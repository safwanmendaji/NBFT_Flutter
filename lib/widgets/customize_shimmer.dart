import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomizedShimmerScreen extends StatelessWidget {
  final Widget child;
  const CustomizedShimmerScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      enabled: true,
      baseColor: Colors.grey.withOpacity(0.3),
      highlightColor: Colors.grey.withOpacity(0.1),
      child: child,
    );
  }
}
