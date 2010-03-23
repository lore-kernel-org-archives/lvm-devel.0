From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 23 Mar 2010 22:30:23 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20100323223023.23696.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-03-23 22:30:20

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	doc            : example.conf 
	lib/metadata   : lv_manip.c metadata-exported.h 
	liblvm         : lvm_lv.c 
	man            : lvchange.8.in lvcreate.8.in vgchange.8.in 
	tools          : commands.h lvchange.c lvcreate.c toollib.c 
	                 toollib.h vgchange.c 

Log message:
	Improve activation monitoring option processing
	
	. Add "monitoring" option to "activation" section of lvm.conf
	. Have clvmd consult the lvm.conf "activation/monitoring" too.
	. Introduce toollib.c:get_activation_monitoring_mode().
	. Error out when both --monitor and --ignoremonitoring are provided.
	. Add --monitor and --ignoremonitoring support to lvcreate.  Update
	lvcreate man page accordingly.
	. Clarify that '--monitor' controls the start and stop of monitoring in
	the {vg,lv}change man pages.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1475&r2=1.1476
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.211&r2=1.212
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.215&r2=1.216
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.189&r2=1.190
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/WHATS_NEW	2010/03/23 15:07:55	1.1475
+++ LVM2/WHATS_NEW	2010/03/23 22:30:18	1.1476
@@ -1,5 +1,8 @@
 Version 2.02.63 - 
 ================================
+  Add "monitoring" option to "activation" section of lvm.conf.
+  Have clvmd consult the lvm.conf "activation/monitoring".
+  Add --monitor and --ignoremonitoring support to lvcreate.
   Allow dynamic extension of array of areas selected as allocation candidates.
   Export and use only valid cookie value in test suite.
   Remove const modifier for struct volume_group* from process_each_lv_in_vg().
--- LVM2/daemons/clvmd/lvm-functions.c	2010/01/26 08:00:03	1.84
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/03/23 22:30:19	1.85
@@ -542,8 +542,12 @@
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
 
--- LVM2/doc/example.conf	2010/03/05 14:48:33	1.55
+++ LVM2/doc/example.conf	2010/03/23 22:30:19	1.56
@@ -428,6 +428,10 @@
     # which used mlockall() to pin the whole process's memory while activating
     # devices.
     # use_mlockall = 0
+
+    # Monitoring is enabled by default when activating logical volumes.
+    # Set to 0 to disable monitoring or use the --ignoremonitoring option.
+    # monitoring = 1
 }
 
 
--- LVM2/lib/metadata/lv_manip.c	2010/03/23 15:07:55	1.211
+++ LVM2/lib/metadata/lv_manip.c	2010/03/23 22:30:19	1.212
@@ -3061,6 +3061,8 @@
 
 	backup(vg);
 
+	init_dmeventd_monitor(lp->activation_monitoring);
+
 	if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
--- LVM2/lib/metadata/metadata-exported.h	2010/03/16 16:57:04	1.136
+++ LVM2/lib/metadata/metadata-exported.h	2010/03/23 22:30:19	1.137
@@ -535,6 +535,7 @@
 	int minor; /* all */
 	int log_count; /* mirror */
 	int nosync; /* mirror */
+	int activation_monitoring; /* all */
 
 	char *origin; /* snap */
 	const char *vg_name; /* all */
--- LVM2/liblvm/lvm_lv.c	2010/02/24 18:16:26	1.19
+++ LVM2/liblvm/lvm_lv.c	2010/03/23 22:30:19	1.20
@@ -111,6 +111,7 @@
 	lp->zero = 1;
 	lp->major = -1;
 	lp->minor = -1;
+	lp->activation_monitoring = DEFAULT_DMEVENTD_MONITOR;
 	lp->vg_name = vg->name;
 	lp->lv_name = lvname; /* FIXME: check this for safety */
 	lp->pvh = &vg->pvs;
--- LVM2/man/lvchange.8.in	2010/01/06 19:08:58	1.6
+++ LVM2/man/lvchange.8.in	2010/03/23 22:30:20	1.7
@@ -56,7 +56,7 @@
 Set the minor number.
 .TP
 .I \-\-monitor y|n
-Controls whether or not a mirrored logical volume is monitored by
+Start or stop monitoring a mirrored or snapshot logical volume with
 dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
 the failure is handled according to 
