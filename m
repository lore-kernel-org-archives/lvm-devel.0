From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:20 +0000 (UTC)
Subject: master - lvmetad: use the disabled flag in commands
Message-ID: <20160419164920.C1A506107E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04a83148cea3b3c7ec7f6ffccb4d84e2372c3f4a
Commit:        04a83148cea3b3c7ec7f6ffccb4d84e2372c3f4a
Parent:        ff867c2ef6b0717c26f2073f0b79041156a6af58
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 6 15:31:15 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 09:41:18 2016 -0500

lvmetad: use the disabled flag in commands

Commands already check if the lvmetad token is valid,
and if not, they rescan devices to repopulate lvmetad
before running.  Now, in addition to checking the
lvmetad token, they also check if the lvmetad disabled
flag is set.  If so, they do not use the lvmetad cache
and revert to disk scanning.
---
 lib/cache/lvmetad.c |    7 +++++++
 tools/lvmcmdline.c  |   13 ++++++++++++-
 tools/lvscan.c      |    9 ++++++++-
 tools/pvscan.c      |   48 +++++++++++++++++++++++++++++++++++++++++++++++-
 tools/vgimport.c    |    7 +++++++
 tools/vgscan.c      |   43 ++++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 123 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 642a407..dba7e5b 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2119,6 +2119,7 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 {
 	struct dm_list pvc_before; /* pv_cache_list */
 	struct dm_list pvc_after; /* pv_cache_list */
+	const char *reason = NULL;
 	daemon_reply reply;
 	int global_invalid;
 
@@ -2183,6 +2184,12 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 		return;
 	}
 
+	if (lvmetad_is_disabled(cmd, &reason)) {
+		log_warn("WARNING: Not using lvmetad because %s.", reason);
+		lvmetad_set_active(cmd, 0);
+		return;
+	}
+
 	/*
 	 * Clear the global_invalid flag in lvmetad.
 	 * Subsequent local commands that read global state
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 48c660b..404c835 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1475,6 +1475,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct dm_config_tree *config_string_cft;
 	struct dm_config_tree *config_profile_command_cft, *config_profile_metadata_cft;
+	const char *reason = NULL;
 	int ret = 0;
 	int locking_type;
 	int monitoring;
@@ -1625,7 +1626,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 		if (lvmetad_used()) {
 			lvmetad_set_active(cmd, 0);
-			log_verbose("Disabling use of lvmetad because read-only is set.");
+			log_verbose("Not using lvmetad because read-only is set.");
 		}
 	} else if (arg_count(cmd, nolocking_ARG))
 		locking_type = 0;
@@ -1655,6 +1656,11 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	 * - Another local command may have run with a different global filter
 	 *   which changed the content of lvmetad from what we want (recognized
 	 *   by different token values.)
+	 *
+	 * lvmetad may have been previously disabled (or disabled during the
+	 * rescan done here) because duplicate devices or lvm1 metadata were seen.
+	 * In this case, disable the *use* of lvmetad by this command, reverting to
+	 * disk scanning.
 	 */
 	if (lvmetad_used() && !(cmd->command->flags & NO_LVMETAD_AUTOSCAN)) {
 		if (cmd->include_foreign_vgs || !lvmetad_token_matches(cmd)) {
@@ -1663,6 +1669,11 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 				lvmetad_set_active(cmd, 0);
 			}
 		}
+
+		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
+			log_warn("WARNING: Not using lvmetad because %s.", reason);
+			lvmetad_set_active(cmd, 0);
+		}
 	}
 
 	/*
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 666626c..4f13587 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -91,6 +91,8 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 int lvscan(struct cmd_context *cmd, int argc, char **argv)
 {
+	const char *reason = NULL;
+
 	if (argc && !arg_count(cmd, cache_long_ARG)) {
 		log_error("No additional command line arguments allowed");
 		return EINVALID_CMD_LINE;
@@ -100,12 +102,17 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 		log_verbose("Ignoring lvscan --cache because lvmetad is not in use.");
 
 	/* Needed because this command has NO_LVMETAD_AUTOSCAN. */
-	if (lvmetad_used() && !lvmetad_token_matches(cmd)) {
+	if (lvmetad_used() && (!lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
 		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, 0)) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
 			lvmetad_set_active(cmd, 0);
 		}
 
