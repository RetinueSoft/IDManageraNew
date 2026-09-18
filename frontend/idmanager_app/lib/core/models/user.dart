import 'enums.dart';

class UserDto {
  final int id;
  final String name;
  final String phone;
  final UserRole role;
  final bool status;
  final int points;
  final DateTime createdAt;

  UserDto({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.status,
    required this.points,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: UserRole.fromInt(json['role'] as int? ?? 0),
        status: json['status'] as bool? ?? false,
        points: json['points'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role.toInt(),
        'status': status,
        'points': points,
        'createdAt': createdAt.toIso8601String(),
      };
}

class LoginResponse {
  final String accessToken;
  final UserDto user;

  LoginResponse({required this.accessToken, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accessToken'] as String,
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      );
}
