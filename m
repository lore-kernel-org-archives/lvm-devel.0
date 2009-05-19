From: Milan Broz <mbroz@redhat.com>
Date: Tue, 19 May 2009 15:47:34 +0200
Subject: [PATCH] User lock query instead of activate_lv_excl
Message-ID: <4A12B876.3090802@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

User lock query instead of activate_lv_excl

 - switch lvremove to not force activate volume when removing
 - ditto for force resync

 - fix some wrong return codes in lvchange_resync()

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c |   29 +++++++----------------------
 tools/lvchange.c        |   18 +++++++++---------
 2 files changed, 16 insertions(+), 31 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 761cd9e..9a8045a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2036,28 +2036,13 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return 0;
 		}
 
-		/*
-		 * Check for confirmation prompts in the following cases:
-		 * 1) Clustered VG, and some remote nodes have the LV active
-		 * 2) Non-clustered VG, but LV active locally
-		 */
-		if (vg_is_clustered(vg) && !activate_lv_excl(cmd, lv) &&
-		    (force == PROMPT)) {
-			if (yes_no_prompt("Logical volume \"%s\" is active on other "
-					  "cluster nodes.  Really remove? [y/n]: ",
-					  lv->name) == 'n') {
-				log_print("Logical volume \"%s\" not removed",
-					  lv->name);
-				return 0;
-			}
-		} else if (info.exists && (force == PROMPT)) {
-			 if (yes_no_prompt("Do you really want to remove active "
-					   "logical volume \"%s\"? [y/n]: ",
-					   lv->name) == 'n') {
-				log_print("Logical volume \"%s\" not removed",
-					  lv->name);
-				return 0;
-			 }
+		if (lv_is_active(lv) && (force == PROMPT) &&
+		    yes_no_prompt("Do you really want to remove active "
+				  "%slogical volume %s? [y/n]: ",
+				  vg_is_clustered(vg) ? "clustered " : "",
+				  lv->name) == 'n') {
+			log_print("Logical volume %s not removed", lv->name);
+			return 0;
 		}
 	}
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 466fe29..4a314a3 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -201,7 +201,7 @@ static int lvchange_resync(struct cmd_context *cmd,
 		if (info.open_count) {
 			log_error("Can't resync open logical volume \"%s\"",
 				  lv->name);
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		if (info.exists) {
@@ -211,11 +211,11 @@ static int lvchange_resync(struct cmd_context *cmd,
 					  lv->name) == 'n') {
 				log_print("Logical volume \"%s\" not resynced",
 					  lv->name);
-				return ECMD_FAILED;
+				return 0;
 			}
 
 			if (sigint_caught())
-				return ECMD_FAILED;
+				return 0;
 
 			active = 1;
 		}
@@ -225,17 +225,17 @@ static int lvchange_resync(struct cmd_context *cmd,
 	monitored = dmeventd_monitor_mode();
 	init_dmeventd_monitor(0);
 
-	if (vg_is_clustered(lv->vg) && !activate_lv_excl(cmd, lv)) {
-		log_error("Can't get exclusive access to clustered volume %s",
-			  lv->name);
-		return ECMD_FAILED;
-	}
-
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate %s for resync", lv->name);
 		return 0;
 	}
 
+	if (vg_is_clustered(lv->vg) && lv_is_active(lv)) {
+		log_error("Can't get exclusive access to clustered volume %s",
+			  lv->name);
+		return 0;
+	}
+
 	init_dmeventd_monitor(monitored);
 
 	log_lv = first_seg(lv)->log_lv;



