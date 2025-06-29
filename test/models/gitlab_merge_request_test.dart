import 'package:flutter_test/flutter_test.dart';
import 'package:labby/models/gitlab_merge_request.dart';

void main() {
  group('GitLabMergeRequest', () {
    final sampleAuthor = GitLabUser(
      id: 1,
      name: 'John Doe',
      username: 'johndoe',
      state: 'active',
      avatarUrl: 'https://gitlab.com/uploads/avatar.png',
      webUrl: 'https://gitlab.com/johndoe',
    );

    final sampleAssignee = GitLabUser(
      id: 2,
      name: 'Jane Smith',
      username: 'janesmith',
      state: 'active',
      webUrl: 'https://gitlab.com/janesmith',
    );

    test('should create from JSON correctly with all fields', () {
      final json = {
        'id': 123,
        'iid': 45,
        'title': 'Test MR',
        'description': 'Test merge request description',
        'state': 'opened',
        'created_at': '2023-10-01T10:00:00Z',
        'updated_at': '2023-10-01T12:00:00Z',
        'target_branch': 'main',
        'source_branch': 'feature/test',
        'author': {
          'id': 1,
          'name': 'John Doe',
          'username': 'johndoe',
          'state': 'active',
          'avatar_url': 'https://gitlab.com/uploads/avatar.png',
          'web_url': 'https://gitlab.com/johndoe',
        },
        'assignee': {
          'id': 2,
          'name': 'Jane Smith',
          'username': 'janesmith',
          'state': 'active',
          'web_url': 'https://gitlab.com/janesmith',
        },
        'assignees': [
          {
            'id': 2,
            'name': 'Jane Smith',
            'username': 'janesmith',
            'state': 'active',
            'web_url': 'https://gitlab.com/janesmith',
          }
        ],
        'web_url': 'https://gitlab.com/group/project/-/merge_requests/45',
        'merge_status': 'can_be_merged',
        'detailed_merge_status': 'mergeable',
        'has_conflicts': false,
        'user_notes_count': 3,
        'upvotes': 2,
        'downvotes': 0,
        'work_in_progress': false,
        'draft': false,
      };

      final mr = GitLabMergeRequest.fromJson(json);

      expect(mr.id, 123);
      expect(mr.iid, 45);
      expect(mr.title, 'Test MR');
      expect(mr.description, 'Test merge request description');
      expect(mr.state, 'opened');
      expect(mr.createdAt, DateTime.parse('2023-10-01T10:00:00Z'));
      expect(mr.updatedAt, DateTime.parse('2023-10-01T12:00:00Z'));
      expect(mr.targetBranch, 'main');
      expect(mr.sourceBranch, 'feature/test');
      expect(mr.author.name, 'John Doe');
      expect(mr.assignee?.name, 'Jane Smith');
      expect(mr.assignees?.length, 1);
      expect(mr.webUrl, 'https://gitlab.com/group/project/-/merge_requests/45');
      expect(mr.mergeStatus, 'can_be_merged');
      expect(mr.detailedMergeStatus, 'mergeable');
      expect(mr.hasConflicts, false);
      expect(mr.userNotesCount, 3);
      expect(mr.upvotes, 2);
      expect(mr.downvotes, 0);
      expect(mr.workInProgress, false);
      expect(mr.draft, false);
    });

    test('should convert to JSON correctly', () {
      final mr = GitLabMergeRequest(
        id: 456,
        iid: 78,
        title: 'JSON Test MR',
        description: 'Testing JSON serialization',
        state: 'merged',
        createdAt: DateTime.parse('2023-10-02T14:00:00Z'),
        updatedAt: DateTime.parse('2023-10-02T16:00:00Z'),
        targetBranch: 'develop',
        sourceBranch: 'feature/json-test',
        author: sampleAuthor,
        assignee: sampleAssignee,
        webUrl: 'https://gitlab.com/org/repo/-/merge_requests/78',
        mergeStatus: 'merged',
        detailedMergeStatus: 'merged',
        hasConflicts: false,
        userNotesCount: 5,
        upvotes: 3,
        downvotes: 1,
        workInProgress: false,
        draft: false,
      );

      final json = mr.toJson();

      expect(json['id'], 456);
      expect(json['iid'], 78);
      expect(json['title'], 'JSON Test MR');
      expect(json['description'], 'Testing JSON serialization');
      expect(json['state'], 'merged');
      expect(json['created_at'], '2023-10-02T14:00:00.000Z');
      expect(json['updated_at'], '2023-10-02T16:00:00.000Z');
      expect(json['target_branch'], 'develop');
      expect(json['source_branch'], 'feature/json-test');
      // The generated toJson doesn't auto-serialize nested objects
      expect(json['author'], isA<GitLabUser>());
      expect(json['assignee'], isA<GitLabUser>());
      expect((json['author'] as GitLabUser).name, 'John Doe');
      expect((json['assignee'] as GitLabUser).name, 'Jane Smith');
      expect(
          json['web_url'], 'https://gitlab.com/org/repo/-/merge_requests/78');
      expect(json['merge_status'], 'merged');
      expect(json['detailed_merge_status'], 'merged');
      expect(json['has_conflicts'], false);
      expect(json['user_notes_count'], 5);
      expect(json['upvotes'], 3);
      expect(json['downvotes'], 1);
      expect(json['work_in_progress'], false);
      expect(json['draft'], false);
    });

    group('status getters', () {
      test('isOpen should return true for opened state', () {
        final mr = GitLabMergeRequest(
          id: 1,
          iid: 1,
          title: 'Test',
          description: '',
          state: 'opened',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          targetBranch: 'main',
          sourceBranch: 'feature',
          author: sampleAuthor,
          webUrl: 'https://gitlab.com/test',
          mergeStatus: 'can_be_merged',
          hasConflicts: false,
          userNotesCount: 0,
          upvotes: 0,
          downvotes: 0,
          workInProgress: false,
          draft: false,
        );

        expect(mr.isOpen, isTrue);
        expect(mr.isClosed, isFalse);
        expect(mr.isMerged, isFalse);
      });

      test('isClosed should return true for closed state', () {
        final mr = GitLabMergeRequest(
          id: 2,
          iid: 2,
          title: 'Test',
          description: '',
          state: 'closed',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          targetBranch: 'main',
          sourceBranch: 'feature',
          author: sampleAuthor,
          webUrl: 'https://gitlab.com/test',
          mergeStatus: 'cannot_be_merged',
          hasConflicts: true,
          userNotesCount: 0,
          upvotes: 0,
          downvotes: 0,
          workInProgress: false,
          draft: false,
        );

        expect(mr.isOpen, isFalse);
        expect(mr.isClosed, isTrue);
        expect(mr.isMerged, isFalse);
      });

      test('isMerged should return true for merged state', () {
        final mr = GitLabMergeRequest(
          id: 3,
          iid: 3,
          title: 'Test',
          description: '',
          state: 'merged',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          targetBranch: 'main',
          sourceBranch: 'feature',
          author: sampleAuthor,
          webUrl: 'https://gitlab.com/test',
          mergeStatus: 'merged',
          hasConflicts: false,
          userNotesCount: 0,
          upvotes: 0,
          downvotes: 0,
          workInProgress: false,
          draft: false,
        );

        expect(mr.isOpen, isFalse);
        expect(mr.isClosed, isFalse);
        expect(mr.isMerged, isTrue);
      });

      test('isDraft should return true when draft is true', () {
        final mr = GitLabMergeRequest(
          id: 4,
          iid: 4,
          title: 'Draft: Test',
          description: '',
          state: 'opened',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          targetBranch: 'main',
          sourceBranch: 'feature',
          author: sampleAuthor,
          webUrl: 'https://gitlab.com/test',
          mergeStatus: 'can_be_merged',
          hasConflicts: false,
          userNotesCount: 0,
          upvotes: 0,
          downvotes: 0,
          workInProgress: false,
          draft: true,
        );

        expect(mr.isDraft, isTrue);
      });

      test('isDraft should return true when workInProgress is true', () {
        final mr = GitLabMergeRequest(
          id: 5,
          iid: 5,
          title: 'WIP: Test',
          description: '',
          state: 'opened',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          targetBranch: 'main',
          sourceBranch: 'feature',
          author: sampleAuthor,
          webUrl: 'https://gitlab.com/test',
          mergeStatus: 'can_be_merged',
          hasConflicts: false,
          userNotesCount: 0,
          upvotes: 0,
          downvotes: 0,
          workInProgress: true,
          draft: false,
        );

        expect(mr.isDraft, isTrue);
      });

      test('canBeMerged should return true when mergeable without conflicts',
          () {
        final mr = GitLabMergeRequest(
          id: 6,
          iid: 6,
          title: 'Test',
          description: '',
          state: 'opened',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          targetBranch: 'main',
          sourceBranch: 'feature',
          author: sampleAuthor,
          webUrl: 'https://gitlab.com/test',
          mergeStatus: 'can_be_merged',
          hasConflicts: false,
          userNotesCount: 0,
          upvotes: 0,
          downvotes: 0,
          workInProgress: false,
          draft: false,
        );

        expect(mr.canBeMerged, isTrue);
      });

      test('canBeMerged should return false when has conflicts', () {
        final mr = GitLabMergeRequest(
          id: 7,
          iid: 7,
          title: 'Test',
          description: '',
          state: 'opened',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          targetBranch: 'main',
          sourceBranch: 'feature',
          author: sampleAuthor,
          webUrl: 'https://gitlab.com/test',
          mergeStatus: 'can_be_merged',
          hasConflicts: true,
          userNotesCount: 0,
          upvotes: 0,
          downvotes: 0,
          workInProgress: false,
          draft: false,
        );

        expect(mr.canBeMerged, isFalse);
      });

      test('hasActivity should return true when there are notes or votes', () {
        final mr = GitLabMergeRequest(
          id: 8,
          iid: 8,
          title: 'Test',
          description: '',
          state: 'opened',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          targetBranch: 'main',
          sourceBranch: 'feature',
          author: sampleAuthor,
          webUrl: 'https://gitlab.com/test',
          mergeStatus: 'can_be_merged',
          hasConflicts: false,
          userNotesCount: 2,
          upvotes: 1,
          downvotes: 0,
          workInProgress: false,
          draft: false,
        );

        expect(mr.hasActivity, isTrue);
      });

      test('hasActivity should return false when no activity', () {
        final mr = GitLabMergeRequest(
          id: 9,
          iid: 9,
          title: 'Test',
          description: '',
          state: 'opened',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          targetBranch: 'main',
          sourceBranch: 'feature',
          author: sampleAuthor,
          webUrl: 'https://gitlab.com/test',
          mergeStatus: 'can_be_merged',
          hasConflicts: false,
          userNotesCount: 0,
          upvotes: 0,
          downvotes: 0,
          workInProgress: false,
          draft: false,
        );

        expect(mr.hasActivity, isFalse);
      });
    });
  });

  group('GitLabUser', () {
    test('should create from JSON correctly', () {
      final json = {
        'id': 123,
        'name': 'John Doe',
        'username': 'johndoe',
        'state': 'active',
        'avatar_url': 'https://gitlab.com/uploads/avatar.png',
        'web_url': 'https://gitlab.com/johndoe',
      };

      final user = GitLabUser.fromJson(json);

      expect(user.id, 123);
      expect(user.name, 'John Doe');
      expect(user.username, 'johndoe');
      expect(user.state, 'active');
      expect(user.avatarUrl, 'https://gitlab.com/uploads/avatar.png');
      expect(user.webUrl, 'https://gitlab.com/johndoe');
    });

    test('should create from JSON with null avatar', () {
      final json = {
        'id': 456,
        'name': 'Jane Smith',
        'username': 'janesmith',
        'state': 'active',
        'web_url': 'https://gitlab.com/janesmith',
      };

      final user = GitLabUser.fromJson(json);

      expect(user.id, 456);
      expect(user.name, 'Jane Smith');
      expect(user.username, 'janesmith');
      expect(user.state, 'active');
      expect(user.avatarUrl, isNull);
      expect(user.webUrl, 'https://gitlab.com/janesmith');
    });

    test('should convert to JSON correctly', () {
      final user = GitLabUser(
        id: 789,
        name: 'Bob Wilson',
        username: 'bobwilson',
        state: 'active',
        avatarUrl: 'https://gitlab.com/uploads/bob.png',
        webUrl: 'https://gitlab.com/bobwilson',
      );

      final json = user.toJson();

      expect(json['id'], 789);
      expect(json['name'], 'Bob Wilson');
      expect(json['username'], 'bobwilson');
      expect(json['state'], 'active');
      expect(json['avatar_url'], 'https://gitlab.com/uploads/bob.png');
      expect(json['web_url'], 'https://gitlab.com/bobwilson');
    });
  });
}
