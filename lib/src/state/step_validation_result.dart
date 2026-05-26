/// The result of validating a single form step.
///
/// Create with [StepValidationResult.valid] or [StepValidationResult.invalid].
///
/// ```dart
/// @override
/// StepValidationResult validate() {
///   if (email.isEmpty) return StepValidationResult.invalid('Email is required.');
///   return StepValidationResult.valid();
/// }
/// ```
class StepValidationResult {
  /// Whether this step passed validation.
  final bool isValid;

  /// An optional error message when [isValid] is `false`.
  final String? error;

  const StepValidationResult._({required this.isValid, this.error});

  /// Creates a passing validation result.
  factory StepValidationResult.valid() =>
      const StepValidationResult._(isValid: true);

  /// Creates a failing validation result with an optional [error] message.
  factory StepValidationResult.invalid([String? error]) =>
      StepValidationResult._(isValid: false, error: error);

  /// Whether validation failed.
  bool get isInvalid => !isValid;

  @override
  String toString() => 'StepValidationResult(isValid: $isValid, error: $error)';
}
