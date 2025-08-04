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

class ChatMessage {
  final int createdAt;
  final MessageDetail detail;
  final int fromUid;
  final int mid;
  final MessageTarget target;

  ChatMessage({
    required this.createdAt,
    required this.detail,
    required this.fromUid,
    required this.mid,
    required this.target,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      createdAt: json['created_at'] ?? 0,
      detail: MessageDetail.fromJson(json['detail'] ?? {}),
      fromUid: json['from_uid'] ?? 0,
      mid: json['mid'] ?? 0,
      target: MessageTarget.fromJson(json['target'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'detail': detail.toJson(),
      'from_uid': fromUid,
      'mid': mid,
      'target': target.toJson(),
    };
  }
}

class MessageDetail {
  final String content;
  final String contentType;
  final int? expiresIn;
  final Map<String, dynamic> properties;
  final String type;

  MessageDetail({
    required this.content,
    required this.contentType,
    this.expiresIn,
    required this.properties,
    required this.type,
  });

  factory MessageDetail.fromJson(Map<String, dynamic> json) {
    return MessageDetail(
      content: json['content'] ?? '',
      contentType: json['content_type'] ?? 'text/plain',
      expiresIn: json['expires_in'],
      properties: json['properties'] ?? {},
      type: json['type'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'content_type': contentType,
      'expires_in': expiresIn,
      'properties': properties,
      'type': type,
    };
  }
}

class MessageTarget {
  final int gid;

  MessageTarget({
    required this.gid,
  });

  factory MessageTarget.fromJson(Map<String, dynamic> json) {
    return MessageTarget(
      gid: json['gid'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gid': gid,
    };
  }
}
