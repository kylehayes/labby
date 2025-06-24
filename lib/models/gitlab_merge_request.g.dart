// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gitlab_merge_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GitLabMergeRequest _$GitLabMergeRequestFromJson(Map<String, dynamic> json) =>
    GitLabMergeRequest(
      id: (json['id'] as num).toInt(),
      iid: (json['iid'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      state: json['state'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      targetBranch: json['target_branch'] as String,
      sourceBranch: json['source_branch'] as String,
      author: GitLabUser.fromJson(json['author'] as Map<String, dynamic>),
      assignee: json['assignee'] == null
          ? null
          : GitLabUser.fromJson(json['assignee'] as Map<String, dynamic>),
      assignees: (json['assignees'] as List<dynamic>?)
          ?.map((e) => GitLabUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      webUrl: json['web_url'] as String,
      mergeStatus: json['merge_status'] as String,
      detailedMergeStatus: json['detailed_merge_status'] as String?,
      hasConflicts: json['has_conflicts'] as bool,
      userNotesCount: (json['user_notes_count'] as num).toInt(),
      upvotes: (json['upvotes'] as num).toInt(),
      downvotes: (json['downvotes'] as num).toInt(),
      workInProgress: json['work_in_progress'] as bool,
      draft: json['draft'] as bool,
    );

Map<String, dynamic> _$GitLabMergeRequestToJson(GitLabMergeRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'iid': instance.iid,
      'title': instance.title,
      'description': instance.description,
      'state': instance.state,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'target_branch': instance.targetBranch,
      'source_branch': instance.sourceBranch,
      'author': instance.author,
      'assignee': instance.assignee,
      'assignees': instance.assignees,
      'web_url': instance.webUrl,
      'merge_status': instance.mergeStatus,
      'detailed_merge_status': instance.detailedMergeStatus,
      'has_conflicts': instance.hasConflicts,
      'user_notes_count': instance.userNotesCount,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'work_in_progress': instance.workInProgress,
      'draft': instance.draft,
    };

GitLabUser _$GitLabUserFromJson(Map<String, dynamic> json) => GitLabUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      username: json['username'] as String,
      state: json['state'] as String,
      avatarUrl: json['avatar_url'] as String?,
      webUrl: json['web_url'] as String,
    );

Map<String, dynamic> _$GitLabUserToJson(GitLabUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'state': instance.state,
      'avatar_url': instance.avatarUrl,
      'web_url': instance.webUrl,
    };
