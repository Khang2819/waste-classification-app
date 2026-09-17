import 'package:equatable/equatable.dart';

class RewardEntity extends Equatable {
  final String id;
  final String title;
  final String name;
  final int points;
  final String description;
  final int stock;
  final String? imageUrl;
  const RewardEntity({
    required this.id,
    required this.title,
    required this.name,
    required this.points,
    required this.description,
    required this.stock,
    this.imageUrl,
  });
  @override
  List<Object?> get props => [
    id,
    title,
    name,
    points,
    description,
    stock,
    imageUrl,
  ];
}
