From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jul 2009 13:26:03 -0000
Subject: LVM2 ./WHATS_NEW include/.symlinks lib/metadat ...
Message-ID: <20090729132603.6335.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-29 13:26:02

Modified files:
	.              : WHATS_NEW 
	include        : .symlinks 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	liblvm         : Makefile.in lvm_base.c lvm_lv.c lvm_pv.c 
	                 lvm_vg.c 
Added files:
	liblvm         : lvm2app.h 
Removed files:
	liblvm         : lvm.h 

Log message:
	Remove pv_t, vg_t & lv_t handles from lib.  Only liblvm uses them.
	Rename lvm.h to lvm2app.h for now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1208&r2=1.1209
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.273&r2=1.274
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.196&r2=1.197
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.41&r2=NONE

--- LVM2/WHATS_NEW	2009/07/28 20:47:40	1.1208
+++ LVM2/WHATS_NEW	2009/07/29 13:26:01	1.1209
@@ -1,5 +1,7 @@
 Version 2.02.51 - 
 ================================
+  Remove pv_t, vg_t & lv_t handles from lib.  Only liblvm uses them.
+  Rename lvm.h to lvm2app.h for now.
 
 Version 2.02.50 - 28th July 2009
 ================================
--- LVM2/include/.symlinks	2009/03/06 22:49:48	1.58
+++ LVM2/include/.symlinks	2009/07/29 13:26:01	1.59
@@ -1,6 +1,6 @@
 ../daemons/clvmd/clvm.h
 ../daemons/dmeventd/libdevmapper-event.h
-../liblvm/lvm.h
+../liblvm/lvm2app.h
 ../lib/activate/activate.h
 ../lib/activate/targets.h
 ../lib/cache/lvmcache.h
--- LVM2/lib/metadata/metadata-exported.h	2009/07/28 15:14:56	1.105
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/29 13:26:01	1.106
@@ -22,7 +22,6 @@
 #define _LVM_METADATA_EXPORTED_H
 
 #include "uuid.h"
-#include "lvm.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
@@ -238,8 +237,7 @@
 	struct dm_list tags;
 
 	/*
-	 * vg_t handle fields.
-	 * FIXME: Split these out.
+	 * FIXME: Move the next fields into a different struct?
 	 */
 
 	/*
@@ -361,8 +359,9 @@
 	unsigned yes;
 };
 
-pv_t * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
-		       struct pvcreate_params *pp);
+struct physical_volume *pvcreate_single(struct cmd_context *cmd,
+					const char *pv_name,
+					struct pvcreate_params *pp);
 
 /*
 * Utility functions
@@ -392,14 +391,14 @@
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct dm_list *mdas, int64_t label_sector);
-int is_pv(pv_t *pv);
+int is_pv(struct physical_volume *pv);
 int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	    const char *pv_name);
 int move_pvs_used_by_lv(struct volume_group *vg_from,
 			struct volume_group *vg_to,
 			const char *lv_name);
 int is_orphan_vg(const char *vg_name);
-int is_orphan(const pv_t *pv);
+int is_orphan(const struct physical_volume *pv);
 int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_from,
 		       struct volume_group *vg_to);
@@ -408,19 +407,19 @@
 /*
  * Return a handle to VG metadata.
  */
-vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
+struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
               const char *vgid, uint32_t flags);
-vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
+struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
                          const char *vgid, uint32_t flags);
 
 /* 
  * Test validity of a VG handle.
  */
-uint32_t vg_read_error(vg_t *vg_handle);
+uint32_t vg_read_error(struct volume_group *vg_handle);
 
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
-pv_t *pv_create(const struct cmd_context *cmd,
+struct physical_volume *pv_create(const struct cmd_context *cmd,
 		      struct device *dev,
 		      struct id *id,
 		      uint64_t size,
@@ -438,17 +437,17 @@
 /* FIXME: move internal to library */
 uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
-vg_t *vg_create(struct cmd_context *cmd, const char *vg_name);
+struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove(struct volume_group *vg);
-int vg_remove_single(vg_t *vg);
+int vg_remove_single(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
 int vg_reduce(struct volume_group *vg, char *pv_name);
-int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
-int vg_set_max_lv(vg_t *vg, uint32_t max_lv);
-int vg_set_max_pv(vg_t *vg, uint32_t max_pv);
-int vg_set_alloc_policy(vg_t *vg, alloc_policy_t alloc);
+int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size);
+int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv);
+int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv);
+int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
@@ -574,7 +573,7 @@
 /* Find a PV within a given VG */
 struct pv_list *find_pv_in_vg(const struct volume_group *vg,
 			      const char *pv_name);
