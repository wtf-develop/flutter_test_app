import 'package:udp_hole/common/entity/data_objects.dart';
import 'package:udp_hole/udp_connection/model.dart';

class MessagesListRepo {
  var network = UdpModel();

  List<UserMessage> getMessages(String userId) {
    return network.getMessages(userId);
  }

  Stream<UserMessage> subscribeMessage(String myId, String userId) {
    return network.getMessageStream().where((event) {
      return (event.from == myId && event.to == userId) ||
          (event.to == myId && event.from == userId);
    });
  }

  void sendMessage(UserMessage mess) {
    network.sendMessage(mess);
  }
}
