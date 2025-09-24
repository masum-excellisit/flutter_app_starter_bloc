



import '../model/edit_profile_response.dart';

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileLoaded extends EditProfileState {
  final EditProfileResponse profile;
  EditProfileLoaded(this.profile);
}

class EditProfileError extends EditProfileState {
  final String message;
  EditProfileError(this.message);
}
