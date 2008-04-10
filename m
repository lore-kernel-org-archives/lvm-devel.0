From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Apr 2008 17:09:39 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20080410170939.2786.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-10 17:09:32

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/display    : display.c 
	lib/format1    : import-export.c 
	lib/locking    : locking.h 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	lib/mirror     : mirrored.c 
	lib/report     : report.c 
	tools          : lvchange.c lvcreate.c pvmove.c vgchange.c 
	                 vgsplit.c 

Log message:
	Add vg_is_clustered() helper function.
	
	Should be no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.841&r2=1.842
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/WHATS_NEW	2008/04/09 20:56:05	1.841
+++ LVM2/WHATS_NEW	2008/04/10 17:09:29	1.842
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add vg_is_clustered() helper function.
   Fix vgsplit to only move hidden 'snapshotN' LVs when necessary.
   Update vgsplit tests for lvnames on the cmdline.
   Update vgsplit man page to reflect lvnames on the cmdline.
--- LVM2/lib/activate/dev_manager.c	2008/04/07 10:23:46	1.135
+++ LVM2/lib/activate/dev_manager.c	2008/04/10 17:09:30	1.136
@@ -836,7 +836,7 @@
 
 	/* If this is a snapshot origin, add real LV */
 	if (lv_is_origin(seg->lv) && !layer) {
-		if (seg->lv->vg->status & CLUSTERED) {
+		if (vg_is_clustered(seg->lv->vg)) {
 			log_error("Clustered snapshots are not yet supported");
 			return 0;
 		}
--- LVM2/lib/display/display.c	2008/03/26 16:48:10	1.87
+++ LVM2/lib/display/display.c	2008/04/10 17:09:31	1.88
@@ -602,7 +602,7 @@
 	/* vg number not part of LVM2 design
 	   log_print ("VG #                  %u\n", vg->vg_number);
 	 */
-	if (vg->status & CLUSTERED) {
+	if (vg_is_clustered(vg)) {
 		log_print("Clustered             yes");
 		log_print("Shared                %s",
 			  vg->status & SHARED ? "yes" : "no");
--- LVM2/lib/format1/import-export.c	2008/02/06 15:47:27	1.95
+++ LVM2/lib/format1/import-export.c	2008/04/10 17:09:31	1.96
@@ -271,7 +271,7 @@
 	if (vg->status & LVM_WRITE)
 		vgd->vg_access |= VG_WRITE;
 
-	if (vg->status & CLUSTERED)
+	if (vg_is_clustered(vg))
 		vgd->vg_access |= VG_CLUSTERED;
 
 	if (vg->status & SHARED)
--- LVM2/lib/locking/locking.h	2008/04/09 12:56:34	1.38
+++ LVM2/lib/locking/locking.h	2008/04/10 17:09:31	1.39
@@ -99,7 +99,7 @@
 #define LCK_LV_DEACTIVATE	(LCK_LV | LCK_NULL | LCK_NONBLOCK)
 
 #define LCK_LV_CLUSTERED(lv)	\
-	(((lv)->vg->status & CLUSTERED) ? LCK_CLUSTER_VG : 0)
+	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
 
 #define lock_lv_vol(cmd, lv, flags)	\
 	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv))
--- LVM2/lib/metadata/lv_manip.c	2008/03/28 19:08:23	1.152
+++ LVM2/lib/metadata/lv_manip.c	2008/04/10 17:09:31	1.153
@@ -1983,7 +1983,7 @@
 		 * 1) Clustered VG, and some remote nodes have the LV active
 		 * 2) Non-clustered VG, but LV active locally
 		 */
