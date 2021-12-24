import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:momentary_bliss/models/friend.dart';
import 'package:momentary_bliss/models/globals.dart';

class FriendResultsScreen extends StatefulWidget {
  const FriendResultsScreen({
    Key? key,
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
                      hintText: "Type the mail here",
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          stream = findFriends(controller.text);
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
                                setState(() {
                                  // ## Send friend notification ##
                                  addFriend(
                                      FirebaseAuth.instance.currentUser!.email!,
                                      friends[index]);
                                  // ## Instead of this ^ ##
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Sent a friend request to ${friends[index].mail}!"),
                                    ),
                                  );
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
