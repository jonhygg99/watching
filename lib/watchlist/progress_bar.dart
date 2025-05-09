import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double percent;
  final int watched;
  final int total;

  const ProgressBar({
    super.key,
    required this.percent,
    required this.watched,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text('$watched/$total', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
