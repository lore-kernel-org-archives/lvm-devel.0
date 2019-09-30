From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Sep 2019 12:39:50 -0400
Subject: master - scan: add PV summary info to lvmcache
Message-ID: <201909301639.x8UGdoWX024762@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f3084ee2e577abe05e4707730f3cb96f2cb5ec45
Commit:        f3084ee2e577abe05e4707730f3cb96f2cb5ec45
Parent:        0c23d3fc8402e49e61c9c490d9c2c9c2d58596e8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 26 11:27:38 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 30 11:38:10 2019 -0500

scan: add PV summary info to lvmcache

Expand the lvmcache info that is saved by the scan to
include PV info from the metadata.
---
 lib/cache/lvmcache.c          |   16 +++++++
 lib/cache/lvmcache.h          |   12 ++---
 lib/format_text/format-text.c |    2 +
 lib/format_text/import_vsn1.c |   96 +++++++++++++++++++++++++++++++++-------
 lib/format_text/text_label.c  |    2 +
 5 files changed, 103 insertions(+), 25 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 29d6446..7ee94c2 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -53,6 +53,7 @@ struct lvmcache_vginfo {
 	struct dm_list list;	/* Join these vginfos together */
 	struct dm_list infos;	/* List head for lvmcache_infos */
 	struct dm_list outdated_infos; /* vg_read moves info from infos to outdated_infos */
+	struct dm_list pvsummaries; /* pv_list taken directly from vgsummary */
 	const struct format_type *fmt;
 	char *vgname;		/* "" == orphan */
 	uint32_t status;
@@ -1295,6 +1296,7 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 		}
 		dm_list_init(&vginfo->infos);
 		dm_list_init(&vginfo->outdated_infos);
+		dm_list_init(&vginfo->pvsummaries);
 
 		/*
 		 * A different VG (different uuid) can exist with the same name.
@@ -1418,6 +1420,18 @@ int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 	return _lvmcache_update_vgname(NULL, vgname, vgname, 0, "", fmt);
 }
 
+static void _lvmcache_update_pvsummaries(struct lvmcache_vginfo *vginfo, struct lvmcache_vgsummary *vgsummary)
+{
+	struct pv_list *pvl, *safe;
+
+	dm_list_init(&vginfo->pvsummaries);
+
+	dm_list_iterate_items_safe(pvl, safe, &vgsummary->pvsummaries) {
+		dm_list_del(&pvl->list);
+		dm_list_add(&vginfo->pvsummaries, &pvl->list);
+	}
+}
+
 /*
  * Returning 0 causes the caller to remove the info struct for this
  * device from lvmcache, which will make it look like a missing device.
@@ -1582,6 +1596,8 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 		log_error("Failed to update VG %s info in lvmcache.", vgname);
 	}
 
+	_lvmcache_update_pvsummaries(vginfo, vgsummary);
+
 	return 1;
 }
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 89fbe6f..1401974 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -41,14 +41,9 @@ struct lvmcache_vginfo;
 
 /*
  * vgsummary represents a summary of the VG that is read
- * without a lock.  The info does not come through vg_read(),
- * but through reading mdas.  It provides information about
- * the VG that is needed to lock the VG and then read it fully
- * with vg_read(), after which the VG summary should be checked
- * against the full VG metadata to verify it was correct (since
- * it was read without a lock.)
- *
- * Once read, vgsummary information is saved in lvmcache_vginfo.
+ * without a lock during label scan.  It's used to populate
+ * basic lvmcache vginfo/info during label scan prior to
+ * vg_read().
  */
 struct lvmcache_vgsummary {
 	const char *vgname;
@@ -63,6 +58,7 @@ struct lvmcache_vgsummary {
 	int mda_num; /* 1 = summary from mda1, 2 = summary from mda2 */
 	unsigned mda_ignored:1;
 	unsigned zero_offset:1;
+	struct dm_list pvsummaries;
 };
 
 int lvmcache_init(struct cmd_context *cmd);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 2a5c8ec..be4730b 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -278,6 +278,8 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	};
 	int rlocn_was_ignored;
 
+	dm_list_init(&vgsummary_orphan.pvsummaries);
+
 	memcpy(&vgsummary_orphan.vgid, FMT_TEXT_ORPHAN_VG_NAME, sizeof(FMT_TEXT_ORPHAN_VG_NAME));
 
 	rlocn = mdah->raw_locns;	/* Slot 0 */
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 2785ab3..d7ff786 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -31,10 +31,12 @@ typedef int (*section_fn) (struct cmd_context *cmd,
 			   struct format_type *fmt,
 			   struct format_instance *fid,
 			   struct dm_pool *mem,
-			   struct volume_group * vg, const struct dm_config_node * pvn,
-			   const struct dm_config_node * vgn,
-			   struct dm_hash_table * pv_hash,
-			   struct dm_hash_table * lv_hash);
+			   struct volume_group *vg,
+			   struct lvmcache_vgsummary *vgsummary,
+			   const struct dm_config_node *pvn,
+			   const struct dm_config_node *vgn,
+			   struct dm_hash_table *pv_hash,
+			   struct dm_hash_table *lv_hash);
 
 #define _read_int32(root, path, result) \
 	dm_config_get_uint32(root, path, (uint32_t *) (result))