+		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
+			log_warn("WARNING: Not using lvmetad because %s.", reason);
+			lvmetad_set_active(cmd, 0);
+		}
+
 		/*
 		 * FIXME: doing lvscan --cache after a full scan is pointless.
 		 * Should the cache case just exit here?
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 10297a3..44e7737 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -386,10 +386,51 @@ out:
 	return ret;
 }
 
+/*
+ * Three main pvscan cases related to lvmetad usage:
+ * 1. pvscan
+ * 2. pvscan --cache
+ * 3. pvscan --cache <dev>
+ *
+ * 1. The 'pvscan' command (without --cache) may or may not attempt to
+ * repopulate the lvmetad cache, and may or may not use the lvmetad
+ * cache to display PV info:
+ *
+ * i. If lvmetad is being used and is in a normal state, then 'pvscan'
+ * will simply read and display PV info from the lvmetad cache.
+ *
+ * ii. If lvmetad is not being used, 'pvscan' will read all devices to
+ * display the PV info.
+ *
+ * iii. If lvmetad is being used, but has been disabled (because of
+ * duplicate devs or lvm1 metadata), or has a non-matching token
+ * (because the device filter is different from the device filter last
+ * used to populate lvmetad), then 'pvscan' will begin by rescanning
+ * devices to repopulate lvmetad.  If lvmetad is enabled after the
+ * rescan, then 'pvscan' will simply read and display PV info from the
+ * lvmetad cache (like case i).  If lvmetad is disabled after the
+ * rescan, then 'pvscan' will read all devices to display PV info
+ * (like case ii).
+ *
+ * 2. The 'pvscan --cache' command (without named devs) will always
+ * attempt to repopulate the lvmetad cache by rescanning all devs
+ * (regardless of whether lvmetad was previously disabled or had an
+ * unmatching token.)  lvmetad may be enabled or disabled after the
+ * rescan (depending on whether duplicate devs or lvm1 metadata was
+ * found).
+ *
+ * 3. The 'pvscan --cache <dev>' command will attempt to repopulate the
+ * lvmetad cache by rescanning all devs if lvmetad has a non-matching
+ * token (e.g. because it has not yet been populated, see FIXME above).
+ * Otherwise, the command will only rescan the named <dev> and send
+ * their metadata to lvmetad.
+ */
+
 int pvscan(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvscan_params params = { 0 };
 	struct processing_handle *handle = NULL;
+	const char *reason = NULL;
 	int ret;
 
 	if (arg_count(cmd, cache_long_ARG))
@@ -421,11 +462,16 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 			  "of exported volume group(s)" : "in no volume group");
 
 	/* Needed because this command has NO_LVMETAD_AUTOSCAN. */
-	if (lvmetad_used() && !lvmetad_token_matches(cmd)) {
+	if (lvmetad_used() && (!lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
 		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, 0)) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
 			lvmetad_set_active(cmd, 0);
 		}
+
+		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
+			log_warn("WARNING: Not using lvmetad because %s.", reason);
+			lvmetad_set_active(cmd, 0);
+		}
 	}
 
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 3c08876..f5980a1 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -61,6 +61,8 @@ bad:
 
 int vgimport(struct cmd_context *cmd, int argc, char **argv)
 {
+	const char *reason = NULL;
+
 	if (!argc && !arg_count(cmd, all_ARG) && !arg_is_set(cmd, select_ARG)) {
 		log_error("Please supply volume groups or -S for selection or use -a for all.");
 		return EINVALID_CMD_LINE;
@@ -98,6 +100,11 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
 			lvmetad_set_active(cmd, 0);
 		}
+
+		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
+			log_warn("WARNING: Not using lvmetad because %s.", reason);
+			lvmetad_set_active(cmd, 0);
+		}
 	}
 
 	return process_each_vg(cmd, argc, argv, NULL,
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 9dc0000..78048c0 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -28,8 +28,44 @@ static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 	return ECMD_PROCESSED;
 }
 
+/*
+ * Two main vgscan cases related to lvmetad usage:
+ * 1. vgscan
+ * 2. vgscan --cache
+ *
+ * 1. The 'vgscan' command (without --cache) may or may not attempt to
+ * repopulate the lvmetad cache, and may or may not use the lvmetad
+ * cache to display VG info:
+ *
+ * i. If lvmetad is being used and is in a normal state, then 'vgscan'
+ * will simply read and display VG info from the lvmetad cache.
+ *
+ * ii. If lvmetad is not being used, 'vgscan' will read all devices to
+ * display the VG info.
+ *
+ * iii. If lvmetad is being used, but has been disabled (because of
+ * duplicate devs or lvm1 metadata), or has a non-matching token
+ * (because the device filter is different from the device filter last
+ * used to populate lvmetad), then 'vgscan' will begin by rescanning
+ * devices to repopulate lvmetad.  If lvmetad is enabled after the
+ * rescan, then 'vgscan' will simply read and display VG info from the
+ * lvmetad cache (like case i).  If lvmetad is disabled after the
+ * rescan, then 'vgscan' will read all devices to display VG info
+ * (like case ii).
+ *
+ * 2. The 'vgscan --cache' command will always attempt to repopulate
+ * the lvmetad cache by rescanning all devs (regardless of whether
+ * lvmetad was previously disabled or had an unmatching token.)
+ * lvmetad may be enabled or disabled after the rescan (depending
+ * on whether duplicate devs or lvm1 metadata was found).
+ * If enabled, then it will simply read and display VG info from the
+ * lvmetad cache (like case 1.i.).  If disabled, then it will
+ * read all devices to display VG info (like case 1.ii.)
+ */
+
 int vgscan(struct cmd_context *cmd, int argc, char **argv)
 {
+	const char *reason = NULL;
 	int maxret, ret;
 
 	if (argc) {
@@ -64,11 +100,16 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 	if (!lvmetad_used() && arg_is_set(cmd, cache_long_ARG))
 		log_verbose("Ignoring vgscan --cache command because lvmetad is not in use.");
 
-	if (lvmetad_used() && (arg_is_set(cmd, cache_long_ARG) || !lvmetad_token_matches(cmd))) {
+	if (lvmetad_used() && (arg_is_set(cmd, cache_long_ARG) || !lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
 		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, arg_is_set(cmd, cache_long_ARG))) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
 			lvmetad_set_active(cmd, 0);
 		}
+
+		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
+			log_warn("WARNING: Not using lvmetad because %s.", reason);
+			lvmetad_set_active(cmd, 0);
+		}
 	}
 
 	if (!lvmetad_used())


