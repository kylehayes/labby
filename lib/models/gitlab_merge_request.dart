import 'package:json_annotation/json_annotation.dart';

part 'gitlab_merge_request.g.dart';

@JsonSerializable()
class GitLabMergeRequest {
  final int id;
  final int iid;
  final String title;
  final String description;
  final String state;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'target_branch')
  final String targetBranch;
  @JsonKey(name: 'source_branch')
  final String sourceBranch;
  final GitLabUser author;
  final GitLabUser? assignee;
  final List<GitLabUser>? assignees;
  @JsonKey(name: 'web_url')
  final String webUrl;
  @JsonKey(name: 'merge_status')
  final String mergeStatus;
  @JsonKey(name: 'detailed_merge_status')
  final String? detailedMergeStatus;
  @JsonKey(name: 'has_conflicts')
  final bool hasConflicts;
  @JsonKey(name: 'user_notes_count')
  final int userNotesCount;
  @JsonKey(name: 'upvotes')
  final int upvotes;
  @JsonKey(name: 'downvotes')
  final int downvotes;
  @JsonKey(name: 'work_in_progress')
  final bool workInProgress;
  @JsonKey(name: 'draft')
  final bool draft;

  GitLabMergeRequest({
    required this.id,
    required this.iid,
    required this.title,
    required this.description,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    required this.targetBranch,
    required this.sourceBranch,
    required this.author,
    this.assignee,
    this.assignees,
    required this.webUrl,
    required this.mergeStatus,
    this.detailedMergeStatus,
    required this.hasConflicts,
    required this.userNotesCount,
    required this.upvotes,
    required this.downvotes,
    required this.workInProgress,
    required this.draft,
  });

  factory GitLabMergeRequest.fromJson(Map<String, dynamic> json) =>
      _$GitLabMergeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GitLabMergeRequestToJson(this);

  bool get isOpen => state == 'opened';
  bool get isClosed => state == 'closed';
  bool get isMerged => state == 'merged';
  bool get isDraft => draft || workInProgress;
  bool get canBeMerged => mergeStatus == 'can_be_merged' && !hasConflicts;
  bool get hasActivity => userNotesCount > 0 || upvotes > 0 || downvotes > 0;
}

@JsonSerializable()
class GitLabUser {
  final int id;
  final String name;
  final String username;
  final String state;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'web_url')
  final String webUrl;

  GitLabUser({
    required this.id,
    required this.name,
    required this.username,
    required this.state,
    this.avatarUrl,
    required this.webUrl,
  });

  factory GitLabUser.fromJson(Map<String, dynamic> json) =>
      _$GitLabUserFromJson(json);

  Map<String, dynamic> toJson() => _$GitLabUserToJson(this);
}
