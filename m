From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Sep 2019 12:39:38 -0400
Subject: master - metadata: add args to metadata import functions
Message-ID: <201909301639.x8UGdckd024725@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fcfabb26a535f9b967e96ad44300377598622c0d
Commit:        fcfabb26a535f9b967e96ad44300377598622c0d
Parent:        8f02f8dcd72571ce3bc6538f1cd23807e2b6a64d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 26 11:50:51 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 30 11:38:10 2019 -0500

metadata: add args to metadata import functions

instead of getting them through fid arg
no functional change
---
 lib/format_text/import_vsn1.c |  101 ++++++++++++++++++++++++++---------------
 1 files changed, 65 insertions(+), 36 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 43ec10b..f29abce 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -27,7 +27,10 @@
 #include "lib/config/defaults.h"
 #include "lib/datastruct/str_list.h"
 
-typedef int (*section_fn) (struct format_instance * fid,
+typedef int (*section_fn) (struct cmd_context *cmd,
+			   struct format_type *fmt,
+			   struct format_instance *fid,
+			   struct dm_pool *mem,
 			   struct volume_group * vg, const struct dm_config_node * pvn,
 			   const struct dm_config_node * vgn,
 			   struct dm_hash_table * pv_hash,
@@ -169,13 +172,15 @@ static int _read_str_list(struct dm_pool *mem, struct dm_list *list, const struc
 	return 1;
 }
 
-static int _read_pv(struct format_instance *fid,
+static int _read_pv(struct cmd_context *cmd,
+		    struct format_type *fmt,
+		    struct format_instance *fid,
+		    struct dm_pool *mem,
 		    struct volume_group *vg, const struct dm_config_node *pvn,
 		    const struct dm_config_node *vgn __attribute__((unused)),
 		    struct dm_hash_table *pv_hash,
 		    struct dm_hash_table *lv_hash __attribute__((unused)))
 {
-	struct dm_pool *mem = vg->vgmem;
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	const struct dm_config_value *cv;
@@ -266,7 +271,7 @@ static int _read_pv(struct format_instance *fid,
 
 	pv->pe_alloc_count = 0;
 	pv->pe_align = 0;
-	pv->fmt = fid->fmt;
+	pv->fmt = fmt;
 
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
@@ -293,10 +298,13 @@ static void _insert_segment(struct logical_volume *lv, struct lv_segment *seg)
 	dm_list_add(&lv->segments, &seg->list);
 }
 
-static int _read_segment(struct logical_volume *lv, const struct dm_config_node *sn,
+static int _read_segment(struct cmd_context *cmd,
+			 struct format_type *fmt,
+			 struct format_instance *fid,
+			 struct dm_pool *mem,
+			 struct logical_volume *lv, const struct dm_config_node *sn,
 			 struct dm_hash_table *pv_hash)
 {
-	struct dm_pool *mem = lv->vg->vgmem;
 	uint32_t area_count = 0u;
 	struct lv_segment *seg;
 	const struct dm_config_node *sn_child = sn->child;
@@ -348,7 +356,7 @@ static int _read_segment(struct logical_volume *lv, const struct dm_config_node
 	       return 0;
 	}
 
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, segtype_with_flags)))
+	if (!(segtype = get_segtype_from_string(cmd, segtype_with_flags)))
 		return_0;
 
 	/* Can drop temporary string here as nothing has allocated from VGMEM meanwhile */
@@ -465,7 +473,11 @@ int text_import_areas(struct lv_segment *seg, const struct dm_config_node *sn,
 	return 1;
 }
 
-static int _read_segments(struct logical_volume *lv, const struct dm_config_node *lvn,
+static int _read_segments(struct cmd_context *cmd,
+			  struct format_type *fmt,
+			  struct format_instance *fid,
+			  struct dm_pool *mem,
+			  struct logical_volume *lv, const struct dm_config_node *lvn,
 			  struct dm_hash_table *pv_hash)
 {
 	const struct dm_config_node *sn;
@@ -477,7 +489,7 @@ static int _read_segments(struct logical_volume *lv, const struct dm_config_node
 		 * All sub-sections are assumed to be segments.
 		 */
 		if (!sn->v) {
-			if (!_read_segment(lv, sn, pv_hash))
+			if (!_read_segment(cmd, fmt, fid, mem, lv, sn, pv_hash))
 				return_0;
 
 			count++;
@@ -516,13 +528,15 @@ static int _read_segments(struct logical_volume *lv, const struct dm_config_node
 	return 1;
 }
 
-static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
+static int _read_lvnames(struct cmd_context *cmd,
+			 struct format_type *fmt,
+			 struct format_instance *fid __attribute__((unused)),
+			 struct dm_pool *mem,
 			 struct volume_group *vg, const struct dm_config_node *lvn,
 			 const struct dm_config_node *vgn __attribute__((unused)),
 			 struct dm_hash_table *pv_hash __attribute__((unused)),
 			 struct dm_hash_table *lv_hash)
 {
-	struct dm_pool *mem = vg->vgmem;
 	struct logical_volume *lv;
 	const char *str;
 	const struct dm_config_value *cv;
@@ -612,7 +626,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	if (dm_config_get_str(lvn, "profile", &str)) {
 		log_debug_metadata("Adding profile configuration %s for LV %s.",
 				   str, display_lvname(lv));
-		if (!(lv->profile = add_profile(vg->cmd, str, CONFIG_PROFILE_METADATA))) {
+		if (!(lv->profile = add_profile(cmd, str, CONFIG_PROFILE_METADATA))) {
 			log_error("Failed to add configuration profile %s for LV %s.",
 				  str, display_lvname(lv));
 			return 0;
@@ -621,7 +635,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 
 	if (!_read_int32(lvn, "read_ahead", &lv->read_ahead))
 		/* If not present, choice of auto or none is configurable */
-		lv->read_ahead = vg->cmd->default_settings.read_ahead;
+		lv->read_ahead = cmd->default_settings.read_ahead;
 	else {
 		switch (lv->read_ahead) {
 		case 0:
@@ -671,13 +685,15 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	return 1;
 }
 
-static int _read_historical_lvnames(struct format_instance *fid __attribute__((unused)),
+static int _read_historical_lvnames(struct cmd_context *cmd,
+				    struct format_type *fmt,
+				    struct format_instance *fid __attribute__((unused)),
+				     struct dm_pool *mem,
 				     struct volume_group *vg, const struct dm_config_node *hlvn,
 				     const struct dm_config_node *vgn __attribute__((unused)),
 				     struct dm_hash_table *pv_hash __attribute__((unused)),
 				     struct dm_hash_table *lv_hash __attribute__((unused)))
 {
-	struct dm_pool *mem = vg->vgmem;
 	struct generic_logical_volume *glv;
 	struct glv_list *glvl;
 	const char *str;
@@ -740,13 +756,15 @@ bad:
 	return 0;
 }
 
-static int _read_historical_lvnames_interconnections(struct format_instance *fid __attribute__((unused)),
+static int _read_historical_lvnames_interconnections(struct cmd_context *cmd,
+						 struct format_type *fmt,
+						 struct format_instance *fid __attribute__((unused)),
+						 struct dm_pool *mem,
 						 struct volume_group *vg, const struct dm_config_node *hlvn,
 						 const struct dm_config_node *vgn __attribute__((unused)),
 						 struct dm_hash_table *pv_hash __attribute__((unused)),
 						 struct dm_hash_table *lv_hash __attribute__((unused)))
 {
-	struct dm_pool *mem = vg->vgmem;
 	const char *historical_lv_name, *origin_name = NULL;
 	struct generic_logical_volume *glv, *origin_glv, *descendant_glv;
 	struct logical_volume *tmp_lv;
@@ -850,7 +868,10 @@ bad:
 	return 0;
 }
 
-static int _read_lvsegs(struct format_instance *fid,
+static int _read_lvsegs(struct cmd_context *cmd,
+			struct format_type *fmt,
+			struct format_instance *fid,
+			struct dm_pool *mem,
 			struct volume_group *vg, const struct dm_config_node *lvn,
 			const struct dm_config_node *vgn __attribute__((unused)),
 			struct dm_hash_table *pv_hash,
@@ -877,7 +898,7 @@ static int _read_lvsegs(struct format_instance *fid,
 
 	memcpy(&lv->lvid.id[0], &lv->vg->id, sizeof(lv->lvid.id[0]));
 
-	if (!_read_segments(lv, lvn, pv_hash))
+	if (!_read_segments(cmd, fmt, fid, mem, lv, lvn, pv_hash))
 		return_0;
 
 	lv->size = (uint64_t) lv->le_count * (uint64_t) vg->extent_size;
@@ -893,14 +914,14 @@ static int _read_lvsegs(struct format_instance *fid,
 
 		if (!dm_config_has_node(lvn, "major"))
 			/* If major is missing, pick default */
-			lv->major = vg->cmd->dev_types->device_mapper_major;
+			lv->major = cmd->dev_types->device_mapper_major;
 		else if (!_read_int32(lvn, "major", &lv->major)) {
 			log_warn("WARNING: Couldn't read major number for logical "
 				 "volume %s.", display_lvname(lv));
-			lv->major = vg->cmd->dev_types->device_mapper_major;
+			lv->major = cmd->dev_types->device_mapper_major;
 		}
 
-		if (!validate_major_minor(vg->cmd, fid->fmt, lv->major, lv->minor)) {
+		if (!validate_major_minor(cmd, fmt, lv->major, lv->minor)) {
 			log_warn("WARNING: Ignoring invalid major, minor number for "
 				 "logical volume %s.", display_lvname(lv));
 			lv->major = lv->minor = -1;
@@ -910,7 +931,10 @@ static int _read_lvsegs(struct format_instance *fid,
 	return 1;
 }
 
-static int _read_sections(struct format_instance *fid,
+static int _read_sections(struct cmd_context *cmd,
+			  struct format_type *fmt,
+			  struct format_instance *fid,
+			  struct dm_pool *mem,
 			  const char *section, section_fn fn,
 			  struct volume_group *vg, const struct dm_config_node *vgn,
 			  struct dm_hash_table *pv_hash,
@@ -929,7 +953,7 @@ static int _read_sections(struct format_instance *fid,
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(fid, vg, n, vgn, pv_hash, lv_hash))
+		if (!fn(cmd, fmt, fid, mem, vg, n, vgn, pv_hash, lv_hash))
 			return_0;
 	}
 
@@ -940,6 +964,9 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 				     const struct dm_config_tree *cft,
 				     unsigned allow_lvmetad_extensions)
 {
+	struct cmd_context *cmd = fid->fmt->cmd;
+	struct format_type *fmt = fid->fmt;
+	struct dm_pool *mem;
 	const struct dm_config_node *vgn;
 	const struct dm_config_value *cv;
 	const char *str, *format_str, *system_id;
@@ -956,9 +983,11 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		return NULL;
 	}
 
-	if (!(vg = alloc_vg("read_vg", fid->fmt->cmd, vgn->key)))
+	if (!(vg = alloc_vg("read_vg", cmd, vgn->key)))
 		return_NULL;
 
+	mem = vg->vgmem;
+
 	/*
 	 * The pv hash memorises the pv section names -> pv
 	 * structures.
@@ -981,13 +1010,13 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	/* A backup file might be a backup of a different format */
 	if (dm_config_get_str(vgn, "format", &format_str) &&
-	    !(vg->original_fmt = get_format_by_name(fid->fmt->cmd, format_str))) {
+	    !(vg->original_fmt = get_format_by_name(cmd, format_str))) {
 		log_error("Unrecognised format %s for volume group %s.", format_str, vg->name);
 		goto bad;
 	}
 
 	if (dm_config_get_str(vgn, "lock_type", &str)) {
-		if (!(vg->lock_type = dm_pool_strdup(vg->vgmem, str)))
+		if (!(vg->lock_type = dm_pool_strdup(mem, str)))
 			goto bad;
 	}
 
@@ -1013,7 +1042,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	 * the lock_args before using it to access the lock manager.
 	 */
 	if (dm_config_get_str(vgn, "lock_args", &str)) {
-		if (!(vg->lock_args = dm_pool_strdup(vg->vgmem, str)))
+		if (!(vg->lock_args = dm_pool_strdup(mem, str)))
 			goto bad;
 	}
 
@@ -1035,7 +1064,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	}
 
 	if (dm_config_get_str(vgn, "system_id", &system_id)) {
-		if (!(vg->system_id = dm_pool_strdup(vg->vgmem, system_id))) {
+		if (!(vg->system_id = dm_pool_strdup(mem, system_id))) {
 			log_error("Failed to allocate memory for system_id in _read_vg.");
 			goto bad;
 		}
@@ -1080,7 +1109,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	if (dm_config_get_str(vgn, "profile", &str)) {
 		log_debug_metadata("Adding profile configuration %s for VG %s.", str, vg->name);
-		vg->profile = add_profile(vg->cmd, str, CONFIG_PROFILE_METADATA);
+		vg->profile = add_profile(cmd, str, CONFIG_PROFILE_METADATA);
 		if (!vg->profile) {
 			log_error("Failed to add configuration profile %s for VG %s", str, vg->name);
 			goto bad;
@@ -1091,7 +1120,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		vg->mda_copies = DEFAULT_VGMETADATACOPIES;
 	}
 
-	if (!_read_sections(fid, "physical_volumes", _read_pv, vg,
+	if (!_read_sections(cmd, fmt, fid, mem, "physical_volumes", _read_pv, vg,
 			    vgn, pv_hash, lv_hash, 0)) {
 		log_error("Couldn't find all physical volumes for volume "
 			  "group %s.", vg->name);
@@ -1100,33 +1129,33 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	/* Optional tags */
 	if (dm_config_get_list(vgn, "tags", &cv) &&
-	    !(_read_str_list(vg->vgmem, &vg->tags, cv))) {
+	    !(_read_str_list(mem, &vg->tags, cv))) {
 		log_error("Couldn't read tags for volume group %s.", vg->name);
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "logical_volumes", _read_lvnames, vg,
+	if (!_read_sections(cmd, fmt, fid, mem, "logical_volumes", _read_lvnames, vg,
 			    vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all logical volume names for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "historical_logical_volumes", _read_historical_lvnames, vg,
+	if (!_read_sections(cmd, fmt, fid, mem, "historical_logical_volumes", _read_historical_lvnames, vg,
 			    vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all historical logical volumes for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, vg,
+	if (!_read_sections(cmd, fmt, fid, mem, "logical_volumes", _read_lvsegs, vg,
 			    vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all logical volumes for "
 			  "volume group %s.", vg->name);
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "historical_logical_volumes", _read_historical_lvnames_interconnections,
+	if (!_read_sections(cmd, fmt, fid, mem, "historical_logical_volumes", _read_historical_lvnames_interconnections,
 			    vg, vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all removed logical volume interconnections "
 			  "for volume group %s.", vg->name);


