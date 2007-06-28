From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 28 Jun 2007 17:33:47 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/c ...
Message-ID: <20070628173347.26116.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2007-06-28 17:33:44

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/commands   : toolcontext.c 
	lib/format_text: archiver.c format-text.c 
	lib/locking    : locking.c 
	lib/log        : log.c log.h 
	lib/metadata   : metadata.c mirror.c 
	scripts        : lvm2_monitoring_init_rhel4 
	tools          : lvconvert.c lvcreate.c lvmcmdline.c 
	                 lvmdiskscan.c lvresize.c pvcreate.c pvremove.c 
	                 pvresize.c pvscan.c vgcfgbackup.c vgcreate.c 

Log message:
	Make warnings go to stderr. Change log_warn to that effect, log_print
	continues to send messages to stdout.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.641&r2=1.642
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_rhel4.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmdiskscan.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2007/06/25 13:19:37	1.641
+++ LVM2/WHATS_NEW	2007/06/28 17:33:43	1.642
@@ -6,6 +6,7 @@
   Add --ignoremonitoring to disable all dmeventd interaction.
   Remove get_ prefix from get_pv_* functions.
   clvmd-openais now uses cpg_local_get() to get nodeid, rather than Clm.
+  Print warnings to stderr instead of stdout.
 
 Version 2.02.26 - 15th June 2007
 ================================
--- LVM2/lib/activate/activate.c	2007/04/27 17:46:16	1.122
+++ LVM2/lib/activate/activate.c	2007/06/28 17:33:43	1.123
@@ -245,7 +245,7 @@
 		log_verbose("Activation enabled. Device-mapper kernel "
 			    "driver will be used.");
 	else
-		log_print("WARNING: Activation disabled. No device-mapper "
+		log_warn("WARNING: Activation disabled. No device-mapper "
 			  "interaction will be attempted.");
 }
 
