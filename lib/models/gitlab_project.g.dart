// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gitlab_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GitLabProject _$GitLabProjectFromJson(Map<String, dynamic> json) =>
    GitLabProject(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      nameWithNamespace: json['name_with_namespace'] as String,
      webUrl: json['web_url'] as String,
      description: json['description'] as String?,
      defaultBranch: json['default_branch'] as String?,
    );

Map<String, dynamic> _$GitLabProjectToJson(GitLabProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_with_namespace': instance.nameWithNamespace,
      'web_url': instance.webUrl,
      'description': instance.description,
      'default_branch': instance.defaultBranch,
    };
