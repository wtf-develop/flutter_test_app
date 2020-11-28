import 'package:json_annotation/json_annotation.dart';

part 'data_objects.g.dart';

@JsonSerializable()
class User {
  User(this.id, this.ip, this.port);

  @JsonKey(required: true)
  String id;

  @JsonKey(defaultValue: "127.0.0.1")
  String ip;

  @JsonKey(defaultValue: 27950)
  int port;

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
}
