From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Dec 2007 12:13:31 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c man/lvc ...
Message-ID: <20071222121331.2504.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-22 12:13:30

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 
	man            : lvconvert.8 
	tools          : commands.h lvconvert.c polldaemon.c 
	                 polldaemon.h pvmove.c 

Log message:
	lvconvert uses polldaemon now

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.748&r2=1.749
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/WHATS_NEW	2007/12/20 18:55:46	1.748
+++ LVM2/WHATS_NEW	2007/12/22 12:13:29	1.749
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Extend lvconvert to use polldaemon.
   Add support for stacked mirrors.
   Major restructuring of pvmove and lvconvert layer manipulation code.
   Replace tools/fsadm with scripts/fsadm.sh.
--- LVM2/lib/metadata/mirror.c	2007/12/22 02:12:59	1.50
+++ LVM2/lib/metadata/mirror.c	2007/12/22 12:13:29	1.51
@@ -1068,6 +1068,8 @@
 						 int in_sync)
 {
 	struct logical_volume *log_lv;
+	const char *suffix;
+	struct lv_segment *seg;
 
 	init_mirror_in_sync(in_sync);
 
@@ -1076,9 +1078,15 @@
 		return NULL;
 	}
 
-	if (!(log_lv = _create_mirror_log(lv, ah, alloc, lv->name,
-					  strstr(lv->name, MIRROR_SYNC_LAYER)
-						? "_mlogtmp_%d" : "_mlog"))) {
+	/* Check if the log is for temporary sync layer. */
+	seg = first_seg(lv);
+	if (seg_type(seg, 0) == AREA_LV &&
+	    strstr(seg_lv(seg, 0)->name, MIRROR_SYNC_LAYER))
+		suffix = "_mlogtmp_%d";
+	else
+		suffix = "_mlog";
+
+	if (!(log_lv = _create_mirror_log(lv, ah, alloc, lv->name, suffix))) {
 		log_error("Failed to create mirror log.");
 		return NULL;
 	}
--- LVM2/man/lvconvert.8	2007/08/30 19:34:19	1.9
+++ LVM2/man/lvconvert.8	2007/12/22 12:13:29	1.10
@@ -5,6 +5,7 @@
 .B lvconvert
 \-m/\-\-mirrors Mirrors [\-\-mirrorlog {disk|core}] [\-\-corelog] [\-R/\-\-regionsize MirrorLogRegionSize]
 [\-A/\-\-alloc AllocationPolicy]
+[\-b/\-\-background] [\-i/\-\-interval Seconds]
 [\-h/\-?/\-\-help]
 [\-v/\-\-verbose]
 [\-\-version]
@@ -52,6 +53,12 @@
 .I \-R, \-\-regionsize MirrorLogRegionSize
 A mirror is divided into regions of this size (in MB), and the mirror log
 uses this granularity to track which regions are in sync.
+.TP
+.I \-b, \-\-background
+Run the daemon in the background.
+.TP
+.I \-i, \-\-interval Seconds
+Report progress as a percentage at regular intervals.
 .br
 .TP
 .I \-s, \-\-snapshot
--- LVM2/tools/commands.h	2007/11/09 16:51:54	1.104
+++ LVM2/tools/commands.h	2007/12/22 12:13:29	1.105
@@ -91,8 +91,10 @@
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
+   "\t[-b|--background]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
+   "\t[-i|--interval seconds]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\tLogicalVolume[Path] [PhysicalVolume[Path]...]\n\n"
@@ -107,8 +109,8 @@
    "\t[--version]" "\n"
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
-   alloc_ARG, chunksize_ARG, corelog_ARG, mirrorlog_ARG, mirrors_ARG,
-   regionsize_ARG, snapshot_ARG, test_ARG, zero_ARG)
+   alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
+   mirrorlog_ARG, mirrors_ARG, regionsize_ARG, snapshot_ARG, test_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
--- LVM2/tools/lvconvert.c	2007/12/22 02:13:00	1.51
+++ LVM2/tools/lvconvert.c	2007/12/22 12:13:29	1.52
@@ -13,6 +13,7 @@
  */
 
 #include "tools.h"
