import 'package:equatable/equatable.dart';

abstract class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object?> get props => [];
}

class SubmitPostEvent extends CreatePostEvent {
  final Map<String, dynamic> data;

  const SubmitPostEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class ResetFormEvent extends CreatePostEvent {}
