import 'package:flutter/material.dart';

class LiveMarkdownEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final VoidCallback? onChanged;

  const LiveMarkdownEditor({
    super.key,
    required this.controller,
    this.hintText = 'Start typing...',
    this.textStyle,
    this.padding,
    this.height,
    this.onChanged,
  });

  @override
  State<LiveMarkdownEditor> createState() => _LiveMarkdownEditorState();
}

class _LiveMarkdownEditorState extends State<LiveMarkdownEditor> {
  late FocusNode _focusNode;
  bool _showPreview = false;
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final currentText = widget.controller.text;
    if (currentText != _lastText) {
      _lastText = currentText;
      if (_showPreview) {
        setState(() {});
      }
      widget.onChanged?.call();
    }
  }

  void _togglePreview() {
    setState(() {
      _showPreview = !_showPreview;
    });
  }

  bool _hasMarkdown() {
    final text = widget.controller.text;
    final patterns = [
      RegExp(r'\*\*.*?\*\*'),
      RegExp(r'\*.*?\*'),
      RegExp(r'`.*?`'),
      RegExp(r'==.*?==(?:\{[^}]+\})?'),
      RegExp(r'~~.*?~~'),
    ];
    return patterns.any((pattern) => pattern.hasMatch(text));
  }

  Widget _buildPreviewText() {
    return RichText(
      text: _parseMarkdownToSpans(widget.controller.text),
      textAlign: TextAlign.start,
    );
  }

  TextSpan _parseMarkdownToSpans(String text) {
    if (text.isEmpty) {
      return const TextSpan(text: '');
    }

    final baseStyle = widget.textStyle ?? _defaultTextStyle();
    List<TextSpan> spans = [];

    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      spans.addAll(_parseLineMarkdown(line, baseStyle));

      if (i < lines.length - 1) {
        spans.add(TextSpan(text: '\n', style: baseStyle));
      }
    }

    return TextSpan(children: spans);
  }

  List<TextSpan> _parseLineMarkdown(String line, TextStyle baseStyle) {
    if (line.isEmpty) {
      return [TextSpan(text: line, style: baseStyle)];
    }

    List<TextSpan> spans = [];
    int lastIndex = 0;

    final patterns = [
      _MarkdownPattern(
        regex: RegExp(r'\*\*(.*?)\*\*'),
        builder: (text) => TextSpan(
          text: text,
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      _MarkdownPattern(
        regex: RegExp(r'(?<!\*)\*([^*\n]+)\*(?!\*)'),
        builder: (text) => TextSpan(
          text: text,
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ),
      ),
      _MarkdownPattern(
        regex: RegExp(r'`([^`\n]+)`'),
        builder: (text) => TextSpan(
          text: text,
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      _MarkdownPattern(
        regex: RegExp(r'==(.*?)==(?:\{([^}]+)\})?'),
        builder: (text) => TextSpan(
          text: text,
          style: baseStyle.copyWith(
            backgroundColor: Colors.yellow.withOpacity(0.3),
          ),
        ),
      ),
      _MarkdownPattern(
        regex: RegExp(r'~~(.*?)~~'),
        builder: (text) => TextSpan(
          text: text,
          style: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
        ),
      ),
    ];

    List<_MarkdownMatch> allMatches = [];
    for (final pattern in patterns) {
      for (final match in pattern.regex.allMatches(line)) {
        String matchText = match.group(1) ?? '';

        if (pattern.regex.pattern.contains('==')) {
          final colorMatch = match.group(2);
          if (colorMatch != null) {
            allMatches.add(
              _MarkdownMatch(
                start: match.start,
                end: match.end,
                text: matchText,
                pattern: _createHighlightPattern(baseStyle, colorMatch),
              ),
            );
          } else {
            allMatches.add(
              _MarkdownMatch(
                start: match.start,
                end: match.end,
                text: matchText,
                pattern: pattern,
              ),
            );
          }
        } else {
          allMatches.add(
            _MarkdownMatch(
              start: match.start,
              end: match.end,
              text: matchText,
              pattern: pattern,
            ),
          );
        }
      }
    }

    allMatches.sort((a, b) => a.start.compareTo(b.start));
    allMatches = _removeOverlaps(allMatches);

    for (final match in allMatches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: line.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      spans.add(match.pattern.builder(match.text));

      lastIndex = match.end;
    }

    if (lastIndex < line.length) {
      spans.add(TextSpan(text: line.substring(lastIndex), style: baseStyle));
    }

    return spans.isEmpty ? [TextSpan(text: line, style: baseStyle)] : spans;
  }

  _MarkdownPattern _createHighlightPattern(
    TextStyle baseStyle,
    String colorName,
  ) {
    Color backgroundColor;
    switch (colorName.toLowerCase()) {
      case 'blue':
        backgroundColor = Colors.blue.withOpacity(0.3);
        break;
      case 'green':
        backgroundColor = Colors.green.withOpacity(0.3);
        break;
      case 'pink':
        backgroundColor = Colors.pink.withOpacity(0.3);
        break;
      case 'orange':
        backgroundColor = Colors.orange.withOpacity(0.3);
        break;
      case 'purple':
        backgroundColor = Colors.purple.withOpacity(0.3);
        break;
      case 'red':
        backgroundColor = Colors.red.withOpacity(0.3);
        break;
      case 'cyan':
        backgroundColor = Colors.cyan.withOpacity(0.3);
        break;
      default:
        backgroundColor = Colors.yellow.withOpacity(0.3);
    }

    return _MarkdownPattern(
      regex: RegExp(r'==(.*?)==(?:\{([^}]+)\})?'),
      builder: (text) => TextSpan(
        text: text,
        style: baseStyle.copyWith(backgroundColor: backgroundColor),
      ),
    );
  }

  List<_MarkdownMatch> _removeOverlaps(List<_MarkdownMatch> matches) {
    if (matches.length <= 1) return matches;

    List<_MarkdownMatch> result = [matches.first];

    for (int i = 1; i < matches.length; i++) {
      final current = matches[i];
      final last = result.last;

      if (current.start >= last.end) {
        result.add(current);
      }
    }

    return result;
  }

  TextStyle _defaultTextStyle() {
    return const TextStyle(fontSize: 18, fontFamily: 'system', height: 1.5);
  }

  @override
  Widget build(BuildContext context) {
    final hasMarkdown = _hasMarkdown();

    return Container(
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Markdown Editor',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (hasMarkdown) ...[
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text('Preview', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(width: 10),
                Switch.adaptive(
                  value: _showPreview,
                  onChanged: (value) => _togglePreview(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _showPreview && hasMarkdown
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildEditor()),
                      const SizedBox(width: 20),

                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Live Preview',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: _buildPreviewText(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: widget.textStyle ?? _defaultTextStyle(),
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        cursorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _MarkdownPattern {
  final RegExp regex;
  final TextSpan Function(String text) builder;

  _MarkdownPattern({required this.regex, required this.builder});
}

class _MarkdownMatch {
  final int start;
  final int end;
  final String text;
  final _MarkdownPattern pattern;

  _MarkdownMatch({
    required this.start,
    required this.end,
    required this.text,
    required this.pattern,
  });
}
