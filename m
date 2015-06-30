From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 30 Jun 2015 17:55:23 +0000 (UTC)
Subject: master - locking: Add missing error handling.
Message-ID: <20150630175523.709BF602C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c629a5257bda5a309df25809f821a8ce1dac3e4
Commit:        4c629a5257bda5a309df25809f821a8ce1dac3e4
Parent:        3489e68ef772d735aeab9f3a69da0fa1e02379c3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jun 30 18:54:38 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 30 18:54:38 2015 +0100

locking: Add missing error handling.

Add missing error logging and detection to unlock_vg and callers
of sync_local_dev_names etc.
---
 WHATS_NEW                 |    1 +
 lib/activate/activate.c   |    4 ++--
 lib/locking/locking.h     |    7 ++++---
 lib/metadata/lv_manip.c   |   13 +++++++++++--
 lib/metadata/metadata.c   |    5 ++++-
 lib/metadata/mirror.c     |   12 ++++++++++--
 lib/metadata/raid_manip.c |    7 ++++++-
 lib/misc/lvm-exec.c       |   14 ++++++++++----
 tools/lvchange.c          |    7 ++++++-
 tools/pvscan.c            |    3 ++-
 tools/toollib.c           |    5 ++++-
 tools/vgchange.c          |   11 ++++++++---
 12 files changed, 68 insertions(+), 21 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0908686..6c539e6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.124 -
 =================================
