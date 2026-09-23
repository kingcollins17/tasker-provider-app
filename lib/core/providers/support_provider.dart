import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/support_client.dart';
import '../models/models.dart';
import '../utils/app_exception_handler.dart';
import '../utils/debug_logger.dart';
import '../utils/extensions/error_ext.dart';
import '../utils/retry_util.dart';

/// Paginated AsyncNotifier for user support cases with mutation action methods.
class CustomerSupportNotifier extends AsyncNotifier<List<SupportCase>> {
  int _page = 1;
  int _total = 0;
  bool _isLoadingMore = false;

  final String? status;

  CustomerSupportNotifier({this.status});

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => (state.value?.length ?? 0) < _total;

  @override
  Future<List<SupportCase>> build() async {
    _page = 1;
    _total = 0;
    _isLoadingMore = false;
    return _fetchInitial();
  }

  Future<List<SupportCase>> _fetchInitial() async {
    try {
      debugLog('[CustomerSupportNotifier] Fetching initial support cases (status: $status)...');
      final client = ref.watch(supportClientProvider);
      final response = await client.getUserCases(
        page: 1,
        perPage: 20,
        status: status,
      );

      if (response.isSuccessful && response.hasData) {
        _total = response.data?.total ?? 0;
        _page = response.data?.page ?? 1;
        debugLog(
          '[CustomerSupportNotifier] Loaded ${response.data?.items?.length} cases',
        );
        return response.data?.items ?? [];
      }
    } catch (e, st) {
      debugLog(
        '[CustomerSupportNotifier] Error fetching cases: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
    }
    return [];
  }

  /// Fetches the next page of user support cases.
  Future<void> fetchMore() async {
    final currentList = state.value;
    if (currentList == null || _isLoadingMore || currentList.length >= _total) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      debugLog('[CustomerSupportNotifier] Fetching cases page $nextPage (status: $status)...');
      final client = ref.read(supportClientProvider);
      final response = await client.getUserCases(
        page: nextPage,
        perPage: 20,
        status: status,
      );

      if (response.isSuccessful && response.hasData) {
        final newItems = response.data?.items ?? [];
        _page = response.data?.page ?? nextPage;
        _total = response.data?.total ?? _total;
        state = AsyncData(List<SupportCase>.from(currentList)..addAll(newItems));
      }
    } catch (e, st) {
      debugLog(
        '[CustomerSupportNotifier] Error fetching page $_page: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refreshes the support cases list.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Action: Creates a new support case.
  Future<void> createCase(
    CreateSupportCaseRequest request, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
    void Function(SupportCase)? onCaseCreated,
  }) async {
    try {
      debugLog(
        '[CustomerSupportNotifier.createCase] Creating support case: ${request.subject}',
      );
      final client = ref.read(supportClientProvider);
      final response = await client.createCase(request);

      if (response.isSuccessful && response.hasData) {
        debugLog(
          '[CustomerSupportNotifier.createCase] Case created successfully',
        );
        onCaseCreated?.call(response.data!);
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.errorMessage ??
            response.detailMessage ??
            'Failed to create support case');
      }
    } catch (e, st) {
      debugLog(
        '[CustomerSupportNotifier.createCase] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  /// Action: Sends a user message for a support case.
  Future<void> sendMessage(
    String caseId,
    SendSupportMessageRequest request, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog(
        '[CustomerSupportNotifier.sendMessage] Sending message for case: $caseId',
      );
      final client = ref.read(supportClientProvider);
      final response = await client.sendUserMessage(caseId, request);

      if (response.isSuccessful) {
        debugLog(
          '[CustomerSupportNotifier.sendMessage] Message sent successfully',
        );
        ref.invalidate(caseMessagesProvider(caseId));
        ref.invalidate(userCaseDetailsProvider(caseId));
        ref.invalidate(caseTimelineProvider(caseId));
        ref.invalidateSelf();
        onSuccess?.call();
      } else {
        throw (response.errorMessage ??
            response.detailMessage ??
            'Failed to send message');
      }
    } catch (e, st) {
      debugLog(
        '[CustomerSupportNotifier.sendMessage] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  /// Action: Uploads an attachment file for a support case.
  Future<void> uploadAttachment(
    String caseId,
    File file, {
    String? messageId,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog(
        '[CustomerSupportNotifier.uploadAttachment] Uploading attachment for case: $caseId',
      );
      final client = ref.read(supportClientProvider);
      final response = await client.uploadCaseAttachment(
        caseId,
        file: file,
        messageId: messageId,
      );

      if (response.isSuccessful) {
        debugLog(
          '[CustomerSupportNotifier.uploadAttachment] Attachment uploaded successfully',
        );
        ref.invalidate(caseMessagesProvider(caseId));
        ref.invalidate(userCaseDetailsProvider(caseId));
        ref.invalidate(caseTimelineProvider(caseId));
        ref.invalidate(caseAttachmentsProvider(caseId));
        onSuccess?.call();
      } else {
        throw (response.errorMessage ??
            response.detailMessage ??
            'Failed to upload attachment');
      }
    } catch (e, st) {
      debugLog(
        '[CustomerSupportNotifier.uploadAttachment] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  /// Action: Closes an open support case.
  Future<void> closeCase(
    String caseId, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog(
        '[CustomerSupportNotifier.closeCase] Closing support case: $caseId',
      );
      final client = ref.read(supportClientProvider);
      final response = await client.closeUserCase(caseId);

      if (response.isSuccessful) {
        debugLog(
          '[CustomerSupportNotifier.closeCase] Case closed successfully',
        );
        ref.invalidate(userCaseDetailsProvider(caseId));
        ref.invalidate(caseTimelineProvider(caseId));
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.errorMessage ??
            response.detailMessage ??
            'Failed to close support case');
      }
    } catch (e, st) {
      debugLog(
        '[CustomerSupportNotifier.closeCase] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  /// Action: Reopens a closed support case.
  Future<void> reopenCase(
    String caseId, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog(
        '[CustomerSupportNotifier.reopenCase] Reopening support case: $caseId',
      );
      final client = ref.read(supportClientProvider);
      final response = await client.reopenUserCase(caseId);

      if (response.isSuccessful) {
        debugLog(
          '[CustomerSupportNotifier.reopenCase] Case reopened successfully',
        );
        ref.invalidate(userCaseDetailsProvider(caseId));
        ref.invalidate(caseTimelineProvider(caseId));
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.errorMessage ??
            response.detailMessage ??
            'Failed to reopen support case');
      }
    } catch (e, st) {
      debugLog(
        '[CustomerSupportNotifier.reopenCase] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

/// Main Family Provider for [CustomerSupportNotifier] filtering by optional status ('open', 'closed', or null for all).
final customerSupportNotifierProvider = AsyncNotifierProvider.family<
    CustomerSupportNotifier,
    List<SupportCase>,
    String?>(
  (status) => CustomerSupportNotifier(status: status),
  retry: retryFunc(3),
);

/// Paginated AsyncNotifier for retrieving user cases filtered by optional [taskId].
class TaskUserCasesNotifier extends AsyncNotifier<List<SupportCase>> {
  int _page = 1;
  int _total = 0;
  bool _isLoadingMore = false;

  final String? taskId;

  TaskUserCasesNotifier({this.taskId});

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => (state.value?.length ?? 0) < _total;

  @override
  Future<List<SupportCase>> build() async {
    _page = 1;
    _total = 0;
    _isLoadingMore = false;
    return _fetchInitial();
  }

  Future<List<SupportCase>> _fetchInitial() async {
    try {
      debugLog(
        '[TaskUserCasesNotifier] Fetching cases (taskId filter: $taskId)...',
      );
      final client = ref.watch(supportClientProvider);
      final response =
          await client.getUserCases(page: 1, perPage: 20, taskId: taskId);

      if (response.isSuccessful && response.hasData) {
        _total = response.data?.total ?? 0;
        _page = response.data?.page ?? 1;
        return response.data?.items ?? [];
      }
    } catch (e, st) {
      debugLog('[TaskUserCasesNotifier] Error: $e', level: DebugLevel.error);
      AppExceptionHandler.instance.handleError(e, st);
    }
    return [];
  }

  Future<void> fetchMore() async {
    final currentList = state.value;
    if (currentList == null || _isLoadingMore || currentList.length >= _total) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      final client = ref.read(supportClientProvider);
      final response = await client.getUserCases(
        page: nextPage,
        perPage: 20,
        taskId: taskId,
      );

      if (response.isSuccessful && response.hasData) {
        final newItems = response.data?.items ?? [];
        _page = response.data?.page ?? nextPage;
        _total = response.data?.total ?? _total;
        state = AsyncData(List<SupportCase>.from(currentList)..addAll(newItems));
      }
    } catch (e, st) {
      debugLog(
        '[TaskUserCasesNotifier] Error fetching more: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Provider to retrieve user support cases with an optional [taskId] filter.
final userCasesProvider = AsyncNotifierProvider.family<
    TaskUserCasesNotifier,
    List<SupportCase>,
    String?>(
  (taskId) => TaskUserCasesNotifier(taskId: taskId),
  retry: retryFunc(3),
);



/// Provider to retrieve detailed information for a single support case.
final userCaseDetailsProvider =
    FutureProvider.family<SupportCase?, String>((ref, caseId) async {
  debugLog('[userCaseDetailsProvider] Fetching case details for ID: $caseId...');
  final client = ref.watch(supportClientProvider);
  final response = await client.getUserCase(caseId);

  if (response.isSuccessful && response.hasData) {
    return response.data;
  }
  return null;
}, retry: retryFunc(3));

/// Paginated AsyncNotifier for retrieving support messages for a specific case.
class CaseMessagesNotifier extends AsyncNotifier<List<SupportMessage>> {
  int _page = 1;
  int _total = 0;
  bool _isLoadingMore = false;

  final String caseId;

  CaseMessagesNotifier({required this.caseId});

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => (state.value?.length ?? 0) < _total;

  @override
  Future<List<SupportMessage>> build() async {
    _page = 1;
    _total = 0;
    _isLoadingMore = false;
    return _fetchInitial();
  }

  Future<List<SupportMessage>> _fetchInitial() async {
    try {
      debugLog(
        '[CaseMessagesNotifier] Fetching messages for case ID: $caseId...',
      );
      final client = ref.watch(supportClientProvider);
      final response =
          await client.getCaseMessages(caseId, page: 1, perPage: 20);

      if (response.isSuccessful && response.hasData) {
        _total = response.data?.total ?? 0;
        _page = response.data?.page ?? 1;
        return response.data?.items ?? [];
      }
    } catch (e, st) {
      debugLog('[CaseMessagesNotifier] Error: $e', level: DebugLevel.error);
      AppExceptionHandler.instance.handleError(e, st);
    }
    return [];
  }

  Future<void> fetchMore() async {
    final currentList = state.value;
    if (currentList == null || _isLoadingMore || currentList.length >= _total) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      final client = ref.read(supportClientProvider);
      final response = await client.getCaseMessages(
        caseId,
        page: nextPage,
        perPage: 20,
      );

      if (response.isSuccessful && response.hasData) {
        final newItems = response.data?.items ?? [];
        _page = response.data?.page ?? nextPage;
        _total = response.data?.total ?? _total;
        state = AsyncData(List<SupportMessage>.from(currentList)..addAll(newItems));
      }
    } catch (e, st) {
      debugLog(
        '[CaseMessagesNotifier] Error fetching more: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Provider to retrieve paginated messages for a specific support case.
final caseMessagesProvider = AsyncNotifierProvider.family<
    CaseMessagesNotifier,
    List<SupportMessage>,
    String>(
  (caseId) => CaseMessagesNotifier(caseId: caseId),
  retry: retryFunc(3),
);

/// Paginated AsyncNotifier for retrieving timeline events for a specific case.
class CaseTimelineNotifier extends AsyncNotifier<List<SupportTimelineItem>> {
  int _page = 1;
  int _total = 0;
  bool _isLoadingMore = false;

  final String caseId;

  CaseTimelineNotifier({required this.caseId});

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => (state.value?.length ?? 0) < _total;

  @override
  Future<List<SupportTimelineItem>> build() async {
    _page = 1;
    _total = 0;
    _isLoadingMore = false;
    return _fetchInitial();
  }

  Future<List<SupportTimelineItem>> _fetchInitial() async {
    try {
      debugLog(
        '[CaseTimelineNotifier] Fetching timeline for case ID: $caseId...',
      );
      final client = ref.watch(supportClientProvider);
      final response =
          await client.getCaseTimeline(caseId, page: 1, perPage: 20);

      if (response.isSuccessful && response.hasData) {
        _total = response.data?.total ?? 0;
        _page = response.data?.page ?? 1;
        return response.data?.items ?? [];
      }
    } catch (e, st) {
      debugLog('[CaseTimelineNotifier] Error: $e', level: DebugLevel.error);
      AppExceptionHandler.instance.handleError(e, st);
    }
    return [];
  }

  Future<void> fetchMore() async {
    final currentList = state.value;
    if (currentList == null || _isLoadingMore || currentList.length >= _total) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      final client = ref.read(supportClientProvider);
      final response = await client.getCaseTimeline(
        caseId,
        page: nextPage,
        perPage: 20,
      );

      if (response.isSuccessful && response.hasData) {
        final newItems = response.data?.items ?? [];
        _page = response.data?.page ?? nextPage;
        _total = response.data?.total ?? _total;
        state = AsyncData(
          List<SupportTimelineItem>.from(currentList)..addAll(newItems),
        );
      }
    } catch (e, st) {
      debugLog(
        '[CaseTimelineNotifier] Error fetching more: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Provider to retrieve paginated timeline items for a specific support case.
final caseTimelineProvider = AsyncNotifierProvider.family<
    CaseTimelineNotifier,
    List<SupportTimelineItem>,
    String>(
  (caseId) => CaseTimelineNotifier(caseId: caseId),
  retry: retryFunc(3),
);

/// Paginated AsyncNotifier for retrieving file attachments for a specific support case.
class CaseAttachmentsNotifier extends AsyncNotifier<List<SupportAttachment>> {
  int _page = 1;
  int _total = 0;
  bool _isLoadingMore = false;

  final String caseId;

  CaseAttachmentsNotifier({required this.caseId});

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => (state.value?.length ?? 0) < _total;

  @override
  Future<List<SupportAttachment>> build() async {
    _page = 1;
    _total = 0;
    _isLoadingMore = false;
    return _fetchInitial();
  }

  Future<List<SupportAttachment>> _fetchInitial() async {
    try {
      debugLog(
        '[CaseAttachmentsNotifier] Fetching attachments for case ID: $caseId...',
      );
      final client = ref.watch(supportClientProvider);
      final response =
          await client.getCaseAttachments(caseId, page: 1, perPage: 20);

      if (response.isSuccessful && response.hasData) {
        _total = response.data?.total ?? 0;
        _page = response.data?.page ?? 1;
        return response.data?.items ?? [];
      }
    } catch (e, st) {
      debugLog('[CaseAttachmentsNotifier] Error: $e', level: DebugLevel.error);
      AppExceptionHandler.instance.handleError(e, st);
    }
    return [];
  }

  Future<void> fetchMore() async {
    final currentList = state.value;
    if (currentList == null || _isLoadingMore || currentList.length >= _total) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      final client = ref.read(supportClientProvider);
      final response = await client.getCaseAttachments(
        caseId,
        page: nextPage,
        perPage: 20,
      );

      if (response.isSuccessful && response.hasData) {
        final newItems = response.data?.items ?? [];
        _page = response.data?.page ?? nextPage;
        _total = response.data?.total ?? _total;
        state = AsyncData(
          List<SupportAttachment>.from(currentList)..addAll(newItems),
        );
      }
    } catch (e, st) {
      debugLog(
        '[CaseAttachmentsNotifier] Error fetching more: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Provider to retrieve paginated file attachments for a specific support case.
final caseAttachmentsProvider = AsyncNotifierProvider.family<
    CaseAttachmentsNotifier,
    List<SupportAttachment>,
    String>(
  (caseId) => CaseAttachmentsNotifier(caseId: caseId),
  retry: retryFunc(3),
);
