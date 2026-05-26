import 'package:formflow/formflow.dart';

/// Abstract base class for a single step in a [FormFlowUtil].
///
/// Subclass [FormStep] for each step in your flow and implement [validate].
/// Override [onEnter] and [onExit] for lifecycle hooks.
///
/// The type parameter [T] is the data shape this step produces. It is used
/// by [FormFlowUtil.dataFor] to return typed data for a specific step.
///
/// ```dart
/// class PersonalInfoStep extends FormStep<PersonalInfoData> {
///   @override
///   String get id => 'personal_info';
///
///   @override
///   String get title => 'Personal Info';
///
///   String name = '';
///   String email = '';
///
///   @override
///   StepValidationResult validate() {
///     if (name.isEmpty) return StepValidationResult.invalid('Name is required.');
///     if (!email.contains('@')) return StepValidationResult.invalid('Invalid email.');
///     return StepValidationResult.valid();
///   }
///
///   @override
///   PersonalInfoData get data => PersonalInfoData(name: name, email: email);
/// }
/// ```
abstract class FormStep<T> {
  /// A unique identifier for this step.
  ///
  /// Used as the key in [FormFlowState.data] and [FormFlowUtil.dataFor].
  String get id;

  /// Human-readable title for this step.
  ///
  /// Used by [FormFlowProgress] and available for display in your UI.
  String get title;

  /// Optional subtitle or description for this step.
  String? get subtitle => null;

  /// Whether this step can be skipped without validation.
  ///
  /// When `true`, [FormFlowUtil.next] advances past this step without
  /// calling [validate]. Defaults to `false`.
  bool get isSkippable => false;

  /// Validates the current state of this step.
  ///
  /// Called by [FormFlowUtil.validate] and [FormFlowUtil.next].
  /// Return [StepValidationResult.valid()] to allow progression,
  /// or [StepValidationResult.invalid(message)] to block it.
  StepValidationResult validate();

  /// The current data snapshot for this step.
  ///
  /// Override to return a typed object representing all fields in this step.
  /// Called by [FormFlowUtil.updateData] and stored in
  /// [FormFlowState.data] under [id].
  T? get data => null;

  /// Called when the flow navigates to this step.
  ///
  /// Override to reset field focus, trigger animations, or prefill data.
  void onEnter() {}

  /// Called when the flow navigates away from this step.
  ///
  /// Override to persist local state, cancel timers, or clean up.
  void onExit() {}

  @override
  String toString() => 'FormStep(id: $id, title: $title)';
}
