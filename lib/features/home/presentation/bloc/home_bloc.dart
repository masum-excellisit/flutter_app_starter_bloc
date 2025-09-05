import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetDashboardDataUseCase getDashboardDataUseCase;

  HomeBloc({required this.getDashboardDataUseCase}) : super(HomeInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    final result = await getDashboardDataUseCase();

    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (data) => emit(HomeLoaded(dashboardData: data)),
    );
  }
}
