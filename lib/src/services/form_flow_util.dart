import 'dart:async';
import 'package:formflow/formflow.dart';

/// The core controller for a multi-step form flow.
///
/// [FormFlowUtil] is pure Dart and it has no Flutter or state-management
/// dependencies. Wire it into Riverpod, Bloc, Provider, GetX, or plain
/// [ValueNotifier] by listening to [stream] or [state].
///
/// ```dart
/// final flow = FormFlowUtil(
///   steps: [PersonalInfoStep(), AddressStep(), ReviewStep()],
///   onComplete: (data) => submitForm(data),
/// );
///
/// flow.next();       // validate current step and advance
/// flow.back();       // go to previous step
/// flow.jumpTo(2);    // jump to step index 2
/// flow.validate();   // validate without advancing
/// ```
///
/// Dispose the controller when done to release the stream:
/// ```dart
/// flow.dispose();
/// ```
class FormFlowUtil {
  final List<FormStep> _steps;
  final void Function(Map<String, dynamic> data)? _onComplete;
  final FormFlowStorage? _storage;
  final String? _persistenceKey;

  late FormFlowState _state;
  final _controller = StreamController<FormFlowState>.broadcast();

  /// Creates a [FormFlowUtil].
  ///
  /// - [steps]: Ordered list of steps in the flow. Must not be empty.
  /// - [_onComplete]: Called with merged step data when the last step is submitted.
  /// - [storage]: Optional persistence backend. Defaults to in-memory only.
  /// - [persistenceKey]: Key used for persistent storage. Required when [storage] is provided.
  /// - [initialIndex]: Step to start on. Defaults to `0`.
  FormFlowUtil({
    required List<FormStep> steps,
    this._onComplete,
    FormFlowStorage? storage,
    String? persistenceKey,
    int initialIndex = 0,
  }) : _steps = steps,
       _storage = storage,
       _persistenceKey = persistenceKey {
    assert(steps.isNotEmpty, 'FormFlowUtil: steps must not be empty.');
    assert(
      initialIndex >= 0 && initialIndex < steps.length,
      'FormFlowUtil: initialIndex must be within bounds.',
    );
    assert(
      storage == null || persistenceKey != null,
      'FormFlowUtil: persistenceKey is required when storage is provided.',
    );

    _state = FormFlowState(
      stepCount: steps.length,
      currentIndex: initialIndex,
      isCurrentStepValid: false,
      isComplete: false,
      data: {},
    );

    _steps[initialIndex].onEnter();
  }

  /// The current state snapshot.
  FormFlowState get state => _state;

  /// Stream of state updates. Listen to drive your UI or state management layer.
  Stream<FormFlowState> get stream => _controller.stream;

  /// The currently active step.
  FormStep get currentStep => _steps[_state.currentIndex];

  /// All steps in the flow.
  List<FormStep> get steps => List.unmodifiable(_steps);

  /// Progress through the flow as a value between 0.0 and 1.0.
  double get progress => _state.progress;

  /// Whether the flow has been completed.
  bool get isComplete => _state.isComplete;

  /// Validates the current step and advances to the next one if valid.
  ///
  /// If the current step is the last step, [onComplete] is called with the
  /// merged data from all steps and the flow is marked complete.
  ///
  /// Does nothing if the flow is already complete.
  ///
  /// Returns `true` if navigation occurred, `false` if validation failed.
  bool next() {
    if (_state.isComplete) return false;

    final step = currentStep;

    if (!step.isSkippable) {
      final result = step.validate();
      _emit(
        _state.copyWith(
          isCurrentStepValid: result.isValid,
          lastValidationResult: result,
        ),
      );
      if (!result.isValid) return false;
    }

    _captureStepData(step);
    step.onExit();

    if (_state.isLastStep) {
      _emit(_state.copyWith(isComplete: true));
      _onComplete?.call(Map.unmodifiable(_state.data));
      _persistState();
      return true;
    }

    final nextIndex = _state.currentIndex + 1;
    _emit(
      _state.copyWith(
        currentIndex: nextIndex,
        isCurrentStepValid: false,
        lastValidationResult: null,
      ),
    );
    _steps[nextIndex].onEnter();
    _persistState();
    return true;
  }

