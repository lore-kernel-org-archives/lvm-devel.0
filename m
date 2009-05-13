From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2009 21:22:00 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/import-export.c l ...
Message-ID: <20090513212200.26257.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-13 21:21:59

Modified files:
	.              : WHATS_NEW 
	lib/format1    : import-export.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : metadata-exported.h snapshot_manip.c 
	lib/snapshot   : snapshot.c 
	tools          : lvconvert.c lvcreate.c 

Log message:
	Fix snapshot segment import to not use duplicate segments & replace.
	
	The snapshot segment (snapshotX) is created twice
	during the text metadata segment processing.
	
	This can cause temporary violation of max_lv count.
	
	Simplify the code, snapshot segment is properly initialized
	in init_snapshot_seg function now and do not need to be replaced
	by vg_add_snapshot call.
	
	The vg_add_snapshot() is now usefull only for adding new
	snapshot and it shares the same initialization function.
	
	The snapshot name is always generated, name paramater can be
	removed from function call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1103&r2=1.1104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.185&r2=1.186

--- LVM2/WHATS_NEW	2009/05/13 14:13:54	1.1103
+++ LVM2/WHATS_NEW	2009/05/13 21:21:58	1.1104
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix snapshot segment import to not use duplicate segments & replace.
   Do not query nonexistent devices for readahead.
   Remove NON_BLOCKING lock flag from tools and set a policy to auto-set.
   Remove snapshot_count from VG and use function instead.
--- LVM2/lib/format1/import-export.c	2009/05/12 19:12:09	1.101
+++ LVM2/lib/format1/import-export.c	2009/05/13 21:21:58	1.102
@@ -616,7 +616,7 @@
 				continue;
 
 			/* insert the snapshot */
