# formflow

A Flutter package for building typed multi-step form flows with validation, flexible navigation, progress tracking, and optional persistence.

[![Pub Points](https://img.shields.io/pub/points/vize)](https://pub.dev/packages/formflow/score)
[![Build Status](https://github.com/dilo-studios/formflow/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/dilo-studios/formflow/actions)
[![pub package](https://img.shields.io/pub/v/formflow.svg)](https://pub.dev/packages/formflow)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- **Pure Dart controller:** no dependency on Riverpod, Bloc, Provider, or GetX
- **Typed step data:** each step owns its data shape via generics
- **Per-step validation:** block or allow progression with a clean result type
- **Skippable steps:** optional steps that bypass validation
- **Lifecycle hooks:** `onEnter` / `onExit` per step
- **Progress tracking:** `0.0-1.0` progress value + three built-in indicator styles
- **Optional persistence** resume interrupted flows via `SharedPreferences` or a custom backend
- **`FormFlowBuilder`** and `StreamBuilder`-based listener, compatible with any state management layer

---

## Installation

```yaml
dependencies:
  formflow: ^0.1.0
```

---

## Quick Start

### 1. Define your steps

```dart
class NameStep extends FormStep<String> {
  String name = '';

  @override String get id => 'name';
  @override String get title => 'Your Name';

  @override
  StepValidationResult validate() {
    if (name.trim().isEmpty) return StepValidationResult.invalid('Name is required.');
    return StepValidationResult.valid();
  }

  @override
  String get data => name;
}
```

### 2. Create the controller

```dart
final flow = FormFlowUtil(
  steps: [NameStep(), EmailStep(), ReviewStep()],
  onComplete: (data) => submitForm(data),
);
```

### 3. Build the UI

```dart
FormFlowBuilder(
  controller: flow,
  builder: (context, state) {
    return Column(
      children: [
        FormFlowProgress(
          state: state,
          titles: flow.steps.map((s) => s.title).toList(),
          style: FormFlowProgressStyle.steps,
        ),
        _buildCurrentStep(state),
        if (state.lastValidationResult?.isInvalid == true)
          Text(state.lastValidationResult!.error ?? ''),
        Row(
          children: [
            if (!state.isFirstStep)
              OutlinedButton(onPressed: flow.back, child: const Text('Back')),
            FilledButton(
              onPressed: flow.next,
              child: Text(state.isLastStep ? 'Submit' : 'Next'),
            ),
          ],
        ),
      ],
    );
  },
)
```

---

## Navigation

```dart
flow.next();        // validate + advance (or complete if last step)
flow.back();        // go back, no validation
flow.jumpTo(2);     // jump to step index 2, no validation
flow.validate();    // validate current step without advancing
flow.reset();       // clear all data, return to step 0
```

All navigation methods return `bool` as `true` if navigation occurred, `false` if blocked (validation failed, bounds exceeded, or already complete).

---

## Step data

```dart
// Get typed data for a specific step after next() has been called
final name = flow.dataFor<String>('name');
final info = flow.dataFor<PersonalInfoData>('personal_info');

// All merged step data
final allData = flow.state.data; // Map<String, dynamic>
```

---

## Progress

```dart
flow.progress          // double 0.0 - 1.0
flow.state.isFirstStep
flow.state.isLastStep
flow.state.isComplete
```

Three built-in progress indicator styles:

```dart
// Linear bar
FormFlowProgress(state: state, style: FormFlowProgressStyle.linear)

// Animated dots
FormFlowProgress(state: state, style: FormFlowProgressStyle.dots)

// Numbered step row with titles
FormFlowProgress(
  state: state,
  titles: flow.steps.map((s) => s.title).toList(),
  style: FormFlowProgressStyle.steps,
)
```

![Linear Progress](https://raw.githubusercontent.com/dilo-studios/formflow/main/assets/linear_progress.png)

![Dots Progress](https://raw.githubusercontent.com/dilo-studios/formflow/main/assets/dots_progress.png)

![Steps Progress](https://raw.githubusercontent.com/dilo-studios/formflow/main/assets/steps_progress.png)

![Completed Progress](https://raw.githubusercontent.com/dilo-studios/formflow/main/assets/completed_progress.png)

---

## Skippable steps

```dart
class OptionalStep extends FormStep<void> {
  @override bool get isSkippable => true;
  @override StepValidationResult validate() => StepValidationResult.valid();
  // ...
}
```

---

## Persistence

```dart
// Use the built-in SharedPreferences backend
final flow = FormFlowUtil(
  steps: [...],
  storage: SharedPrefsStorage(),
  persistenceKey: 'onboarding_flow',
  onComplete: (_) {},
);

// Restore on app start
await flow.restore();
```

Implement `FormFlowStorage` to use Hive, SQLite, secure storage, or any other backend:

```dart
class HiveFlowStorage implements FormFlowStorage {
  @override
  Future<void> save(String key, Map<String, dynamic> data) async { ... }
  @override
  Future<Map<String, dynamic>?> load(String key) async { ... }
  @override
  Future<void> clear(String key) async { ... }
}
```

---

## State management integration

`FormFlowUtil` emits state via a broadcast `Stream`. Wire it into anything:

```dart
// Riverpod
final flowProvider = StreamProvider((ref) => flow.stream);

// Bloc
flow.stream.listen((state) => add(FlowStateChanged(state)));

// ValueNotifier / setState
flow.stream.listen((state) => setState(() => _state = state));
```

---

## API Reference

### `FormFlowUtil`

| Method / Property       | Description                                      |
| ----------------------- | ------------------------------------------------ |
| `next()`                | Validate + advance. Returns `bool`.              |
| `back()`                | Go back. Returns `bool`.                         |
| `jumpTo(index)`         | Jump to step. Returns `bool`.                    |
| `validate()`            | Validate without navigating.                     |
| `updateData()`          | Capture current step data into state.            |
| `dataFor<T>(stepId)`    | Typed data for a step.                           |
| `reset()`               | Clear all data, return to step 0.                |
| `restore()`             | Load persisted state from storage.               |
| `dispose()`             | Close the stream. Call in `dispose()`.           |
| `state`                 | Current `FormFlowState` snapshot.                |
| `stream`                | Broadcast stream of `FormFlowState`.             |
| `progress`              | `double` 0.0-1.0.                                |
| `currentStep`           | The active `FormStep`.                           |
| `steps`                 | All steps (unmodifiable list).                   |

### `FormStep<T>`

| Member          | Description                                        |
| --------------- | -------------------------------------------------- |
| `id`            | Unique step identifier (required).                 |
| `title`         | Human-readable step name (required).               |
| `subtitle`      | Optional description.                              |
| `isSkippable`   | Skip validation on `next()`. Default `false`.      |
| `validate()`    | Returns `StepValidationResult`.                    |
| `data`          | Current typed data snapshot.                       |
| `onEnter()`     | Called when flow navigates to this step.           |
| `onExit()`      | Called when flow navigates away from this step.    |

### `FormFlowState`

| Property                 | Type                      | Description                     |
| ------------------------ | ------------------------- | ------------------------------- |
| `currentIndex`           | `int`                     | Zero-based active step index    |
| `stepCount`              | `int`                     | Total steps                     |
| `progress`               | `double`                  | 0.0-1.0                         |
| `isFirstStep`            | `bool`                    |                                 |
| `isLastStep`             | `bool`                    |                                 |
| `isComplete`             | `bool`                    |                                 |
| `isCurrentStepValid`     | `bool`                    |                                 |
| `lastValidationResult`   | `StepValidationResult?`   | Null until first validation     |
| `data`                   | `Map<String, dynamic>`    | Merged data from all steps      |

---

## License

MIT - see [LICENSE](LICENSE) for details.

## Support

If FormFlow helps you ship faster, a ⭐ on [GitHub](https://github.com/dilo-studios/formflow) goes a long way!

**Issues:** [GitHub Issues](https://github.com/dilo-studios/formflow/issues)

---

Made with ❤️ for the Flutter community.
