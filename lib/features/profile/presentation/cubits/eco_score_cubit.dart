import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/features/profile/domain/models/eco_score_event.dart';

// ─── States ────────────────────────────────────────────────────────────────

abstract class EcoScoreState extends Equatable {
  const EcoScoreState();
  @override
  List<Object?> get props => [];
}

class EcoScoreInitial extends EcoScoreState {}

class EcoScoreLoading extends EcoScoreState {}

class EcoScoreLoaded extends EcoScoreState {
  final Map<String, dynamic> details;
  final List<EcoScoreEvent> history;

  const EcoScoreLoaded({required this.details, required this.history});

  @override
  List<Object?> get props => [details, history];
}

class EcoScoreError extends EcoScoreState {
  final String message;
  const EcoScoreError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ─────────────────────────────────────────────────────────────────

class EcoScoreCubit extends Cubit<EcoScoreState> {
  final ConsumerRepository _repo;

  EcoScoreCubit({ConsumerRepository? repo}) 
      : _repo = repo ?? ConsumerRepository(),
        super(EcoScoreInitial());

  Future<void> loadDetails() async {
    emit(EcoScoreLoading());
    try {
      final details = await _repo.fetchEcoScore();
      final history = await _repo.fetchEcoScoreHistory();
      emit(EcoScoreLoaded(details: details, history: history));
    } catch (e) {
      emit(EcoScoreError(e.toString()));
    }
  }
}
