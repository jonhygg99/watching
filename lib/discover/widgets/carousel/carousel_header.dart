import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/fonts.dart';
import 'package:watching/shared/constants/measures.dart';

class CarouselHeader extends StatelessWidget {
  const CarouselHeader({super.key, required this.title, this.onViewMore});

  final String title;
  final VoidCallback? onViewMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: kSpacePhoneHorizontal,
        right: kSpacePhoneHorizontal,
        bottom: kSpaceBtwTitleWidget,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: kMediumTitleFontSize,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onViewMore != null)
            TextButton(
              onPressed: onViewMore,
              child: Text(
                AppLocalizations.of(context)?.viewMore ?? 'View More',
                style: TextStyle(
                  fontSize: 14.0, // kFontSizeButtonTextViewMore
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
