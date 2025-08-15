part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {}

class AuthSocialRequested extends AuthEvent {}

class AuthGuestRequested extends AuthEvent {}
