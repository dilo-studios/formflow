import 'package:formflow/formflow.dart';

/// A customizable animated linear progress indicator.
///
/// This widget wraps Flutter's [LinearProgressIndicator] and adds:
/// - smooth animated transitions between values
/// - rounded corners
/// - configurable colors and height
///
/// Commonly used in FormFlow to represent multi-step progress.
class LinearProgress extends StatelessWidget {
  /// Current progress value between 0.0 and 1.0.
  final double progress;

  /// Color of the filled (active) portion.
  final Color activeColor;

  /// Color of the unfilled (inactive) portion.
  final Color inactiveColor;

  /// Height of the progress bar.
  final double height;

  const LinearProgress({
    super.key,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.height,
  }) : assert(height > 0);

  @override
  Widget build(BuildContext context) {
    /// Clamp progress to avoid UI bugs if developers pass invalid values
    final clampedProgress = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: TweenAnimationBuilder<double>(
        /// Prevents animation always restarting from 0
        tween: Tween<double>(begin: 0, end: clampedProgress),

        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,

        builder: (context, value, _) {
          return LinearProgressIndicator(
            value: value,
            backgroundColor: inactiveColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(activeColor),
            minHeight: height,
          );
        },
      ),
    );
  }
}
