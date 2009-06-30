From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2009 18:39:34 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20090630183934.11350.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-06-30 18:39:32

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	lib/commands   : errors.h 
	lib/metadata   : metadata.c 
	man            : lvconvert.8.in lvs.8.in pvs.8.in 
	tools          : commands.h lvconvert.c 

Log message:
	pre-release tidy up

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.197&r2=1.198
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1158&r2=1.1159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.279&r2=1.280
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/errors.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.227&r2=1.228
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/VERSION	2009/06/26 10:57:30	1.197
+++ LVM2/VERSION	2009/06/30 18:39:31	1.198
@@ -1 +1 @@
-2.02.48-cvs (2009-06-26)
+2.02.48-cvs (2009-06-29)
--- LVM2/VERSION_DM	2009/06/26 10:57:30	1.10
+++ LVM2/VERSION_DM	2009/06/30 18:39:31	1.11
@@ -1 +1 @@
-1.02.33-cvs (2009-06-26)
+1.02.33-cvs (2009-06-29)
--- LVM2/WHATS_NEW	2009/06/26 10:57:30	1.1158
+++ LVM2/WHATS_NEW	2009/06/30 18:39:31	1.1159
@@ -1,27 +1,26 @@
-Version 2.02.48 - 26th June 2009
+Version 2.02.48 - 29th June 2009
 ================================
   Abort if automatic metadata correction fails when reading VG to update it.
   Explicitly request fallback to default major number in device mapper.
   Ignore suspended devices during repair.
-  Call vgreduce --removemissing automatically to clean up bad PVs in dmeventd.
-  Suggest use lvchange --resync when up converting not yet synced mirror.
-  Destroy toolcontext on exit in clvmd (fixes memory pool leaks).
-  Fix lvconvert to not poll mirror if no conversion in progress.
+  Call vgreduce --removemissing automatically to fix missing PVs in dmeventd.
+  Suggest using lvchange --resync when adding leg to not-yet-synced mirror.
+  Destroy toolcontext on clvmd exit to avoid memory pool leaks.
+  Fix lvconvert not to poll mirror if no conversion in progress.
   Fix memory leaks in toolcontext error path.
-  Re-instate partial activation support in clustered mode. (2.02.40)
+  Reinstate partial activation support in clustered mode. (2.02.40)
   Allow metadata correction even when PVs are missing.
   Use 'lvm lvresize' instead of 'lvresize' in fsadm.
   Do not use '-n' realine option in fsadm for busybox compatiblity.
-  Update vgrename, vgsplit, and vgcreate to use vg_lock_newname.
-  Add vg_lock_newname() library function.
+  Add vg_lock_newname() library function for vgrename, vgsplit and vgcreate.
   Round up requested readahead to at least one page and print warning.
   Try to repair vg before actual vgremove when force flag provided.
   Fix possible double release of VG after recovery.
   Add parameter to process_each_vg specifying what to do with inconsistent VG.
-  Unify error messages when procesing inconsistent volume group.
+  Unify error messages when processing inconsistent volume group.
   Use lvconvert --repair instead of vgreduce in mirror dmeventd DSO.
   Introduce lvconvert --use_policies (repair policy according to lvm.conf).
-  Fix clvmd-corosync to match new corosync API.
+  Update clvmd-corosync to match new corosync API.
   Fix makefile to build also shared libraries when running plain make.
   Fix rename of active snapshot with virtual origin.
   Fix convert polling to ignore LV with different UUID.
--- LVM2/WHATS_NEW_DM	2009/06/26 10:57:30	1.279
+++ LVM2/WHATS_NEW_DM	2009/06/30 18:39:31	1.280
@@ -1,8 +1,8 @@
-Version 1.02.33 - 26th June 2009
+Version 1.02.33 - 29th June 2009
 ================================
-  Do not fallback to default major number, provide new function instead (1.02.31)
+  Don't fallback to default major number: use dm_task_set_major_minor. (1.02.31)
   Do not fork daemon when dmeventd cannot be found.
