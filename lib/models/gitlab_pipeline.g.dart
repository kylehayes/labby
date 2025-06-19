// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gitlab_pipeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GitLabPipeline _$GitLabPipelineFromJson(Map<String, dynamic> json) =>
    GitLabPipeline(
      id: (json['id'] as num).toInt(),
      sha: json['sha'] as String,
      ref: json['ref'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      webUrl: json['web_url'] as String,
    );

Map<String, dynamic> _$GitLabPipelineToJson(GitLabPipeline instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sha': instance.sha,
      'ref': instance.ref,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'web_url': instance.webUrl,
    };
