import 'package:udp_hole/common/entity/data_objects.dart';
import 'package:udp_hole/common/network/client.dart';

class UserListRepo {
  var network = NetworkClient();

  Stream<List<User>> getOnlineUsers() {
    var stream = network.getUsersListStream();
    return stream;
  }
}
