import 'package:equatable/equatable.dart';

class RewardEntity extends Equatable {
  final String id;
  final String title;
  final int points;
  final String description;
  final int stock;
  const RewardEntity({
    required this.id,
    required this.title,
    required this.points,
    required this.description,
    required this.stock,
  });
  @override
  List<Object> get props => [id, title, points, description, stock];
}
