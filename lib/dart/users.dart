/// Default level for a member of the platform.
const int USER_LEVEL_MEMBER = 1;

/// This level is reserved for google or apple, and makes it so the user account password cannot be changed. It will also make it so they can view some more administrative data, but in read-only mode. Such as viewing all tickets in the Feedback HUB.
const int USER_LEVEL_APP_STORE = 2;

/// Reserved for demo or test accounts which reject changing the password, email, or any other security related option. All other app features work as intended.
const int USER_LEVEL_TESTER = 4;

/// This level will not be visible in the app, because of the user's login being denied.
///
/// This will only ever be used in the most extreme of situations, where no other action can be performed, except a account level ban.
const int USER_LEVEL_BANNED = 8;

/// Moderators can moderate the Image and avatar database. In the event something violates the law, or the TOS, it will be replaced with a placeholder image that signifies the image was removed by a administrative action.
const int USER_LEVEL_MODERATOR = 16;

/// This is a special level, which may unlock cosmetic features in the future.
///
/// No application features will ever be paywalled. It just might give a fancy badge on the profile, or some unique effect, or mark Feedback HUB entries as prioritized, due to supporter status.
const int USER_LEVEL_SUPPORTER = 32;

/// Administrators have full control over the platform, and are able to assist users with account related problems.
///
/// Anything that requires direct database access must be sent to a developer.
const int USER_LEVEL_ADMIN = 64;

/// This is the flag that signifies a user is a developer.
///
/// NOTE: All privileges that come with MODERATOR, and ADMIN are given to a developer within the app.
const int USER_LEVEL_DEVELOPER = 128;

String getAccountLevel(int accountLevel) {
  String ret = "";
  int p = 0;
  int max = 512;
  List<String> levels = [];

  for (p = 1; p <= max; p = p * 2) {
    if ((accountLevel & p) == p) {
      levels.add(userLevelToString(p));
    }
  }
  ret = levels.join(" | ");

  return ret.isNotEmpty ? ret : "Unknown";
}

String userLevelToString(int level) {
  switch (level) {
    case USER_LEVEL_MEMBER:
      {
        return "Member";
      }
    case USER_LEVEL_APP_STORE:
      {
        return "App Store";
      }
    case USER_LEVEL_TESTER:
      {
        return "Tester";
      }
    case USER_LEVEL_BANNED:
      {
        return "BANNED";
      }
    case USER_LEVEL_MODERATOR:
      {
        return "Moderator";
      }
    case USER_LEVEL_ADMIN:
      {
        return "Admin";
      }
    case USER_LEVEL_DEVELOPER:
      {
        return "Developer";
      }
    case USER_LEVEL_SUPPORTER:
      {
        return "Supporter";
      }
  }

  return "";
}
