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
}
