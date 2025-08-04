/// 用户信息模型
class UserInfo {
  final int uid;
  final String email;
  final String name;
  final int avatarUpdatedAt;
  final String? birthday;
  final String createBy;
  final int gender;
  final bool isAdmin;
  final bool isBot;
  final String language;
  final bool msgSmtpNotifyEnable;

  UserInfo({
    required this.uid,
    required this.email,
    required this.name,
    required this.avatarUpdatedAt,
    this.birthday,
    required this.createBy,
    required this.gender,
    required this.isAdmin,
    required this.isBot,
    required this.language,
    required this.msgSmtpNotifyEnable,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      uid: json['uid'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatarUpdatedAt: json['avatar_updated_at'] ?? 0,
      birthday: json['birthday'],
      createBy: json['create_by'] ?? '',
      gender: json['gender'] ?? 0,
      isAdmin: json['is_admin'] ?? false,
      isBot: json['is_bot'] ?? false,
      language: json['language'] ?? 'en-US',
      msgSmtpNotifyEnable: json['msg_smtp_notify_enable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'avatar_updated_at': avatarUpdatedAt,
      'birthday': birthday,
      'create_by': createBy,
      'gender': gender,
      'is_admin': isAdmin,
      'is_bot': isBot,
      'language': language,
      'msg_smtp_notify_enable': msgSmtpNotifyEnable,
    };
  }

  UserInfo copyWith({
    int? uid,
    String? email,
    String? name,
    int? avatarUpdatedAt,
    String? birthday,
    String? createBy,
    int? gender,
    bool? isAdmin,
    bool? isBot,
    String? language,
    bool? msgSmtpNotifyEnable,
  }) {
    return UserInfo(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUpdatedAt: avatarUpdatedAt ?? this.avatarUpdatedAt,
      birthday: birthday ?? this.birthday,
      createBy: createBy ?? this.createBy,
      gender: gender ?? this.gender,
      isAdmin: isAdmin ?? this.isAdmin,
      isBot: isBot ?? this.isBot,
      language: language ?? this.language,
      msgSmtpNotifyEnable: msgSmtpNotifyEnable ?? this.msgSmtpNotifyEnable,
    );
  }
}
