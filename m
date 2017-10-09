From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 9 Oct 2017 14:48:46 -0400
Subject: master - thin: Improve overprovisioning and repair warnings.
Message-ID: <201710091848.v99ImkSc004018@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=22789563dec6d470a48e728305e6e0a92ff92a9f
Commit:        22789563dec6d470a48e728305e6e0a92ff92a9f
Parent:        3a639d81445a00974c5ccfd877a197adf5607b22
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 9 19:48:00 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 9 19:48:00 2017 +0100

thin: Improve overprovisioning and repair warnings.

---
 WHATS_NEW                 |    1 +
 lib/metadata/thin_manip.c |    9 ++++++---
 tools/lvconvert.c         |    9 +++++----
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7899365..4314c69 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Improve thin pool overprovisioning and repair warning messages.
 
 Version 2.02.175 - 6th October 2017
 ===================================
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index bd2d2c3..3dfbcc1 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -365,16 +365,19 @@ int pool_check_overprovisioning(const struct logical_volume *lv)
 
 	if (sz != UINT64_C(~0)) {
 		log_warn("WARNING: Sum of all thin volume sizes (%s) exceeds the "
-			 "size of thin pool%s%s%s (%s)!",
+			 "size of thin pool%s%s%s (%s).",
 			 display_size(cmd, thinsum),
 			 more_pools ? "" : " ",
 			 more_pools ? "s" : display_lvname(pool_lv),
 			 txt,
 			 (sz > 0) ? display_size(cmd, sz) : "no free space in volume group");
+		if (max_threshold > 99 || !min_percent)
+			log_print_unless_silent("WARNING: You have not turned on protection against thin pools running out of space.");
 		if (max_threshold > 99)
-			log_print_unless_silent("For thin pool auto extension activation/thin_pool_autoextend_threshold should be below 100.");
+			log_print_unless_silent("WARNING: Set activation/thin_pool_autoextend_threshold below 100 to trigger automatic extension of thin pools before they get full.");
 		if (!min_percent)
-			log_print_unless_silent("For thin pool auto extension activation/thin_pool_autoextend_percent should be above 0.");
+			log_print_unless_silent("WARNING: Set activation/thin_pool_autoextend_percent above 0 to specify by how much to extend thin pools reaching the threshold.");
+		/* FIXME Also warn if there isn't sufficient free space for one pool extension to occur? */
 	}
 
 	return 1;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 77d9174..28909dd 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2272,7 +2272,7 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 	argv[++args] = NULL;
 
 	if (pool_is_active(pool_lv)) {
-		log_error("Only inactive pool can be repaired.");
+		log_error("Active pools cannot be repaired.  Use lvchange -an first.");
 		return 0;
 	}
 
@@ -2377,11 +2377,12 @@ deactivate_pmslv:
 	if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
 		return_0;
 
-	log_warn("WARNING: If everything works, remove %s volume.",
+	log_warn("WARNING: LV %s holds a backup of the unrepaired metadata. Use lvremove when no longer required.",
 		 display_lvname(mlv));
 
-	log_warn("WARNING: Use pvmove command to move %s on the best fitting PV.",
-		 display_lvname(first_seg(pool_lv)->metadata_lv));
+	if (dm_list_size(&pool_lv->vg->pvs) > 1)
+		log_warn("WARNING: New metadata LV %s might use different PVs.  Move it with pvmove if required.",
+			 display_lvname(first_seg(pool_lv)->metadata_lv));
 
 	return 1;
 }


