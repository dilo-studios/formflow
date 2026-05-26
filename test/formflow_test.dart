import 'package:flutter_test/flutter_test.dart';
import 'package:formflow/formflow.dart';

// Tests for step implementations

class NameStep extends FormStep<String> {
  String name = '';

  @override
  String get id => 'name';

  @override
  String get title => 'Your Name';

  @override
  StepValidationResult validate() {
    if (name.trim().isEmpty) {
      return StepValidationResult.invalid('Name is required.');
    }
    return StepValidationResult.valid();
  }

  @override
  String get data => name;
}

class EmailStep extends FormStep<String> {
  String email = '';

  @override
  String get id => 'email';

  @override
  String get title => 'Your Email';

  @override
  StepValidationResult validate() {
    if (!email.contains('@')) {
      return StepValidationResult.invalid('Invalid email.');
    }
    return StepValidationResult.valid();
  }

  @override
  String get data => email;
}

class SkippableStep extends FormStep<void> {
  @override
  String get id => 'optional';

  @override
  String get title => 'Optional Step';

  @override
  bool get isSkippable => true;

  @override
  StepValidationResult validate() => StepValidationResult.valid();
}

// Helpers

FormFlowUtil _makeFlow({
  int initialIndex = 0,
  void Function(Map<String, dynamic> data)? onComplete,
}) {
  return FormFlowUtil(
    steps: [NameStep(), EmailStep(), SkippableStep()],
    initialIndex: initialIndex,
    onComplete: onComplete,
  );
}

void main() {
  group('FormFlowUtil with initial state', () {
    test('starts at step 0 with correct stepCount', () {
      final flow = _makeFlow();
      expect(flow.state.currentIndex, 0);
      expect(flow.state.stepCount, 3);
      expect(flow.state.isComplete, false);
      expect(flow.state.isFirstStep, true);
      expect(flow.state.isLastStep, false);
      flow.dispose();
    });

    test('progress at step 0 is 1/3', () {
      final flow = _makeFlow();
      expect(flow.state.progress, closeTo(1 / 3, 0.001));
      flow.dispose();
    });
  });

  group('FormFlowUtil with validation', () {
    test(
      'next() returns false and emits invalid result when step is invalid',
      () {
        final flow = _makeFlow();
        final advanced = flow.next();
        expect(advanced, false);
        expect(flow.state.isCurrentStepValid, false);
        expect(flow.state.lastValidationResult?.isInvalid, true);
        expect(flow.state.lastValidationResult?.error, 'Name is required.');
        flow.dispose();
      },
    );

    test('next() advances when step is valid', () {
      final flow = _makeFlow();
      (flow.currentStep as NameStep).name = 'Baron';
      final advanced = flow.next();
      expect(advanced, true);
      expect(flow.state.currentIndex, 1);
      flow.dispose();
    });

    test('validate() updates state without navigating', () {
      final flow = _makeFlow();
      final result = flow.validate();
      expect(result.isInvalid, true);
      expect(flow.state.currentIndex, 0);
      flow.dispose();
    });
  });

  group('FormFlowUtil with navigation', () {
    test('back() does nothing on first step', () {
      final flow = _makeFlow();
      final moved = flow.back();
      expect(moved, false);
      expect(flow.state.currentIndex, 0);
      flow.dispose();
    });

    test('back() navigates to previous step', () {
      final flow = _makeFlow();
      (flow.currentStep as NameStep).name = 'Baron';
      flow.next();
      expect(flow.state.currentIndex, 1);
      flow.back();
      expect(flow.state.currentIndex, 0);
      flow.dispose();
    });

    test('jumpTo() navigates to target step', () {
      final flow = _makeFlow();
      flow.jumpTo(2);
      expect(flow.state.currentIndex, 2);
      flow.dispose();
    });
  });

  group('FormFlowUtil with skippable steps', () {
    test('skippable step advances without validation', () {
      final flow = FormFlowUtil(
        steps: [SkippableStep(), EmailStep()],
        onComplete: (_) {},
      );
      final advanced = flow.next();
      expect(advanced, true);
      expect(flow.state.currentIndex, 1);
      flow.dispose();
    });
  });

  group('FormFlowUtil with data', () {
    test('dataFor returns typed step data after next()', () {
      final flow = _makeFlow();
      (flow.currentStep as NameStep).name = 'Baron';
      flow.next();
      final name = flow.dataFor<String>('name');
      expect(name, 'Baron');
      flow.dispose();
    });
  });

  group('FormFlowUtil with completion', () {
    test('completing last step marks flow as complete', () {
      final flow = FormFlowUtil(steps: [NameStep()], onComplete: (_) {});
      (flow.currentStep as NameStep).name = 'Baron';
      flow.next();
      expect(flow.state.isComplete, true);
      expect(flow.state.progress, 1.0);
      flow.dispose();
    });

    test('next() does nothing once complete', () {
      final flow = FormFlowUtil(steps: [NameStep()], onComplete: (_) {});
      (flow.currentStep as NameStep).name = 'Baron';
      flow.next();
      final result = flow.next();
      expect(result, false);
      flow.dispose();
    });
  });

  group('FormFlowUtil with reset', () {
    test('reset clears data and returns to step 0', () {
      final flow = _makeFlow();
      (flow.currentStep as NameStep).name = 'Baron';
      flow.next();
      flow.reset();
      expect(flow.state.currentIndex, 0);
      expect(flow.state.data, isEmpty);
      flow.dispose();
    });
  });

  group('StepValidationResult', () {
    test('valid result has isValid true', () {
      final r = StepValidationResult.valid();
      expect(r.isValid, true);
      expect(r.isInvalid, false);
      expect(r.error, isNull);
    });

    test('invalid result carries error message', () {
      final r = StepValidationResult.invalid('Required');
      expect(r.isInvalid, true);
      expect(r.error, 'Required');
    });
  });

  group('FormFlowState', () {
    test('progress calculates correctly mid-flow', () {
      const s = FormFlowState(
        stepCount: 4,
        currentIndex: 1,
        isCurrentStepValid: false,
        isComplete: false,
        data: {},
      );
      expect(s.progress, closeTo(2 / 4, 0.001));
    });

    test('progress is 1.0 when complete', () {
      const s = FormFlowState(
        stepCount: 4,
        currentIndex: 3,
        isCurrentStepValid: true,
        isComplete: true,
        data: {},
      );
      expect(s.progress, 1.0);
    });
  });
}
