From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:39 +0000 (UTC)
Subject: dev-mornfall-lvmcache - Clean-up: Replace 'lv_is_active' with more correct/specific variants
Message-ID: <20130605120339.230B16116D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06ac797f420e0af50fb23dbb85a3b5f908918e6a
Commit:        06ac797f420e0af50fb23dbb85a3b5f908918e6a
Parent:        b3b551a93ed4dc85fc92897ce356baba1ca13a11
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu May 16 10:36:56 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu May 16 10:36:56 2013 -0500

Clean-up: Replace 'lv_is_active' with more correct/specific variants

There are places where 'lv_is_active' was being used where it was
more correct to use 'lv_is_active_locally'.  For example, when checking
for the existance of a kernel instance before asking for its status.
Most of the time these would work correctly.  (RAID is only allowed on
non-clustered VGs at the moment, which means that 'lv_is_active' and
'lv_is_active_locally' would give the same result.)  However, it is
more correct to use the proper variant and it helps with future
scenarios where targets might be allowed exclusively (or clustered) in
a cluster VG.
---
 WHATS_NEW                 |    1 +
 lib/activate/activate.c   |    8 ++++----
 lib/metadata/lv.c         |   14 ++++++++++----
 lib/metadata/lv_manip.c   |    4 ++--
 lib/metadata/mirror.c     |    4 ++++
 lib/metadata/raid_manip.c |   11 ++++++-----
 tools/lvconvert.c         |    7 ++++---
 7 files changed, 31 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c00597e..2583e2d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Replace 'lv_is_active' with more correct/specific variants (e.g. *_locally).
   Refuse to init a snapshot merge in lvconvert if there's no kernel support.
   Fix exported symbols regex for non-GNU busybox sed.
   Accept --yes in all commands so test scripts can be simpler.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1174ce2..6c368b9 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -818,7 +818,7 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 	log_debug_activation("Checking raid device health for LV %s/%s",
 			     lv->vg->name, lv->name);
 
-	if (!lv_is_active(lv))
+	if (!lv_is_active_locally(lv))
 		return 0;
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
@@ -850,7 +850,7 @@ int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
 	log_debug_activation("Checking raid mismatch count for LV %s/%s",
 			     lv->vg->name, lv->name);
 
-	if (!lv_is_active(lv))
+	if (!lv_is_active_locally(lv))
 		return_0;
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
@@ -881,7 +881,7 @@ int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action)
 	log_debug_activation("Checking raid sync_action for LV %s/%s",
 			     lv->vg->name, lv->name);
 
-	if (!lv_is_active(lv))
+	if (!lv_is_active_locally(lv))
 		return_0;
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
@@ -907,7 +907,7 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 	struct dev_manager *dm;
 	struct dm_status_raid *status;
 
-	if (!lv_is_active(lv)) {
+	if (!lv_is_active_locally(lv)) {
 		log_error("Unable to send message to an inactive logical volume.");
 		return 0;
 	}
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 69b13fa..4795032 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -393,8 +393,11 @@ static int _lv_raid_image_in_sync(const struct logical_volume *lv)
 	char *raid_health;
 	struct lv_segment *raid_seg;
 
-	/* If the LV is not active, it doesn't make sense to check status */
-	if (!lv_is_active(lv))
+	/*
+	 * If the LV is not active locally,
+	 * it doesn't make sense to check status
+	 */
+	if (!lv_is_active_locally(lv))
 		return 0;  /* Assume not in-sync */
 
 	if (!(lv->status & RAID_IMAGE)) {
@@ -452,8 +455,11 @@ static int _lv_raid_healthy(const struct logical_volume *lv)
 	char *raid_health;
 	struct lv_segment *raid_seg;
 
-	/* If the LV is not active, it doesn't make sense to check status */
-	if (!lv_is_active(lv))
+	/*
+	 * If the LV is not active locally,
+	 * it doesn't make sense to check status
+	 */
+	if (!lv_is_active_locally(lv))
 		return 1;  /* assume healthy */
 
 	if (!lv_is_raid_type(lv)) {
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ae86472..fadef6b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2906,8 +2906,8 @@ int lv_extend(struct logical_volume *lv,
 		    (lv->status & LV_NOTSYNCED)) {
 			percent_t sync_percent = PERCENT_INVALID;
 
-			if (!lv_is_active(lv)) {
-				log_error("%s/%s is not active."
+			if (!lv_is_active_locally(lv)) {
+				log_error("%s/%s is not active locally."
 					  "  Unable to get sync percent.",
 					  lv->vg->name, lv->name);
 				/* FIXME Support --force */
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index b93d73c..f23bee3 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1714,6 +1714,10 @@ int remove_mirror_log(struct cmd_context *cmd,
 			log_error("Unable to determine mirror sync status.");
 			return 0;
 		}
+	} else if (lv_is_active(lv)) {
+		log_error("Unable to determine sync status of"
+			  " remotely active mirror, %s", lv->name);
+		return 0;
 	} else if (vg_is_clustered(vg)) {
 		log_error("Unable to convert the log of an inactive "
 			  "cluster mirror, %s", lv->name);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c0d38d8..05f509a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -84,7 +84,7 @@ static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 
 	/* If top RAID was EX, use EX */
 	if (lv_is_active_exclusive_locally(top_lv)) {
-		if (!activate_lv_excl(cmd, sub_lv))
+		if (!activate_lv_excl_local(cmd, sub_lv))
 			return_0;
 	} else {
 		if (!activate_lv(cmd, sub_lv))
@@ -226,7 +226,7 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
  */
 static int _clear_lv(struct logical_volume *lv)
 {
-	int was_active = lv_is_active(lv);
+	int was_active = lv_is_active_locally(lv);
 
 	if (test_mode())
 		return 1;
@@ -1579,9 +1579,10 @@ int lv_raid_replace(struct logical_volume *lv,
 	dm_list_init(&new_meta_lvs);
 	dm_list_init(&new_data_lvs);
 
-	if (!lv_is_active(lv)) {
-		log_error("%s/%s must be active to perform this operation.",
-			  lv->vg->name, lv->name);
+	if (!lv_is_active_locally(lv)) {
+		log_error("%s/%s must be active %sto perform this operation.",
+			  lv->vg->name, lv->name,
+			  vg_is_clustered(lv->vg) ? "locally " : "");
 		return 0;
 	}
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 17e39ae..718f49c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1681,9 +1681,10 @@ static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp
 		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
 
 	if (arg_count(cmd, repair_ARG)) {
-		if (!lv_is_active(lv)) {
-			log_error("%s/%s must be active to perform"
-				  "this operation.", lv->vg->name, lv->name);
+		if (!lv_is_active_locally(lv)) {
+			log_error("%s/%s must be active %sto perform"
+				  "this operation.", lv->vg->name, lv->name,
+				  vg_is_clustered(lv->vg) ? "locally " : "");
 			return 0;
 		}
 


