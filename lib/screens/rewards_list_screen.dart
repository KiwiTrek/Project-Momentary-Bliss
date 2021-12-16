import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:momentary_bliss/models/globals.dart';
import 'package:momentary_bliss/models/reward.dart';
import 'package:provider/provider.dart';

class RewardListScreen extends StatelessWidget {
  final String user;

  const RewardListScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: user,
      builder: (context, _) => StreamBuilder(
        stream: userRewardSnapshots(user),
        builder: (BuildContext context, AsyncSnapshot<List<Reward>> snapshot) {
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
  final List<Reward> rewards;
  final String user;
  const _Screen(this.rewards, this.user);

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
      current -= value;
      if (current <= 0) current = 0;
      db.doc("/Users/$userId").update({'coins': current});
    });
  }

  void deleteWithUndo(BuildContext context, Reward reward) {
    deleteReward(context.read<String>(), reward.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You deleted '${reward.what}'"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            undeleteReward(context.read<String>(), reward);
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
          decoration: const BoxDecoration(color: Colors.orange),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Row(
              children: [
                const Text("Rewards",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const Expanded(child: SizedBox()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .doc("/Users/${widget.user}")
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
          color: Colors.deepOrange,
        ),
        Expanded(
          child: ListView.separated(
            itemCount: widget.rewards.length,
            itemBuilder: (context, index) {
              final reward = widget.rewards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: ListTile(
                    title: Text(
                      reward.what,
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
                          Text("-${reward.value}",
                              style: const TextStyle(fontSize: 32)),
                        ],
                        mainAxisAlignment: MainAxisAlignment.end,
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        updateCoins(widget.user, reward.value);
                      },
                    ),
                    onTap: () {
                      updateCoins(widget.user, reward.value);
                    },
                    //Add dash for trashcan to appear
                    onLongPress: () {
                      deleteWithUndo(context, reward);
                    },
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
          elevation: 20,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 12.0,
                right: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: whatController,
                    cursorColor: Colors.deepOrangeAccent,
                    decoration:
                        const InputDecoration(hintText: "Set a new reward"),
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
                    cursorColor: Colors.deepOrangeAccent,
                    decoration:
                        const InputDecoration(hintText: "& add its value"),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.deepOrangeAccent,
                  ),
                  onPressed: () {
                    if (whatController.text.isNotEmpty &&
                        valueController.text.isNotEmpty) {
                      int value = int.parse(valueController.text);
                      if (value >= 999) value = 999;
                      addReward(
                          context.read<String>(), whatController.text, value);
                      whatController.clear();
                      valueController.clear();
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