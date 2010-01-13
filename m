From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:35:50 -0000
Subject: LVM2/lib format_text/flags.c metadata/lv_manip ...
Message-ID: <20100113013550.1831.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:35:49

Modified files:
	lib/format_text: flags.c 
	lib/metadata   : lv_manip.c metadata-exported.h snapshot_manip.c 
	lib/snapshot   : snapshot.c 

Log message:
	Add 'SNAPSHOT_MERGE' lv_segment 'status' flag.
	
	Make 'merging_snapshot' pointer that points from the origin to the
	segment that represents the merging snapshot.
	
	Import/export 'merging_store' metadata.
	
	Do not allow creating snapshots while another snapshot is merging.
	Snapshot created in this state would certainly contain invalid data.
	
	NOTE: patches at the end of this series will remove 'merging_snapshot'
	and will introduce helpful wrappers and cleanups.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.197&r2=1.198
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/lib/format_text/flags.c	2010/01/07 14:47:57	1.39
+++ LVM2/lib/format_text/flags.c	2010/01/13 01:35:49	1.40
@@ -61,6 +61,7 @@
 	{MIRRORED, NULL, 0},
 	{VIRTUAL, NULL, 0},
 	{SNAPSHOT, NULL, 0},
+	{SNAPSHOT_MERGE, NULL, 0},
 	{ACTIVATE_EXCL, NULL, 0},
 	{CONVERTING, NULL, 0},
 	{PARTIAL_LV, NULL, 0},
--- LVM2/lib/metadata/lv_manip.c	2010/01/12 20:53:20	1.197
+++ LVM2/lib/metadata/lv_manip.c	2010/01/13 01:35:49	1.198
@@ -1877,6 +1877,7 @@
 	}
 
 	lv->snapshot = NULL;
+	lv->merging_snapshot = NULL;
 	dm_list_init(&lv->snapshot_segs);
 	dm_list_init(&lv->segments);
 	dm_list_init(&lv->tags);
@@ -2941,6 +2942,11 @@
 					  "supported yet");
 				return 0;
 			}
+			if (org->merging_snapshot) {
+				log_error("Snapshots of an origin that has a "
+					  "merging snapshot is not supported");
+				return 0;
+			}
 			if ((org->status & MIRROR_IMAGE) ||
 			    (org->status & MIRROR_LOG)) {
 				log_error("Snapshots of mirror %ss "
--- LVM2/lib/metadata/metadata-exported.h	2010/01/08 22:32:35	1.125
+++ LVM2/lib/metadata/metadata-exported.h	2010/01/13 01:35:49	1.126
@@ -69,6 +69,8 @@
 //#define POSTORDER_OPEN_FLAG	0x04000000U    temporary use inside vg_read_internal. */
 //#define VIRTUAL_ORIGIN	0x08000000U	/* LV - internal use only */
 
+#define SNAPSHOT_MERGE		0x10000000U	/* SEG */
+
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
 #define CLUSTERED         	0x00000400U	/* VG */
@@ -328,6 +330,9 @@
 	struct dm_list snapshot_segs;
 	struct lv_segment *snapshot;
 
+	/* A snapshot that is merging into this origin */
+	struct lv_segment *merging_snapshot;
+
 	struct dm_list segments;
 	struct dm_list tags;
 	struct dm_list segs_using_this_lv;
@@ -624,7 +629,9 @@
 struct logical_volume *origin_from_cow(const struct logical_volume *lv);
 
 void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
-		       struct logical_volume *cow, uint32_t chunk_size);
+		       struct logical_volume *cow, uint32_t chunk_size, int merge);
+
+void init_snapshot_merge(struct lv_segment *cow_seg, struct logical_volume *origin);
 
 int vg_add_snapshot(struct logical_volume *origin, struct logical_volume *cow,
 		    union lvid *lvid, uint32_t extent_count,
--- LVM2/lib/metadata/snapshot_manip.c	2009/07/15 20:02:47	1.44
+++ LVM2/lib/metadata/snapshot_manip.c	2010/01/13 01:35:49	1.45
@@ -37,6 +37,9 @@
 		if (lv_is_virtual_origin(origin_from_cow(lv)))
 			return 1;
 
+		if (find_cow(lv)->status & SNAPSHOT_MERGE)
+			return 0;
+
 		return lv_is_visible(origin_from_cow(lv));
 	}
 
