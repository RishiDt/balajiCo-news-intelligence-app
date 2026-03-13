// Hive-compatible user model (manual adapter)
import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String? token;
  @HiveField(3)
  final DateTime loggedInAt;

  UserModel({
    required this.id,
    required this.username,
    this.token,
    required this.loggedInAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        username: json['username'] as String,
        token: json['token'] as String?,
        loggedInAt: DateTime.parse(json['loggedInAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'token': token,
        'loggedInAt': loggedInAt.toIso8601String(),
      };
}

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return UserModel(
      id: fields[0] as String,
      username: fields[1] as String,
      token: fields[2] as String?,
      loggedInAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.token)
      ..writeByte(3)
      ..write(obj.loggedInAt);
  }
}
