// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_objects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id']);
  return User(
    json['id'] as String,
    json['ip'] as String ?? '127.0.0.1',
    json['port'] as int ?? 27950,
  )..publicName = json['publicName'] as String ?? '';
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'ip': instance.ip,
      'port': instance.port,
      'publicName': instance.publicName,
    };
