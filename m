From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Jun 2012 13:48:59 +0000 (UTC)
Subject: master - args: add --activate synonym for --available arg
Message-ID: <20120628134859.E55BC1687@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2729720fd329f2c33cddeeded591a06fe4b6a147
Commit:        2729720fd329f2c33cddeeded591a06fe4b6a147
Parent:        07a25c249b3ed449ca9f678c19ddb320967adaa9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 27 07:48:31 2012 -0400
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 28 09:42:44 2012 -0400

args: add --activate synonym for --available arg

We're refererring to 'activation' all over the code and we're talking
about 'LVs being activated' all the time so let's use 'activation/activate'
everywhere for clarity and consistency (still providing the old
'available' keyword as a synonym for backward compatibility with
existing environments).
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |   10 ++++----
 man/lvchange.8.in                |    4 +-
 man/lvcreate.8.in                |    4 +-
 man/vgchange.8.in                |    4 +-
 tools/args.h                     |    3 +-
 tools/commands.h                 |   40 +++++++++++++++++++-------------------
 tools/lvchange.c                 |   25 +++++++++++------------
 tools/lvcreate.c                 |    4 +-
 tools/lvmcmdline.c               |    5 ++-
 tools/toollib.c                  |    2 +-
 tools/tools.h                    |    2 +-
 tools/vgchange.c                 |   26 ++++++++++++------------
 13 files changed, 66 insertions(+), 64 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0eac530..0f90080 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add --activate synonym for --available arg and prefer --activate.
   Never issue discards when LV extents are being reconfigured, not deleted.
   Allow release_lv_segment_area to fail as functions it calls can fail.
   Open device read-only to obtain readahead value.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f42ec33..403367e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -563,11 +563,11 @@ int update_pool_lv(struct logical_volume *lv, int activate);
  * Activation options
  */
 typedef enum {
-	CHANGE_AY = 0,
-	CHANGE_AN = 1,
-	CHANGE_AE = 2,
-	CHANGE_ALY = 3,
-	CHANGE_ALN = 4
+	CHANGE_AY = 0,  /* activate */
+	CHANGE_AN = 1,  /* deactivate */
+	CHANGE_AE = 2,  /* activate exclusively */
+	CHANGE_ALY = 3, /* activate locally */
+	CHANGE_ALN = 4  /* deactivate locally */
 } activation_change_t;
 
 /* FIXME: refactor and reduce the size of this struct! */
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 927be25..9494ba7 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -7,7 +7,7 @@ lvchange \- change attributes of a logical volume
 .IR Tag ]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
-.RB [ \-a | \-\-available
+.RB [ \-a | \-\-activate
 .RI [ e | l ]{ y | n }]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
@@ -46,7 +46,7 @@ including making them known to the kernel ready for use.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
-.BR \-a ", " \-\-available " [" \fIe | \fIl ]{ \fIy | \fIn }
+.BR \-a ", " \-\-activate " [" \fIe | \fIl ]{ \fIy | \fIn }
 Controls the availability of the logical volumes for use.
 Communicates with the kernel device-mapper driver via
 libdevmapper to activate (\-ay) or deactivate (\-an) the
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 97fe624..4b393e1 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -7,7 +7,7 @@ lvcreate \- create a logical volume in an existing volume group
 .IR Tag ]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
-.RB [ \-a | \-\-available
+.RB [ \-a | \-\-activate
 .RI [ e | l ]{ y | n }]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
@@ -107,7 +107,7 @@ See
 .BR lvm (8)
 for common options.
 .TP
-.IR \fB\-a ", " \fB\-\-available " {" y | n | ey | en | ly | ln }
+.IR \fB\-a ", " \fB\-\-activate " {" y | n | ey | en | ly | ln }
 Controls the availability of the Logical Volumes for immediate use after
 the command finishes running.
 By default, new Logical Volumes are activated automatically (\fB-a\fIy\fR).
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index d43f79a..056acb4 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -9,7 +9,7 @@ vgchange \- change attributes of a volume group
 .IR AllocationPolicy ]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
-.RB [ \-a | \-\-available
+.RB [ \-a | \-\-activate
 .RI [ e | l ]
 .RI { y | n }]
 .RB [ \-\-monitor
@@ -64,7 +64,7 @@ Controls automatic backup of metadata after the change.  See
 .BR vgcfgbackup (8).
 Default is yes.
 .TP
-.BR \-a ", " \-\-available " [" \fIe | \fIl ]{ \fIy | \fIn }
+.BR \-a ", " \-\-activate " [" \fIe | \fIl ]{ \fIy | \fIn }
 Controls the availability of the logical volumes in the volume
 group for input/output.
 In other words, makes the logical volumes known/unknown to the kernel.
