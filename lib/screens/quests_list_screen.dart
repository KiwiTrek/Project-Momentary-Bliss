import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:momentary_bliss/models/globals.dart';
import 'package:momentary_bliss/models/quest.dart';
import 'package:momentary_bliss/models/reward.dart';
import 'package:provider/provider.dart';

class QuestListScreen extends StatefulWidget {
  final String userMail;

  const QuestListScreen({
    Key? key,
    required this.userMail,
  }) : super(key: key);

  @override
  State<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends State<QuestListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: widget.userMail,
      builder: (context, _) => StreamBuilder(
        stream: userQuestSnapshots(widget.userMail),
        builder: (BuildContext context, AsyncSnapshot<List<Quest>> snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error!);
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case ConnectionState.active:
              return _Screen(snapshot.data!, widget.userMail);
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
  final List<Quest> quests;
  final String userMail;
  const _Screen(this.quests, this.userMail);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  //The text editors
  late TextEditingController whatController;
  late TextEditingController valueController;
  bool isDaily = false;

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
      if (current >= 999999) current = 999999;
      db.doc("/Users/$userId").update({'coins': current});
    });
  }

  void deleteWithUndo(BuildContext context, Quest todo) {
    deleteQuest(context.read<String>(), todo.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You deleted '${todo.what}'"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            undeleteQuest(context.read<String>(), todo);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(color: darkPurple),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                const Text("Quests",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const Expanded(child: SizedBox()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .doc("/Users/${widget.userMail}")
                          .snapshots(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot,
                      ) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final doc = snapshot.data!;
                        final data = doc.data()!;
                        if (doc.data() != null) {
                          return Row(
                            children: [
                              const Icon(
                                IcoFontIcons.moneyBag,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 1),
                              Text(data['coins'].toString(),
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.white))
                            ],
                          );
                        } else {
                          return Row(
                            children: const [
                              Icon(IcoFontIcons.moneyBag),
                              Text("<undefined>"),
                            ],
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
        const Divider(
          height: 0,
          thickness: 2,
          color: purple,
        ),
        Expanded(
          child: ListView.separated(
            itemCount: widget.quests.length,
            itemBuilder: (context, index) {
              final quest = widget.quests[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Dismissible(
                  key: Key(quest.id),
                  onDismissed: (direction) {
                    deleteWithUndo(context, quest);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: darkPurple),
                        borderRadius: BorderRadius.circular(8.0)),
                    child: ListTile(
                      title: Text(
                        quest.what,
                      ),
                      subtitle:
                          quest.isDaily ? const Text("Daily Quest") : null,
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
                            Text("${quest.value}",
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
                          if (quest.isDaily == false) {
                            deleteQuest(context.read<String>(), quest.id);
                          }
                          updateCoins(widget.userMail, quest.value);
                        },
                      ),
                      onTap: () {
                        if (quest.isDaily == false) {
                          deleteQuest(context.read<String>(), quest.id);
                        }
                        updateCoins(widget.userMail, quest.value);
                      },
                    ),
                  ),
                ),
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
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 12.0,
                right: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: whatController,
                    cursorColor: Colors.purpleAccent,
                    decoration: const InputDecoration(hintText: "Create quest"),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    cursorColor: Colors.purpleAccent,
                    decoration: const InputDecoration(hintText: "& add value"),
                  ),
                ),
                Column(
                  children: [
                    const Text(
                      "Daily Quest",
                      style: TextStyle(color: Colors.purple),
                    ),
                    Checkbox(
                      value: isDaily,
                      onChanged: (value) {
                        setState(() {
                          isDaily = value!;
                        });
                      },
                      checkColor: Colors.purpleAccent[50],
                      activeColor: Colors.purple[200],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.purpleAccent,
                  ),
                  onPressed: () {
                    if (whatController.text.isNotEmpty &&
                        valueController.text.isNotEmpty) {
                      int value = int.parse(valueController.text);
                      if (value >= 999) value = 999;
                      addQuest(context.read<String>(), whatController.text,
                          value, isDaily);
                      whatController.clear();
                      valueController.clear();
                      setState(() {
                        isDaily = false;
                      });
                    }
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
