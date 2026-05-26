import 'package:formflow/formflow.dart';

/// The visual style of the [FormFlowProgress] indicator.
enum FormFlowProgressStyle {
  /// A linear progress bar.
  linear,

  /// A row of step dots (filled = visited, outlined = upcoming).
  dots,

  /// Step titles rendered as a horizontal tab-style row with status icons or numbers.
  steps,
}

/// A ready-made progress indicator for a [FormFlowUtil].
///
/// Pass the current [FormFlowState] and a list of step [titles] to render
/// progress in one of three styles.
///
/// ```dart
/// FormFlowProgress(
///   state: state,
///   titles: flow.steps.map((s) => s.title).toList(),
///   style: FormFlowProgressStyle.steps,
///   activeColor: Colors.blue,
///   completedIcon: Icons.done_all,
/// )
/// ```
class FormFlowProgress extends StatelessWidget {
  /// The current flow state.
  final FormFlowState state;

  /// Step titles displayed in [FormFlowProgressStyle.steps] mode.
  final List<String> titles;

  /// The visual style. Defaults to [FormFlowProgressStyle.linear].
  final FormFlowProgressStyle style;

  /// Color for the active step and filled progress. Defaults to
  /// the theme's primary color.
  final Color? activeColor;

  /// Color for inactive steps. Defaults to the theme's disabled color.
  final Color? inactiveColor;

  /// Height of the linear bar or dot diameter. Defaults to `6.0` for linear, `10.0` for dots.
  final double? size;

  /// Optional custom icon to display in [FormFlowProgressStyle.steps] mode
  /// when a step is fully completed. Defaults to [Icons.check].
  final IconData? completedIcon;

  /// Optional builder to customize the internal child of the step indicator circle
  /// during [FormFlowProgressStyle.steps] mode.
  final Widget? Function(
    BuildContext context,
    int index,
    bool isDone,
    bool isActive,
  )?
  stepIconBuilder;

  /// Optional builder to customize or format the text label displayed below the step circle
  /// during [FormFlowProgressStyle.steps] mode. Takes precedence over [titles] if defined.
  final String Function(int index)? stepLabelBuilder;

  /// Creates a [FormFlowProgress].
  const FormFlowProgress({
    super.key,
    required this.state,
    this.titles = const [],
    this.style = FormFlowProgressStyle.linear,
    this.activeColor,
    this.inactiveColor,
    this.size,
    this.completedIcon,
    this.stepIconBuilder,
    this.stepLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? theme.colorScheme.primary;
    final inactive = inactiveColor ?? theme.disabledColor;

    return switch (style) {
      FormFlowProgressStyle.linear => LinearProgress(
        progress: state.progress,
        activeColor: active,
        inactiveColor: inactive,
        height: size ?? 6.0,
      ),
      FormFlowProgressStyle.dots => DotsProgress(
        currentIndex: state.currentIndex,
        stepCount: state.stepCount,
        isComplete: state.isComplete,
        activeColor: active,
        inactiveColor: inactive,
        dotSize: size ?? 10.0,
      ),
      FormFlowProgressStyle.steps => StepsProgress(
        currentIndex: state.currentIndex,
        stepCount: state.stepCount,
        isComplete: state.isComplete,
        titles: titles.isNotEmpty ? titles : null,
        activeColor: active,
        inactiveColor: inactive,
        completedIcon: completedIcon,
        stepIconBuilder: stepIconBuilder,
        stepLabelBuilder: stepLabelBuilder,
      ),
    };
  }
}
