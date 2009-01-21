From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:49 +0100
Subject: [PATCH 08/15] Add crypto_store to LV segment allocation functions.
In-Reply-To: <0cf2e4e850e1c919e0e6bc98504be6d5087caa1c.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
	<589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
	<b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
	<3417d8a2769cc152bd8aef5921716b693360ee15.1232488181.git.mbroz@redhat.com>
	<6d887c3c90806a55ac1cf569425845ce0ed16daa.1232488181.git.mbroz@redhat.com>
	<0cf2e4e850e1c919e0e6bc98504be6d5087caa1c.1232488181.git.mbroz@redhat.com>
Message-ID: <b8d375b5ca799bd88ff701ba19b93bed02f62343.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Also by default inherit crypto store from first segment
when allocating new crypt segment.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format1/import-extents.c    |    4 ++--
 lib/format_pool/import_export.c |    4 ++--
 lib/format_text/import_vsn1.c   |    2 +-
 lib/metadata/lv_alloc.h         |    3 ++-
 lib/metadata/lv_manip.c         |   24 ++++++++++++++++--------
 lib/metadata/merge.c            |    2 +-
 6 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
index ded0a8e..937c5bf 100644
--- a/lib/format1/import-extents.c
+++ b/lib/format1/import-extents.c
@@ -219,7 +219,7 @@ static int _read_linear(struct cmd_context *cmd, struct lv_map *lvm)
 		len = _area_length(lvm, le);
 
 		if (!(seg = alloc_lv_segment(cmd->mem, segtype, lvm->lv, le,
-					     len, 0, 0, NULL, 1, len, 0, 0, 0))) {
+					     len, 0, 0, NULL, 1, len, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate linear segment.");
 			return 0;
 		}
@@ -293,7 +293,7 @@ static int _read_stripes(struct cmd_context *cmd, struct lv_map *lvm)
 					     lvm->stripes * area_len,
 					     0, lvm->stripe_size, NULL,
 					     lvm->stripes,
-					     area_len, 0, 0, 0))) {
+					     area_len, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate striped segment.");
 			return 0;
 		}
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 4d2163d..a5198de 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -220,7 +220,7 @@ static int _add_stripe_seg(struct dm_pool *mem,
 	if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur,
 				     area_len * usp->num_devs, 0,
 				     usp->striping, NULL, usp->num_devs,
-				     area_len, 0, 0, 0))) {
+				     area_len, 0, 0, 0, NULL))) {
 		log_error("Unable to allocate striped lv_segment structure");
 		return 0;
 	}
@@ -257,7 +257,7 @@ static int _add_linear_seg(struct dm_pool *mem,
 		if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur,
 					     area_len, 0, usp->striping,
 					     NULL, 1, area_len,
-					     POOL_PE_SIZE, 0, 0))) {
+					     POOL_PE_SIZE, 0, 0, NULL))) {
 			log_error("Unable to allocate linear lv_segment "
 				  "structure");
 			return 0;
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index b610501..1de6fbc 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -336,7 +336,7 @@ static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
 
 	if (!(seg = alloc_lv_segment(mem, segtype, lv, start_extent,
 				     extent_count, 0, 0, NULL, area_count,
-				     extent_count, 0, 0, 0))) {
+				     extent_count, 0, 0, 0, NULL))) {
 		log_error("Segment allocation failed");
 		return 0;
 	}
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index f94f503..e21fb08 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -26,7 +26,8 @@ struct lv_segment *alloc_lv_segment(struct dm_pool *mem,
 				    uint32_t area_len,
 				    uint32_t chunk_size,
 				    uint32_t region_size,
-				    uint32_t extents_copied);
+				    uint32_t extents_copied,
+				    struct crypto_store *crypto_store);
 
 struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 				      uint32_t status, uint32_t old_le_count);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2661e0c..2c3fdf5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -173,7 +173,8 @@ struct lv_segment *alloc_lv_segment(struct dm_pool *mem,
 				    uint32_t area_len,
 				    uint32_t chunk_size,
 				    uint32_t region_size,
-				    uint32_t extents_copied)
+				    uint32_t extents_copied,
+				    struct crypto_store *crypto_store)
 {
 	struct lv_segment *seg;
 	uint32_t areas_sz = area_count * sizeof(*seg->areas);
@@ -203,6 +204,7 @@ struct lv_segment *alloc_lv_segment(struct dm_pool *mem,
 	seg->region_size = region_size;
 	seg->extents_copied = extents_copied;
 	seg->log_lv = log_lv;
+	seg->crypto_store = crypto_store;
 	dm_list_init(&seg->tags);
 
 	if (log_lv && !attach_mirror_log(seg, log_lv))
@@ -226,7 +228,7 @@ struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv, old_le_count,
 				     lv->le_count - old_le_count, status, 0,
 				     NULL, 0, lv->le_count - old_le_count,
-				     0, 0, 0))) {
+				     0, 0, 0, NULL))) {
 		log_error("Couldn't allocate new snapshot segment.");
 		return NULL;
 	}
