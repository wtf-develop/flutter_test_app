import 'package:udp_hole/common/entity/data_objects.dart';

class NetworkClient {
  Future<List<User>> getUsers() {
    return Future.delayed(Duration(milliseconds: 3000)).then((value) {
      return List<User>.generate(
          1000,
          (i) => User(i.toString() + "HelloIdname", "Ip address" + i.toString(),
              3333 + i));
    });
  }

  Future<List<String>> getMessages() {
    return Future.delayed(Duration(milliseconds: 1000)).then((value) {
      return List<String>.generate(10, (i) => ("Message" + i.toString()));
    });
  }
}
