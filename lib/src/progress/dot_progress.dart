import 'package:formflow/formflow.dart';

/// A compact dot-based progress indicator for multi-step flows.
///
/// Shows progress using animated dots, where:
/// - Completed steps are fully active
/// - Current step is visually emphasized (wider dot)
/// - Future steps are inactive
class DotsProgress extends StatelessWidget {
  /// Index of the currently active step (0-based).
  final int currentIndex;

  /// Total number of steps in the flow.
  final int stepCount;

  /// Whether the flow is fully completed.
  final bool isComplete;

  /// Color used for active/completed dots.
  final Color activeColor;

  /// Color used for inactive dots.
  final Color inactiveColor;

  /// Base size of each dot.
  final double dotSize;

  const DotsProgress({
    super.key,
    required this.currentIndex,
    required this.stepCount,
    required this.isComplete,
    required this.activeColor,
    required this.inactiveColor,
    required this.dotSize,
  }) : assert(stepCount > 0),
       assert(currentIndex >= 0),
       assert(currentIndex < stepCount),
       assert(dotSize > 0);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stepCount, (i) {
        /// Step is active if:
        /// a flow is complete OR
        /// a step index is <= current index
        final isActive = isComplete || i <= currentIndex;

        /// Current step is visually emphasized
        final isCurrent = i == currentIndex && !isComplete;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,

          margin: const EdgeInsets.symmetric(horizontal: 4),

          /// Current step is expanded for emphasis
          width: isCurrent ? dotSize * 2.4 : dotSize,
          height: dotSize,

          decoration: BoxDecoration(
            color: isActive
                ? activeColor
                : inactiveColor.withValues(alpha: 0.3),

            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}
