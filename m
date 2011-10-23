From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Oct 2011 16:05:46 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import_vsn1.c
Message-ID: <20111023160546.29538.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-23 16:05:45

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import_vsn1.c 

Log message:
	Drop mempool parameter from read functions
	
	Use implicit vgmem pool.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2169&r2=1.2170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/WHATS_NEW	2011/10/23 16:02:01	1.2169
+++ LVM2/WHATS_NEW	2011/10/23 16:05:45	1.2170
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Use vg memory pool implicitely for vg read.
   Always use vg memory pool for allocated lv segment.
   Remove extra 4kB buffer allocated on stack in print_log().
   Make move_lv_segment non-static function and use dm_list function.
--- LVM2/lib/format_text/import_vsn1.c	2011/10/23 16:02:02	1.94
+++ LVM2/lib/format_text/import_vsn1.c	2011/10/23 16:05:45	1.95
@@ -25,7 +25,7 @@
 #include "text_import.h"
 #include "defaults.h"
 
-typedef int (*section_fn) (struct format_instance * fid, struct dm_pool * mem,
+typedef int (*section_fn) (struct format_instance * fid,
 			   struct volume_group * vg, const struct dm_config_node * pvn,
 			   const struct dm_config_node * vgn,
 			   struct dm_hash_table * pv_hash,
@@ -148,7 +148,7 @@
 	return 1;
 }
 
-static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
+static int _read_pv(struct format_instance *fid,
 		    struct volume_group *vg, const struct dm_config_node *pvn,
 		    const struct dm_config_node *vgn __attribute__((unused)),
 		    struct dm_hash_table *pv_hash,
@@ -156,6 +156,7 @@
 		    unsigned *scan_done_once,
 		    unsigned report_missing_devices)
 {
+	struct dm_pool *mem = vg->vgmem;
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	const struct dm_config_value *cv;
@@ -285,10 +286,10 @@
 	dm_list_add(&lv->segments, &seg->list);
 }
 
-static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
-			 struct logical_volume *lv, const struct dm_config_node *sn,
+static int _read_segment(struct logical_volume *lv, const struct dm_config_node *sn,
 			 struct dm_hash_table *pv_hash)
 {
+	struct dm_pool *mem = lv->vg->vgmem;
 	uint32_t area_count = 0u;
 	struct lv_segment *seg;
 	const struct dm_config_node *sn_child = sn->child;
@@ -321,7 +322,7 @@
 		return 0;
 	}
 
-	if (!(segtype = get_segtype_from_string(vg->cmd, segtype_str)))
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, segtype_str)))
 		return_0;
 
 	if (segtype->ops->text_import_area_count &&
@@ -343,7 +344,7 @@
 	if (dm_config_get_list(sn_child, "tags", &cv) &&
 	    !(read_tags(mem, &seg->tags, cv))) {
 		log_error("Couldn't read tags for a segment of %s/%s.",
-			  vg->name, lv->name);
+			  lv->vg->name, lv->name);
 		return 0;
 	}
 
@@ -430,8 +431,7 @@
 	return 1;
 }
 
-static int _read_segments(struct dm_pool *mem, struct volume_group *vg,
-			  struct logical_volume *lv, const struct dm_config_node *lvn,
+static int _read_segments(struct logical_volume *lv, const struct dm_config_node *lvn,
 			  struct dm_hash_table *pv_hash)
 {
 	const struct dm_config_node *sn;
@@ -443,7 +443,7 @@
 		 * All sub-sections are assumed to be segments.
 		 */
 		if (!sn->v) {
-			if (!_read_segment(mem, vg, lv, sn, pv_hash))
+			if (!_read_segment(lv, sn, pv_hash))
 				return_0;
 
 			count++;
@@ -483,7 +483,6 @@
 }
 
 static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
-			 struct dm_pool *mem,
 			 struct volume_group *vg, const struct dm_config_node *lvn,
 			 const struct dm_config_node *vgn __attribute__((unused)),
 			 struct dm_hash_table *pv_hash __attribute__((unused)),
@@ -491,6 +490,7 @@
 			 unsigned *scan_done_once __attribute__((unused)),
 			 unsigned report_missing_devices __attribute__((unused)))
 {
+	struct dm_pool *mem = vg->vgmem;
 	struct logical_volume *lv;
 	const char *lv_alloc;
 	const struct dm_config_value *cv;
@@ -552,7 +552,6 @@
 }
 
 static int _read_lvsegs(struct format_instance *fid __attribute__((unused)),
-			struct dm_pool *mem,
 			struct volume_group *vg, const struct dm_config_node *lvn,
 			const struct dm_config_node *vgn __attribute__((unused)),
 			struct dm_hash_table *pv_hash,
@@ -581,7 +580,7 @@
 
 	memcpy(&lv->lvid.id[0], &lv->vg->id, sizeof(lv->lvid.id[0]));
 
-	if (!_read_segments(mem, vg, lv, lvn, pv_hash))
+	if (!_read_segments(lv, lvn, pv_hash))
 		return_0;
 
 	lv->size = (uint64_t) lv->le_count * (uint64_t) vg->extent_size;
@@ -606,7 +605,6 @@
 
 static int _read_sections(struct format_instance *fid,
 			  const char *section, section_fn fn,
-			  struct dm_pool *mem,
 			  struct volume_group *vg, const struct dm_config_node *vgn,
 			  struct dm_hash_table *pv_hash,
 			  struct dm_hash_table *lv_hash,
@@ -627,7 +625,7 @@
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(fid, mem, vg, n, vgn, pv_hash, lv_hash,
+		if (!fn(fid, vg, n, vgn, pv_hash, lv_hash,
 			scan_done_once, report_missing_devices))
 			return_0;
 	}
@@ -728,7 +726,7 @@
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "physical_volumes", _read_pv, vg->vgmem, vg,
+	if (!_read_sections(fid, "physical_volumes", _read_pv, vg,
 			    vgn, pv_hash, lv_hash, 0, &scan_done_once)) {
 		log_error("Couldn't find all physical volumes for volume "
 			  "group %s.", vg->name);
@@ -751,15 +749,15 @@
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "logical_volumes", _read_lvnames, vg->vgmem,
-			    vg, vgn, pv_hash, lv_hash, 1, NULL)) {
+	if (!_read_sections(fid, "logical_volumes", _read_lvnames, vg,
+			    vgn, pv_hash, lv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volume names for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, vg->vgmem,
-			    vg, vgn, pv_hash, lv_hash, 1, NULL)) {
+	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, vg,
+			    vgn, pv_hash, lv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volumes for "
 			  "volume group %s.", vg->name);
 		goto bad;


