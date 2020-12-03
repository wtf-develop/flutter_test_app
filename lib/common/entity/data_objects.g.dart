// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_objects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['id', 'ip', 'port'],
      disallowNullValues: const ['id', 'ip', 'port']);
  return User(
    json['id'] as String,
    json['ip'] as String,
    json['port'] as int,
  )..publicName = json['publicName'] as String ?? '';
}

Map<String, dynamic> _$UserToJson(User instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('ip', instance.ip);
  writeNotNull('port', instance.port);
  val['publicName'] = instance.publicName;
  return val;
}

IdsRequest _$IdsRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['sender']);
  return IdsRequest(
    json['sender'] as String ?? '',
    (json['ids'] as List)?.map((e) => e as String)?.toList() ?? [],
  );
}

Map<String, dynamic> _$IdsRequestToJson(IdsRequest instance) =>
    <String, dynamic>{
      'ids': instance.ids,
      'sender': instance.sender,
    };

UsersList _$UsersListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['sender']);
  return UsersList(
    json['sender'] as String ?? '',
    (json['users'] as List)
            ?.map((e) =>
                e == null ? null : User.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$UsersListToJson(UsersList instance) => <String, dynamic>{
      'sender': instance.sender,
      'users': instance.users,
    };