--- LVM2/man/lvcreate.8.in	2010/02/03 03:58:08	1.15
+++ LVM2/man/lvcreate.8.in	2010/03/23 22:30:20	1.16
@@ -7,6 +7,8 @@
 [\-\-alloc AllocationPolicy]
 [\-A|\-\-autobackup y|n] [\-C|\-\-contiguous y|n] [\-d|\-\-debug]
 [\-h|\-?|\-\-help] [\-\-noudevsync]
+[\-\-ignoremonitoring]
+[\-\-monitor {y|n}]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
@@ -26,6 +28,8 @@
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-c|\-\-chunksize ChunkSize]
 [\-\-noudevsync]
+[\-\-ignoremonitoring]
+[\-\-monitor {y|n}]
 \-n|\-\-name SnapshotLogicalVolumeName
 {{\-s|\-\-snapshot}
 OriginalLogicalVolumePath | 
@@ -129,6 +133,18 @@
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
+.I \-\-monitor y|n
+Start or avoid monitoring a mirrored or snapshot logical volume with
+dmeventd, if it is installed. 
+If a device used by a monitored mirror reports an I/O error,
+the failure is handled according to 
+\fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
+set in \fBlvm.conf\fP.
+.TP
+.I \-\-ignoremonitoring
+Make no attempt to interact with dmeventd unless \-\-monitor
+is specified.
+.TP
 .I \-p, \-\-permission r|rw
 Set access permissions to read only or read and write.
 .br
--- LVM2/man/vgchange.8.in	2010/01/06 19:08:58	1.7
+++ LVM2/man/vgchange.8.in	2010/03/23 22:30:20	1.8
@@ -78,7 +78,7 @@
 Generate new random UUID for specified Volume Groups.
 .TP
 .BR \-\-monitor " " { y | n }
-Controls whether or not a mirrored logical volume is monitored by
+Start or stop monitoring a mirrored or snapshot logical volume with
 dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
 the failure is handled according to 
--- LVM2/tools/commands.h	2010/02/03 03:58:08	1.141
+++ LVM2/tools/commands.h	2010/03/23 22:30:20	1.142
@@ -150,6 +150,8 @@
    "\t[-C|--contiguous {y|n}]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
+   "\t[--ignoremonitoring]\n"
+   "\t[--monitor {y|n}]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
@@ -177,6 +179,8 @@
    "\t[-C|--contiguous {y|n}]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
+   "\t[--ignoremonitoring]\n"
+   "\t[--monitor {y|n}]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
@@ -192,11 +196,11 @@
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
--- LVM2/tools/lvchange.c	2010/02/24 18:15:49	1.117
+++ LVM2/tools/lvchange.c	2010/03/23 22:30:20	1.118
@@ -518,7 +518,7 @@
 			   void *handle __attribute((unused)))
 {
 	int doit = 0, docmds = 0;
-	int archived = 0;
+	int dmeventd_mode, archived = 0;
 	struct logical_volume *origin;
 
 	if (!(lv->vg->status & LVM_WRITE) &&
@@ -575,9 +575,10 @@
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
--- LVM2/tools/lvcreate.c	2010/02/03 03:58:08	1.215
+++ LVM2/tools/lvcreate.c	2010/03/23 22:30:20	1.216
@@ -482,6 +482,9 @@
 		return 0;
 	}
 
+	if (!get_activation_monitoring_mode(cmd, &lp->activation_monitoring))
+		return_0;
+
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !_read_stripe_params(lp, cmd) ||
--- LVM2/tools/toollib.c	2010/03/23 14:24:04	1.189
+++ LVM2/tools/toollib.c	2010/03/23 22:30:20	1.190
@@ -1423,3 +1423,24 @@
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
--- LVM2/tools/toollib.h	2010/03/23 14:24:04	1.69
+++ LVM2/tools/toollib.h	2010/03/23 22:30:20	1.70
@@ -112,4 +112,7 @@
 			     int argc, char **argv,
 			     struct pvcreate_params *pp);
 
+int get_activation_monitoring_mode(struct cmd_context *cmd,
+				   int *monitoring_mode);
+
 #endif
--- LVM2/tools/vgchange.c	2010/02/24 18:15:06	1.99
+++ LVM2/tools/vgchange.c	2010/03/23 22:30:20	1.100
@@ -522,16 +522,17 @@
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


