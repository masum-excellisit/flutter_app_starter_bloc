import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/edit_profile_repository.dart';

import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final EditProfileRepository repository;

  EditProfileBloc(this.repository) : super(EditProfileInitial()) {
    on<FetchProfileEvent>((event, emit) async {
      emit(EditProfileLoading());
      final response = await repository.fetchProfile();
      if (response.data != null) {
        emit(EditProfileLoaded(response.data!));
      } else {
        emit(EditProfileError(response.errorMessage ?? "Something went wrong"));
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(EditProfileLoading());
      final response = await repository.updateProfile(event.request,
          imageFile: event.imageFile);
      print("Response: ${response.toString()}");
      if (response.data != null) {
        emit(EditProfileLoaded(response.data!));
      } else {
        emit(EditProfileError(response.errorMessage ?? "Update failed"));
      }
    });
  }
}
