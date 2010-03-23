From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 23 Mar 2010 15:23:53 -0400
Subject: [PATCH v2] improve activation monitoring option processing
Message-ID: <1269372233-4199-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add "monitoring" option to "activation" section of lvm.conf

Have clvmd consult the lvm.conf "activation/monitoring" too.

Introduce toollib.c:get_activation_monitoring_mode().

Error out when both --monitor and --ignoremonitoring are provided.

Add --monitor and --ignoremonitoring support to lvcreate.  Update
lvcreate man page accordingly.

Clarify that '--monitor' controls the start and stop of monitoring in
the {vg,lv}change man pages.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 daemons/clvmd/lvm-functions.c    |    8 ++++++--
 doc/example.conf                 |    4 ++++
 lib/metadata/lv_manip.c          |    2 ++
 lib/metadata/metadata-exported.h |    1 +
 liblvm/lvm_lv.c                  |    1 +
 man/lvchange.8.in                |    3 +--
 man/lvcreate.8.in                |   14 ++++++++++++++
 man/vgchange.8.in                |    3 +--
 tools/commands.h                 |   14 +++++++++-----
 tools/lvchange.c                 |    9 +++++----
 tools/lvcreate.c                 |    3 +++
 tools/toollib.c                  |   21 +++++++++++++++++++++
 tools/toollib.h                  |    3 +++
 tools/vgchange.c                 |    9 +++++----
 14 files changed, 76 insertions(+), 19 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 02d401b..60b6db4 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -542,8 +542,12 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(0);
 
-	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
-		init_dmeventd_monitor(DEFAULT_DMEVENTD_MONITOR);
+	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE)) {
+		int dmeventd_mode =
+			find_config_tree_bool(cmd, "activation/monitoring",
+					      DEFAULT_DMEVENTD_MONITOR);
+		init_dmeventd_monitor(dmeventd_mode);
+	}
 
 	cmd->partial_activation = 0;
 
