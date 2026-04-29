import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/data/api_service.dart';
import 'package:my_project/domain/bin_event_model.dart';

abstract class HistoryEvent {}

class FetchHistoryEvent extends HistoryEvent {}

class ToggleDataSourceEvent extends HistoryEvent {
  final bool useFirestore;
  ToggleDataSourceEvent(this.useFirestore);
}

abstract class HistoryState {
  final bool useFirestore;
  HistoryState({this.useFirestore = false});
}

class HistoryLoading extends HistoryState {
  HistoryLoading({super.useFirestore});
}

class HistoryLoaded extends HistoryState {
  final List<BinEvent> events;
  HistoryLoaded(this.events, {super.useFirestore});
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message, {super.useFirestore});
}

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ApiService _apiService;

  HistoryBloc(this._apiService) : super(HistoryLoading()) {
    on<FetchHistoryEvent>(_onFetchHistory);
    on<ToggleDataSourceEvent>(_onToggleDataSource);
  }

  Future<void> _onFetchHistory(
    FetchHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading(useFirestore: state.useFirestore));
    try {
      final events = await _apiService.getHistory(
        useFirestore: state.useFirestore,
      );
      emit(HistoryLoaded(events, useFirestore: state.useFirestore));
    } catch (e) {
      emit(HistoryError(e.toString(), useFirestore: state.useFirestore));
    }
  }

  Future<void> _onToggleDataSource(
    ToggleDataSourceEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading(useFirestore: event.useFirestore));
    add(FetchHistoryEvent());
  }
}
