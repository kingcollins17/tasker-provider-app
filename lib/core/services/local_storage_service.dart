import 'dart:convert';
import 'package:hive/hive.dart';

enum HiveBoxes { appStorage }

enum HiveKeys { accessToken }

/// A local storage service that wraps Hive box operations.
class LocalStorageService {
  /// The filename representing the Hive box name.
  final String filename;

  LocalStorageService(this.filename);

  /// Helper method to ensure the Hive box is open before any operation.
  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(filename)) {
      return await Hive.openBox(filename);
    }
    return Hive.box(filename);
  }

  /// Retrieves a value from Hive and deserializes it.
  ///
  /// If the stored value is a JSON string, it will be decoded before
  /// passing to the [deserializer].
  Future<T?> get<T>(String key, [T Function(dynamic)? deserializer]) async {
    final box = await _getBox();
    final dynamic rawValue = box.get(key);
    if (rawValue == null) return null;

    dynamic processedValue = rawValue;
    if (rawValue is String) {
      try {
        processedValue = jsonDecode(rawValue);
      } catch (_) {
        processedValue = rawValue;
      }
    }

    if (deserializer != null) {
      return deserializer(processedValue);
    }
    return processedValue as T?;
  }

  /// Saves a value to Hive.
  ///
  /// If the type is already a [String], it saves it as-is.
  /// Otherwise, it uses [jsonEncode] to convert it to a JSON string.
  Future<void> save(String key, dynamic value) async {
    final box = await _getBox();
    if (value is String) {
      await box.put(key, value);
    } else {
      final jsonString = jsonEncode(value);
      await box.put(key, jsonString);
    }
  }

  /// Deletes the specified key from the Hive box.
  Future<void> delete(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  /// Clears all keys and values from the Hive box.
  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }
}

/// Global instance of [LocalStorageService] for quick app-wide storage access.
final appStorage = LocalStorageService(HiveBoxes.appStorage.name);