  /// Navigates to the previous step without validation.
  ///
  /// Does nothing if already on the first step or the flow is complete.
  ///
  /// Returns `true` if navigation occurred.
  bool back() {
    if (_state.isFirstStep || _state.isComplete) return false;

    currentStep.onExit();
    final prevIndex = _state.currentIndex - 1;
    _emit(
      _state.copyWith(
        currentIndex: prevIndex,
        isCurrentStepValid: false,
        lastValidationResult: null,
      ),
    );
    _steps[prevIndex].onEnter();
    _persistState();
    return true;
  }

  /// Jumps directly to the step at [index] without validation.
  ///
  /// Use with caution if skipping steps bypasses their validation.
  /// Useful for edit flows where the user returns to a specific step.
  ///
  /// Returns `true` if navigation occurred.
  bool jumpTo(int index) {
    assert(
      index >= 0 && index < _steps.length,
      'FormFlowUtil.jumpTo: index $index is out of bounds.',
    );
    if (index == _state.currentIndex) return false;

    currentStep.onExit();
    _emit(
      _state.copyWith(
        currentIndex: index,
        isCurrentStepValid: false,
        lastValidationResult: null,
      ),
    );
    _steps[index].onEnter();
    _persistState();
    return true;
  }

  /// Validates the current step without navigating.
  ///
  /// Updates [state] with the validation result and returns it.
  StepValidationResult validate() {
    final result = currentStep.validate();
    _emit(
      _state.copyWith(
        isCurrentStepValid: result.isValid,
        lastValidationResult: result,
      ),
    );
    return result;
  }

  /// Updates the merged data for the current step.
  ///
  /// Call this from your UI whenever field values change:
  /// ```dart
  /// TextField(
  ///   onChanged: (_) => flow.updateData(),
  /// )
  /// ```
  void updateData() {
    _captureStepData(currentStep);
    _persistState();
  }

  /// Returns the typed data for the step with [stepId].
  ///
  /// Returns `null` if no data has been captured for that step yet.
  ///
  /// ```dart
  /// final info = flow.dataFor<PersonalInfoData>('personal_info');
  /// ```
  T? dataFor<T>(String stepId) {
    final value = _state.data[stepId];
    return value is T ? value : null;
  }

  /// Resets the flow to its initial state.
  ///
  /// Clears all step data, navigates to the first step, and calls
  /// [onEnter] on the first step.
  void reset() {
    currentStep.onExit();
    _emit(
      FormFlowState(
        stepCount: _steps.length,
        currentIndex: 0,
        isCurrentStepValid: false,
        isComplete: false,
        data: {},
      ),
    );
    _steps[0].onEnter();
    _persistState();
  }

  /// Restores flow state from [storage] if available.
  ///
  /// Call this during app init or splash to resume an interrupted flow.
  /// Does nothing if no [storage] or [persistenceKey] was provided.
  Future<void> restore() async {
    if (_storage == null || _persistenceKey == null) return;
    final saved = await _storage.load(_persistenceKey);
    if (saved == null) return;

    final index = saved['currentIndex'] as int? ?? 0;
    final data = Map<String, dynamic>.from(saved['data'] as Map? ?? {});

    if (index >= 0 && index < _steps.length) {
      currentStep.onExit();
      _emit(_state.copyWith(currentIndex: index, data: data));
      _steps[index].onEnter();
    }
  }

  /// Releases the stream controller. Call when the controller is no longer needed.
  void dispose() {
    _controller.close();
  }

  //Private helpers
  void _emit(FormFlowState newState) {
    _state = newState;
    if (!_controller.isClosed) _controller.add(_state);
  }

  void _captureStepData(FormStep step) {
    final stepData = step.data;
    if (stepData == null) return;
    final updated = Map<String, dynamic>.from(_state.data)
      ..[step.id] = stepData;
    _emit(_state.copyWith(data: updated));
  }

  Future<void> _persistState() async {
    if (_storage == null || _persistenceKey == null) return;
    await _storage.save(_persistenceKey, {
      'currentIndex': _state.currentIndex,
      'data': _state.data,
    });
  }
}
