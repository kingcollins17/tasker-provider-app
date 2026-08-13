import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasker_app/core/providers/services_editor_provider.dart';

void main() {
  group('ServicesEditorState', () {
    test('initial state has empty sets', () {
      const state = ServicesEditorState();
      expect(state.selected, isEmpty);
      expect(state.unSelected, isEmpty);
    });

    test('isSelected and isUnselected return correct boolean', () {
      const state = ServicesEditorState(
        selected: {'s1', 's2'},
        unSelected: {'s3'},
      );
      expect(state.isSelected('s1'), isTrue);
      expect(state.isSelected('s3'), isFalse);
      expect(state.isUnselected('s3'), isTrue);
      expect(state.isUnselected('s1'), isFalse);
    });

    test('value equality works as expected', () {
      const state1 = ServicesEditorState(selected: {'a'}, unSelected: {'b'});
      const state2 = ServicesEditorState(selected: {'a'}, unSelected: {'b'});
      expect(state1, equals(state2));
    });
  });

  group('ServicesEditorNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state via provider is empty', () {
      final state = container.read(servicesEditorProvider);
      expect(state.selected, isEmpty);
      expect(state.unSelected, isEmpty);
    });

    test('add service adds to selected and removes from unSelected', () {
      final notifier = container.read(servicesEditorProvider.notifier);

      // Pre-set unselected set
      notifier.initialize(unSelected: {'s1', 's2'});

      notifier.add('s1');

      final state = container.read(servicesEditorProvider);
      expect(state.selected, contains('s1'));
      expect(state.unSelected, isNot(contains('s1')));
      expect(state.unSelected, contains('s2'));
    });

    test('remove service removes from selected and adds to unSelected', () {
      final notifier = container.read(servicesEditorProvider.notifier);

      // Pre-set selected set
      notifier.initialize(selected: {'s1', 's2'});

      notifier.remove('s1');

      final state = container.read(servicesEditorProvider);
      expect(state.selected, isNot(contains('s1')));
      expect(state.selected, contains('s2'));
      expect(state.unSelected, contains('s1'));
    });

    test('toggle service toggles between selected and unselected', () {
      final notifier = container.read(servicesEditorProvider.notifier);

      notifier.toggle('s1');
      expect(container.read(servicesEditorProvider).selected, contains('s1'));

      notifier.toggle('s1');
      expect(container.read(servicesEditorProvider).selected, isNot(contains('s1')));
      expect(container.read(servicesEditorProvider).unSelected, contains('s1'));
    });

    test('reset clears both selected and unselected sets', () {
      final notifier = container.read(servicesEditorProvider.notifier);

      notifier.initialize(selected: {'s1'}, unSelected: {'s2'});
      notifier.reset();

      final state = container.read(servicesEditorProvider);
      expect(state.selected, isEmpty);
      expect(state.unSelected, isEmpty);
    });
  });
}
