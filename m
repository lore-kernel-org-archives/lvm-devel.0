From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:56:20 -0000
Subject: LVM2 lib/format_text/flags.c lib/metadata/lv_m ...
Message-ID: <20100113015620.2686.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:56:19

Modified files:
	lib/format_text: flags.c 
	lib/metadata   : lv_manip.c metadata-exported.h snapshot_manip.c 
	lib/snapshot   : snapshot.c 
	tools          : toollib.c vgchange.c 

Log message:
	Rename segment and lv status flag from SNAPSHOT_MERGE to MERGING.
	
	Eliminate 'merging_snapshot' from 'struct logical_volume' and just use
	'snapshot' for origin lv's reference to the merging snapshot; also set
	MERGING in the origin lv's status.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.201&r2=1.202
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.183&r2=1.184
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/lib/format_text/flags.c	2010/01/13 01:35:49	1.40
+++ LVM2/lib/format_text/flags.c	2010/01/13 01:56:18	1.41
@@ -61,7 +61,7 @@
 	{MIRRORED, NULL, 0},
 	{VIRTUAL, NULL, 0},
 	{SNAPSHOT, NULL, 0},
-	{SNAPSHOT_MERGE, NULL, 0},
+	{MERGING, NULL, 0},
 	{ACTIVATE_EXCL, NULL, 0},
 	{CONVERTING, NULL, 0},
 	{PARTIAL_LV, NULL, 0},
--- LVM2/lib/metadata/lv_manip.c	2010/01/13 01:55:44	1.201
+++ LVM2/lib/metadata/lv_manip.c	2010/01/13 01:56:18	1.202
@@ -1877,7 +1877,6 @@
 	}
 
 	lv->snapshot = NULL;
-	lv->merging_snapshot = NULL;
 	dm_list_init(&lv->snapshot_segs);
 	dm_list_init(&lv->segments);
 	dm_list_init(&lv->tags);
--- LVM2/lib/metadata/metadata-exported.h	2010/01/13 01:55:44	1.127
+++ LVM2/lib/metadata/metadata-exported.h	2010/01/13 01:56:18	1.128
@@ -69,7 +69,7 @@
 //#define POSTORDER_OPEN_FLAG	0x04000000U    temporary use inside vg_read_internal. */
 //#define VIRTUAL_ORIGIN	0x08000000U	/* LV - internal use only */
 
-#define SNAPSHOT_MERGE		0x10000000U	/* SEG */
+#define MERGING			0x10000000U	/* LV SEG */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
@@ -330,9 +330,6 @@
 	struct dm_list snapshot_segs;
 	struct lv_segment *snapshot;
 
-	/* A snapshot that is merging into this origin */
-	struct lv_segment *merging_snapshot;
-
 	struct dm_list segments;
 	struct dm_list tags;
 	struct dm_list segs_using_this_lv;
