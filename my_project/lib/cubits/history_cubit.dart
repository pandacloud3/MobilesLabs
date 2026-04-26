import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/data/api_service.dart';
import 'package:my_project/domain/bin_event_model.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<BinEvent> events;
  HistoryLoaded(this.events);
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

class HistoryCubit extends Cubit<HistoryState> {
  final ApiService _apiService;

  HistoryCubit(this._apiService) : super(HistoryInitial());

  Future<void> fetchHistory() async {
    emit(HistoryLoading());
    try {
      final events = await _apiService.getHistory();
      emit(HistoryLoaded(events));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