diff --git a/tools/args.h b/tools/args.h
index f2fa14b..2ce3c36 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -79,11 +79,12 @@ arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
 arg(allocation_ARG, '\0', "allocation", yes_no_arg, 0)
+arg(available_ARG, '\0', "available", activation_arg, 0)
 
 /*
  * ... and now the short args.
  */
-arg(available_ARG, 'a', "available", yes_no_excl_arg, 0)
+arg(activate_ARG, 'a', "activate", activation_arg, 0)
 arg(all_ARG, 'a', "all", NULL, 0)
 arg(autobackup_ARG, 'A', "autobackup", yes_no_arg, 0)
 arg(activevolumegroups_ARG, 'A', "activevolumegroups", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index a008a7b..a8c6587 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -61,7 +61,7 @@ xx(lvchange,
    CACHE_VGMETADATA | PERMITTED_READ_ONLY,
    "lvchange\n"
    "\t[-A|--autobackup y|n]\n"
-   "\t[-a|--available [e|l]y|n]\n"
+   "\t[-a|--activate [e|l]y|n]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous y|n]\n"
@@ -87,11 +87,11 @@ xx(lvchange,
    "\t[--version]" "\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
-   alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
-   ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
-   monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
-   poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG,
-   sysinit_ARG, test_ARG, yes_ARG)
+   alloc_ARG, autobackup_ARG, activate_ARG, available_ARG, contiguous_ARG,
+   force_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG,
+   minor_ARG, monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG,
+   persistent_ARG, poll_ARG, readahead_ARG, resync_ARG, refresh_ARG,
+   addtag_ARG, deltag_ARG, sysinit_ARG, test_ARG, yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -159,7 +159,7 @@ xx(lvcreate,
    0,
    "lvcreate " "\n"
    "\t[-A|--autobackup {y|n}]\n"
-   "\t[-a|--available [e|l]y|n]\n"
+   "\t[-a|--activate [e|l]y|n]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous {y|n}]\n"
@@ -214,13 +214,13 @@ xx(lvcreate,
 
    "\t[PhysicalVolumePath...]\n\n",
 
-   addtag_ARG, alloc_ARG, autobackup_ARG, available_ARG, chunksize_ARG,
-   contiguous_ARG, corelog_ARG, extents_ARG, ignoremonitoring_ARG, major_ARG,
-   minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG, name_ARG, nosync_ARG,
-   noudevsync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
-   regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, thin_ARG, thinpool_ARG, type_ARG, virtualoriginsize_ARG,
-   poolmetadatasize_ARG, virtualsize_ARG, zero_ARG)
+   addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
+   chunksize_ARG, contiguous_ARG, corelog_ARG, extents_ARG,
+   ignoremonitoring_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
+   monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG, permission_ARG,
+   persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG,
+   stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, type_ARG,
+   virtualoriginsize_ARG, poolmetadatasize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
@@ -742,7 +742,7 @@ xx(vgchange,
    "\t[-u|--uuid] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]" "\n"
-   "\t{-a|--available [e|l]{y|n}  |" "\n"
+   "\t{-a|--activate [e|l]{y|n}  |" "\n"
    "\t -c|--clustered {y|n} |" "\n"
    "\t -x|--resizeable {y|n} |" "\n"
    "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
@@ -752,11 +752,11 @@ xx(vgchange,
    "\t --deltag Tag}\n"
    "\t[VolumeGroupName...]\n",
 
-   addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
-   clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
-   logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
-   metadatacopies_ARG, vgmetadatacopies_ARG, partial_ARG,
-   physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
+   addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, activate_ARG,
+   available_ARG, clustered_ARG, deltag_ARG, ignorelockingfailure_ARG,
+   ignoremonitoring_ARG, logicalvolume_ARG, maxphysicalvolumes_ARG,
+   monitor_ARG, noudevsync_ARG, metadatacopies_ARG, vgmetadatacopies_ARG,
+   partial_ARG, physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
    resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 2ed8c16..4d040be 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -127,12 +127,11 @@ static int lvchange_background_polling(struct cmd_context *cmd,
 	return 1;
 }
 
-static int lvchange_availability(struct cmd_context *cmd,
-				 struct logical_volume *lv)
+static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	int activate;
 
-	activate = arg_uint_value(cmd, available_ARG, 0);
+	activate = arg_uint_value(cmd, activate_ARG, 0);
 
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)))
 		lv = origin_from_cow(lv);
@@ -556,7 +555,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin = origin_from_cow(lv)) &&
-	    arg_count(cmd, available_ARG)) {
+	    arg_count(cmd, activate_ARG)) {
 		if (origin->origin_count < 2)
 			snaps_msg[0] = '\0';
 		else if (dm_snprintf(snaps_msg, sizeof(snaps_msg),
@@ -577,7 +576,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (lv->status & PVMOVE) {
 		log_error("Unable to change pvmove LV %s", lv->name);
-		if (arg_count(cmd, available_ARG))
+		if (arg_count(cmd, activate_ARG))
 			log_error("Use 'pvmove --abort' to abandon a pvmove");
 		return ECMD_FAILED;
 	}
@@ -594,7 +593,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* If LV is sparse, activate origin instead */
-	if (arg_count(cmd, available_ARG) && lv_is_cow(lv) &&
+	if (arg_count(cmd, activate_ARG) && lv_is_cow(lv) &&
 	    lv_is_virtual_origin(origin = origin_from_cow(lv)))
 		lv = origin;
 
@@ -696,9 +695,9 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return ECMD_FAILED;
 		}
 
-	/* availability change */
-	if (arg_count(cmd, available_ARG)) {
-		if (!lvchange_availability(cmd, lv)) {
+	/* activation change */
+	if (arg_count(cmd, activate_ARG)) {
+		if (!_lvchange_activate(cmd, lv)) {
 			stack;
 			return ECMD_FAILED;
 		}
@@ -710,7 +709,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return ECMD_FAILED;
 		}
 
-	if (!arg_count(cmd, available_ARG) &&
+	if (!arg_count(cmd, activate_ARG) &&
 	    !arg_count(cmd, refresh_ARG) &&
 	    arg_count(cmd, monitor_ARG)) {
 		if (!lvchange_monitoring(cmd, lv)) {
@@ -719,7 +718,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (!arg_count(cmd, available_ARG) &&
+	if (!arg_count(cmd, activate_ARG) &&
 	    !arg_count(cmd, refresh_ARG) &&
 	    arg_count(cmd, poll_ARG)) {
 		if (!lvchange_background_polling(cmd, lv)) {
@@ -745,7 +744,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG);
 
 	if (!update &&
-            !arg_count(cmd, available_ARG) && !arg_count(cmd, refresh_ARG) &&
+            !arg_count(cmd, activate_ARG) && !arg_count(cmd, refresh_ARG) &&
             !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG)) {
 		log_error("Need 1 or more of -a, -C, -M, -p, -r, "
 			  "--resync, --refresh, --alloc, --addtag, --deltag, "
@@ -753,7 +752,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, available_ARG) && arg_count(cmd, refresh_ARG)) {
+	if (arg_count(cmd, activate_ARG) && arg_count(cmd, refresh_ARG)) {
 		log_error("Only one of -a and --refresh permitted.");
 		return EINVALID_CMD_LINE;
 	}
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 28d4dbf..a81e39d 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -560,11 +560,11 @@ static int _read_activation_params(struct lvcreate_params *lp, struct cmd_contex
 	unsigned pagesize;
 
 	lp->activate = (activation_change_t)
-		arg_uint_value(cmd, available_ARG, CHANGE_AY);
+		arg_uint_value(cmd, activate_ARG, CHANGE_AY);
 
 	if (lp->activate == CHANGE_AN || lp->activate == CHANGE_ALN) {
 		if (lp->zero && !seg_is_thin(lp)) {
-			log_error("--available n requires --zero n");
+			log_error("--activate n requires --zero n");
 			return 0;
 		}
 	}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 2c3bb39..37b86da 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -172,7 +172,7 @@ int yes_no_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_value
 	return 1;
 }
 
-int yes_no_excl_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
+int activation_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
 	av->sign = SIGN_NONE;
 	av->percent = PERCENT_NONE;
@@ -889,7 +889,8 @@ static int _get_settings(struct cmd_context *cmd)
 	if (!_merge_synonym(cmd, resizable_ARG, resizeable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, allocatable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, resizeable_ARG) ||
-	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG))
+	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG) ||
+	    !_merge_synonym(cmd, available_ARG, activate_ARG))
 		return EINVALID_CMD_LINE;
 
 	if ((!strncmp(cmd->command->name, "pv", 2) &&
diff --git a/tools/toollib.c b/tools/toollib.c
index 361052b..142de55 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -129,7 +129,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 
 		/* Skip availability change for non-virt snaps when processing all LVs */
 		/* FIXME: pass process_all to process_single_lv() */
-		if (process_all && arg_count(cmd, available_ARG) &&
+		if (process_all && arg_count(cmd, activate_ARG) &&
 		    lv_is_cow(lvl->lv) && !lv_is_virtual_origin(origin_from_cow(lvl->lv)))
 			continue;
 
diff --git a/tools/tools.h b/tools/tools.h
index b467e4b..8ddd351 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -138,7 +138,7 @@ void usage(const char *name);
 
 /* the argument verify/normalise functions */
 int yes_no_arg(struct cmd_context *cmd, struct arg_values *av);
-int yes_no_excl_arg(struct cmd_context *cmd, struct arg_values *av);
+int activation_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_kb_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg(struct cmd_context *cmd, struct arg_values *av);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index dc06ac9..fdad81f 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -211,10 +211,10 @@ static int _vgchange_background_polling(struct cmd_context *cmd, struct volume_g
 	return 1;
 }
 
-static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
+static int _vgchange_activate(struct cmd_context *cmd, struct volume_group *vg)
 {
 	int lv_open, active, monitored = 0;
-	int available, r = 1;
+	int activate_arg, r = 1;
 	int activate = 1;
 
 	/*
@@ -223,9 +223,9 @@ static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 	 */
 	cmd->handles_missing_pvs = 1;
 
-	available = arg_uint_value(cmd, available_ARG, 0);
+	activate_arg = arg_uint_value(cmd, activate_ARG, 0);
 
-	if ((available == CHANGE_AN) || (available == CHANGE_ALN))
+	if ((activate_arg == CHANGE_AN) || (activate_arg == CHANGE_ALN))
 		activate = 0;
 
 	/* FIXME: Force argument to deactivate them? */
@@ -252,7 +252,7 @@ static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 		}
 	}
 
-	if (!_activate_lvs_in_vg(cmd, vg, available))
+	if (!_activate_lvs_in_vg(cmd, vg, activate_arg))
 		r = 0;
 
 	/* Print message only if there was not found a missing VG */
@@ -508,8 +508,8 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		log_print("Volume group \"%s\" successfully changed", vg->name);
 	}
 
-	if (arg_count(cmd, available_ARG)) {
-		if (!_vgchange_available(cmd, vg))
+	if (arg_count(cmd, activate_ARG)) {
+		if (!_vgchange_activate(cmd, vg))
 			return ECMD_FAILED;
 	}
 
@@ -519,7 +519,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			return ECMD_FAILED;
 	}
 
-	if (!arg_count(cmd, available_ARG) &&
+	if (!arg_count(cmd, activate_ARG) &&
 	    !arg_count(cmd, refresh_ARG) &&
 	    arg_count(cmd, monitor_ARG)) {
 		/* -ay* will have already done monitoring changes */
@@ -551,7 +551,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, vgmetadatacopies_ARG);
 
 	if (!update &&
-	    !arg_count(cmd, available_ARG) &&
+	    !arg_count(cmd, activate_ARG) &&
 	    !arg_count(cmd, monitor_ARG) &&
 	    !arg_count(cmd, poll_ARG) &&
 	    !arg_count(cmd, refresh_ARG)) {
@@ -562,7 +562,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, available_ARG) && arg_count(cmd, refresh_ARG)) {
+	if (arg_count(cmd, activate_ARG) && arg_count(cmd, refresh_ARG)) {
 		log_error("Only one of -a and --refresh permitted.");
 		return EINVALID_CMD_LINE;
 	}
@@ -573,9 +573,9 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, available_ARG) &&
+	if (arg_count(cmd, activate_ARG) &&
 	    (arg_count(cmd, monitor_ARG) || arg_count(cmd, poll_ARG))) {
-		int activate = arg_uint_value(cmd, available_ARG, 0);
+		int activate = arg_uint_value(cmd, activate_ARG, 0);
 		if (activate == CHANGE_AN || activate == CHANGE_ALN) {
 			log_error("Only -ay* allowed with --monitor or --poll.");
 			return EINVALID_CMD_LINE;
@@ -587,7 +587,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, available_ARG) == 1
+	if (arg_count(cmd, activate_ARG) == 1
 	    && arg_count(cmd, autobackup_ARG)) {
 		log_error("-A option not necessary with -a option");
 		return EINVALID_CMD_LINE;


