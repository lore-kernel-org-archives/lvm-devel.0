From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 23 Apr 2010 19:27:12 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20100423192712.25114.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-04-23 19:27:11

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	test           : t-snapshot-merge.sh 
	tools          : lvremove.c 

Log message:
	Disallow the direct removal of a merging snapshot.
	
	Allow lv_remove_with_dependencies() to know the top-level LV that was
	requested to be removed (otherwise it recurses and we lose context).
	
	A merging snapshot cannot be removed directly but the associated origin
	can be.  Disallow removal of a merging snapshot unless the associated
	origin is also being removed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1536&r2=1.1537
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.228&r2=1.229
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.337&r2=1.338
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2010/04/23 14:16:32	1.1536
+++ LVM2/WHATS_NEW	2010/04/23 19:27:10	1.1537
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Disallow the direct removal of a merging snapshot.
   Set appropriate udev flags for reserved LVs.
   Don't preload the origin when removing a snapshot whose merge is pending.
   Disallow the addition of mirror images while a conversion is happening.
--- LVM2/lib/metadata/lv_manip.c	2010/04/09 01:00:11	1.228
+++ LVM2/lib/metadata/lv_manip.c	2010/04/23 19:27:10	1.229
@@ -2306,16 +2306,25 @@
  * remove LVs with its dependencies - LV leaf nodes should be removed first
  */
 int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
-				const force_t force)
+				const force_t force, unsigned level)
 {
 	struct dm_list *snh, *snht;
 
-        if (lv_is_origin(lv)) {
+	if (lv_is_cow(lv)) {
+		/* A merging snapshot cannot be removed directly */
+		if (lv_is_merging_cow(lv) && !level) {
+			log_error("Can't remove merging snapshot logical volume \"%s\"",
+				  lv->name);
+			return 0;
+		}
+	}
+
+	if (lv_is_origin(lv)) {
 		/* remove snapshot LVs first */
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs) {
 			if (!lv_remove_with_dependencies(cmd, dm_list_struct_base(snh, struct lv_segment,
-									       origin_list)->cow,
-							 force))
+										  origin_list)->cow,
+							 force, level + 1))
 				return 0;
 		}
 	}
--- LVM2/lib/metadata/metadata-exported.h	2010/04/14 13:09:17	1.142
+++ LVM2/lib/metadata/metadata-exported.h	2010/04/23 19:27:10	1.143
@@ -534,7 +534,7 @@
 		     force_t force);
 
 int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
-				force_t force);
+				force_t force, unsigned level);
 
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name);
--- LVM2/lib/metadata/metadata.c	2010/04/14 13:09:17	1.337
+++ LVM2/lib/metadata/metadata.c	2010/04/23 19:27:10	1.338
@@ -484,7 +484,7 @@
 
 	while ((lst = dm_list_first(&vg->lvs))) {
 		lvl = dm_list_item(lst, struct lv_list);
-		if (!lv_remove_with_dependencies(cmd, lvl->lv, force))
+		if (!lv_remove_with_dependencies(cmd, lvl->lv, force, 0))
 		    return 0;
 	}
 
--- LVM2/test/t-snapshot-merge.sh	2010/04/23 02:57:43	1.5
+++ LVM2/test/t-snapshot-merge.sh	2010/04/23 19:27:11	1.6
@@ -44,17 +44,22 @@
 aux prepare_vg 1 100
 
 
-# full merge of a single LV
+# test full merge of a single LV
 setup_merge $vg $lv1
-
 # now that snapshot LV is created: test if snapshot-merge target is available
 $(dmsetup targets | grep -q snapshot-merge) || exit 200
-
 lvs -a
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
 
+# test that an actively merging snapshot may not be removed
+setup_merge $vg $lv1
+lvconvert -i+100 --merge --background $vg/$(snap_lv_name_ $lv1)
+not lvremove -f $vg/$(snap_lv_name_ $lv1)
+lvremove -f $vg/$lv1
+
+
 # "onactivate merge" test
 setup_merge $vg $lv1
 lvs -a
@@ -99,6 +104,7 @@
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
+
 # test merging multiple snapshots that share the same tag
 setup_merge $vg $lv1
 setup_merge $vg $lv2
--- LVM2/tools/lvremove.c	2009/09/14 22:47:49	1.59
+++ LVM2/tools/lvremove.c	2010/04/23 19:27:11	1.60
@@ -26,7 +26,7 @@
         if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
                 lv = origin;
 
-	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG))) {
+	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG), 0)) {
 		stack;
 		return ECMD_FAILED;
 	}


