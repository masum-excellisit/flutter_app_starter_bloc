import 'package:equatable/equatable.dart';
import '../models/post_model.dart';

enum CreatePostStatus { initial, loading, success, failure }

class CreatePostState extends Equatable {
  final CreatePostStatus status;
  final PostModel? post;
  final String? errorMessage;

  const CreatePostState({
    this.status = CreatePostStatus.initial,
    this.post,
    this.errorMessage,
  });

  CreatePostState copyWith({
    CreatePostStatus? status,
    PostModel? post,
    String? errorMessage,
  }) {
    return CreatePostState(
      status: status ?? this.status,
      post: post ?? this.post,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, post, errorMessage];
}
