import 'gitlab_pipeline.dart';
import 'gitlab_project.dart';

class StarredPipeline {
  final GitLabPipeline pipeline;
  final GitLabProject project;

  const StarredPipeline({
    required this.pipeline,
    required this.project,
  });
}