@@ -176,7 +178,9 @@ static int _read_pv(struct cmd_context *cmd,
 		    struct format_type *fmt,
 		    struct format_instance *fid,
 		    struct dm_pool *mem,
-		    struct volume_group *vg, const struct dm_config_node *pvn,
+		    struct volume_group *vg,
+		    struct lvmcache_vgsummary *vgsummary,
+		    const struct dm_config_node *pvn,
 		    const struct dm_config_node *vgn __attribute__((unused)),
 		    struct dm_hash_table *pv_hash,
 		    struct dm_hash_table *lv_hash __attribute__((unused)))
@@ -289,6 +293,49 @@ static int _read_pv(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _read_pvsummary(struct cmd_context *cmd,
+			   struct format_type *fmt,
+			   struct format_instance *fid,
+			   struct dm_pool *mem,
+			   struct volume_group *vg,
+			   struct lvmcache_vgsummary *vgsummary,
+			   const struct dm_config_node *pvn,
+			   const struct dm_config_node *vgn __attribute__((unused)),
+			   struct dm_hash_table *pv_hash __attribute__((unused)),
+			   struct dm_hash_table *lv_hash __attribute__((unused)))
+{
+	struct physical_volume *pv;
+	struct pv_list *pvl;
+	const char *device_hint;
+
+	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
+	    !(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv))))
+		return_0;
+
+	pv = pvl->pv;
+
+	if (!(pvn = pvn->child)) {
+		log_error("Empty pv section.");
+		return 0;
+	}
+
+	if (!_read_id(&pv->id, pvn, "id"))
+		log_warn("Couldn't read uuid for physical volume.");
+
+	if (dm_config_has_node(pvn, "dev_size") &&
+	    !_read_uint64(pvn, "dev_size", &pv->size))
+		log_warn("Couldn't read dev size for physical volume.");
+
+	if (dm_config_get_str(pvn, "device", &device_hint)) {
+		if (!(pv->device_hint = dm_pool_strdup(mem, device_hint)))
+			log_error("Failed to allocate memory for device hint in read_pv.");
+	}
+
+	dm_list_add(&vgsummary->pvsummaries, &pvl->list);
+
+	return 1;
+}
+
 static void _insert_segment(struct logical_volume *lv, struct lv_segment *seg)
 {
 	struct lv_segment *comp;
@@ -538,7 +585,9 @@ static int _read_lvnames(struct cmd_context *cmd,
 			 struct format_type *fmt,
 			 struct format_instance *fid __attribute__((unused)),
 			 struct dm_pool *mem,
-			 struct volume_group *vg, const struct dm_config_node *lvn,
+			 struct volume_group *vg,
+			 struct lvmcache_vgsummary *vgsummary,
+			 const struct dm_config_node *lvn,
 			 const struct dm_config_node *vgn __attribute__((unused)),
 			 struct dm_hash_table *pv_hash __attribute__((unused)),
 			 struct dm_hash_table *lv_hash)
@@ -695,7 +744,9 @@ static int _read_historical_lvnames(struct cmd_context *cmd,
 				    struct format_type *fmt,
 				    struct format_instance *fid __attribute__((unused)),
 				     struct dm_pool *mem,
-				     struct volume_group *vg, const struct dm_config_node *hlvn,
+				     struct volume_group *vg,
+				     struct lvmcache_vgsummary *vgsummary,
+				     const struct dm_config_node *hlvn,
 				     const struct dm_config_node *vgn __attribute__((unused)),
 				     struct dm_hash_table *pv_hash __attribute__((unused)),
 				     struct dm_hash_table *lv_hash __attribute__((unused)))
@@ -766,7 +817,9 @@ static int _read_historical_lvnames_interconnections(struct cmd_context *cmd,
 						 struct format_type *fmt,
 						 struct format_instance *fid __attribute__((unused)),
 						 struct dm_pool *mem,
-						 struct volume_group *vg, const struct dm_config_node *hlvn,
+						 struct volume_group *vg,
+			  			 struct lvmcache_vgsummary *vgsummary,
+						 const struct dm_config_node *hlvn,
 						 const struct dm_config_node *vgn __attribute__((unused)),
 						 struct dm_hash_table *pv_hash __attribute__((unused)),
 						 struct dm_hash_table *lv_hash __attribute__((unused)))
@@ -878,7 +931,9 @@ static int _read_lvsegs(struct cmd_context *cmd,
 			struct format_type *fmt,
 			struct format_instance *fid,
 			struct dm_pool *mem,
-			struct volume_group *vg, const struct dm_config_node *lvn,
+			struct volume_group *vg,
+			struct lvmcache_vgsummary *vgsummary,
+			const struct dm_config_node *lvn,
 			const struct dm_config_node *vgn __attribute__((unused)),
 			struct dm_hash_table *pv_hash,
 			struct dm_hash_table *lv_hash)
@@ -942,7 +997,9 @@ static int _read_sections(struct cmd_context *cmd,
 			  struct format_instance *fid,
 			  struct dm_pool *mem,
 			  const char *section, section_fn fn,
-			  struct volume_group *vg, const struct dm_config_node *vgn,
+			  struct volume_group *vg,
+			  struct lvmcache_vgsummary *vgsummary,
+			  const struct dm_config_node *vgn,
 			  struct dm_hash_table *pv_hash,
 			  struct dm_hash_table *lv_hash,
 			  int optional)
@@ -959,7 +1016,7 @@ static int _read_sections(struct cmd_context *cmd,
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(cmd, fmt, fid, mem, vg, n, vgn, pv_hash, lv_hash))
+		if (!fn(cmd, fmt, fid, mem, vg, vgsummary, n, vgn, pv_hash, lv_hash))
 			return_0;
 	}
 
