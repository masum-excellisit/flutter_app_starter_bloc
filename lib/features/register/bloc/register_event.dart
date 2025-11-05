import '../model/register_request.dart';

abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final RegisterRequest request;
  RegisterSubmitted(this.request);
}
