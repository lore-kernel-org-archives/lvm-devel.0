From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Aug 2015 13:36:15 +0000 (UTC)
Subject: master - thin: metadata size cannot be reduced
Message-ID: <20150821133615.B528D60DC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4b9ac46d74e2783d4a27ceffc49d7f97fe4409f
Commit:        e4b9ac46d74e2783d4a27ceffc49d7f97fe4409f
Parent:        45f3e8bbef54b5541714010eb96da767e7856f62
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 21 11:05:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 21 15:35:45 2015 +0200

thin: metadata size cannot be reduced

Until we implement offline metadata manipulation,
the size of metadata LV cannot be reduced.
---
 lib/metadata/lv_manip.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c192d1b..5630234 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5105,6 +5105,11 @@ static int _lvresize_check_type(struct cmd_context *cmd, const struct logical_vo
 		}
 	}
 
+	if ((lp->resize == LV_REDUCE) && lv_is_thin_pool_metadata(lv)) {
+		log_error("Thin pool metadata volumes cannot be reduced.");
+		return 0;
+	}
+
 	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv &&
 	    (lp->resize == LV_EXTEND)) {
 		/* Validate thin target supports bigger size of thin volume then external origin */
@@ -5296,7 +5301,7 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		 */
 		inactive = 1;
 		if (!activate_lv_excl(cmd, lock_lv)) {
-			log_error("Failed to activate %s.", lock_lv->name);
+			log_error("Failed to activate %s.", display_lvname(lock_lv));
 			return 0;
 		}
 	}
@@ -5317,7 +5322,7 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		backup(vg);
 
 		if (inactive && !deactivate_lv(cmd, lock_lv)) {
-			log_error("Problem deactivating %s.", lock_lv->name);
+			log_error("Problem deactivating %s.", display_lvname(lock_lv));
 			return 0;
 		}
 	}


