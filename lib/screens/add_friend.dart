import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:momentary_bliss/models/friend.dart';
import 'package:momentary_bliss/models/globals.dart';
import 'package:momentary_bliss/models/notification.dart';

class FriendResultsScreen extends StatefulWidget {
  final String userMail;

  const FriendResultsScreen({
    Key? key,
    required this.userMail,
  }) : super(key: key);

  @override
  State<FriendResultsScreen> createState() => _FriendResultsScreenState();
}

class _FriendResultsScreenState extends State<FriendResultsScreen> {
  late TextEditingController controller;
  late Stream<List<Friend>> stream;
  bool isNotEmpty = false;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void checkFriend(Friend friend) {
    final db = FirebaseFirestore.instance;
    db.collection("/Users/${widget.userMail}/friends/").get().then((snapshot) {
      List<Friend> friends = [];
      for (final doc in snapshot.docs) {
        friends.add(Friend.fromFirestore(doc.id, doc.data()));
      }
      bool check = false;
      for (final currentFriend in friends) {
        if (friend.mail == currentFriend.mail) {
          check = true;
          break;
        }
      }
      if (!check) {
        if (friend.mail != widget.userMail) {
          addNotification("${widget.userMail} has sent you a friend request!",
              widget.userMail, friend.mail, 0, "", 0);
          SnackBar snack = SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(vertical: 55, horizontal: 12),
            content: Text("Sent a friend request to ${friend.mail}!"),
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(vertical: 55, horizontal: 12),
              content:
                  Text("You can't add yourself as a friend! That's just sad!"),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(vertical: 55, horizontal: 12),
            content: Text("You already have this user as a friend"),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a friend"),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Find your friends here!",
                    ),
                    onEditingComplete: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          stream = findFriendList(controller.text);
                          isNotEmpty = true;
                        });
                      } else {
                        setState(() {
                          isNotEmpty = false;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          stream = findFriendList(controller.text);
                          isNotEmpty = true;
                        });
                      } else {
                        setState(() {
                          isNotEmpty = false;
                        });
                      }
                    },
                    icon: const Icon(CommunityMaterialIcons.magnify))
              ],
            ),
          ),
          const Divider(),
          Padding(
              padding: const EdgeInsets.all(1.0),
              child: isNotEmpty
                  ? Expanded(
                      child: StreamBuilder(
                        stream: stream,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Friend>> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: Text(
                                "No users found.",
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 22),
                              ),
                            );
                          }
                          List<Friend> friendsFound = snapshot.data!;
                          return ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: friendsFound.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                  leading: CircleAvatar(
                                    radius: 30.0,
                                    backgroundImage: NetworkImage(
                                        friendsFound[index].avatar),
                                  ),
                                  title: Text(friendsFound[index].mail),
                                  subtitle: Text(friendsFound[index].uid),
                                  onTap: () {
                                    setState(() {
                                      checkFriend(friendsFound[index]);
                                    });
                                  });
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                              thickness: 1,
                              color: green,
                            ),
                          );
                        },
                      ),
                    )
                  : null),
        ],
      ),
    );
  }
}