--- LVM2/lib/commands/toolcontext.c	2007/04/26 16:44:58	1.50
+++ LVM2/lib/commands/toolcontext.c	2007/06/28 17:33:44	1.51
@@ -184,7 +184,7 @@
 	}
 
 	if (*cmd->proc_dir && !dir_exists(cmd->proc_dir)) {
-		log_error("Warning: proc dir %s not found - some checks will be bypassed",
+		log_error("WARNING: proc dir %s not found - some checks will be bypassed",
 			  cmd->proc_dir);
 		cmd->proc_dir[0] = '\0';
 	}
--- LVM2/lib/format_text/archiver.c	2007/06/08 22:38:48	1.6
+++ LVM2/lib/format_text/archiver.c	2007/06/28 17:33:44	1.7
@@ -214,7 +214,7 @@
 int backup(struct volume_group *vg)
 {
 	if (!vg->cmd->backup_params->enabled || !vg->cmd->backup_params->dir) {
-		log_print("WARNING: This metadata update is NOT backed up");
+		log_warn("WARNING: This metadata update is NOT backed up");
 		return 1;
 	}
 
--- LVM2/lib/format_text/format-text.c	2007/04/25 21:10:55	1.75
+++ LVM2/lib/format_text/format-text.c	2007/06/28 17:33:44	1.76
@@ -1204,8 +1204,8 @@
 
 	/* Ensure it's not going to be bigger than the disk! */
 	if (start1 + mda_size1 > disk_size) {
-		log_print("Warning: metadata area fills disk leaving no "
-			  "space for data on %s.", dev_name(pv->dev));
+		log_warn("WARNING: metadata area fills disk leaving no "
+			 "space for data on %s.", dev_name(pv->dev));
 		/* Leave some free space for rounding */
 		/* Avoid empty data area as could cause tools problems */
 		mda_size1 = disk_size - start1 - alignment * 2;
--- LVM2/lib/locking/locking.c	2007/06/15 20:46:04	1.37
+++ LVM2/lib/locking/locking.c	2007/06/28 17:33:44	1.38
@@ -214,7 +214,7 @@
 	switch (type) {
 	case 0:
 		init_no_locking(&_locking, cmd);
-		log_print("WARNING: Locking disabled. Be careful! "
+		log_warn("WARNING: Locking disabled. Be careful! "
 			  "This could corrupt your metadata.");
 		return 1;
 
@@ -255,8 +255,8 @@
 	if ((type == 2 || type == 3) &&
             find_config_tree_int(cmd, "locking/fallback_to_local_locking",
 				 DEFAULT_FALLBACK_TO_LOCAL_LOCKING)) {
-		log_print("WARNING: Falling back to local file-based locking.");
-		log_print("Volume Groups with the clustered attribute will "
+		log_warn("WARNING: Falling back to local file-based locking.");
+		log_warn("Volume Groups with the clustered attribute will "
 			  "be inaccessible.");
 		if (init_file_locking(&_locking, cmd))
 			return 1;
--- LVM2/lib/log/log.c	2007/01/25 21:22:30	1.38
+++ LVM2/lib/log/log.c	2007/06/28 17:33:44	1.39
@@ -302,6 +302,9 @@
 	int bufused, n;
 	const char *message;
 	const char *trformat;		/* Translated format string */
+	int use_stderr = level & _LOG_STDERR;
+
+	level &= ~_LOG_STDERR;
 
 	if (_log_suppress == 2)
 		return;
@@ -373,9 +376,9 @@
 			break;
 		case _LOG_WARN:
 			if (_verbose_level >= _LOG_WARN) {
-				printf("%s%s", _cmd_name, _msg_prefix);
-				vprintf(trformat, ap);
-				putchar('\n');
+				fprintf(use_stderr ? stderr : stdout, "%s%s", _cmd_name, _msg_prefix);
+				vfprintf(use_stderr ? stderr : stdout, trformat, ap);
+				fputc('\n', use_stderr ? stderr : stdout);
 			}
 			break;
 		case _LOG_ERR:
--- LVM2/lib/log/log.h	2007/04/26 16:44:58	1.36
+++ LVM2/lib/log/log.h	2007/06/28 17:33:44	1.37
@@ -41,6 +41,8 @@
 #include <string.h>		/* strerror() */
 #include <errno.h>
 
+#define _LOG_STDERR 128 /* force things to go to stderr, even if loglevel
+			   would make them go to stdout */
 #define _LOG_DEBUG 7
 #define _LOG_INFO 6
 #define _LOG_NOTICE 5
@@ -116,14 +118,14 @@
 #define log_debug(x...) plog(_LOG_DEBUG, x)
 #define log_info(x...) plog(_LOG_INFO, x)
 #define log_notice(x...) plog(_LOG_NOTICE, x)
-#define log_warn(x...) plog(_LOG_WARN, x)
+#define log_warn(x...) plog(_LOG_WARN | _LOG_STDERR, x)
 #define log_err(x...) plog(_LOG_ERR, x)
 #define log_fatal(x...) plog(_LOG_FATAL, x)
 
 #define stack log_debug("<backtrace>")	/* Backtrace on error */
 
 #define log_error(args...) log_err(args)
-#define log_print(args...) log_warn(args)
+#define log_print(args...) plog(_LOG_WARN, args)
 #define log_verbose(args...) log_notice(args)
 #define log_very_verbose(args...) log_info(args)
 
--- LVM2/lib/metadata/metadata.c	2007/06/19 04:36:12	1.121
+++ LVM2/lib/metadata/metadata.c	2007/06/28 17:33:44	1.122
@@ -207,8 +207,8 @@
 	}
 
 	if (!consistent)
-		log_error("Warning: Volume group %s is not consistent",
-			  vg_name);
+		log_warn("WARNING: Volume group %s is not consistent",
+			 vg_name);
 
 	list_iterate_items(pvl, &vg->pvs) {
 		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
@@ -641,7 +641,7 @@
 
 	if (size) {
 		if (size > pv->size)
-			log_print("WARNING: %s: Overriding real size. "
+			log_warn("WARNING: %s: Overriding real size. "
 				  "You could lose data.", dev_name(pv->dev));
 		log_verbose("%s: Pretending size is %" PRIu64 " sectors.",
 			    dev_name(pv->dev), size);
@@ -1324,8 +1324,8 @@
 			return correct_vg;
 		}
 
-		log_print("Inconsistent metadata found for VG %s - updating "
-			  "to use version %u", vgname, correct_vg->seqno);
+		log_warn("WARNING: Inconsistent metadata found for VG %s - updating "
+			 "to use version %u", vgname, correct_vg->seqno);
 
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
@@ -1620,8 +1620,8 @@
 			continue;
 		}
 		if (!consistent)
-			log_print("Warning: Volume Group %s is not consistent",
-				  vgname);
+			log_warn("WARNING: Volume Group %s is not consistent",
+				 vgname);
 
 		/* Move PVs onto results list */
 		list_iterate_safe(pvh, tmp, &vg->pvs) {
--- LVM2/lib/metadata/mirror.c	2007/03/26 16:10:10	1.38
+++ LVM2/lib/metadata/mirror.c	2007/06/28 17:33:44	1.39
@@ -377,7 +377,7 @@
 		/* Unable to remove bad devices */
 		return 0;
 
-	log_print("WARNING: Bad device removed from mirror volume, %s/%s",
+	log_warn("WARNING: Bad device removed from mirror volume, %s/%s",
 		  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 
 	log_policy = get_mirror_log_fault_policy(mirrored_seg->lv->vg->cmd);
@@ -394,15 +394,15 @@
 			  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 	else if (r > 0)
 		/* Success in replacing device(s) */
-		log_print("WARNING: Mirror volume, %s/%s restored - substitute for failed device found.",
+		log_warn("WARNING: Mirror volume, %s/%s restored - substitute for failed device found.",
 			  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 	else
 		/* Bad device removed, but not replaced because of policy */
 		if (mirrored_seg->area_count == 1) {
-			log_print("WARNING: Mirror volume, %s/%s converted to linear due to device failure.",
+			log_warn("WARNING: Mirror volume, %s/%s converted to linear due to device failure.",
 				  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 		} else if (had_log && !mirrored_seg->log_lv) {
-			log_print("WARNING: Mirror volume, %s/%s disk log removed due to device failure.",
+			log_warn("WARNING: Mirror volume, %s/%s disk log removed due to device failure.",
 				  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 		}
 	/*
--- LVM2/scripts/lvm2_monitoring_init_rhel4	2007/03/16 17:15:36	1.3
+++ LVM2/scripts/lvm2_monitoring_init_rhel4	2007/06/28 17:33:44	1.4
@@ -31,7 +31,7 @@
 {
 	ret=0
 	# TODO do we want to separate out already active groups only?
-	VGS=`vgs --noheadings -o name`
+	VGS=`vgs --noheadings -o name 2> /dev/null`
 	for vg in $VGS
 	do
 	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y $vg || ret=$?
@@ -49,7 +49,7 @@
 	   echo "Not stopping monitoring, this is a dangerous operation. Please use force-stop to override."
 	   return 1
 	fi
-	VGS=`vgs --noheadings -o name`
+	VGS=`vgs --noheadings -o name 2> /dev/null`
 	for vg in $VGS
 	do
 	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n $vg || ret=$?
--- LVM2/tools/lvconvert.c	2007/06/06 19:40:28	1.27
+++ LVM2/tools/lvconvert.c	2007/06/28 17:33:44	1.28
@@ -447,7 +447,7 @@
 	}
 
 	if (!lp->zero || !(lv->status & LVM_WRITE))
-		log_print("WARNING: \"%s\" not zeroed", lv->name);
+		log_warn("WARNING: \"%s\" not zeroed", lv->name);
 	else if (!set_lv(cmd, lv, 0, 0)) {
 			log_error("Aborting. Failed to wipe snapshot "
 				  "exception store.");
--- LVM2/tools/lvcreate.c	2007/06/19 04:23:32	1.136
+++ LVM2/tools/lvcreate.c	2007/06/28 17:33:44	1.137
@@ -693,7 +693,7 @@
 		init_mirror_in_sync(lp->nosync);
 
 		if (lp->nosync) {
-			log_print("WARNING: New mirror won't be synchronised. "
+			log_warn("WARNING: New mirror won't be synchronised. "
 				  "Don't read what you didn't write!");
 			status |= MIRROR_NOTSYNCED;
 		}
--- LVM2/tools/lvmcmdline.c	2007/06/15 10:11:14	1.43
+++ LVM2/tools/lvmcmdline.c	2007/06/28 17:33:44	1.44
@@ -733,7 +733,7 @@
 			return EINVALID_CMD_LINE;
 		}
 		init_trust_cache(1);
-		log_print("WARNING: Cache file of PVs will be trusted.  "
+		log_warn("WARNING: Cache file of PVs will be trusted.  "
 			  "New devices holding PVs may get ignored.");
 	} else
 		init_trust_cache(0);
--- LVM2/tools/lvmdiskscan.c	2007/06/25 13:19:37	1.18
+++ LVM2/tools/lvmdiskscan.c	2007/06/28 17:33:44	1.19
@@ -106,7 +106,7 @@
 	pv_parts_found = 0;
 
 	if (arg_count(cmd, lvmpartition_ARG))
-		log_print("WARNING: only considering LVM devices");
+		log_warn("WARNING: only considering LVM devices");
 
 	max_len = _get_max_dev_name_len(cmd->filter);
 
--- LVM2/tools/lvresize.c	2007/06/15 10:11:14	1.78
+++ LVM2/tools/lvresize.c	2007/06/28 17:33:44	1.79
@@ -155,14 +155,14 @@
 		if (vg->fid->fmt->features & FMT_SEGMENTS)
 			lp->stripes = arg_uint_value(cmd, stripes_ARG, 1);
 		else
-			log_print("Varied striping not supported. Ignoring.");
+			log_warn("Varied striping not supported. Ignoring.");
 	}
 
 	if (arg_count(cmd, mirrors_ARG)) {
 		if (vg->fid->fmt->features & FMT_SEGMENTS)
 			lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 1) + 1;
 		else
-			log_print("Mirrors not supported. Ignoring.");
+			log_warn("Mirrors not supported. Ignoring.");
 		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
 			log_error("Mirrors argument may not be negative");
 			return 0;
@@ -182,7 +182,7 @@
 		}
 
 		if (!(vg->fid->fmt->features & FMT_SEGMENTS))
-			log_print("Varied stripesize not supported. Ignoring.");
+			log_warn("Varied stripesize not supported. Ignoring.");
 		else if (arg_uint_value(cmd, stripesize_ARG, 0) > vg->extent_size) {
                 	log_error("Reducing stripe size %s to maximum, "
 				  "physical extent size %s",
@@ -447,7 +447,7 @@
 
 	if (lp->resize == LV_REDUCE) {
 		if (lp->argc)
-			log_print("Ignoring PVs on command line when reducing");
+			log_warn("Ignoring PVs on command line when reducing");
 	} else if (!(pvh = lp->argc ? create_pv_list(cmd->mem, vg, lp->argc,
 						     lp->argv, 1) : &vg->pvs)) {
 		stack;
@@ -469,13 +469,13 @@
 		}
 
 		if (info.exists && !lp->resizefs && (lp->resize == LV_REDUCE)) {
-			log_print("WARNING: Reducing active%s logical volume "
+			log_warn("WARNING: Reducing active%s logical volume "
 				  "to %s", info.open_count ? " and open" : "",
 				  display_size(cmd, (uint64_t) lp->extents *
 						    vg->extent_size));
 
-			log_print("THIS MAY DESTROY YOUR DATA "
-				  "(filesystem etc.)");
+			log_warn("THIS MAY DESTROY YOUR DATA "
+				 "(filesystem etc.)");
 
 			if (!arg_count(cmd, force_ARG)) {
 				if (yes_no_prompt("Do you really want to "
--- LVM2/tools/pvcreate.c	2007/06/15 22:16:55	1.53
+++ LVM2/tools/pvcreate.c	2007/06/28 17:33:44	1.54
@@ -110,7 +110,7 @@
 		return 0;
 
 	if (pv && !is_orphan(pv) && arg_count(cmd, force_ARG)) {
-		log_print("WARNING: Forcing physical volume creation on "
+		log_warn("WARNING: Forcing physical volume creation on "
 			  "%s%s%s%s", name,
 			  !is_orphan(pv) ? " of volume group \"" : "",
 			  !is_orphan(pv) ? pv_vg_name(pv) : "",
--- LVM2/tools/pvremove.c	2007/06/15 22:16:55	1.17
+++ LVM2/tools/pvremove.c	2007/06/28 17:33:44	1.18
@@ -62,7 +62,7 @@
 	}
 
 	if (arg_count(cmd, force_ARG)) {
-		log_print("WARNING: Wiping physical volume label from "
+		log_warn("WARNING: Wiping physical volume label from "
 			  "%s%s%s%s", name,
 			  !is_orphan(pv) ? " of volume group \"" : "",
 			  !is_orphan(pv) ? pv_vg_name(pv) : "",
--- LVM2/tools/pvresize.c	2007/06/15 22:16:55	1.11
+++ LVM2/tools/pvresize.c	2007/06/28 17:33:44	1.12
@@ -111,7 +111,7 @@
 	
 	if (params->new_size) {
 		if (params->new_size > size)
-			log_print("WARNING: %s: Overriding real size. "
+			log_warn("WARNING: %s: Overriding real size. "
 				  "You could lose data.", pv_name);
 		log_verbose("%s: Pretending size is %" PRIu64 " not %" PRIu64
 			    " sectors.", pv_name, params->new_size, pv_size(pv));
--- LVM2/tools/pvscan.c	2007/06/15 22:16:55	1.39
+++ LVM2/tools/pvscan.c	2007/06/28 17:33:44	1.40
@@ -120,7 +120,7 @@
 	}
 
 	if (arg_count(cmd, exported_ARG) || arg_count(cmd, novolumegroup_ARG))
-		log_print("WARNING: only considering physical volumes %s",
+		log_warn("WARNING: only considering physical volumes %s",
 			  arg_count(cmd, exported_ARG) ?
 			  "of exported volume group(s)" : "in no volume group");
 
--- LVM2/tools/vgcfgbackup.c	2006/05/10 17:49:25	1.21
+++ LVM2/tools/vgcfgbackup.c	2007/06/28 17:33:44	1.22
@@ -61,7 +61,7 @@
 	}
 
 	if (!consistent)
-		log_error("Warning: Volume group \"%s\" inconsistent", vg_name);
+		log_error("WARNING: Volume group \"%s\" inconsistent", vg_name);
 
 	if (arg_count(cmd, file_ARG)) {
 		if (!(filename = _expand_filename(arg_value(cmd, file_ARG),
--- LVM2/tools/vgcreate.c	2007/03/09 20:47:41	1.48
+++ LVM2/tools/vgcreate.c	2007/06/28 17:33:44	1.49
@@ -95,12 +95,12 @@
 		return ECMD_FAILED;
 
 	if (max_lv != vg->max_lv)
-		log_error("Warning: Setting maxlogicalvolumes to %d "
-			  "(0 means unlimited)", vg->max_lv);
+		log_warn("WARNING: Setting maxlogicalvolumes to %d "
+			 "(0 means unlimited)", vg->max_lv);
 
 	if (max_pv != vg->max_pv)
-		log_error("Warning: Setting maxphysicalvolumes to %d "
-			  "(0 means unlimited)", vg->max_pv);
+		log_warn("WARNING: Setting maxphysicalvolumes to %d "
+			 "(0 means unlimited)", vg->max_pv);
 
 	if (arg_count(cmd, addtag_ARG)) {
 		if (!(tag = arg_str_value(cmd, addtag_ARG, NULL))) {


