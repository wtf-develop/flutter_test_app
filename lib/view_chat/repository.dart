import 'package:udp_hole/common/network/client.dart';

class MessagesListRepo {
  var network = NetworkClient();

  Future<List<String>> getMessages() {
    return network.getMessages();
  }
}
