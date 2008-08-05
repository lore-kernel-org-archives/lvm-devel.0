From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Aug 2008 12:05:27 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
Message-ID: <20080805120527.12988.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-05 12:05:26

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	.              : WHATS_NEW 

Log message:
	vgremove tries to remove lv snapshot first.
	Added function lv_remove_with_dependencies().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.184&r2=1.185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.943&r2=1.944

--- LVM2/lib/metadata/lv_manip.c	2008/04/22 12:54:33	1.154
+++ LVM2/lib/metadata/lv_manip.c	2008/08/05 12:05:25	1.155
@@ -2049,6 +2049,27 @@
 }
 
 /*
+ * remove LVs with its dependencies - LV leaf nodes should be removed first
+ */
+int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
+				const force_t force)
+{
+	struct list *snh, *snht;
+
+        if (lv_is_origin(lv)) {
+		/* remove snapshot LVs first */
+		list_iterate_safe(snh, snht, &lv->snapshot_segs) {
+			if (!lv_remove_with_dependencies(cmd, list_struct_base(snh, struct lv_segment,
+									       origin_list)->cow,
+							 force))
+				return 0;
+		}
+	}
+
+        return lv_remove_single(cmd, lv, force);
+}
+
+/*
  * insert_layer_for_segments_on_pv() inserts a layer segment for a segment area.
  * However, layer modification could split the underlying layer segment.
  * This function splits the parent area according to keep the 1:1 relationship
--- LVM2/lib/metadata/metadata-exported.h	2008/06/24 20:10:31	1.49
+++ LVM2/lib/metadata/metadata-exported.h	2008/08/05 12:05:25	1.50
@@ -416,6 +416,9 @@
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		     force_t force);
 
+int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
+				force_t force);
+
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name);
 
--- LVM2/lib/metadata/metadata.c	2008/06/27 15:18:31	1.184
+++ LVM2/lib/metadata/metadata.c	2008/08/05 12:05:25	1.185
@@ -298,8 +298,8 @@
 {
 	struct lv_list *lvl;
 
-	list_iterate_items(lvl, &vg->lvs)
-		if (!lv_remove_single(cmd, lvl->lv, force))
+        while ((lvl = list_first(&vg->lvs)))
+		if (!lv_remove_with_dependencies(cmd, lvl->lv, force))
 			return 0;
 
 	return 1;
--- LVM2/WHATS_NEW	2008/08/01 19:51:27	1.943
+++ LVM2/WHATS_NEW	2008/08/05 12:05:26	1.944
@@ -1,5 +1,7 @@
 Version 2.02.40 - 
 ================================
+  vgremove tries to remove lv snapshot first.
+  Added function lv_remove_with_dependencies().
   Improve file descriptor leak detection to display likely culprit and filename.
   Change clustered mirror kernel module name from cmirror to dm-log-clustered.
   Avoid looping forever in _pv_analyze_mda_raw used by pvck.


