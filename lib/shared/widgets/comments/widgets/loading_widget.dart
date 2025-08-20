import 'package:flutter/material.dart';

class CommentsLoadingWidget extends StatelessWidget {
  final bool isInitialLoad;

  const CommentsLoadingWidget({
    super.key,
    this.isInitialLoad = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isInitialLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      ),
    );
  }
}
