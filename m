From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Oct 2011 16:44:24 -0000
Subject: LVM2/lib/metadata metadata.h thin_manip.c
Message-ID: <20111022164424.8239.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-22 16:44:23

Modified files:
	lib/metadata   : metadata.h thin_manip.c 

Log message:
	Recoded way to insert thin pool into vg
	
	Code in _lv_insert_empty_sublvs  was not able to provide proper
	initialization order for thin pool LV.
	
	New function extend_pool() first adds metadata segment to pool LV which
	is still visible. Such LV is activate and cleared.
	
	Then new meta LV is created and metadata segments are moved there.
	Now the preallocated pool data segment is attached to the pool LV
	and layer _tpool is created. Finaly segment is marked as thin_pool.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.260&r2=1.261
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/lib/metadata/metadata.h	2011/10/22 16:42:11	1.260
+++ LVM2/lib/metadata/metadata.h	2011/10/22 16:44:23	1.261
@@ -69,6 +69,7 @@
 
 struct dm_config_tree;
 struct metadata_area;
+struct alloc_handle;
 
 /* Per-format per-metadata area operations */
 struct metadata_area_ops {
@@ -461,6 +462,8 @@
 			struct logical_volume *lv, uint32_t delete_id,
 			int read_only);
 int detach_pool_messages(struct lv_segment *seg);
+int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
+		struct alloc_handle *ah);
 
 /*
  * Begin skeleton for external LVM library
--- LVM2/lib/metadata/thin_manip.c	2011/10/19 16:42:14	1.12
+++ LVM2/lib/metadata/thin_manip.c	2011/10/22 16:44:23	1.13
@@ -13,6 +13,8 @@
  */
 
 #include "lib.h"
+#include "activate.h"
+#include "locking.h"
 #include "metadata.h"
 #include "segtype.h"
 #include "lv_alloc.h"
@@ -216,3 +218,96 @@
 
 	return max_id;
 }
+
+int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segtype,
+		struct alloc_handle *ah)
+{
+	const struct segment_type *striped;
+	struct logical_volume *meta_lv, *data_lv;
+	struct lv_segment *seg;
+	const size_t len = strlen(pool_lv->name) + 16;
+	char name[len];
+
+	if (lv_is_thin_pool(pool_lv)) {
+		log_error("Resize of pool %s not yet implemented.", pool_lv->name);
+		return 0;
+	}
+
+	/* LV is not yet a pool, so it's extension from lvcreate */
+	if (!(striped = get_segtype_from_string(pool_lv->vg->cmd, "striped")))
+		return_0;
+
+	if (activation() && segtype->ops->target_present &&
+	    !segtype->ops->target_present(pool_lv->vg->cmd, NULL, NULL)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel.", segtype->name);
+		return 0;
+	}
+
+	/* Metadata segment */
+	if (!lv_add_segment(ah, 1, 1, pool_lv, striped, 1, 0, 0))
+		return_0;
+
+	if (activation()) {
+		if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
+			return_0;
+
+		/*
+		 * If killed here, only the VISIBLE striped pool LV is left
+		 * and user could easily remove it.
+		 *
+		 * FIXME: implement lazy clearing when activation is disabled
+		 */
+
+		// FIXME: activate_lv_local_excl is actually wanted here
+		if (!activate_lv_local(pool_lv->vg->cmd, pool_lv) ||
+		    // FIXME: maybe -zero n  should  allow to recreate same thin pool
+		    // and different option should be used for zero_new_blocks
+		    /* Clear 4KB of metadata device for new thin-pool. */
+		    !set_lv(pool_lv->vg->cmd, pool_lv, UINT64_C(0), 0)) {
+			log_error("Aborting. Failed to wipe pool metadata %s.",
+				  pool_lv->name);
+			return 0;
+		}
+
+		if (!deactivate_lv_local(pool_lv->vg->cmd, pool_lv)) {
+			log_error("Aborting. Could not deactivate pool metadata %s.",
+				  pool_lv->name);
+			return 0;
+		}
+	} else {
+		log_error("Pool %s created without initilization.", pool_lv->name);
+	}
+
+	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0)
+		return_0;
+
+	if (!(meta_lv = lv_create_empty(name, NULL, LVM_READ | LVM_WRITE,
+					ALLOC_INHERIT, pool_lv->vg)))
+		return_0;
+
+	if (!move_lv_segments(meta_lv, pool_lv, 0, 0))
+		return_0;
+
+	/* Pool data segment */
+	if (!lv_add_segment(ah, 0, 1, pool_lv, striped, 1, 0, 0))
+		return_0;
+
+	if (!(data_lv = insert_layer_for_lv(pool_lv->vg->cmd, pool_lv,
+					    pool_lv->status, "_tpool")))
+		return_0;
+
+	seg = first_seg(pool_lv);
+	seg->segtype = segtype; /* Set as thin_pool segment */
+	seg->lv->status |= THIN_POOL;
+
+	if (!attach_pool_metadata_lv(seg, meta_lv))
+		return_0;
+
+	/* Drop reference as attach_pool_data_lv() takes it again */
+	remove_seg_from_segs_using_this_lv(data_lv, seg);
+	if (!attach_pool_data_lv(seg, data_lv))
+		return_0;
+
+	return 1;
+}