-pv_t *find_pv_in_vg_by_uuid(const struct volume_group *vg,
+struct physical_volume *find_pv_in_vg_by_uuid(const struct volume_group *vg,
 			    const struct id *id);
 
 /* Find an LV within a given VG */
@@ -692,29 +691,29 @@
 /*
 * Begin skeleton for external LVM library
 */
-struct device *pv_dev(const pv_t *pv);
-const char *pv_vg_name(const pv_t *pv);
-const char *pv_dev_name(const pv_t *pv);
-uint64_t pv_size(const pv_t *pv);
-uint32_t pv_status(const pv_t *pv);
-uint32_t pv_pe_size(const pv_t *pv);
-uint64_t pv_pe_start(const pv_t *pv);
-uint32_t pv_pe_count(const pv_t *pv);
-uint32_t pv_pe_alloc_count(const pv_t *pv);
-uint32_t pv_mda_count(const pv_t *pv);
-
-uint64_t lv_size(const lv_t *lv);
-
-int vg_missing_pv_count(const vg_t *vg);
-uint32_t vg_seqno(const vg_t *vg);
-uint32_t vg_status(const vg_t *vg);
-uint64_t vg_size(const vg_t *vg);
-uint64_t vg_free(const vg_t *vg);
-uint64_t vg_extent_size(const vg_t *vg);
-uint64_t vg_extent_count(const vg_t *vg);
-uint64_t vg_free_count(const vg_t *vg);
-uint64_t vg_pv_count(const vg_t *vg);
-int vg_check_write_mode(vg_t *vg);
+struct device *pv_dev(const struct physical_volume *pv);
+const char *pv_vg_name(const struct physical_volume *pv);
+const char *pv_dev_name(const struct physical_volume *pv);
+uint64_t pv_size(const struct physical_volume *pv);
+uint32_t pv_status(const struct physical_volume *pv);
+uint32_t pv_pe_size(const struct physical_volume *pv);
+uint64_t pv_pe_start(const struct physical_volume *pv);
+uint32_t pv_pe_count(const struct physical_volume *pv);
+uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
+uint32_t pv_mda_count(const struct physical_volume *pv);
+
+uint64_t lv_size(const struct logical_volume *lv);
+
+int vg_missing_pv_count(const struct volume_group *vg);
+uint32_t vg_seqno(const struct volume_group *vg);
+uint32_t vg_status(const struct volume_group *vg);
+uint64_t vg_size(const struct volume_group *vg);
+uint64_t vg_free(const struct volume_group *vg);
+uint64_t vg_extent_size(const struct volume_group *vg);
+uint64_t vg_extent_count(const struct volume_group *vg);
+uint64_t vg_free_count(const struct volume_group *vg);
+uint64_t vg_pv_count(const struct volume_group *vg);
+int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 
 struct vgcreate_params {
--- LVM2/lib/metadata/metadata.c	2009/07/28 20:41:41	1.273
+++ LVM2/lib/metadata/metadata.c	2009/07/29 13:26:01	1.274
@@ -58,9 +58,6 @@
 static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
 						      const struct id *id);
 
-static vg_t *_vg_make_handle(struct cmd_context *cmd,
-			     struct volume_group *vg,
-			     uint32_t failure);
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint32_t status);
 
@@ -429,7 +426,7 @@
 	return 1;
 }
 
-int vg_remove_single(vg_t *vg)
+int vg_remove_single(struct volume_group *vg)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -629,16 +626,42 @@
 }
 
 /*
+ * Create a (struct volume_group) volume group handle from a struct volume_group pointer and a
+ * possible failure code or zero for success.
+ */
+static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
+			     struct volume_group *vg,
+			     uint32_t failure)
+{
+	struct dm_pool *vgmem;
+
+	if (!vg) {
+		if (!(vgmem = dm_pool_create("lvm2 vg_handle", VG_MEMPOOL_CHUNK)) ||
+		    !(vg = dm_pool_zalloc(vgmem, sizeof(*vg)))) {
+			log_error("Error allocating vg handle.");
+			if (vgmem)
+				dm_pool_destroy(vgmem);
+			return_NULL;
+		}
+		vg->vgmem = vgmem;
+	}
+
+	vg->read_status = failure;
+
+	return (struct volume_group *)vg;
+}
+
+/*
  * Create a VG with default parameters.
  * Returns:
- * - vg_t* with SUCCESS code: VG structure created
- * - NULL or vg_t* with FAILED_* code: error creating VG structure
+ * - struct volume_group* with SUCCESS code: VG structure created
+ * - NULL or struct volume_group* with FAILED_* code: error creating VG structure
  * Use vg_read_error() to determine success or failure.
  * FIXME: cleanup usage of _vg_make_handle()
  */
-vg_t *vg_create(struct cmd_context *cmd, const char *vg_name)
+struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 {
-	vg_t *vg;
+	struct volume_group *vg;
 	int consistent = 0;
 	struct dm_pool *mem;
 	uint32_t rc;
@@ -778,7 +801,7 @@
 	return 1;
 }
 
-int vg_set_extent_size(vg_t *vg, uint32_t new_size)
+int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;
 	struct pv_list *pvl;
@@ -925,7 +948,7 @@
 	return 1;
 }
 
