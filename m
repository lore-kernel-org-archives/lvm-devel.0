From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:14 -0400
Subject: [PATCH 02/20] Refactor metadata.[ch] into pv.[ch] for pv functions.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The metadata.[ch] files are very large.  This patch makes a first
attempt at separating out pv functions and data, particularly
related to the reporting fields calculations.

More code could be moved here but for now I'm stopping at reporting
functions 'get' / 'set' functions.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks.in             |    1 +
 lib/Makefile.in                  |    1 +
 lib/metadata/metadata-exported.h |   52 +---------
 lib/metadata/metadata.c          |  206 -----------------------------------
 lib/metadata/pv.c                |  223 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/pv.h                |   74 +++++++++++++
 6 files changed, 300 insertions(+), 257 deletions(-)
 create mode 100644 lib/metadata/pv.c
 create mode 100644 lib/metadata/pv.h

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 4dca46f..398e856 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -33,6 +33,7 @@
 @top_srcdir@/lib/metadata/lv_alloc.h
 @top_srcdir@/lib/metadata/metadata.h
 @top_srcdir@/lib/metadata/metadata-exported.h
+ at top_srcdir@/lib/metadata/pv.h
 @top_srcdir@/lib/metadata/pv_alloc.h
 @top_srcdir@/lib/metadata/segtype.h
 @top_srcdir@/lib/metadata/vg.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 172a0fd..2c173b3 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -77,6 +77,7 @@ SOURCES =\
 	metadata/merge.c \
 	metadata/metadata.c \
 	metadata/mirror.c \
+	metadata/pv.c \
 	metadata/pv_manip.c \
 	metadata/pv_map.c \
 	metadata/replicator_manip.c \
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index fef6903..86c90fa 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -22,6 +22,7 @@
 #define _LVM_METADATA_EXPORTED_H
 
 #include "uuid.h"
+#include "pv.h"
 #include "vg.h"
 
 #define MAX_STRIPES 128U
@@ -175,39 +176,6 @@ struct pv_segment {
 
 #define pvseg_is_allocated(pvseg) ((pvseg)->lvseg)
 
-struct physical_volume {
-	struct id id;
-	struct device *dev;
-	const struct format_type *fmt;
-
-	/*
-	 * vg_name and vgid are used before the parent VG struct exists.
-	 * FIXME: Investigate removal/substitution with 'vg' fields.
-	 */
-	const char *vg_name;
-	struct id vgid;
-
-	/*
-	 * 'vg' is set and maintained when the PV belongs to a 'pvs'
-	 * list in a parent VG struct.
-	 */
-	struct volume_group *vg;
-
-	uint64_t status;
-	uint64_t size;
-
-	/* physical extents */
-	uint32_t pe_size;
-	uint64_t pe_start;
-	uint32_t pe_count;
-	uint32_t pe_alloc_count;
-	unsigned long pe_align;
-	unsigned long pe_align_offset;
-
-	struct dm_list segments;	/* Ordered pv_segments covering complete PV */
-	struct dm_list tags;
-};
-
 struct format_instance {
 	const struct format_type *fmt;
 	/*
@@ -419,7 +387,6 @@ int scan_vgs_for_pvs(struct cmd_context *cmd);
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct dm_list *mdas, int64_t label_sector);
-int is_pv(struct physical_volume *pv);
 int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	    const char *pv_name);
 int move_pvs_used_by_lv(struct volume_group *vg_from,
@@ -427,8 +394,6 @@ int move_pvs_used_by_lv(struct volume_group *vg_from,
 			const char *lv_name);
 int is_global_vg(const char *vg_name);
 int is_orphan_vg(const char *vg_name);
-int is_orphan(const struct physical_volume *pv);
-int is_missing_pv(const struct physical_volume *pv);
 int vg_missing_pv_count(const struct volume_group *vg);
 int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_from,
@@ -777,21 +742,6 @@ char *generate_lv_name(struct volume_group *vg, const char *format,
 /*
 * Begin skeleton for external LVM library
 */
-struct device *pv_dev(const struct physical_volume *pv);
-const char *pv_vg_name(const struct physical_volume *pv);
-const char *pv_dev_name(const struct physical_volume *pv);
-uint64_t pv_size(const struct physical_volume *pv);
-uint64_t pv_size_field(const struct physical_volume *pv);
-uint64_t pv_dev_size(const struct physical_volume *pv);
-uint64_t pv_free(const struct physical_volume *pv);
-uint64_t pv_status(const struct physical_volume *pv);
-uint32_t pv_pe_size(const struct physical_volume *pv);
-uint64_t pv_pe_start(const struct physical_volume *pv);
-uint32_t pv_pe_count(const struct physical_volume *pv);
-uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
-uint32_t pv_mda_count(const struct physical_volume *pv);
-uint32_t pv_mda_used_count(const struct physical_volume *pv);
-unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored);
 int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignore);
 
 uint64_t lv_size(const struct logical_volume *lv);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ca741b2..ac19603 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -34,12 +34,6 @@
 #include <math.h>
 #include <sys/param.h>
 
