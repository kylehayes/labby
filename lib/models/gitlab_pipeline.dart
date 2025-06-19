import 'package:json_annotation/json_annotation.dart';

part 'gitlab_pipeline.g.dart';

@JsonSerializable()
class GitLabPipeline {
  final int id;
  final String sha;
  final String ref;
  final String status;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'web_url')
  final String webUrl;

  const GitLabPipeline({
    required this.id,
    required this.sha,
    required this.ref,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.webUrl,
  });

  factory GitLabPipeline.fromJson(Map<String, dynamic> json) =>
      _$GitLabPipelineFromJson(json);

  Map<String, dynamic> toJson() => _$GitLabPipelineToJson(this);

  bool get isRunning => status == 'running' || status == 'pending';
}