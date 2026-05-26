/// Abstract persistence interface for [FormFlowUtil].
///
/// Implement this to provide a custom storage backend (Hive, SQLite,
/// secure storage, etc.). A [SharedPrefsStorage] implementation is
/// provided out of the box.
///
/// ```dart
/// class HiveFlowStorage implements FormFlowStorage {
///   @override
///   Future<void> save(String key, Map<String, dynamic> data) async {
///     await Hive.box('formflow').put(key, data);
///   }
///
///   @override
///   Future<Map<String, dynamic>?> load(String key) async {
///     return Hive.box('formflow').get(key) as Map<String, dynamic>?;
///   }
///
///   @override
///   Future<void> clear(String key) async {
///     await Hive.box('formflow').delete(key);
///   }
/// }
/// ```
abstract class FormFlowStorage {
  /// Persists [data] under [key].
  Future<void> save(String key, Map<String, dynamic> data);

  /// Loads data previously saved under [key].
  ///
  /// Returns `null` if no data exists for [key].
  Future<Map<String, dynamic>?> load(String key);

  /// Clears saved data for [key].
  Future<void> clear(String key);
}