+  Add missing error logging to unlock_vg and sync_local_dev_names callers.
 
 Version 2.02.123 - 30th June 2015
 =================================
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8c89f98..5905b7b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -648,8 +648,8 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 	 * in progress - as only those could lead to opened files
 	 */
 	if (with_open_count) {
-		if (locking_is_clustered())
-			sync_local_dev_names(cmd); /* Wait to have udev in sync */
+		if (locking_is_clustered() && !sync_local_dev_names(cmd)) /* Wait to have udev in sync */
+			return_0;
 		else if (fs_has_non_delete_ops())
 			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
 	}
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 644e07c..706b59e 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -195,9 +195,10 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 
 #define unlock_vg(cmd, vol)	\
 	do { \
-		if (is_real_vg(vol)) \
-			sync_dev_names(cmd); \
-		(void) lock_vol(cmd, vol, LCK_VG_UNLOCK, NULL);	\
+		if (is_real_vg(vol) && !sync_dev_names(cmd)) \
+			stack; \
+		if (!lock_vol(cmd, vol, LCK_VG_UNLOCK, NULL)) \
+			stack;	\
 	} while (0)
 #define unlock_and_release_vg(cmd, vg, vol) \
 	do { \
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index de96743..b539fde 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6633,7 +6633,12 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		/* nothing to do */
 		return 1;
 
-	sync_local_dev_names(lv->vg->cmd);  /* Wait until devices are available */
+	/* Wait until devices are available */
+	if (!sync_local_dev_names(lv->vg->cmd)) {
+		log_error("Failed to sync local devices before wiping LV %s.",
+			  display_lvname(lv));
+		return 0;
+	}
 
 	if (!lv_is_active_locally(lv)) {
 		log_error("Volume \"%s/%s\" is not active locally.",
@@ -7447,7 +7452,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 
 		/* Get in sync with deactivation, before reusing LV as snapshot */
-		sync_local_dev_names(lv->vg->cmd);
+		if (!sync_local_dev_names(lv->vg->cmd)) {
+			log_error("Failed to sync local devices before creating snapshot using %s.",
+				  display_lvname(lv));
+			goto revert_new_lv;
+		}
 
 		/* Create zero origin volume for spare snapshot */
 		if (lp->virtual_extents &&
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 75f3038..9b77daa 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3241,7 +3241,10 @@ static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg,
 			return_0;
 
 		/* Refresh metadata after orphan write */
-		drop_cached_metadata(vg);
+		if (!drop_cached_metadata(vg)) {
+			log_error("Unable to drop cached metadata for VG %s while wiping outdated PVs.", vg->name);
+			return 0;
+		}
 next_pv:
 		;
 	}
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 543c00e..4857ad0 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -368,7 +368,11 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	backup(log_lv->vg);
 
 	/* Wait for events following any deactivation before reactivating */
-	sync_local_dev_names(cmd);
+	if (!sync_local_dev_names(cmd)) {
+		log_error("Aborting. Failed to sync local devices before initialising mirror log %s.",
+			  display_lvname(log_lv));
+		goto revert_new_lv;
+	}
 
 	if (!activate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to activate mirror log.");
@@ -484,7 +488,11 @@ static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *l
 			return_0;
 
 		/* FIXME Is this superfluous now? */
-		sync_local_dev_names(cmd);
+		if (!sync_local_dev_names(cmd)) {
+			log_error("Failed to sync local devices when reactivating %s.",
+				  display_lvname(lv));
+			return 0;
+		}
 
 		if (!deactivate_lv(cmd, lv))
 			return_0;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 64cfb3f..8b9879c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1007,10 +1007,15 @@ static int _raid_remove_images(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (!sync_local_dev_names(lv->vg->cmd)) {
+		log_error("Failed to sync local devices after committing changes for %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	/*
 	 * Eliminate the extracted LVs
 	 */
-	sync_local_dev_names(lv->vg->cmd);
 	if (!dm_list_empty(&removal_list)) {
 		dm_list_iterate_items(lvl, &removal_list) {
 			if (!deactivate_lv(lv->vg->cmd, lvl->lv))
diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index 273e7f9..e414524 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -62,8 +62,11 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 		*rstatus = -1;
 
 	if (sync_needed)
-		if (!sync_local_dev_names(cmd)) /* Flush ops and reset dm cookie */
-			return_0;
+		/* Flush ops and reset dm cookie */
+		if (!sync_local_dev_names(cmd)) {
+			log_error("Failed to sync local device names before forking.");
+			return 0;
+		}
 
 	log_verbose("Executing:%s", _verbose_args(argv, buf, sizeof(buf)));
 
@@ -148,8 +151,11 @@ FILE *pipe_open(struct cmd_context *cmd, const char *const argv[],
 	char buf[PATH_MAX * 2];
 
 	if (sync_needed)
-		if (!sync_local_dev_names(cmd)) /* Flush ops and reset dm cookie */
-			return_0;
+		/* Flush ops and reset dm cookie */
+		if (!sync_local_dev_names(cmd)) {
+			log_error("Failed to sync local device names before forking.");
+			return 0;
+		}
 
 	if (pipe(pipefd)) {
 		log_sys_error("pipe", "");
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e790ea0..1e1c0fe 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -472,7 +472,12 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		}
 	}
 
-	sync_local_dev_names(lv->vg->cmd);  /* Wait until devices are away */
+	/* Wait until devices are away */
+	if (!sync_local_dev_names(lv->vg->cmd)) {
+		log_error("Failed to sync local devices after updating %s",
+			  display_lvname(lv));
+		return 0;
+	}
 
 	/* Put metadata sub-LVs back in place */
 	if (!attach_metadata_devices(seg, &device_list)) {
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 2c997b7..51f5d2b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -319,7 +319,8 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 out:
-	sync_local_dev_names(cmd);
+	if (!sync_local_dev_names(cmd))
+		stack;
 	unlock_vg(cmd, VG_GLOBAL);
 
 	return ret;
diff --git a/tools/toollib.c b/tools/toollib.c
index bfd3789..5032e2c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -56,7 +56,10 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 	sigaction(SIGCHLD, &act, NULL);
 
 	if (!skip_lvm)
-		sync_local_dev_names(cmd); /* Flush ops and reset dm cookie */
+		if (!sync_local_dev_names(cmd)) { /* Flush ops and reset dm cookie */
+			log_error("Failed to sync local devices before forking.");
+			return -1;
+		}
 
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 1665d3e..f689c61 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -85,7 +85,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct lv_list *lvl;
 	struct logical_volume *lv;
-	int count = 0, expected_count = 0;
+	int count = 0, expected_count = 0, r = 1;
 
 	sigint_allow();
 	dm_list_iterate_items(lvl, &vg->lvs) {
@@ -142,14 +142,19 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	sigint_restore();
-	sync_local_dev_names(vg->cmd);  /* Wait until devices are available */
+
+	/* Wait until devices are available */
+	if (!sync_local_dev_names(vg->cmd)) {
+		log_error("Failed to sync local devices for VG %s.", vg->name);
+		r = 0;
+	}
 
 	if (expected_count)
 		log_verbose("%s %d logical volumes in volume group %s",
 			    is_change_activating(activate) ?
 			    "Activated" : "Deactivated", count, vg->name);
 
-	return (expected_count != count) ? 0 : 1;
+	return (expected_count != count) ? 0 : r;
 }
 
 static int _vgchange_monitoring(struct cmd_context *cmd, struct volume_group *vg)


