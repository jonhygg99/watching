import 'package:flutter/material.dart';

class SkeletonHeader extends StatelessWidget {
  const SkeletonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: size.height * 0.65,
        child: Container(
          width: double.infinity,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}
