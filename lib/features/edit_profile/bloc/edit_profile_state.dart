

import '../../profile/model/profile_response.dart';

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileLoaded extends EditProfileState {
  final ProfileResponse profile;
  EditProfileLoaded(this.profile);
}

class EditProfileError extends EditProfileState {
  final String message;
  EditProfileError(this.message);
}
