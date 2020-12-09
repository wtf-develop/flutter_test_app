import 'package:udp_hole/common/entity/data_objects.dart';
import 'package:udp_hole/udp_connection/model.dart';

class UserListRepo {
  var network = UdpModel();

  Stream<List<User>> getOnlineUsers() {
    var stream = network.getUsersListStream();
    return stream;
  }
}
