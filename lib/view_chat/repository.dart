import 'package:udp_hole/common/entity/data_objects.dart';
import 'package:udp_hole/udp_connection/model.dart';

class MessagesListRepo {
  var network = UdpModel();

  Future<List<String>> getMessages() {
    return network.getMessages();
  }

  void sendMessage(UserMessage mess) {
    network.sendMessage(mess);
  }
}
