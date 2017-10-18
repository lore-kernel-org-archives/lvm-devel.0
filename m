From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 18 Oct 2017 10:59:35 -0400
Subject: master - tidy: Add missing underscores to statics.
Message-ID: <201710181459.v9IExZ6w021023@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1cc5b12fd80c3c62247fccfb2e5537aef27533d
Commit:        f1cc5b12fd80c3c62247fccfb2e5537aef27533d
Parent:        327d9d59be6f7179b2e0a756deaa0f9a196e0651
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Oct 18 15:57:46 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Oct 18 15:58:13 2017 +0100

tidy: Add missing underscores to statics.

---
 lib/cache/lvmetad.c              |    6 +-
 lib/commands/toolcontext.c       |   10 +-
 lib/device/dev-md.c              |   13 +-
 lib/device/dev-swap.c            |    3 +-
 lib/locking/cluster_locking.c    |    6 +-
 lib/metadata/lv_manip.c          |    4 +-
 lib/metadata/metadata.c          |   18 +-
 lib/metadata/pv_manip.c          |   22 +--
 lib/metadata/raid_manip.c        |   10 +-
 lib/mm/memlock.c                 |    6 +-
 lib/report/report.c              |   15 +-
 lib/report/values.h              |    4 +-
 libdaemon/client/config-util.c   |    4 +-
 libdaemon/server/daemon-log.c    |    8 +-
 libdaemon/server/daemon-server.c |    4 +-
 libdm/ioctl/libdm-iface.c        |    4 +-
 libdm/libdm-config.c             |    6 +-
 libdm/mm/pool-fast.c             |    8 +-
 libdm/mm/pool.c                  |    6 +-
 tools/command.c                  |  397 +++++++++++++++++++-------------------
 tools/dmsetup.c                  |   12 +-
 tools/lvchange.c                 |    8 +-
 tools/lvmcmdline.c               |   18 +-
 tools/lvpoll.c                   |    4 +-
 tools/lvscan.c                   |    6 +-
 tools/polldaemon.c               |   22 +-
 tools/pvcreate.c                 |   12 +-
 tools/pvmove.c                   |   12 +-
 tools/toollib.c                  |   10 +-
 tools/vgcfgbackup.c              |    8 +-
 tools/vgchange.c                 |    8 +-
 tools/vgconvert.c                |    8 +-
 tools/vgdisplay.c                |    8 +-
 tools/vgimport.c                 |   10 +-
 tools/vgremove.c                 |    8 +-
 tools/vgscan.c                   |    8 +-
 tools/vgsplit.c                  |    4 +-
 37 files changed, 358 insertions(+), 362 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 1ba844f..1fd9091 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -39,7 +39,7 @@ static int64_t _lvmetad_update_timeout;
 
 static int _found_lvm1_metadata = 0;
 
