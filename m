From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 13:16:57 -0000
Subject: LVM2/lib/metadata vg.c vg.h lv.c lv.h
Message-ID: <20100930131657.1793.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 13:16:55

Added files:
	lib/metadata   : vg.c vg.h lv.c lv.h 

Log message:
	Add lib/metadata/vg.[ch] and lib/metadata/lv.[ch].
	
	These got missed when git cvsexportcommit was used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/lib/metadata/vg.c,v  -->  standard output
revision 1.1
--- LVM2/lib/metadata/vg.c
+++ -	2010-09-30 13:16:56.215268000 +0000
@@ -0,0 +1,436 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+#include "activate.h"
+
+uint32_t vg_seqno(const struct volume_group *vg)
+{
+	return vg->seqno;
+}
+
+uint64_t vg_status(const struct volume_group *vg)
+{
+	return vg->status;
+}
+
+uint64_t vg_size(const struct volume_group *vg)
+{
+	return (uint64_t) vg->extent_count * vg->extent_size;
+}
+
+uint64_t vg_free(const struct volume_group *vg)
+{
+	return (uint64_t) vg->free_count * vg->extent_size;
+}
+
+uint64_t vg_extent_size(const struct volume_group *vg)
+{
+	return (uint64_t) vg->extent_size;
+}
+
+uint64_t vg_extent_count(const struct volume_group *vg)
+{
+	return (uint64_t) vg->extent_count;
+}
+
+uint64_t vg_free_count(const struct volume_group *vg)
+{
+	return (uint64_t) vg->free_count;
+}
+
+uint64_t vg_pv_count(const struct volume_group *vg)
+{
+	return (uint64_t) vg->pv_count;
+}
+
+uint64_t vg_max_pv(const struct volume_group *vg)
+{
+	return (uint64_t) vg->max_pv;
+}
+
+uint64_t vg_max_lv(const struct volume_group *vg)
+{
+	return (uint64_t) vg->max_lv;
+}
+
+unsigned snapshot_count(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	unsigned num_snapshots = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_cow(lvl->lv))
+			num_snapshots++;
+
+	return num_snapshots;
+}
+
+unsigned vg_visible_lvs(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	unsigned lv_count = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lv_is_visible(lvl->lv))
+			lv_count++;
+	}
+
+	return lv_count;
+}
+
+uint32_t vg_mda_count(const struct volume_group *vg)
+{
+	return dm_list_size(&vg->fid->metadata_areas_in_use) +
+		dm_list_size(&vg->fid->metadata_areas_ignored);
+}
+
+uint32_t vg_mda_used_count(const struct volume_group *vg)
+{
+       uint32_t used_count = 0;
+       struct metadata_area *mda;
+
+	/*
+	 * Ignored mdas could be on either list - the reason being the state
+	 * may have changed from ignored to un-ignored and we need to write
+	 * the state to disk.
+	 */
+       dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use)
+	       if (!mda_is_ignored(mda))
+		       used_count++;
+
+       return used_count;
+}
+
+uint32_t vg_mda_copies(const struct volume_group *vg)
+{
+	return vg->mda_copies;
+}
+
+uint64_t vg_mda_size(const struct volume_group *vg)
+{
+	return find_min_mda_size(&vg->fid->metadata_areas_in_use);
+}
+
+uint64_t vg_mda_free(const struct volume_group *vg)
+{
+	uint64_t freespace = UINT64_MAX, mda_free;
+	struct metadata_area *mda;
+
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		if (!mda->ops->mda_free_sectors)
+			continue;
+		mda_free = mda->ops->mda_free_sectors(mda);
+		if (mda_free < freespace)
+			freespace = mda_free;
+	}
+
+	if (freespace == UINT64_MAX)
+		freespace = UINT64_C(0);
+	return freespace;
+}
+
+int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies)
+{
+	vg->mda_copies = mda_copies;
+
+	/* FIXME Use log_verbose when this is due to specific cmdline request. */
+	log_debug("Setting mda_copies to %"PRIu32" for VG %s",
+		    mda_copies, vg->name);
+
+	return 1;
+}
+
+static int _recalc_extents(uint32_t *extents, const char *desc1,
+			   const char *desc2, uint32_t old_size,
+			   uint32_t new_size)
+{
+	uint64_t size = (uint64_t) old_size * (*extents);
+
+	if (size % new_size) {
+		log_error("New size %" PRIu64 " for %s%s not an exact number "
+			  "of new extents.", size, desc1, desc2);
+		return 0;
+	}
+
+	size /= new_size;
+
+	if (size > UINT32_MAX) {
+		log_error("New extent count %" PRIu64 " for %s%s exceeds "
+			  "32 bits.", size, desc1, desc2);
+		return 0;
+	}
+
+	*extents = (uint32_t) size;
+
+	return 1;
+}
+
+int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
+{
+	uint32_t old_size = vg->extent_size;
+	struct pv_list *pvl;
+	struct lv_list *lvl;
+	struct physical_volume *pv;
+	struct logical_volume *lv;
+	struct lv_segment *seg;
+	struct pv_segment *pvseg;
+	uint32_t s;
+
+	if (!vg_is_resizeable(vg)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change PE size", vg->name);
+		return 0;
+	}
+
+	if (!new_size) {
+		log_error("Physical extent size may not be zero");
+		return 0;
+	}
+
+	if (new_size == vg->extent_size)
+		return 1;
+
+	if (new_size & (new_size - 1)) {
+		log_error("Physical extent size must be a power of 2.");
+		return 0;
+	}
+
+	if (new_size > vg->extent_size) {
+		if ((uint64_t) vg_size(vg) % new_size) {
+			/* FIXME Adjust used PV sizes instead */
+			log_error("New extent size is not a perfect fit");
+			return 0;
+		}
+	}
+
+	vg->extent_size = new_size;
+
+	if (vg->fid->fmt->ops->vg_setup &&
+	    !vg->fid->fmt->ops->vg_setup(vg->fid, vg))
+		return_0;
+
+	if (!_recalc_extents(&vg->extent_count, vg->name, "", old_size,
+			     new_size))
+		return_0;
+
+	if (!_recalc_extents(&vg->free_count, vg->name, " free space",
+			     old_size, new_size))
+		return_0;
+
+	/* foreach PV */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		pv = pvl->pv;
+
+		pv->pe_size = new_size;
+		if (!_recalc_extents(&pv->pe_count, pv_dev_name(pv), "",
+				     old_size, new_size))
+			return_0;
+
+		if (!_recalc_extents(&pv->pe_alloc_count, pv_dev_name(pv),
+				     " allocated space", old_size, new_size))
+			return_0;
+
+		/* foreach free PV Segment */
+		dm_list_iterate_items(pvseg, &pv->segments) {
+			if (pvseg_is_allocated(pvseg))
+				continue;
+
+			if (!_recalc_extents(&pvseg->pe, pv_dev_name(pv),
+					     " PV segment start", old_size,
+					     new_size))
+				return_0;
+			if (!_recalc_extents(&pvseg->len, pv_dev_name(pv),
+					     " PV segment length", old_size,
+					     new_size))
+				return_0;
+		}
+	}
+
+	/* foreach LV */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		lv = lvl->lv;
+
+		if (!_recalc_extents(&lv->le_count, lv->name, "", old_size,
+				     new_size))
+			return_0;
+
+		dm_list_iterate_items(seg, &lv->segments) {
+			if (!_recalc_extents(&seg->le, lv->name,
+					     " segment start", old_size,
+					     new_size))
+				return_0;
+
+			if (!_recalc_extents(&seg->len, lv->name,
+					     " segment length", old_size,
+					     new_size))
+				return_0;
+
+			if (!_recalc_extents(&seg->area_len, lv->name,
+					     " area length", old_size,
+					     new_size))
+				return_0;
+
+			if (!_recalc_extents(&seg->extents_copied, lv->name,
+					     " extents moved", old_size,
+					     new_size))
+				return_0;
+
+			/* foreach area */
+			for (s = 0; s < seg->area_count; s++) {
+				switch (seg_type(seg, s)) {
+				case AREA_PV:
+					if (!_recalc_extents
+					    (&seg_pe(seg, s),
+					     lv->name,
+					     " pvseg start", old_size,
+					     new_size))
+						return_0;
+					if (!_recalc_extents
+					    (&seg_pvseg(seg, s)->len,
+					     lv->name,
+					     " pvseg length", old_size,
+					     new_size))
+						return_0;
+					break;
+				case AREA_LV:
+					if (!_recalc_extents
+					    (&seg_le(seg, s), lv->name,
+					     " area start", old_size,
+					     new_size))
+						return_0;
+					break;
+				case AREA_UNASSIGNED:
+					log_error("Unassigned area %u found in "
+						  "segment", s);
+					return 0;
+				}
+			}
+		}
+
+	}
+
+	return 1;
+}
+
+int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv)
+{
+	if (!vg_is_resizeable(vg)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change MaxLogicalVolume", vg->name);
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!max_lv)
+			max_lv = 255;
+		else if (max_lv > 255) {
+			log_error("MaxLogicalVolume limit is 255");
+			return 0;
+		}
+	}
+
+	if (max_lv && max_lv < vg_visible_lvs(vg)) {
+		log_error("MaxLogicalVolume is less than the current number "
+			  "%d of LVs for %s", vg_visible_lvs(vg),
+			  vg->name);
+		return 0;
+	}
+	vg->max_lv = max_lv;
+
+	return 1;
+}
+
+int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv)
+{
+	if (!vg_is_resizeable(vg)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change MaxPhysicalVolumes", vg->name);
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!max_pv)
+			max_pv = 255;
+		else if (max_pv > 255) {
+			log_error("MaxPhysicalVolume limit is 255");
+			return 0;
+		}
+	}
+
+	if (max_pv && max_pv < vg->pv_count) {
+		log_error("MaxPhysicalVolumes is less than the current number "
+			  "%d of PVs for \"%s\"", vg->pv_count,
+			  vg->name);
+		return 0;
+	}
+	vg->max_pv = max_pv;
+	return 1;
+}
+
+int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc)
+{
+	if (alloc == ALLOC_INHERIT) {
+		log_error("Volume Group allocation policy cannot inherit "
+			  "from anything");
+		return 0;
+	}
+
+	if (alloc == vg->alloc)
+		return 1;
+
+	vg->alloc = alloc;
+	return 1;
+}
+
+int vg_set_clustered(struct volume_group *vg, int clustered)
+{
+	struct lv_list *lvl;
+
+	/*
+	 * We do not currently support switching the cluster attribute
+	 * on active mirrors or snapshots.
+	 */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lv_is_mirrored(lvl->lv) && lv_is_active(lvl->lv)) {
+			log_error("Mirror logical volumes must be inactive "
+				  "when changing the cluster attribute.");
+			return 0;
+		}
+
+		if (clustered) {
+			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
+				log_error("Volume group %s contains snapshots "
+					  "that are not yet supported.",
+					  vg->name);
+				return 0;
+			}
+		}
+
+		if ((lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) &&
+		    lv_is_active(lvl->lv)) {
+			log_error("Snapshot logical volumes must be inactive "
+				  "when changing the cluster attribute.");
+			return 0;
+		}
+	}
+
+	if (clustered)
+		vg->status |= CLUSTERED;
+	else
+		vg->status &= ~CLUSTERED;
+	return 1;
+}
+
/cvs/lvm2/LVM2/lib/metadata/vg.h,v  -->  standard output
revision 1.1
--- LVM2/lib/metadata/vg.h
+++ -	2010-09-30 13:16:56.647085000 +0000
@@ -0,0 +1,127 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+#ifndef _VG_H
+#define _VG_H
+
+struct cmd_context;
+struct dm_pool;
+struct format_instance;
+struct dm_list;
+struct id;
+
+typedef enum {
+	ALLOC_INVALID,
+	ALLOC_CONTIGUOUS,
+	ALLOC_CLING,
+	ALLOC_NORMAL,
+	ALLOC_ANYWHERE,
+	ALLOC_INHERIT
+} alloc_policy_t;
+
+struct volume_group {
+	struct cmd_context *cmd;
+	struct dm_pool *vgmem;
+	struct format_instance *fid;
+	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
+	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
+	uint32_t seqno;		/* Metadata sequence number */
+
+	alloc_policy_t alloc;
+	uint64_t status;
+
+	struct id id;
+	char *name;
+	char *old_name;		/* Set during vgrename and vgcfgrestore */
+	char *system_id;
+
+	uint32_t extent_size;
+	uint32_t extent_count;
+	uint32_t free_count;
+
+	uint32_t max_lv;
+	uint32_t max_pv;
+
+	/* physical volumes */
+	uint32_t pv_count;
+	struct dm_list pvs;
+
+	/*
+	 * logical volumes
+	 * The following relationship should always hold:
+	 * dm_list_size(lvs) = user visible lv_count + snapshot_count + other invisible LVs
+	 *
+	 * Snapshots consist of 2 instances of "struct logical_volume":
+	 * - cow (lv_name is visible to the user)
+	 * - snapshot (lv_name is 'snapshotN')
+	 *
+	 * Mirrors consist of multiple instances of "struct logical_volume":
+	 * - one for the mirror log
+	 * - one for each mirror leg
+	 * - one for the user-visible mirror LV
+	 */
+	struct dm_list lvs;
+
+	struct dm_list tags;
+
+	/*
+	 * FIXME: Move the next fields into a different struct?
+	 */
+
+	/*
+	 * List of removed physical volumes by pvreduce.
+	 * They have to get cleared on vg_commit.
+	 */
+	struct dm_list removed_pvs;
+	uint32_t open_mode; /* FIXME: read or write - check lock type? */
+
+	/*
+	 * Store result of the last vg_read().
+	 * 0 for success else appropriate FAILURE_* bits set.
+	 */
+	uint32_t read_status;
+	uint32_t mda_copies; /* target number of mdas for this VG */
+};
+
+uint32_t vg_seqno(const struct volume_group *vg);
+uint64_t vg_status(const struct volume_group *vg);
+int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc);
+int vg_set_clustered(struct volume_group *vg, int clustered);
+uint64_t vg_size(const struct volume_group *vg);
+uint64_t vg_free(const struct volume_group *vg);
+uint64_t vg_extent_size(const struct volume_group *vg);
+int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size);
+uint64_t vg_extent_count(const struct volume_group *vg);
+uint64_t vg_free_count(const struct volume_group *vg);
+uint64_t vg_pv_count(const struct volume_group *vg);
+uint64_t vg_max_pv(const struct volume_group *vg);
+int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv);
+uint64_t vg_max_lv(const struct volume_group *vg);
+int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv);
+uint32_t vg_mda_count(const struct volume_group *vg);
+uint32_t vg_mda_used_count(const struct volume_group *vg);
+uint32_t vg_mda_copies(const struct volume_group *vg);
+int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies);
+/*
+ * Returns visible LV count - number of LVs from user perspective
+ */
+unsigned vg_visible_lvs(const struct volume_group *vg);
+/*
+ * Count snapshot LVs.
+ */
+unsigned snapshot_count(const struct volume_group *vg);
+
+uint64_t vg_mda_size(const struct volume_group *vg);
+uint64_t vg_mda_free(const struct volume_group *vg);
+
+#endif
/cvs/lvm2/LVM2/lib/metadata/lv.c,v  -->  standard output
revision 1.1
--- LVM2/lib/metadata/lv.c
+++ -	2010-09-30 13:16:56.895538000 +0000
@@ -0,0 +1,21 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+uint64_t lv_size(const struct logical_volume *lv)
+{
+	return lv->size;
+}
/cvs/lvm2/LVM2/lib/metadata/lv.h,v  -->  standard output
revision 1.1
--- LVM2/lib/metadata/lv.h
+++ -	2010-09-30 13:16:57.348008000 +0000
@@ -0,0 +1,52 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+#ifndef _LV_H
+#define _LV_H
+
+union lvid;
+struct volume_group;
+struct dm_list;
+struct lv_segment;
+struct replicator_device;
+
+struct logical_volume {
+	union lvid lvid;
+	char *name;
+
+	struct volume_group *vg;
+
+	uint64_t status;
+	alloc_policy_t alloc;
+	uint32_t read_ahead;
+	int32_t major;
+	int32_t minor;
+
+	uint64_t size;		/* Sectors */
+	uint32_t le_count;
+
+	uint32_t origin_count;
+	struct dm_list snapshot_segs;
+	struct lv_segment *snapshot;
+
+	struct replicator_device *rdevice;/* For replicator-devs, rimages, slogs - reference to rdevice */
+	struct dm_list rsites;	/* For replicators - all sites */
+
+	struct dm_list segments;
+	struct dm_list tags;
+	struct dm_list segs_using_this_lv;
+};
+
+uint64_t lv_size(const struct logical_volume *lv);
+
+#endif