-/*
- * FIXME: Check for valid handle before dereferencing field or log error?
- */
-#define pv_field(handle, field)				\
-	(((const struct physical_volume *)(handle))->field)
-
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct dm_pool *pvmem,
 					const char *pv_name,
@@ -3424,29 +3418,6 @@ int is_orphan_vg(const char *vg_name)
 	return (vg_name && !strncmp(vg_name, ORPHAN_PREFIX, sizeof(ORPHAN_PREFIX) - 1)) ? 1 : 0;
 }
 
-/**
- * is_orphan - Determine whether a pv is an orphan based on its vg_name
- * @pv: handle to the physical volume
- */
-int is_orphan(const struct physical_volume *pv)
-{
-	return is_orphan_vg(pv_field(pv, vg_name));
-}
-
-/**
- * is_pv - Determine whether a pv is a real pv or dummy one
- * @pv: handle to device
- */
-int is_pv(struct physical_volume *pv)
-{
-	return (pv_field(pv, vg_name) ? 1 : 0);
-}
- 
-int is_missing_pv(const struct physical_volume *pv)
-{
-	return pv_field(pv, status) & MISSING_PV ? 1 : 0;
-}
-
 /*
  * Returns:
  *  0 - fail
@@ -3790,101 +3761,6 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 	return FAILED_EXIST;
 }
 
-/*
- * Gets/Sets for external LVM library
- */
-struct id pv_id(const struct physical_volume *pv)
-{
-	return pv_field(pv, id);
-}
-
-const struct format_type *pv_format_type(const struct physical_volume *pv)
-{
-	return pv_field(pv, fmt);
-}
-
-struct id pv_vgid(const struct physical_volume *pv)
-{
-	return pv_field(pv, vgid);
-}
-
-struct device *pv_dev(const struct physical_volume *pv)
-{
-	return pv_field(pv, dev);
-}
-
-const char *pv_vg_name(const struct physical_volume *pv)
-{
-	return pv_field(pv, vg_name);
-}
-
-const char *pv_dev_name(const struct physical_volume *pv)
-{
-	return dev_name(pv_dev(pv));
-}
-
-uint64_t pv_size(const struct physical_volume *pv)
-{
-	return pv_field(pv, size);
-}
-
-uint64_t pv_dev_size(const struct physical_volume *pv)
-{
-	uint64_t size;
-
-	if (!dev_get_size(pv->dev, &size))
-		size = 0;
-	return size;
-}
-
-uint64_t pv_size_field(const struct physical_volume *pv)
-{
-	uint64_t size;
-
-	if (!pv->pe_count)
-		size = pv->size;
-	else
-		size = (uint64_t) pv->pe_count * pv->pe_size;
-	return size;
-}
-
-uint64_t pv_free(const struct physical_volume *pv)
-{
-	uint64_t freespace;
-
-	if (!pv->pe_count)
-		freespace = pv->size;
-	else
-		freespace = (uint64_t)
-			(pv->pe_count - pv->pe_alloc_count) * pv->pe_size;
-	return freespace;
-}
-
-uint64_t pv_status(const struct physical_volume *pv)
-{
-	return pv_field(pv, status);
-}
-
-uint32_t pv_pe_size(const struct physical_volume *pv)
-{
-	return pv_field(pv, pe_size);
-}
-
-uint64_t pv_pe_start(const struct physical_volume *pv)
-{
-	return pv_field(pv, pe_start);
-}
-
-uint32_t pv_pe_count(const struct physical_volume *pv)
-{
-	return pv_field(pv, pe_count);
-}
-
-uint32_t pv_pe_alloc_count(const struct physical_volume *pv)
-{
-	return pv_field(pv, pe_alloc_count);
-}
-
 void fid_add_mda(struct format_instance *fid, struct metadata_area *mda)
 {
 	dm_list_add(mda_is_ignored(mda) ? &fid->metadata_areas_ignored :
@@ -3983,88 +3859,6 @@ void mda_set_ignored(struct metadata_area *mda, unsigned mda_ignored)
 		  mda->ops->mda_metadata_locn_offset ? mda->ops->mda_metadata_locn_offset(locn) : UINT64_C(0));
 }
 
