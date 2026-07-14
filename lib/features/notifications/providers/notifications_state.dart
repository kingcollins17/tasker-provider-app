import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/api/api.dart';

part 'notifications_state.freezed.dart';

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default(null) PaginatedData<NotificationItem>? paginatedData,
    @Default(null) NotificationCounts? counts,
    @Default(null) List<NotificationPreference>? preferences,
    @Default(false) bool isLoadingMore,
  }) = _NotificationsState;
}