+#include "polldaemon.h"
 #include "lv_alloc.h"
 
 struct lvconvert_params {
@@ -21,7 +22,9 @@
 
 	const char *origin;
 	const char *lv_name;
+	const char *lv_name_full;
 	const char *vg_name;
+	int wait_daemon;
 
 	uint32_t chunk_size;
 	uint32_t region_size;
@@ -70,11 +73,11 @@
 		return 0;
 	}
 
-	lp->lv_name = (*pargv)[0];
+	lp->lv_name = lp->lv_name_full = (*pargv)[0];
 	(*pargv)++, (*pargc)--;
 
-	if (strchr(lp->lv_name, '/') &&
-	    (vg_name = extract_vgname(cmd, lp->lv_name)) &&
+	if (strchr(lp->lv_name_full, '/') &&
+	    (vg_name = extract_vgname(cmd, lp->lv_name_full)) &&
 	    lp->vg_name && strcmp(vg_name, lp->vg_name)) {
 		log_error("Please use a single volume group name "
 			  "(\"%s\" or \"%s\")", vg_name, lp->vg_name);
@@ -89,7 +92,7 @@
 		return 0;
 	}
 
-	if ((ptr = strrchr(lp->lv_name, '/')))
+	if ((ptr = strrchr(lp->lv_name_full, '/')))
 		lp->lv_name = ptr + 1;
 
 	if (!apply_lvname_restrictions(lp->lv_name))
@@ -227,6 +230,90 @@
 	return 1;
 }
 
+
+static struct volume_group *_get_lvconvert_vg(struct cmd_context *cmd,
+					      const char *lv_name)
+{
+        dev_close_all();
+
+        return vg_lock_and_read(cmd, extract_vgname(cmd, lv_name),
+				NULL, LCK_VG_WRITE,
+ 				CLUSTERED | EXPORTED_VG | LVM_WRITE,
+				CORRECT_INCONSISTENT | FAIL_INCONSISTENT);
+}
+
+static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute((unused)),
+						struct volume_group *vg,
+						const char *name,
+						uint32_t lv_type __attribute((unused)))
+{
+	return find_lv(vg, name);
+}
+
+static int _update_lvconvert_mirror(struct cmd_context *cmd __attribute((unused)),
+				    struct volume_group *vg __attribute((unused)),
+				    struct logical_volume *lv __attribute((unused)),
+				    struct list *lvs_changed __attribute((unused)),
+				    int first_time __attribute((unused)))
+{
+	/* lvconvert mirror doesn't require periodical metadata update */
+	return 1;
+}
+
+static int _finish_lvconvert_mirror(struct cmd_context *cmd,
+				    struct volume_group *vg,
+				    struct logical_volume *lv,
+				    struct list *lvs_changed __attribute((unused)))
+{
+	if (!collapse_mirrored_lv(lv)) {
+		log_error("Failed to remove temporary sync layer.");
+		return 0;
+	}
+
+	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
+
+	if (!vg_write(vg))
+		return_0;
+
+	backup(vg);
+
+	if (!suspend_lv(cmd, lv)) {
+		log_error("Failed to lock %s", lv->name);
+		vg_revert(vg);
+		return 0;
+	}
+
+	if (!vg_commit(vg)) {
+		resume_lv(cmd, lv);
+		return 0;
+	}
+
+	log_very_verbose("Updating \"%s\" in kernel", lv->name);
+
+	if (!resume_lv(cmd, lv)) {
+		log_error("Problem reactivating %s", lv->name);
+		return 0;
+	}
+
+	log_print("Logical volume %s converted.", lv->name);
+
+	return 1;
+}
+
+static struct poll_functions _lvconvert_mirror_fns = {
+	.get_copy_vg = _get_lvconvert_vg,
+	.get_copy_lv = _get_lvconvert_lv,
+	.update_metadata = _update_lvconvert_mirror,
+	.finish_copy = _finish_lvconvert_mirror,
+};
+
+static int _lvconvert_poll(struct cmd_context *cmd, const char *lv_name,
+			   unsigned background)
+{
+	return poll_daemon(cmd, lv_name, background, 0, &_lvconvert_mirror_fns,
+			   "Converted");
+}
+
 static int _insert_lvconvert_layer(struct cmd_context *cmd,
 				   struct logical_volume *lv)
 {
@@ -284,9 +371,8 @@
 
 	/* If called with no argument, try collapsing the resync layers */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG)) {
-		if (!collapse_mirrored_lv(lv))
-			return_0;
-		goto commit_changes;
+		lp->wait_daemon = 1;
+		return 1;
 	}
 
 	/*
@@ -439,6 +525,7 @@
 				    corelog ? 0U : 1U, lp->pvh, lp->alloc,
 				    MIRROR_BY_LV))
 			return_0;
+		lp->wait_daemon = 1;
 	} else {
 		/* Reduce number of mirrors */
 		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
