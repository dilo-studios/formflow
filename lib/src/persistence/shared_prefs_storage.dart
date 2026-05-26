import 'dart:convert';
import 'package:formflow/formflow.dart';

/// A [FormFlowStorage] implementation backed by [SharedPreferences].
///
/// Pass to [FormFlowUtil] to persist flow progress across app restarts:
///
/// ```dart
/// final flow = FormFlowUtil(
///   steps: [...],
///   storage: SharedPrefsStorage(),
///   persistenceKey: 'onboarding_flow',
/// );
///
/// // On app start, restore previous progress:
/// await flow.restore();
/// ```
class SharedPrefsStorage implements FormFlowStorage {
  static const _prefix = 'formflow_';

  @override
  Future<void> save(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', jsonEncode(data));
  }

  @override
  Future<Map<String, dynamic>?> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('$_prefix$key');
    if (value == null) return null;
    return Map<String, dynamic>.from(jsonDecode(value) as Map);
  }

  @override
  Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }
}
