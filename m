From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jul 2009 05:50:24 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090715055024.6365.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-07-15 05:50:22

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : pvdisplay.c pvresize.c reporter.c toollib.c 
	                 vgreduce.c 

Log message:
	Port process_each_pv to new vg_read.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.252&r2=1.253
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/lib/metadata/metadata-exported.h	2009/07/14 03:00:30	1.93
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/15 05:50:22	1.94
@@ -95,6 +95,7 @@
 /* vg_read and vg_read_for_update flags */
 #define READ_ALLOW_INCONSISTENT	0x00010000U
 #define READ_ALLOW_EXPORTED	0x00020000U
+#define READ_WITHOUT_LOCK       0x00040000U
 
 /* A meta-flag, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE 	0x00100000U
--- LVM2/lib/metadata/metadata.c	2009/07/15 05:49:48	1.252
+++ LVM2/lib/metadata/metadata.c	2009/07/15 05:50:22	1.253
@@ -2897,7 +2897,8 @@
 	lock_name = is_orphan_vg(vg_name) ? VG_ORPHANS : vg_name;
 	already_locked = vgname_is_locked(lock_name);
 
-	if (!already_locked && !lock_vol(cmd, lock_name, lock_flags)) {
+	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK) &&
+	    !lock_vol(cmd, lock_name, lock_flags)) {
 		log_error("Can't get lock for %s", vg_name);
 		return _vg_make_handle(cmd, vg, FAILED_LOCKING);
 	}
@@ -2953,7 +2954,7 @@
 	return _vg_make_handle(cmd, vg, failure);
 
 bad:
-	if (!already_locked)
+	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK))
 		unlock_vg(cmd, lock_name);
 
 	return _vg_make_handle(cmd, vg, failure);
--- LVM2/tools/pvdisplay.c	2009/07/01 16:59:37	1.52
+++ LVM2/tools/pvdisplay.c	2009/07/15 05:50:22	1.53
@@ -113,6 +113,6 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ, 0, NULL,
+	return process_each_pv(cmd, argc, argv, NULL, 0, 0, NULL,
 			       _pvdisplay_single);
 }
--- LVM2/tools/pvresize.c	2009/07/07 01:18:35	1.31
+++ LVM2/tools/pvresize.c	2009/07/15 05:50:22	1.32
@@ -205,7 +205,7 @@
 	params.done = 0;
 	params.total = 0;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, LCK_VG_WRITE, 0, &params,
+	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, 0, &params,
 			      _pvresize_single);
 
 	log_print("%d physical volume(s) resized / %d physical volume(s) "
--- LVM2/tools/reporter.c	2009/07/01 17:00:52	1.53
+++ LVM2/tools/reporter.c	2009/07/15 05:50:22	1.54
@@ -378,12 +378,12 @@
 				    report_handle, &_vgs_single);
 		break;
 	case LABEL:
-		r = process_each_pv(cmd, argc, argv, NULL, LCK_NONE,
+		r = process_each_pv(cmd, argc, argv, NULL, READ_WITHOUT_LOCK,
 				    1, report_handle, &_label_single);
 		break;
 	case PVS:
 		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
+			r = process_each_pv(cmd, argc, argv, NULL, 0,
 					    0, report_handle, &_pvs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, 0,
@@ -395,7 +395,7 @@
 		break;
 	case PVSEGS:
 		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
+			r = process_each_pv(cmd, argc, argv, NULL, 0,
 					    0, report_handle, &_pvsegs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, 0,
--- LVM2/tools/toollib.c	2009/07/15 05:23:19	1.161
+++ LVM2/tools/toollib.c	2009/07/15 05:50:22	1.162
@@ -615,7 +615,7 @@
  * This can pause alongide pvscan or vgscan process for a while.
  */
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    struct volume_group *vg, uint32_t lock_type,
+		    struct volume_group *vg, uint32_t flags,
 		    int scan_label_only, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct volume_group * vg,
@@ -625,7 +625,7 @@
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
-	int lock_global = lock_type == LCK_VG_READ;
+	int lock_global = !(flags & READ_WITHOUT_LOCK) && !(flags & READ_FOR_UPDATE);
 
 	struct pv_list *pvl;
 	struct physical_volume *pv;
@@ -633,12 +633,11 @@
 	struct dm_list tags;
 	struct str_list *sll;
 	char *tagname;
-	int consistent = 1;
 	int scanned = 0;
 
 	dm_list_init(&tags);
 
-	if (lock_global && !lock_vol(cmd, VG_GLOBAL, lock_type)) {
+	if (lock_global && !lock_vol(cmd, VG_GLOBAL, LCK_READ)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
@@ -719,26 +718,11 @@
 		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
-				if (!lock_vol(cmd, sll->str, lock_type)) {
-					log_error("Can't lock %s: skipping", sll->str);
+				vg = vg_read(cmd, sll->str, NULL, flags);
+				if (vg_read_error(vg)) {
 					ret_max = ECMD_FAILED;
 					continue;
 				}
-				if (!(vg = vg_read_internal(cmd, sll->str, NULL, &consistent))) {
-					log_error("Volume group \"%s\" not found", sll->str);
-					unlock_vg(cmd, sll->str);
-					ret_max = ECMD_FAILED;
-					continue;
-				}
-				if (!consistent) {
-					unlock_and_release_vg(cmd, vg, sll->str);
-					continue;
-				}
-
-				if (!vg_check_status(vg, CLUSTERED)) {
-					unlock_and_release_vg(cmd, vg, sll->str);
-					continue;
-				}
 
 				ret = process_each_pv_in_vg(cmd, vg, &tags,
 							    handle,
--- LVM2/tools/vgreduce.c	2009/07/15 05:47:55	1.95
+++ LVM2/tools/vgreduce.c	2009/07/15 05:50:22	1.96
@@ -573,7 +573,7 @@
 
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch here? */
-		ret = process_each_pv(cmd, argc, argv, vg, LCK_NONE, 0, NULL,
+		ret = process_each_pv(cmd, argc, argv, vg, READ_FOR_UPDATE, 0, NULL,
 				      _vgreduce_single);
 
 	}


