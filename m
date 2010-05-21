From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 12:21:54 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c tools/toollib ...
Message-ID: <20100521122154.4914.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 12:21:52

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c toollib.h vgdisplay.c 

Log message:
	API change for args of process_each_lv_in_vg()
	
	Patch adds failed_lvnames to the list of parameters for process_each_lv_in_vg().
	If the list is not NULL it will be filled with LV names of failing LVs
	during function execution.
	
	Application could later reiterate only on failed LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1575&r2=1.1576
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.198&r2=1.199
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2010/05/21 12:19:22	1.1575
+++ LVM2/WHATS_NEW	2010/05/21 12:21:51	1.1576
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Extend process_each_lv_in_vg() with support for list of failed lvnames.
   Return ECMD_FAILED for break in process_each_lv() and process_each_segment_in_lv().
 
 Version 2.02.66 - 20th May 2010
--- LVM2/tools/toollib.c	2010/05/21 12:19:22	1.198
+++ LVM2/tools/toollib.c	2010/05/21 12:21:52	1.199
@@ -86,6 +86,7 @@
 			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
+			  struct dm_list *failed_lvnames,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv)
 {
@@ -96,7 +97,7 @@
 	unsigned tags_supplied = 0;
 	unsigned lvargs_supplied = 0;
 	unsigned lvargs_matched = 0;
-
+	char *lv_name;
 	struct lv_list *lvl;
 
 	if (!vg_check_status(vg, EXPORTED_VG))
@@ -155,6 +156,14 @@
 			continue;
 
 		ret = process_single_lv(cmd, lvl->lv, handle);
+		if (ret != ECMD_PROCESSED && failed_lvnames) {
+			lv_name = dm_pool_strdup(cmd->mem, lvl->lv->name);
+			if (!lv_name ||
+			    !str_list_add(cmd->mem, failed_lvnames, lv_name)) {
+				log_error("Allocation failed for str_list.");
+				return ECMD_FAILED;
+			}
+		}
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -325,7 +334,7 @@
 		}
 
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
-					    handle, process_single_lv);
+					    NULL, handle, process_single_lv);
 		unlock_and_release_vg(cmd, vg, vgname);
 		if (ret > ret_max)
 			ret_max = ret;
--- LVM2/tools/toollib.h	2010/04/13 23:57:41	1.73
+++ LVM2/tools/toollib.h	2010/05/21 12:21:52	1.74
@@ -78,6 +78,7 @@
 			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
+			  struct dm_list *failed_lvnames,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv);
 
--- LVM2/tools/vgdisplay.c	2009/10/26 14:37:09	1.27
+++ LVM2/tools/vgdisplay.c	2010/05/21 12:21:52	1.28
@@ -37,7 +37,7 @@
 	if (arg_count(cmd, verbose_ARG)) {
 		vgdisplay_extents(vg);
 
-		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
+		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL, NULL,
 				      (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");


