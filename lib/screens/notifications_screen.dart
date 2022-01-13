import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:momentary_bliss/models/friend.dart';
import 'package:momentary_bliss/models/notification.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  final String userMail;

  const NotificationScreen({
    Key? key,
    required this.userMail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: userMail,
      builder: (context, _) => StreamBuilder(
        stream: userNotificationSnapshots(userMail),
        builder: (BuildContext context,
            AsyncSnapshot<List<MyNotification>> snapshot) {
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
  final List<MyNotification> notifications;
  final String userMail;
  const _Screen(this.notifications, this.userMail);

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

  void deleteWithUndo(BuildContext context, MyNotification notification) {
    deleteNotification(context.read<String>(), notification.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You deleted '${notification.what}'"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            undeleteNotification(context.read<String>(), notification);
          },
        ),
      ),
    );
  }

  selectNotification(MyNotification notification) {
    switch (notification.type) {
      case 0: //Friend
        return ListTile(
          leading: const Icon(Icons.person_add, size: 32, color: Colors.green),
          title: Text(notification.what),
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        addFriend(widget.userMail, notification.from);
                        deleteNotification(widget.userMail, notification.id);
                        addFriend(notification.from, widget.userMail);
                        addNotification(
                         "${widget.userMail} has accepted your friend request",
                         widget.userMail,
                          notification.from,
                         2);
                        //TODO: Add notification to sender?
                      });
                    },
                    icon:
                        const Icon(Icons.check, color: Colors.green, size: 32)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        deleteWithUndo(context, notification);
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.red, size: 32))
              ],
            ),
          ),
        );
      case 1: //Reward
        return ListTile(
          leading: const Icon(CommunityMaterialIcons.treasure_chest,
              size: 32, color: Colors.orange),
          title: Text(notification.what),
          trailing: SizedBox(
            width: 25,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        //Set State
                      });
                    },
                    icon:
                        const Icon(Icons.check, color: Colors.green, size: 32)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        deleteWithUndo(context, notification);
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.red, size: 32))
              ],
            ),
          ),
        );
      case 2: //Info
        return ListTile(
            leading: const Icon(Icons.notification_important,
                size: 32, color: Colors.amberAccent),
            title: Text(notification.what));
    }
  }

  @override
  Widget build(BuildContext context) {
    final systemBarHeight = MediaQuery.of(context).viewPadding.top;
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(color: Colors.yellow),
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(16, 10 + systemBarHeight, 16, 10),
            child: Row(
              children: const [
                Text("Notifications",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
        const Divider(
          height: 0,
          thickness: 2,
          color: Colors.amberAccent,
        ),
        Expanded(
          child: widget.notifications.isNotEmpty
              ? ListView.separated(
                  itemCount: widget.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = widget.notifications[index];
                    return Dismissible(
                      key: Key(notification.id),
                      onDismissed: (direction) {
                        deleteWithUndo(context, notification);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.amber),
                                borderRadius: BorderRadius.circular(8.0)),
                            child: selectNotification(notification)),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                    thickness: 1,
                    color: Colors.amberAccent,
                  ),
                )
              : const Center(
                  child: Text(
                    "You got no notification :)",
                    style: TextStyle(color: Colors.amber, fontSize: 22),
                  ),
                ),
        ),
      ],
    );
  }
}
