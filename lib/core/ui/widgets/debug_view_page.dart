import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../router/navigator_keys.dart';
import '../../utils/debug_logger.dart';
import '../designs/designs.dart';
import '../widgets/app_text_field.dart';

enum _FilterLevel { all, info, warn, error }

class DebugViewPage extends StatefulWidget {
  const DebugViewPage({super.key});

  /// Shows the [DebugViewPage] using the root navigator context.
  static Future<void> show([BuildContext? context]) {
    final ctx = context ?? NavigatorKeys.rootNavigatorKey.currentContext;
    if (ctx == null) return Future.value();
    return Navigator.of(
      ctx,
    ).push(MaterialPageRoute(builder: (_) => const DebugViewPage()));
  }

  @override
  State<DebugViewPage> createState() => _DebugViewPageState();
}

class _DebugViewPageState extends State<DebugViewPage> {
  _FilterLevel _selectedFilter = _FilterLevel.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    DebugLogger.instance.addListener(_onLogsChanged);
  }

  @override
  void dispose() {
    DebugLogger.instance.removeListener(_onLogsChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onLogsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<DebugData> _filterLogs(List<DebugData> allLogs) {
    return allLogs.where((log) {
      // Level filter
      if (_selectedFilter == _FilterLevel.info &&
          log.level != DebugLevel.info) {
        return false;
      }
      if (_selectedFilter == _FilterLevel.warn &&
          log.level != DebugLevel.warn) {
        return false;
      }
      if (_selectedFilter == _FilterLevel.error &&
          log.level != DebugLevel.error) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final contentMatches = log.data.toLowerCase().contains(query);
        final levelMatches = log.level.name.toLowerCase().contains(query);
        if (!contentMatches && !levelMatches) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Debug Console', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear Console Logs',
            onPressed: () {
              DebugLogger.instance.clearLogs();
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                AppTextField(
                  controller: _searchController,
                  hintText: 'Search logs...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
                SizedBox(height: 12.h),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _FilterLevel.values.map((filter) {
                      final isSelected = filter == _selectedFilter;
                      final label = switch (filter) {
                        _FilterLevel.all => 'All Logs',
                        _FilterLevel.info => 'Info',
                        _FilterLevel.warn => 'Warnings',
                        _FilterLevel.error => 'Errors',
                      };

                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? AppColors.textSecondary
                                      : const Color(0xFF334155)),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: ListenableBuilder(
              listenable: DebugLogger.instance,
              builder: (context, _) {
                final allLogs = DebugLogger.instance.logs;
                final filteredLogs = _filterLogs(allLogs);

                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.terminal_rounded,
                            size: 56.r,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            allLogs.isEmpty
                                ? 'No debug logs captured yet'
                                : 'No logs match your filter',
                            style: AppTextStyles.subtitle.copyWith(
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            allLogs.isEmpty
                                ? 'Console logs and network payloads will appear here automatically in debug mode.'
                                : 'Try adjusting your search query or filter chips.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    // Display newest logs first or chronological order (newest first is great for debugging)
                    final log = filteredLogs[filteredLogs.length - 1 - index];
                    return _LogCard(log: log, isDark: isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final DebugData log;
  final bool isDark;

  const _LogCard({required this.log, required this.isDark});

  Color _getLevelColor(DebugLevel level) {
    switch (level) {
      case DebugLevel.info:
        return AppColors.success;
      case DebugLevel.warn:
        return AppColors.warning;
      case DebugLevel.error:
        return AppColors.error;
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor(log.level);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(
          color: isDark ? AppColors.border : levelColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      log.level.name.toUpperCase(),
                      style: AppTextStyles.labelUppercase.copyWith(
                        color: levelColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatTime(log.timestamp),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11.sp,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  size: 16.r,
                  color: AppColors.textMuted,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Copy Log Content',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: log.data));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Log copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Code Content Block
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: SelectableText(
              log.data,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.sp,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
