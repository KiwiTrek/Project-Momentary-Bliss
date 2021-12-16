import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String id;
  String what;
  DateTime? date;
  int value;

  Todo.fromFirestore(this.id, Map<String, dynamic> json)
      : what = json['what'],
        date = (json['date'] as Timestamp).toDate(),
        value = json['value'];
}

Stream<List<Todo>> userTodoSnapshots(String user) {
  final db = FirebaseFirestore.instance;
  final stream =
      db.collection("/Users/$user/todos").orderBy("date").snapshots();
  return stream.map((query) {
    List<Todo> todos = [];
    for (final doc in query.docs) {
      todos.add(Todo.fromFirestore(doc.id, doc.data()));
    }
    return todos;
  });
}

void addTodo(String user, String what, int value) {
  final db = FirebaseFirestore.instance;
  db
      .collection("/Users/$user/todos")
      .add({'what': what, 'date': Timestamp.now(), 'value': value});
}

void deleteTodo(String user, String docId) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$user/todos/$docId").delete();
}

void undeleteTodo(String user, Todo todo) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$user/todos/${todo.id}").set({
    'what': todo.what,
    'date': Timestamp.fromDate(todo.date!),
    'value': todo.value
  });
}
