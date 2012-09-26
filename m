From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:56 +0000 (UTC)
Subject: master - lvmetad: Make vgscan --cache an alias to pvscan --cache.
Message-ID: <20120926175556.BEE00A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7d3553906f15b9117d0152844f69de33564ab46
Commit:        e7d3553906f15b9117d0152844f69de33564ab46
Parent:        2d7a8b453196893186ae3eb61dc31c1df8b1cf6f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Sep 10 16:35:43 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

lvmetad: Make vgscan --cache an alias to pvscan --cache.

---
 tools/vgscan.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/tools/vgscan.c b/tools/vgscan.c
index 8deafb6..99124ef 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -15,8 +15,6 @@
 
 #include "tools.h"
 
-static int _lvmetad;
-
 static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
 			 void *handle __attribute__((unused)))
@@ -27,12 +25,6 @@ static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 
 	check_current_backup(vg);
 
-	/* keep lvmetad up to date, restore the "active" state temporarily */
-	lvmetad_set_active(_lvmetad);
-	if (!lvmetad_vg_update(vg))
-		stack;
-	lvmetad_set_active(0);
-
 	return ECMD_PROCESSED;
 }
 
@@ -54,10 +46,11 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 		cmd->filter->wipe(cmd->filter);
 	lvmcache_destroy(cmd, 1);
 
-	_lvmetad = lvmetad_active();
 	if (arg_count(cmd, cache_ARG)) {
-		if (_lvmetad)
-			lvmetad_set_active(0); /* do not rely on lvmetad info */
+		if (lvmetad_active()) {
+			if (!lvmetad_pvscan_all_devs(cmd, NULL))
+				return ECMD_FAILED;
+		}
 		else {
 			log_error("Cannot proceed since lvmetad is not active.");
 			unlock_vg(cmd, VG_GLOBAL);
@@ -76,7 +69,6 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 			maxret = ret;
 	}
 
-	lvmetad_set_active(_lvmetad); /* restore */
 	unlock_vg(cmd, VG_GLOBAL);
 	return maxret;
 }


