import 'package:flutter/material.dart';
import 'package:watching/shared/constants/colors.dart';

/// A widget that displays a text that can be expanded to show more text.
///
/// The widget will show a "Read more" button if the text is too long and
/// exceeds the given [maxLines] limit. When the button is pressed, the
/// widget will expand to show the full text. After expanding, the button
/// text will change to "Read less" and pressing it will collapse the widget
/// back to the original size.
///
/// The style of the text and button can be customized using [style] and
/// [buttonStyle] respectively.
///
/// The animation duration and curve can be customized using [animationDuration]
/// and [animationCurve] respectively.
///
/// The default values are:
///
/// - [maxLines]: 3
/// - [expandText]: "Read more"
/// - [collapseText]: "Read less"
/// - [animationDuration]: 200 milliseconds
/// - [animationCurve]: Curves.easeInOut
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final String expandText;
  final String collapseText;
  final TextStyle? buttonStyle;
  final Duration animationDuration;
  final Curve animationCurve;

  const ExpandableText(
    this.text, {
    super.key,
    this.maxLines = 3,
    this.style,
    this.expandText = 'Read more',
    this.collapseText = 'Read less',
    this.buttonStyle,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  // Tracks if the text is in expanded state
  bool _isExpanded = false;
  // Controls visibility of the 'Read more' button
  bool _showReadMore = false;
  // Key to access the text widget for size calculations
  final _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Schedule the overflow check after the first frame is rendered
    // This ensures we have valid dimensions to work with
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  /// Checks if the text overflows the maximum allowed lines
  /// and updates the _showReadMore state accordingly
  void _checkTextOverflow() {
    // Get the render box of the text widget to measure its dimensions
    final renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      // Create a TextPainter to measure text dimensions
      final textPainter = TextPainter(
        text: TextSpan(
          text: widget.text,
          style: widget.style ?? const TextStyle(fontSize: 15),
        ),
        maxLines: widget.maxLines,
        textDirection: TextDirection.ltr,
      )..layout(
        maxWidth: renderBox.size.width,
      ); // Set the max width to the available width

      // Check if the text overflows the specified number of lines
      final isTextOverflowing = textPainter.didExceedMaxLines;

      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          _showReadMore = isTextOverflowing;
        });
      }
    }
  }

  /// Toggles between expanded and collapsed states
  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LayoutBuilder provides constraints based on available space
        LayoutBuilder(
          builder: (context, constraints) {
            // Get text style with fallback to default
            final textStyle = widget.style ?? const TextStyle(fontSize: 15);
            // Create a TextSpan for text measurement
            final textSpan = TextSpan(text: widget.text, style: textStyle);

            // Measure text to determine if it overflows
            final textPainter = TextPainter(
              text: textSpan,
              maxLines: widget.maxLines,
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: constraints.maxWidth);

            // Determine if we need to show the fade effect
            // (only when text overflows and is not expanded)
            final needsFade = textPainter.didExceedMaxLines && !_isExpanded;

            // AnimatedSize handles smooth transitions between states
            return AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                // Ensure text doesn't exceed available width
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show either expanded or collapsed text
                    _isExpanded
                        // Expanded state - show all text
                        ? Text(widget.text, style: textStyle, key: _textKey)
                        // Collapsed state - apply fade effect if needed
                        : ShaderMask(
                          // Creates a gradient mask for the fade effect
                          shaderCallback: (Rect bounds) {
                            final theme = Theme.of(context);
                            final color =
                                theme.brightness == Brightness.dark
                                    ? kScaffoldLightBackgroundColor
                                    : kScaffoldDarkBackgroundColor;
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withValues(
                                  alpha: 1.0,
                                ), // Opaque at the top
                                color.withValues(
                                  alpha: needsFade ? 0.0 : 1.0,
                                ), // Transparent at bottom if needed
                              ],
                              // Position the gradient (70% opaque, 100% transparent)
                              stops: needsFade ? const [0.7, 1.0] : null,
                            ).createShader(bounds);
                          },
                          child: Text(
                            widget.text,
                            style: textStyle,
                            maxLines: widget.maxLines,
                            overflow:
                                TextOverflow.fade, // Fade the overflow text
                            key: _textKey, // Key for measuring text dimensions
                          ),
                        ),
                  ],
                ),
              ),
            );
          },
        ),
        // Show 'Read more/less' button only if text overflows
        if (_showReadMore)
          TextButton(
            onPressed: _toggleExpand,
            // Minimal button styling
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero, // Remove default padding
              minimumSize: Size.zero, // Make button as small as its content
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap, // Minimize tap target
            ),
            child: Text(
              // Toggle between 'Read more' and 'Read less' text
              _isExpanded ? widget.collapseText : widget.expandText,
              style: widget.buttonStyle ?? const TextStyle(fontSize: 14),
            ),
          ),
      ],
    );
  }
}
