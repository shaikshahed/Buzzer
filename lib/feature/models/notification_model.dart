import 'dart:convert';

class NotificationResponse {
  int? multicastId;
  int? success;
  int? failure;
  int? canonicalIds;
  List<Result>? results;

  NotificationResponse({
    this.multicastId,
    this.success,
    this.failure,
    this.canonicalIds,
    this.results,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      multicastId: json['multicast_id'],
      success: json['success'],
      failure: json['failure'],
      canonicalIds: json['canonical_ids'],
      results:
          (json['results'] as List).map((i) => Result.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'multicast_id': multicastId,
      'success': success,
      'failure': failure,
      'canonical_ids': canonicalIds,
      'results': results?.map((e) => e.toJson()).toList(),
    };
  }
}

class Result {
  final String messageId;

  Result({required this.messageId});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      messageId: json['message_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
    };
  }
}

class UserData {
  String? phoneNumber;
  String? name;
  String? deviceToken;
  List<Map<String, dynamic>>? userContactList;

  UserData({
    this.phoneNumber,
    this.name,
    this.deviceToken,
    this.userContactList,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      deviceToken: json['deviceToken'],
      userContactList: (json['userContactList'] as List<dynamic>)
          .map((contact) => Map<String, dynamic>.from(contact))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'deviceToken': deviceToken,
      'userContactList': userContactList,
    };
  }
}