-  Add crypt target handling to libdevmapper node.
+  Add crypt target handling to libdevmapper tree nodes.
   Add splitname command to dmsetup.
   Add subsystem, vg_name, lv_name, lv_layer fields to dmsetup reports.
   Make mempool optional in dm_split_lvm_name().
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/06/15 14:47:39	1.24
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/06/30 18:39:31	1.25
@@ -13,6 +13,7 @@
  */
 
 #include "lvm2cmd.h"
+#include "errors.h"
 
 #include <libdevmapper.h>
 #include <libdevmapper-event.h>
@@ -161,14 +162,14 @@
 
 	r = lvm2_run(_lvm_handle, cmd_str);
 
-	if (r == 1) {
+	if (r == ECMD_PROCESSED) {
 		snprintf(cmd_str, CMD_SIZE, "vgreduce --removemissing %s", vg);
 		if (lvm2_run(_lvm_handle, cmd_str) != 1)
 			syslog(LOG_ERR, "Unable to remove failed PVs from VG %s", vg);
 	}
 
 	dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
-	return (r == 1) ? 0 : -1;
+	return (r == ECMD_PROCESSED) ? 0 : -1;
 }
 
 void process_event(struct dm_task *dmt,
--- LVM2/lib/commands/errors.h	2007/08/20 20:55:24	1.5
+++ LVM2/lib/commands/errors.h	2009/06/30 18:39:31	1.6
@@ -21,4 +21,6 @@
 #define EINVALID_CMD_LINE	3
 #define ECMD_FAILED		5
 
+/* FIXME Also returned by cmdlib. */
+
 #endif
--- LVM2/lib/metadata/metadata.c	2009/06/10 20:17:32	1.227
+++ LVM2/lib/metadata/metadata.c	2009/06/30 18:39:31	1.228
@@ -2953,12 +2953,11 @@
 		}
 	}
 
-	/* Found vgname, cannot reserve */
+	/* Found vgname so cannot reserve. */
 	unlock_vg(cmd, vgname);
 	return FAILED_EXIST;
 }
 
-
 /*
  * Gets/Sets for external LVM library
  */
--- LVM2/man/lvconvert.8.in	2009/06/04 12:01:15	1.4
+++ LVM2/man/lvconvert.8.in	2009/06/30 18:39:32	1.5
@@ -5,11 +5,10 @@
 .B lvconvert
 \-m|\-\-mirrors Mirrors [\-\-mirrorlog {disk|core}] [\-\-corelog] [\-R|\-\-regionsize MirrorLogRegionSize]
 [\-A|\-\-alloc AllocationPolicy]
-[\-b|\-\-background] [\-i|\-\-interval Seconds]
+[\-b|\-\-background] [\-f|\-\-force] [\-i|\-\-interval Seconds]
 [\-h|\-?|\-\-help]
-[\-v|\-\-verbose]
+[\-v|\-\-verbose] [\-y|\-\-yes]
 [\-\-version]
-.br
 LogicalVolume[Path] [PhysicalVolume[Path]...]
 .br
 
@@ -62,15 +61,13 @@
 .br
 .TP
 .I \-\-repair
-Repair a mirror that has suffered a disk failure. The mirror will be brought
-back into a consistent state, and if possible, the original number of mirrors
-will be restored, if so desired. By default, lvconvert will prompt you whether
-to perform the replacement. If you instead wish to unconditionally replace
-missing devices, you may specify \-y on the commandline and if you instead want
-no replacement to happen at all, you may provide \-f. Additionally, you may use
-"--use-policies" - this option will use the device replacement policy specified
-in lvm.conf, specifically "activation/mirror_log_fault_policy" and
-"activation/mirror_device_fault_policy".
+Repair a mirror after suffering a disk failure. The mirror will be brought back
+into a consistent state.  By default, the original number of mirrors will be
+restored if possible.  Specify \-y on the command line to skip the prompts.
+Use \-f if you do not want any replacement.  Additionally, you may use
+\-\-use-policies to use the device replacement policy specified in lvm.conf,
+viz. activation/mirror_log_fault_policy or
+activation/mirror_device_fault_policy.
 .br
 .TP
 .I \-s, \-\-snapshot
--- LVM2/man/lvs.8.in	2009/06/15 17:09:32	1.8
+++ LVM2/man/lvs.8.in	2009/06/30 18:39:32	1.9
@@ -38,16 +38,17 @@
 Comma-separated ordered list of columns.  Precede the list with '+' to append
 to the default selection of columns instead of replacing it.
 .IP
