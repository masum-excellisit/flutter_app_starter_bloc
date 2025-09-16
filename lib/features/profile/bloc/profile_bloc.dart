import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../data/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc(this.repository) : super(ProfileInitial()) {
    on<FetchProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final response = await repository.fetchProfile();

        if (response.data != null) {
          emit(ProfileLoaded(response.data!));
        } else {
          emit(ProfileError(response.errorMessage ?? "Failed to load profile"));
        }
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