-uint32_t pv_mda_count(const struct physical_volume *pv)
-{
-	struct lvmcache_info *info;
-
-	info = info_from_pvid((const char *)&pv->id.uuid, 0);
-	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
-}
-
-uint32_t pv_mda_used_count(const struct physical_volume *pv)
-{
-	struct lvmcache_info *info;
-	struct metadata_area *mda;
-	uint32_t used_count=0;
-
-	info = info_from_pvid((const char *)&pv->id.uuid, 0);
-	if (!info)
-		return 0;
-	dm_list_iterate_items(mda, &info->mdas) {
-		if (!mda_is_ignored(mda))
-			used_count++;
-	}
-	return used_count;
-}
-
-unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignored)
-{
-	struct lvmcache_info *info;
-	struct metadata_area *mda, *vg_mda, *tmda;
-	struct dm_list *vg_mdas_in_use, *vg_mdas_ignored;
-
-	if (!(info = info_from_pvid((const char *)&pv->id.uuid, 0)))
-		return_0;
-
-	if (is_orphan(pv)) {
-		dm_list_iterate_items(mda, &info->mdas)
-			mda_set_ignored(mda, mda_ignored);
-		return 1;
-	}
-
-	/*
-	 * Do not allow disabling of the the last PV in a VG.
-	 */
-	if (pv_mda_used_count(pv) == vg_mda_used_count(pv->vg)) {
-		log_error("Cannot disable all metadata areas in volume group %s.",
-			  pv->vg->name);
-		return 0;
-	}
-
-	/*
-	 * Non-orphan case is more complex.
-	 * If the PV's mdas are ignored, and we wish to un-ignore,
-	 * we clear the bit and move them from the ignored mda list to the
-	 * in_use list, ensuring the new state will get written to disk
-	 * in the vg_write() path.
-	 * If the PV's mdas are not ignored, and we are setting
-	 * them to ignored, we set the bit but leave them on the in_use
-	 * list, ensuring the new state will get written to disk in the
-	 * vg_write() path.
-	 */
-	vg_mdas_in_use = &pv->vg->fid->metadata_areas_in_use;
-	vg_mdas_ignored = &pv->vg->fid->metadata_areas_ignored;
-
-	dm_list_iterate_items(mda, &info->mdas) {
-		if (mda_is_ignored(mda) && !mda_ignored)
-			/* Changing an ignored mda to one in_use requires moving it */
-			dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_ignored)
-				if (mda_locns_match(mda, vg_mda)) {
-					mda_set_ignored(vg_mda, mda_ignored);
-					dm_list_move(vg_mdas_in_use, &vg_mda->list);
-				}
-
-		dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_in_use)
-			if (mda_locns_match(mda, vg_mda))
-				/* Don't move mda: needs writing to disk. */
-				mda_set_ignored(vg_mda, mda_ignored);
-
-		mda_set_ignored(mda, mda_ignored);
-	}
-
-	return 1;
-}
-
 int mdas_empty_or_ignored(struct dm_list *mdas)
 {
 	struct metadata_area *mda;
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
new file mode 100644
index 0000000..dc4a300
--- /dev/null
+++ b/lib/metadata/pv.c
@@ -0,0 +1,223 @@
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
+#include "lvmcache.h"
+
+/*
+ * FIXME: Check for valid handle before dereferencing field or log error?
+ */
+#define pv_field(handle, field)	((handle)->field)
+
+/*
+ * Gets/Sets for external LVM library
+ */
+struct id pv_id(const struct physical_volume *pv)
+{
+	return pv_field(pv, id);
+}
+
+const struct format_type *pv_format_type(const struct physical_volume *pv)
+{
+	return pv_field(pv, fmt);
+}
+
+struct id pv_vgid(const struct physical_volume *pv)
+{
+	return pv_field(pv, vgid);
+}
+
+struct device *pv_dev(const struct physical_volume *pv)
+{
+	return pv_field(pv, dev);
+}
+
+const char *pv_vg_name(const struct physical_volume *pv)
+{
+	return pv_field(pv, vg_name);
+}
+
+const char *pv_dev_name(const struct physical_volume *pv)
+{
+	return dev_name(pv_dev(pv));
+}
+
+uint64_t pv_size(const struct physical_volume *pv)
+{
+	return pv_field(pv, size);
+}
+
+uint64_t pv_dev_size(const struct physical_volume *pv)
+{
+	uint64_t size;
+
+	if (!dev_get_size(pv->dev, &size))
+		size = 0;
+	return size;
+}
+
+uint64_t pv_size_field(const struct physical_volume *pv)
+{
+	uint64_t size;
+
+	if (!pv->pe_count)
+		size = pv->size;
+	else
+		size = (uint64_t) pv->pe_count * pv->pe_size;
+	return size;
+}
+
+uint64_t pv_free(const struct physical_volume *pv)
+{
+	uint64_t freespace;
+
+	if (!pv->pe_count)
+		freespace = pv->size;
+	else
+		freespace = (uint64_t)
+			(pv->pe_count - pv->pe_alloc_count) * pv->pe_size;
+	return freespace;
+}
+
+uint64_t pv_status(const struct physical_volume *pv)
+{
+	return pv_field(pv, status);
+}
+
+uint32_t pv_pe_size(const struct physical_volume *pv)
+{
+	return pv_field(pv, pe_size);
+}
+
+uint64_t pv_pe_start(const struct physical_volume *pv)
+{
+	return pv_field(pv, pe_start);
+}
+
+uint32_t pv_pe_count(const struct physical_volume *pv)
+{
+	return pv_field(pv, pe_count);
+}
+
+uint32_t pv_pe_alloc_count(const struct physical_volume *pv)
+{
+	return pv_field(pv, pe_alloc_count);
+}
+
+uint32_t pv_mda_count(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+
+	info = info_from_pvid((const char *)&pv->id.uuid, 0);
+	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
+}
+
+uint32_t pv_mda_used_count(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+	struct metadata_area *mda;
+	uint32_t used_count=0;
+
+	info = info_from_pvid((const char *)&pv->id.uuid, 0);
+	if (!info)
+		return 0;
+	dm_list_iterate_items(mda, &info->mdas) {
+		if (!mda_is_ignored(mda))
+			used_count++;
+	}
+	return used_count;
+}
+
+/**
+ * is_orphan - Determine whether a pv is an orphan based on its vg_name
+ * @pv: handle to the physical volume
+ */
+int is_orphan(const struct physical_volume *pv)
+{
+	return is_orphan_vg(pv_field(pv, vg_name));
+}
+
+/**
+ * is_pv - Determine whether a pv is a real pv or dummy one
+ * @pv: handle to device
+ */
+int is_pv(const struct physical_volume *pv)
+{
+	return (pv_field(pv, vg_name) ? 1 : 0);
+}
+
+int is_missing_pv(const struct physical_volume *pv)
+{
+	return pv_field(pv, status) & MISSING_PV ? 1 : 0;
+}
+
+unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignored)
+{
+	struct lvmcache_info *info;
+	struct metadata_area *mda, *vg_mda, *tmda;
+	struct dm_list *vg_mdas_in_use, *vg_mdas_ignored;
+
+	if (!(info = info_from_pvid((const char *)&pv->id.uuid, 0)))
+		return_0;
+
+	if (is_orphan(pv)) {
+		dm_list_iterate_items(mda, &info->mdas)
+			mda_set_ignored(mda, mda_ignored);
+		return 1;
+	}
+
+	/*
+	 * Do not allow disabling of the the last PV in a VG.
+	 */
+	if (pv_mda_used_count(pv) == vg_mda_used_count(pv->vg)) {
+		log_error("Cannot disable all metadata areas in volume group %s.",
+			  pv->vg->name);
+		return 0;
+	}
+
+	/*
+	 * Non-orphan case is more complex.
+	 * If the PV's mdas are ignored, and we wish to un-ignore,
+	 * we clear the bit and move them from the ignored mda list to the
+	 * in_use list, ensuring the new state will get written to disk
+	 * in the vg_write() path.
+	 * If the PV's mdas are not ignored, and we are setting
+	 * them to ignored, we set the bit but leave them on the in_use
+	 * list, ensuring the new state will get written to disk in the
+	 * vg_write() path.
+	 */
+	vg_mdas_in_use = &pv->vg->fid->metadata_areas_in_use;
+	vg_mdas_ignored = &pv->vg->fid->metadata_areas_ignored;
+
+	dm_list_iterate_items(mda, &info->mdas) {
+		if (mda_is_ignored(mda) && !mda_ignored)
+			/* Changing an ignored mda to one in_use requires moving it */
+			dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_ignored)
+				if (mda_locns_match(mda, vg_mda)) {
+					mda_set_ignored(vg_mda, mda_ignored);
+					dm_list_move(vg_mdas_in_use, &vg_mda->list);
+				}
+
+		dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_in_use)
+			if (mda_locns_match(mda, vg_mda))
+				/* Don't move mda: needs writing to disk. */
+				mda_set_ignored(vg_mda, mda_ignored);
+
+		mda_set_ignored(mda, mda_ignored);
+	}
+
+	return 1;
+}
+
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
new file mode 100644
index 0000000..ba5c4a4
--- /dev/null
+++ b/lib/metadata/pv.h
@@ -0,0 +1,74 @@
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
+#ifndef _PV_H
+#define _PV_H
+
+struct id;
+struct device;
+struct format_type;
+struct volume_group;
+
+struct physical_volume {
+	struct id id;
+	struct device *dev;
+	const struct format_type *fmt;
+
+	/*
+	 * vg_name and vgid are used before the parent VG struct exists.
+	 * FIXME: Investigate removal/substitution with 'vg' fields.
+	 */
+	const char *vg_name;
+	struct id vgid;
+
+	/*
+	 * 'vg' is set and maintained when the PV belongs to a 'pvs'
+	 * list in a parent VG struct.
+	 */
+	struct volume_group *vg;
+
+	uint64_t status;
+	uint64_t size;
+
+	/* physical extents */
+	uint32_t pe_size;
+	uint64_t pe_start;
+	uint32_t pe_count;
+	uint32_t pe_alloc_count;
+	unsigned long pe_align;
+	unsigned long pe_align_offset;
+
+	struct dm_list segments;	/* Ordered pv_segments covering complete PV */
+	struct dm_list tags;
+};
+
+struct device *pv_dev(const struct physical_volume *pv);
+const char *pv_vg_name(const struct physical_volume *pv);
+const char *pv_dev_name(const struct physical_volume *pv);
+uint64_t pv_size(const struct physical_volume *pv);
+uint64_t pv_size_field(const struct physical_volume *pv);
+uint64_t pv_dev_size(const struct physical_volume *pv);
+uint64_t pv_free(const struct physical_volume *pv);
+uint64_t pv_status(const struct physical_volume *pv);
+uint32_t pv_pe_size(const struct physical_volume *pv);
+uint64_t pv_pe_start(const struct physical_volume *pv);
+uint32_t pv_pe_count(const struct physical_volume *pv);
+uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
+uint32_t pv_mda_count(const struct physical_volume *pv);
+uint32_t pv_mda_used_count(const struct physical_volume *pv);
+unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored);
+int is_orphan(const struct physical_volume *pv);
+int is_missing_pv(const struct physical_volume *pv);
+int is_pv(const struct physical_volume *pv);
+
+#endif
-- 
1.7.2.2


