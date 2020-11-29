import 'package:test/test.dart';
import 'package:udp_hole/common/entity/data_objects.dart';
import 'package:udp_hole/view_friends/model.dart';

void main() {
  test('Test merging list with update callbacks', () {
    final mylist = UserListModel();
    //clear old data
    mylist.removeAll();
    expect(mylist.items.length, 0);

    //create current list
    mylist.add(User("kalsjfh1", "ip", 99));
    mylist.add(User("kalsjfh2", "ip", 99));
    mylist.add(User("kalsjfh3", "ip", 99));
    mylist.add(User("kalsjfh4", "ip", 99));
    mylist.add(User("kalsjfh5", "ip", 99));
    mylist.add(User("kalsjfh6", "ip", 99));
    mylist.add(User("kalsjfh7", "ip", 99));
    mylist.add(User("kalsjfh8", "ip", 99));
    mylist.add(User("kalsjfh9", "ip", 99));
    expect(mylist.items[3].id, "kalsjfh4");
    expect(mylist.items.length, 9);


    //remove element - "kalsjfh4",6,7,8,9
    List<User> fromServer = [
      User("kalsjfh5", "ip", 99),
      User("kalsjfh1", "ip", 99),
      User("kalsjfh3", "ip", 99),
      User("kalsjfh2", "ip", 99),
    ];
    mylist.update(fromServer);
    expect(mylist.items.length, 4);
    expect(mylist.items[3].id, "kalsjfh5");



    //remove element "kalsjfh1" and add "kalsjfh0" to the end
    fromServer = [
      User("kalsjfh0", "ip", 99),
      User("kalsjfh2", "ip", 99),
      User("kalsjfh5", "ip", 99),
      User("kalsjfh3", "ip", 99),
    ];
    var callbackTestFail=true;
    var listener = (() {
      callbackTestFail=false;//callback must be called
    });
    mylist.addListener(listener);
    mylist.update(fromServer);
    expect(callbackTestFail,false);
    expect(mylist.items.length, 4);
    expect(mylist.items[3].id, "kalsjfh0");
    mylist.removeListener(listener);



    //dont change anything, but order is random
    fromServer = [
      User("kalsjfh5", "ip", 99),
      User("kalsjfh2", "ip", 99),
      User("kalsjfh3", "ip", 99),
      User("kalsjfh0", "ip", 99),
    ];
    callbackTestFail=false;
    listener = (() {
      callbackTestFail=true;//callback must NOT be called
    });
    mylist.addListener(listener);
    mylist.update(fromServer);
    expect(callbackTestFail,false);
    mylist.removeListener(listener);



    //clear list from elements
    mylist.removeAll();
    expect(mylist.items.length, 0);
  });
}
