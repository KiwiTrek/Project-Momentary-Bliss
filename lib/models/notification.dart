import 'package:cloud_firestore/cloud_firestore.dart';

/*
enum NotificationType {
  friendRequest = 0
  rewardRequest = 1
  info          = 2
}
*/

class MyNotification {
  String id;
  String what;
  DateTime? date;
  String from;
  String destination;
  int type;

  MyNotification.fromFirestore(this.id, Map<String, dynamic> json)
      : what = json['what'],
        date = (json['date'] as Timestamp).toDate(),
        from = json['from'],
        destination = json['destination'],
        type = json['type'];
}

Stream<List<MyNotification>> userNotificationSnapshots(String user) {
  final db = FirebaseFirestore.instance;
  final stream =
      db.collection("/Users/$user/notifications").orderBy("date").snapshots();
  return stream.map((query) {
    List<MyNotification> todos = [];
    for (final doc in query.docs) {
      todos.add(MyNotification.fromFirestore(doc.id, doc.data()));
    }
    return todos;
  });
}

void addNotification(String what, String from, String to, int type) {
  final db = FirebaseFirestore.instance;
  db.collection("/Users/$to/notifications").add({
    'what': what,
    'date': Timestamp.now(),
    'from': from,
    'destination': to,
    'type': type
  });
}

void deleteNotification(String user, String docId) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$user/notifications/$docId").delete();
}

void undeleteNotification(String user, MyNotification notification) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$user/notifications/${notification.id}").set({
    'what': notification.what,
    'date': Timestamp.fromDate(notification.date!),
    'from': notification.from,
    'destination': notification.destination,
    'type': notification.type
  });
}
