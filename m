From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:12 -0400
Subject: master - display: basic vdo segment lvdisplay and lvs support
Message-ID: <201807091335.w69DZC5l030765@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5807993bbfedfc7a7c58de082c92811109c02ea0
Commit:        5807993bbfedfc7a7c58de082c92811109c02ea0
Parent:        4f708e870974fb9414ce7f1b7d277f14af6c2d38
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 1 15:58:01 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

display: basic vdo segment lvdisplay and lvs support

Print some basic info about vdo segment.

'lvdisplay -m' ATM shows the most.
lvs  shows usage percentage.
---
 lib/display/display.c |   22 ++++++++++++++++++++++
 lib/metadata/lv.c     |   24 +++++++++++++++++++-----
 lib/vdo/vdo.c         |   44 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 85 insertions(+), 5 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index c6f855b..055fc69 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -411,6 +411,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 	int thin_active = 0;
 	dm_percent_t thin_percent;
 	struct lv_status_cache *cache_status = NULL;
+	struct lv_status_vdo *vdo_status = NULL;
 
 	if (lv_is_historical(lv))
 		return _lvdisplay_historical_full(cmd, lv);
@@ -529,6 +530,27 @@ int lvdisplay_full(struct cmd_context *cmd,
 		seg = first_seg(lv);
 		log_print("LV Pool metadata       %s", seg->metadata_lv->name);
 		log_print("LV Pool data           %s", seg_lv(seg, 0)->name);
+	} else if (lv_is_vdo_pool(lv)) {
+		seg = first_seg(lv);
+		log_print("LV VDO Pool data       %s", seg_lv(seg, 0)->name);
+		if (inkernel && lv_vdo_pool_status(lv, 0, &vdo_status)) { /* FIXME: flush option? */
+			log_print("LV VDO Pool usage      %s%%",
+				  display_percent(cmd, vdo_status->usage));
+			log_print("LV VDO Pool saving     %s%%",
+				  display_percent(cmd, vdo_status->saving));
+			log_print("LV VDO Operating mode  %s",
+				  get_vdo_operating_mode_name(vdo_status->vdo->operating_mode));
+			log_print("LV VDO Index state     %s",
+				  get_vdo_index_state_name(vdo_status->vdo->index_state));
+			log_print("LV VDO Compression st  %s",
+				  get_vdo_compression_state_name(vdo_status->vdo->compression_state));
+			log_print("LV VDO Used size       %s",
+				  display_size(cmd, vdo_status->vdo->used_blocks * DM_VDO_BLOCK_SIZE));
+			dm_pool_destroy(vdo_status->mem);
+		}
+	} else if (lv_is_vdo(lv)) {
+		seg = first_seg(lv);
+		log_print("LV VDO Pool name       %s", seg_lv(seg, 0)->name);
 	}
 
 	if (inkernel && info.suspended)
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index cf6fafa..d8417bc 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -450,6 +450,9 @@ dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_an
 			}
 		}
 		break;
+	case SEG_STATUS_VDO_POOL:
+		p = s->vdo_pool.usage;
+		break;
 	default:
 		p = DM_PERCENT_INVALID;
 	}
@@ -695,11 +698,13 @@ char *lv_mirror_log_uuid_dup(struct dm_pool *mem, const struct logical_volume *l
 
 struct logical_volume *lv_pool_lv(const struct logical_volume *lv)
 {
-	struct lv_segment *seg = (lv_is_thin_volume(lv) || lv_is_cache(lv)) ?
-				  first_seg(lv) : NULL;
-	struct logical_volume *pool_lv = seg ? seg->pool_lv : NULL;
+	if (lv_is_thin_volume(lv) || lv_is_cache(lv))
+		return first_seg(lv)->pool_lv;
+
+	if (lv_is_vdo(lv))
+		return seg_lv(first_seg(lv), 0);
 
-	return pool_lv;
+	return NULL;
 }
 
 static char *_do_lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv,
@@ -728,7 +733,9 @@ char *lv_pool_lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 struct logical_volume *lv_data_lv(const struct logical_volume *lv)
 {
-	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
+	struct lv_segment *seg = (lv_is_cache_pool(lv) ||
+				  lv_is_thin_pool(lv) ||
+				  lv_is_vdo_pool(lv)) ?
 				  first_seg(lv) : NULL;
 	struct logical_volume *data_lv = seg ? seg_lv(seg, 0) : NULL;
 
@@ -1181,6 +1188,13 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 	else if (lv_is_thin_volume(lv))
 		repstr[0] = lv_is_merging_origin(lv) ?
 			'O' : (lv_is_merging_thin_snapshot(lv) ? 'S' : 'V');
+	//else if (lv_is_vdo(lv))
+	//	repstr[0] = 'V'; // TODO: Show 'V' like Virtual Thin ?
+	// ATM shows 'v' as virtual target just like: error, zero
+	else if (lv_is_vdo_pool(lv))
+		repstr[0] = 'd';
+	else if (lv_is_vdo_pool_data(lv))
+		repstr[0] = 'D';
 	else if (lv_is_virtual(lv))
 		repstr[0] = 'v';
 	else if (lv_is_thin_pool(lv))
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index a32ffcd..80ddcfd 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -66,6 +66,11 @@ static const char *_vdo_name(const struct lv_segment *seg)
 	return SEG_TYPE_NAME_VDO;
 }
 
+static void _vdo_display(const struct lv_segment *seg)
+{
+	display_stripe(seg, 0, "    ");
+}
+
 static int _vdo_text_import(struct lv_segment *seg,
 			    const struct dm_config_node *n,
 			    struct dm_hash_table *pv_hash __attribute__((unused)))
@@ -150,6 +155,43 @@ static const char *_vdo_pool_name(const struct lv_segment *seg)
 	return SEG_TYPE_NAME_VDO_POOL;
 }
 
