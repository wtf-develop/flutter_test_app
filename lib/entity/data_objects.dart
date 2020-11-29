import 'package:json_annotation/json_annotation.dart';

part 'data_objects.g.dart';

@JsonSerializable()
class User implements Comparable<User> {
  User(this.id, this.ip, this.port);

  @JsonKey(required: true, disallowNullValue: true)
  String id = "";

  @JsonKey(required: true, disallowNullValue: true)
  String ip = "";

  @JsonKey(required: true, disallowNullValue: true)
  int port = 0;

  @JsonKey(defaultValue: "")
  String publicName = "";

  @JsonKey(ignore: true)
  String _privateName = "";

  @JsonKey(ignore: true, required: false)
  String get visibleName => (_privateName.isEmpty
      ? (publicName.isEmpty ? (ip) : (publicName))
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
  IdsRequest(this.ids);

  @JsonKey(required: false, defaultValue: [])
  List<String> ids = [];

  factory IdsRequest.fromJson(Map<String, dynamic> json) =>
      _$IdsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$IdsRequestToJson(this);
}