@@ -971,7 +1028,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 				     unsigned allow_lvmetad_extensions)
 {
 	struct cmd_context *cmd = fid->fmt->cmd;
-	struct format_type *fmt = fid->fmt;
+	struct format_type *fmt = (struct format_type *)fid->fmt;
 	struct dm_pool *mem;
 	const struct dm_config_node *vgn;
 	const struct dm_config_value *cv;
@@ -1126,7 +1183,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		vg->mda_copies = DEFAULT_VGMETADATACOPIES;
 	}
 
-	if (!_read_sections(cmd, fmt, fid, mem, "physical_volumes", _read_pv, vg,
+	if (!_read_sections(cmd, fmt, fid, mem, "physical_volumes", _read_pv, vg, NULL,
 			    vgn, pv_hash, lv_hash, 0)) {
 		log_error("Couldn't find all physical volumes for volume "
 			  "group %s.", vg->name);
@@ -1140,21 +1197,21 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	if (!_read_sections(cmd, fmt, fid, mem, "logical_volumes", _read_lvnames, vg,
+	if (!_read_sections(cmd, fmt, fid, mem, "logical_volumes", _read_lvnames, vg, NULL,
 			    vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all logical volume names for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
-	if (!_read_sections(cmd, fmt, fid, mem, "historical_logical_volumes", _read_historical_lvnames, vg,
+	if (!_read_sections(cmd, fmt, fid, mem, "historical_logical_volumes", _read_historical_lvnames, vg, NULL,
 			    vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all historical logical volumes for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
-	if (!_read_sections(cmd, fmt, fid, mem, "logical_volumes", _read_lvsegs, vg,
+	if (!_read_sections(cmd, fmt, fid, mem, "logical_volumes", _read_lvsegs, vg, NULL,
 			    vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all logical volumes for "
 			  "volume group %s.", vg->name);
@@ -1162,7 +1219,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	}
 
 	if (!_read_sections(cmd, fmt, fid, mem, "historical_logical_volumes", _read_historical_lvnames_interconnections,
-			    vg, vgn, pv_hash, lv_hash, 1)) {
+			    vg, NULL, vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all removed logical volume interconnections "
 			  "for volume group %s.", vg->name);
 		goto bad;
@@ -1270,6 +1327,11 @@ static int _read_vgsummary(const struct format_type *fmt, const struct dm_config
 		return 0;
 	}
 
+	if (!_read_sections(fmt->cmd, NULL, NULL, mem, "physical_volumes", _read_pvsummary, NULL, vgsummary,
+			    vgn, NULL, NULL, 0)) {
+		log_debug("Couldn't read pv summaries");
+	}
+
 	return 1;
 }
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 934bc73..41276be 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -498,6 +498,7 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 	if (mda1) {
 		log_debug_metadata("Scanning %s mda1 summary.", dev_name(dev));
 		memset(&vgsummary, 0, sizeof(vgsummary));
+		dm_list_init(&vgsummary.pvsummaries);
 		bad_fields = 0;
 		vgsummary.mda_num = 1;
 
@@ -541,6 +542,7 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 	if (mda2) {
 		log_debug_metadata("Scanning %s mda2 summary.", dev_name(dev));
 		memset(&vgsummary, 0, sizeof(vgsummary));
+		dm_list_init(&vgsummary.pvsummaries);
 		bad_fields = 0;
 		vgsummary.mda_num = 2;
 


