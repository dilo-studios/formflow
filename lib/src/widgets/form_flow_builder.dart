import 'package:formflow/formflow.dart';

/// A widget that listens to a [FormFlowUtil] and rebuilds on every
/// state change.
///
/// [FormFlowBuilder] is package not tied to any state management tool;
/// it uses a [StreamBuilder] internally so it works alongside Riverpod,
/// Bloc, Provider, GetX, or plain `setState` without conflict.
///
/// ```dart
/// FormFlowBuilder(
///   controller: flow,
///   builder: (context, state) {
///     return Column(
///       children: [
///         Text('Step ${state.currentIndex + 1} of ${state.stepCount}'),
///         _buildStep(state),
///         if (state.lastValidationResult?.isInvalid == true)
///           Text(state.lastValidationResult!.error ?? 'Invalid'),
///         Row(
///           children: [
///             if (!state.isFirstStep)
///               ElevatedButton(
///                 onPressed: flow.back,
///                 child: const Text('Back'),
///               ),
///             ElevatedButton(
///               onPressed: flow.next,
///               child: Text(state.isLastStep ? 'Submit' : 'Next'),
///             ),
///           ],
///         ),
///       ],
///     );
///   },
/// )
/// ```
class FormFlowBuilder extends StatelessWidget {
  /// The controller driving this flow.
  final FormFlowUtil controller;

  /// Called with the latest [FormFlowState] on every state change.
  final Widget Function(BuildContext context, FormFlowState state) builder;

  /// Creates a [FormFlowBuilder].
  const FormFlowBuilder({
    super.key,
    required this.controller,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FormFlowState>(
      stream: controller.stream,
      initialData: controller.state,
      builder: (context, snapshot) {
        return builder(context, snapshot.data ?? controller.state);
      },
    );
  }
}
