# Changelog

All notable changes to **formflow** are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-05-25

### Added

- Initial release
- `FormStep<T>` typed abstract base class with validation, lifecycle hooks, and skippable step support
- `FormFlowUtil` pure Dart controller for navigation, validation, persistence, and flow state management
- `FormFlowState` immutable state snapshot with progress, completion, and validation metadata
- `StepValidationResult` result type with `valid()` and `invalid(message)` helpers
- `FormFlowBuilder` reactive builder widget powered by `StreamBuilder`
- `FormFlowProgress` animated progress indicator with `linear`, `dots`, and `steps` styles
- `FormFlowStorage` abstract persistence interface
- `SharedPrefsStorage` built-in `SharedPreferences` storage adapter
