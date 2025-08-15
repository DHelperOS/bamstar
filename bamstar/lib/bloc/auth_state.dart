part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();
  
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final String user;
  
  const AuthAuthenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  final String error;
  
  const AuthFailure(this.error);
  
  @override
  List<Object> get props => [error];
}
