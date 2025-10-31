class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  UserModel({required this.uid, this.displayName, this.email, this.photoUrl});

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
        uid: m['uid'] as String,
        displayName: m['displayName'] as String?,
        email: m['email'] as String?,
        photoUrl: m['photoUrl'] as String?,
      );
}
