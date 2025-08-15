import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSocialRequested>(_onSocialRequested);
    on<AuthGuestRequested>(_onGuestRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    // 시뮬레이션된 로그인 로직
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      // 여기에서는 항상 성공한다고 가정
      emit(const AuthAuthenticated('이메일 사용자'));
    } catch (e) {
      emit(AuthFailure('로그인 실패: $e'));
    }
  }

  Future<void> _onSocialRequested(
    AuthSocialRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    // 시뮬레이션된 소셜 로그인 로직
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      emit(const AuthAuthenticated('소셜 사용자'));
    } catch (e) {
      emit(AuthFailure('소셜 로그인 실패: $e'));
    }
  }

  Future<void> _onGuestRequested(
    AuthGuestRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    // 시뮬레이션된 게스트 로그인 로직
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      emit(const AuthAuthenticated('게스트 사용자'));
    } catch (e) {
      emit(AuthFailure('게스트 로그인 실패: $e'));
    }
  }
}
