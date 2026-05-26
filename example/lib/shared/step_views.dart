import 'package:formflow/formflow.dart';
import 'shared.dart';

abstract class FormStepView<T extends FormStep> extends StatelessWidget {
  final T step;
  final FormFlowUtil flow;

  const FormStepView({super.key, required this.step, required this.flow});
}

class ReviewStepView extends FormStepView<ReviewStep> {
  const ReviewStepView({super.key, required super.step, required super.flow});

  @override
  Widget build(BuildContext context) {
    final name = flow.dataFor<Map>('name');
    final email = flow.dataFor<String>('email');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review your details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ReviewRow(label: 'First name', value: name?['firstName'] ?? ''),
        ReviewRow(label: 'Last name', value: name?['lastName'] ?? ''),
        ReviewRow(label: 'Email', value: email ?? ''),
      ],
    );
  }
}

class NameStepView extends FormStepView<NameStep> {
  const NameStepView({super.key, required super.step, required super.flow});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s your name?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(labelText: 'First name'),
          onChanged: (v) {
            step.firstName = v;
            flow.updateData();
          },
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(labelText: 'Last name'),
          onChanged: (v) {
            step.lastName = v;
            flow.updateData();
          },
        ),
      ],
    );
  }
}

class EmailStepView extends FormStepView<EmailStep> {
  const EmailStepView({super.key, required super.step, required super.flow});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your email address',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) {
            step.email = v;
            flow.updateData();
          },
        ),
      ],
    );
  }
}