--- LVM2/lib/metadata/snapshot_manip.c	2010/01/13 01:55:44	1.46
+++ LVM2/lib/metadata/snapshot_manip.c	2010/01/13 01:56:18	1.47
@@ -25,7 +25,7 @@
 
 int lv_is_cow(const struct logical_volume *lv)
 {
-	return lv->snapshot ? 1 : 0;
+	return (!lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
 }
 
 int lv_is_visible(const struct logical_volume *lv)
@@ -53,18 +53,21 @@
 
 int lv_is_merging_origin(const struct logical_volume *origin)
 {
-	return origin->merging_snapshot ? 1 : 0;
+	return (origin->status & MERGING) ? 1 : 0;
 }
 
 struct lv_segment *find_merging_cow(const struct logical_volume *origin)
 {
-	return origin->merging_snapshot;
+	/* FIXME: eliminate this wrapper and just use find_cow()?
+	 * - find_merging_cow() adds to code clarity in caller
+	 */
+	return find_cow(origin);
 }
 
 int lv_is_merging_cow(const struct logical_volume *snapshot)
 {
-	/* NOTE: use of find_cow() rather than find_merging_cow() */
-	return (find_cow(snapshot)->status & SNAPSHOT_MERGE) ? 1 : 0;
+	/* checks lv_segment's status to see if cow is merging */
+	return (find_cow(snapshot)->status & MERGING) ? 1 : 0;
 }
 
 /* Given a cow LV, return the snapshot lv_segment that uses it */
@@ -117,15 +120,17 @@
 	 *   merge metadata (cow_seg->lv is now "internal")
 	 */
 	cow_seg->lv->status &= ~VISIBLE_LV;
-	cow_seg->status |= SNAPSHOT_MERGE;
-	origin->merging_snapshot = cow_seg;
+	cow_seg->status |= MERGING;
+	origin->snapshot = cow_seg;
+	origin->status |= MERGING;
 }
 
 void clear_snapshot_merge(struct logical_volume *origin)
 {
 	/* clear merge attributes */
-	origin->merging_snapshot->status &= ~SNAPSHOT_MERGE;
-	origin->merging_snapshot = NULL;
+	origin->snapshot->status &= ~MERGING;
+	origin->snapshot = NULL;
+	origin->status &= ~MERGING;
 }
 
 int vg_add_snapshot(struct logical_volume *origin,
--- LVM2/lib/snapshot/snapshot.c	2010/01/13 01:39:44	1.41
+++ LVM2/lib/snapshot/snapshot.c	2010/01/13 01:56:18	1.42
@@ -84,7 +84,7 @@
 {
 	outf(f, "chunk_size = %u", seg->chunk_size);
 	outf(f, "origin = \"%s\"", seg->origin->name);
-	if (!(seg->status & SNAPSHOT_MERGE))
+	if (!(seg->status & MERGING))
 		outf(f, "cow_store = \"%s\"", seg->cow->name);
 	else
 		outf(f, "merging_store = \"%s\"", seg->cow->name);
@@ -144,7 +144,7 @@
 		_snap_checked = 1;
 	}
 
-	if (!_snap_merge_checked && seg && (seg->status & SNAPSHOT_MERGE)) {
+	if (!_snap_merge_checked && seg && (seg->status & MERGING)) {
 		_snap_merge_present = target_present(cmd, "snapshot-merge", 0);
 		_snap_merge_checked = 1;
 		return _snap_present && _snap_merge_present;
--- LVM2/tools/toollib.c	2010/01/13 01:55:44	1.183
+++ LVM2/tools/toollib.c	2010/01/13 01:56:18	1.184
@@ -1307,7 +1307,7 @@
 		pvmove_poll(cmd, pvname, 1);
 	}
 
-	if (lv->status & CONVERTING || lv_is_merging_origin(lv)) {
+	if (lv->status & (CONVERTING|MERGING)) {
 		log_verbose("Spawning background lvconvert process for %s",
 			lv->name);
 		lvconvert_poll(cmd, lv, 1);
--- LVM2/tools/vgchange.c	2010/01/13 01:55:44	1.97
+++ LVM2/tools/vgchange.c	2010/01/13 01:56:18	1.98
@@ -69,8 +69,7 @@
 			lv_active = info.exists;
 
 		if (lv_active &&
-		    (lv->status & (PVMOVE|CONVERTING) ||
-		     lv_is_merging_origin(lv))) {
+		    (lv->status & (PVMOVE|CONVERTING|MERGING))) {
 			lv_spawn_background_polling(cmd, lv);
 			count++;
 		}
@@ -140,8 +139,7 @@
 
 		if (background_polling() &&
 		    activate != CHANGE_AN && activate != CHANGE_ALN &&
-		    (lv->status & (PVMOVE|CONVERTING) ||
-		     lv_is_merging_origin(lv)))
+		    (lv->status & (PVMOVE|CONVERTING|MERGING)))
 			lv_spawn_background_polling(cmd, lv);
 
 		count++;