-static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg);
+static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg);
 
 static uint64_t _monotonic_seconds(void)
 {
@@ -1090,7 +1090,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 		 * invalidated the cached vg.
 		 */
 		if (rescan) {
-			if (!(vg2 = lvmetad_pvscan_vg(cmd, vg))) {
+			if (!(vg2 = _lvmetad_pvscan_vg(cmd, vg))) {
 				log_debug_lvmetad("VG %s from lvmetad not found during rescan.", vgname);
 				fid = NULL;
 				release_vg(vg);
@@ -1787,7 +1787,7 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
  * the VG, and that PV may have been reused for another VG.
  */
 
-static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg)
+static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg)
 {
 	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
 	char uuid[64] __attribute__((aligned(8)));
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 3cb3cf8..e742df5 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -54,7 +54,7 @@
 #  include <malloc.h>
 #endif
 
-static const size_t linebuffer_size = 4096;
+static const size_t _linebuffer_size = 4096;
 
 /*
  * Copy the input string, removing invalid characters.
@@ -1873,7 +1873,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	/* Set in/out stream buffering before glibc */
 	if (set_buffering) {
 		/* Allocate 2 buffers */
-		if (!(cmd->linebuffer = dm_malloc(2 * linebuffer_size))) {
+		if (!(cmd->linebuffer = dm_malloc(2 * _linebuffer_size))) {
 			log_error("Failed to allocate line buffer.");
 			goto out;
 		}
@@ -1884,7 +1884,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		    (flags & O_ACCMODE) != O_WRONLY) {
 			if (!reopen_standard_stream(&stdin, "r"))
 				goto_out;
-			if (setvbuf(stdin, cmd->linebuffer, _IOLBF, linebuffer_size)) {
+			if (setvbuf(stdin, cmd->linebuffer, _IOLBF, _linebuffer_size)) {
 				log_sys_error("setvbuf", "");
 				goto out;
 			}
@@ -1895,8 +1895,8 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		    (flags & O_ACCMODE) != O_RDONLY) {
 			if (!reopen_standard_stream(&stdout, "w"))
 				goto_out;
-			if (setvbuf(stdout, cmd->linebuffer + linebuffer_size,
-				     _IOLBF, linebuffer_size)) {
+			if (setvbuf(stdout, cmd->linebuffer + _linebuffer_size,
+				     _IOLBF, _linebuffer_size)) {
 				log_sys_error("setvbuf", "");
 				goto out;
 			}
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index d0e69a1..6e0a312 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -261,8 +261,7 @@ out:
 /*
  * Retrieve chunk size from md device using sysfs.
  */
-static unsigned long dev_md_chunk_size(struct dev_types *dt,
-				       struct device *dev)
+static unsigned long _dev_md_chunk_size(struct dev_types *dt, struct device *dev)
 {
 	const char *attribute = "chunk_size";
 	unsigned long chunk_size_bytes = 0UL;
@@ -280,7 +279,7 @@ static unsigned long dev_md_chunk_size(struct dev_types *dt,
 /*
  * Retrieve level from md device using sysfs.
  */
-static int dev_md_level(struct dev_types *dt, struct device *dev)
+static int _dev_md_level(struct dev_types *dt, struct device *dev)
 {
 	char level_string[MD_MAX_SYSFS_SIZE];
 	const char *attribute = "level";
@@ -303,7 +302,7 @@ static int dev_md_level(struct dev_types *dt, struct device *dev)
 /*
  * Retrieve raid_disks from md device using sysfs.
  */
-static int dev_md_raid_disks(struct dev_types *dt, struct device *dev)
+static int _dev_md_raid_disks(struct dev_types *dt, struct device *dev)
 {
 	const char *attribute = "raid_disks";
 	int raid_disks = 0;
@@ -327,15 +326,15 @@ unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev)
 	unsigned long stripe_width_sectors = 0UL;
 	int level, raid_disks, data_disks;
 
-	chunk_size_sectors = dev_md_chunk_size(dt, dev);
+	chunk_size_sectors = _dev_md_chunk_size(dt, dev);
 	if (!chunk_size_sectors)
 		return 0;
 
-	level = dev_md_level(dt, dev);
+	level = _dev_md_level(dt, dev);
 	if (level < 0)
 		return 0;
 
-	raid_disks = dev_md_raid_disks(dt, dev);
+	raid_disks = _dev_md_raid_disks(dt, dev);
 	if (!raid_disks)
 		return 0;
 
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index 6bce535..7d16dd1 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -20,8 +20,7 @@
 #define MAX_PAGESIZE	(64 * 1024)
 #define SIGNATURE_SIZE  10
 
-static int
-_swap_detect_signature(const char *buf)
+static int _swap_detect_signature(const char *buf)
 {
 	if (memcmp(buf, "SWAP-SPACE", 10) == 0 ||
             memcmp(buf, "SWAPSPACE2", 10) == 0)
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index a04d9c7..e2f8123 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -515,7 +515,7 @@ static int _lock_resource(struct cmd_context *cmd, const char *resource,
 	return _lock_for_cluster(cmd, clvmd_cmd, flags, lockname);
 }
 
-static int decode_lock_type(const char *response)
+static int _decode_lock_type(const char *response)
 {
 	if (!response)
 		return LCK_NULL;
@@ -566,8 +566,8 @@ int query_resource(const char *resource, const char *node, int *mode)
 		 * If two nodes report different locks,
 		 * something is broken - just return more important mode.
 		 */
-		if (decode_lock_type(response[i].response) > *mode)
-			*mode = decode_lock_type(response[i].response);
+		if (_decode_lock_type(response[i].response) > *mode)
+			*mode = _decode_lock_type(response[i].response);
 
 		log_debug_locking("Lock held for %s, node %s : %s", resource,
 				  response[i].node, response[i].response);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e71e2eb..c0e9a99 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4719,7 +4719,7 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 	return 1;
 }
 
-static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
+static uint32_t _lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
 {
 	uint32_t s;
 	struct lv_segment *seg_mirr;
@@ -5165,7 +5165,7 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 			seg_physical_extents = seg->area_len * seg->area_count;	/* FIXME Also metadata, cow etc. */
 
 			/* Check for underlying stripe sizes */
-			seg_stripes = lvseg_get_stripes(seg, &seg_stripesize);
+			seg_stripes = _lvseg_get_stripes(seg, &seg_stripesize);
 
 			if (seg_is_mirrored(seg))
 				seg_mirrors = lv_mirror_count(seg->lv);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 496dbee..15e08e6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -177,8 +177,8 @@ void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
  *  1 - success
  * FIXME: remove pv_name - obtain safely from pv
  */
-static int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
-		        struct physical_volume *pv, int new_pv)
+static int _add_pv_to_vg(struct volume_group *vg, const char *pv_name,
+		         struct physical_volume *pv, int new_pv)
 {
 	struct pv_list *pvl;
 	struct format_instance *fid = vg->fid;
@@ -720,9 +720,9 @@ static int _check_pv_dev_sizes(struct volume_group *vg)
  * - max_phys_block_size: largest physical block size found amongst PVs in a VG
  *
  */
-static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
-			       struct pvcreate_params *pp,
-			       unsigned int *max_phys_block_size)
+static int _vg_extend_single_pv(struct volume_group *vg, char *pv_name,
+			        struct pvcreate_params *pp,
+			        unsigned int *max_phys_block_size)
 {
 	struct physical_volume *pv;
 	struct pv_to_write *pvw;
@@ -746,7 +746,7 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 					  max_phys_block_size)))
 		goto_bad;
 
-	if (!add_pv_to_vg(vg, pv_name, pv, new_pv))
+	if (!_add_pv_to_vg(vg, pv_name, pv, new_pv))
 		goto_bad;
 
 	if ((pv->fmt->features & FMT_PV_FLAGS) ||
@@ -774,7 +774,7 @@ bad:
  * source file.  All the following and more are only used by liblvm:
  *
  * . vg_extend()
- * . vg_extend_single_pv()
+ * . _vg_extend_single_pv()
  * . pvcreate_vol()
  * . _pvcreate_check()
  * . _pvcreate_write()
@@ -813,7 +813,7 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 			return 0;
 		}
 		dm_unescape_colons_and_at_signs(pv_name, NULL, NULL);
-		if (!vg_extend_single_pv(vg, pv_name, pp, &max_phys_block_size)) {
+		if (!_vg_extend_single_pv(vg, pv_name, pp, &max_phys_block_size)) {
 			log_error("Unable to add physical volume '%s' to "
 				  "volume group '%s'.", pv_name, vg->name);
 			dm_free(pv_name);
@@ -849,7 +849,7 @@ int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 			return 0;
 		}
 
-		if (!add_pv_to_vg(vg, pv_dev_name(pvl->pv), pvl->pv, 0)) {
+		if (!_add_pv_to_vg(vg, pv_dev_name(pvl->pv), pvl->pv, 0)) {
 			log_error("PV %s cannot be added to VG %s.",
 				  pv_dev_name(pvl->pv), vg->name);
 			return 0;
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index f37bc4c..2a1754d 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -84,8 +84,8 @@ int peg_dup(struct dm_pool *mem, struct dm_list *peg_new, struct dm_list *peg_ol
 }
 
 /* Find segment at a given physical extent in a PV */
-static struct pv_segment *find_peg_by_pe(const struct physical_volume *pv,
-					 uint32_t pe)
+static struct pv_segment *_find_peg_by_pe(const struct physical_volume *pv,
+					  uint32_t pe)
 {
 	struct pv_segment *pvseg;
 
@@ -137,7 +137,7 @@ int pv_split_segment(struct dm_pool *mem,
 	if (pe == pv->pe_count)
 		goto out;
 
-	if (!(pvseg = find_peg_by_pe(pv, pe))) {
+	if (!(pvseg = _find_peg_by_pe(pv, pe))) {
 		log_error("Segment with extent %" PRIu32 " in PV %s not found",
 			  pe, pv_dev_name(pv));
 		return 0;
@@ -158,7 +158,7 @@ out:
 	return 1;
 }
 
-static struct pv_segment null_pv_segment = {
+static struct pv_segment _null_pv_segment = {
 	.pv = NULL,
 	.pe = 0,
 };
@@ -172,7 +172,7 @@ struct pv_segment *assign_peg_to_lvseg(struct physical_volume *pv,
 
 	/* Missing format1 PV */
 	if (!pv)
-		return &null_pv_segment;
+		return &_null_pv_segment;
 
 	if (!pv_split_segment(seg->lv->vg->vgmem, pv, pe, &peg) ||
 	    !pv_split_segment(seg->lv->vg->vgmem, pv, pe + area_len, NULL))
@@ -556,9 +556,7 @@ static int _extend_pv(struct physical_volume *pv, struct volume_group *vg,
  * Resize a PV in a VG, adding or removing segments as needed.
  * New size must fit within pv->size.
  */
-static int pv_resize(struct physical_volume *pv,
-	      struct volume_group *vg,
-	      uint64_t size)
+static int _pv_resize(struct physical_volume *pv, struct volume_group *vg, uint64_t size)
 {
 	uint32_t old_pe_count, new_pe_count = 0;
 
@@ -674,7 +672,7 @@ int pv_resize_single(struct cmd_context *cmd,
 	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
 		    pv_name, size);
 
-	if (!pv_resize(pv, vg, size))
+	if (!_pv_resize(pv, vg, size))
 		goto_out;
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
@@ -712,8 +710,8 @@ out:
  * Decide whether it is "safe" to wipe the labels on this device.
  * 0 indicates we may not.
  */
-static int pvremove_check(struct cmd_context *cmd, const char *name,
-			  unsigned force_count, unsigned prompt, struct dm_list *pvslist)
+static int _pvremove_check(struct cmd_context *cmd, const char *name,
+			   unsigned force_count, unsigned prompt, struct dm_list *pvslist)
 {
 	static const char really_wipe_msg[] = "Really WIPE LABELS from physical volume";
 	struct device *dev;
@@ -804,7 +802,7 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 	struct lvmcache_info *info;
 	int r = 0;
 
-	if (!pvremove_check(cmd, pv_name, force_count, prompt, pvslist))
+	if (!_pvremove_check(cmd, pv_name, force_count, prompt, pvslist))
 		goto out;
 
 	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 691ff58..f065a4c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1321,7 +1321,7 @@ static int _cmp_level(const struct segment_type *t1, const struct segment_type *
  *
  * Return 1 if same, else != 1
  */
-static int is_same_level(const struct segment_type *t1, const struct segment_type *t2)
+static int _is_same_level(const struct segment_type *t1, const struct segment_type *t2)
 {
 	return _cmp_level(t1, t2);
 }
@@ -2331,7 +2331,7 @@ static int _raid_reshape(struct logical_volume *lv,
 	if (!seg_is_reshapable_raid(seg))
 		return_0;
 
-	if (!is_same_level(seg->segtype, new_segtype))
+	if (!_is_same_level(seg->segtype, new_segtype))
 		return_0;
 
 	if (!(old_image_count = seg->area_count))
@@ -2510,7 +2510,7 @@ static int _reshape_requested(const struct logical_volume *lv, const struct segm
 		return 0;
 
 	/* Switching raid levels is a takeover, no reshape */
-	if (!is_same_level(seg->segtype, segtype))
+	if (!_is_same_level(seg->segtype, segtype))
 		return 0;
 
 	/* Possible takeover in case #data_copies == #stripes */
@@ -6042,7 +6042,7 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 	const struct segment_type *segtype_sav = *segtype;
 
 	/* Bail out if same RAID level is requested. */
-	if (is_same_level(seg_from->segtype, *segtype))
+	if (_is_same_level(seg_from->segtype, *segtype))
 		return 1;
 
 	log_debug("Checking LV %s requested %s segment type for convenience",
@@ -6296,7 +6296,7 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 	if (r &&
 	    !yes &&
 	    strcmp((*segtype_to)->name, SEG_TYPE_NAME_MIRROR) && /* "mirror" is prompted for later */
-	    !is_same_level(seg_from->segtype, *segtype_to)) { /* Prompt here for takeover */
+	    !_is_same_level(seg_from->segtype, *segtype_to)) { /* Prompt here for takeover */
 		const char *basic_fmt = "Are you sure you want to convert %s LV %s";
 		const char *type_fmt = " to %s type";
 		const char *question_fmt = "? [y/n]: ";
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index da90144..389e213 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -396,7 +396,7 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 #define _GNU_SOURCE
 #endif
 #include <dlfcn.h>
-static const unsigned char INSTRUCTION_HLT = 0x94;
+static const unsigned char _instruction_hlt = 0x94;
 static char _mmap_orig;
 static unsigned char *_mmap_addr;
 #ifdef __i386__
@@ -429,8 +429,8 @@ static int _disable_mmap(void)
 		}
 		_mmap_orig = *_mmap_addr;
 	}
-	log_debug_mem("Remapping mmap entry %02x to %02x.", _mmap_orig, INSTRUCTION_HLT);
-	*_mmap_addr = INSTRUCTION_HLT;
+	log_debug_mem("Remapping mmap entry %02x to %02x.", _mmap_orig, _instruction_hlt);
+	*_mmap_addr = _instruction_hlt;
 
 #ifdef __i386__
 	if (!_mmap64_addr) {
diff --git a/lib/report/report.c b/lib/report/report.c
index c32df71..6d6289e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -38,8 +38,7 @@ struct lvm_report_object {
 	struct label *label;
 };
 
-static uint32_t log_seqnum = 1;
-
+static uint32_t _log_seqnum = 1;
 
 /*
  *  Enum for field_num index to use in per-field reserved value definition.
@@ -1091,10 +1090,10 @@ static void *_lv_time_handler_get_dynamic_value(struct dm_report *rh,
 	return result;
 }
 
-static int lv_time_handler(struct dm_report *rh, struct dm_pool *mem,
-			   uint32_t field_num,
-			   dm_report_reserved_action_t action,
-			   const void *data_in, const void **data_out)
+static int _lv_time_handler(struct dm_report *rh, struct dm_pool *mem,
+			    uint32_t field_num,
+			    dm_report_reserved_action_t action,
+			    const void *data_in, const void **data_out)
 {
 	*data_out = NULL;
 	if (!data_in)
@@ -4128,7 +4127,7 @@ int report_cmdlog(void *handle, const char *type, const char *context,
 		  const char *object_group_id, const char *msg,
 		  int current_errno, int ret_code)
 {
-	struct cmd_log_item log_item = {log_seqnum++, type, context, object_type_name,
+	struct cmd_log_item log_item = {_log_seqnum++, type, context, object_type_name,
 					object_name ? : "", object_id ? : "",
 					object_group ? : "", object_group_id ? : "",
 					msg ? : "", current_errno, ret_code};
@@ -4141,7 +4140,7 @@ int report_cmdlog(void *handle, const char *type, const char *context,
 
 void report_reset_cmdlog_seqnum(void)
 {
-	log_seqnum = 1;
+	_log_seqnum = 1;
 }
 
 int report_current_object_cmdlog(const char *type, const char *msg, int32_t ret_code)
diff --git a/lib/report/values.h b/lib/report/values.h
index 652689b..7c53651 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -90,8 +90,8 @@ FIELD_RESERVED_VALUE(NOFLAG, lv_read_ahead, lv_read_ahead_auto, "", &_siz_max, "
 FIELD_RESERVED_VALUE(NAMED, lv_when_full, lv_when_full_error, "", "error", "error", "error when full", "error if no space")
 FIELD_RESERVED_VALUE(NAMED, lv_when_full, lv_when_full_queue, "", "queue", "queue", "queue when full", "queue if no space")
 FIELD_RESERVED_VALUE(NOFLAG, lv_when_full, lv_when_full_undef, "", "", "", "undefined")
-FIELD_RESERVED_VALUE(NAMED | RANGE | FUZZY | DYNAMIC, lv_time, lv_time_fuzzy, "", lv_time_handler, NULL)
-FIELD_RESERVED_VALUE(NAMED | RANGE | FUZZY | DYNAMIC, lv_time_removed, lv_time_removed_fuzzy, "", lv_time_handler, NULL)
+FIELD_RESERVED_VALUE(NAMED | RANGE | FUZZY | DYNAMIC, lv_time, lv_time_fuzzy, "", _lv_time_handler, NULL)
+FIELD_RESERVED_VALUE(NAMED | RANGE | FUZZY | DYNAMIC, lv_time_removed, lv_time_removed_fuzzy, "", _lv_time_handler, NULL)
 
 /* Reserved values for SEG fields */
 FIELD_RESERVED_VALUE(NOFLAG, cache_policy, cache_policy_undef, "", "", "", "undefined")
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 5b6cfb8..32f36f6 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -304,7 +304,7 @@ struct dm_config_node *config_make_nodes(struct dm_config_tree *cft,
 }
 
 /* Test if the doubles are close enough to be considered equal */
-static int close_enough(double d1, double d2)
+static int _close_enough(double d1, double d2)
 {
 	return fabs(d1 - d2) < DBL_EPSILON;
 }
@@ -320,7 +320,7 @@ int compare_value(struct dm_config_value *a, struct dm_config_value *b)
 
 	switch (a->type) {
 	case DM_CFG_STRING: r = strcmp(a->v.str, b->v.str); break;
-	case DM_CFG_FLOAT: r = close_enough(a->v.f, b->v.f) ? 0 : (a->v.f > b->v.f) ? 1 : -1; break;
+	case DM_CFG_FLOAT: r = _close_enough(a->v.f, b->v.f) ? 0 : (a->v.f > b->v.f) ? 1 : -1; break;
 	case DM_CFG_INT: r = (a->v.i == b->v.i) ? 0 : (a->v.i > b->v.i) ? 1 : -1; break;
 	case DM_CFG_EMPTY_ARRAY: return 0;
 	}
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index e0fe188..3be5573 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -24,7 +24,7 @@ struct backend {
 	void (*log)(log_state *s, void **state, int type, const char *message);
 };
 
-static void log_syslog(log_state *s, void **state, int type, const char *message)
+static void _log_syslog(log_state *s, void **state, int type, const char *message)
 {
 	int prio;
 
@@ -44,7 +44,7 @@ static void log_syslog(log_state *s, void **state, int type, const char *message
 	syslog(prio, "%s", message);
 }
 
-static void log_stderr(log_state *s, void **state, int type, const char *message)
+static void _log_stderr(log_state *s, void **state, int type, const char *message)
 {
 	const char *prefix;
 
@@ -60,8 +60,8 @@ static void log_stderr(log_state *s, void **state, int type, const char *message
 }
 
 struct backend backend[] = {
-	{ DAEMON_LOG_OUTLET_SYSLOG, log_syslog },
-	{ DAEMON_LOG_OUTLET_STDERR, log_stderr },
+	{ DAEMON_LOG_OUTLET_SYSLOG, _log_syslog },
+	{ DAEMON_LOG_OUTLET_STDERR, _log_stderr },
 	{ 0, 0 }
 };
 
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 2ffdf40..3b19883 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -498,7 +498,7 @@ fail:
 	return NULL;
 }
 
-static int handle_connect(daemon_state s)
+static int _handle_connect(daemon_state s)
 {
 	thread_state *ts;
 	struct sockaddr_un sockaddr;
@@ -651,7 +651,7 @@ void daemon_start(daemon_state s)
 			perror("select error");
 		if (FD_ISSET(s.socket_fd, &in)) {
 			timeout_count = 0;
-			handle_connect(s);
+			_handle_connect(s);
 		}
 
 		_reap(s, 0);
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 100d0cc..8bee24b 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -594,7 +594,7 @@ int dm_cookie_supported(void)
 		_dm_version_minor >= 15);
 }
 
-static int dm_inactive_supported(void)
+static int _dm_inactive_supported(void)
 {
 	int inactive_supported = 0;
 
@@ -1231,7 +1231,7 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 		dmi->flags |= DM_SECURE_DATA_FLAG;
 	}
 	if (dmt->query_inactive_table) {
-		if (!dm_inactive_supported())
+		if (!_dm_inactive_supported())
 			log_warn("WARNING: Inactive table query unsupported "
 				 "by kernel.  It will use live table.");
 		dmi->flags |= DM_QUERY_INACTIVE_TABLE_FLAG;
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index d85effb..e1ca210 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -72,7 +72,7 @@ static struct dm_config_node *_create_node(struct dm_pool *mem);
 static char *_dup_tok(struct parser *p);
 static char *_dup_token(struct dm_pool *mem, const char *b, const char *e);
 
-static const int sep = '/';
+static const int _sep = '/';
 
 #define MAX_INDENT 32
 
@@ -530,11 +530,11 @@ static struct dm_config_node *_find_or_make_node(struct dm_pool *mem,
 
 	while (cn || mem) {
 		/* trim any leading slashes */
-		while (*path && (*path == sep))
+		while (*path && (*path == _sep))
 			path++;
 
 		/* find the end of this segment */
-		for (e = path; *e && (*e != sep); e++) ;
+		for (e = path; *e && (*e != _sep); e++) ;
 
 		/* hunt for the node */
 		cn_found = NULL;
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index 65ca856..614e903 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -269,16 +269,16 @@ static struct chunk *_new_chunk(struct dm_pool *p, size_t s)
 		p->spare_chunk = 0;
 	} else {
 #ifdef DEBUG_ENFORCE_POOL_LOCKING
-		if (!pagesize) {
-			pagesize = getpagesize(); /* lvm_pagesize(); */
-			pagesize_mask = pagesize - 1;
+		if (!_pagesize) {
+			_pagesize = getpagesize(); /* lvm_pagesize(); */
+			_pagesize_mask = _pagesize - 1;
 		}
 		/*
 		 * Allocate page aligned size so malloc could work.
 		 * Otherwise page fault would happen from pool unrelated
 		 * memory writes of internal malloc pointers.
 		 */
-#  define aligned_malloc(s)	(posix_memalign((void**)&c, pagesize, \
+#  define aligned_malloc(s)	(posix_memalign((void**)&c, _pagesize, \
 						ALIGN_ON_PAGE(s)) == 0)
 #else
 #  define aligned_malloc(s)	(c = dm_malloc(s))
diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index c1cb61e..1321cc7 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -35,9 +35,9 @@ void dm_pools_check_leaks(void);
  * - Only pool-fast is properly handled for now.
  * - Checksum is slower compared to mprotect.
  */
-static size_t pagesize = 0;
-static size_t pagesize_mask = 0;
-#define ALIGN_ON_PAGE(size) (((size) + (pagesize_mask)) & ~(pagesize_mask))
+static size_t _pagesize = 0;
+static size_t _pagesize_mask = 0;
+#define ALIGN_ON_PAGE(size) (((size) + (_pagesize_mask)) & ~(_pagesize_mask))
 #endif
 
 #ifdef DEBUG_POOL
diff --git a/tools/command.c b/tools/command.c
index 52a3766..17b5eb4 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -83,7 +83,7 @@ static void *dm_pool_alloc(void *p, size_t size)
 struct cmd_context;
 struct arg_values;
 
-/* needed to include args.h */
+/* needed to include vals.h */
 static inline int yes_no_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int activation_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int cachemetadataformat_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
@@ -273,14 +273,14 @@ struct command lvm_all;
 
 /* saves OO_FOO lines (groups of optional options) to include in multiple defs */
 
-static int oo_line_count;
+static int _oo_line_count;
 #define MAX_OO_LINES 256
 
 struct oo_line {
 	char *name;
 	char *line;
 };
-static struct oo_line oo_lines[MAX_OO_LINES];
+static struct oo_line _oo_lines[MAX_OO_LINES];
 
 #define REQUIRED 1  /* required option */
 #define OPTIONAL 0  /* optional option */
@@ -297,14 +297,14 @@ static struct oo_line oo_lines[MAX_OO_LINES];
  */
 #include "command-lines-input.h"
 
-static void add_optional_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[]);
+static void __add_optional_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[]);
 
 /*
  * modifies buf, replacing the sep characters with \0
  * argv pointers point to positions in buf
  */
 
-static char *split_line(char *buf, int *argc, char **argv, char sep)
+static char *_split_line(char *buf, int *argc, char **argv, char sep)
 {
 	char *p = buf, *rp = NULL;
 	int i;
@@ -331,7 +331,7 @@ static char *split_line(char *buf, int *argc, char **argv, char sep)
 
 /* convert value string, e.g. Number, to foo_VAL enum */
 
-static int val_str_to_num(char *str)
+static int _val_str_to_num(char *str)
 {
 	char name[32];
 	char *new;
@@ -357,7 +357,7 @@ static int val_str_to_num(char *str)
 
 #define MAX_LONG_OPT_NAME_LEN 32
 
-static int opt_str_to_num(struct command *cmd, char *str)
+static int _opt_str_to_num(struct command *cmd, char *str)
 {
 	char long_name[MAX_LONG_OPT_NAME_LEN];
 	char *p;
@@ -432,7 +432,7 @@ int command_id_to_enum(const char *str)
 
 /* "lv_is_prop" to is_prop_LVP */
 
-static int lvp_name_to_enum(struct command *cmd, char *str)
+static int _lvp_name_to_enum(struct command *cmd, char *str)
 {
 	int i;
 
@@ -448,7 +448,7 @@ static int lvp_name_to_enum(struct command *cmd, char *str)
 
 /* "type" to type_LVT */
 
-static int lvt_name_to_enum(struct command *cmd, char *str)
+static int _lvt_name_to_enum(struct command *cmd, char *str)
 {
 	int i;
 
@@ -464,9 +464,9 @@ static int lvt_name_to_enum(struct command *cmd, char *str)
 
 /* LV_<type> to <type>_LVT */
 
-static int lv_to_enum(struct command *cmd, char *name)
+static int _lv_to_enum(struct command *cmd, char *name)
 {
-	return lvt_name_to_enum(cmd, name + 3);
+	return _lvt_name_to_enum(cmd, name + 3);
 }
 
 /*
@@ -480,7 +480,7 @@ static int lv_to_enum(struct command *cmd, char *name)
 
 #define LVTYPE_LEN 64
 
-static uint64_t lv_to_bits(struct command *cmd, char *name)
+static uint64_t _lv_to_bits(struct command *cmd, char *name)
 {
 	char buf[LVTYPE_LEN];
 	char *argv[MAX_LINE_ARGC];
@@ -492,20 +492,20 @@ static uint64_t lv_to_bits(struct command *cmd, char *name)
 	memset(buf, 0, sizeof(buf));
 	strncpy(buf, name, LVTYPE_LEN-1);
 
-	split_line(buf, &argc, argv, '_');
+	_split_line(buf, &argc, argv, '_');
 
 	/* 0 is "LV" */
 	for (i = 1; i < argc; i++) {
 		if (!strcmp(argv[i], "new"))
 			continue;
-		lvt_enum = lvt_name_to_enum(cmd, argv[i]);
+		lvt_enum = _lvt_name_to_enum(cmd, argv[i]);
 		lvt_bits |= lvt_enum_to_bit(lvt_enum);
 	}
 
 	return lvt_bits;
 }
 
-static struct command_name *find_command_name(const char *name)
+static struct command_name *_find_command_name(const char *name)
 {
 	int i;
 
@@ -522,17 +522,17 @@ static struct command_name *find_command_name(const char *name)
 	return NULL;
 }
 
-static const char *is_command_name(char *str)
+static const char *_is_command_name(char *str)
 {
 	const struct command_name *c;
 
-	if ((c = find_command_name(str)))
+	if ((c = _find_command_name(str)))
 		return c->name;
 
 	return NULL;
 }
 
-static int is_opt_name(char *str)
+static int _is_opt_name(char *str)
 {
 	if ((str[0] == '-') && (str[1] == '-'))
 		return 1;
@@ -548,7 +548,7 @@ static int is_opt_name(char *str)
  * can be empty if the --select option is used.
  */
 
-static int is_pos_name(char *str)
+static int _is_pos_name(char *str)
 {
 	switch (str[0]) {
 	case 'V': return (str[1] == 'G'); /* VG */
@@ -562,56 +562,56 @@ static int is_pos_name(char *str)
 	return 0;
 }
 
-static int is_oo_definition(char *str)
+static int _is_oo_definition(char *str)
 {
 	if (!strncmp(str, "OO_", 3) && strchr(str, ':'))
 		return 1;
 	return 0;
 }
 
-static int is_oo_line(char *str)
+static int _is_oo_line(char *str)
 {
 	if (!strncmp(str, "OO:", 3))
 		return 1;
 	return 0;
 }
 
-static int is_io_line(char *str)
+static int _is_io_line(char *str)
 {
 	if (!strncmp(str, "IO:", 3))
 		return 1;
 	return 0;
 }
 
-static int is_op_line(char *str)
+static int _is_op_line(char *str)
 {
 	if (!strncmp(str, "OP:", 3))
 		return 1;
 	return 0;
 }
 
-static int is_desc_line(char *str)
+static int _is_desc_line(char *str)
 {
 	if (!strncmp(str, "DESC:", 5))
 		return 1;
 	return 0;
 }
 
-static int is_flags_line(char *str)
+static int _is_flags_line(char *str)
 {
 	if (!strncmp(str, "FLAGS:", 6))
 		return 1;
 	return 0;
 }
 
-static int is_rule_line(char *str)
+static int _is_rule_line(char *str)
 {
 	if (!strncmp(str, "RULE:", 5))
 		return 1;
 	return 0;
 }
 
-static int is_id_line(char *str)
+static int _is_id_line(char *str)
 {
 	if (!strncmp(str, "ID:", 3))
 		return 1;
@@ -624,7 +624,7 @@ static int is_id_line(char *str)
  * like VG, VG|LV, VG|LV_linear|LV_striped, etc.
  */
 
-static void set_pos_def(struct command *cmd, char *str, struct arg_def *def)
+static void _set_pos_def(struct command *cmd, char *str, struct arg_def *def)
 {
 	char *argv[MAX_LINE_ARGC];
 	int argc;
@@ -632,12 +632,12 @@ static void set_pos_def(struct command *cmd, char *str, struct arg_def *def)
 	int val_enum;
 	int i;
 
-	split_line(str, &argc, argv, '|');
+	_split_line(str, &argc, argv, '|');
 
 	for (i = 0; i < argc; i++) {
 		name = argv[i];
 
-		val_enum = val_str_to_num(name);
+		val_enum = _val_str_to_num(name);
 
 		if (!val_enum) {
 			log_error("Parsing command defs: unknown pos arg: %s.", name);
@@ -648,7 +648,7 @@ static void set_pos_def(struct command *cmd, char *str, struct arg_def *def)
 		def->val_bits |= val_enum_to_bit(val_enum);
 
 		if ((val_enum == lv_VAL) && strchr(name, '_'))
-			def->lvt_bits = lv_to_bits(cmd, name);
+			def->lvt_bits = _lv_to_bits(cmd, name);
 
 		if (strstr(name, "_new")) {
 			if (val_enum == lv_VAL)
@@ -664,7 +664,7 @@ static void set_pos_def(struct command *cmd, char *str, struct arg_def *def)
  * Parse str for anything that can follow --option.
  */
 
-static void set_opt_def(struct cmd_context *cmdtool, struct command *cmd, char *str, struct arg_def *def)
+static void _set_opt_def(struct cmd_context *cmdtool, struct command *cmd, char *str, struct arg_def *def)
 {
 	char *argv[MAX_LINE_ARGC];
 	int argc;
@@ -672,12 +672,12 @@ static void set_opt_def(struct cmd_context *cmdtool, struct command *cmd, char *
 	int val_enum;
 	int i;
 
-	split_line(str, &argc, argv, '|');
+	_split_line(str, &argc, argv, '|');
 
 	for (i = 0; i < argc; i++) {
 		name = argv[i];
 
-		val_enum = val_str_to_num(name);
+		val_enum = _val_str_to_num(name);
 
 		if (!val_enum) {
 			/* a literal number or string */
@@ -713,7 +713,7 @@ static void set_opt_def(struct cmd_context *cmdtool, struct command *cmd, char *
 
 		if (val_enum == lv_VAL) {
 			if (strchr(name, '_'))
-				def->lvt_bits = lv_to_bits(cmd, name);
+				def->lvt_bits = _lv_to_bits(cmd, name);
 		}
 
 		if (strstr(name, "_new")) {
@@ -736,13 +736,13 @@ static void set_opt_def(struct cmd_context *cmdtool, struct command *cmd, char *
  * oo->line = "--opt1 ...";
  */
 
-static void add_oo_definition_line(const char *name, const char *line)
+static void _add_oo_definition_line(const char *name, const char *line)
 {
 	struct oo_line *oo;
 	char *colon;
 	char *start;
 
-	oo = &oo_lines[oo_line_count++];
+	oo = &_oo_lines[_oo_line_count++];
 
 	if (!(oo->name = dm_strdup(name))) {
 		log_error("Failer to duplicate name %s.", name);
@@ -765,14 +765,14 @@ static void add_oo_definition_line(const char *name, const char *line)
 
 /* Support OO_FOO: continuing on multiple lines. */
 
-static void append_oo_definition_line(const char *new_line)
+static void _append_oo_definition_line(const char *new_line)
 {
 	struct oo_line *oo;
 	char *old_line;
 	char *line;
 	int len;
 
-	oo = &oo_lines[oo_line_count-1];
+	oo = &_oo_lines[_oo_line_count - 1];
 
 	old_line = oo->line;
 
@@ -793,7 +793,7 @@ static void append_oo_definition_line(const char *new_line)
 
 #define OO_NAME_LEN 64
 
-static char *get_oo_line(const char *str)
+static char *_get_oo_line(const char *str)
 {
 	char *name;
 	char *end;
@@ -806,10 +806,10 @@ static char *get_oo_line(const char *str)
 	if ((end = strchr(str2, ',')))
 		*end = '\0';
 
-	for (i = 0; i < oo_line_count; i++) {
-		name = oo_lines[i].name;
+	for (i = 0; i < _oo_line_count; i++) {
+		name = _oo_lines[i].name;
 		if (!strcmp(name, str2))
-			return oo_lines[i].line;
+			return _oo_lines[i].line;
 	}
 	return NULL;
 }
@@ -819,14 +819,14 @@ static char *get_oo_line(const char *str)
  * i.e. include common options from an OO_FOO definition.
  */
 
-static void include_optional_opt_args(struct cmd_context *cmdtool, struct command *cmd, const char *str)
+static void _include_optional_opt_args(struct cmd_context *cmdtool, struct command *cmd, const char *str)
 {
 	char *oo_line;
 	char *line;
 	char *line_argv[MAX_LINE_ARGC];
 	int line_argc;
 
-	if (!(oo_line = get_oo_line(str))) {
+	if (!(oo_line = _get_oo_line(str))) {
 		log_error("Parsing command defs: no OO line found for %s.", str);
 		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
@@ -837,8 +837,8 @@ static void include_optional_opt_args(struct cmd_context *cmdtool, struct comman
 		return;
 	}
 
-	split_line(line, &line_argc, line_argv, ' ');
-	add_optional_opt_line(cmdtool, cmd, line_argc, line_argv);
+	_split_line(line, &line_argc, line_argv, ' ');
+	__add_optional_opt_line(cmdtool, cmd, line_argc, line_argv);
 	dm_free(line);
 }
 
@@ -847,7 +847,7 @@ static void include_optional_opt_args(struct cmd_context *cmdtool, struct comman
  * This function sets the opt_args.opt value for it.
  */
 
-static void add_opt_arg(struct command *cmd, char *str,
+static void _add_opt_arg(struct command *cmd, char *str,
 			int *takes_arg, int *already, int required)
 {
 	char *comma;
@@ -855,7 +855,7 @@ static void add_opt_arg(struct command *cmd, char *str,
 	int i;
 
 	/* opt_arg.opt set here */
-	/* opt_arg.def will be set in update_prev_opt_arg() if needed */
+	/* opt_arg.def will be set in _update_prev_opt_arg() if needed */
 
 	if ((comma = strchr(str, ',')))
 		*comma = '\0';
@@ -870,7 +870,7 @@ static void add_opt_arg(struct command *cmd, char *str,
 		goto skip;
 	}
 
-	opt = opt_str_to_num(cmd, str);
+	opt = _opt_str_to_num(cmd, str);
 
 	/* If the binary-search finds uuidstr_ARG switch to uuid_ARG */
 	if (opt == uuidstr_ARG)
@@ -903,7 +903,7 @@ skip:
  * for the value that appears after --option.
  */
 
-static void update_prev_opt_arg(struct cmd_context *cmdtool, struct command *cmd, char *str, int required)
+static void _update_prev_opt_arg(struct cmd_context *cmdtool, struct command *cmd, char *str, int required)
 {
 	struct arg_def def = { 0 };
 	char *comma;
@@ -915,12 +915,12 @@ static void update_prev_opt_arg(struct cmd_context *cmdtool, struct command *cmd
 	}
 
 	/* opt_arg.def set here */
-	/* opt_arg.opt was previously set in add_opt_arg() when --foo was read */
+	/* opt_arg.opt was previously set in _add_opt_arg() when --foo was read */
 
 	if ((comma = strchr(str, ',')))
 		*comma = '\0';
 
-	set_opt_def(cmdtool, cmd, str, &def);
+	_set_opt_def(cmdtool, cmd, str, &def);
 
 	if (required > 0)
 		cmd->required_opt_args[cmd->ro_count-1].def = def;
@@ -935,13 +935,13 @@ static void update_prev_opt_arg(struct cmd_context *cmdtool, struct command *cmd
  * This function sets the pos_args.pos and pos_args.def.
  */
 
-static void add_pos_arg(struct command *cmd, char *str, int required)
+static void _add_pos_arg(struct command *cmd, char *str, int required)
 {
 	struct arg_def def = { 0 };
 
 	/* pos_arg.pos and pos_arg.def are set here */
 
-	set_pos_def(cmd, str, &def);
+	_set_pos_def(cmd, str, &def);
 
 	if (required) {
 		cmd->required_pos_args[cmd->rp_count].pos = cmd->pos_count++;
@@ -956,7 +956,7 @@ static void add_pos_arg(struct command *cmd, char *str, int required)
 
 /* Process something that follows a pos arg, which is not a new pos arg. */
 
-static void update_prev_pos_arg(struct command *cmd, char *str, int required)
+static void _update_prev_pos_arg(struct command *cmd, char *str, int required)
 {
 	struct arg_def *def;
 
@@ -978,7 +978,7 @@ static void update_prev_pos_arg(struct command *cmd, char *str, int required)
 
 /* Process what follows OO:, which are the optional opt args for the cmd def. */
 
-static void add_optional_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
+static void __add_optional_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
 {
 	int takes_arg = 0;
 	int already;
@@ -990,12 +990,12 @@ static void add_optional_opt_line(struct cmd_context *cmdtool, struct command *c
 
 		already = 0;
 
-		if (is_opt_name(argv[i]))
-			add_opt_arg(cmd, argv[i], &takes_arg, &already, OPTIONAL);
+		if (_is_opt_name(argv[i]))
+			_add_opt_arg(cmd, argv[i], &takes_arg, &already, OPTIONAL);
 		else if (!strncmp(argv[i], "OO_", 3))
-			include_optional_opt_args(cmdtool, cmd, argv[i]);
+			_include_optional_opt_args(cmdtool, cmd, argv[i]);
 		else if (takes_arg)
-			update_prev_opt_arg(cmdtool, cmd, argv[i], OPTIONAL);
+			_update_prev_opt_arg(cmdtool, cmd, argv[i], OPTIONAL);
 		else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				i, argv[i], argv[i-1]);
@@ -1010,7 +1010,7 @@ static void add_optional_opt_line(struct cmd_context *cmdtool, struct command *c
 
 /* Process what follows IO:, which are the ignore options for the cmd def. */
 
-static void add_ignore_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
+static void _add_ignore_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
 {
 	int takes_arg = 0;
 	int i;
@@ -1018,10 +1018,10 @@ static void add_ignore_opt_line(struct cmd_context *cmdtool, struct command *cmd
 	for (i = 0; i < argc; i++) {
 		if (!i && !strncmp(argv[i], "IO:", 3))
 			continue;
-		if (is_opt_name(argv[i]))
-			add_opt_arg(cmd, argv[i], &takes_arg, NULL, IGNORE);
+		if (_is_opt_name(argv[i]))
+			_add_opt_arg(cmd, argv[i], &takes_arg, NULL, IGNORE);
 		else if (takes_arg)
-			update_prev_opt_arg(cmdtool, cmd, argv[i], IGNORE);
+			_update_prev_opt_arg(cmdtool, cmd, argv[i], IGNORE);
 		else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				i, argv[i], argv[i-1]);
@@ -1033,30 +1033,30 @@ static void add_ignore_opt_line(struct cmd_context *cmdtool, struct command *cmd
 
 /* Process what follows OP:, which are optional pos args for the cmd def. */
 
-static void add_optional_pos_line(struct command *cmd, int argc, char *argv[])
+static void _add_optional_pos_line(struct command *cmd, int argc, char *argv[])
 {
 	int i;
 
 	for (i = 0; i < argc; i++) {
 		if (!i && !strncmp(argv[i], "OP:", 3))
 			continue;
-		if (is_pos_name(argv[i]))
-			add_pos_arg(cmd, argv[i], OPTIONAL);
+		if (_is_pos_name(argv[i]))
+			_add_pos_arg(cmd, argv[i], OPTIONAL);
 		else
-			update_prev_pos_arg(cmd, argv[i], OPTIONAL);
+			_update_prev_pos_arg(cmd, argv[i], OPTIONAL);
 	}
 }
 
-static void add_required_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
+static void _add_required_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
 {
 	int takes_arg = 0;
 	int i;
 
 	for (i = 0; i < argc; i++) {
-		if (is_opt_name(argv[i]))
-			add_opt_arg(cmd, argv[i], &takes_arg, NULL, REQUIRED);
+		if (_is_opt_name(argv[i]))
+			_add_opt_arg(cmd, argv[i], &takes_arg, NULL, REQUIRED);
 		else if (takes_arg)
-			update_prev_opt_arg(cmdtool, cmd, argv[i], REQUIRED);
+			_update_prev_opt_arg(cmdtool, cmd, argv[i], REQUIRED);
 		else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				  i, argv[i], argv[i-1]);
@@ -1075,14 +1075,14 @@ static void add_required_opt_line(struct cmd_context *cmdtool, struct command *c
  * this special case.
  */
  
-static void include_required_opt_args(struct cmd_context *cmdtool, struct command *cmd, char *str)
+static void _include_required_opt_args(struct cmd_context *cmdtool, struct command *cmd, char *str)
 {
 	char *oo_line;
 	char *line;
 	char *line_argv[MAX_LINE_ARGC];
 	int line_argc;
 
-	if (!(oo_line = get_oo_line(str))) {
+	if (!(oo_line = _get_oo_line(str))) {
 		log_error("Parsing command defs: no OO line found for %s.", str);
 		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
@@ -1093,14 +1093,14 @@ static void include_required_opt_args(struct cmd_context *cmdtool, struct comman
 		return;
 	}
 
-	split_line(line, &line_argc, line_argv, ' ');
-	add_required_opt_line(cmdtool, cmd, line_argc, line_argv);
+	_split_line(line, &line_argc, line_argv, ' ');
+	_add_required_opt_line(cmdtool, cmd, line_argc, line_argv);
 	dm_free(line);
 }
 
 /* Process what follows command_name, which are required opt/pos args. */
 
-static void add_required_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
+static void _add_required_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
 {
 	int i;
 	int takes_arg;
@@ -1110,32 +1110,32 @@ static void add_required_line(struct cmd_context *cmdtool, struct command *cmd,
 
 	for (i = 1; i < argc; i++) {
 
-		if (is_opt_name(argv[i])) {
+		if (_is_opt_name(argv[i])) {
 			/* add new required_opt_arg */
-			add_opt_arg(cmd, argv[i], &takes_arg, NULL, REQUIRED);
+			_add_opt_arg(cmd, argv[i], &takes_arg, NULL, REQUIRED);
 			prev_was_opt = 1;
 			prev_was_pos = 0;
 
 		} else if (prev_was_opt && takes_arg) {
 			/* set value for previous required_opt_arg */
-			update_prev_opt_arg(cmdtool, cmd, argv[i], REQUIRED);
+			_update_prev_opt_arg(cmdtool, cmd, argv[i], REQUIRED);
 			prev_was_opt = 0;
 			prev_was_pos = 0;
 
-		} else if (is_pos_name(argv[i])) {
+		} else if (_is_pos_name(argv[i])) {
 			/* add new required_pos_arg */
-			add_pos_arg(cmd, argv[i], REQUIRED);
+			_add_pos_arg(cmd, argv[i], REQUIRED);
 			prev_was_opt = 0;
 			prev_was_pos = 1;
 
 		} else if (!strncmp(argv[i], "OO_", 3)) {
 			/* one required_opt_arg is required, special case lv/vgchange */
 			cmd->cmd_flags |= CMD_FLAG_ONE_REQUIRED_OPT;
-			include_required_opt_args(cmdtool, cmd, argv[i]);
+			_include_required_opt_args(cmdtool, cmd, argv[i]);
 
 		} else if (prev_was_pos) {
 			/* set property for previous required_pos_arg */
-			update_prev_pos_arg(cmd, argv[i], REQUIRED);
+			_update_prev_pos_arg(cmd, argv[i], REQUIRED);
 		} else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				  i, argv[i], argv[i-1]);
@@ -1145,7 +1145,7 @@ static void add_required_line(struct cmd_context *cmdtool, struct command *cmd,
 	}
 }
 
-static void add_flags(struct command *cmd, char *line)
+static void _add_flags(struct command *cmd, char *line)
 {
 	if (strstr(line, "SECONDARY_SYNTAX"))
 		cmd->cmd_flags |= CMD_FLAG_SECONDARY_SYNTAX;
@@ -1155,7 +1155,7 @@ static void add_flags(struct command *cmd, char *line)
 
 #define MAX_RULE_OPTS 64
 
-static void add_rule(struct cmd_context *cmdtool, struct command *cmd, char *line)
+static void _add_rule(struct cmd_context *cmdtool, struct command *cmd, char *line)
 {
 	struct cmd_rule *rule;
 	char *line_argv[MAX_LINE_ARGC];
@@ -1172,7 +1172,7 @@ static void add_rule(struct cmd_context *cmdtool, struct command *cmd, char *lin
 
 	rule = &cmd->rules[cmd->rule_count++];
 
-	split_line(line, &line_argc, line_argv, ' ');
+	_split_line(line, &line_argc, line_argv, ' ');
 
 	for (i = 0; i < line_argc; i++) {
 		arg = line_argv[i];
@@ -1212,13 +1212,13 @@ static void add_rule(struct cmd_context *cmdtool, struct command *cmd, char *lin
 			}
 
 			if (check)
-				rule->check_opts[rule->check_opts_count++] = opt_str_to_num(cmd, arg);
+				rule->check_opts[rule->check_opts_count++] = _opt_str_to_num(cmd, arg);
 			else
-				rule->opts[rule->opts_count++] = opt_str_to_num(cmd, arg);
+				rule->opts[rule->opts_count++] = _opt_str_to_num(cmd, arg);
 		}
 
 		else if (!strncmp(arg, "LV_", 3)) {
-			lvt_enum = lv_to_enum(cmd, arg);
+			lvt_enum = _lv_to_enum(cmd, arg);
 
 			if (check)
 				rule->check_lvt_bits |= lvt_enum_to_bit(lvt_enum);
@@ -1227,7 +1227,7 @@ static void add_rule(struct cmd_context *cmdtool, struct command *cmd, char *lin
 		}
 
 		else if (!strncmp(arg, "lv_is_", 6)) {
-			lvp_enum = lvp_name_to_enum(cmd, arg);
+			lvp_enum = _lvp_name_to_enum(cmd, arg);
 
 			if (check)
 				rule->check_lvp_bits |= lvp_enum_to_bit(lvp_enum);
@@ -1239,7 +1239,7 @@ static void add_rule(struct cmd_context *cmdtool, struct command *cmd, char *lin
 
 /* The given option is common to all lvm commands (set in lvm_all). */
 
-static int is_lvm_all_opt(int opt)
+static int _is_lvm_all_opt(int opt)
 {
 	int oo;
 
@@ -1335,26 +1335,27 @@ int command_has_alternate_extents(const char *name)
 	return 0;
 }
 
-static int long_name_compare(const void *on1, const void *on2)
+static int _long_name_compare(const void *on1, const void *on2)
 {
 	const struct opt_name * const *optname1 = on1;
 	const struct opt_name * const *optname2 = on2;
+
 	return strcmp((*optname1)->long_opt + 2, (*optname2)->long_opt + 2);
 }
 
 /* Create list of option names for printing alphabetically. */
 
-static void create_opt_names_alpha(void)
+static void _create_opt_names_alpha(void)
 {
 	int i;
 
 	for (i = 0; i < ARG_COUNT; i++)
 		opt_names_alpha[i] = &opt_names[i];
 
-	qsort(opt_names_alpha, ARG_COUNT, sizeof(long), long_name_compare);
+	qsort(opt_names_alpha, ARG_COUNT, sizeof(long), _long_name_compare);
 }
 
-static int copy_line(char *line, int max_line, int *position)
+static int _copy_line(char *line, int max_line, int *position)
 {
 	int p = *position;
 	int i = 0;
@@ -1398,11 +1399,11 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 	if (run_name && !strcmp(run_name, "help"))
 		run_name = NULL;
 
-	create_opt_names_alpha();
+	_create_opt_names_alpha();
 
 	/* Process each line of command-lines-input.h (from command-lines.in) */
 
-	while (copy_line(line, MAX_LINE, &copy_pos)) {
+	while (_copy_line(line, MAX_LINE, &copy_pos)) {
 		if (line[0] == '\n')
 			break;
 
@@ -1410,13 +1411,13 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 			*n = '\0';
 
 		memcpy(line_orig, line, sizeof(line));
-		split_line(line, &line_argc, line_argv, ' ');
+		_split_line(line, &line_argc, line_argv, ' ');
 
 		if (!line_argc)
 			continue;
 
 		/* New cmd def begins: command_name <required opt/pos args> */
-		if ((name = is_command_name(line_argv[0]))) {
+		if ((name = _is_command_name(line_argv[0]))) {
 			if (cmd_count >= COMMAND_COUNT) {
 				return 0;
 			}
@@ -1448,10 +1449,10 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 			skip = 0;
 
 			cmd->pos_count = 1;
-			add_required_line(cmdtool, cmd, line_argc, line_argv);
+			_add_required_line(cmdtool, cmd, line_argc, line_argv);
 
 			/* Every cmd gets the OO_ALL options */
-			include_optional_opt_args(cmdtool, cmd, "OO_ALL:");
+			_include_optional_opt_args(cmdtool, cmd, "OO_ALL:");
 			continue;
 		}
 
@@ -1460,7 +1461,7 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 		 * context of the existing command[].
 		 */
 
-		if (is_desc_line(line_argv[0]) && !skip && cmd) {
+		if (_is_desc_line(line_argv[0]) && !skip && cmd) {
 			char *desc = dm_pool_strdup(cmdtool->libmem, line_orig);
 			if (cmd->desc) {
 				int newlen = strlen(cmd->desc) + strlen(desc) + 2;
@@ -1479,17 +1480,17 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 			continue;
 		}
 
-		if (is_flags_line(line_argv[0]) && !skip && cmd) {
-			add_flags(cmd, line_orig);
+		if (_is_flags_line(line_argv[0]) && !skip && cmd) {
+			_add_flags(cmd, line_orig);
 			continue;
 		}
 
-		if (is_rule_line(line_argv[0]) && !skip && cmd) {
-			add_rule(cmdtool, cmd, line_orig);
+		if (_is_rule_line(line_argv[0]) && !skip && cmd) {
+			_add_rule(cmdtool, cmd, line_orig);
 			continue;
 		}
 
-		if (is_id_line(line_argv[0]) && cmd) {
+		if (_is_id_line(line_argv[0]) && cmd) {
 			cmd->command_id = dm_pool_strdup(cmdtool->libmem, line_argv[1]);
 
 			if (!cmd->command_id) {
@@ -1501,8 +1502,8 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 		}
 
 		/* OO_FOO: ... */
-		if (is_oo_definition(line_argv[0])) {
-			add_oo_definition_line(line_argv[0], line_orig);
+		if (_is_oo_definition(line_argv[0])) {
+			_add_oo_definition_line(line_argv[0], line_orig);
 			prev_was_oo_def = 1;
 			prev_was_oo = 0;
 			prev_was_op = 0;
@@ -1510,8 +1511,8 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 		}
 
 		/* OO: ... */
-		if (is_oo_line(line_argv[0]) && !skip && cmd) {
-			add_optional_opt_line(cmdtool, cmd, line_argc, line_argv);
+		if (_is_oo_line(line_argv[0]) && !skip && cmd) {
+			__add_optional_opt_line(cmdtool, cmd, line_argc, line_argv);
 			prev_was_oo_def = 0;
 			prev_was_oo = 1;
 			prev_was_op = 0;
@@ -1519,8 +1520,8 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 		}
 
 		/* OP: ... */
-		if (is_op_line(line_argv[0]) && !skip && cmd) {
-			add_optional_pos_line(cmd, line_argc, line_argv);
+		if (_is_op_line(line_argv[0]) && !skip && cmd) {
+			_add_optional_pos_line(cmd, line_argc, line_argv);
 			prev_was_oo_def = 0;
 			prev_was_oo = 0;
 			prev_was_op = 1;
@@ -1528,8 +1529,8 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 		}
 
 		/* IO: ... */
-		if (is_io_line(line_argv[0]) && !skip && cmd) {
-			add_ignore_opt_line(cmdtool, cmd, line_argc, line_argv);
+		if (_is_io_line(line_argv[0]) && !skip && cmd) {
+			_add_ignore_opt_line(cmdtool, cmd, line_argc, line_argv);
 			prev_was_oo = 0;
 			prev_was_op = 0;
 			continue;
@@ -1538,17 +1539,17 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 		/* handle OO_FOO:, OO:, OP: continuing on multiple lines */
 
 		if (prev_was_oo_def) {
-			append_oo_definition_line(line_orig);
+			_append_oo_definition_line(line_orig);
 			continue;
 		}
 
 		if (prev_was_oo && cmd) {
-			add_optional_opt_line(cmdtool, cmd, line_argc, line_argv);
+			__add_optional_opt_line(cmdtool, cmd, line_argc, line_argv);
 			continue;
 		}
 
 		if (prev_was_op && cmd) {
-			add_optional_pos_line(cmd, line_argc, line_argv);
+			_add_optional_pos_line(cmd, line_argc, line_argv);
 			continue;
 		}
 
@@ -1561,15 +1562,15 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 			return 0;
 	}
 
-	include_optional_opt_args(cmdtool, &lvm_all, "OO_ALL");
+	_include_optional_opt_args(cmdtool, &lvm_all, "OO_ALL");
 
-	for (i = 0; i < oo_line_count; i++) {
-		struct oo_line *oo = &oo_lines[i];
+	for (i = 0; i < _oo_line_count; i++) {
+		struct oo_line *oo = &_oo_lines[i];
 		dm_free(oo->name);
 		dm_free(oo->line);
 	}
-	memset(&oo_lines, 0, sizeof(oo_lines));
-	oo_line_count = 0;
+	memset(&_oo_lines, 0, sizeof(_oo_lines));
+	_oo_line_count = 0;
 
 	return 1;
 }
@@ -1665,7 +1666,7 @@ void configure_command_option_values(const char *name)
 
 /* type_LVT to "type" */
 
-static const char *lvt_enum_to_name(int lvt_enum)
+static const char *_lvt_enum_to_name(int lvt_enum)
 {
 	return lv_types[lvt_enum].name;
 }
@@ -1706,7 +1707,7 @@ static void _print_usage_description(struct command *cmd)
 	}
 }
 
-static void print_val_usage(struct command *cmd, int opt_enum, int val_enum)
+static void _print_val_usage(struct command *cmd, int opt_enum, int val_enum)
 {
 	int is_relative_opt = (opt_enum == size_ARG) ||
 			      (opt_enum == extents_ARG) ||
@@ -1732,7 +1733,7 @@ static void print_val_usage(struct command *cmd, int opt_enum, int val_enum)
 		printf("%s", val_names[val_enum].usage);
 }
 
-static void print_usage_def(struct command *cmd, int opt_enum, struct arg_def *def)
+static void _print_usage_def(struct command *cmd, int opt_enum, struct arg_def *def)
 {
 	int val_enum;
 	int lvt_enum;
@@ -1749,14 +1750,14 @@ static void print_usage_def(struct command *cmd, int opt_enum, struct arg_def *d
 
 			else {
 				if (sep) printf("|");
-				print_val_usage(cmd, opt_enum, val_enum);
+				_print_val_usage(cmd, opt_enum, val_enum);
 				sep = 1;
 			}
 
 			if (val_enum == lv_VAL && def->lvt_bits) {
 				for (lvt_enum = 1; lvt_enum < LVT_COUNT; lvt_enum++) {
 					if (lvt_bit_is_set(def->lvt_bits, lvt_enum))
-						printf("_%s", lvt_enum_to_name(lvt_enum));
+						printf("_%s", _lvt_enum_to_name(lvt_enum));
 				}
 			}
 
@@ -1773,7 +1774,7 @@ static void print_usage_def(struct command *cmd, int opt_enum, struct arg_def *d
 
 void print_usage(struct command *cmd, int longhelp, int desc_first)
 {
-	struct command_name *cname = find_command_name(cmd->name);
+	struct command_name *cname = _find_command_name(cmd->name);
 	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
 	int include_extents = 0;
 	int ro, rp, oo, op, opt_enum, first;
@@ -1813,7 +1814,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
+				_print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
 			}
 		}
 
@@ -1837,7 +1838,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
+				_print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
 			}
 		}
 
@@ -1858,7 +1859,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
+				_print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
 			}
 		}
 	}
@@ -1869,7 +1870,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
 				printf(" ");
-				print_usage_def(cmd, 0, &cmd->required_pos_args[rp].def);
+				_print_usage_def(cmd, 0, &cmd->required_pos_args[rp].def);
 			}
 		}
 	}
@@ -1883,7 +1884,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 	if (cmd->oo_count) {
 		if (include_extents) {
 			printf("\n\t[ -l|--extents ");
-			print_val_usage(cmd, extents_ARG, opt_names[extents_ARG].val_enum);
+			_print_val_usage(cmd, extents_ARG, opt_names[extents_ARG].val_enum);
 			printf(" ]");
 		}
 
@@ -1901,7 +1902,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			 * see print_common_options_lvm()
 			 */
 
-			if (is_lvm_all_opt(opt_enum))
+			if (_is_lvm_all_opt(opt_enum))
 				continue;
 
 			/*
@@ -1921,7 +1922,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
+				_print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
 			}
 
 			printf(" ]");
@@ -1941,7 +1942,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			 * see print_common_options_lvm()
 			 */
 
-			if (is_lvm_all_opt(opt_enum))
+			if (_is_lvm_all_opt(opt_enum))
 				continue;
 
 			/*
@@ -1961,7 +1962,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			printf("    %s", opt_names[opt_enum].long_opt);
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
+				_print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
 			}
 
 			printf(" ]");
@@ -1980,7 +1981,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		for (op = 0; op < cmd->op_count; op++) {
 			if (cmd->optional_pos_args[op].def.val_bits) {
 				printf(" ");
-				print_usage_def(cmd, 0, &cmd->optional_pos_args[op].def);
+				_print_usage_def(cmd, 0, &cmd->optional_pos_args[op].def);
 			}
 		}
 	}
@@ -2014,7 +2015,7 @@ void print_usage_common_lvm(struct command_name *cname, struct command *cmd)
 		printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
 		if (lvm_all.optional_opt_args[oo].def.val_bits) {
 			printf(" ");
-			print_usage_def(cmd, opt_enum, &lvm_all.optional_opt_args[oo].def);
+			_print_usage_def(cmd, opt_enum, &lvm_all.optional_opt_args[oo].def);
 		}
 		printf(" ]");
 	}
@@ -2032,7 +2033,7 @@ void print_usage_common_lvm(struct command_name *cname, struct command *cmd)
 		printf("    %s", opt_names[opt_enum].long_opt);
 		if (lvm_all.optional_opt_args[oo].def.val_bits) {
 			printf(" ");
-			print_usage_def(cmd, opt_enum, &lvm_all.optional_opt_args[oo].def);
+			_print_usage_def(cmd, opt_enum, &lvm_all.optional_opt_args[oo].def);
 		}
 		printf(" ]");
 	}
@@ -2060,7 +2061,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 		if (!cname->common_options[opt_enum])
 			continue;
 
-		if (is_lvm_all_opt(opt_enum))
+		if (_is_lvm_all_opt(opt_enum))
 			continue;
 
 		if (!opt_names[opt_enum].short_opt)
@@ -2075,7 +2076,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 			printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
+				_print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
 			}
 			break;
 		}
@@ -2088,7 +2089,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 		if (!cname->common_options[opt_enum])
 			continue;
 
-		if (is_lvm_all_opt(opt_enum))
+		if (_is_lvm_all_opt(opt_enum))
 			continue;
 
 		if (opt_names[opt_enum].short_opt)
@@ -2103,7 +2104,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 			printf("    %s", opt_names[opt_enum].long_opt);
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
+				_print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
 			}
 			break;
 		}
@@ -2185,7 +2186,7 @@ void print_usage_notes(struct command_name *cname)
  * Otherwise, this function has to be updated in
  * sync with any string changes in vals.h
  */
-static void print_val_man(struct command_name *cname, int opt_enum, int val_enum)
+static void _print_val_man(struct command_name *cname, int opt_enum, int val_enum)
 {
 	const char *str;
 	char *line;
@@ -2296,7 +2297,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 
 	if (strchr(str, '|')) {
 		line = dm_strdup(str);
-		split_line(line, &line_argc, line_argv, '|');
+		_split_line(line, &line_argc, line_argv, '|');
 		for (i = 0; i < line_argc; i++) {
 			if (i)
 				printf("|");
@@ -2312,7 +2313,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	printf("\\fB%s\\fP", str);
 }
 
-static void print_def_man(struct command_name *cname, int opt_enum, struct arg_def *def, int usage)
+static void _print_def_man(struct command_name *cname, int opt_enum, struct arg_def *def, int usage)
 {
 	int val_enum;
 	int lvt_enum;
@@ -2333,7 +2334,7 @@ static void print_def_man(struct command_name *cname, int opt_enum, struct arg_d
 				if (!usage || !val_names[val_enum].usage)
 					printf("\\fI%s\\fP", val_names[val_enum].name);
 				else
-					print_val_man(cname, opt_enum, val_enum);
+					_print_val_man(cname, opt_enum, val_enum);
 
 				sep = 1;
 			}
@@ -2342,7 +2343,7 @@ static void print_def_man(struct command_name *cname, int opt_enum, struct arg_d
 				printf("\\fI");
 				for (lvt_enum = 1; lvt_enum < LVT_COUNT; lvt_enum++) {
 					if (lvt_bit_is_set(def->lvt_bits, lvt_enum))
-						printf("_%s", lvt_enum_to_name(lvt_enum));
+						printf("_%s", _lvt_enum_to_name(lvt_enum));
 				}
 				printf("\\fP");
 			}
@@ -2358,7 +2359,7 @@ static void print_def_man(struct command_name *cname, int opt_enum, struct arg_d
 }
 
 #define	LONG_OPT_NAME_LEN	64
-static const char *man_long_opt_name(const char *cmdname, int opt_enum)
+static const char *_man_long_opt_name(const char *cmdname, int opt_enum)
 {
 	static char long_opt_name[LONG_OPT_NAME_LEN];
 	const char *long_opt;
@@ -2409,7 +2410,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 	int need_ro_indent_end = 0;
 	int include_extents = 0;
 
-	if (!(cname = find_command_name(cmd->name)))
+	if (!(cname = _find_command_name(cmd->name)))
 		return;
 
 	printf("\\fB%s\\fP", lvmname);
@@ -2453,15 +2454,15 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			if (opt_names[opt_enum].short_opt) {
 				printf(" \\fB-%c\\fP|\\fB%s\\fP",
 				       opt_names[opt_enum].short_opt,
-				       man_long_opt_name(cmd->name, opt_enum));
+				       _man_long_opt_name(cmd->name, opt_enum));
 			} else {
 				printf("   ");
-				printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+				printf(" \\fB%s\\fP", _man_long_opt_name(cmd->name, opt_enum));
 			}
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
 			}
 
 			sep++;
@@ -2484,11 +2485,11 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				printf(".ad l\n");
 
 			printf("   ");
-			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+			printf(" \\fB%s\\fP", _man_long_opt_name(cmd->name, opt_enum));
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
 			}
 
 			sep++;
@@ -2504,7 +2505,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, 0, &cmd->required_pos_args[rp].def, 1);
+				_print_def_man(cname, 0, &cmd->required_pos_args[rp].def, 1);
 			}
 		}
 
@@ -2543,13 +2544,13 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			if (opt_names[opt_enum].short_opt) {
 				printf(" \\fB-%c\\fP|\\fB%s\\fP",
 				       opt_names[opt_enum].short_opt,
-				       man_long_opt_name(cmd->name, opt_enum));
+				       _man_long_opt_name(cmd->name, opt_enum));
 			} else
 				printf(" \\fB%s\\fP", opt_names[cmd->required_opt_args[ro].opt].long_opt);
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
 			}
 
 			sep++;
@@ -2561,7 +2562,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, 0, &cmd->required_pos_args[rp].def, 1);
+				_print_def_man(cname, 0, &cmd->required_pos_args[rp].def, 1);
 			}
 		}
 
@@ -2592,7 +2593,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			 */
 			printf(".ad l\n");
 			printf("[ \\fB-l\\fP|\\fB--extents\\fP ");
-			print_val_man(cname, extents_ARG, opt_names[extents_ARG].val_enum);
+			_print_val_man(cname, extents_ARG, opt_names[extents_ARG].val_enum);
 			printf(" ]\n");
 			printf(".ad b\n");
 			sep = 1;
@@ -2606,7 +2607,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			if (!opt_names[opt_enum].short_opt)
 				continue;
 
-			if (is_lvm_all_opt(opt_enum))
+			if (_is_lvm_all_opt(opt_enum))
 				continue;
 
 			if ((cname->variants > 1) && cname->common_options[opt_enum])
@@ -2618,11 +2619,11 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
-				man_long_opt_name(cmd->name, opt_enum));
+				_man_long_opt_name(cmd->name, opt_enum));
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2637,7 +2638,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			if (opt_names[opt_enum].short_opt)
 				continue;
 
-			if (is_lvm_all_opt(opt_enum))
+			if (_is_lvm_all_opt(opt_enum))
 				continue;
 
 			if ((cname->variants > 1) && cname->common_options[opt_enum])
@@ -2650,11 +2651,11 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			/* space alignment without short opt */
 			printf("[   ");
 
-			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+			printf(" \\fB%s\\fP", _man_long_opt_name(cmd->name, opt_enum));
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2682,7 +2683,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		for (op = 0; op < cmd->op_count; op++) {
 			if (cmd->optional_pos_args[op].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, 0, &cmd->optional_pos_args[op].def, 1);
+				_print_def_man(cname, 0, &cmd->optional_pos_args[op].def, 1);
 			}
 		}
 	}
@@ -2696,7 +2697,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
  *
  * For commands with only one variant, this is only
  * the options which are common to all lvm commands
- * (in lvm_all, see is_lvm_all_opt).
+ * (in lvm_all, see _is_lvm_all_opt).
  *
  * For commands with more than one variant, this
  * is the set of options common to all variants
@@ -2713,7 +2714,7 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 	struct command_name *cname;
 	int i, sep, oo, opt_enum;
 
-	if (!(cname = find_command_name(cmd->name)))
+	if (!(cname = _find_command_name(cmd->name)))
 		return;
 
 	printf("Common options for lvm:\n");
@@ -2730,7 +2731,7 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 		if (!opt_names[opt_enum].short_opt)
 			continue;
 
-		if (!is_lvm_all_opt(opt_enum))
+		if (!_is_lvm_all_opt(opt_enum))
 			continue;
 
 		if (sep)
@@ -2743,11 +2744,11 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 
 			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
-				man_long_opt_name(cmd->name, opt_enum));
+				_man_long_opt_name(cmd->name, opt_enum));
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2764,7 +2765,7 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 		if (opt_names[opt_enum].short_opt)
 			continue;
 
-		if (!is_lvm_all_opt(opt_enum))
+		if (!_is_lvm_all_opt(opt_enum))
 			continue;
 
 		if (sep)
@@ -2778,11 +2779,11 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 			/* space alignment without short opt */
 			printf("[   ");
 
-			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+			printf(" \\fB%s\\fP", _man_long_opt_name(cmd->name, opt_enum));
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2800,7 +2801,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 	struct command_name *cname;
 	int i, sep, oo, opt_enum;
 
-	if (!(cname = find_command_name(cmd->name)))
+	if (!(cname = _find_command_name(cmd->name)))
 		return;
 
 	if (cname->variants < 2)
@@ -2827,7 +2828,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 		if (cname->variants < 2)
 			continue;
 
-		if (is_lvm_all_opt(opt_enum))
+		if (_is_lvm_all_opt(opt_enum))
 			continue;
 
 		if (sep)
@@ -2840,11 +2841,11 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 
 			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
-				man_long_opt_name(cmd->name, opt_enum));
+				_man_long_opt_name(cmd->name, opt_enum));
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2868,7 +2869,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 		if (cname->variants < 2)
 			continue;
 
-		if (is_lvm_all_opt(opt_enum))
+		if (_is_lvm_all_opt(opt_enum))
 			continue;
 
 		if (sep)
@@ -2882,11 +2883,11 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 			/* space alignment without short opt */
 			printf("[   ");
 
-			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+			printf(" \\fB%s\\fP", _man_long_opt_name(cmd->name, opt_enum));
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -3003,10 +3004,10 @@ static void _print_man_all_options_list(struct command_name *cname)
 		if (opt_names[opt_enum].short_opt) {
 			printf(" \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
-				man_long_opt_name(cname->name, opt_enum));
+				_man_long_opt_name(cname->name, opt_enum));
 		} else {
 			/* spaces for alignment without short opt */
-			printf("    \\fB%s\\fP", man_long_opt_name(cname->name, opt_enum));
+			printf("    \\fB%s\\fP", _man_long_opt_name(cname->name, opt_enum));
 		}
 
 		val_enum = opt_names[opt_enum].val_enum;
@@ -3020,7 +3021,7 @@ static void _print_man_all_options_list(struct command_name *cname)
 			printf("\\fP");
 		} else {
 			printf(" ");
-			print_val_man(cname, opt_enum, val_enum);
+			_print_val_man(cname, opt_enum, val_enum);
 		}
 
 		printf("\n.ad b\n");
@@ -3051,9 +3052,9 @@ static void _print_man_all_options_desc(struct command_name *cname)
 		if (opt_names[opt_enum].short_opt) {
 			printf("\\fB-%c\\fP|\\fB%s\\fP",
 			       opt_names[opt_enum].short_opt,
-			       man_long_opt_name(cname->name, opt_enum));
+			       _man_long_opt_name(cname->name, opt_enum));
 		} else {
-			printf("\\fB%s\\fP", man_long_opt_name(cname->name, opt_enum));
+			printf("\\fB%s\\fP", _man_long_opt_name(cname->name, opt_enum));
 		}
 
 		val_enum = opt_names[opt_enum].val_enum;
@@ -3067,7 +3068,7 @@ static void _print_man_all_options_desc(struct command_name *cname)
 			printf("\\fP");
 		} else {
 			printf(" ");
-			print_val_man(cname, opt_enum, val_enum);
+			_print_val_man(cname, opt_enum, val_enum);
 		}
 
 		if (opt_names[opt_enum].flags & ARG_COUNTABLE)
@@ -3277,7 +3278,7 @@ static void _print_desc_man(const char *desc)
 	}
 }
 
-static char *upper_command_name(char *str)
+static const char *_upper_command_name(char *str)
 {
 	static char str_upper[32];
 	int i = 0;
@@ -3292,7 +3293,7 @@ static char *upper_command_name(char *str)
 
 #define MAX_MAN_DESC (1024 * 1024)
 
-static int include_description_file(char *name, char *des_file)
+static int _include_description_file(char *name, char *des_file)
 {
 	char *buf;
 	int fd, r = 0;
@@ -3348,10 +3349,10 @@ static int _print_man(char *name, char *des_file, int secondary)
 		name += 4;
 	}
 
-	cname = find_command_name(name);
+	cname = _find_command_name(name);
 
 	printf(".TH %s 8 \"LVM TOOLS #VERSION#\" \"Red Hat, Inc.\"\n",
-		upper_command_name(lvmname));
+		_upper_command_name(lvmname));
 
 	for (i = 0; i < COMMAND_COUNT; i++) {
 
@@ -3389,7 +3390,7 @@ static int _print_man(char *name, char *des_file, int secondary)
 			printf(".SH SYNOPSIS\n");
 			prev_cmd = cmd;
 
-			if (!(cname = find_command_name(cmd->name)))
+			if (!(cname = _find_command_name(cmd->name)))
 				return 0;
 
 			if (cname->variant_has_ro && cname->variant_has_rp)
@@ -3419,7 +3420,7 @@ static int _print_man(char *name, char *des_file, int secondary)
 				_print_man_all_options_list(cname);
 			}
 
-			if (des_file && !include_description_file(lvmname, des_file))
+			if (des_file && !_include_description_file(lvmname, des_file))
 				return 0;
 
 			printf(".SH USAGE\n");
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5a9f006..661910f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4625,8 +4625,8 @@ FIELD_F(STATS_META, STR, "ObjType", 7, dm_stats_object_type, "obj_type", "Type o
 #undef NUM
 #undef SIZ
 
-static const char *default_report_options = "name,major,minor,attr,open,segments,events,uuid";
-static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
+static const char *_default_report_options = "name,major,minor,attr,open,segments,events,uuid";
+static const char *_splitname_report_options = "vg_name,lv_name,lv_layer";
 
 /* Stats counters & derived metrics. */
 #define RD_COUNTERS "read_count,reads_merged_count,read_sector_count,read_time,read_ticks"
@@ -4661,7 +4661,7 @@ static const char *_stats_hist_relative_options = STATS_HIST ",hist_percent_boun
 
 static int _report_init(const struct command *cmd, const char *subcommand)
 {
-	char *options = (char *) default_report_options;
+	char *options = (char *) _default_report_options;
 	char *opt_fields = NULL; /* optional fields from command line */
 	const char *keys = "";
 	const char *separator = " ";
@@ -4673,7 +4673,7 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 	int r = 0;
 
 	if (cmd && !strcmp(cmd->name, "splitname")) {
-		options = (char *) splitname_report_options;
+		options = (char *) _splitname_report_options;
 		_report_type |= DR_NAME;
 	}
 
@@ -6490,7 +6490,7 @@ static int _process_tree_options(const char *options)
 	return 1;
 }
 
-static char *parse_loop_device_name(const char *dev, const char *dev_dir)
+static char *_parse_loop_device_name(const char *dev, const char *dev_dir)
 {
 	char *buf;
 	char *device = NULL;
@@ -6657,7 +6657,7 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 		return 0;
 	}
 
-	if (!(device_name = parse_loop_device_name((*argvp)[0], dev_dir))) {
+	if (!(device_name = _parse_loop_device_name((*argvp)[0], dev_dir))) {
 		fprintf(stderr, "%s: Could not parse loop_device %s\n",
 			base, (*argvp)[0]);
 		_usage(stderr);
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 92161e2..83dbf97 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -241,7 +241,7 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 	return 1;
 }
 
-static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
+static int _detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 {
 	uint32_t s;
 	uint32_t num_meta_lvs;
@@ -274,7 +274,7 @@ static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 	return 1;
 }
 
-static int attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
+static int _attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 {
 	struct lv_list *lvl;
 
@@ -407,7 +407,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	lv->status &= ~LV_NOTSYNCED;
 
 	/* Separate mirror log or metadata devices so we can clear them */
-	if (!detach_metadata_devices(seg, &device_list)) {
+	if (!_detach_metadata_devices(seg, &device_list)) {
 		log_error("Failed to clear %s %s for %s.",
 			  lvseg_name(seg), seg_is_raid(seg) ?
 			  "metadata area" : "mirror log", display_lvname(lv));
@@ -458,7 +458,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	}
 
 	/* Put metadata sub-LVs back in place */
-	if (!attach_metadata_devices(seg, &device_list)) {
+	if (!_attach_metadata_devices(seg, &device_list)) {
 		log_error("Failed to reattach %s device after clearing.",
 			  (seg_is_raid(seg)) ? "metadata" : "log");
 		return 0;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index fc4b3bb..f2e208c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -91,7 +91,7 @@ static struct cmdline_context _cmdline;
  * to use these functions instead of the old per-command-name function.
  * For now, any command id not included here uses the old command fn.
  */
-static const struct command_function command_functions[CMD_COUNT] = {
+static const struct command_function _command_functions[CMD_COUNT] = {
 	{ lvmconfig_general_CMD, lvmconfig },
 	{ lvchange_properties_CMD, lvchange_properties_cmd },
 	{ lvchange_resync_CMD, lvchange_resync_cmd },
@@ -1234,7 +1234,7 @@ static void _set_valid_args_for_command_name(int ci)
 	command_names[ci].num_args = num_args;
 }
 
-static struct command_name *find_command_name(const char *name)
+static struct command_name *_find_command_name(const char *name)
 {
 	int i;
 	
@@ -1255,8 +1255,8 @@ static const struct command_function *_find_command_id_function(int command_enum
 		return NULL;
 
 	for (i = 0; i < CMD_COUNT; i++) {
-		if (command_functions[i].command_enum == command_enum)
-			return &command_functions[i];
+		if (_command_functions[i].command_enum == command_enum)
+			return &_command_functions[i];
 	}
 	return NULL;
 }
@@ -1307,7 +1307,7 @@ int lvm_register_commands(struct cmd_context *cmd, const char *run_name)
 
 		/* old style */
 		if (!commands[i].functions) {
-			struct command_name *cname = find_command_name(commands[i].name);
+			struct command_name *cname = _find_command_name(commands[i].name);
 			if (cname)
 				commands[i].fn = cname->fn;
 		}
@@ -1877,7 +1877,7 @@ static void _short_usage(const char *name)
 
 static int _usage(const char *name, int longhelp, int skip_notes)
 {
-	struct command_name *cname = find_command_name(name);
+	struct command_name *cname = _find_command_name(name);
 	struct command *cmd = NULL;
 	int show_full = longhelp;
 	int i;
@@ -2041,7 +2041,7 @@ static int _find_arg(const char *cmd_name, int goval)
 	int arg_enum;
 	int i;
 
-	if (!(cname = find_command_name(cmd_name)))
+	if (!(cname = _find_command_name(cmd_name)))
 		return -1;
 
 	for (i = 0; i < cname->num_args; i++) {
@@ -2768,7 +2768,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 
 	/* Look up command - will be NULL if not recognised */
-	if (!(cmd->cname = find_command_name(cmd->name)))
+	if (!(cmd->cname = _find_command_name(cmd->name)))
 		return ENO_SUCH_CMD;
 
 	if (!_process_command_line(cmd, &argc, &argv)) {
@@ -3512,7 +3512,7 @@ int lvm2_main(int argc, char **argv)
 	 */
 	if (!run_name)
 		run_shell = 1;
-	else if (!find_command_name(run_name))
+	else if (!_find_command_name(run_name))
 		run_script = 1;
 	else
 		run_command_name = run_name;
diff --git a/tools/lvpoll.c b/tools/lvpoll.c
index fe237d9..8b4580f 100644
--- a/tools/lvpoll.c
+++ b/tools/lvpoll.c
@@ -72,7 +72,7 @@ static int _set_daemon_parms(struct cmd_context *cmd, struct daemon_parms *parms
 	return 1;
 }
 
-static int poll_lv(struct cmd_context *cmd, const char *lv_name)
+static int _poll_lv(struct cmd_context *cmd, const char *lv_name)
 {
 	struct daemon_parms parms = { 0 };
 	struct poll_operation_id id = {
@@ -110,5 +110,5 @@ int lvpoll(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return poll_lv(cmd, argv[0]);
+	return _poll_lv(cmd, argv[0]);
 }
diff --git a/tools/lvscan.c b/tools/lvscan.c
index ab3238b..c38208a 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -45,8 +45,8 @@ static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume
 	return ECMD_PROCESSED;
 }
 
-static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
-			 struct processing_handle *handle __attribute__((unused)))
+static int _lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
+			  struct processing_handle *handle __attribute__((unused)))
 {
 	struct lvinfo info;
 	int inkernel, snap_active = 1;
@@ -119,5 +119,5 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 		 */
 	}
 
-	return process_each_lv(cmd, argc, argv, NULL, NULL, 0, NULL, NULL, &lvscan_single);
+	return process_each_lv(cmd, argc, argv, NULL, NULL, 0, NULL, NULL, &_lvscan_single);
 }
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index a4df22e..d69284d 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -237,13 +237,13 @@ struct poll_id_list {
 	struct poll_operation_id *id;
 };
 
-static struct poll_operation_id *copy_poll_operation_id(struct dm_pool *mem,
+static struct poll_operation_id *_copy_poll_operation_id(struct dm_pool *mem,
 							const struct poll_operation_id *id)
 {
 	struct poll_operation_id *copy;
 
 	if (!id || !id->vg_name || !id->lv_name || !id->display_name || !id->uuid) {
-		log_error(INTERNAL_ERROR "Wrong params for copy_poll_operation_id.");
+		log_error(INTERNAL_ERROR "Wrong params for _copy_poll_operation_id.");
 		return NULL;
 	}
 
@@ -264,8 +264,8 @@ static struct poll_operation_id *copy_poll_operation_id(struct dm_pool *mem,
 	return copy;
 }
 
-static struct poll_id_list* poll_id_list_create(struct dm_pool *mem,
-						const struct poll_operation_id *id)
+static struct poll_id_list* _poll_id_list_create(struct dm_pool *mem,
+						 const struct poll_operation_id *id)
 {
 	struct poll_id_list *idl = (struct poll_id_list *) dm_pool_alloc(mem, sizeof(struct poll_id_list));
 
@@ -274,7 +274,7 @@ static struct poll_id_list* poll_id_list_create(struct dm_pool *mem,
 		return NULL;
 	}
 
-	if (!(idl->id = copy_poll_operation_id(mem, id))) {
+	if (!(idl->id = _copy_poll_operation_id(mem, id))) {
 		dm_pool_free(mem, idl);
 		return NULL;
 	}
@@ -329,7 +329,7 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		id.vg_name = vg->name;
 		id.uuid = lv->lvid.s;
 
-		idl = poll_id_list_create(cmd->mem, &id);
+		idl = _poll_id_list_create(cmd->mem, &id);
 		if (!idl) {
 			log_error("Failed to create poll_id_list.");
 			goto err;
@@ -379,8 +379,8 @@ typedef struct {
 	struct dm_list idls;
 } lvmpolld_parms_t;
 
-static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id,
-			   struct daemon_parms *parms)
+static int _report_progress(struct cmd_context *cmd, struct poll_operation_id *id,
+			    struct daemon_parms *parms)
 {
 	struct volume_group *vg;
 	struct logical_volume *lv;
@@ -482,7 +482,7 @@ static int _lvmpolld_init_poll_vg(struct cmd_context *cmd, const char *vgname,
 		r = lvmpolld_poll_init(cmd, &id, lpdp->parms);
 
 		if (r && !lpdp->parms->background) {
-			if (!(idl = poll_id_list_create(cmd->mem, &id)))
+			if (!(idl = _poll_id_list_create(cmd->mem, &id)))
 				return ECMD_FAILED;
 
 			dm_list_add(&lpdp->idls, &idl->list);
@@ -519,7 +519,7 @@ static void _lvmpolld_poll_for_all_vgs(struct cmd_context *cmd,
 			if (!r || finished)
 				dm_list_del(&idl->list);
 			else if (!parms->aborting)
-				report_progress(cmd, idl->id, lpdp.parms);
+				_report_progress(cmd, idl->id, lpdp.parms);
 		}
 
 		if (lpdp.parms->interval)
@@ -548,7 +548,7 @@ static int _lvmpoll_daemon(struct cmd_context *cmd, struct poll_operation_id *id
 			while (1) {
 				if (!(r = lvmpolld_request_info(id, parms, &finished)) ||
 				    finished ||
-				    (!parms->aborting && !(r = report_progress(cmd, id, parms))))
+				    (!parms->aborting && !(r = _report_progress(cmd, id, parms))))
 					break;
 
 				if (parms->interval)
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 9dc50e4..73605a8 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -22,8 +22,8 @@
  * Output arguments:
  * pp: structure allocated by caller, fields written / validated here
  */
-static int pvcreate_restore_params_from_args(struct cmd_context *cmd, int argc,
-					     struct pvcreate_params *pp)
+static int _pvcreate_restore_params_from_args(struct cmd_context *cmd, int argc,
+					      struct pvcreate_params *pp)
 {
 	pp->restorefile = arg_str_value(cmd, restorefile_ARG, NULL);
 
@@ -63,7 +63,7 @@ static int pvcreate_restore_params_from_args(struct cmd_context *cmd, int argc,
 	return 1;
 }
 
-static int pvcreate_restore_params_from_backup(struct cmd_context *cmd,
+static int _pvcreate_restore_params_from_backup(struct cmd_context *cmd,
 					       struct pvcreate_params *pp)
 {
 	struct volume_group *vg;
@@ -110,7 +110,7 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	/*
 	 * Device info needs to be available for reading the VG backup file in
-	 * pvcreate_restore_params_from_backup.
+	 * _pvcreate_restore_params_from_backup.
 	 */
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
@@ -126,10 +126,10 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	pvcreate_params_set_defaults(&pp);
 
-	if (!pvcreate_restore_params_from_args(cmd, argc, &pp))
+	if (!_pvcreate_restore_params_from_args(cmd, argc, &pp))
 		return EINVALID_CMD_LINE;
 
-	if (!pvcreate_restore_params_from_backup(cmd, &pp))
+	if (!_pvcreate_restore_params_from_backup(cmd, &pp))
 		return EINVALID_CMD_LINE;
 
 	if (!pvcreate_params_from_args(cmd, &pp))
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 305647e..09ce54b 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -293,7 +293,7 @@ static int _insert_pvmove_mirrors(struct cmd_context *cmd,
  *
  * Returns: 1 if true, 0 otherwise
  */
-static int sub_lv_of(struct logical_volume *lv, const char *lv_name)
+static int _sub_lv_of(struct logical_volume *lv, const char *lv_name)
 {
 	struct lv_segment *seg;
 
@@ -308,7 +308,7 @@ static int sub_lv_of(struct logical_volume *lv, const char *lv_name)
 		return 1;
 
 	/* Continue up the tree */
-	return sub_lv_of(seg->lv, lv_name);
+	return _sub_lv_of(seg->lv, lv_name);
 }
 
 /*
@@ -319,7 +319,7 @@ static int sub_lv_of(struct logical_volume *lv, const char *lv_name)
  *
  * If this LV is below a cache LV (at any depth), return 1.
  */
-static int parent_lv_is_cache_type(struct logical_volume *lv)
+static int _parent_lv_is_cache_type(struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 
@@ -334,7 +334,7 @@ static int parent_lv_is_cache_type(struct logical_volume *lv)
 		return 1;
 
 	/* Continue up the tree */
-	return parent_lv_is_cache_type(seg->lv);
+	return _parent_lv_is_cache_type(seg->lv);
 }
 
 /* Create new LV with mirror segments for the required copies */
@@ -451,7 +451,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 
 		if (lv_name) {
-			if (strcmp(lv->name, lv_name) && !sub_lv_of(lv, lv_name))
+			if (strcmp(lv->name, lv_name) && !_sub_lv_of(lv, lv_name))
 				continue;
 			lv_found = 1;
 		}
@@ -469,7 +469,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 		}
 
-		if (parent_lv_is_cache_type(lv)) {
+		if (_parent_lv_is_cache_type(lv)) {
 			log_print_unless_silent("Skipping %s because a parent"
 						" is of cache type", lv->name);
 			lv_skipped = 1;
diff --git a/tools/toollib.c b/tools/toollib.c
index fc615f3..79829f4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2375,7 +2375,7 @@ void opt_array_to_str(struct cmd_context *cmd, int *opts, int count,
 	buf[len - 1] = '\0';
 }
 
-static void lvp_bits_to_str(uint64_t bits, char *buf, int len)
+static void _lvp_bits_to_str(uint64_t bits, char *buf, int len)
 {
 	struct lv_prop *prop;
 	int lvp_enum;
@@ -2396,7 +2396,7 @@ static void lvp_bits_to_str(uint64_t bits, char *buf, int len)
 	buf[len - 1] = '\0';
 }
 
-static void lvt_bits_to_str(uint64_t bits, char *buf, int len)
+static void _lvt_bits_to_str(uint64_t bits, char *buf, int len)
 {
 	struct lv_type *type;
 	int lvt_enum;
@@ -2850,7 +2850,7 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 
 		if (rule->check_lvt_bits && (rule->rule == RULE_REQUIRE) && !lv_types_match_bits) {
 			memset(buf, 0, sizeof(buf));
-			lvt_bits_to_str(rule->check_lvt_bits, buf, sizeof(buf));
+			_lvt_bits_to_str(rule->check_lvt_bits, buf, sizeof(buf));
 			if (rule->opts_count)
 				log_warn("Command on LV %s uses options that require LV types %s.",
 					 display_lvname(lv), buf);
@@ -2864,7 +2864,7 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 
 		if (rule->check_lvp_bits && (rule->rule == RULE_INVALID) && lv_props_match_bits) {
 			memset(buf, 0, sizeof(buf));
-			lvp_bits_to_str(lv_props_match_bits, buf, sizeof(buf));
+			_lvp_bits_to_str(lv_props_match_bits, buf, sizeof(buf));
 			if (rule->opts_count)
 				log_warn("Command on LV %s uses options that are invalid with LV properties: %s.",
 				 	 display_lvname(lv), buf);
@@ -2878,7 +2878,7 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 
 		if (rule->check_lvp_bits && (rule->rule == RULE_REQUIRE) && lv_props_unmatch_bits) {
 			memset(buf, 0, sizeof(buf));
-			lvp_bits_to_str(lv_props_unmatch_bits, buf, sizeof(buf));
+			_lvp_bits_to_str(lv_props_unmatch_bits, buf, sizeof(buf));
 			if (rule->opts_count)
 				log_warn("Command on LV %s uses options that require LV properties: %s.",
 				 	 display_lvname(lv), buf);
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index a04c3ab..5d21131 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -47,9 +47,9 @@ static char *_expand_filename(const char *template, const char *vg_name,
 	return filename;
 }
 
-static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg,
-			    struct processing_handle *handle)
+static int _vg_backup_single(struct cmd_context *cmd, const char *vg_name,
+			     struct volume_group *vg,
+			     struct processing_handle *handle)
 {
 	char **last_filename = (char **)handle->custom_handle;
 	char *filename;
@@ -95,7 +95,7 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 	init_pvmove(1);
 
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_ALLOW_INCONSISTENT, 0,
-			      handle, &vg_backup_single);
+			      handle, &_vg_backup_single);
 
 	dm_free(last_filename);
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 3de635d..ae97a4a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -680,9 +680,9 @@ static int _vgchange_lock_stop(struct cmd_context *cmd, struct volume_group *vg)
 	return lockd_stop_vg(cmd, vg);
 }
 
-static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
-			   struct volume_group *vg,
-			   struct processing_handle *handle)
+static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
+			    struct volume_group *vg,
+			    struct processing_handle *handle)
 {
 	int ret = ECMD_PROCESSED;
 	unsigned i;
@@ -927,7 +927,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	ret = process_each_vg(cmd, argc, argv, NULL, NULL, flags, 0, handle, &vgchange_single);
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, flags, 0, handle, &_vgchange_single);
 
 	destroy_processing_handle(cmd, handle);
 	return ret;
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 9f98048..8bdf8be 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -15,9 +15,9 @@
 
 #include "tools.h"
 
-static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg,
-			    struct processing_handle *handle __attribute__((unused)))
+static int _vgconvert_single(struct cmd_context *cmd, const char *vg_name,
+			     struct volume_group *vg,
+			     struct processing_handle *handle __attribute__((unused)))
 {
 	struct pv_create_args pva = { 0 };
 	struct logical_volume *lv;
@@ -170,5 +170,5 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	return process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, 0, NULL,
-			       &vgconvert_single);
+			       &_vgconvert_single);
 }
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index f4b0b6f..e9d0842 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -15,9 +15,9 @@
 
 #include "tools.h"
 
-static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg,
-			    struct processing_handle *handle __attribute__((unused)))
+static int _vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
+			     struct volume_group *vg,
+			     struct processing_handle *handle __attribute__((unused)))
 {
 	if (arg_is_set(cmd, activevolumegroups_ARG) && !lvs_in_vg_activated(vg))
 		return ECMD_PROCESSED;
@@ -93,7 +93,7 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 **********/
 
 	return process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL,
-			       vgdisplay_single);
+			       _vgdisplay_single);
 
 /******** FIXME Need to count number processed
 	  Add this to process_each_vg if arg_is_set(cmd,activevolumegroups_ARG) ?
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 53eeca5..ea50198 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -15,10 +15,10 @@
 
 #include "tools.h"
 
-static int vgimport_single(struct cmd_context *cmd,
-			   const char *vg_name,
-			   struct volume_group *vg,
-			   struct processing_handle *handle __attribute__((unused)))
+static int _vgimport_single(struct cmd_context *cmd,
+			    const char *vg_name,
+			    struct volume_group *vg,
+			    struct processing_handle *handle __attribute__((unused)))
 {
 	struct pv_list *pvl;
 	struct physical_volume *pv;
@@ -110,5 +110,5 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 	return process_each_vg(cmd, argc, argv, NULL, NULL,
 			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
 			       0, NULL,
-			       &vgimport_single);
+			       &_vgimport_single);
 }
diff --git a/tools/vgremove.c b/tools/vgremove.c
index d105fc6..8bf3841 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -15,9 +15,9 @@
 
 #include "tools.h"
 
-static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
-			   struct volume_group *vg,
-			   struct processing_handle *handle __attribute__((unused)))
+static int _vgremove_single(struct cmd_context *cmd, const char *vg_name,
+			    struct volume_group *vg,
+			    struct processing_handle *handle __attribute__((unused)))
 {
 	/*
 	 * Though vgremove operates per VG by definition, internally, it
@@ -111,7 +111,7 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 	cmd->handles_missing_pvs = 1;
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL,
 			      READ_FOR_UPDATE, 0,
-			      NULL, &vgremove_single);
+			      NULL, &_vgremove_single);
 
 	return ret;
 }
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 4deab73..1ec9083 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -15,9 +15,9 @@
 
 #include "tools.h"
 
-static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
-			 struct volume_group *vg,
-			 struct processing_handle *handle __attribute__((unused)))
+static int _vgscan_single(struct cmd_context *cmd, const char *vg_name,
+			  struct volume_group *vg,
+			  struct processing_handle *handle __attribute__((unused)))
 {
 	log_print_unless_silent("Found %svolume group \"%s\" using metadata type %s",
 				vg_is_exported(vg) ? "exported " : "", vg_name,
@@ -117,7 +117,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 	else
 		log_print_unless_silent("Reading volume groups from cache.");
 
-	maxret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL, &vgscan_single);
+	maxret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL, &_vgscan_single);
 
 	if (arg_is_set(cmd, mknodes_ARG)) {
 		ret = vgmknodes(cmd, argc, argv);
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 843738b..46c8911 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -529,7 +529,7 @@ static struct volume_group *_vgsplit_from(struct cmd_context *cmd,
 /*
  * Has the user given an option related to a new vg as the split destination?
  */
-static int new_vg_option_specified(struct cmd_context *cmd)
+static int _new_vg_option_specified(struct cmd_context *cmd)
 {
 	return(arg_is_set(cmd, clustered_ARG) ||
 	       arg_is_set(cmd, alloc_ARG) ||
@@ -616,7 +616,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (existing_vg) {
-		if (new_vg_option_specified(cmd)) {
+		if (_new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
 			goto bad;


