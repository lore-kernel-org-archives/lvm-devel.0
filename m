From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jul 2011 00:29:46 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20110706002946.17922.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-06 00:29:45

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Cope with a PV only discovered missing when creating deptree.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2036&r2=1.2037
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.225&r2=1.226

--- LVM2/WHATS_NEW	2011/07/05 23:10:14	1.2036
+++ LVM2/WHATS_NEW	2011/07/06 00:29:44	1.2037
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Cope with a PV only discovered missing when creating deptree.
   Abort operation if dm_tree_node_add_target_area fails.
   Add activation/checks to lvm.conf to perform additional ioctl validation.
   When suspending, automatically preload newly-visible existing LVs.
--- LVM2/lib/activate/dev_manager.c	2011/07/05 23:10:15	1.225
+++ LVM2/lib/activate/dev_manager.c	2011/07/06 00:29:45	1.226
@@ -1194,13 +1194,21 @@
 	uint64_t extent_size = seg->lv->vg->extent_size;
 	uint32_t s;
 	char *dlid;
+	struct stat info;
+	const char *name;
 
+	/* FIXME Avoid repeating identical stat in dm_tree_node_add_target_area */
 	for (s = start_area; s < areas; s++) {
 		if ((seg_type(seg, s) == AREA_PV &&
-		     (!seg_pvseg(seg, s) ||
-		      !seg_pv(seg, s) ||
-		      !seg_dev(seg, s))) ||
+		     (!seg_pvseg(seg, s) || !seg_pv(seg, s) || !seg_dev(seg, s) ||
+		       !(name = dev_name(seg_dev(seg, s))) || !*name ||
+		       stat(name, &info) < 0 || !S_ISBLK(info.st_mode))) ||
 		    (seg_type(seg, s) == AREA_LV && !seg_lv(seg, s))) {
+			if (!seg->lv->vg->cmd->partial_activation) {
+				log_error("Aborting.  LV %s is now incomplete "
+					  "and --partial was not specified.", seg->lv->name);
+				return 0;
+			}
 			if (!_add_error_area(dm, node, seg, s))
 				return_0;
 		} else if (seg_type(seg, s) == AREA_PV) {


