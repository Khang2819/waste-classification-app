import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../map/domain/entities/waste_point_entity.dart';
import '../../../reward/domain/entities/reward_entity.dart';
import '../../domain/usecases/admin_usecases.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminUseCases adminUseCases;

  AdminCubit({required this.adminUseCases}) : super(const AdminState());

  Future<void> loadAllData({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(isLoading: true, clearMessages: true));
    }
    try {
      final results = await Future.wait([
        adminUseCases.getAllUsers(),
        adminUseCases.getAllWastePoints(),
        adminUseCases.getAllRewards(),
        adminUseCases.getAllRedeemHistories(),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          users: results[0] as dynamic,
          wastePoints: results[1] as dynamic,
          rewards: results[2] as dynamic,
          redeemHistories: results[3] as dynamic,
          clearMessages: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể tải dữ liệu quản trị: $e',
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  // ==================== WASTE POINTS ====================
  Future<void> saveWastePoint({
    String? id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required List<String> wasteTypes,
    required WastePointStatus status,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final entity = WastePointEntity(
        id: id ?? '',
        name: name.trim(),
        latitude: latitude,
        longitude: longitude,
        wasteTypes: wasteTypes,
        address: address.trim(),
        status: status,
      );

      if (id == null || id.isEmpty) {
        await adminUseCases.addWastePoint(entity);
      } else {
        await adminUseCases.updateWastePoint(entity);
      }

      final updatedPoints = await adminUseCases.getAllWastePoints();
      emit(
        state.copyWith(
          isSubmitting: false,
          wastePoints: updatedPoints,
          successMessage:
              id == null || id.isEmpty
                  ? 'Đã thêm điểm thu gom mới thành công!'
                  : 'Đã cập nhật điểm thu gom thành công!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Lỗi lưu điểm thu gom: $e',
        ),
      );
    }
  }

  Future<void> changeWastePointStatus(
    String pointId,
    WastePointStatus newStatus,
  ) async {
    emit(state.copyWith(clearMessages: true));
    try {
      await adminUseCases.updateWastePointStatus(pointId, newStatus);
      final updatedPoints =
          state.wastePoints.map((p) {
            if (p.id == pointId) {
              return WastePointEntity(
                id: p.id,
                name: p.name,
                latitude: p.latitude,
                longitude: p.longitude,
                wasteTypes: p.wasteTypes,
                address: p.address,
                status: newStatus,
              );
            }
            return p;
          }).toList();

      emit(
        state.copyWith(
          wastePoints: updatedPoints,
          successMessage:
              newStatus == WastePointStatus.active
                  ? 'Đã làm trống thùng rác & kích hoạt trạm!'
                  : 'Đã cập nhật trạng thái điểm thu gom!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Không thể đổi trạng thái trạm: $e'),
      );
    }
  }

  Future<void> deleteWastePoint(String pointId) async {
    emit(state.copyWith(clearMessages: true));
    try {
      await adminUseCases.deleteWastePoint(pointId);
      final updatedPoints =
          state.wastePoints.where((p) => p.id != pointId).toList();
      emit(
        state.copyWith(
          wastePoints: updatedPoints,
          successMessage: 'Đã xóa điểm thu gom rác!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Lỗi xóa điểm thu gom: $e'));
    }
  }

  // ==================== REWARDS & REDEEM HISTORIES ====================
  Future<void> saveReward({
    String? id,
    required String title,
    required String categoryName,
    required int points,
    required String description,
    required int stock,
    String? existingImageUrl,
    File? newImageFile,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      String? finalImageUrl = existingImageUrl;
      if (newImageFile != null) {
        final uploadedUrl = await CloudinaryService.uploadImage(newImageFile);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          finalImageUrl = uploadedUrl;
        }
      }

      final entity = RewardEntity(
        id: id ?? '',
        title: title.trim(),
        name: categoryName.trim(),
        points: points,
        description: description.trim(),
        stock: stock,
        imageUrl: finalImageUrl,
      );

      if (id == null || id.isEmpty) {
        await adminUseCases.addReward(entity);
      } else {
        await adminUseCases.updateReward(entity);
      }

      final updatedRewards = await adminUseCases.getAllRewards();
      emit(
        state.copyWith(
          isSubmitting: false,
          rewards: updatedRewards,
          successMessage:
              id == null || id.isEmpty
                  ? 'Đã thêm phần thưởng mới!'
                  : 'Đã cập nhật thông tin phần thưởng!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Lỗi lưu phần thưởng: $e',
        ),
      );
    }
  }

  Future<void> updateRewardStock(String rewardId, int newStock) async {
    if (newStock < 0) return;
    emit(state.copyWith(clearMessages: true));
    try {
      await adminUseCases.updateRewardStock(rewardId, newStock);
      final updatedRewards =
          state.rewards.map((r) {
            if (r.id == rewardId) {
              return RewardEntity(
                id: r.id,
                title: r.title,
                name: r.name,
                points: r.points,
                description: r.description,
                stock: newStock,
                imageUrl: r.imageUrl,
              );
            }
            return r;
          }).toList();

      emit(
        state.copyWith(
          rewards: updatedRewards,
          successMessage: 'Đã cập nhật tồn kho ($newStock)!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Lỗi cập nhật tồn kho: $e'));
    }
  }

  Future<void> deleteReward(String rewardId) async {
    emit(state.copyWith(clearMessages: true));
    try {
      await adminUseCases.deleteReward(rewardId);
      final updatedRewards =
          state.rewards.where((r) => r.id != rewardId).toList();
      emit(
        state.copyWith(
          rewards: updatedRewards,
          successMessage: 'Đã xóa phần thưởng!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Lỗi xóa phần thưởng: $e'));
    }
  }

  Future<void> updateRedeemHistoryStatus({
    required String userId,
    required String historyId,
    required String status,
  }) async {
    emit(state.copyWith(clearMessages: true));
    try {
      await adminUseCases.updateRedeemStatus(
        userId: userId,
        historyId: historyId,
        status: status,
      );
      final histories = await adminUseCases.getAllRedeemHistories();
      emit(
        state.copyWith(
          redeemHistories: histories,
          successMessage: 'Đã cập nhật trạng thái voucher!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Lỗi cập nhật voucher: $e'));
    }
  }

  // ==================== USERS & QR STATION REWARD ====================
  Future<void> adjustUserPointsAndXp({
    required String userIdOrQr,
    required int greenPointsDelta,
    required int xpDelta,
    required String reason,
    String notificationType = 'reward',
    bool incrementScanCount = false,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      await adminUseCases.adjustUserPointsAndXp(
        userId: userIdOrQr,
        greenPointsDelta: greenPointsDelta,
        xpDelta: xpDelta,
        reason: reason,
        notificationType: notificationType,
        incrementScanCount: incrementScanCount,
      );

      final updatedUsers = await adminUseCases.getAllUsers();
      emit(
        state.copyWith(
          isSubmitting: false,
          users: updatedUsers,
          successMessage:
              'Đã cập nhật điểm & gửi thông báo cho người dùng thành công!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Không thể cập nhật điểm: $e',
        ),
      );
    }
  }

  // ==================== SYSTEM NOTIFICATIONS ====================
  Future<void> sendSystemNotification({
    required String title,
    required String body,
    required String type,
    String? targetUserId,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      await adminUseCases.sendNotification(
        title: title,
        body: body,
        type: type,
        targetUserId: targetUserId,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          successMessage:
              targetUserId == null || targetUserId.isEmpty
                  ? 'Đã phát thông báo tới toàn bộ (${state.users.length}) người dùng!'
                  : 'Đã gửi thông báo tới người dùng thành công!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Lỗi gửi thông báo: $e',
        ),
      );
    }
  }
}