@@ -62,7 +65,7 @@
 }
 
 void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
-		       struct logical_volume *cow, uint32_t chunk_size)
+		       struct logical_volume *cow, uint32_t chunk_size, int merge)
 {
 	seg->chunk_size = chunk_size;
 	seg->origin = origin;
@@ -79,10 +82,30 @@
 		origin->status |= VIRTUAL_ORIGIN;
 
 	seg->lv->status |= (SNAPSHOT | VIRTUAL);
+	if (merge)
+		init_snapshot_merge(seg, origin);
 
 	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
 }
 
+void init_snapshot_merge(struct lv_segment *cow_seg,
+			 struct logical_volume *origin)
+{
+	/*
+	 * Even though lv_is_visible(cow_seg->lv) returns 0,
+	 * the cow_seg->lv (name: snapshotX) is _not_ hidden;
+	 * this is part of the lvm2 snapshot fiction.  Must
+	 * clear VISIBLE_LV directly (lv_set_visible can't)
+	 * - cow_seg->lv->status is used to control whether 'lv'
+	 *   (with user provided snapshot LV name) is visible
+	 * - this also enables vg_validate() to succeed with
+	 *   merge metadata (cow_seg->lv is now "internal")
+	 */
+	cow_seg->lv->status &= ~VISIBLE_LV;
+	cow_seg->status |= SNAPSHOT_MERGE;
+	origin->merging_snapshot = cow_seg;
+}
+
 int vg_add_snapshot(struct logical_volume *origin,
 		    struct logical_volume *cow, union lvid *lvid,
 		    uint32_t extent_count, uint32_t chunk_size)
@@ -113,7 +136,7 @@
 	if (!(seg = alloc_snapshot_seg(snap, 0, 0)))
 		return_0;
 
-	init_snapshot_seg(seg, origin, cow, chunk_size);
+	init_snapshot_seg(seg, origin, cow, chunk_size, 0);
 
 	return 1;
 }
@@ -122,6 +145,8 @@
 {
 	dm_list_del(&cow->snapshot->origin_list);
 	cow->snapshot->origin->origin_count--;
+	if (cow->snapshot->origin->merging_snapshot == cow->snapshot)
+		cow->snapshot->origin->merging_snapshot = NULL;
 
 	if (!lv_remove(cow->snapshot->lv)) {
 		log_error("Failed to remove internal snapshot LV %s",
--- LVM2/lib/snapshot/snapshot.c	2010/01/05 21:14:05	1.39
+++ LVM2/lib/snapshot/snapshot.c	2010/01/13 01:35:49	1.40
@@ -37,7 +37,7 @@
 	uint32_t chunk_size;
 	const char *org_name, *cow_name;
 	struct logical_volume *org, *cow;
-	int old_suppress;
+	int old_suppress, merge = 0;
 
 	if (!get_config_uint32(sn, "chunk_size", &chunk_size)) {
 		log_error("Couldn't read chunk size for snapshot.");
@@ -46,7 +46,10 @@
 
 	old_suppress = log_suppress(1);
 
-	if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
+	cow_name = find_config_str(sn, "merging_store", NULL);
+	if (cow_name) {
+		merge = 1;
+	} else if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
 		log_suppress(old_suppress);
 		log_error("Snapshot cow storage not specified.");
 		return 0;
@@ -72,7 +75,7 @@
 		return 0;
 	}
 
-	init_snapshot_seg(seg, org, cow, chunk_size);
+	init_snapshot_seg(seg, org, cow, chunk_size, merge);
 
 	return 1;
 }
@@ -81,7 +84,10 @@
 {
 	outf(f, "chunk_size = %u", seg->chunk_size);
 	outf(f, "origin = \"%s\"", seg->origin->name);
-	outf(f, "cow_store = \"%s\"", seg->cow->name);
+	if (!(seg->status & SNAPSHOT_MERGE))
+		outf(f, "cow_store = \"%s\"", seg->cow->name);
+	else
+		outf(f, "merging_store = \"%s\"", seg->cow->name);
 
 	return 1;
 }


