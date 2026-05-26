import 'package:formflow/formflow.dart';

/// A horizontal step progress indicator for multi-step flows.
///
/// Can be customized using explicit icons or custom label text generation overrides.
///
/// ```dart
/// StepsProgress(
///   currentIndex: 0,
///   stepCount: 3,
///   isComplete: false,
///   activeColor: Colors.blue,
///   inactiveColor: Colors.grey,
///   completedIcon: Icons.verified, // Optional override
/// )
/// ```
class StepsProgress extends StatelessWidget {
  /// Index of the currently active step (0-based).
  final int currentIndex;

  /// Total number of steps in the flow.
  final int stepCount;

  /// Whether the entire flow has been completed.
  final bool isComplete;

  /// Optional titles for each step.
  ///
  /// If provided, must match [stepCount].
  /// If null, step numbers will be shown instead or handled via [stepLabelBuilder].
  final List<String>? titles;

  /// The color used for completed and currently active steps.
  final Color activeColor;

  /// The color used for pending/unreached steps.
  final Color inactiveColor;

  /// Optional icon to display when a step status is marked done.
  ///
  /// Defaults to [Icons.check] if not provided.
  final IconData? completedIcon;

  /// An optional builder to customize the widget nested inside the step circle.
  ///
  /// Provides the 0-based step index, whether it is done, and if it's currently active.
  /// If this returns null, the default checkmark/number system will be applied.
  final Widget? Function(
    BuildContext context,
    int index,
    bool isDone,
    bool isActive,
  )?
  stepIconBuilder;

  /// An optional builder to customize the text label displayed below the step circle.
  ///
  /// Takes precedence over the [titles] list parameter if provided.
  final String Function(int index)? stepLabelBuilder;

  const StepsProgress({
    super.key,
    required this.currentIndex,
    required this.stepCount,
    required this.isComplete,
    this.titles,
    required this.activeColor,
    required this.inactiveColor,
    this.completedIcon,
    this.stepIconBuilder,
    this.stepLabelBuilder,
  }) : assert(stepCount > 0, 'stepCount must be greater than 0'),
       assert(currentIndex >= 0, 'currentIndex cannot be negative'),
       assert(
         isComplete || currentIndex < stepCount,
         'currentIndex must be less than stepCount when not complete',
       ),
       assert(
         titles == null || titles.length == stepCount,
         'titles must be null or have the same length as stepCount',
       );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: List.generate(stepCount, (i) {
        final isActive = i == currentIndex && !isComplete;
        final isDone = isComplete || i < currentIndex;

        final color = isActive || isDone ? activeColor : inactiveColor;

        // Determine label value based on custom builder or fallback titles list
        final label = stepLabelBuilder != null
            ? stepLabelBuilder!(i)
            : (titles?[i] ?? '${i + 1}');

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Step indicator row:
              /// connector line + step circle
              Row(
                children: [
                  // Left connector line
                  if (i > 0)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        color: isDone
                            ? activeColor
                            : inactiveColor.withValues(alpha: 0.3),
                      ),
                    ),

                  // Step circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? activeColor : Colors.transparent,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(
                      child: _buildStepInnerWidget(
                        context,
                        i,
                        isDone,
                        isActive,
                        color,
                      ),
                    ),
                  ),

                  // Right connector line
                  if (i < stepCount - 1)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        color: isComplete || (i + 1) <= currentIndex
                            ? activeColor
                            : inactiveColor.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 6),

              // Step label text
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Evaluates inner widget presentation priorities based on builder presence.
  Widget _buildStepInnerWidget(
    BuildContext context,
    int index,
    bool isDone,
    bool isActive,
    Color color,
  ) {
    // 1. Check if the package consumer supplied a custom content builder mapping
    if (stepIconBuilder != null) {
      final customWidget = stepIconBuilder!(context, index, isDone, isActive);
      if (customWidget != null) return customWidget;
    }

    // 2. Default to Icon render if step state is completely resolved
    if (isDone) {
      return Icon(completedIcon ?? Icons.check, size: 14, color: Colors.white);
    }

    // 3. Fallback to standard indexed text configuration
    return Text(
      '${index + 1}',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
    );
  }
}
