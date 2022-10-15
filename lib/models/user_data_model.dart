class UserDataModel {
  final bool isPending;

  final String? pendingAmount;
  final DateTime? nextPaymentDate;
  final String? totalAmount;

  UserDataModel(
      {this.isPending = false,
      this.pendingAmount,
      this.nextPaymentDate,
      this.totalAmount});

  Map<String, dynamic> toJson() {
    return {
      'isPending': isPending,
      'pendingAmount': pendingAmount,
      'nextPaymentDate': nextPaymentDate,
      'totalAmount': totalAmount,
    };
  }

  factory UserDataModel.fromJson(dynamic json) {
    return UserDataModel(
      isPending: json['isPending'],
      pendingAmount: json['pendingAmount'],
      nextPaymentDate: json['nextPaymentDate'].toDate(),
      totalAmount: json['totalAmount'],
    );
  }
}
