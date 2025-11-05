import 'package:equatable/equatable.dart';

abstract class CreateProductEvent extends Equatable {
  const CreateProductEvent();

  @override
  List<Object?> get props => [];
}

class SubmitProductEvent extends CreateProductEvent {
  final Map<String, dynamic> data;

  const SubmitProductEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class ResetFormEvent extends CreateProductEvent {}
