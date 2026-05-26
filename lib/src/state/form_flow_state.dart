import 'package:formflow/formflow.dart';

/// An immutable snapshot of the current [FormFlowUtil] state.
///
/// Rebuilt and emitted on every navigation or data change. Wire this into
/// your preferred state management solution or use [FormFlowBuilder] to
/// listen automatically.
class FormFlowState {
  /// Total number of steps in the flow.
  final int stepCount;

  /// Zero-based index of the currently active step.
  final int currentIndex;

  /// Whether the current step has been validated successfully.
  final bool isCurrentStepValid;

  /// The most recent validation result for the current step.
  ///
  /// `null` until [FormFlowUtil.validate] has been called at least once.
  final StepValidationResult? lastValidationResult;

  /// Whether the flow has been completed (all steps submitted).
  final bool isComplete;

  /// The merged data map from all steps, keyed by step ID.
  ///
  /// Each entry is the last data snapshot emitted by that step via
  /// [FormFlowUtil.updateData].
  final Map<String, dynamic> data;

  /// Creates a [FormFlowState].
  const FormFlowState({
    required this.stepCount,
    required this.currentIndex,
    required this.isCurrentStepValid,
    required this.isComplete,
    required this.data,
    this.lastValidationResult,
  });

  /// Whether the current step is the first step.
  bool get isFirstStep => currentIndex == 0;

  /// Whether the current step is the last step.
  bool get isLastStep => currentIndex == stepCount - 1;

  /// Progress through the flow as a value between 0.0 and 1.0.
  ///
  /// Returns `1.0` when [isComplete] is `true`.
  double get progress => isComplete
      ? 1.0
      : stepCount == 0
      ? 0.0
      : (currentIndex + 1) / stepCount;

  /// Creates a copy with the given fields replaced.
  FormFlowState copyWith({
    int? stepCount,
    int? currentIndex,
    bool? isCurrentStepValid,
    bool? isComplete,
    Map<String, dynamic>? data,
    StepValidationResult? lastValidationResult,
  }) {
    return FormFlowState(
      stepCount: stepCount ?? this.stepCount,
      currentIndex: currentIndex ?? this.currentIndex,
      isCurrentStepValid: isCurrentStepValid ?? this.isCurrentStepValid,
      isComplete: isComplete ?? this.isComplete,
      data: data ?? this.data,
      lastValidationResult: lastValidationResult ?? this.lastValidationResult,
    );
  }

  @override
  String toString() =>
      'FormFlowState(step: $currentIndex/$stepCount, '
      'valid: $isCurrentStepValid, complete: $isComplete)';
}
