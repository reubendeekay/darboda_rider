import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? phoneNumber;
  String? userId;
  final bool? isBlocked;
  final String? name;
  Timestamp? createdAt = Timestamp.now();
  final String? profilePic;
  final bool isDriver;
  final String? rideId;

  UserModel(
      {this.phoneNumber,
      this.isBlocked = false,
      this.userId,
      this.profilePic =
          'https://cdn.dribbble.com/users/230875/screenshots/12589592/media/a12435c0fd22de967b379b098f606683.jpg?compress=1&resize=400x300',
      this.name,
      this.isDriver = false,
      this.rideId = '',
      this.createdAt});

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'isBlocked': isBlocked,
      'name': name,
      'isDriver': isDriver,
      'createdAt': Timestamp.now(),
      'userId': userId,
      'profilePic': profilePic,
      'rideId': rideId,
    };
  }

  factory UserModel.fromJson(dynamic json) {
    return UserModel(
      phoneNumber: json['phoneNumber'],
      isBlocked: json['isBlocked'],
      name: json['name'],
      isDriver: json['isDriver'],
      createdAt: json['createdAt'],
      userId: json['userId'],
      profilePic: json['profilePic'],
      rideId: json['rideId'],
    );
  }
}
