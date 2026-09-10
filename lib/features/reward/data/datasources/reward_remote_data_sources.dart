import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_classification_app/features/reward/data/models/reward_models.dart';

abstract class RewardRemoteDataSources {
  Future<List<RewardModels>> getReward();
}

class RewardRemoteDataSourcesImpl implements RewardRemoteDataSources {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<List<RewardModels>> getReward() async {
    try {
      final snapshot = await _firestore.collection('rewards').get();
      return snapshot.docs
          .map((doc) => RewardModels.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rewards: $e');
    }
  }
}
