/// API base URLs and endpoints for competitive programming platforms.
class ApiConstants {
  ApiConstants._();

  // ─── Codeforces ───
  static const String codeforcesBase = 'https://codeforces.com/api';
  static const String cfContestList = '$codeforcesBase/contest.list';
  static const String cfUserInfo = '$codeforcesBase/user.info';
  static const String cfUserRating = '$codeforcesBase/user.rating';
  static const String cfContestUrl = 'https://codeforces.com/contest';

  // ─── LeetCode ───
  static const String leetcodeGraphQL = 'https://leetcode.com/graphql/';
  static const String leetcodeContestUrl = 'https://leetcode.com/contest';

  // ─── CodeChef ───
  static const String codechefApi = 'https://codechef-api.vercel.app/handle';
  static const String codechefContests = 'https://www.codechef.com/api/list/contests/all';
  static const String codechefContestUrl = 'https://www.codechef.com';

  // ─── Refresh Intervals ───
  static const Duration contestRefreshInterval = Duration(minutes: 30);
  static const Duration profileRefreshInterval = Duration(hours: 1);

  // ─── Rate Limiting ───
  static const Duration apiRequestDelay = Duration(milliseconds: 500);
}

/// LeetCode GraphQL queries.
class LeetCodeQueries {
  LeetCodeQueries._();

  static const String userProfile = '''
    query getUserProfile(\$username: String!) {
      matchedUser(username: \$username) {
        username
        profile {
          realName
          ranking
          userAvatar
        }
        submitStatsGlobal {
          acSubmissionNum {
            difficulty
            count
          }
        }
      }
    }
  ''';

  static const String userContestInfo = '''
    query userContestRankingInfo(\$username: String!) {
      userContestRanking(username: \$username) {
        attendedContestsCount
        rating
        globalRanking
        topPercentage
      }
      userContestRankingHistory(username: \$username) {
        attended
        rating
        ranking
        contest {
          title
          startTime
        }
      }
    }
  ''';

  static const String userCalendar = '''
    query userProfileCalendar(\$username: String!, \$year: Int) {
      matchedUser(username: \$username) {
        userCalendar(year: \$year) {
          activeYears
          streak
          totalActiveDays
          submissionCalendar
        }
      }
    }
  ''';

  static const String upcomingContests = '''
    query {
      topTwoContests {
        title
        titleSlug
        startTime
        duration
        cardImg
      }
    }
  ''';
}