-			if (!vg_add_snapshot(NULL, org, cow, NULL,
+			if (!vg_add_snapshot(org, cow, NULL,
 					     org->le_count,
 					     lvd->lv_chunk_size)) {
 				log_err("Couldn't add snapshot.");
--- LVM2/lib/format_text/import_vsn1.c	2009/04/10 09:59:19	1.58
+++ LVM2/lib/format_text/import_vsn1.c	2009/05/13 21:21:58	1.59
@@ -603,16 +603,6 @@
 
 	lv->size = (uint64_t) lv->le_count * (uint64_t) vg->extent_size;
 
-	/*
-	 * FIXME We now have 2 LVs for each snapshot. The real one was
-	 * created by vg_add_snapshot from the segment text_import.
-	 */
-	if (lv->status & SNAPSHOT) {
-		vg->lv_count--;
-		dm_list_del(&lvl->list);
-		return 1;
-	}
-
 	lv->minor = -1;
 	if ((lv->status & FIXED_MINOR) &&
 	    !_read_int32(lvn, "minor", &lv->minor)) {
--- LVM2/lib/metadata/metadata-exported.h	2009/05/12 19:12:09	1.66
+++ LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:21:58	1.67
@@ -545,8 +545,10 @@
 /* Given a cow LV, return its origin */
 struct logical_volume *origin_from_cow(const struct logical_volume *lv);
 
-int vg_add_snapshot(const char *name,
-		    struct logical_volume *origin, struct logical_volume *cow,
+void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
+		       struct logical_volume *cow, uint32_t chunk_size);
+
+int vg_add_snapshot(struct logical_volume *origin, struct logical_volume *cow,
 		    union lvid *lvid, uint32_t extent_count,
 		    uint32_t chunk_size);
 
--- LVM2/lib/metadata/snapshot_manip.c	2009/05/12 19:12:10	1.36
+++ LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:21:58	1.37
@@ -62,7 +62,31 @@
 	return lv->snapshot->origin;
 }
 
-int vg_add_snapshot(const char *name, struct logical_volume *origin,
+void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
+		       struct logical_volume *cow, uint32_t chunk_size)
+{
+	seg->chunk_size = chunk_size;
+	seg->origin = origin;
+	seg->cow = cow;
+
+	// FIXME: direct count manipulation to be removed later
+	cow->status &= ~VISIBLE_LV;
+	cow->vg->lv_count--;
+	cow->snapshot = seg;
+
+	origin->origin_count++;
+	origin->vg->lv_count--;
+
+	/* FIXME Assumes an invisible origin belongs to a sparse device */
+	if (!lv_is_visible(origin))
+		origin->status |= VIRTUAL_ORIGIN;
+
+	seg->lv->status |= (SNAPSHOT | VIRTUAL);
+
+	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
+}
+
+int vg_add_snapshot(struct logical_volume *origin,
 		    struct logical_volume *cow, union lvid *lvid,
 		    uint32_t extent_count, uint32_t chunk_size)
 {
@@ -82,39 +106,18 @@
 		return 0;
 	}
 
-	/*
-	 * Set origin lv count in advance to prevent fail because
-	 * of temporary violation of LV limits.
-	 */
-	origin->vg->lv_count--;
-
-	if (!(snap = lv_create_empty(name ? name : "snapshot%d",
+	if (!(snap = lv_create_empty("snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
-				     ALLOC_INHERIT, 1, origin->vg))) {
-		origin->vg->lv_count++;
+				     ALLOC_INHERIT, 1, origin->vg)))
 		return_0;
-	}
 
 	snap->le_count = extent_count;
 
 	if (!(seg = alloc_snapshot_seg(snap, 0, 0)))
 		return_0;
 
-	seg->chunk_size = chunk_size;
-	seg->origin = origin;
-	seg->cow = cow;
-	seg->lv->status |= SNAPSHOT;
-
-	origin->origin_count++;
-	cow->snapshot = seg;
-
-	cow->status &= ~VISIBLE_LV;
-
-        /* FIXME Assumes an invisible origin belongs to a sparse device */
-        if (!lv_is_visible(origin))
-                origin->status |= VIRTUAL_ORIGIN;
-
-	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
+	origin->vg->lv_count++;
+	init_snapshot_seg(seg, origin, cow, chunk_size);
 
 	return 1;
 }
--- LVM2/lib/snapshot/snapshot.c	2009/04/02 21:34:41	1.36
+++ LVM2/lib/snapshot/snapshot.c	2009/05/13 21:21:58	1.37
@@ -39,8 +39,6 @@
 	struct logical_volume *org, *cow;
 	int old_suppress;
 
-	seg->lv->status |= SNAPSHOT;
-
 	if (!get_config_uint32(sn, "chunk_size", &chunk_size)) {
 		log_error("Couldn't read chunk size for snapshot.");
 		return 0;
@@ -74,9 +72,7 @@
 		return 0;
 	}
 
-	if (!vg_add_snapshot(seg->lv->name, org, cow,
-			     &seg->lv->lvid, seg->len, chunk_size))
-		return_0;
+	init_snapshot_seg(seg, org, cow, chunk_size);
 
 	return 1;
 }
--- LVM2/tools/lvconvert.c	2009/04/29 20:11:46	1.72
+++ LVM2/tools/lvconvert.c	2009/05/13 21:21:59	1.73
@@ -760,8 +760,7 @@
 		return 0;
 	}
 
-	if (!vg_add_snapshot(NULL, org, lv, NULL, org->le_count,
-			     lp->chunk_size)) {
+	if (!vg_add_snapshot(org, lv, NULL, org->le_count, lp->chunk_size)) {
 		log_error("Couldn't create snapshot.");
 		return 0;
 	}
--- LVM2/tools/lvcreate.c	2009/04/29 20:14:21	1.185
+++ LVM2/tools/lvcreate.c	2009/05/13 21:21:59	1.186
@@ -918,7 +918,7 @@
 
 		/* cow LV remains active and becomes snapshot LV */
 
-		if (!vg_add_snapshot(NULL, org, lv, NULL,
+		if (!vg_add_snapshot(org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {
 			log_error("Couldn't create snapshot.");
 			goto deactivate_and_revert_new_lv;


