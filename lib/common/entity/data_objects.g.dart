// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_objects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['u', 'i', 'p'],
      disallowNullValues: const ['u', 'i', 'p']);
  return User(
    json['u'] as String,
    json['i'] as String,
    json['p'] as int,
  )..publicName = json['n'] as String ?? '';
}

Map<String, dynamic> _$UserToJson(User instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('u', instance.id);
  writeNotNull('i', instance.ipv4);
  writeNotNull('p', instance.port);
  val['n'] = instance.publicName;
  return val;
}

IdsRequest _$IdsRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['s']);
  return IdsRequest(
    json['s'] as String ?? '',
    (json['d'] as List)?.map((e) => e as String)?.toList() ?? [],
  );
}

Map<String, dynamic> _$IdsRequestToJson(IdsRequest instance) =>
    <String, dynamic>{
      'd': instance.ids,
      's': instance.sender,
    };

UsersList _$UsersListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['s']);
  return UsersList(
    json['s'] as String ?? '',
    (json['r'] as List)
            ?.map((e) =>
                e == null ? null : User.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$UsersListToJson(UsersList instance) => <String, dynamic>{
      's': instance.sender,
      'r': instance.users,
    };

MyContact _$MyContactFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['u', 'n', 'l', 'o', 'c']);
  return MyContact(
    json['u'] as String ?? '',
    json['n'] as String ?? '',
    json['l'] as String ?? '',
    json['o'] as int ?? 0,
    json['c'] as int ?? 0,
  );
}

Map<String, dynamic> _$MyContactToJson(MyContact instance) => <String, dynamic>{
      'u': instance.id,
      'n': instance.privateName,
      'l': instance.lastIp,
      'o': instance.lastOnline,
      'c': instance.created,
    };

MyContactsList _$MyContactsListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['contacts']);
  return MyContactsList(
    (json['contacts'] as List)
            ?.map((e) => e == null
                ? null
                : MyContact.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$MyContactsListToJson(MyContactsList instance) =>
    <String, dynamic>{
      'contacts': instance.contacts,
    };
