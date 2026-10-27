import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_all_as_read.dart';
import '../../domain/usecases/mark_as_read.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotifications getNotifications;
  final MarkAllAsRead markAllAsRead;
  final MarkAsRead markAsRead;

  StreamSubscription<List<AppNotification>>? _streamSubscription;

  NotificationCubit({
    required this.getNotifications,
    required this.markAllAsRead,
    required this.markAsRead,
  }) : super(NotificationInitial());

  void start(String uid) {
    if (state is! NotificationLoaded) {
      emit(NotificationLoading());
    }
    _streamSubscription?.cancel();
    _streamSubscription = getNotifications(uid).listen(
      (items) {
        emit(NotificationLoaded(items));
      },
      onError: (error) {
        emit(NotificationError(error.toString()));
      },
    );
  }

  Future<void> onMarkAsRead(String uid, String notificationId) async {
    try {
      await markAsRead(uid, notificationId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> onMarkAllAsRead(String uid) async {
    try {
      await markAllAsRead(uid);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
