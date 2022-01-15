import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:momentary_bliss/models/friend.dart';
import 'package:momentary_bliss/models/globals.dart';
import 'package:momentary_bliss/models/notification.dart';
import 'package:momentary_bliss/models/reward.dart';
import 'package:provider/provider.dart';

class RewardListScreen extends StatelessWidget {
  final String userMail;

  const RewardListScreen({
    Key? key,
    required this.userMail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: userMail,
      builder: (context, _) => StreamBuilder(
        stream: userRewardSnapshots(userMail),
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
              return _Screen(snapshot.data!, userMail);
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
  final String userMail;
  const _Screen(this.rewards, this.userMail);

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
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(vertical: 55, horizontal: 12),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            undeleteReward(context.read<String>(), reward);
          },
        ),
      ),
    );
  }

  void checkReward(String userId, int value, String what) {
    final db = FirebaseFirestore.instance;
    db.doc("/Users/$userId").get().then((doc) {
      Map<String, dynamic> data = doc.data()!;
      if (data["coins"] >= value) {
        if (data["reward_checker"] == true) {
          db.collection("/Users/$userId/friends").get().then((snapShot) {
            String mail = "null";
            List<Friend> friends = [];
            for (final doc in snapShot.docs) {
              friends.add(Friend.fromFirestore(doc.id, doc.data()));
            }
            for (final f in friends) {
              if (f.selected) {
                mail = f.mail;
                break;
              }
            }
            if (mail != "null") {
              addNotification("$userId has requested a reward!", userId, mail,
                  1, "$what: $value coins", value);
              SnackBar snack = const SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.symmetric(vertical: 55, horizontal: 12),
                content: Text("Sent reward to your selected friend!"),
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
            } else {
              SnackBar snack = const SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.symmetric(vertical: 55, horizontal: 12),
                content: Text(
                    "Select a friend or uncheck the friend approval first."),
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
            }
          });
        } else {
          updateCoins(userId, value);
        }
      } else {
        SnackBar snack = const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(vertical: 55, horizontal: 12),
          content: Text("You don't have enough coins to get this reward"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snack);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final systemBarHeight = MediaQuery.of(context).viewPadding.top;
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(color: Colors.orange),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 10 + systemBarHeight, 16, 10),
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
          color: Colors.deepOrange,
        ),
        Expanded(
          child: ListView.separated(
            itemCount: widget.rewards.length,
            itemBuilder: (context, index) {
              final reward = widget.rewards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Dismissible(
                  key: Key(reward.id),
                  onDismissed: (direction) {
                    deleteWithUndo(context, reward);
                  },
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
                          checkReward(
                              widget.userMail, reward.value, reward.what);
                        },
                      ),
                      onTap: () {
                        checkReward(widget.userMail, reward.value, reward.what);
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