@@ -655,16 +657,21 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint32_t status,
 {
 	uint32_t s, extents, area_multiple;
 	struct lv_segment *seg;
+	struct crypto_store *cs = NULL;
 
 	area_multiple = calc_area_multiple(segtype, area_count);
 
+	/* Inherit crypto_store from first segment */
+	if (segtype_is_encrypted(segtype) && first_seg(lv))
+		cs = first_seg(lv)->crypto_store;
+
 	/* log_lv gets set up elsehere */
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
 				     lv->le_count,
 				     aa[0].len * area_multiple,
 				     status, stripe_size, NULL,
 				     area_count,
-				     aa[0].len, 0u, region_size, 0u))) {
+				     aa[0].len, 0u, region_size, 0u, cs))) {
 		log_error("Couldn't allocate new LV segment.");
 		return 0;
 	}
@@ -673,6 +680,7 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint32_t status,
 		if (!set_lv_segment_area_pv(seg, s, aa[s].pv, aa[s].pe))
 			return_0;
 
+
 	dm_list_add(&lv->segments, &seg->list);
 
 	extents = aa[0].len * area_multiple;
@@ -1260,7 +1268,7 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint32_t status,
 
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
 				     lv->le_count, extents, status, 0,
-				     NULL, 0, extents, 0, 0, 0))) {
+				     NULL, 0, extents, 0, 0, 0, NULL))) {
 		log_error("Couldn't allocate new zero segment.");
 		return 0;
 	}
@@ -1393,7 +1401,7 @@ static struct lv_segment *_convert_seg_to_mirror(struct lv_segment *seg,
 					log_lv,
 					seg->area_count, seg->area_len,
 					seg->chunk_size, region_size,
-					seg->extents_copied))) {
+					seg->extents_copied, NULL))) {
 		log_error("Couldn't allocate converted LV segment");
 		return NULL;
 	}
@@ -1534,7 +1542,7 @@ int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv)
 				     get_segtype_from_string(log_lv->vg->cmd,
 							     "striped"),
 				     log_lv, 0, ah->log_area.len, MIRROR_LOG,
-				     0, NULL, 1, ah->log_area.len, 0, 0, 0))) {
+				     0, NULL, 1, ah->log_area.len, 0, 0, 0, NULL))) {
 		log_error("Couldn't allocate new mirror log segment.");
 		return 0;
 	}
@@ -2447,7 +2455,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	if (!(mapseg = alloc_lv_segment(cmd->mem, segtype,
 					lv_where, 0, layer_lv->le_count,
 					status, 0, NULL, 1, layer_lv->le_count,
-					0, 0, 0)))
+					0, 0, 0, NULL)))
 		return_NULL;
 
 	/* map the new segment to the original underlying are */
@@ -2490,7 +2498,7 @@ static int _extend_layer_lv_for_segment(struct logical_volume *layer_lv,
 	if (!(mapseg = alloc_lv_segment(layer_lv->vg->cmd->mem, segtype,
 					layer_lv, layer_lv->le_count,
 					seg->area_len, status, 0,
-					NULL, 1, seg->area_len, 0, 0, 0)))
+					NULL, 1, seg->area_len, 0, 0, 0, NULL)))
 		return_0;
 
 	/* map the new segment to the original underlying are */
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 66e9ce0..f1d8b9a 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -274,7 +274,7 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 					   seg->log_lv,
 					   seg->area_count, seg->area_len,
 					   seg->chunk_size, seg->region_size,
-					   seg->extents_copied))) {
+					   seg->extents_copied, seg->crypto_store))) {
 		log_error("Couldn't allocate cloned LV segment.");
 		return 0;
 	}
-- 
1.5.6.5


