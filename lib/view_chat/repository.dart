import 'package:udp_hole/udp_connection/model.dart';

class MessagesListRepo {
  var network = UdpModel();

  Future<List<String>> getMessages() {
    return network.getMessages();
  }
}
