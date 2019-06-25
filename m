From: David Teigland <teigland@sourceware.org>
Date: Tue, 25 Jun 2019 16:47:32 -0400
Subject: master - exported vg handling
Message-ID: <201906252047.x5PKlWB8020428@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4402bd821723067c2becaf8e2a0452d4896cfd7
Commit:        b4402bd821723067c2becaf8e2a0452d4896cfd7
Parent:        d16142f90fdcf2aef42a51ecabd0c4ff11733d7c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 21 13:37:11 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 25 15:39:08 2019 -0500

exported vg handling

The exported VG checking/enforcement was scattered and
inconsistent.  This centralizes it and makes it consistent,
following the existing approach for foreign and shared
VGs/PVs, which are very similar to exported VGs/PVs.

The access policy that now applies to foreign/shared/exported
VGs/PVs, is that if a foreign/shared/exported VG/PV is named
on the command line (i.e. explicitly requested by the user),
and the command is not permitted to operate on it because it
is foreign/shared/exported, then an access error is reported
and the command exits with an error.  But, if the command is
processing all VGs/PVs, and happens to come across a
foreign/shared/exported VG/PV (that is not explicitly named on
the command line), then the command silently skips it and does
not produce an error.

A command using tags or --select handles inaccessible VGs/PVs
the same way as a command processing all VGs/PVs, and will
not report/return errors if these inaccessible VGs/PVs exist.

The new policy fixes the exit codes on a somewhat random set of
commands that previously exited with an error if they were
looking at all VGs/PVs and an exported VG existed on the system.

There should be no change to which commands are allowed/disallowed
on exported VGs/PVs.

Certain LV commands (lvs/lvdisplay/lvscan) would previously not
display LVs from an exported VG (for unknown reasons).  This has
not changed.  The lvm fullreport command would previously report
info about an exported VG but not about the LVs in it.  This
has changed to include all info from the exported VG.
---
 lib/commands/toolcontext.h       |    1 +
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/metadata.c          |   44 ++++++++++++++++++++-----------
 tools/command.c                  |    1 +
 tools/commands.h                 |   29 +++++++++++----------
 tools/lvmcmdline.c               |    2 +
 tools/pvchange.c                 |    7 +----
 tools/pvresize.c                 |    7 +----
 tools/toollib.c                  |   52 ++++++++++++++++++++++++++++++--------
 tools/tools.h                    |    2 +
 tools/vgchange.c                 |   22 +++-------------
 tools/vgck.c                     |    3 --
 tools/vgimport.c                 |    6 +---
 tools/vgimportclone.c            |    4 +-
 tools/vgreduce.c                 |    5 +--
 tools/vgremove.c                 |    3 --
 tools/vgrename.c                 |    3 +-
 tools/vgsplit.c                  |   12 +++++++-
 18 files changed, 113 insertions(+), 91 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 6e4530c..488752c 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -148,6 +148,7 @@ struct cmd_context {
 	unsigned unknown_system_id:1;
 	unsigned include_historical_lvs:1;	/* also process/report/display historical LVs */
 	unsigned record_historical_lvs:1;	/* record historical LVs */
+	unsigned include_exported_vgs:1;
 	unsigned include_foreign_vgs:1;		/* report/display cmds can reveal foreign VGs */
 	unsigned include_shared_vgs:1;		/* report/display cmds can reveal lockd VGs */
 	unsigned include_active_foreign_vgs:1;	/* cmd should process foreign VGs with active LVs */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 966c88f..f18587a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -181,7 +181,6 @@
 #define MIRROR_SKIP_INIT_SYNC	0x00000010U	/* skip initial sync */
 
 /* vg_read and vg_read_for_update flags */
-#define READ_ALLOW_EXPORTED	0x00020000U
 #define READ_OK_NOTFOUND	0x00040000U
 #define READ_WARN_INCONSISTENT	0x00080000U
 #define READ_FOR_UPDATE		0x00100000U /* command tells vg_read it plans to write the vg */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7b0d6ce..121cf4f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -593,9 +593,6 @@ int vg_remove_check(struct volume_group *vg)
 		return 0;
 	}
 
