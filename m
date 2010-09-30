From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 13:05:21 -0000
Subject: LVM2 include/.symlinks.in lib/Makefile.in lib/ ...
Message-ID: <20100930130521.19959.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 13:05:20

Modified files:
	include        : .symlinks.in 
	lib            : Makefile.in 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Refactor metadata.[ch] into pv.[ch] for pv functions.
	
	The metadata.[ch] files are very large.  This patch makes a first
	attempt at separating out pv functions and data, particularly
	related to the reporting fields calculations.
	
	More code could be moved here but for now I'm stopping at reporting
	functions 'get' / 'set' functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.166&r2=1.167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.398&r2=1.399

--- LVM2/include/.symlinks.in	2010/09/30 13:04:55	1.4
+++ LVM2/include/.symlinks.in	2010/09/30 13:05:20	1.5
@@ -33,6 +33,7 @@
 @top_srcdir@/lib/metadata/lv_alloc.h
 @top_srcdir@/lib/metadata/metadata.h
 @top_srcdir@/lib/metadata/metadata-exported.h
+ at top_srcdir@/lib/metadata/pv.h
 @top_srcdir@/lib/metadata/pv_alloc.h
 @top_srcdir@/lib/metadata/segtype.h
 @top_srcdir@/lib/metadata/vg.h
--- LVM2/lib/Makefile.in	2010/09/30 13:04:55	1.106
+++ LVM2/lib/Makefile.in	2010/09/30 13:05:20	1.107
@@ -77,6 +77,7 @@
 	metadata/merge.c \
 	metadata/metadata.c \
 	metadata/mirror.c \
+	metadata/pv.c \
 	metadata/pv_manip.c \
 	metadata/pv_map.c \
 	metadata/replicator_manip.c \
--- LVM2/lib/metadata/metadata-exported.h	2010/09/30 13:04:56	1.166
+++ LVM2/lib/metadata/metadata-exported.h	2010/09/30 13:05:20	1.167
@@ -22,6 +22,7 @@
 #define _LVM_METADATA_EXPORTED_H
 
 #include "uuid.h"
+#include "pv.h"
 #include "vg.h"
 
 #define MAX_STRIPES 128U
@@ -175,39 +176,6 @@
 
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
@@ -419,7 +387,6 @@
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct dm_list *mdas, int64_t label_sector);
-int is_pv(struct physical_volume *pv);
 int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	    const char *pv_name);
 int move_pvs_used_by_lv(struct volume_group *vg_from,
@@ -427,8 +394,6 @@
 			const char *lv_name);
 int is_global_vg(const char *vg_name);
 int is_orphan_vg(const char *vg_name);
-int is_orphan(const struct physical_volume *pv);
-int is_missing_pv(const struct physical_volume *pv);
 int vg_missing_pv_count(const struct volume_group *vg);
 int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_from,
@@ -777,21 +742,6 @@
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
--- LVM2/lib/metadata/metadata.c	2010/09/30 13:04:56	1.398
+++ LVM2/lib/metadata/metadata.c	2010/09/30 13:05:20	1.399
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
@@ -3425,29 +3419,6 @@
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
@@ -3791,101 +3762,6 @@
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
@@ -3984,88 +3860,6 @@
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


