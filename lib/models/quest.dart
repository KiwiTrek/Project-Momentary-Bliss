import 'package:cloud_firestore/cloud_firestore.dart';

class Quest {
  String id;
  String what;
  DateTime? date;
  int value;
  bool isDaily;

  Quest.fromFirestore(this.id, Map<String, dynamic> json)
      : what = json['what'],
        date = (json['date'] as Timestamp).toDate(),
        value = json['value'],
        isDaily = json['isDaily'];
}

Stream<List<Quest>> userTodoSnapshots(String user) {
  final db = FirebaseFirestore.instance;
  final stream =
      db.collection("/Users/$user/quests").orderBy("date").snapshots();
  return stream.map((query) {
    List<Quest> todos = [];
    for (final doc in query.docs) {
      todos.add(Quest.fromFirestore(doc.id, doc.data()));
    }
    return todos;
  });
}

void addQuest(String user, String what, int value, bool isDaily) {
  final db = FirebaseFirestore.instance;
  db.collection("/Users/$user/quests").add({
    'what': what,
    'date': Timestamp.now(),
    'value': value,
    'isDaily': isDaily
  });
}

void deleteQuest(String user, String docId) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$user/quests/$docId").delete();
}

void undeleteQuest(String user, Quest quest) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$user/quests/${quest.id}").set({
    'what': quest.what,
    'date': Timestamp.fromDate(quest.date!),
    'value': quest.value,
    'isDaily': quest.isDaily
  });
}
