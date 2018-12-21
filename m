From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:50 -0500
Subject: master - lvconvert: writecache fix return code
Message-ID: <201812212046.wBLKkoeS021411@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=65cb8efd16f636a42f6ce13b29d86298f10667aa
Commit:        65cb8efd16f636a42f6ce13b29d86298f10667aa
Parent:        fb85d5d02478a34ab6648bdbdf09a931176dee71
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 20:49:36 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:42:30 2018 +0100

lvconvert: writecache fix return code

Detach function return 0 for error and 1 for success.
Add missing log errors from failing deactivation.
Add missing log error from failing synchronization.
---
 tools/lvconvert.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f6f94c0..17d7454 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5165,7 +5165,7 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 	}
 
 	if (!archive(lv->vg))
-		goto_bad;
+		return_0;
 
 	/*
 	 * Activate LV internally since the LV needs to be active to flush.
@@ -5180,17 +5180,23 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 		return 0;
 	}
 
-	sync_local_dev_names(cmd);
+	if (!sync_local_dev_names(cmd)) {
+		log_error("Failed to sync local devices before detaching LV %s.",
+			  display_lvname(lv));
+		return 0;
+	}
 
 	if (!lv_writecache_message(lv, "flush")) {
 		log_error("Failed to flush writecache for %s.", display_lvname(lv));
-		deactivate_lv(cmd, lv);
+		if (!deactivate_lv(cmd, lv))
+			log_error("Failed to deactivate %s.", display_lvname(lv));
 		return 0;
 	}
 
 	if (!_get_writecache_kernel_error(cmd, lv, &kernel_error)) {
 		log_error("Failed to get writecache error status for %s.", display_lvname(lv));
-		deactivate_lv(cmd, lv);
+		if (!deactivate_lv(cmd, lv))
+			log_error("Failed to deactivate %s.", display_lvname(lv));
 		return 0;
 	}
 
@@ -5219,10 +5225,7 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 
 	log_print_unless_silent("Logical volume %s write cache has been detached.",
 				display_lvname(lv));
-	return ECMD_PROCESSED;
-bad:
-	return ECMD_FAILED;
-
+	return 1;
 }
 
 static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecache_settings *settings,