diff --git a/doc/example.conf b/doc/example.conf
index 511e20c..89e13ed 100644
--- a/doc/example.conf
+++ b/doc/example.conf
@@ -428,6 +428,10 @@ activation {
     # which used mlockall() to pin the whole process's memory while activating
     # devices.
     # use_mlockall = 0
+
+    # Monitoring is enabled by default when activating logical volumes.
+    # Set to 0 to disable monitoring or use the --ignoremonitoring option.
+    # monitoring = 1
 }
 
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 93fd57f..bb3f5cd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3056,6 +3056,8 @@ int lv_create_single(struct volume_group *vg,
 
 	backup(vg);
 
+	init_dmeventd_monitor(lp->activation_monitoring);
+
 	if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2f1405f..b02a22c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -535,6 +535,7 @@ struct lvcreate_params {
 	int minor; /* all */
 	int log_count; /* mirror */
 	int nosync; /* mirror */
+	int activation_monitoring; /* all */
 
 	char *origin; /* snap */
 	const char *vg_name; /* all */
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 86175ae..82e6d4b 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -111,6 +111,7 @@ static void _lv_set_default_params(struct lvcreate_params *lp,
 	lp->zero = 1;
 	lp->major = -1;
 	lp->minor = -1;
+	lp->activation_monitoring = DEFAULT_DMEVENTD_MONITOR;
 	lp->vg_name = vg->name;
 	lp->lv_name = lvname; /* FIXME: check this for safety */
 	lp->pvh = &vg->pvs;
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 08a83c4..99f9bf3 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -56,8 +56,7 @@ of your data.
 Set the minor number.
 .TP
 .I \-\-monitor y|n
-Controls whether or not a mirrored logical volume is monitored by
-dmeventd, if it is installed.
+Start or stop monitoring a logical volume, if dmeventd is installed.
 If a device used by a monitored mirror reports an I/O error,
 the failure is handled according to 
 \fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 314c354..826610f 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -7,6 +7,8 @@ lvcreate \- create a logical volume in an existing volume group
 [\-\-alloc AllocationPolicy]
 [\-A|\-\-autobackup y|n] [\-C|\-\-contiguous y|n] [\-d|\-\-debug]
 [\-h|\-?|\-\-help] [\-\-noudevsync]
+[\-\-ignoremonitoring]
+[\-\-monitor {y|n}]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
@@ -26,6 +28,8 @@ VolumeGroupName [PhysicalVolumePath[:PE[-PE]]...]
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-c|\-\-chunksize ChunkSize]
 [\-\-noudevsync]
+[\-\-ignoremonitoring]
+[\-\-monitor {y|n}]
 \-n|\-\-name SnapshotLogicalVolumeName
 {{\-s|\-\-snapshot}
 OriginalLogicalVolumePath | 
@@ -128,6 +132,16 @@ process will not wait for notification from udev.
 It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
+.I \-\-monitor y|n
+Start or avoid monitoring a logical volume, if dmeventd is installed.
+If a device used by a monitored mirror reports an I/O error,
+the failure is handled according to 
+\fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
+set in \fBlvm.conf\fP.
+.TP
+.I \-\-ignoremonitoring
+Make no attempt to interact with dmeventd unless \-\-monitor
+is specified.
 .TP
 .I \-p, \-\-permission r|rw
 Set access permissions to read only or read and write.
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 5013c1e..e01158a 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -78,8 +78,7 @@ are not marked as clustered.
 Generate new random UUID for specified Volume Groups.
 .TP
 .BR \-\-monitor " " { y | n }
-Controls whether or not a mirrored logical volume is monitored by
-dmeventd, if it is installed.
+Start or stop monitoring a logical volume, if dmeventd is installed.
 If a device used by a monitored mirror reports an I/O error,
 the failure is handled according to 
 .BR mirror_image_fault_policy
diff --git a/tools/commands.h b/tools/commands.h
index ad0b385..58d6d7b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -150,6 +150,8 @@ xx(lvcreate,
    "\t[-C|--contiguous {y|n}]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
+   "\t[--ignoremonitoring]\n"
+   "\t[--monitor {y|n}]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
@@ -177,6 +179,8 @@ xx(lvcreate,
    "\t[-C|--contiguous {y|n}]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
+   "\t[--ignoremonitoring]\n"
+   "\t[--monitor {y|n}]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
@@ -192,11 +196,11 @@ xx(lvcreate,
    "\t[PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
-   corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
-   name_ARG, nosync_ARG, noudevsync_ARG, permission_ARG, persistent_ARG,
-   readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG,
-   stripesize_ARG, test_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
-   zero_ARG)
+   corelog_ARG, extents_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
+   mirrorlog_ARG, mirrors_ARG, monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG,
+   permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG,
+   snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG,
+   virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 2d7955e..534c993 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -518,7 +518,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute((unused)))
 {
 	int doit = 0, docmds = 0;
-	int archived = 0;
+	int dmeventd_mode, archived = 0;
 	struct logical_volume *origin;
 
 	if (!(lv->vg->status & LVM_WRITE) &&
@@ -575,9 +575,10 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
-					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
-					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
+	if (!get_activation_monitoring_mode(cmd, &dmeventd_mode))
+		return ECMD_FAILED;
+
+	init_dmeventd_monitor(dmeventd_mode);
 
 	/*
 	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 211cfeb..10b5aa5 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -482,6 +482,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
+	if (!get_activation_monitoring_mode(cmd, &lp->activation_monitoring))
+		return_0;
+
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !_read_stripe_params(lp, cmd) ||
diff --git a/tools/toollib.c b/tools/toollib.c
index 5470169..b1528e2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1423,3 +1423,24 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 	return 1;
 }
 
+int get_activation_monitoring_mode(struct cmd_context *cmd,
+				   int *monitoring_mode)
+{
+	*monitoring_mode = DEFAULT_DMEVENTD_MONITOR;
+
+	if (arg_count(cmd, monitor_ARG) &&
+	    arg_count(cmd, ignoremonitoring_ARG)) {
+		log_error("Conflicting monitor and ignoremonitoring options");
+		return 0;
+	}
+
+	if (arg_count(cmd, monitor_ARG))
+		*monitoring_mode = arg_int_value(cmd, monitor_ARG,
+						 DEFAULT_DMEVENTD_MONITOR);
+	else if (is_static() || arg_count(cmd, ignoremonitoring_ARG) ||
+		 !find_config_tree_bool(cmd, "activation/monitoring",
+					DEFAULT_DMEVENTD_MONITOR))
+		*monitoring_mode = DMEVENTD_MONITOR_IGNORE;
+	
+	return 1;
+}
diff --git a/tools/toollib.h b/tools/toollib.h
index d284de4..987814e 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -112,4 +112,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 			     int argc, char **argv,
 			     struct pvcreate_params *pp);
 
+int get_activation_monitoring_mode(struct cmd_context *cmd,
+				   int *monitoring_mode);
+
 #endif
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 6d869f9..e013bde 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -522,16 +522,17 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
-	int r = ECMD_FAILED;
+	int dmeventd_mode, r = ECMD_FAILED;
 
 	if (vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
 	}
 
-	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
-					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
-					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
+	if (!get_activation_monitoring_mode(cmd, &dmeventd_mode))
+		return ECMD_FAILED;
+
+	init_dmeventd_monitor(dmeventd_mode);
 
 	/*
 	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".


