
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
                            child: CircularProgressIndicator(),
                          );
                        }
                        List<Friend> friends = snapshot.data!;
                        return ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 30.0,
                                backgroundImage:
                                    NetworkImage(friends[index].avatar),
                              ),
                              title: Text(friends[index].mail),
                              subtitle: Text(friends[index].uid),
                              onTap: () {
                                final db = FirebaseFirestore.instance;
                                final doc = db
                                    .collection(
                                        "/Users/${widget.userMail}/friends")
                                    .doc("/${friends[index].mail}");
                                doc.get().then((snapShot) => {
                                      if (!snapShot.exists)
                                        {
                                          if (friends[index].mail !=
                                              widget.userMail)
                                            {
                                              setState(() {
                                                addNotification(
                                                  "${widget.userMail} has sent you a friend request!",
                                                  widget.userMail,
                                                  friends[index].mail,
                                                  0,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Sent a friend request to ${friends[index].mail}!"),
                                                  ),
                                                );
                                              })
                                            }
                                          else
                                            {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "You can't add yourself as a friend! That's just sad!"),
                                                ),
                                              )
                                            }
                                        }
                                      else
                                        {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "You already addded this friend"),
                                            ),
                                          )
                                        }
                                    });
                              },
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                            thickness: 1,
                            color: green,
                          ),
                        );
                      },
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
