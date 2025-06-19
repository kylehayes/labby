import 'package:json_annotation/json_annotation.dart';

part 'gitlab_project.g.dart';

@JsonSerializable()
class GitLabProject {
  final int id;
  final String name;
  @JsonKey(name: 'name_with_namespace')
  final String nameWithNamespace;
  @JsonKey(name: 'web_url')
  final String webUrl;
  final String? description;
  @JsonKey(name: 'default_branch')
  final String? defaultBranch;

  const GitLabProject({
    required this.id,
    required this.name,
    required this.nameWithNamespace,
    required this.webUrl,
    this.description,
    this.defaultBranch,
  });

  factory GitLabProject.fromJson(Map<String, dynamic> json) =>
      _$GitLabProjectFromJson(json);

  Map<String, dynamic> toJson() => _$GitLabProjectToJson(this);

  @override
  String toString() => nameWithNamespace;
}