@@ -472,7 +559,8 @@
 		return 0;
 	}
 
-	log_print("Logical volume %s converted.", lv->name);
+	if (!lp->wait_daemon)
+		log_print("Logical volume %s converted.", lv->name);
 
 	return 1;
 }
@@ -625,5 +713,9 @@
 
 error:
 	unlock_vg(cmd, lp.vg_name);
+
+	if (lp.wait_daemon)
+		ret = _lvconvert_poll(cmd, lp.lv_name_full,
+				      arg_count(cmd, background_ARG) ? 1U : 0);
 	return ret;
 }
--- LVM2/tools/polldaemon.c	2007/08/20 20:55:30	1.8
+++ LVM2/tools/polldaemon.c	2007/12/22 12:13:29	1.9
@@ -93,9 +93,11 @@
 
 	overall_percent = copy_percent(lv_mirr);
 	if (parms->progress_display)
-		log_print("%s: Moved: %.1f%%", name, overall_percent);
+		log_print("%s: %s: %.1f%%", name, parms->progress_title,
+			  overall_percent);
 	else
-		log_verbose("%s: Moved: %.1f%%", name, overall_percent);
+		log_verbose("%s: %s: %.1f%%", name, parms->progress_title,
+			    overall_percent);
 
 	if (segment_percent < 100.0) {
 		/* The only case the caller *should* try again later */
@@ -224,7 +226,8 @@
 }
 
 int poll_daemon(struct cmd_context *cmd, const char *name, unsigned background,
-		uint32_t lv_type, struct poll_functions *poll_fns)
+		uint32_t lv_type, struct poll_functions *poll_fns,
+		const char *progress_title)
 {
 	struct daemon_parms parms;
 
@@ -232,6 +235,7 @@
 	parms.background = background;
 	parms.interval = arg_uint_value(cmd, interval_ARG, DEFAULT_INTERVAL);
 	parms.progress_display = 1;
+	parms.progress_title = progress_title;
 	parms.lv_type = lv_type;
 	parms.poll_fns = poll_fns;
 
--- LVM2/tools/polldaemon.h	2007/08/20 20:55:30	1.3
+++ LVM2/tools/polldaemon.h	2007/12/22 12:13:29	1.4
@@ -42,11 +42,13 @@
 	unsigned background;
 	unsigned outstanding_count;
 	unsigned progress_display;
+	const char *progress_title;
 	uint32_t lv_type;
 	struct poll_functions *poll_fns;
 };
 
 int poll_daemon(struct cmd_context *cmd, const char *name, unsigned background,
-		uint32_t lv_type, struct poll_functions *poll_fns);
+		uint32_t lv_type, struct poll_functions *poll_fns,
+		const char *progress_title);
 
 #endif
--- LVM2/tools/pvmove.c	2007/12/20 15:42:55	1.45
+++ LVM2/tools/pvmove.c	2007/12/22 12:13:29	1.46
@@ -525,7 +525,8 @@
 int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
 		unsigned background)
 {
-	return poll_daemon(cmd, pv_name, background, PVMOVE, &_pvmove_fns);
+	return poll_daemon(cmd, pv_name, background, PVMOVE, &_pvmove_fns,
+			   "Moved");
 }
 
 int pvmove(struct cmd_context *cmd, int argc, char **argv)