+static void _vdo_pool_display(const struct lv_segment *seg)
+{
+	struct cmd_context *cmd = seg->lv->vg->cmd;
+	const struct dm_vdo_target_params *vtp = &seg->vdo_params;
+
+	log_print("  Virtual size\t%s", display_size(cmd, get_vdo_pool_virtual_size(seg)));
+	log_print("  Header size\t\t%s", display_size(cmd, seg->vdo_pool_header_size));
+
+	_print_yes_no("Compression\t", vtp->use_compression);
+	_print_yes_no("Deduplication", vtp->use_deduplication);
+	_print_yes_no("Emulate 512 sectors", vtp->emulate_512_sectors);
+
+	log_print("  Block map cache sz\t%s",
+		  display_size(cmd, vtp->block_map_cache_size_mb * UINT64_C(2 * 1024)));
+	log_print("  Block map period\t%u", vtp->block_map_period);
+
+	_print_yes_no("Sparse index", vtp->use_sparse_index);
+
+	log_print("  Index memory size\t%s",
+		  display_size(cmd, vtp->index_memory_size_mb * UINT64_C(2 * 1024)));
+
+	_print_yes_no("Using read cache", vtp->use_read_cache);
+
+	log_print("  Read cache size\t%s",
+		  display_size(cmd, vtp->read_cache_size_mb * UINT64_C(2 * 1024)));
+	log_print("  Slab size\t\t%s",
+		  display_size(cmd, vtp->slab_size_mb * UINT64_C(2 * 1024)));
+
+	log_print("  # Ack threads\t%u", (unsigned) vtp->ack_threads);
+	log_print("  # Bio threads\t%u", (unsigned) vtp->bio_threads);
+	log_print("  Bio rotation\t%u", (unsigned) vtp->bio_rotation);
+	log_print("  # CPU threads\t%u", (unsigned) vtp->cpu_threads);
+	log_print("  # Hash zone threads\t%u", (unsigned) vtp->hash_zone_threads);
+	log_print("  # Logical threads\t%u", (unsigned) vtp->logical_threads);
+	log_print("  # Physical threads\t%u", (unsigned) vtp->physical_threads);
+}
+
 /* reused as _vdo_text_import_area_count */
 static int _vdo_pool_text_import_area_count(const struct dm_config_node *sn __attribute__((unused)),
 					    uint32_t *area_count)
@@ -419,6 +461,7 @@ static void _vdo_pool_destroy(struct segment_type *segtype)
 
 static struct segtype_handler _vdo_ops = {
 	.name = _vdo_name,
+	.display = _vdo_display,
 	.text_import = _vdo_text_import,
 	.text_import_area_count = _vdo_pool_text_import_area_count,
 	.text_export = _vdo_text_export,
@@ -434,6 +477,7 @@ static struct segtype_handler _vdo_ops = {
 
 static struct segtype_handler _vdo_pool_ops = {
 	.name = _vdo_pool_name,
+	.display = _vdo_pool_display,
 	.text_import = _vdo_pool_text_import,
 	.text_import_area_count = _vdo_pool_text_import_area_count,
 	.text_export = _vdo_pool_text_export,


