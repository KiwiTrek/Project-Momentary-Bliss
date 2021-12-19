import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  String id;
  String what;
  int value;

  Reward.fromFirestore(this.id, Map<String, dynamic> json)
      : what = json['what'],
        value = json['value'];
}

Stream<List<Reward>> userRewardSnapshots(String user) {
  final db = FirebaseFirestore.instance;
  final stream = db.collection("/Users/$user/rewards").snapshots();
  return stream.map((query) {
    List<Reward> rewards = [];
    for (final doc in query.docs) {
      rewards.add(Reward.fromFirestore(doc.id, doc.data()));
    }
    return rewards;
  });
}

void addReward(String user, String what, int value) {
  final db = FirebaseFirestore.instance;
  db.collection("/Users/$user/rewards").add({'what': what, 'value': value});
}

void deleteReward(String user, String docId) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$user/rewards/$docId").delete();
}

void undeleteReward(String user, Reward reward) {
  final db = FirebaseFirestore.instance;
  db
      .doc("/Users/$user/rewards/${reward.id}")
      .set({'what': reward.what, 'value': reward.value});
}
