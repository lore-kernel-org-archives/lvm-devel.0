From: Milan Broz <mbroz@redhat.com>
Date: Tue, 10 Mar 2009 18:41:18 +0100
Subject: [PATCH 2/3] metadata backup: call backup() after vg_commit always
Message-ID: <49B6A63E.1030404@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move metadata backup call after vg_commit.

The backup() call store metadata from memory.

In cluster, backup() call performs remote node metadata
backup, it reads data from disk.

We want to have all metadata backup consistent,
so move all backup() calls after vg_commit.

(Moreover, some tools already do that. The reason
was probably that in old ode there were no vg_commit
but only vg_write.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c |   11 ++++-------
 lib/metadata/mirror.c   |   25 ++++++++++++++-----------
 tools/lvchange.c        |   32 ++++++++++++--------------------
 tools/lvconvert.c       |   12 ++++++------
 tools/lvcreate.c        |   10 +++++-----
 tools/lvresize.c        |    4 ++--
 tools/pvmove.c          |    4 ++--
 7 files changed, 45 insertions(+), 53 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2661e0c..9974093 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1777,8 +1777,6 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!vg_write(vg))
 		return 0;
 
-	backup(vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		stack;
 		vg_revert(vg);
@@ -1791,6 +1789,8 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	backup(vg);
+
 	resume_lv(cmd, lv);
 
 	return 1;
@@ -2055,14 +2055,11 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* store it on disks */
-	if (!vg_write(vg))
-		return 0;
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
 
 	backup(vg);
 
-	if (!vg_commit(vg))
-		return 0;
-
 	/* If no snapshots left, reload without -real. */
 	if (origin && !lv_is_origin(origin)) {
 		if (!suspend_lv(cmd, origin))
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index c7f16df..c0707b3 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -270,14 +270,11 @@ static int _init_mirror_log(struct cmd_context *cmd,
 		}
 
 	/* store mirror log on disk(s) */
-	if (!vg_write(log_lv->vg))
+	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
 		goto activate_lv;
 
 	backup(log_lv->vg);
 
-	if (!vg_commit(log_lv->vg))
-		goto activate_lv;
-
 	if (!activate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to activate mirror log.");
 		goto revert_new_lv;
@@ -334,10 +331,12 @@ revert_new_lv:
 		return 0;
 	}
 
-	if (!vg_write(log_lv->vg) ||
-	    (backup(log_lv->vg), !vg_commit(log_lv->vg)))
+	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
 		log_error("Manual intervention may be required to "
 			  "remove/restore abandoned log LV before retrying.");
+	else
+		backup(log_lv->vg);
+
 activate_lv:
 	if (was_active && !remove_on_failure && !activate_lv(cmd, log_lv))
 		return_0;
@@ -1497,11 +1496,15 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 	return 1;
 
   out_remove_log:
-	if (log_lv && (!lv_remove(log_lv) || !vg_write(log_lv->vg) ||
-		       (backup(log_lv->vg), !vg_commit(log_lv->vg))))
-		log_error("Manual intervention may be required to remove "
-			  "abandoned log LV before retrying.");
-
+	if (log_lv) {
+		if (!lv_remove(log_lv) ||
+		    !vg_write(log_lv->vg) ||
+		    !vg_commit(log_lv->vg))
+			log_error("Manual intervention may be required to remove "
+				  "abandoned log LV before retrying.");
+		else
+			backup(log_lv->vg);
+	}
   out_remove_imgs:
 	return 0;
 }
diff --git a/tools/lvchange.c b/tools/lvchange.c
index cd0ff5a..cb258ea 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -56,8 +56,6 @@ static int lvchange_permission(struct cmd_context *cmd,
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
@@ -69,6 +67,8 @@ static int lvchange_permission(struct cmd_context *cmd,
 		return 0;
 	}
 
+	backup(lv->vg);
+
 	log_very_verbose("Updating permissions for \"%s\" in kernel", lv->name);
 	if (!resume_lv(cmd, lv)) {
 		log_error("Problem reactivating %s", lv->name);
@@ -274,8 +274,6 @@ static int lvchange_resync(struct cmd_context *cmd,
 			return 0;
 		}
 
-		backup(lv->vg);
-
 		if (!vg_commit(lv->vg)) {
 			log_error("Failed to commit intermediate VG metadata.");
 			if (!attach_mirror_log(first_seg(lv), log_lv))
@@ -285,6 +283,8 @@ static int lvchange_resync(struct cmd_context *cmd,
 			return 0;
 		}
 
+		backup(lv->vg);
+
 		if (!activate_lv(cmd, log_lv)) {
 			log_error("Unable to activate %s for mirror log resync",
 				  log_lv->name);
@@ -349,15 +349,12 @@ static int lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
-	if (!vg_write(lv->vg))
+	/* No need to suspend LV for this change */
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
 	backup(lv->vg);
 
-	/* No need to suspend LV for this change */
-	if (!vg_commit(lv->vg))
-		return_0;
-
 	return 1;
 }
 
@@ -401,8 +398,6 @@ static int lvchange_readahead(struct cmd_context *cmd,
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
@@ -414,6 +409,8 @@ static int lvchange_readahead(struct cmd_context *cmd,
 		return 0;
 	}
 
+	backup(lv->vg);
+
 	log_very_verbose("Updating permissions for \"%s\" in kernel", lv->name);
 	if (!resume_lv(cmd, lv)) {
 		log_error("Problem reactivating %s", lv->name);
@@ -477,14 +474,11 @@ static int lvchange_persistent(struct cmd_context *cmd,
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg))
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
 	backup(lv->vg);
 
-	if (!vg_commit(lv->vg))
-		return_0;
-
 	if (active) {
 		log_verbose("Re-activating logical volume \"%s\"", lv->name);
 		if (!activate_lv(cmd, lv)) {
@@ -527,15 +521,13 @@ static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg))
-		return_0;
-
-	backup(lv->vg);
 
 	/* No need to suspend LV for this change */
-	if (!vg_commit(lv->vg))
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
+	backup(lv->vg);
+
 	return 1;
 }
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index cc9c5ca..9b95da4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -281,8 +281,6 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 	if (!vg_write(vg))
 		return_0;
 
-	backup(vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(vg);
@@ -294,6 +292,8 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 		return 0;
 	}
 
+	backup(vg);
+
 	log_very_verbose("Updating \"%s\" in kernel", lv->name);
 
 	if (!resume_lv(cmd, lv)) {
@@ -589,8 +589,6 @@ commit_changes:
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
@@ -602,6 +600,8 @@ commit_changes:
 		return 0;
 	}
 
+	backup(lv->vg);
+
 	log_very_verbose("Updating \"%s\" in kernel", lv->name);
 
 	if (!resume_lv(cmd, lv)) {
@@ -664,8 +664,6 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, org)) {
 		log_error("Failed to suspend origin %s", org->name);
 		vg_revert(lv->vg);
@@ -675,6 +673,8 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 	if (!vg_commit(lv->vg))
 		return_0;
 
+	backup(lv->vg);
+
 	if (!resume_lv(cmd, org)) {
 		log_error("Problem reactivating origin %s", org->name);
 		return 0;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 1f14eb1..bf68f97 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -786,14 +786,11 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	/* store vg on disk(s) */
-	if (!vg_write(vg))
+	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
 	backup(vg);
 
-	if (!vg_commit(vg))
-		return_0;
-
 	if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
@@ -878,9 +875,12 @@ deactivate_and_revert_new_lv:
 
 revert_new_lv:
 	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(lv) || !vg_write(vg) || (backup(vg), !vg_commit(vg)))
+	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
+	else
+		backup(vg);
+
 	return 0;
 }
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index b74978b..8871874 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -626,8 +626,6 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	backup(vg);
-
 	/* If snapshot, must suspend all associated devices */
 	if (lv_is_cow(lv))
 		lock_lv = origin_from_cow(lv);
@@ -646,6 +644,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
+	backup(vg);
+
 	if (!resume_lv(cmd, lock_lv)) {
 		log_error("Problem reactivating %s", lp->lv_name);
 		return ECMD_FAILED;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 6fb439d..12b4ec3 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -287,8 +287,6 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	backup(vg);
-
 	/* Suspend lvs_changed */
 	if (!suspend_lvs(cmd, lvs_changed))
 		return_0;
@@ -312,6 +310,8 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
+	backup(vg);
+
 	/* Activate the temporary mirror LV */
 	/* Only the first mirror segment gets activated as a mirror */
 	/* FIXME: Add option to use a log */



