import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({required this.getCurrentUserUseCase, required this.logoutUseCase})
    : super(AuthInitial()) {
    on<AppStarted>(_onStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
  }

  Future<void> _onStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthUnknown());
    await emit.forEach<User?>(
      getCurrentUserUseCase(),
      onData: (user) {
        if (user != null) {
          return AuthAuthenticated(user: user);
        } else {
          return AuthUnauthenticated();
        }
      },
      onError: (_, __) => AuthUnauthenticated(),
    );
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthAuthenticated(user: event.user));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    try {
      await logoutUseCase();
    } catch (_) {}
    emit(AuthUnauthenticated());
  }
}
