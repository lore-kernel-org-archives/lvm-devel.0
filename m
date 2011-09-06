From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Sep 2011 19:25:45 -0000
Subject: LVM2 tools/lvcreate.c lib/Makefile.in lib/meta ...
Message-ID: <20110906192545.20690.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-06 19:25:44

Modified files:
	tools          : lvcreate.c 
	lib            : Makefile.in 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.h 
	                 mirror.c replicator_manip.c 
	lib/thin       : thin.c 
Added files:
	lib/metadata   : thin_manip.c 

Log message:
	add thin_manip.c like the other manip files
	move basic lv_is_* to macros
	data_lv -> pool_lv - we decided to call it 'pool' everywhere now

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.236&r2=1.237
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.280&r2=1.281
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.205&r2=1.206
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.252&r2=1.253
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/replicator_manip.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/tools/lvcreate.c	2011/09/06 15:35:11	1.236
+++ LVM2/tools/lvcreate.c	2011/09/06 19:25:42	1.237
@@ -192,7 +192,6 @@
 				  struct lvcreate_params *lp)
 {
 	struct lv_list *lvl;
-	struct lv_segment *seg;
 
 	if (!(lvl = find_lv_in_vg(vg, lp->origin))) {
 		log_error("Snapshot origin LV %s not found in Volume group %s.", lp->origin, vg->name);
@@ -200,12 +199,12 @@
 	}
 
 	/* FIXME Replace with lv_is_thin_volume() once more flags are added */
-	if (seg_is_thin_volume(seg = first_seg(lvl->lv))) {
+	if (lv_is_thin_volume(lvl->lv)) {
 		lp->thin = 1;
 		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
 			return_0;
 
-		lp->pool = seg->thin_pool_lv->name;
+		lp->pool = first_seg(lvl->lv)->thin_pool_lv->name;
 	}
 
 	if (!lp->thin && !arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
@@ -804,8 +803,7 @@
 			log_error("Pool %s not found in Volume group %s.", lp->pool, vg->name);
 			return 0;
 		}
-		/* FIXME Use lv_is_thin_pool() */
-		if (!seg_is_thin_pool(first_seg(lvl->lv))) {
+		if (!lv_is_thin_pool(lvl->lv)) {
 			log_error("Logical volume %s is not a thin pool.", lp->pool);
 			return 0;
 		}
--- LVM2/lib/Makefile.in	2011/08/24 08:27:50	1.112
+++ LVM2/lib/Makefile.in	2011/09/06 19:25:43	1.113
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -93,6 +93,7 @@
 	metadata/replicator_manip.c \
 	metadata/segtype.c \
 	metadata/snapshot_manip.c \
+	metadata/thin_manip.c \
 	metadata/vg.c \
 	misc/crc.c \
 	misc/lvm-exec.c \
/cvs/lvm2/LVM2/lib/metadata/thin_manip.c,v  -->  standard output
revision 1.1
--- LVM2/lib/metadata/thin_manip.c
+++ -	2011-09-06 19:25:44.583371000 +0000
@@ -0,0 +1,33 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "metadata.h"
+
+int attach_pool_metadata(struct lv_segment *seg, struct logical_volume *thin_pool_metadata)
+{
+	// FIXME Housekeeping needed here (cf attach_mirror_log)
+	seg->metadata_lv = thin_pool_metadata;
+
+	return 1;
+}
+
+int attach_pool_lv(struct lv_segment *seg, struct logical_volume *thin_pool_lv)
+{
+	// FIXME Housekeeping needed here (cf attach_mirror_log)
+	seg->thin_pool_lv = thin_pool_lv;
+
+	return 1;
+}
+
--- LVM2/lib/metadata/lv_manip.c	2011/09/06 18:49:32	1.280
+++ LVM2/lib/metadata/lv_manip.c	2011/09/06 19:25:43	1.281
@@ -198,22 +198,6 @@
 	return i;
 }
 
-static int _attach_pool_metadata(struct lv_segment *seg, struct logical_volume *thin_pool_metadata)
-{
-	// FIXME Housekeeping needed here (cf attach_mirror_log)
-	seg->metadata_lv = thin_pool_metadata;
-
-	return 1;
-}
-
-static int _attach_pool_lv(struct lv_segment *seg, struct logical_volume *thin_pool_lv)
-{
-	// FIXME Housekeeping needed here (cf attach_mirror_log)
-	seg->thin_pool_lv = thin_pool_lv;
-
-	return 1;
-}
-
 /*
  * All lv_segments get created here.
  */
@@ -268,12 +252,12 @@
 	seg->pvmove_source_seg = pvmove_source_seg;
 	dm_list_init(&seg->tags);
 
-	if (thin_pool_lv && !_attach_pool_lv(seg, thin_pool_lv))
+	if (thin_pool_lv && !attach_pool_lv(seg, thin_pool_lv))
 		return_NULL;
 
 	if (log_lv) {
 		if (thin_pool_lv) {
-			if (!_attach_pool_metadata(seg, log_lv))
+			if (!attach_pool_metadata(seg, log_lv))
 				return_NULL;
 		} else if (!attach_mirror_log(seg, log_lv))
 			return_NULL;
--- LVM2/lib/metadata/metadata-exported.h	2011/09/06 18:49:32	1.205
+++ LVM2/lib/metadata/metadata-exported.h	2011/09/06 19:25:43	1.206
@@ -132,6 +132,11 @@
 #define VGMETADATACOPIES_ALL UINT32_MAX
 #define VGMETADATACOPIES_UNMANAGED 0
 
+#define lv_is_thin_volume(lv)	((lv)->status & THIN_VOLUME ? 1 : 0)
+#define lv_is_thin_pool(lv)	((lv)->status & THIN_POOL ? 1 : 0)
+#define lv_is_mirrored(lv)	((lv)->status & MIRRORED ? 1 : 0)
+#define lv_is_rlog(lv)		((lv)->status & REPLICATOR_LOG ? 1 : 0)
+
 /* Ordered list - see lv_manip.c */
 typedef enum {
 	AREA_UNASSIGNED,
@@ -318,7 +323,7 @@
 
 	struct lv_segment_area *areas;
 	struct lv_segment_area *meta_areas; /* For RAID */
-	struct logical_volume *data_lv;		/* For thin_pool */
+	struct logical_volume *pool_lv;		/* For thin_pool */
 	struct logical_volume *metadata_lv;	/* For thin_pool */
 	uint64_t transaction_id;		/* For thin_pool */
 	uint32_t zero_new_blocks;		/* For thin_pool */
@@ -696,7 +701,6 @@
 
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
-int lv_is_mirrored(const struct logical_volume *lv);
 uint32_t lv_mirror_count(const struct logical_volume *lv);
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 				    uint32_t region_size);
@@ -742,7 +746,6 @@
 int lv_is_replicator(const struct logical_volume *lv);
 int lv_is_replicator_dev(const struct logical_volume *lv);
 int lv_is_rimage(const struct logical_volume *lv);
-int lv_is_rlog(const struct logical_volume *lv);
 int lv_is_slog(const struct logical_volume *lv);
 struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 /* --  metadata/replicator_manip.c */
--- LVM2/lib/metadata/metadata.h	2011/09/06 18:49:32	1.252
+++ LVM2/lib/metadata/metadata.h	2011/09/06 19:25:43	1.253
@@ -440,6 +440,13 @@
 int fixup_imported_mirrors(struct volume_group *vg);
 
 /*
+ * From thin_manip.c
+ */
+int attach_pool_metadata(struct lv_segment *seg,
+			 struct logical_volume *thin_pool_metadata);
+int attach_pool_lv(struct lv_segment *seg, struct logical_volume *thin_pool_lv);
+
+/*
  * Begin skeleton for external LVM library
  */
 struct id pv_id(const struct physical_volume *pv);
--- LVM2/lib/metadata/mirror.c	2011/09/06 18:49:32	1.161
+++ LVM2/lib/metadata/mirror.c	2011/09/06 19:25:43	1.162
@@ -72,14 +72,6 @@
 	return NULL;
 }
 
-int lv_is_mirrored(const struct logical_volume *lv)
-{
-	if (lv->status & MIRRORED)
-		return 1;
-
-	return 0;
-}
-
 /*
  * cluster_mirror_is_available
  *
--- LVM2/lib/metadata/replicator_manip.c	2011/08/10 20:25:30	1.8
+++ LVM2/lib/metadata/replicator_manip.c	2011/09/06 19:25:43	1.9
@@ -446,14 +446,6 @@
 }
 
 /**
- * Is this LV rlog
- */
-int lv_is_rlog(const struct logical_volume *lv)
-{
-	return (lv->status & REPLICATOR_LOG);
-}
-
-/**
  * Is this LV sync log
  */
 int lv_is_slog(const struct logical_volume *lv)
--- LVM2/lib/thin/thin.c	2011/09/06 00:26:43	1.8
+++ LVM2/lib/thin/thin.c	2011/09/06 19:25:44	1.9
@@ -51,12 +51,14 @@
 	if (!dm_config_get_str(sn, "data", &lv_name))
 		return SEG_LOG_ERROR("Thin pool data must be a string in");
 
-	if (!(seg->data_lv = find_lv(seg->lv->vg, lv_name)))
+// Use attach_pool_lv
+	if (!(seg->pool_lv = find_lv(seg->lv->vg, lv_name)))
 		return SEG_LOG_ERROR("Unknown pool data %s in", lv_name);
 
 	if (!dm_config_get_str(sn, "metadata", &lv_name))
 		return SEG_LOG_ERROR("Thin pool metadata must be a string in");
 
+// Use attach_pool_metadata()
 	if (!(seg->metadata_lv = find_lv(seg->lv->vg, lv_name)))
 		return SEG_LOG_ERROR("Unknown pool metadata %s in", lv_name);
 
@@ -72,7 +74,7 @@
 
 static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter *f)
 {
-	outf(f, "data = \"%s\"", seg->data_lv->name);
+	outf(f, "data = \"%s\"", seg->pool_lv->name);
 	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
 	if (seg->zero_new_blocks)


