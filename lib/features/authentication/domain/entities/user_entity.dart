import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final bool isAnonymous;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [id, email, displayName, isAnonymous];
}
