import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../api/api.dart';
import '../models/models.dart';
import '../utils/app_exception_handler.dart';
import '../utils/extensions/error_ext.dart';
import 'user_provider.dart';

part 'services_editor_provider.freezed.dart';

/// Immutable state representation for the services editor using Freezed.
///
/// Holds [selected] service IDs (to be attached/added) and
/// [unSelected] service IDs (to be detached/removed).
@freezed
abstract class ServicesEditorState with _$ServicesEditorState {
  const ServicesEditorState._();

  const factory ServicesEditorState({
    @Default(<String>{}) Set<String> selected,
    @Default(<String>{}) Set<String> unSelected,
  }) = _ServicesEditorState;

  /// Checks if [serviceId] is in the [selected] set.
  bool isSelected(String serviceId) => selected.contains(serviceId);

  /// Checks if [serviceId] is in the [unSelected] set.
  bool isUnselected(String serviceId) => unSelected.contains(serviceId);
}

/// Notifier managing the selected and unselected service IDs.
///
/// When a service is added, it is appended to [ServicesEditorState.selected]
/// and popped/removed from [ServicesEditorState.unSelected].
/// When a service is removed, it is popped/removed from [ServicesEditorState.selected]
/// and appended to [ServicesEditorState.unSelected].
class ServicesEditorNotifier extends Notifier<ServicesEditorState> {
  @override
  ServicesEditorState build() {
    return const ServicesEditorState();
  }

  /// Initializes the state with initial sets of selected and unselected service IDs.
  void initialize({Set<String>? selected, Set<String>? unSelected}) {
    state = ServicesEditorState(
      selected: selected != null
          ? Set<String>.from(selected)
          : const <String>{},
      unSelected: unSelected != null
          ? Set<String>.from(unSelected)
          : const <String>{},
    );
  }

  /// Adds [serviceId] to [ServicesEditorState.selected] and removes (pops) it from [ServicesEditorState.unSelected].
  void add(String serviceId) {
    final updatedSelected = Set<String>.from(state.selected)..add(serviceId);
    final updatedUnSelected = Set<String>.from(state.unSelected)
      ..remove(serviceId);

    state = state.copyWith(
      selected: updatedSelected,
      unSelected: updatedUnSelected,
    );
  }

  /// Alias for [add].
  void addService(String serviceId) => add(serviceId);

  /// Pops/removes [serviceId] from [ServicesEditorState.selected] and adds it to [ServicesEditorState.unSelected].
  void remove(String serviceId) {
    final updatedSelected = Set<String>.from(state.selected)..remove(serviceId);
    final updatedUnSelected = Set<String>.from(state.unSelected)
      ..add(serviceId);

    state = state.copyWith(
      selected: updatedSelected,
      unSelected: updatedUnSelected,
    );
  }

  /// Alias for [remove].
  void removeService(String serviceId) => remove(serviceId);

  /// Toggles selection state of [serviceId].
  void toggle(String serviceId) {
    if (state.selected.contains(serviceId)) {
      remove(serviceId);
    } else {
      add(serviceId);
    }
  }

  /// Alias for [toggle].
  void toggleService(String serviceId) => toggle(serviceId);

  /// Resets both [selected] and [unSelected] sets to empty sets.
  void reset() {
    state = const ServicesEditorState();
  }

  /// Commits changes to backend via bulk APIs and invalidates user state on success.
  /// Ensures selected and unselected sets are strictly disjoint before sending.
  Future<void> saveChanges({
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      // Ensure a service in selected is not in unselected and vice versa
      final cleanSelected = state.selected.difference(state.unSelected);
      final cleanUnSelected = state.unSelected.difference(state.selected);

      if (cleanSelected.length != state.selected.length ||
          cleanUnSelected.length != state.unSelected.length) {
        state = state.copyWith(
          selected: cleanSelected,
          unSelected: cleanUnSelected,
        );
      }

      final client = ref.read(usersClientProvider);

      if (cleanSelected.isNotEmpty) {
        final response = await client.bulkAddProviderServices(
          BulkServiceRequest(serviceIds: cleanSelected.toList()),
        );
        if (response.isError) {
          throw Exception(response.detail ?? 'Failed to add services');
        }
      }

      if (cleanUnSelected.isNotEmpty) {
        final response = await client.bulkRemoveProviderServices(
          BulkServiceRequest(serviceIds: cleanUnSelected.toList()),
        );
        if (response.isError) {
          throw Exception(response.detail ?? 'Failed to remove services');
        }
      }

      // ref.invalidate(userProvider); this would be handled in onSuccess
      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

/// Provider exposing [ServicesEditorNotifier] state.
final servicesEditorProvider =
    NotifierProvider<ServicesEditorNotifier, ServicesEditorState>(
      ServicesEditorNotifier.new,
    );

/// Alias for [ServicesEditorNotifier] matching [ServicesEditor] class naming.
typedef ServicesEditor = ServicesEditorNotifier;
