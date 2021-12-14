import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:momentary_bliss/models/globals.dart';
import 'package:momentary_bliss/models/todo.dart';
import 'package:provider/provider.dart';
import 'package:momentary_bliss/models/globals.dart';

class TodoListScreen extends StatelessWidget {
  final String user;

  const TodoListScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: user,
      builder: (context, _) => StreamBuilder(
        stream: userTodoSnapshots(user),
        builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error!);
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case ConnectionState.active:
              return _Screen(snapshot.data!, user);
            case ConnectionState.none:
              return ErrorWidget("The stream was wrong (connectionState.none)");
            case ConnectionState.done:
              return ErrorWidget("The stream has ended??");
          }
        },
      ),
    );
  }
}

class _Screen extends StatefulWidget {
  final List<Todo> todos;
  final String user;
  const _Screen(this.todos, this.user);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  //The text editors
  late TextEditingController whatController;
  late TextEditingController valueController;

  @override
  void initState() {
    super.initState();
    whatController = TextEditingController();
    valueController = TextEditingController();
  }

  @override
  void dispose() {
    whatController.dispose();
    valueController.dispose();
    super.dispose();
  }

  void updateCoins(String userId, int value) {
    final db = FirebaseFirestore.instance;
    int current = 0;
    db.doc("/Users/$userId").get().then((doc) {
      Map<String, dynamic> data = doc.data()!;
      current = data['coins'];
      current += value;
      db.doc("/Users/$userId").update({'coins': current});
    });
  }

  void deleteWithUndo(BuildContext context, Todo todo) {
    deleteTodo(context.read<String>(), todo.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You deleted '${todo.what}'"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            undeleteTodo(context.read<String>(), todo);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: const [
              Text("Quests",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.purple)),
              Expanded(child: SizedBox())
            ],
          ),
        ),
        const Divider(
          height: 0,
          thickness: 2,
          color: purple,
        ),
        Expanded(
          child: ListView.separated(
            itemCount: widget.todos.length,
            itemBuilder: (context, index) {
              final todo = widget.todos[index];
              return ListTile(
                title: Text(
                  todo.what,
                ),
                trailing: SizedBox(
                  width: 105,
                  child: Row(
                    children: [
                      const Icon(
                        IcoFontIcons.coins,
                        size: 32,
                        color: orange,
                      ),
                      const SizedBox(width: 2),
                      Text("${todo.value}",
                          style: const TextStyle(fontSize: 32)),
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: purple,
                  ),
                  onPressed: () {
                    deleteTodo(context.read<String>(), todo.id);
                    updateCoins(widget.user, todo.value);
                  },
                ),
                onTap: () {
                  deleteTodo(context.read<String>(), todo.id);
                  updateCoins(widget.user, todo.value);
                },
                //Add dash for trashcan to appear
                onLongPress: () {
                  deleteWithUndo(context, todo);
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              thickness: 1,
              color: purple,
            ),
          ),
        ),

        // The "Add task part", should be on a separated screen
        Material(
          elevation: 20,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(controller: whatController),
                ),
                Expanded(
                    child: TextField(
                        controller: valueController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ])),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.purple,
                  ),
                  onPressed: () {
                    addTodo(context.read<String>(), whatController.text,
                        int.parse(valueController.text));
                    whatController.clear();
                    valueController.clear();
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
