import 'package:formflow/formflow.dart';
import 'shared/shared.dart';

void main() => runApp(const FormFlowExample());

/// FormFlow Example App
class FormFlowExample extends StatelessWidget {
  const FormFlowExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormFlow Example',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final FormFlowUtil _flow;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _flow = FormFlowUtil(
      steps: [NameStep(), EmailStep(), ReviewStep()],
      onComplete: (data) => setState(() => _submitted = true),
    );
  }

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'All done!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Name: ${_flow.dataFor<Map>('name')?['firstName']} '
                '${_flow.dataFor<Map>('name')?['lastName']}',
              ),
              Text('Email: ${_flow.dataFor<String>('email')}'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: FormFlowBuilder(
        controller: _flow,
        builder: (context, state) {
          final isStepInvalid = state.lastValidationResult?.isInvalid == true;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Progress Indicators
                ///
                /// Configured to use 'FormFlowProgressStyle.steps' to utilize the
                /// horizontal progress line with structural circles, labels, and icons.
                FormFlowProgress(
                  state: state,
                  titles: _flow.steps.map((s) => s.title).toList(),
                  style: FormFlowProgressStyle.steps,
                  completedIcon:
                      Icons.check, // Native package icon override parameter
                  // Package hook: Highlight an error icon directly inside the current
                  // step circle if validation fails
                  stepIconBuilder: (context, index, isDone, isActive) {
                    if (isActive && isStepInvalid) {
                      return const Icon(
                        Icons.error_outline,
                        size: 14,
                        color: Colors.red,
                      );
                    }
                    return null; // Fallback to package defaults (numbers or check icons)
                  },
                ),
                const SizedBox(height: 32),

                // Step content
                // Wrapped inside a layout animation for smoother transitions between view states
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey<int>(state.currentIndex),
                      child: _buildStep(state),
                    ),
                  ),
                ),

                // Error
                if (isStepInvalid)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      state.lastValidationResult!.error ??
                          'Please check your input.',
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),

                // Navigation
                Row(
                  children: [
                    if (!state.isFirstStep)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _flow.back,
                          child: const Text('Back'),
                        ),
                      ),
                    if (!state.isFirstStep) const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _flow.next,
                        child: Text(state.isLastStep ? 'Submit' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(FormFlowState state) {
    final step = _flow.currentStep;

    return switch (step) {
      NameStep s => NameStepView(step: s, flow: _flow),
      EmailStep s => EmailStepView(step: s, flow: _flow),
      ReviewStep s => ReviewStepView(step: s, flow: _flow),
      _ => const SizedBox.shrink(),
    };
  }
}