-	if (!vg_check_status(vg, EXPORTED_VG))
-		return 0;
-
 	lv_count = vg_visible_lvs(vg);
 
 	if (lv_count) {
@@ -3709,12 +3706,6 @@ uint32_t vg_bad_status_bits(const struct volume_group *vg, uint64_t status)
 		/* Return because other flags are considered undefined. */
 		return FAILED_CLUSTERED;
 
-	if ((status & EXPORTED_VG) &&
-	    vg_is_exported(vg)) {
-		log_error("Volume group %s is exported", vg->name);
-		failure |= FAILED_EXPORTED;
-	}
-
 	if ((status & LVM_WRITE) &&
 	    !(vg->status & LVM_WRITE)) {
 		log_error("Volume group %s is read-only", vg->name);
@@ -3733,7 +3724,7 @@ uint32_t vg_bad_status_bits(const struct volume_group *vg, uint64_t status)
 /**
  * vg_check_status - check volume group status flags and log error
  * @vg - volume group to check status flags
- * @status - specific status flags to check (e.g. EXPORTED_VG)
+ * @status - specific status flags to check
  */
 int vg_check_status(const struct volume_group *vg, uint64_t status)
 {
@@ -3914,6 +3905,28 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	return 0;
 }
 
+static int _access_vg_exported(struct cmd_context *cmd, struct volume_group *vg)
+{
+	if (!vg_is_exported(vg))
+		return 1;
+
+	if (cmd->include_exported_vgs)
+		return 1;
+
+	/*
+	 * Some commands want the error printed by vg_read, others by ignore_vg.
+	 * Those using ignore_vg may choose to skip the error.
+	 */
+	if (cmd->vg_read_print_access_error) {
+		log_error("Volume group %s is exported", vg->name);
+		return 0;
+	}
+
+	/* Silently ignore exported vgs. */
+
+	return 0;
+}
+
 /*
  * Test the validity of a VG handle returned by vg_read() or vg_read_for_update().
  */
@@ -4898,18 +4911,17 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		goto_bad;
 	}
 
+	if (!_access_vg_exported(cmd, vg)) {
+		failure |= FAILED_EXPORTED;
+		goto_bad;
+	}
+
 	/*
 	 * If the command intends to write or activate the VG, there are
 	 * additional restrictions.  FIXME: These restrictions should
 	 * probably be checked/applied after vg_read returns.
 	 */
 	if (writing || activating) {
-		if (!(read_flags & READ_ALLOW_EXPORTED) && vg_is_exported(vg)) {
-			log_error("Volume group %s is exported", vg->name);
-			failure |= FAILED_EXPORTED;
-			goto_bad;
-		}
-
 		if (!(vg->status & LVM_WRITE)) {
 			log_error("Volume group %s is read-only", vg->name);
 			failure |= FAILED_READ_ONLY;
diff --git a/tools/command.c b/tools/command.c
index bdd18d6..724040e 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -137,6 +137,7 @@ static inline int configtype_arg(struct cmd_context *cmd __attribute__((unused))
 #define GET_VGNAME_FROM_OPTIONS  0x00001000
 #define CAN_USE_ONE_SCAN	 0x00002000
 #define ALLOW_HINTS              0x00004000
+#define ALLOW_EXPORTED           0x00008000
 
 
 /* create foo_CMD enums for command def ID's in command-lines.in */
diff --git a/tools/commands.h b/tools/commands.h
index 4006fab..c1670ae 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -35,7 +35,7 @@ xx(help,
 
 xx(fullreport,
    "Display full report",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS | ALLOW_EXPORTED)
 
 xx(lastlog,
    "Display last command's log report",
@@ -71,7 +71,7 @@ xx(lvmconfig,
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
-   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS)
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ALLOW_EXPORTED)
 
 xx(lvmsadc,
    "Collect activity data",
@@ -115,7 +115,7 @@ xx(pvresize,
 
 xx(pvck,
    "Check metadata on physical volumes",
-   LOCKD_VG_SH)
+   LOCKD_VG_SH | ALLOW_EXPORTED)
 
 xx(pvcreate,
    "Initialize physical volume(s) for use by LVM",
@@ -127,7 +127,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED)
 
 /* ALL_VGS_IS_DEFAULT is for polldaemon to find pvmoves in-progress using process_each_vg. */
 
@@ -145,11 +145,11 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED)
 
 xx(pvscan,
    "List all physical volumes",
-   PERMITTED_READ_ONLY | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | LOCKD_VG_SH | ALLOW_EXPORTED)
 
 xx(segtypes,
    "List available segment types",
@@ -165,11 +165,11 @@ xx(tags,
 
 xx(vgcfgbackup,
    "Backup volume group configuration(s)",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_EXPORTED)
 
 xx(vgcfgrestore,
    "Restore volume group configuration",
-   0)
+   ALLOW_EXPORTED)
 
 xx(vgchange,
    "Change volume group attributes",
@@ -189,7 +189,7 @@ xx(vgcreate,
 
 xx(vgdisplay,
    "Display volume group information",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -201,10 +201,11 @@ xx(vgextend,
 
 xx(vgimport,
    "Register exported volume group with system",
-   ALL_VGS_IS_DEFAULT)
+   ALL_VGS_IS_DEFAULT | ALLOW_EXPORTED)
 
 xx(vgimportclone,
-   "Import a VG from cloned PVs", 0)
+   "Import a VG from cloned PVs",
+   ALLOW_EXPORTED)
 
 xx(vgmerge,
    "Merge volume groups",
@@ -224,15 +225,15 @@ xx(vgremove,
 
 xx(vgrename,
    "Rename a volume group",
-   ALLOW_UUID_AS_NAME)
+   ALLOW_UUID_AS_NAME | ALLOW_EXPORTED)
 
 xx(vgs,
    "Display information about volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED)
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_EXPORTED)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3fec702..30f9d81 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2315,6 +2315,8 @@ static int _get_current_settings(struct cmd_context *cmd)
 	if (cmd->cname->flags & CAN_USE_ONE_SCAN)
 		cmd->can_use_one_scan = 1;
 
+	cmd->include_exported_vgs = (cmd->cname->flags & ALLOW_EXPORTED) ? 1 : 0;
+
 	cmd->scan_lvs = find_config_tree_bool(cmd, devices_scan_lvs_CFG, NULL);
 
 	/*
diff --git a/tools/pvchange.c b/tools/pvchange.c
index f37fd91..1ece34a 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -35,11 +35,6 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 
 	params->total++;
 
-	if (vg && vg_is_exported(vg)) {
-		log_error("Volume group %s is exported", vg->name);
-		goto bad;
-	}
-
 	/*
 	 * The primary location of this check is in vg_write(), but it needs
 	 * to be copied here to prevent the pv_write() which is called before
@@ -239,7 +234,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 
 	clear_hint_file(cmd);
 
-	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, handle, _pvchange_single);
+	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE, handle, _pvchange_single);
 
 	log_print_unless_silent("%d physical volume%s changed / %d physical volume%s not changed",
 				params.done, params.done == 1 ? "" : "s",
diff --git a/tools/pvresize.c b/tools/pvresize.c
index c7e750d..2c7f543 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -36,11 +36,6 @@ static int _pvresize_single(struct cmd_context *cmd,
 	}
 	params->total++;
 
-	if (vg && vg_is_exported(vg)) {
-		log_error("Volume group %s is exported", vg->name);
-		return ECMD_FAILED;
-	}
-
 	/*
 	 * Needed to change a property on an orphan PV.
 	 * i.e. the global lock is only needed for orphans.
@@ -93,7 +88,7 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &params;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, handle, _pvresize_single);
+	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE, handle, _pvresize_single);
 
 	log_print_unless_silent("%d physical volume(s) resized or updated / %d physical volume(s) "
 				"not resized", params.done, params.total - params.done);
diff --git a/tools/toollib.c b/tools/toollib.c
index 506ad2d..b2313f8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -223,6 +223,17 @@ static int _ignore_vg(struct cmd_context *cmd,
 		}
 	}
 
+	if (read_error & FAILED_EXPORTED) {
+		if (arg_vgnames && str_list_match_item(arg_vgnames, vg_name)) {
+			log_error("Volume group %s is exported", vg_name);
+			return 1;
+		} else {
+			read_error &= ~FAILED_EXPORTED; /* Check for other errors */
+			log_verbose("Skipping exported volume group %s", vg_name);
+			*skip = 1;
+		}
+	}
+
 	/*
 	 * Commands that operate on "all vgs" shouldn't be bothered by
 	 * skipping a foreign VG, and the command shouldn't fail when
@@ -3032,11 +3043,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	dm_list_init(&final_lvs);
 	dm_list_init(&found_arg_lvnames);
 
-	if (!vg_check_status(vg, EXPORTED_VG)) {
-		ret_max = ECMD_FAILED;
-		goto_out;
-	}
-
 	if (tags_in && !dm_list_empty(tags_in))
 		tags_supplied = 1;
 
@@ -4161,6 +4167,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			      int process_all_pvs,
 			      int process_all_devices,
 			      int skip,
+			      uint32_t error_flags,
 			      struct processing_handle *handle,
 			      process_single_pv_fn_t process_single_pv)
 {
@@ -4216,21 +4223,42 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		}
 
 		process_pv = process_all_pvs;
+		dil = NULL;
 
 		/* Remove each arg_devices entry as it is processed. */
 
-		if (!process_pv && !dm_list_empty(arg_devices) &&
-		    (dil = _device_list_find_dev(arg_devices, pv->dev))) {
-			process_pv = 1;
-			_device_list_remove(arg_devices, dil->dev);
+		if (arg_devices && !dm_list_empty(arg_devices)) {
+			if ((dil = _device_list_find_dev(arg_devices, pv->dev)))
+				_device_list_remove(arg_devices, dil->dev);
 		}
 
+		if (!process_pv && dil)
+			process_pv = 1;
+
 		if (!process_pv && !dm_list_empty(arg_tags) &&
 		    str_list_match_list(arg_tags, &pv->tags, NULL))
 			process_pv = 1;
 
 		process_pv = process_pv && select_match_pv(cmd, handle, vg, pv) && _select_matches(handle);
 
+		/*
+		 * The command has asked to process a specific PV
+		 * named on the command line, but the VG containing
+		 * that PV cannot be accessed.  In this case report
+		 * and return an error.  If the inaccessible PV is
+		 * not explicitly named on the command line, it is
+		 * silently skipped.
+		 */
+		if (process_pv && skip && dil && error_flags) {
+			if (error_flags & FAILED_EXPORTED)
+				log_error("Cannot use PV %s in exported VG %s.", pv_name, vg->name);
+			if (error_flags & FAILED_SYSTEMID)
+				log_error("Cannot use PV %s in foreign VG %s.", pv_name, vg->name);
+			if (error_flags & (FAILED_LOCK_TYPE | FAILED_LOCK_MODE))
+				log_error("Cannot use PV %s in shared VG %s.", pv_name, vg->name);
+			ret_max = ECMD_FAILED;
+		}
+
 		if (process_pv) {
 			if (skip)
 				log_verbose("Skipping PV %s in VG %s.", pv_name, vg->name);
@@ -4352,6 +4380,8 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 
 		log_debug("Processing PVs in VG %s", vg_name);
 
+		error_flags = 0;
+
 		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state, &error_flags, &error_vg);
 		if (_ignore_vg(cmd, error_flags, error_vg, vg_name, NULL, read_flags, &skip, &notfound)) {
 			stack;
@@ -4359,7 +4389,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 			report_log_ret_code(ret_max);
 			if (!skip)
 				goto endvg;
-			/* Drop through to eliminate a clustered VG's PVs from the devices list */
+			/* Drop through to eliminate unmpermitted PVs from the devices list */
 		}
 		if (notfound)
 			goto endvg;
@@ -4370,7 +4400,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		 */
 		
 		ret = _process_pvs_in_vg(cmd, vg ? vg : error_vg, all_devices, arg_devices, arg_tags,
-					 process_all_pvs, process_all_devices, skip,
+					 process_all_pvs, process_all_devices, skip, error_flags,
 					 handle, process_single_pv);
 		if (ret != ECMD_PROCESSED)
 			stack;
diff --git a/tools/tools.h b/tools/tools.h
index 69132a5..b78c471 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -136,6 +136,8 @@ struct arg_value_group_list {
 #define CAN_USE_ONE_SCAN	 0x00002000
 /* Command can use hints file */
 #define ALLOW_HINTS		 0x00004000
+/* Command can access exported vg. */
+#define ALLOW_EXPORTED           0x00008000
 
 
 void usage(const char *name);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index aad6db3..479ddd6 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -630,13 +630,6 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ detachprofile_ARG, &_vgchange_profile },
 	};
 
-	if (vg_is_exported(vg)) {
-		if (cmd->command->command_enum == vgchange_monitor_CMD)
-			return ECMD_PROCESSED;
-		log_error("Volume group \"%s\" is exported", vg_name);
-		return ECMD_FAILED;
-	}
-
 	/*
 	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
 	 * If --poll is explicitly provided use it; otherwise polling
@@ -984,11 +977,6 @@ static int _vgchange_locktype_single(struct cmd_context *cmd, const char *vg_nam
 			             struct volume_group *vg,
 			             struct processing_handle *handle)
 {
-	if (vg_is_exported(vg)) {
-		log_error("Volume group \"%s\" is exported", vg_name);
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg))
 		return_ECMD_FAILED;
 
@@ -1147,11 +1135,14 @@ int vgchange_lock_start_stop_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 		/* Disable the lockd_gl in process_each_vg. */
 		cmd->lockd_gl_disable = 1;
+	} else {
+		/* If the VG was started when it was exported, allow it to be stopped. */
+		cmd->include_exported_vgs = 1;
 	}
 
 	handle->custom_handle = &vp;
 
-	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_ALLOW_EXPORTED, 0, handle, &_vgchange_lock_start_stop_single);
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, handle, &_vgchange_lock_start_stop_single);
 
 	/* Wait for lock-start ops that were initiated in vgchange_lockstart. */
 
@@ -1180,11 +1171,6 @@ static int _vgchange_systemid_single(struct cmd_context *cmd, const char *vg_nam
 			             struct volume_group *vg,
 			             struct processing_handle *handle)
 {
-	if (vg_is_exported(vg)) {
-		log_error("Volume group \"%s\" is exported", vg_name);
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg))
 		return_ECMD_FAILED;
 
diff --git a/tools/vgck.c b/tools/vgck.c
index 90fc5a3..46ad594 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -71,9 +71,6 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 		       struct volume_group *vg,
 		       struct processing_handle *handle __attribute__((unused)))
 {
-	if (!vg_check_status(vg, EXPORTED_VG))
-		return_ECMD_FAILED;
-
 	if (!vg_validate(vg))
 		return_ECMD_FAILED;
 
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 26c6363..0d8b0f2 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -87,8 +87,6 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		cmd->handles_missing_pvs = 1;
 	}
 
-	return process_each_vg(cmd, argc, argv, NULL, NULL,
-			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
-			       0, NULL,
-			       &_vgimport_single);
+	return process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
+			       0, NULL, &_vgimport_single);
 }
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index a3af841..be01861 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -235,7 +235,7 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 
 	log_debug("Finding devices to import.");
 	cmd->cname->flags |= ENABLE_DUPLICATE_DEVS;
-	process_each_pv(cmd, argc, argv, NULL, 0, READ_ALLOW_EXPORTED, handle, _vgimportclone_pv_single);
+	process_each_pv(cmd, argc, argv, NULL, 0, 0, handle, _vgimportclone_pv_single);
 
 	if (vp.found_args != argc) {
 		log_error("Failed to find all devices.");
@@ -342,7 +342,7 @@ retry_name:
 
 	clear_hint_file(cmd);
 
-	ret = process_each_vg(cmd, 0, NULL, vp.old_vgname, NULL, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, 0, handle, _vgimportclone_vg_single);
+	ret = process_each_vg(cmd, 0, NULL, vp.old_vgname, NULL, READ_FOR_UPDATE, 0, handle, _vgimportclone_vg_single);
 
 	unlock_vg(cmd, NULL, vp.new_vgname);
 out:
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index bc1f5b6..b001ccb 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -135,7 +135,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 {
 	int r;
 
-	if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG))
+	if (!vg_check_status(vg, LVM_WRITE | RESIZEABLE_VG))
 		return ECMD_FAILED;
 
 	r = vgreduce_single(cmd, vg, pv, 1);
@@ -250,8 +250,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 
 	init_ignore_suspended_devices(1);
 
-	process_each_vg(cmd, 0, NULL, vg_name, NULL,
-			READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
+	process_each_vg(cmd, 0, NULL, vg_name, NULL, READ_FOR_UPDATE,
 			0, handle, &_vgreduce_repair_single);
 
 	if (vp.already_consistent) {
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 23640f6..8f73297 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -42,9 +42,6 @@ static int _vgremove_single(struct cmd_context *cmd, const char *vg_name,
 	unsigned lv_count, missing;
 	int ret;
 
-	if (!vg_check_status(vg, EXPORTED_VG))
-		return_ECMD_FAILED;
-
 	lv_count = vg_visible_lvs(vg);
 
 	if (lv_count) {
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 4735e8b..8b76d0b 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -233,8 +233,7 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &vp;
 
-	ret = process_each_vg(cmd, 0, NULL, vg_name_old, NULL,
-			      READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
+	ret = process_each_vg(cmd, 0, NULL, vg_name_old, NULL, READ_FOR_UPDATE,
 			      0, handle, _vgrename_single);
 
 	/* Needed if process_each_vg returns error before calling _single. */
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 61cb13b..1bcc308 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -665,8 +665,16 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!test_mode()) {
 		unlock_vg(cmd, NULL, vg_name_to);
 		release_vg(vg_to);
-		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
-					   READ_ALLOW_EXPORTED, 0);
+
+		/*
+		 * This command uses the exported vg flag internally, but
+		 * exported VGs are not allowed to be split from the command
+		 * level, so ALLOW_EXPORTED is not set in commands.h.
+		 */
+		cmd->include_exported_vgs = 1;
+
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0, 0);
+
 		if (vg_read_error(vg_to)) {
 			log_error("Volume group \"%s\" became inconsistent: "
 				  "please fix manually", vg_name_to);


