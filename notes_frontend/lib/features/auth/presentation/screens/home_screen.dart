import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_service.dart';
import '../../../notes/presentation/bloc/notes_bloc.dart';
import '../../../notes/presentation/bloc/notes_event.dart';
import '../../../notes/presentation/bloc/notes_state.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/screens/note_detail_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'All Notes';

  @override
  void initState() {
    super.initState();

    context.read<NotesBloc>().add(NotesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              border: Border(
                right: BorderSide(color: theme.colorScheme.outline, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Thamie Notes',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer<ThemeService>(
                    builder: (context, themeService, child) {
                      AppColors.setDarkMode(themeService.isDarkMode);

                      return TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search notes...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.6,
                            ),
                            size: 20,
                          ),
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      BlocBuilder<NotesBloc, NotesState>(
                        builder: (context, state) {
                          return _buildNavItem(
                            context,
                            'All Notes',
                            Icons.note_alt_outlined,
                            isSelected: _selectedTab == 'All Notes',
                            count: state.notes.length,
                          );
                        },
                      ),
                      _buildNavItem(
                        context,
                        'Recent',
                        Icons.access_time,
                        isSelected: _selectedTab == 'Recent',
                      ),
                      _buildNavItem(
                        context,
                        'Favorites',
                        Icons.star_outline,
                        isSelected: _selectedTab == 'Favorites',
                      ),
                      _buildNavItem(
                        context,
                        'Trash',
                        Icons.delete_outline,
                        isSelected: _selectedTab == 'Trash',
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'FOLDERS',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.6,
                            ),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildNavItem(
                        context,
                        'Personal',
                        Icons.folder_outlined,
                        isSelected: _selectedTab == 'Personal',
                      ),
                      _buildNavItem(
                        context,
                        'Work',
                        Icons.folder_outlined,
                        isSelected: _selectedTab == 'Work',
                      ),
                      _buildNavItem(
                        context,
                        'Ideas',
                        Icons.folder_outlined,
                        isSelected: _selectedTab == 'Ideas',
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Your Account',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'logout') {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 18),
                                SizedBox(width: 8),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ],
                        child: Icon(
                          Icons.more_horiz,
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.6,
                          ),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Consumer<ThemeService>(
                  builder: (context, themeService, child) {
                    AppColors.setDarkMode(themeService.isDarkMode);

                    return Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _selectedTab,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              tooltip: 'Search notes',
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Consumer<ThemeService>(
                              builder: (context, themeService, child) {
                                return IconButton(
                                  onPressed: () {
                                    themeService.toggleTheme();
                                  },
                                  icon: Icon(
                                    themeService.isDarkMode
                                        ? Icons.light_mode
                                        : Icons.dark_mode,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  tooltip: themeService.isDarkMode
                                      ? 'Switch to light mode'
                                      : 'Switch to dark mode',
                                );
                              },
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.grid_view,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  tooltip: 'Grid view',
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: AppColors.primary.withOpacity(0.1),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.view_list,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                  tooltip: 'List view',
                                ),
                              ],
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _navigateToCreateNote(context),
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'New Note',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                Expanded(child: _buildMainContent(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isSelected = false,
    int? count,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTab = title;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onBackground.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onBackground,
                    ),
                  ),
                ),
                if (count != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onBackground.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return BlocConsumer<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state.status == NotesStatus.created) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.status == NotesStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'An error occurred'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == NotesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.notes.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildNotesList(context, state.notes);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.accent.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 64,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Your story begins here',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Create your first note and start building your\npersonal knowledge base.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCreateNote(context),
                icon: const Icon(Icons.add, size: 20, color: Colors.white),
                label: const Text(
                  'Create your first note',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureChip(Icons.search, 'Searchable'),
                const SizedBox(width: 12),
                _buildFeatureChip(Icons.cloud_sync, 'Synced'),
                const SizedBox(width: 12),
                _buildFeatureChip(Icons.security, 'Secure'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<Note> notes) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final note = notes[index];
              return _buildModernNoteCard(context, note, index);
            }, childCount: notes.length),
          ),
        ),
      ],
    );
  }

  Widget _buildModernNoteCard(BuildContext context, Note note, int index) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        AppColors.setDarkMode(themeService.isDarkMode);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(note: note),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title.isNotEmpty ? note.title : 'Untitled',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NoteDetailScreen(note: note),
                                ),
                              );
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, note);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: Text(
                        _cleanMarkdownForPreview(note.content),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_getWordCount(note.content)} words',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (note.updatedAt != null || note.createdAt != null)
                          Text(
                            _formatDate(note.updatedAt ?? note.createdAt!),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  int _getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  String _cleanMarkdownForPreview(String markdownText) {
    if (markdownText.trim().isEmpty) return 'No content';

    String cleaned = markdownText;

    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), ' [code] ');

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'^#{1,6}\s+(.*)$', multiLine: true),
      (match) => match.group(1) ?? '',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'==(.+?)==(\{[^}]+\})?'),
      (match) => match.group(1) ?? '',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => match.group(1) ?? '',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^\*\n]+?)\*(?!\*)'),
      (match) => match.group(1) ?? '',
    );
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(?<!_)_([^_\n]+?)_(?!_)'),
      (match) => match.group(1) ?? '',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'~~(.*?)~~'),
      (match) => match.group(1) ?? '',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'`([^`]+?)`'),
      (match) => match.group(1) ?? '',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\[([^\]]*)\]\([^)]*\)'),
      (match) => match.group(1) ?? '',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'!\[([^\]]*)\]\([^)]*\)'),
      (match) => match.group(1) ?? '',
    );

    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');

    cleaned = cleaned.replaceAll(RegExp(r'^\s*>\s+', multiLine: true), '');

    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*>'), '');

    cleaned = cleaned.replaceAll(RegExp(r'\n+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.trim();

    return cleaned.isNotEmpty ? cleaned : 'No content';
  }

  void _showDeleteConfirmation(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (note.id != null) {
                context.read<NotesBloc>().add(
                  NotesDeleteRequested(id: note.id!),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteDetailScreen()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
