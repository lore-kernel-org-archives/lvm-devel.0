From: Milan Broz <mbroz@redhat.com>
Date: Mon, 29 Mar 2010 15:12:54 +0200
Subject: [PATCH 1/5] Use hash table for quick lv reference when reading metadata.
In-Reply-To: <cover.1269866168.git.mbroz@redhat.com>
References: <cover.1269866168.git.mbroz@redhat.com>
Message-ID: <73e3dd132150b15ae47df9e776e45d339dc8d9ba.1269866168.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The _read_vg uses already hash for PVs to optimise
reading of large VGs and avoiding repeated PV list traversing.

Use the same aproach to speed up parsing VG with many LVs.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format_text/import_vsn1.c |   42 ++++++++++++++++++++++++++++++----------
 1 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 7e7d60f..21928eb 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -28,6 +28,7 @@ typedef int (*section_fn) (struct format_instance * fid, struct dm_pool * mem,
 			   struct volume_group * vg, struct config_node * pvn,
 			   struct config_node * vgn,
 			   struct dm_hash_table * pv_hash,
+			   struct dm_hash_table * lv_hash,
 			   unsigned *scan_done_once,
 			   unsigned report_missing_devices);
 
@@ -155,7 +156,9 @@ static int _read_flag_config(struct config_node *n, uint64_t *status, int type)
 static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		    struct volume_group *vg, struct config_node *pvn,
 		    struct config_node *vgn __attribute((unused)),
-		    struct dm_hash_table *pv_hash, unsigned *scan_done_once,
+		    struct dm_hash_table *pv_hash,
+		    struct dm_hash_table *lv_hash __attribute((unused)),
+		    unsigned *scan_done_once,
 		    unsigned report_missing_devices)
 {
 	struct physical_volume *pv;
@@ -495,6 +498,7 @@ static int _read_lvnames(struct format_instance *fid __attribute((unused)),
 			 struct volume_group *vg, struct config_node *lvn,
 			 struct config_node *vgn __attribute((unused)),
 			 struct dm_hash_table *pv_hash __attribute((unused)),
+			 struct dm_hash_table *lv_hash,
 			 unsigned *scan_done_once __attribute((unused)),
 			 unsigned report_missing_devices __attribute((unused)))
 {
@@ -555,6 +559,9 @@ static int _read_lvnames(struct format_instance *fid __attribute((unused)),
 		return 0;
 	}
 
+	if (!dm_hash_insert(lv_hash, lv->name, lv))
+		return_0;
+
 	return link_lv_to_vg(vg, lv);
 }
 
@@ -563,19 +570,17 @@ static int _read_lvsegs(struct format_instance *fid __attribute((unused)),
 			struct volume_group *vg, struct config_node *lvn,
 			struct config_node *vgn __attribute((unused)),
 			struct dm_hash_table *pv_hash,
+			struct dm_hash_table *lv_hash,
 			unsigned *scan_done_once __attribute((unused)),
 			unsigned report_missing_devices __attribute((unused)))
 {
 	struct logical_volume *lv;
-	struct lv_list *lvl;
 
-	if (!(lvl = find_lv_in_vg(vg, lvn->key))) {
+	if (!(lv = dm_hash_lookup(lv_hash, lvn->key))) {
 		log_error("Lost logical volume reference %s", lvn->key);
 		return 0;
 	}
 
-	lv = lvl->lv;
-
 	if (!(lvn = lvn->child)) {
 		log_error("Empty logical volume section.");
 		return 0;
@@ -617,7 +622,9 @@ static int _read_sections(struct format_instance *fid,
 			  const char *section, section_fn fn,
 			  struct dm_pool *mem,
 			  struct volume_group *vg, struct config_node *vgn,
-			  struct dm_hash_table *pv_hash, int optional,
+			  struct dm_hash_table *pv_hash,
+			  struct dm_hash_table *lv_hash,
+			  int optional,
 			  unsigned *scan_done_once)
 {
 	struct config_node *n;
@@ -634,7 +641,7 @@ static int _read_sections(struct format_instance *fid,
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(fid, mem, vg, n, vgn, pv_hash, scan_done_once, report_missing_devices))
+		if (!fn(fid, mem, vg, n, vgn, pv_hash, lv_hash, scan_done_once, report_missing_devices))
 			return_0;
 	}
 
@@ -647,7 +654,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 {
 	struct config_node *vgn, *cn;
 	struct volume_group *vg;
-	struct dm_hash_table *pv_hash = NULL;
+	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
 	struct dm_pool *mem = dm_pool_create("lvm2 vg_read", VG_MEMPOOL_CHUNK);
 	unsigned scan_done_once = use_cached_pvs;
 
@@ -752,7 +759,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	dm_list_init(&vg->pvs);
 	if (!_read_sections(fid, "physical_volumes", _read_pv, mem, vg,
-			    vgn, pv_hash, 0, &scan_done_once)) {
+			    vgn, pv_hash, lv_hash, 0, &scan_done_once)) {
 		log_error("Couldn't find all physical volumes for volume "
 			  "group %s.", vg->name);
 		goto bad;
@@ -769,15 +776,24 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
+	/*
+	 * The lv hash memoises the lv section names -> lv
+	 * structures.
+	 */
+	if (!(lv_hash = dm_hash_create(32))) {
+		log_error("Couldn't create hash table.");
+		goto bad;
+	}
+
 	if (!_read_sections(fid, "logical_volumes", _read_lvnames, mem, vg,
-			    vgn, pv_hash, 1, NULL)) {
+			    vgn, pv_hash, lv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volume names for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
 	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, mem, vg,
-			    vgn, pv_hash, 1, NULL)) {
+			    vgn, pv_hash, lv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volumes for "
 			  "volume group %s.", vg->name);
 		goto bad;
@@ -790,6 +806,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	}
 
 	dm_hash_destroy(pv_hash);
+	dm_hash_destroy(lv_hash);
 
 	/*
 	 * Finished.
@@ -800,6 +817,9 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	if (pv_hash)
 		dm_hash_destroy(pv_hash);
 
+	if (lv_hash)
+		dm_hash_destroy(lv_hash);
+
 	dm_pool_destroy(mem);
 	return NULL;
 }
-- 
1.7.0.3