-int vg_set_max_lv(vg_t *vg, uint32_t max_lv)
+int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv)
 {
 	if (!(vg_status(vg) & RESIZEABLE_VG)) {
 		log_error("Volume group \"%s\" must be resizeable "
@@ -953,7 +976,7 @@
 	return 1;
 }
 
-int vg_set_max_pv(vg_t *vg, uint32_t max_pv)
+int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv)
 {
 	if (!(vg_status(vg) & RESIZEABLE_VG)) {
 		log_error("Volume group \"%s\" must be resizeable "
@@ -980,7 +1003,7 @@
 	return 1;
 }
 
-int vg_set_alloc_policy(vg_t *vg, alloc_policy_t alloc)
+int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc)
 {
 	if (alloc == ALLOC_INHERIT) {
 		log_error("Volume Group allocation policy cannot inherit "
@@ -1189,9 +1212,9 @@
  *
  * Returns:
  * NULL: error
- * pv_t * (non-NULL): handle to physical volume created
+ * struct physical_volume * (non-NULL): handle to physical volume created
  */
-pv_t * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+struct physical_volume * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 		       struct pvcreate_params *pp)
 {
 	void *pv;
@@ -1452,7 +1475,7 @@
  * Note
  *   FIXME - liblvm todo - make into function that takes VG handle
  */
-pv_t *find_pv_in_vg_by_uuid(const struct volume_group *vg,
+struct physical_volume *find_pv_in_vg_by_uuid(const struct volume_group *vg,
 			    const struct id *id)
 {
 	return _find_pv_in_vg_by_uuid(vg, id);
@@ -2277,7 +2300,7 @@
 	return 1;
 }
 
-int vg_missing_pv_count(const vg_t *vg)
+int vg_missing_pv_count(const struct volume_group *vg)
 {
 	int ret = 0;
 	struct pv_list *pvl;
@@ -2986,7 +3009,7 @@
  * is_orphan - Determine whether a pv is an orphan based on its vg_name
  * @pv: handle to the physical volume
  */
-int is_orphan(const pv_t *pv)
+int is_orphan(const struct physical_volume *pv)
 {
 	return is_orphan_vg(pv_field(pv, vg_name));
 }
@@ -2995,7 +3018,7 @@
  * is_pv - Determine whether a pv is a real pv or dummy one
  * @pv: handle to device
  */
-int is_pv(pv_t *pv)
+int is_pv(struct physical_volume *pv)
 {
 	return (pv_field(pv, vg_name) ? 1 : 0);
 }
@@ -3043,7 +3066,7 @@
 }
 
 /* FIXME: remove / combine this with locking? */
-int vg_check_write_mode(vg_t *vg)
+int vg_check_write_mode(struct volume_group *vg)
 {
 	if (vg->open_mode != 'w') {
 		log_errno(EPERM, "Attempt to modify a read-only VG");
@@ -3101,33 +3124,7 @@
 	return !_vg_bad_status_bits(vg, status);
 }
 
-/*
- * Create a (vg_t) volume group handle from a struct volume_group pointer and a
- * possible failure code or zero for success.
- */
-static vg_t *_vg_make_handle(struct cmd_context *cmd,
-			     struct volume_group *vg,
-			     uint32_t failure)
-{
-	struct dm_pool *vgmem;
-
-	if (!vg) {
-		if (!(vgmem = dm_pool_create("lvm2 vg_handle", VG_MEMPOOL_CHUNK)) ||
-		    !(vg = dm_pool_zalloc(vgmem, sizeof(*vg)))) {
-			log_error("Error allocating vg handle.");
-			if (vgmem)
-				dm_pool_destroy(vgmem);
-			return_NULL;
-		}
-		vg->vgmem = vgmem;
-	}
-
-	vg->read_status = failure;
-
-	return (vg_t *)vg;
-}
-
-static vg_t *_recover_vg(struct cmd_context *cmd, const char *lock_name,
+static struct volume_group *_recover_vg(struct cmd_context *cmd, const char *lock_name,
 			 const char *vg_name, const char *vgid,
 			 uint32_t lock_flags)
 {
@@ -3152,7 +3149,7 @@
 		return_NULL;
 	}
 
-	return (vg_t *)vg;
+	return (struct volume_group *)vg;
 }
 
 /*
@@ -3166,7 +3163,7 @@
  * problems reading the volume group.
  * Zero value means that the VG is open and appropriate locks are held.
  */
-static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
+static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 			       const char *vgid, uint32_t lock_flags,
 			       uint32_t status_flags, uint32_t misc_flags)
 {
@@ -3279,7 +3276,7 @@
  * toollib just set lock_flags to LCK_VG_WRITE and called vg_read_internal with
  * *consistent = 1.
  */
-vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
+struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
 	      const char *vgid, uint32_t flags)
 {
 	uint32_t status = 0;
@@ -3301,7 +3298,7 @@
  * later update (this means the user code can change the metadata and later
  * request the new metadata to be written and committed).
  */
-vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
+struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
 			 const char *vgid, uint32_t flags)
 {
 	return vg_read(cmd, vg_name, vgid, flags | READ_FOR_UPDATE);
@@ -3310,7 +3307,7 @@
 /*
  * Test the validity of a VG handle returned by vg_read() or vg_read_for_update().
  */
-uint32_t vg_read_error(vg_t *vg_handle)
+uint32_t vg_read_error(struct volume_group *vg_handle)
 {
 	if (!vg_handle)
 		return FAILED_ALLOCATION;
@@ -3366,67 +3363,67 @@
 /*
  * Gets/Sets for external LVM library
  */
-struct id pv_id(const pv_t *pv)
+struct id pv_id(const struct physical_volume *pv)
 {
 	return pv_field(pv, id);
 }
 
-const struct format_type *pv_format_type(const pv_t *pv)
+const struct format_type *pv_format_type(const struct physical_volume *pv)
 {
 	return pv_field(pv, fmt);
 }
 
-struct id pv_vgid(const pv_t *pv)
+struct id pv_vgid(const struct physical_volume *pv)
 {
 	return pv_field(pv, vgid);
 }
 
-struct device *pv_dev(const pv_t *pv)
+struct device *pv_dev(const struct physical_volume *pv)
 {
 	return pv_field(pv, dev);
 }
 
-const char *pv_vg_name(const pv_t *pv)
+const char *pv_vg_name(const struct physical_volume *pv)
 {
 	return pv_field(pv, vg_name);
 }
 
-const char *pv_dev_name(const pv_t *pv)
+const char *pv_dev_name(const struct physical_volume *pv)
 {
 	return dev_name(pv_dev(pv));
 }
 
-uint64_t pv_size(const pv_t *pv)
+uint64_t pv_size(const struct physical_volume *pv)
 {
 	return pv_field(pv, size);
 }
 
-uint32_t pv_status(const pv_t *pv)
+uint32_t pv_status(const struct physical_volume *pv)
 {
 	return pv_field(pv, status);
 }
 
-uint32_t pv_pe_size(const pv_t *pv)
+uint32_t pv_pe_size(const struct physical_volume *pv)
 {
 	return pv_field(pv, pe_size);
 }
 
-uint64_t pv_pe_start(const pv_t *pv)
+uint64_t pv_pe_start(const struct physical_volume *pv)
 {
 	return pv_field(pv, pe_start);
 }
 
-uint32_t pv_pe_count(const pv_t *pv)
+uint32_t pv_pe_count(const struct physical_volume *pv)
 {
 	return pv_field(pv, pe_count);
 }
 
-uint32_t pv_pe_alloc_count(const pv_t *pv)
+uint32_t pv_pe_alloc_count(const struct physical_volume *pv)
 {
 	return pv_field(pv, pe_alloc_count);
 }
 
-uint32_t pv_mda_count(const pv_t *pv)
+uint32_t pv_mda_count(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info;
 
@@ -3434,47 +3431,47 @@
 	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
 }
 
-uint32_t vg_seqno(const vg_t *vg)
+uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
 }
 
-uint32_t vg_status(const vg_t *vg)
+uint32_t vg_status(const struct volume_group *vg)
 {
 	return vg->status;
 }
 
-uint64_t vg_size(const vg_t *vg)
+uint64_t vg_size(const struct volume_group *vg)
 {
 	return (uint64_t) vg->extent_count * vg->extent_size;
 }
 
-uint64_t vg_free(const vg_t *vg)
+uint64_t vg_free(const struct volume_group *vg)
 {
 	return (uint64_t) vg->free_count * vg->extent_size;
 }
 
-uint64_t vg_extent_size(const vg_t *vg)
+uint64_t vg_extent_size(const struct volume_group *vg)
 {
 	return (uint64_t) vg->extent_size;
 }
 
-uint64_t vg_extent_count(const vg_t *vg)
+uint64_t vg_extent_count(const struct volume_group *vg)
 {
 	return (uint64_t) vg->extent_count;
 }
 
-uint64_t vg_free_count(const vg_t *vg)
+uint64_t vg_free_count(const struct volume_group *vg)
 {
 	return (uint64_t) vg->free_count;
 }
 
-uint64_t vg_pv_count(const vg_t *vg)
+uint64_t vg_pv_count(const struct volume_group *vg)
 {
 	return (uint64_t) vg->pv_count;
 }
 
-uint64_t lv_size(const lv_t *lv)
+uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
 }
@@ -3490,7 +3487,7 @@
  *
  * FIXME: merge with find_pv_by_name ?
  */
-pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name)
+struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name)
 {
 	struct dm_list mdas;
 
--- LVM2/lib/metadata/metadata.h	2009/06/01 12:43:32	1.196
+++ LVM2/lib/metadata/metadata.h	2009/07/29 13:26:01	1.197
@@ -368,11 +368,11 @@
 /*
  * Begin skeleton for external LVM library
  */
-struct id pv_id(const pv_t *pv);
-const struct format_type *pv_format_type(const pv_t *pv);
-struct id pv_vgid(const pv_t *pv);
+struct id pv_id(const struct physical_volume *pv);
+const struct format_type *pv_format_type(const struct physical_volume *pv);
+struct id pv_vgid(const struct physical_volume *pv);
 
-pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name);
+struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv);
 
/cvs/lvm2/LVM2/liblvm/lvm2app.h,v  -->  standard output
revision 1.1
--- LVM2/liblvm/lvm2app.h
+++ -	2009-07-29 13:26:03.035391000 +0000
@@ -0,0 +1,829 @@
+/*
+ * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
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
+#ifndef _LIB_LVM2APP_H
+#define _LIB_LVM2APP_H
+
+#include "lvm-version.h"
+#include "libdevmapper.h"
+
+#include <stdint.h>
+
+
+/******************************** WARNING ***********************************
+ *
+ * NOTE: This API is under development and subject to change at any time.
+ *
+ * Please send feedback to lvm-devel at redhat.com
+ *
+ *********************************** WARNING ********************************/
+
+/*************************** Design Overview ********************************/
+
+/**
+ * \mainpage LVM library API
+ *
+ * The API is designed around the following basic LVM objects:
+ * 1) Physical Volume (PV) 2) Volume Group (VG) 3) Logical Volume (LV).
+ *
+ * The library provides functions to list the objects in a system,
+ * get and set object properties (such as names, UUIDs, and sizes), as well
+ * as create/remove objects and perform more complex operations and
+ * transformations. Each object instance is represented by a handle, and
+ * handles are passed to and from the functions to perform the operations.
+ *
+ * A central object in the library is the Volume Group, represented by the
+ * VG handle, vg_t. Performing an operation on a PV or LV object first
+ * requires obtaining a VG handle. Once the vg_t has been obtained, it can
+ * be used to enumerate the pv_t's and lv_t's within that vg_t. Attributes
+ * of these objects can then be queried.
+ *
+ * A volume group handle may be obtained with read or write permission.
+ * Any attempt to change a property of a pv_t, vg_t, or lv_t without
+ * obtaining write permission on the vg_t will fail with EPERM.
+ *
+ * An application first opening a VG read-only, then later wanting to change
+ * a property of an object must first close the VG and re-open with write
+ * permission. Currently liblvm provides no mechanism to determine whether
+ * the VG has changed on-disk in between these operations - this is the
+ * application's responsiblity. One way the application can ensure the VG
+ * has not changed is to save the "vg_seqno" field after opening the VG with
+ * READ permission. If the application later needs to modify the VG, it can
+ * close the VG and re-open with WRITE permission. It should then check
+ * whether the original "vg_seqno" obtained with READ permission matches
+ * the new one obtained with WRITE permission.
+ */
+
+/**
+ * Retrieve the library version.
+ *
+ * The library version is the same format as the full LVM version.
+ * The format is as follows:
+ *    LVM_MAJOR.LVM_MINOR.LVM_PATCHLEVEL(LVM_LIBAPI)[-LVM_RELEASE]
+ * An application wishing to determine compatibility with a particular version
+ * of the library should check at least the LVM_MAJOR, LVM_MINOR, and
+ * LVM_LIBAPI numbers.  For example, assume the full LVM version is
+ * 2.02.50(1)-1.  The application should verify the "2.02" and the "(1)".
+ *
+ * \return  A string describing the library version.
+ */
+const char *lvm_library_get_version(void);
+
+/******************************** structures ********************************/
+
+/**
+ * Opaque structures - do not use directly.  Internal structures may change
+ * without notice between releases, whereas this API will be changed much less
+ * frequently.  Backwards compatibility will normally be preserved in future
+ * releases.  On any occasion when the developers do decide to break backwards
+ * compatibility in any significant way, the LVM_LIBAPI number (included in
+ * the library's soname) will be incremented.
+ */
+struct lvm;
+struct physical_volume;
+struct volume_group;
+struct logical_volume;
+
+/**
+ * lvm handle.
+ *
+ * This is the base handle that is needed to open and create objects such as
+ * volume groups and logical volumes.  In addition, this handle provides a
+ * context for error handling information, saving any error number (see
+ * lvm_errno) and error message (see lvm_errmsg) that any function may
+ * generate.
+ */
+typedef struct lvm *lvm_t;
+
+/**
+ * Volume group object.
+ *
+ * This object can be either a read-only object or a read-write object
+ * depending on the mode it was returned by a function. Create functions
+ * return a read-write object, but open functions have the argument mode to
+ * define if the object can be modified or not.
+ */
+typedef struct volume_group vg_t;
+
+/**
+ * Logical Volume object.
+ *
+ * This object is bound to a volume group and has the same mode of the volume
+ * group.  Changes will be written to disk when the volume group gets
+ * committed to disk.
+ */
+typedef struct logical_volume lv_t;
+
+/**
+ * Physical volume object.
+ *
+ * This object is bound to a volume group and has the same mode of the volume
+ * group.  Changes will be written to disk when the volume group gets
+ * committed to disk.
+ */
+typedef struct physical_volume pv_t;
+
+/**
+ * Logical Volume object list.
+ *
+ * Lists of these structures are returned by lvm_vg_list_pvs.
+ */
+typedef struct lvm_lv_list {
+	struct dm_list list;
+	lv_t *lv;
+} lv_list_t;
+
+/**
+ * Physical volume object list.
+ *
+ * Lists of these structures are returned by lvm_vg_list_pvs.
+ */
+typedef struct lvm_pv_list {
+	struct dm_list list;
+	pv_t *pv;
+} pv_list_t;
+
+/**
+ * String list.
+ *
+ * This string list contains read-only strings.
+ * Lists of these structures are returned by lvm_list_vg_names and
+ * lvm_list_vg_uuids.
+ */
+struct lvm_str_list {
+	struct dm_list list;
+	const char *str;
+};
+
+/*************************** generic lvm handling ***************************/
+/**
+ * Create a LVM handle.
+ *
+ * Once all LVM operations have been completed, use lvm_quit to release
+ * the handle and any associated resources.
+ *
+ * \param system_dir
+ * Set an alternative LVM system directory. Use NULL to use the
+ * default value. If the environment variable LVM_SYSTEM_DIR is set,
+ * it will override any system_dir setting.
+ *
+ * \return
+ * A valid LVM handle is returned or NULL if there has been a
+ * memory allocation problem. You have to check if an error occured
+ * with the lvm_error function.
+ */
+lvm_t lvm_init(const char *system_dir);
+
+/**
+ * Destroy a LVM handle allocated with lvm_init.
+ *
+ * This function should be used after all LVM operations are complete or after
+ * an unrecoverable error.  Destroying the LVM handle frees the memory and
+ * other resources associated with the handle.  Once destroyed, the handle
+ * cannot be used subsequently.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init.
+ */
+void lvm_quit(lvm_t libh);
+
+/**
+ * Reload the original configuration from the system directory.
+ *
+ * This function should be used when any LVM configuration changes in the LVM
+ * system_dir or by another lvm_config* function, and the change is needed by
+ * the application.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_config_reload(lvm_t libh);
+
+/**
+ * Override the LVM configuration with a configuration string.
+ *
+ * This function is equivalent to the --config option on lvm commands.
+ * Once this API has been used to over-ride the configuration,
+ * use lvm_config_reload to apply the new settings.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init.
+ *
+ * \param   config_string
+ * LVM configuration string to apply.  See the lvm.conf file man page
+ * for the format of the config string.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_config_override(lvm_t libh, const char *config_string);
+
+/**
+ * Return stored error no describing last LVM API error.
+ *
+ * Users of liblvm should use lvm_errno to determine the details of a any
+ * failure of the last call.  A basic success or fail is always returned by
+ * every function, either by returning a 0 or -1, or a non-NULL / NULL.
+ * If a function has failed, lvm_errno may be used to get a more specific
+ * error code describing the failure.  In this way, lvm_errno may be used
+ * after every function call, even after a 'get' function call that simply
+ * returns a value.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init.
+ *
+ * \return
+ * An errno value describing the last LVM error.
+ */
+int lvm_errno(lvm_t libh);
+
+/**
+ * Return stored error message describing last LVM error.
+ *
+ * This function may be used in conjunction with lvm_errno to obtain more
+ * specific error information for a function that is known to have failed.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init.
+ *
+ * \return
+ * An error string describing the last LVM error.
+ */
+const char *lvm_errmsg(lvm_t libh);
+
+/**
+ * Scan all devices on the system for VGs and LVM metadata.
+ * FIXME: Elaborate on when to use, side-effects, .cache file, etc
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_scan(lvm_t libh);
+
+/*************************** volume group handling **************************/
+
+/**
+ * Return the list of volume group names.
+ *
+ * The memory allocated for the list is tied to the lvm_t handle and will be
+ * released when lvm_quit is called.
+ *
+ * NOTE: This function normally does not scan devices in the system for LVM
+ * metadata.  To scan the system, use lvm_scan.
+ * NOTE: This function currently returns hidden VG names.  These names always
+ * begin with a "#" and should be filtered out and not used.
+ *
+ * To process the list, use the dm_list iterator functions.  For example:
+ *      vg_t *vg;
+ *      struct dm_list *vgnames;
+ *      struct lvm_str_list *strl;
+ *
+ *      vgnames = lvm_list_vg_names(libh);
+ *	dm_list_iterate_items(strl, vgnames) {
+ *		vgname = strl->str;
+ *              vg = lvm_vg_open(libh, vgname, "r");
+ *              // do something with vg
+ *              lvm_vg_close(vg);
+ *      }
+ *
+ *
+ * \return
+ * A list with entries of type struct lvm_str_list, containing the
+ * VG name strings of the Volume Groups known to the system.
+ * NULL is returned if unable to allocate memory.
+ * An empty list (verify with dm_list_empty) is returned if no VGs
+ * exist on the system.
+ */
+struct dm_list *lvm_list_vg_names(lvm_t libh);
+
+/**
+ * Return the list of volume group uuids.
+ *
+ * The memory allocated for the list is tied to the lvm_t handle and will be
+ * released when lvm_quit is called.
+ *
+ * NOTE: This function normally does not scan devices in the system for LVM
+ * metadata.  To scan the system, use lvm_scan.
+ * NOTE: This function currently returns hidden VG names.  These names always
+ * begin with a "#" and should be filtered out and not used.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init.
+ *
+ * \return
+ * A list with entries of type struct lvm_str_list, containing the
+ * VG UUID strings of the Volume Groups known to the system.
+ * NULL is returned if unable to allocate memory.
+ * An empty list (verify with dm_list_empty) is returned if no VGs
+ * exist on the system.
+ */
+struct dm_list *lvm_list_vg_uuids(lvm_t libh);
+
+/**
+ * Open an existing VG.
+ *
+ * Open a VG for reading or writing.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init.
+ *
+ * \param   vgname
+ * Name of the VG to open.
+ *
+ * \param   mode
+ * Open mode - either "r" (read) or "w" (read/write).
+ * Any other character results in an error with EINVAL set.
+ *
+ * \param   flags
+ * Open flags - currently ignored.
+ *
+ * \return  non-NULL VG handle (success) or NULL (failure).
+ */
+vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
+		  uint32_t flags);
+
+/**
+ * Create a VG with default parameters.
+ *
+ * This function creates a Volume Group object in memory.
+ * Upon success, other APIs may be used to set non-default parameters.
+ * For example, to set a non-default extent size, use lvm_vg_set_extent_size.
+ * Next, to add physical storage devices to the volume group, use
+ * lvm_vg_extend for each device.
+ * Once all parameters are set appropriately and all devices are added to the
+ * VG, use lvm_vg_write to commit the new VG to disk, and lvm_vg_close to
+ * release the VG handle.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init.
+ *
+ * \param   vg_name
+ * Name of the VG to open.
+ *
+ * \return
+ * non-NULL vg handle (success) or NULL (failure)
+ */
+vg_t *lvm_vg_create(lvm_t libh, const char *vg_name);
+
+ /**
+ * Write a VG to disk.
+ *
+ * This function commits the Volume Group object referenced by the VG handle
+ * to disk. Upon failure, retry the operation and/or release the VG handle
+ * with lvm_vg_close.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_write(vg_t *vg);
+
+/**
+ * Remove a VG from the system.
+ *
+ * This function commits the change to disk and does not require calling
+ * lvm_vg_write.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_remove(vg_t *vg);
+
+/**
+ * Close a VG opened with lvm_vg_create or lvm_vg_open.
+ *
+ * This function releases a VG handle and any resources associated with the
+ * handle.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_close(vg_t *vg);
+
+/**
+ * Extend a VG by adding a device.
+ *
+ * This function requires calling lvm_vg_write to commit the change to disk.
+ * After successfully adding a device, use lvm_vg_write to commit the new VG
+ * to disk.  Upon failure, retry the operation or release the VG handle with
+ * lvm_vg_close.
+ * If the device is not initialized for LVM use, it will be initialized
+ * before adding to the VG.  Although some internal checks are done,
+ * the caller should be sure the device is not in use by other subsystems
+ * before calling lvm_vg_extend.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \param   device
+ * Absolute pathname of device to add to VG.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_extend(vg_t *vg, const char *device);
+
+/**
+ * Reduce a VG by removing an unused device.
+ *
+ * This function requires calling lvm_vg_write to commit the change to disk.
+ * After successfully removing a device, use lvm_vg_write to commit the new VG
+ * to disk.  Upon failure, retry the operation or release the VG handle with
+ * lvm_vg_close.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \param   device
+ * Name of device to remove from VG.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_reduce(vg_t *vg, const char *device);
+
+/**
+ * Set the extent size of a VG.
+ *
+ * This function requires calling lvm_vg_write to commit the change to disk.
+ * After successfully setting a new extent size, use lvm_vg_write to commit
+ * the new VG to disk.  Upon failure, retry the operation or release the VG
+ * handle with lvm_vg_close.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \param   new_size
+ * New extent size in bytes.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
+
+/**
+ * Get the current metadata sequence number of a volume group.
+ *
+ * The metadata sequence number is incrented for each metadata change.
+ * Applications may use the sequence number to determine if any LVM objects
+ * have changed from a prior query.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Metadata sequence number.
+ */
+uint64_t lvm_vg_get_seqno(const vg_t *vg);
+
+/**
+ * Get the current name of a volume group.
+ *
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Copy of the uuid string.
+ */
+char *lvm_vg_get_uuid(const vg_t *vg);
+
+/**
+ * Get the current uuid of a volume group.
+ *
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Copy of the name.
+ */
+char *lvm_vg_get_name(const vg_t *vg);
+
+/**
+ * Get the current size in bytes of a volume group.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Size in bytes.
+ */
+uint64_t lvm_vg_get_size(const vg_t *vg);
+
+/**
+ * Get the current unallocated space in bytes of a volume group.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Free size in bytes.
+ */
+uint64_t lvm_vg_get_free_size(const vg_t *vg);
+
+/**
+ * Get the current extent size in bytes of a volume group.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Extent size in bytes.
+ */
+uint64_t lvm_vg_get_extent_size(const vg_t *vg);
+
+/**
+ * Get the current number of total extents of a volume group.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Extent count.
+ */
+uint64_t lvm_vg_get_extent_count(const vg_t *vg);
+
+/**
+ * Get the current number of free extents of a volume group.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Free extent count.
+ */
+uint64_t lvm_vg_get_free_extent_count(const vg_t *vg);
+
+/**
+ * Get the current number of physical volumes of a volume group.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Physical volume count.
+ */
+uint64_t lvm_vg_get_pv_count(const vg_t *vg);
+
+/************************** logical volume handling *************************/
+
+/**
+ * Return a list of LV handles for a given VG handle.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * A list of lv_list_t structures containing lv handles for this vg.
+ * If no LVs exist on the given VG, NULL is returned.
+ */
+struct dm_list *lvm_vg_list_lvs(vg_t *vg);
+
+/**
+ * Create a linear logical volume.
+ * This function commits the change to disk and does _not_ require calling
+ * lvm_vg_write.
+ * NOTE: The commit behavior of this function is subject to change
+ * as the API is developed.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \param   name
+ * Name of logical volume to create.
+ *
+ * \param   size
+ * Size of logical volume in extents.
+ *
+ * \return
+ * non-NULL handle to an LV object created, or NULL if creation fails.
+ *
+ */
+lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size);
+
+/**
+ * Activate a logical volume.
+ *
+ * This function is the equivalent of the lvm command "lvchange -ay".
+ *
+ * NOTE: This function cannot currently handle LVs with an in-progress pvmove or
+ * lvconvert.
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_lv_activate(lv_t *lv);
+
+/**
+ * Deactivate a logical volume.
+ *
+ * This function is the equivalent of the lvm command "lvchange -an".
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_lv_deactivate(lv_t *lv);
+
+/**
+ * Remove a logical volume from a volume group.
+ *
+ * This function commits the change to disk and does _not_ require calling
+ * lvm_vg_write.
+ * NOTE: The commit behavior of this function is subject to change
+ * as the API is developed.
+ * Currently only removing linear LVs are possible.
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_remove_lv(lv_t *lv);
+
+/**
+ * Get the current name of a logical volume.
+ *
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * Copy of the uuid string.
+ */
+char *lvm_lv_get_uuid(const lv_t *lv);
+
+/**
+ * Get the current uuid of a logical volume.
+ *
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * Copy of the name.
+ */
+char *lvm_lv_get_name(const lv_t *lv);
+
+/**
+ * Get the current size in bytes of a logical volume.
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * Size in bytes.
+ */
+uint64_t lvm_lv_get_size(const lv_t *lv);
+
+/**
+ * Get the current activation state of a logical volume.
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * 1 if the LV is active in the kernel, 0 if not
+ */
+uint64_t lvm_lv_is_active(const lv_t *lv);
+
+/**
+ * Get the current suspended state of a logical volume.
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * 1 if the LV is suspended in the kernel, 0 if not
+ */
+uint64_t lvm_lv_is_suspended(const lv_t *lv);
+
+/**
+ * Resize logical volume to new_size bytes.
+ *
+ * NOTE: This function is currently not implemented.
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \param   new_size
+ * New size in bytes.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ *
+ */
+int lvm_lv_resize(const lv_t *lv, uint64_t new_size);
+
+/************************** physical volume handling ************************/
+
+/**
+ * Physical volume handling should not be needed anymore. Only physical volumes
+ * bound to a vg contain useful information. Therefore the creation,
+ * modification and the removal of orphan physical volumes is not suported.
+ */
+
+/**
+ * Return a list of PV handles for a given VG handle.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * A list of pv_list_t structures containing pv handles for this vg.
+ * If no PVs exist on the given VG, NULL is returned.
+ */
+struct dm_list *lvm_vg_list_pvs(vg_t *vg);
+
+/**
+ * Get the current uuid of a logical volume.
+ *
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \return
+ * Copy of the uuid string.
+ */
+char *lvm_pv_get_uuid(const pv_t *pv);
+
+/**
+ * Get the current name of a logical volume.
+ *
+ * Memory is allocated using dm_malloc() and caller must free the memory
+ * using dm_free().
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \return
+ * Copy of the name.
+ */
+char *lvm_pv_get_name(const pv_t *pv);
+
+/**
+ * Get the current number of metadata areas in the physical volume.
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \return
+ * Number of metadata areas in the PV.
+ */
+uint64_t lvm_pv_get_mda_count(const pv_t *pv);
+
+/**
+ * Resize physical volume to new_size bytes.
+ *
+ * NOTE: This function is currently not implemented.
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \param   new_size
+ * New size in bytes.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_pv_resize(const pv_t *pv, uint64_t new_size);
+
+#endif /* _LIB_LVM2APP_H */
--- LVM2/liblvm/Makefile.in	2009/07/23 23:40:05	1.11
+++ LVM2/liblvm/Makefile.in	2009/07/29 13:26:01	1.12
@@ -62,7 +62,7 @@
 install: $(INSTALL_TYPE) install_include
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm.h $(includedir)/lvm.h
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm2app.h $(includedir)/lvm2app.h
 
 install_dynamic: $(LIB_SHARED)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/liblvm/lvm_base.c	2009/07/28 13:16:40	1.11
+++ LVM2/liblvm/lvm_base.c	2009/07/29 13:26:01	1.12
@@ -13,7 +13,7 @@
  */
 
 #include "lib.h"
-#include "lvm.h"
+#include "lvm2app.h"
 #include "toolcontext.h"
 #include "locking.h"
 
--- LVM2/liblvm/lvm_lv.c	2009/07/28 15:14:56	1.12
+++ LVM2/liblvm/lvm_lv.c	2009/07/29 13:26:01	1.13
@@ -13,7 +13,7 @@
  */
 
 #include "lib.h"
-#include "lvm.h"
+#include "lvm2app.h"
 #include "metadata-exported.h"
 #include "lvm-string.h"
 #include "defaults.h"
@@ -120,7 +120,7 @@
 	lvl = find_lv_in_vg(vg, name);
 	if (!lvl)
 		return NULL;
-	return lvl->lv;
+	return (struct lv_t *) lvl->lv;
 }
 
 /*
--- LVM2/liblvm/lvm_pv.c	2009/07/28 09:56:48	1.5
+++ LVM2/liblvm/lvm_pv.c	2009/07/29 13:26:01	1.6
@@ -13,7 +13,7 @@
  */
 
 #include "lib.h"
-#include "lvm.h"
+#include "lvm2app.h"
 #include "metadata-exported.h"
 #include "lvm-string.h"
 
--- LVM2/liblvm/lvm_vg.c	2009/07/28 15:14:56	1.23
+++ LVM2/liblvm/lvm_vg.c	2009/07/29 13:26:01	1.24
@@ -13,7 +13,7 @@
  */
 
 #include "lib.h"
-#include "lvm.h"
+#include "lvm2app.h"
 #include "toolcontext.h"
 #include "metadata-exported.h"
 #include "archiver.h"
@@ -36,7 +36,7 @@
 		return NULL;
 	}
 	vg->open_mode = 'w';
-	return vg;
+	return (vg_t *) vg;
 }
 
 int lvm_vg_extend(vg_t *vg, const char *device)
@@ -180,7 +180,7 @@
 	/* FIXME: combine this with locking ? */
 	vg->open_mode = mode[0];
 
-	return vg;
+	return (vg_t *) vg;
 }
 
 struct dm_list *lvm_vg_list_pvs(vg_t *vg)


