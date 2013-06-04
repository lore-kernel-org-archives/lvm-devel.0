From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:54 +0000 (UTC)
Subject: dev-mornfall-activate - Actually pass LV metadata to activation code, when available.
Message-ID: <20130604192854.397B261470@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e190fe89fff90f260b85a4f8e8639239bd3ccd4a
Commit:        e190fe89fff90f260b85a4f8e8639239bd3ccd4a
Parent:        08b87ba1e1f7f45744f61aff1097c74d5b02be84
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Sun Mar 17 21:49:00 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jun 4 18:17:46 2013 +0200

Actually pass LV metadata to activation code, when available.

This ties the two preceding changes together, actually using the "ondisk"
version of VG metadata instead of calling into lvmcache when activating
volumes. The cache hooks are still used as a fallback, because we don't have an
uncached scanning API yet.
---
 lib/locking/file_locking.c |   10 +++++-----
 lib/locking/no_locking.c   |    6 +++---
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 1f2468d..2854015 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -295,17 +295,17 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_UNLOCK:
 			log_very_verbose("Unlocking LV %s%s%s", resource, origin_only ? " without snapshots" : "", revert ? " (reverting)" : "");
-			if (!lv_resume_if_active(cmd, resource, origin_only, 0, revert, NULL))
+			if (!lv_resume_if_active(cmd, resource, origin_only, 0, revert, lv_ondisk(lv)))
 				return 0;
 			break;
 		case LCK_NULL:
 			log_very_verbose("Locking LV %s (NL)", resource);
-			if (!lv_deactivate(cmd, resource, NULL))
+			if (!lv_deactivate(cmd, resource, lv_ondisk(lv)))
 				return 0;
 			break;
 		case LCK_READ:
 			log_very_verbose("Locking LV %s (R)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 0, NULL))
+			if (!lv_activate_with_filter(cmd, resource, 0, lv_ondisk(lv)))
 				return 0;
 			break;
 		case LCK_PREAD:
@@ -313,12 +313,12 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			break;
 		case LCK_WRITE:
 			log_very_verbose("Locking LV %s (W)%s", resource, origin_only ? " without snapshots" : "");
-			if (!lv_suspend_if_active(cmd, resource, origin_only, 0, NULL))
+			if (!lv_suspend_if_active(cmd, resource, origin_only, 0, lv_ondisk(lv)))
 				return 0;
 			break;
 		case LCK_EXCL:
 			log_very_verbose("Locking LV %s (EX)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 1, NULL))
+			if (!lv_activate_with_filter(cmd, resource, 1, lv_ondisk(lv)))
 				return 0;
 			break;
 		default:
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index 715cc10..f6f76cf 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -44,15 +44,15 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 	case LCK_LV:
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_NULL:
-			return lv_deactivate(cmd, resource, lv);
+			return lv_deactivate(cmd, resource, lv_ondisk(lv));
 		case LCK_UNLOCK:
 			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0, (flags & LCK_REVERT) ? 1 : 0, NULL);
 		case LCK_READ:
-			return lv_activate_with_filter(cmd, resource, 0, NULL);
+			return lv_activate_with_filter(cmd, resource, 0, lv_ondisk(lv));
 		case LCK_WRITE:
 			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0, 0, lv);
 		case LCK_EXCL:
-			return lv_activate_with_filter(cmd, resource, 1, NULL);
+			return lv_activate_with_filter(cmd, resource, 1, lv_ondisk(lv));
 		default:
 			break;
 		}


