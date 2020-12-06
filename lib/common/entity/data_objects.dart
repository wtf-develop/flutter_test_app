import 'package:json_annotation/json_annotation.dart';

part 'data_objects.g.dart';

//flutter pub run build_runner build
// or once
//flutter pub run build_runner watch

@JsonSerializable()
class User implements Comparable<User> {
  User(this.id, this.ipv4, this.port);

  @JsonKey(name: "u", required: true, disallowNullValue: true)
  String id = "";

  @JsonKey(name: "i", required: true, disallowNullValue: true)
  String ipv4 = "";

  @JsonKey(name: "p", required: true, disallowNullValue: true)
  int port = 0;

  @JsonKey(name: "n", defaultValue: "")
  String publicName = "";

  @JsonKey(ignore: true)
  String _privateName = "";

  @JsonKey(ignore: true, required: false)
  String get visibleName => (_privateName.isEmpty
      ? (publicName.isEmpty ? (ipv4) : (publicName))
      : _privateName);

  set visibleName(String name) => _privateName = name;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  int compareTo(User other) {
    if (other.id == this.id) {
      return 0;
    }
    var result = this.port - other.port;
    if (result == 0) {
      result = 1;
    }
    return result;
  }
}

@JsonSerializable()
class IdsRequest {
  IdsRequest(this.sender, this.ids);

  @JsonKey(name: "d", required: false, defaultValue: [])
  List<String> ids = [];

  @JsonKey(name: "s", required: true, defaultValue: "")
  String sender = "";

  factory IdsRequest.fromJson(Map<String, dynamic> json) =>
      _$IdsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$IdsRequestToJson(this);
}

@JsonSerializable()
class UsersList {
  UsersList(this.sender, this.users);

  @JsonKey(name: "s", required: true, defaultValue: "")
  String sender = "";

  @JsonKey(name: "r", required: false, defaultValue: [])
  List<User> users = [];

  factory UsersList.fromJson(Map<String, dynamic> json) =>
      _$UsersListFromJson(json);

  Map<String, dynamic> toJson() => _$UsersListToJson(this);
}

@JsonSerializable()
class MyContact {
  MyContact(
      this.id, this.privateName, this.lastIp, this.lastOnline, this.created);

  @JsonKey(name: "u", required: true, defaultValue: "")
  String id = "";

  @JsonKey(name: "n", required: true, defaultValue: "")
  String privateName = "";

  @JsonKey(name: "l", required: true, defaultValue: "")
  String lastIp = "";

  @JsonKey(name: "o", required: true, defaultValue: 0)
  int lastOnline = 0;

  @JsonKey(name: "c", required: true, defaultValue: 0)
  int created = 0;

  factory MyContact.fromJson(Map<String, dynamic> json) =>
      _$MyContactFromJson(json);

  Map<String, dynamic> toJson() => _$MyContactToJson(this);
}

@JsonSerializable()
class MyContactsList {
  MyContactsList(this.contacts);

  @JsonKey(required: true, defaultValue: [])
  List<MyContact> contacts = [];

  @JsonKey(ignore: true)
  List<String> getIdsOnly() {
    var arr = List<String>();
    for (var item in contacts) {
      arr.add(item.id);
    }
    return arr;
  }

  factory MyContactsList.fromJson(Map<String, dynamic> json) =>
      _$MyContactsListFromJson(json);

  Map<String, dynamic> toJson() => _$MyContactsListToJson(this);
}
