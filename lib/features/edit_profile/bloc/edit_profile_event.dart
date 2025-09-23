import 'dart:io';

import '../model/edit_profile_request.dart';

abstract class EditProfileEvent {}

class FetchProfileEvent extends EditProfileEvent {}

class UpdateProfileEvent extends EditProfileEvent {
  final EditProfileRequest request;
  final File? imageFile;
  UpdateProfileEvent(this.request, {this.imageFile});
}
