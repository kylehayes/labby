// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gitlab_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GitLabJob _$GitLabJobFromJson(Map<String, dynamic> json) => GitLabJob(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      stage: json['stage'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      startedAt: json['started_at'] as String?,
      finishedAt: json['finished_at'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      webUrl: json['web_url'] as String,
      when: json['when'] as String?,
    );

Map<String, dynamic> _$GitLabJobToJson(GitLabJob instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stage': instance.stage,
      'status': instance.status,
      'created_at': instance.createdAt,
      'started_at': instance.startedAt,
      'finished_at': instance.finishedAt,
      'duration': instance.duration,
      'web_url': instance.webUrl,
      'when': instance.when,
    };
