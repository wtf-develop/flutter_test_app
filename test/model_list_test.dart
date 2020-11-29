import 'package:test/test.dart';
import 'package:udp_hole/entity/data_objects.dart';
import 'package:udp_hole/view_friends/model.dart';

void main() {
  test('Merge list users from server', () {
    final mylist = UserListModel();
    mylist.removeAll();
    expect(mylist.items.length, 0);
    mylist.add(User("kalsjfh1", "ip", 99));
    mylist.add(User("kalsjfh2", "ip", 99));
    mylist.add(User("kalsjfh3", "ip", 99));
    mylist.add(User("kalsjfh4", "ip", 99));
    mylist.add(User("kalsjfh5", "ip", 99));
    expect(mylist.items[3].id, "kalsjfh4");
    expect(mylist.items.length, 5);

    List<User> fromServer = [
      User("kalsjfh5", "ip", 99),
      User("kalsjfh1", "ip", 99),
      User("kalsjfh3", "ip", 99),
      User("kalsjfh2", "ip", 99),
    ];
    mylist.update(fromServer);
    expect(mylist.items.length, 4);
    expect(mylist.items[3].id, "kalsjfh5");
    fromServer = [
      User("kalsjfh0", "ip", 99),
      User("kalsjfh2", "ip", 99),
      User("kalsjfh5", "ip", 99),
      User("kalsjfh3", "ip", 99),
    ];
    mylist.update(fromServer);
    expect(mylist.items.length, 4);
    expect(mylist.items[3].id, "kalsjfh0");

    mylist.removeAll();
    expect(mylist.items.length, 0);
  });
}
