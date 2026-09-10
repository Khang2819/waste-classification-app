import 'package:equatable/equatable.dart';
import '../../domain/entities/scan_entities.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {
  final String? message;
  const ScanLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class ScanSuccess extends ScanState {
  final ScanEntities result;
  const ScanSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class ScanError extends ScanState {
  final String message;
  const ScanError(this.message);

  @override
  List<Object?> get props => [message];
}
