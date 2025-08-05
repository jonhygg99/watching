import 'package:flutter/material.dart';

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
  bool _isExpanded = false;
  bool _showReadMore = false;
  final _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  void _checkTextOverflow() {
    final renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: widget.text,
          style: widget.style ?? const TextStyle(fontSize: 15),
        ),
        maxLines: widget.maxLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: renderBox.size.width);

      final isTextOverflowing = textPainter.didExceedMaxLines;
      if (mounted) {
        setState(() {
          _showReadMore = isTextOverflowing;
        });
      }
    }
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  String _getTextAfterMaxLines(String text, TextStyle style, double maxWidth, int maxLines) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    final position = textPainter.getPositionForOffset(Offset(
      textPainter.width,
      textPainter.height,
    ));
    
    final textAfterMaxLines = text.substring(position.offset);
    return textAfterMaxLines.trim().isNotEmpty ? textAfterMaxLines : '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final textStyle = widget.style ?? const TextStyle(fontSize: 15);
            final textSpan = TextSpan(text: widget.text, style: textStyle);
            final textPainter = TextPainter(
              text: textSpan,
              maxLines: widget.maxLines,
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: constraints.maxWidth);
            
            final needsFade = textPainter.didExceedMaxLines && !_isExpanded;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show text with fade effect only if it exceeds max lines
                needsFade
                    ? ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black,
                              Colors.black.withOpacity(0.0),
                            ],
                            stops: const [0.7, 1.0],
                          ).createShader(bounds);
                        },
                        child: Text(
                          widget.text,
                          style: textStyle,
                          maxLines: widget.maxLines,
                          overflow: TextOverflow.fade,
                          key: _textKey,
                        ),
                      )
                    : Text(
                        widget.text,
                        style: textStyle,
                        maxLines: _isExpanded ? null : widget.maxLines,
                        overflow: _isExpanded ? null : TextOverflow.ellipsis,
                        key: _textKey,
                      ),
                // Show additional content when expanded
                if (_isExpanded && _showReadMore)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: widget.animationDuration,
                    curve: widget.animationCurve,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: Text(
                      _getTextAfterMaxLines(widget.text, textStyle, constraints.maxWidth, widget.maxLines),
                      style: textStyle,
                    ),
                  ),
              ],
            );
          },
        ),
        if (_showReadMore)
          TextButton(
            onPressed: _toggleExpand,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isExpanded ? widget.collapseText : widget.expandText,
              style: widget.buttonStyle ??
                  const TextStyle(
                    fontSize: 14,
                  ),
            ),
          ),
      ],
    );
  }
}
