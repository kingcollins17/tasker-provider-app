import 'dart:convert';
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
    final filtered = allLogs.where((log) {
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

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
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
                    final log = filteredLogs[index];
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

          // Code Content / Interactive JSON Viewer Block
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    dynamic jsonObject;
    final trimmed = log.data.trim();
    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      try {
        jsonObject = jsonDecode(trimmed);
      } catch (_) {
        jsonObject = null;
      }
    }

    if (jsonObject != null && (jsonObject is Map || jsonObject is List)) {
      return _JsonViewer(
        data: jsonObject,
        rawJson: log.data,
        isDark: isDark,
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: SelectableText(
        log.data,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11.sp,
          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
          height: 1.4,
        ),
      ),
    );
  }
}

class _JsonTheme {
  final bool isDark;

  const _JsonTheme(this.isDark);

  Color get keyColor => isDark ? const Color(0xFF9CDCFE) : const Color(0xFF0451A5);
  Color get stringColor => isDark ? const Color(0xFFCE9178) : const Color(0xFFA31515);
  Color get numberColor => isDark ? const Color(0xFFB5CEA8) : const Color(0xFF098658);
  Color get boolColor => isDark ? const Color(0xFF569CD6) : const Color(0xFF0000FF);
  Color get nullColor => isDark ? const Color(0xFF808080) : const Color(0xFF757575);
  Color get punctuationColor => isDark ? const Color(0xFFD4D4D4) : const Color(0xFF333333);
  Color get arrowColor => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get indentLineColor =>
      isDark ? const Color(0xFF334155).withValues(alpha: 0.6) : const Color(0xFFCBD5E1);
  Color get previewColor => isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
}

class _JsonViewer extends StatefulWidget {
  final dynamic data;
  final String rawJson;
  final bool isDark;

  const _JsonViewer({
    required this.data,
    required this.rawJson,
    required this.isDark,
  });

  @override
  State<_JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<_JsonViewer> {
  late final ValueNotifier<bool?> _expandNotifier;

  @override
  void initState() {
    super.initState();
    _expandNotifier = ValueNotifier<bool?>(null);
  }

  @override
  void dispose() {
    _expandNotifier.dispose();
    super.dispose();
  }

  void _expandAll() {
    _expandNotifier.value = true;
  }

  void _collapseAll() {
    _expandNotifier.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = _JsonTheme(widget.isDark);

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7.r),
                topRight: Radius.circular(7.r),
              ),
              border: Border(
                bottom: BorderSide(
                  color: widget.isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.data_object_rounded,
                          size: 12.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'JSON',
                          style: AppTextStyles.labelUppercase.copyWith(
                            fontSize: 9.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    widget.data is Map
                        ? '{ ${(widget.data as Map).length} keys }'
                        : '[ ${(widget.data as List).length} items ]',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10.sp,
                      fontFamily: 'monospace',
                      color: widget.isDark
                          ? AppColors.textMuted
                          : const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  InkWell(
                    onTap: _expandAll,
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.unfold_more_rounded,
                            size: 14.r,
                            color: theme.arrowColor,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Expand All',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: theme.arrowColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  InkWell(
                    onTap: _collapseAll,
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.unfold_less_rounded,
                            size: 14.r,
                            color: theme.arrowColor,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Collapse All',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: theme.arrowColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // JSON Interactive Tree
          Padding(
            padding: EdgeInsets.all(10.r),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _JsonNodeWidget(
                keyName: null,
                value: widget.data,
                jsonTheme: theme,
                depth: 0,
                isLast: true,
                expandNotifier: _expandNotifier,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JsonNodeWidget extends StatefulWidget {
  final String? keyName;
  final dynamic value;
  final _JsonTheme jsonTheme;
  final int depth;
  final bool isLast;
  final ValueNotifier<bool?> expandNotifier;

  const _JsonNodeWidget({
    super.key,
    required this.keyName,
    required this.value,
    required this.jsonTheme,
    required this.depth,
    required this.isLast,
    required this.expandNotifier,
  });

  @override
  State<_JsonNodeWidget> createState() => _JsonNodeWidgetState();
}

class _JsonNodeWidgetState extends State<_JsonNodeWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Expand root & top levels by default
    _isExpanded = widget.depth < 2;
    widget.expandNotifier.addListener(_onExpandNotifierChanged);
  }

  @override
  void didUpdateWidget(covariant _JsonNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expandNotifier != widget.expandNotifier) {
      oldWidget.expandNotifier.removeListener(_onExpandNotifierChanged);
      widget.expandNotifier.addListener(_onExpandNotifierChanged);
    }
  }

  @override
  void dispose() {
    widget.expandNotifier.removeListener(_onExpandNotifierChanged);
    super.dispose();
  }

  void _onExpandNotifierChanged() {
    final notifierValue = widget.expandNotifier.value;
    if (notifierValue != null && mounted) {
      setState(() {
        _isExpanded = notifierValue;
      });
    }
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final comma = widget.isLast ? '' : ',';
    final theme = widget.jsonTheme;

    if (value is Map) {
      return _buildObjectNode(value, comma, theme);
    } else if (value is List) {
      return _buildArrayNode(value, comma, theme);
    } else {
      return _buildPrimitiveNode(value, comma, theme);
    }
  }

  Widget _buildKeyPrefix(_JsonTheme theme) {
    if (widget.keyName == null) return const SizedBox.shrink();
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '"${widget.keyName}"',
            style: TextStyle(
              color: theme.keyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: ': ',
            style: TextStyle(color: theme.punctuationColor),
          ),
        ],
      ),
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 11.sp,
        height: 1.4,
      ),
    );
  }

