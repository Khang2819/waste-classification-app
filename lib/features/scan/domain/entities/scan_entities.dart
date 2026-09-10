import 'package:equatable/equatable.dart';

class ScanEntities extends Equatable {
  final String label;
  final String imagePath;
  final double confidence;
  final String instruction;

  const ScanEntities({
    required this.label,
    required this.imagePath,
    required this.confidence,
    required this.instruction,
  });

  @override
  List<Object> get props => [label, imagePath, confidence, instruction];
}
