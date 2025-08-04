class ChatGroup {
  final bool addFriend;
  final int avatarUpdatedAt;
  final String? description;
  final bool dmToMember;
  final Map<String, dynamic>? extSettings;
  final int gid;
  final bool isPublic;
  final List<dynamic> members;
  final String name;
  final bool onlyOwnerCanSendMsg;
  final dynamic owner;
  final List<dynamic> pinnedMessages;
  final bool showEmail;

  ChatGroup({
    required this.addFriend,
    required this.avatarUpdatedAt,
    this.description,
    required this.dmToMember,
    this.extSettings,
    required this.gid,
    required this.isPublic,
    required this.members,
    required this.name,
    required this.onlyOwnerCanSendMsg,
    this.owner,
    required this.pinnedMessages,
    required this.showEmail,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      addFriend: json['add_friend'] ?? false,
      avatarUpdatedAt: json['avatar_updated_at'] ?? 0,
      description: json['description'],
      dmToMember: json['dm_to_member'] ?? false,
      extSettings: json['ext_settings'],
      gid: json['gid'] ?? 0,
      isPublic: json['is_public'] ?? false,
      members: json['members'] ?? [],
      name: json['name'] ?? '',
      onlyOwnerCanSendMsg: json['only_owner_can_send_msg'] ?? false,
      owner: json['owner'],
      pinnedMessages: json['pinned_messages'] ?? [],
      showEmail: json['show_email'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'add_friend': addFriend,
      'avatar_updated_at': avatarUpdatedAt,
      'description': description,
      'dm_to_member': dmToMember,
      'ext_settings': extSettings,
      'gid': gid,
      'is_public': isPublic,
      'members': members,
      'name': name,
      'only_owner_can_send_msg': onlyOwnerCanSendMsg,
      'owner': owner,
      'pinned_messages': pinnedMessages,
      'show_email': showEmail,
    };
  }
}
