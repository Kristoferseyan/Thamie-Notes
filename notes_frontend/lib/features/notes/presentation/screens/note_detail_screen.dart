import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_service.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../widgets/live_markdown_editor.dart';
import '../../../folders/presentation/bloc/folder_bloc.dart';
import '../../../folders/presentation/bloc/folder_event.dart';
import '../../../folders/presentation/bloc/folder_state.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;
  final bool isReadOnly;

  const NoteDetailScreen({super.key, this.note, this.isReadOnly = false});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen>
    with TickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late AnimationController _toolbarAnimationController;
  late AnimationController _saveAnimationController;
  late Animation<double> _toolbarSlideAnimation;
  late Animation<double> _saveScaleAnimation;

  bool _isEditing = false;
  bool _hasChanges = false;
  bool _showToolbar = false;
  String _selectedHighlightColor = 'yellow';
  String? _selectedFolderId;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _selectedFolderId = widget.note?.folderId;

    // Load folders for selection
    context.read<FolderBloc>().add(FoldersLoadRequested());

    _toolbarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _toolbarSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _toolbarAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _saveScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _saveAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _isEditing = widget.note == null;
    if (_isEditing) {
      _showToolbar = true;
      _toolbarAnimationController.forward();
    }

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
    _contentFocusNode.addListener(_onContentFocusChanged);
  }

  void _onContentFocusChanged() {
    if (_contentFocusNode.hasFocus && _isEditing) {
      setState(() {
        _showToolbar = true;
      });
      _toolbarAnimationController.forward();
    }
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _toolbarAnimationController.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _showToolbar = true;
        _toolbarAnimationController.forward();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _contentFocusNode.requestFocus();
        });
      } else {
        _showToolbar = false;
        _toolbarAnimationController.reverse();
        _titleController.text = widget.note?.title ?? '';
        _contentController.text = widget.note?.content ?? '';
        _hasChanges = false;
      }
    });
  }

  void _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Title cannot be empty', isError: true);
      return;
    }

    _saveAnimationController.forward().then((_) {
      _saveAnimationController.reverse();
    });

    HapticFeedback.lightImpact();

    if (widget.note == null) {
      context.read<NotesBloc>().add(
        NotesCreateRequested(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          folderId: _selectedFolderId,
        ),
      );
    } else {
      context.read<NotesBloc>().add(
        NotesUpdateRequested(
          id: widget.note!.id!,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          folderId: _selectedFolderId,
        ),
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _applyMarkdownFormat(
    String prefix,
    String suffix, {
    String? placeholder,
  }) {
    final selection = _contentController.selection;
    final text = _contentController.text;

    if (selection.isValid) {
      String selectedText = selection.textInside(text);
      if (selectedText.isEmpty && placeholder != null) {
        selectedText = placeholder;
      }

      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );

      _contentController.text = newText;

      final newCursorPos =
          selection.start + prefix.length + selectedText.length + suffix.length;
      _contentController.selection = TextSelection.collapsed(
        offset: newCursorPos,
      );
    } else {
      final cursorPos = _contentController.selection.baseOffset;
      final insertText = placeholder != null
          ? '$prefix$placeholder$suffix'
          : prefix;

      final newText = text.replaceRange(cursorPos, cursorPos, insertText);
      _contentController.text = newText;

      if (placeholder != null) {
        _contentController.selection = TextSelection(
          baseOffset: cursorPos + prefix.length,
          extentOffset: cursorPos + prefix.length + placeholder.length,
        );
      } else {
        _contentController.selection = TextSelection.collapsed(
          offset: cursorPos + insertText.length,
        );
      }
    }
  }

  void _makeBold() =>
      _applyMarkdownFormat('**', '**', placeholder: 'bold text');
  void _makeItalic() =>
      _applyMarkdownFormat('*', '*', placeholder: 'italic text');
  void _makeCode() => _applyMarkdownFormat('`', '`', placeholder: 'code');
  void _makeStrikethrough() =>
      _applyMarkdownFormat('~~', '~~', placeholder: 'strikethrough');

  void _makeHeading(int level) {
    final prefix = '${'#' * level} ';
    _applyMarkdownFormat(prefix, '', placeholder: 'Heading $level');
  }

  void _makeList() {
    final selection = _contentController.selection;
    final text = _contentController.text;

    if (selection.isValid && selection.start != selection.end) {
      final selectedText = selection.textInside(text);
      final lines = selectedText.split('\n');

      final processedLines = lines.map((line) {
        if (RegExp(r'^\s*[-*+]\s+').hasMatch(line)) {
          return line;
        } else if (RegExp(r'^\s*\d+\.\s+').hasMatch(line)) {
          return line;
        } else {
          final match = RegExp(r'^(\s*)(.*)').firstMatch(line);
          if (match != null) {
            final indent = match.group(1) ?? '';
            final content = match.group(2) ?? '';
            if (content.isNotEmpty) {
              return '$indent- $content';
            }
            return line;
          }
          return '- $line';
        }
      }).toList();

      final newText = text.replaceRange(
        selection.start,
        selection.end,
        processedLines.join('\n'),
      );

      _contentController.text = newText;

      final addedChars = processedLines.join('\n').length - selectedText.length;
      _contentController.selection = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.end + addedChars,
      );
    } else {
      final cursorPos = selection.baseOffset;

      int lineStart = text.lastIndexOf('\n', cursorPos - 1) + 1;

      int lineEnd = text.indexOf('\n', cursorPos);
      if (lineEnd == -1) lineEnd = text.length;
      final currentLine = text.substring(lineStart, lineEnd);

      if (RegExp(r'^\s*[-*+]\s+').hasMatch(currentLine)) {
        return;
      } else if (RegExp(r'^\s*\d+\.\s+').hasMatch(currentLine)) {
        return;
      }

      final newText = text.replaceRange(lineStart, lineStart, '- ');
      _contentController.text = newText;
      _contentController.selection = TextSelection.collapsed(
        offset: cursorPos + 2,
      );
    }
  }

  void _makeNumberedList() {
    final selection = _contentController.selection;
    final text = _contentController.text;

    if (selection.isValid && selection.start != selection.end) {
      final selectedText = selection.textInside(text);
      final lines = selectedText.split('\n');

      int counter = 1;
      final processedLines = lines.map((line) {
        if (RegExp(r'^\s*\d+\.\s+').hasMatch(line)) {
          return line;
        } else if (RegExp(r'^\s*[-*+]\s+').hasMatch(line)) {
          return line;
        } else {
          final match = RegExp(r'^(\s*)(.*)').firstMatch(line);
          if (match != null) {
            final indent = match.group(1) ?? '';
            final content = match.group(2) ?? '';
            if (content.isNotEmpty) {
              return '$indent${counter++}. $content';
            }
            return line;
          }
          return '${counter++}. $line';
        }
      }).toList();

      final newText = text.replaceRange(
        selection.start,
        selection.end,
        processedLines.join('\n'),
      );

      _contentController.text = newText;

      final addedChars = processedLines.join('\n').length - selectedText.length;
      _contentController.selection = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.end + addedChars,
      );
    } else {
      final cursorPos = selection.baseOffset;

      int lineStart = text.lastIndexOf('\n', cursorPos - 1) + 1;

      int lineEnd = text.indexOf('\n', cursorPos);
      if (lineEnd == -1) lineEnd = text.length;
      final currentLine = text.substring(lineStart, lineEnd);

      if (RegExp(r'^\s*\d+\.\s+').hasMatch(currentLine)) {
        return;
      } else if (RegExp(r'^\s*[-*+]\s+').hasMatch(currentLine)) {
        return;
      }

      final newText = text.replaceRange(lineStart, lineStart, '1. ');
      _contentController.text = newText;
      _contentController.selection = TextSelection.collapsed(
        offset: cursorPos + 3,
      );
    }
  }

  void _makeQuote() {
    final selection = _contentController.selection;
    final text = _contentController.text;
    final cursorPos = selection.baseOffset;

    int lineStart = text.lastIndexOf('\n', cursorPos - 1) + 1;

    final newText = text.replaceRange(lineStart, lineStart, '> ');
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: cursorPos + 2,
    );
  }

  void _makeHighlight() {
    final selection = _contentController.selection;
    final text = _contentController.text;

    if (selection.isValid && selection.start != selection.end) {
      String selectedText = selection.textInside(text);

      RegExp existingHighlightRegex = RegExp(r'^==(.*?)==(?:\{([^}]+)\})?$');
      Match? existingMatch = existingHighlightRegex.firstMatch(selectedText);

      String newText;
      if (existingMatch != null) {
        String innerText = existingMatch.group(1) ?? '';
        newText = '==$innerText=={$_selectedHighlightColor}';
      } else {
        newText = '==$selectedText=={$_selectedHighlightColor}';
      }

      final updatedText = text.replaceRange(
        selection.start,
        selection.end,
        newText,
      );

      _contentController.text = updatedText;

      final newCursorPos = selection.start + newText.length;
      _contentController.selection = TextSelection.collapsed(
        offset: newCursorPos,
      );
    } else {
      final cursorPos = _contentController.selection.baseOffset;
      final expandedSelection = _findHighlightAtCursor(text, cursorPos);

      if (expandedSelection != null) {
        String selectedText = text.substring(
          expandedSelection.start,
          expandedSelection.end,
        );
        RegExp existingHighlightRegex = RegExp(r'^==(.*?)==(?:\{([^}]+)\})?$');
        Match? existingMatch = existingHighlightRegex.firstMatch(selectedText);

        if (existingMatch != null) {
          String innerText = existingMatch.group(1) ?? '';
          String newText = '==$innerText=={$_selectedHighlightColor}';

          final updatedText = text.replaceRange(
            expandedSelection.start,
            expandedSelection.end,
            newText,
          );

          _contentController.text = updatedText;
          _contentController.selection = TextSelection.collapsed(
            offset: expandedSelection.start + newText.length,
          );
          return;
        }
      }

      final insertText = '==highlighted text=={$_selectedHighlightColor}';

      final newText = text.replaceRange(cursorPos, cursorPos, insertText);
      _contentController.text = newText;

      _contentController.selection = TextSelection(
        baseOffset: cursorPos + 2,
        extentOffset: cursorPos + 2 + 'highlighted text'.length,
      );
    }
  }

  TextSelection? _findHighlightAtCursor(String text, int cursorPos) {
    RegExp highlightRegex = RegExp(r'==(.*?)==(?:\{([^}]+)\})?');

    for (Match match in highlightRegex.allMatches(text)) {
      if (cursorPos >= match.start && cursorPos <= match.end) {
        return TextSelection(baseOffset: match.start, extentOffset: match.end);
      }
    }

    return null;
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Highlight Color'),
        content: SizedBox(
          width: 280,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _getAvailableColors().map((colorData) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedHighlightColor = colorData['name'];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorData['color'],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedHighlightColor == colorData['name']
                          ? AppColors.primary
                          : Colors.grey.withOpacity(0.3),
                      width: _selectedHighlightColor == colorData['name']
                          ? 3
                          : 1,
                    ),
                  ),
                  child: _selectedHighlightColor == colorData['name']
                      ? Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailableColors() {
    return [
      {'name': 'yellow', 'color': Colors.yellow.withOpacity(0.6)},
      {'name': 'blue', 'color': Colors.blue.withOpacity(0.6)},
      {'name': 'green', 'color': Colors.green.withOpacity(0.6)},
      {'name': 'pink', 'color': Colors.pink.withOpacity(0.6)},
      {'name': 'orange', 'color': Colors.orange.withOpacity(0.6)},
      {'name': 'purple', 'color': Colors.purple.withOpacity(0.6)},
      {'name': 'red', 'color': Colors.red.withOpacity(0.6)},
      {'name': 'cyan', 'color': Colors.cyan.withOpacity(0.6)},
    ];
  }

  Widget _buildHybridMarkdownRenderer(String content) {
    List<Map<String, dynamic>> parts = _parseContentIntoSegments(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        if (part['type'] == 'highlighted') {
          return Html(
            data: '<mark>${part['text']}</mark>',
            shrinkWrap: true,
            style: {
              'mark': Style(
                backgroundColor: _parseColorString(part['color']),
                padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
              ),
            },
          );
        } else {
          return MarkdownWidget(
            data: part['text'],
            shrinkWrap: true,
            selectable: true,
            config: Provider.of<ThemeService>(context).isDarkMode
                ? MarkdownConfig.darkConfig
                : MarkdownConfig.defaultConfig,
          );
        }
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _parseContentIntoSegments(String content) {
    List<Map<String, dynamic>> segments = [];

    RegExp highlightRegex = RegExp(r'==(.*?)==(?:\{([^}]+)\})?');
    int lastIndex = 0;

    for (Match match in highlightRegex.allMatches(content)) {
      if (match.start > lastIndex) {
        String beforeText = content.substring(lastIndex, match.start);
        if (beforeText.isNotEmpty) {
          segments.add({'type': 'markdown', 'text': beforeText});
        }
      }

      String highlightedText = match.group(1) ?? '';
      String color = match.group(2) ?? 'yellow';
      segments.add({
        'type': 'highlighted',
        'text': highlightedText,
        'color': color,
      });

      lastIndex = match.end;
    }

    if (lastIndex < content.length) {
      String remainingText = content.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        segments.add({'type': 'markdown', 'text': remainingText});
      }
    }

    return segments;
  }

  Color _parseColorString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
        return Colors.yellow.withOpacity(0.3);
      case 'blue':
        return Colors.blue.withOpacity(0.3);
      case 'green':
        return Colors.green.withOpacity(0.3);
      case 'pink':
        return Colors.pink.withOpacity(0.3);
      case 'orange':
        return Colors.orange.withOpacity(0.3);
      case 'purple':
        return Colors.purple.withOpacity(0.3);
      case 'red':
        return Colors.red.withOpacity(0.3);
      case 'cyan':
        return Colors.cyan.withOpacity(0.3);
      default:
        return Colors.yellow.withOpacity(0.3);
    }
  }

  void _deleteNote() {
    if (widget.note?.id != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<NotesBloc>().add(
                  NotesDeleteRequested(id: widget.note!.id!),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        AppColors.setDarkMode(themeService.isDarkMode);

        return BlocListener<NotesBloc, NotesState>(
          listener: (context, state) {
            if (state.status == NotesStatus.created ||
                state.status == NotesStatus.updated) {
              setState(() {
                _isEditing = false;
                _hasChanges = false;
                _showToolbar = false;
              });
              _toolbarAnimationController.reverse();
              _showSnackBar('Note saved successfully! 🎉');
            } else if (state.status == NotesStatus.deleted) {
              Navigator.pop(context);
              _showSnackBar('Note deleted successfully');
            } else if (state.status == NotesStatus.error) {
              _showSnackBar(
                state.message ?? 'An error occurred',
                isError: true,
              );
            }
          },
          child: Scaffold(
            backgroundColor: themeService.isDarkMode
                ? const Color(0xFF0F0F0F)
                : const Color(0xFFFAFAFA),
            body: SafeArea(
              child: Column(
                children: [
                  _buildModernAppBar(context, themeService),
                  Expanded(
                    child: _isEditing && !widget.isReadOnly
                        ? _buildModernEditingView(themeService)
                        : _buildModernReadingView(themeService),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernAppBar(BuildContext context, ThemeService themeService) {
    final isDark = themeService.isDarkMode;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 18,
                ),
                onPressed: () {
                  if (_hasChanges && _isEditing) {
                    _showUnsavedChangesDialog(context);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),

            const Spacer(),

            if (_isEditing) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 14, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      'Editing',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],

            Row(
              children: [
                if (widget.note != null &&
                    !widget.isReadOnly &&
                    !_isEditing) ...[
                  _buildModernActionButton(
                    icon: Icons.edit_outlined,
                    onPressed: _toggleEditMode,
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildModernActionButton(
                    icon: Icons.delete_outline,
                    onPressed: _deleteNote,
                    color: Colors.red,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                ],

                if (_isEditing && !widget.isReadOnly)
                  BlocBuilder<NotesBloc, NotesState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == NotesStatus.creating ||
                          state.status == NotesStatus.updating;

                      return ScaleTransition(
                        scale: _saveScaleAnimation,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                            onPressed: isLoading ? null : _saveNote,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildModernEditingView(ThemeService themeService) {
    final isDark = themeService.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.3,
              ),
              decoration: InputDecoration(
                hintText: 'Note title...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),

          const SizedBox(height: 20),

          // Folder Selection Dropdown
          BlocBuilder<FolderBloc, FolderState>(
            builder: (context, folderState) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black26
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedFolderId,
                  decoration: InputDecoration(
                    labelText: 'Folder',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.folder_outlined,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  dropdownColor: isDark
                      ? const Color(0xFF1A1A1A)
                      : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'No folder',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    ...folderState.folders.map((folder) {
                      return DropdownMenuItem<String>(
                        value: folder.id,
                        child: Text(folder.title),
                      );
                    }),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedFolderId = value;
                      _hasChanges = true;
                    });
                  },
                  hint: Text(
                    'Select a folder (optional)',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          AnimatedBuilder(
            animation: _toolbarSlideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _toolbarSlideAnimation.value * 50),
                child: Opacity(
                  opacity: 1 + _toolbarSlideAnimation.value,
                  child: _showToolbar
                      ? _buildModernToolbar(isDark)
                      : const SizedBox.shrink(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          Container(
            height: 500,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LiveMarkdownEditor(
                controller: _contentController,
                hintText:
                    'Start writing your note with live markdown preview...',
                height: 500,
                padding: const EdgeInsets.all(24),
                textStyle: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.6,
                  fontFamily: 'system',
                ),
                onChanged: () => setState(() {}),
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildModernToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette,
                size: 16,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Formatting',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildModernToolbarButton(
                Icons.format_bold,
                'Bold',
                _makeBold,
                isDark,
              ),
              _buildModernToolbarButton(
                Icons.format_italic,
                'Italic',
                _makeItalic,
                isDark,
              ),
              _buildModernToolbarButton(Icons.code, 'Code', _makeCode, isDark),
              _buildModernToolbarButton(
                Icons.strikethrough_s,
                'Strike',
                _makeStrikethrough,
                isDark,
              ),
              _buildHighlightButton(isDark),
              const SizedBox(width: 8),
              _buildModernToolbarButton(
                Icons.title,
                'H1',
                () => _makeHeading(1),
                isDark,
              ),
              _buildModernToolbarButton(
                Icons.title,
                'H2',
                () => _makeHeading(2),
                isDark,
                fontSize: 14,
              ),
              _buildModernToolbarButton(
                Icons.title,
                'H3',
                () => _makeHeading(3),
                isDark,
                fontSize: 12,
              ),
              const SizedBox(width: 8),
              _buildModernToolbarButton(
                Icons.format_list_bulleted,
                'List',
                _makeList,
                isDark,
              ),
              _buildModernToolbarButton(
                Icons.format_list_numbered,
                'Numbers',
                _makeNumberedList,
                isDark,
              ),
              _buildModernToolbarButton(
                Icons.format_quote,
                'Quote',
                _makeQuote,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernToolbarButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
    bool isDark, {
    double fontSize = 16,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: fontSize,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _makeHighlight();
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.highlight,
                      size: 16,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Highlight',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showColorPicker,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _parseColorString(_selectedHighlightColor),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 14,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernReadingView(ThemeService themeService) {
    final isDark = themeService.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_titleController.text.isNotEmpty) ...[
            SelectableText(
              _titleController.text,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (widget.note?.updatedAt != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last edited ${_formatDate(widget.note!.updatedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          if (_contentController.text.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black26
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildHybridMarkdownRenderer(_contentController.text),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This note is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the edit button to start writing',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white24 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showUnsavedChangesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