  Widget _buildObjectNode(Map mapValue, String comma, _JsonTheme theme) {
    if (mapValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16.w),
            _buildKeyPrefix(theme),
            Text(
              '{}$comma',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.sp,
                color: theme.punctuationColor,
              ),
            ),
          ],
        ),
      );
    }

    final entries = mapValue.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggleExpand,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isExpanded
                      ? Icons.arrow_drop_down_rounded
                      : Icons.arrow_right_rounded,
                  size: 16.r,
                  color: theme.arrowColor,
                ),
                _buildKeyPrefix(theme),
                Text(
                  '{',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.sp,
                    color: theme.punctuationColor,
                  ),
                ),
                if (!_isExpanded) ...[
                  SizedBox(width: 4.w),
                  Text(
                    _buildInlineMapPreview(mapValue),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.sp,
                      color: theme.previewColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '}$comma',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.sp,
                      color: theme.punctuationColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          Container(
            margin: EdgeInsets.only(left: 7.w),
            padding: EdgeInsets.only(left: 9.w),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.indentLineColor,
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(entries.length, (index) {
                final entry = entries[index];
                return _JsonNodeWidget(
                  key: ValueKey('${widget.keyName}_${entry.key}_$index'),
                  keyName: entry.key.toString(),
                  value: entry.value,
                  jsonTheme: theme,
                  depth: widget.depth + 1,
                  isLast: index == entries.length - 1,
                  expandNotifier: widget.expandNotifier,
                );
              }),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 1.h, bottom: 1.h),
            child: Text(
              '}$comma',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.sp,
                color: theme.punctuationColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildArrayNode(List listValue, String comma, _JsonTheme theme) {
    if (listValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16.w),
            _buildKeyPrefix(theme),
            Text(
              '[]$comma',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.sp,
                color: theme.punctuationColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggleExpand,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isExpanded
                      ? Icons.arrow_drop_down_rounded
                      : Icons.arrow_right_rounded,
                  size: 16.r,
                  color: theme.arrowColor,
                ),
                _buildKeyPrefix(theme),
                Text(
                  '[',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.sp,
                    color: theme.punctuationColor,
                  ),
                ),
                if (!_isExpanded) ...[
                  SizedBox(width: 4.w),
                  Text(
                    '${listValue.length} ${listValue.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.sp,
                      color: theme.previewColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    ']$comma',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.sp,
                      color: theme.punctuationColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          Container(
            margin: EdgeInsets.only(left: 7.w),
            padding: EdgeInsets.only(left: 9.w),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.indentLineColor,
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(listValue.length, (index) {
                return _JsonNodeWidget(
                  key: ValueKey('${widget.keyName}_$index'),
                  keyName: null,
                  value: listValue[index],
                  jsonTheme: theme,
                  depth: widget.depth + 1,
                  isLast: index == listValue.length - 1,
                  expandNotifier: widget.expandNotifier,
                );
              }),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 1.h, bottom: 1.h),
            child: Text(
              ']$comma',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.sp,
                color: theme.punctuationColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrimitiveNode(dynamic val, String comma, _JsonTheme theme) {
    Color valColor;
    String displayStr;
    FontWeight fontWeight = FontWeight.normal;
    FontStyle fontStyle = FontStyle.normal;

    if (val == null) {
      valColor = theme.nullColor;
      displayStr = 'null';
      fontStyle = FontStyle.italic;
    } else if (val is bool) {
      valColor = theme.boolColor;
      displayStr = val.toString();
      fontWeight = FontWeight.w600;
    } else if (val is num) {
      valColor = theme.numberColor;
      displayStr = val.toString();
    } else if (val is String) {
      valColor = theme.stringColor;
      final escaped = val
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r')
          .replaceAll('\t', '\\t');
      displayStr = '"$escaped"';
    } else {
      valColor = theme.punctuationColor;
      displayStr = val.toString();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 16.w),
          _buildKeyPrefix(theme),
          Text(
            '$displayStr$comma',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11.sp,
              color: valColor,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _buildInlineMapPreview(Map map) {
    if (map.isEmpty) return '';
    final keys = map.keys.take(3).join(', ');
    final more = map.length > 3 ? '...' : '';
    final keysStr = more.isNotEmpty ? '$keys, $more' : keys;
    return '{ $keysStr } (${map.length} ${map.length == 1 ? 'key' : 'keys'})';
  }
}

