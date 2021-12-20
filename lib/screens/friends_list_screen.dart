import 'package:flutter/material.dart';
import 'package:momentary_bliss/models/friend.dart';
import 'package:momentary_bliss/models/globals.dart';
import 'package:provider/provider.dart';

class FriendListScreen extends StatelessWidget {
  final String userMail;

  const FriendListScreen({
    Key? key,
    required this.userMail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: userMail,
      builder: (context, _) => StreamBuilder(
        stream: userFriendSnapshots(userMail),
        builder: (BuildContext context, AsyncSnapshot<List<Friend>> snapshot) {
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
  final List<Friend> friends;
  final String userMail;
  const _Screen(this.friends, this.userMail);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(color: green),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                const Text("Friends",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const Expanded(child: SizedBox()),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 32,
                  ),
                  hoverColor: Colors.green,
                )
              ],
            ),
          ),
        ),
        const Divider(
          height: 0,
          thickness: 2,
          color: lightGreen,
        ),
        Expanded(
          child: widget.friends.isNotEmpty
              ? ListView.separated(
                  itemCount: widget.friends.length,
                  itemBuilder: (context, index) {
                    final friend = widget.friends[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30.0,
                            backgroundImage: NetworkImage(friend.avatar),
                          ),
                          title: Text(friend.uid),
                          subtitle: Text(friend.mail),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                    thickness: 1,
                    color: green,
                  ),
                )
              : const Center(
                  child: Text(
                    "You got no friends :(",
                    style: TextStyle(color: Colors.green, fontSize: 22),
                  ),
                ),
        ),
      ],
    );
  }
}
