From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 19 Jul 2011 16:37:43 -0000
Subject: LVM2/lib/metadata lv_alloc.h lv_manip.c mirror.c
Message-ID: <20110719163743.24421.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-07-19 16:37:42

Modified files:
	lib/metadata   : lv_alloc.h lv_manip.c mirror.c 

Log message:
	Remove and unneeded parameter from build_parallel_areas_from_lv()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.267&r2=1.268
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158

--- LVM2/lib/metadata/lv_alloc.h	2010/04/08 00:28:58	1.28
+++ LVM2/lib/metadata/lv_alloc.h	2011/07/19 16:37:42	1.29
@@ -76,8 +76,7 @@
 
 void alloc_destroy(struct alloc_handle *ah);
 
-struct dm_list *build_parallel_areas_from_lv(struct cmd_context *cmd,
-					     struct logical_volume *lv,
+struct dm_list *build_parallel_areas_from_lv(struct logical_volume *lv,
 					     unsigned use_pvmove_parent_lv);
 
 #endif
--- LVM2/lib/metadata/lv_manip.c	2011/07/08 12:48:41	1.267
+++ LVM2/lib/metadata/lv_manip.c	2011/07/19 16:37:42	1.268
@@ -2575,10 +2575,10 @@
  * Construct dm_list of segments of LVs showing which PVs they use.
  * For pvmove we use the *parent* LV so we can pick up stripes & existing mirrors etc.
  */
-struct dm_list *build_parallel_areas_from_lv(struct cmd_context *cmd,
-					     struct logical_volume *lv,
+struct dm_list *build_parallel_areas_from_lv(struct logical_volume *lv,
 					     unsigned use_pvmove_parent_lv)
 {
+	struct cmd_context *cmd = lv->vg->cmd;
 	struct dm_list *parallel_areas;
 	struct seg_pvs *spvs;
 	uint32_t current_le = 0;
@@ -2866,7 +2866,7 @@
 	uint32_t s;
 	struct dm_list *parallel_areas;
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, layer_lv, 0)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(layer_lv, 0)))
 		return_0;
 
 	/* Loop through all LVs except itself */
--- LVM2/lib/metadata/mirror.c	2011/06/24 23:39:09	1.157
+++ LVM2/lib/metadata/mirror.c	2011/07/19 16:37:42	1.158
@@ -1624,7 +1624,7 @@
 	uint32_t adjusted_region_size;
 	int r = 1;
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv, 1)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 1)))
 		return_0;
 
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
@@ -1876,7 +1876,7 @@
 		return 1;
 	}
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv, 0)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0)))
 		return_0;
 
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
@@ -1948,7 +1948,7 @@
 	 * allocate destination extents
 	 */
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv, 0)))
+	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0)))
 		return_0;
 
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))


