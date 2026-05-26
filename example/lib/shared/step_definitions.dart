import 'package:formflow/formflow.dart';

/// Add Step Definitions
class NameStep extends FormStep<Map<String, String>> {
  String firstName = '';
  String lastName = '';

  @override
  String get id => 'name';
  @override
  String get title => 'Name';

  @override
  StepValidationResult validate() {
    if (firstName.trim().isEmpty) {
      return StepValidationResult.invalid('First name is required.');
    }
    if (lastName.trim().isEmpty) {
      return StepValidationResult.invalid('Last name is required.');
    }
    return StepValidationResult.valid();
  }

  @override
  Map<String, String> get data => {
    'firstName': firstName,
    'lastName': lastName,
  };
}

class EmailStep extends FormStep<String> {
  String email = '';

  @override
  String get id => 'email';
  @override
  String get title => 'Email';

  @override
  StepValidationResult validate() {
    if (!email.contains('@') || !email.contains('.')) {
      return StepValidationResult.invalid('Enter a valid email address.');
    }
    return StepValidationResult.valid();
  }

  @override
  String get data => email;
}

class ReviewStep extends FormStep<void> {
  @override
  String get id => 'review';
  @override
  String get title => 'Review';

  @override
  StepValidationResult validate() => StepValidationResult.valid();
}
