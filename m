From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Feb 2018 07:57:23 -0500
Subject: master - cleanup: add missing WARNING
Message-ID: <201802151257.w1FCvNTq005043@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1195aaa66ab4a04bc2149f53bf442f141b78229
Commit:        a1195aaa66ab4a04bc2149f53bf442f141b78229
Parent:        d67f1602005b4f83e5949668a0cf4e7e5ff0c7d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 15 13:49:45 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 15 13:52:02 2018 +0100

cleanup: add missing WARNING

ATM log_warn() is supposed to be used with WARNING: prefix.
---
 WHATS_NEW             |    1 +
 lib/metadata/mirror.c |    2 +-
 tools/lvconvert.c     |    8 ++++----
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2bded4d..e2deaae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Add deprecate messages for usage of mirrors with mirrorlog.
   Separate reporting of monitoring status and error status.
   Improve validation of created strings in vgimportclone.
   Add missing initialisation of mem pool in systemd generator.
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 71d3457..4a0e99f 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1946,7 +1946,7 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (log_count > 1) {
-		log_warn("Log type \"mirrored\" is DEPRECATED and will be removed in the future. Use RAID1 LV or disk log instead.");
+		log_warn("WARNING: Log type \"mirrored\" is DEPRECATED and will be removed in the future. Use RAID1 LV or disk log instead.");
 	}
 
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 0)))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e18ec23..8006699 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -686,7 +686,7 @@ static void _remove_missing_empty_pv(struct volume_group *vg, struct dm_list *re
 			stack;
 			return;
 		}
-		log_warn("%d missing and now unallocated Physical Volumes removed from VG.", removed);
+		log_warn("WARNING: %d missing and now unallocated Physical Volumes removed from VG.", removed);
 	}
 }
 
@@ -828,7 +828,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 	uint32_t old_log_count = _get_log_count(lv);
 
 	if ((lp->mirrors == 1) && !lv_is_mirrored(lv)) {
-		log_warn("Logical volume %s is already not mirrored.",
+		log_warn("WARNING: Logical volume %s is already not mirrored.",
 			 display_lvname(lv));
 		return 1;
 	}
@@ -1100,7 +1100,7 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	log_count = replace_logs ? original_logs : (original_logs - failed_logs);
 
 	while (replace_mimages || replace_logs) {
-		log_warn("Trying to up-convert to %d images, %d logs.", lp->mirrors, log_count);
+		log_warn("WARNING: Trying to up-convert to %d images, %d logs.", lp->mirrors, log_count);
 		if (_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
 					   lp->mirrors, log_count, pvh))
 			break;
@@ -1218,7 +1218,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 
 	if ((old_log_count != new_log_count) &&
 	    (new_log_count == MIRROR_LOG_MIRRORED)) {
-		log_warn("Log type \"mirrored\" is DEPRECATED and will be removed in the future. Use RAID1 LV or disk log instead.");
+		log_warn("WARNING: Log type \"mirrored\" is DEPRECATED and will be removed in the future. Use RAID1 LV or disk log instead.");
 	}
 
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,