-		if ((vg_status(vg) & CLUSTERED) && !activate_lv_excl(cmd, lv) &&
+		if (vg_is_clustered(vg) && !activate_lv_excl(cmd, lv) &&
 		    (force == PROMPT)) {
 			if (yes_no_prompt("Logical volume \"%s\" is active on other "
 					  "cluster nodes.  Really remove? [y/n]: ",
--- LVM2/lib/metadata/metadata-exported.h	2008/03/26 16:48:10	1.46
+++ LVM2/lib/metadata/metadata-exported.h	2008/04/10 17:09:31	1.47
@@ -544,6 +544,7 @@
 uint32_t pv_pe_alloc_count(const pv_t *pv);
 
 uint32_t vg_status(const vg_t *vg);
+#define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 
 struct vgcreate_params {
 	char *vg_name;
--- LVM2/lib/metadata/metadata.c	2008/04/08 12:49:20	1.167
+++ LVM2/lib/metadata/metadata.c	2008/04/10 17:09:31	1.168
@@ -1124,7 +1124,7 @@
 	}
 
 	/* Clustering attribute must be the same */
-	if ((vg_to->status & CLUSTERED) != (vg_from->status & CLUSTERED)) {
+	if (vg_is_clustered(vg_to) != vg_is_clustered(vg_from)) {
 		log_error("Clustered attribute differs for \"%s\" and \"%s\"",
 			  vg_to->name, vg_from->name);
 		return 0;
@@ -2102,7 +2102,7 @@
 int vg_check_status(const struct volume_group *vg, uint32_t status)
 {
 	if ((status & CLUSTERED) &&
-	    (vg->status & CLUSTERED) && !locking_is_clustered() &&
+	    (vg_is_clustered(vg)) && !locking_is_clustered() &&
 	    !lockingfailed()) {
 		log_error("Skipping clustered volume group %s", vg->name);
 		return 0;
@@ -2240,7 +2240,6 @@
 	return vg->status;
 }
 
-
 /**
  * pv_by_path - Given a device path return a PV handle if it is a PV
  * @cmd - handle to the LVM command instance
--- LVM2/lib/mirror/mirrored.c	2008/04/07 10:23:46	1.53
+++ LVM2/lib/mirror/mirrored.c	2008/04/10 17:09:31	1.54
@@ -237,7 +237,7 @@
 	 * in clustered VG.
 	 */
 	if ((!(seg->lv->status & ACTIVATE_EXCL) &&
-	      (seg->lv->vg->status & CLUSTERED)))
+	      (vg_is_clustered(seg->lv->vg))))
 		clustered = 1;
 
 	if (seg->log_lv) {
@@ -519,7 +519,7 @@
 	    !list_segment_modules(mem, first_seg(seg->log_lv), modules))
 		return_0;
 
-	if ((seg->lv->vg->status & CLUSTERED) &&
+	if (vg_is_clustered(seg->lv->vg) &&
 	    !str_list_add(mem, modules, "clog")) {
 		log_error("cluster log string list allocation failed");
 		return 0;
--- LVM2/lib/report/report.c	2008/02/06 15:47:28	1.77
+++ LVM2/lib/report/report.c	2008/04/10 17:09:32	1.78
@@ -439,7 +439,7 @@
 
 	repstr[4] = _alloc_policy_char(vg->alloc);
 
-	if (vg->status & CLUSTERED)
+	if (vg_is_clustered(vg))
 		repstr[5] = 'c';
 	else
 		repstr[5] = '-';
--- LVM2/tools/lvchange.c	2008/01/30 14:00:01	1.89
+++ LVM2/tools/lvchange.c	2008/04/10 17:09:32	1.90
@@ -35,7 +35,7 @@
 		return 0;
 	}
 
-	if ((lv->status & MIRRORED) && (lv->vg->status & CLUSTERED) &&
+	if ((lv->status & MIRRORED) && (vg_is_clustered(lv->vg)) &&
 	    lv_info(cmd, lv, &info, 0, 0) && info.exists) {
 		log_error("Cannot change permissions of mirror \"%s\" "
 			  "while active.", lv->name);
@@ -119,7 +119,7 @@
 		if (!deactivate_lv(cmd, lv))
 			return_0;
 	} else {
-		if (lockingfailed() && (lv->vg->status & CLUSTERED)) {
+		if (lockingfailed() && (vg_is_clustered(lv->vg))) {
 			log_verbose("Locking failed: ignoring clustered "
 				    "logical volume %s", lv->name);
 			return 0;
@@ -221,7 +221,7 @@
 		}
 	}
 
-	if ((lv->vg->status & CLUSTERED) && !activate_lv_excl(cmd, lv)) {
+	if (vg_is_clustered(lv->vg) && !activate_lv_excl(cmd, lv)) {
 		log_error("Can't get exclusive access to clustered volume %s",
 			  lv->name);
 		return ECMD_FAILED;
@@ -236,7 +236,7 @@
 
 	log_very_verbose("Starting resync of %s%s%s mirror \"%s\"",
 			 (active) ? "active " : "",
-			 (lv->vg->status & CLUSTERED) ? "clustered " : "",
+			 vg_is_clustered(lv->vg) ? "clustered " : "",
 			 (log_lv) ? "disk-logged" : "core-logged",
 			 lv->name);
 
--- LVM2/tools/lvcreate.c	2008/04/07 10:23:47	1.173
+++ LVM2/tools/lvcreate.c	2008/04/10 17:09:32	1.174
@@ -638,7 +638,7 @@
 			return 0;
 		}
 		/* FIXME Allow exclusive activation. */
-		if (vg_status(vg) & CLUSTERED) {
+		if (vg_is_clustered(vg)) {
 			log_error("Clustered snapshots are not yet supported.");
 			return 0;
 		}
--- LVM2/tools/pvmove.c	2008/04/09 12:56:34	1.52
+++ LVM2/tools/pvmove.c	2008/04/10 17:09:32	1.53
@@ -49,7 +49,7 @@
 static unsigned _pvmove_is_exclusive(struct cmd_context *cmd,
 				     struct volume_group *vg)
 {
-	if (vg_status(vg) & CLUSTERED)
+	if (vg_is_clustered(vg))
 		if (!_pvmove_target_present(cmd, 1))
 			return 1;
 
--- LVM2/tools/vgchange.c	2008/01/30 14:00:02	1.63
+++ LVM2/tools/vgchange.c	2008/04/10 17:09:32	1.64
@@ -134,7 +134,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (activate && lockingfailed() && (vg_status(vg) & CLUSTERED)) {
+	if (activate && lockingfailed() && (vg_is_clustered(vg))) {
 		log_error("Locking inactive: ignoring clustered "
 			  "volume group %s", vg->name);
 		return ECMD_FAILED;
@@ -243,13 +243,13 @@
 	int clustered = !strcmp(arg_str_value(cmd, clustered_ARG, "n"), "y");
 	struct lv_list *lvl;
 
-	if (clustered && (vg_status(vg) & CLUSTERED)) {
+	if (clustered && (vg_is_clustered(vg))) {
 		log_error("Volume group \"%s\" is already clustered",
 			  vg->name);
 		return ECMD_FAILED;
 	}
 
-	if (!clustered && !(vg_status(vg) & CLUSTERED)) {
+	if (!clustered && !(vg_is_clustered(vg))) {
 		log_error("Volume group \"%s\" is already not clustered",
 			  vg->name);
 		return ECMD_FAILED;
--- LVM2/tools/vgsplit.c	2008/04/10 02:15:56	1.60
+++ LVM2/tools/vgsplit.c	2008/04/10 17:09:32	1.61
@@ -379,7 +379,7 @@
 					vp_new.alloc, 0, NULL)))
 			goto bad;
 
-		if (vg_from->status & CLUSTERED)
+		if (vg_is_clustered(vg_from))
 			vg_to->status |= CLUSTERED;
 	}
 