-Use \fb-o lv_all\fP to select all logical volume columns, and \fb-o seg_all\fP to select all
-logical segment columns.
+Use \fb-o lv_all\fP to select all logical volume columns, and \fb-o seg_all\fP
+to select all logical volume segment columns.
 .IP
 Use \fb-o help\fP to view the full list of columns available.
 .IP
 Column names include:
-lv_uuid, lv_name, lv_attr, lv_major, lv_minor, lv_read_ahead, lv_kernel_major, lv_kernel_minor,
-lv_kernel_read_ahead, lv_size, seg_count, origin, origin_size, snap_percent, copy_percent, move_pv,
-convert_lv, lv_tags, mirror_log, modules, segtype, stripes, stripesize, regionsize, chunksize, seg_start,
-seg_start_pe, seg_size, seg_tags, seg_pe_ranges, devices.
+lv_uuid, lv_name, lv_attr, lv_major, lv_minor, lv_read_ahead, lv_kernel_major,
+lv_kernel_minor, lv_kernel_read_ahead, lv_size, seg_count, origin, origin_size,
+snap_percent, copy_percent, move_pv, convert_lv, lv_tags, mirror_log, modules,
+segtype, stripes, stripesize, regionsize, chunksize, seg_start, seg_start_pe,
+seg_size, seg_tags, seg_pe_ranges, devices.
 .IP
 With \-\-segments, any "seg_" prefixes are optional; otherwise any "lv_"
 prefixes are optional.  Columns mentioned in \fBvgs (8)\fP 
@@ -56,9 +57,9 @@
 The lv_attr bits are: 
 .RS
 .IP 1 3
-Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin, (p)vmove, (s)napshot, 
-invalid (S)napshot, (v)irtual, mirror (i)mage, mirror (I)mage out-of-sync,
-under (c)onversion
+Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin, (p)vmove,
+(s)napshot, invalid (S)napshot, (v)irtual, mirror (i)mage, mirror (I)mage
+out-of-sync, under (c)onversion
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only
 .IP 3 3
--- LVM2/man/pvs.8.in	2009/06/15 17:09:32	1.9
+++ LVM2/man/pvs.8.in	2009/06/30 18:39:32	1.10
@@ -39,7 +39,7 @@
 to the default selection of columns.
 .IP
 Use \fb-o pv_all\fP to select all physical volume columns, and \fb-o pvseg_all\fP
-to select all physical segment columns.
+to select all Physical Volume segment columns.
 .IP
 Use \fb-o help\fP to view the full list of columns available.
 .IP
--- LVM2/tools/commands.h	2009/06/04 12:01:16	1.127
+++ LVM2/tools/commands.h	2009/06/30 18:39:32	1.128
@@ -99,9 +99,11 @@
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
    "\t[-d|--debug]\n"
+   "\t[-f|--force]\n"
    "\t[-h|-?|--help]\n"
    "\t[-i|--interval seconds]\n"
    "\t[-v|--verbose]\n"
+   "\t[-y|--yes]\n"
    "\t[--version]" "\n"
    "\tLogicalVolume[Path] [PhysicalVolume[Path]...]\n\n"
 
--- LVM2/tools/lvconvert.c	2009/06/26 11:29:06	1.86
+++ LVM2/tools/lvconvert.c	2009/06/30 18:39:32	1.87
@@ -111,9 +111,10 @@
 	memset(lp, 0, sizeof(*lp));
 
 	if (arg_count(cmd, snapshot_ARG) &&
-	    (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG))) {
-		log_error("--snapshots argument cannot be mixed "
-			  "with --mirrors or --log");
+	    (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG) ||
+	     arg_count(cmd, repair_ARG))) {
+		log_error("--snapshot argument cannot be mixed "
+			  "with --mirrors, --repair or --log");
 		return 0;
 	}
 
@@ -529,7 +530,7 @@
 	}
 
 	if (arg_count(cmd, mirrors_ARG) && repair) {
-		log_error("You can only use one of -m, --repair.");
+		log_error("You may only use one of --mirrors and --repair.");
 		return 0;
 	}
 


