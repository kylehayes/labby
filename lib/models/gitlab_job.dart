import 'package:json_annotation/json_annotation.dart';

part 'gitlab_job.g.dart';

@JsonSerializable()
class GitLabJob {
  final int id;
  final String name;
  final String stage;
  final String status;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'started_at')
  final String? startedAt;
  @JsonKey(name: 'finished_at')
  final String? finishedAt;
  final double? duration;
  @JsonKey(name: 'web_url')
  final String webUrl;
  final String? when;

  const GitLabJob({
    required this.id,
    required this.name,
    required this.stage,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.duration,
    required this.webUrl,
    this.when,
  });

  factory GitLabJob.fromJson(Map<String, dynamic> json) =>
      _$GitLabJobFromJson(json);

  Map<String, dynamic> toJson() => _$GitLabJobToJson(this);

  bool get isRunning => status == 'running';
  bool get isPending => status == 'pending' || status == 'created';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isCanceled => status == 'canceled';
  bool get isManual => status == 'manual';
  bool get canBeStarted => status == 'manual';
}