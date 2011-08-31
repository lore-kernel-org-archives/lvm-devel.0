From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 31 Aug 2011 15:19:21 -0000
Subject: LVM2 lib/config/config.c lib/format_text/impor ...
Message-ID: <20110831151921.10101.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-08-31 15:19:20

Modified files:
	lib/config     : config.c 
	lib/format_text: import_vsn1.c text_import.h 
	lib/mirror     : mirrored.c 
	lib/raid       : raid.c 
	lib/striped    : striped.c 
	libdm          : libdevmapper.h libdm-config.c 

Log message:
	Replace const usage of dm_config_find_node with more appropriate value-lookup
	functionality. A number of bugs (copied and pasted all over the code) should
	disappear:
	
	- most string lookup based on dm_config_find_node would segfault when
	encountering a non-zero integer (the intention there was to print an
	error message instead)
	- check for required sections in metadata would have been satisfied by
	values as well (i.e. not sections)
	- encountering a section in place of expected flag value would have
	segfaulted (due to assumed but unchecked cn->v != NULL)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_import.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/config/config.c	2011/08/30 14:55:16	1.102
+++ LVM2/lib/config/config.c	2011/08/31 15:19:19	1.103
@@ -222,7 +222,7 @@
 			/* Ignore - we don't have any of these yet */
 			continue;
 		/* Not already present? */
-		if (!(oldn = (struct dm_config_node*)dm_config_find_node(cn1->child, cn->key))) {
+		if (!(oldn = dm_config_find_node(cn1->child, cn->key))) {
 			_insert_config_node(&cn1->child, cn);
 			continue;
 		}
@@ -266,7 +266,7 @@
 int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 		      struct dm_config_tree *newdata)
 {
-	const struct dm_config_node *root = cft->root;
+	struct dm_config_node *root = cft->root;
 	struct dm_config_node *cn, *nextn, *oldn, *cn2;
 	const struct dm_config_node *tn;
 
@@ -280,7 +280,7 @@
 			if (!_match_host_tags(&cmd->tags, tn))
 				continue;
 		}
-		if (!(oldn = (struct dm_config_node *)dm_config_find_node(root, cn->key))) {
+		if (!(oldn = dm_config_find_node(root, cn->key))) {
 			_insert_config_node(&cft->root, cn);
 			/* Remove any "tags" nodes */
 			for (cn2 = cn->child; cn2; cn2 = cn2->sib) {
--- LVM2/lib/format_text/import_vsn1.c	2011/08/30 14:55:17	1.91
+++ LVM2/lib/format_text/import_vsn1.c	2011/08/31 15:19:19	1.92
@@ -108,20 +108,14 @@
 
 static int _read_id(struct id *id, const struct dm_config_node *cn, const char *path)
 {
-	const struct dm_config_value *cv;
+	const char *uuid;
 
-	if (!(cn = dm_config_find_node(cn, path))) {
+	if (!dm_config_get_str(cn, path, &uuid)) {
 		log_error("Couldn't find uuid.");
 		return 0;
 	}
 
-	cv = cn->v;
-	if (!cv || !cv->v.str) {
-		log_error("uuid must be a string.");
-		return 0;
-	}
-
-	if (!id_read_format(id, cv->v.str)) {
+	if (!id_read_format(id, uuid)) {
 		log_error("Invalid uuid.");
 		return 0;
 	}
@@ -131,21 +125,21 @@
 
 static int _read_flag_config(const struct dm_config_node *n, uint64_t *status, int type)
 {
-	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 	*status = 0;
 
-	if (!(cn = dm_config_find_node(n, "status"))) {
+	if (!dm_config_get_list(n, "status", &cv)) {
 		log_error("Could not find status flags.");
 		return 0;
 	}
 
-	if (!(read_flags(status, type | STATUS_FLAG, cn->v))) {
+	if (!(read_flags(status, type | STATUS_FLAG, cv))) {
 		log_error("Could not read status flags.");
 		return 0;
 	}
 
-	if ((cn = dm_config_find_node(n, "flags"))) {
-		if (!(read_flags(status, type, cn->v))) {
+	if (dm_config_get_list(n, "flags", &cv)) {
+		if (!(read_flags(status, type, cv))) {
 			log_error("Could not read flags.");
 			return 0;
 		}
@@ -164,7 +158,7 @@
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
-	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 	uint64_t size;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
@@ -238,8 +232,8 @@
 	dm_list_init(&pv->segments);
 
 	/* Optional tags */
-	if ((cn = dm_config_find_node(pvn, "tags")) &&
-	    !(read_tags(mem, &pv->tags, cn->v))) {
+	if (dm_config_get_list(pvn, "tags", &cv) &&
+	    !(read_tags(mem, &pv->tags, cv))) {
 		log_error("Couldn't read tags for physical volume %s in %s.",
 			  pv_dev_name(pv), vg->name);
 		return 0;
@@ -297,7 +291,7 @@
 {
 	uint32_t area_count = 0u;
 	struct lv_segment *seg;
-	const struct dm_config_node *cn, *sn_child = sn->child;
+	const struct dm_config_node *sn_child = sn->child;
 	const struct dm_config_value *cv;
 	uint32_t start_extent, extent_count;
 	struct segment_type *segtype;
@@ -322,13 +316,9 @@
 
 	segtype_str = "striped";
 
-	if ((cn = dm_config_find_node(sn_child, "type"))) {
-		cv = cn->v;
-		if (!cv || !cv->v.str) {
-			log_error("Segment type must be a string.");
-			return 0;
-		}
-		segtype_str = cv->v.str;
+	if (!dm_config_get_str(sn_child, "type", &segtype_str)) {
+		log_error("Segment type must be a string.");
+		return 0;
 	}
 
 	if (!(segtype = get_segtype_from_string(vg->cmd, segtype_str)))
@@ -350,8 +340,8 @@
 		return_0;
 
 	/* Optional tags */
-	if ((cn = dm_config_find_node(sn_child, "tags")) &&
-	    !(read_tags(mem, &seg->tags, cn->v))) {
+	if (dm_config_get_list(sn_child, "tags", &cv) &&
+	    !(read_tags(mem, &seg->tags, cv))) {
 		log_error("Couldn't read tags for a segment of %s/%s.",
 			  vg->name, lv->name);
 		return 0;
@@ -378,11 +368,10 @@
 }
 
 int text_import_areas(struct lv_segment *seg, const struct dm_config_node *sn,
-		      const struct dm_config_node *cn, struct dm_hash_table *pv_hash,
+		      const struct dm_config_value *cv, struct dm_hash_table *pv_hash,
 		      uint64_t status)
 {
 	unsigned int s;
-	const struct dm_config_value *cv;
 	struct logical_volume *lv1;
 	struct physical_volume *pv;
 	const char *seg_name = dm_config_parent_name(sn);
@@ -392,7 +381,7 @@
 		return 0;
 	}
 
-	for (cv = cn->v, s = 0; cv && s < seg->area_count; s++, cv = cv->next) {
+	for (s = 0; cv && s < seg->area_count; s++, cv = cv->next) {
 
 		/* first we read the pv */
 		if (cv->type != DM_CFG_STRING) {
@@ -503,7 +492,8 @@
 			 unsigned report_missing_devices __attribute__((unused)))
 {
 	struct logical_volume *lv;
-	const struct dm_config_node *cn;
+	const char *lv_alloc;
+	const struct dm_config_value *cv;
 
 	if (!(lv = alloc_lv(mem)))
 		return_0;
@@ -523,16 +513,10 @@
 	}
 
 	lv->alloc = ALLOC_INHERIT;
-	if ((cn = dm_config_find_node(lvn, "allocation_policy"))) {
-		const struct dm_config_value *cv = cn->v;
-		if (!cv || !cv->v.str) {
-			log_error("allocation_policy must be a string.");
-			return 0;
-		}
-
-		lv->alloc = get_alloc_from_string(cv->v.str);
+	if (dm_config_get_str(lvn, "allocation_policy", &lv_alloc)) {
+		lv->alloc = get_alloc_from_string(lv_alloc);
 		if (lv->alloc == ALLOC_INVALID) {
-			log_warn("WARNING: Ignoring unrecognised allocation policy %s for LV %s", cv->v.str, lv->name);
+			log_warn("WARNING: Ignoring unrecognised allocation policy %s for LV %s", lv_alloc, lv->name);
 			lv->alloc = ALLOC_INHERIT;
 		}
 	}
@@ -554,8 +538,8 @@
 	}
 
 	/* Optional tags */
-	if ((cn = dm_config_find_node(lvn, "tags")) &&
-	    !(read_tags(mem, &lv->tags, cn->v))) {
+	if (dm_config_get_list(lvn, "tags", &cv) &&
+	    !(read_tags(mem, &lv->tags, cv))) {
 		log_error("Couldn't read tags for logical volume %s/%s.",
 			  vg->name, lv->name);
 		return 0;
@@ -633,7 +617,7 @@
 	/* Only report missing devices when doing a scan */
 	unsigned report_missing_devices = scan_done_once ? !*scan_done_once : 1;
 
-	if (!(n = dm_config_find_node(vgn, section))) {
+	if (!dm_config_get_section(vgn, section, &n)) {
 		if (!optional) {
 			log_error("Couldn't find section '%s'.", section);
 			return 0;
@@ -655,7 +639,9 @@
 				     const struct dm_config_tree *cft,
 				     unsigned use_cached_pvs)
 {
-	const struct dm_config_node *vgn, *cn;
+	const struct dm_config_node *vgn;
+	const struct dm_config_value *cv;
+	const char *str;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
 	unsigned scan_done_once = use_cached_pvs;
@@ -677,12 +663,8 @@
 
 	vgn = vgn->child;
 
-	if ((cn = dm_config_find_node(vgn, "system_id")) && cn->v) {
-		if (!cn->v->v.str) {
-			log_error("system_id must be a string");
-			goto bad;
-		}
-		strncpy(vg->system_id, cn->v->v.str, NAME_LEN);
+	if (dm_config_get_str(vgn, "system_id", &str)) {
+		strncpy(vg->system_id, str, NAME_LEN);
 	}
 
 	if (!_read_id(&vg->id, vgn, "id")) {
@@ -725,16 +707,10 @@
 		goto bad;
 	}
 
-	if ((cn = dm_config_find_node(vgn, "allocation_policy"))) {
-		const struct dm_config_value *cv = cn->v;
-		if (!cv || !cv->v.str) {
-			log_error("allocation_policy must be a string.");
-			goto bad;
-		}
-
-		vg->alloc = get_alloc_from_string(cv->v.str);
+	if (dm_config_get_str(vgn, "allocation_policy", &str)) {
+		vg->alloc = get_alloc_from_string(str);
 		if (vg->alloc == ALLOC_INVALID) {
-			log_warn("WARNING: Ignoring unrecognised allocation policy %s for VG %s", cv->v.str, vg->name);
+			log_warn("WARNING: Ignoring unrecognised allocation policy %s for VG %s", str, vg->name);
 			vg->alloc = ALLOC_NORMAL;
 		}
 	}
@@ -760,8 +736,8 @@
 	}
 
 	/* Optional tags */
-	if ((cn = dm_config_find_node(vgn, "tags")) &&
-	    !(read_tags(vg->vgmem, &vg->tags, cn->v))) {
+	if (dm_config_get_list(vgn, "tags", &cv) &&
+	    !(read_tags(vg->vgmem, &vg->tags, cv))) {
 		log_error("Couldn't read tags for volume group %s.", vg->name);
 		goto bad;
 	}
--- LVM2/lib/format_text/text_import.h	2011/08/30 14:55:17	1.6
+++ LVM2/lib/format_text/text_import.h	2011/08/31 15:19:19	1.7
@@ -20,7 +20,7 @@
 struct dm_config_node;
 
 int text_import_areas(struct lv_segment *seg, const struct dm_config_node *sn,
-		      const struct dm_config_node *cn, struct dm_hash_table *pv_hash,
+		      const struct dm_config_value *cv, struct dm_hash_table *pv_hash,
 		      uint64_t status);
 
 #endif
--- LVM2/lib/mirror/mirrored.c	2011/08/30 14:55:17	1.90
+++ LVM2/lib/mirror/mirrored.c	2011/08/31 15:19:20	1.91
@@ -83,10 +83,10 @@
 static int _mirrored_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 			struct dm_hash_table *pv_hash)
 {
-	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 	const char *logname = NULL;
 
-	if (dm_config_find_node(sn, "extents_moved")) {
+	if (dm_config_has_node(sn, "extents_moved")) {
 		if (dm_config_get_uint32(sn, "extents_moved",
 				      &seg->extents_copied))
 			seg->status |= PVMOVE;
@@ -98,7 +98,7 @@
 		}
 	}
 
-	if (dm_config_find_node(sn, "region_size")) {
+	if (dm_config_has_node(sn, "region_size")) {
 		if (!dm_config_get_uint32(sn, "region_size",
 				      &seg->region_size)) {
 			log_error("Couldn't read 'region_size' for "
@@ -108,12 +108,7 @@
 		}
 	}
 
-	if ((cn = dm_config_find_node(sn, "mirror_log"))) {
-		if (!cn->v || !cn->v->v.str) {
-			log_error("Mirror log type must be a string.");
-			return 0;
-		}
-		logname = cn->v->v.str;
+	if (dm_config_get_str(sn, "mirror_log", &logname)) {
 		if (!(seg->log_lv = find_lv(seg->lv->vg, logname))) {
 			log_error("Unrecognised mirror log in "
 				  "segment %s of logical volume %s.",
@@ -130,14 +125,14 @@
 		return 0;
 	}
 
-	if (!(cn = dm_config_find_node(sn, "mirrors"))) {
+	if (!dm_config_get_list(sn, "mirrors", &cv)) {
 		log_error("Couldn't find mirrors array for "
 			  "segment %s of logical volume %s.",
 			  dm_config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 
-	return text_import_areas(seg, sn, cn, pv_hash, MIRROR_IMAGE);
+	return text_import_areas(seg, sn, cv, pv_hash, MIRROR_IMAGE);
 }
 
 static int _mirrored_text_export(const struct lv_segment *seg, struct formatter *f)
--- LVM2/lib/raid/raid.c	2011/08/30 14:55:18	1.10
+++ LVM2/lib/raid/raid.c	2011/08/31 15:19:20	1.11
@@ -45,10 +45,9 @@
 
 static int _raid_text_import_areas(struct lv_segment *seg,
 				   const struct dm_config_node *sn,
-				   const struct dm_config_node *cn)
+				   const struct dm_config_value *cv)
 {
 	unsigned int s;
-	const struct dm_config_value *cv;
 	struct logical_volume *lv1;
 	const char *seg_name = dm_config_parent_name(sn);
 
@@ -57,7 +56,7 @@
 		return 0;
 	}
 
-	for (cv = cn->v, s = 0; cv && s < seg->area_count; s++, cv = cv->next) {
+	for (s = 0; cv && s < seg->area_count; s++, cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
 			log_error("Bad volume name in areas array for segment %s.", seg_name);
 			return 0;
@@ -104,9 +103,9 @@
 			     const struct dm_config_node *sn,
 			     struct dm_hash_table *pv_hash)
 {
-	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 
-	if (dm_config_find_node(sn, "region_size")) {
+	if (dm_config_has_node(sn, "region_size")) {
 		if (!dm_config_get_uint32(sn, "region_size", &seg->region_size)) {
 			log_error("Couldn't read 'region_size' for "
 				  "segment %s of logical volume %s.",
@@ -114,7 +113,7 @@
 			return 0;
 		}
 	}
-	if (dm_config_find_node(sn, "stripe_size")) {
+	if (dm_config_has_node(sn, "stripe_size")) {
 		if (!dm_config_get_uint32(sn, "stripe_size", &seg->stripe_size)) {
 			log_error("Couldn't read 'stripe_size' for "
 				  "segment %s of logical volume %s.",
@@ -122,14 +121,14 @@
 			return 0;
 		}
 	}
-	if (!(cn = dm_config_find_node(sn, "raids"))) {
+	if (!dm_config_get_list(sn, "raids", &cv)) {
 		log_error("Couldn't find RAID array for "
 			  "segment %s of logical volume %s.",
 			  dm_config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 
-	if (!_raid_text_import_areas(seg, sn, cn)) {
+	if (!_raid_text_import_areas(seg, sn, cv)) {
 		log_error("Failed to import RAID images");
 		return 0;
 	}
--- LVM2/lib/striped/striped.c	2011/08/30 14:55:18	1.38
+++ LVM2/lib/striped/striped.c	2011/08/31 15:19:20	1.39
@@ -71,7 +71,7 @@
 static int _striped_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 			struct dm_hash_table *pv_hash)
 {
-	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 
 	if ((seg->area_count != 1) &&
 	    !dm_config_get_uint32(sn, "stripe_size", &seg->stripe_size)) {
@@ -80,7 +80,7 @@
 		return 0;
 	}
 
-	if (!(cn = dm_config_find_node(sn, "stripes"))) {
+	if (!dm_config_get_list(sn, "stripes", &cv)) {
 		log_error("Couldn't find stripes array for segment %s "
 			  "of logical volume %s.", dm_config_parent_name(sn), seg->lv->name);
 		return 0;
@@ -88,7 +88,7 @@
 
 	seg->area_len /= seg->area_count;
 
-	return text_import_areas(seg, sn, cn, pv_hash, 0);
+	return text_import_areas(seg, sn, cv, pv_hash, 0);
 }
 
 static int _striped_text_export(const struct lv_segment *seg, struct formatter *f)
--- LVM2/libdm/libdevmapper.h	2011/08/31 12:39:58	1.146
+++ LVM2/libdm/libdevmapper.h	2011/08/31 15:19:20	1.147
@@ -1275,7 +1275,8 @@
 time_t dm_config_timestamp(struct dm_config_tree *cft);
 int dm_config_changed(struct dm_config_tree *cft);
 
-struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn, const char *path);
+struct dm_config_node *dm_config_find_node(struct dm_config_node *cn, const char *path);
+int dm_config_has_node(const struct dm_config_node *cn, const char *path);
 const char *dm_config_find_str(const struct dm_config_node *cn, const char *path, const char *fail);
 int dm_config_find_int(const struct dm_config_node *cn, const char *path, int fail);
 float dm_config_find_float(const struct dm_config_node *cn, const char *path, float fail);
@@ -1307,6 +1308,10 @@
 
 int dm_config_get_str(const struct dm_config_node *cn, const char *path,
 		      const char **result);
+int dm_config_get_list(const struct dm_config_node *cn, const char *path,
+		       const struct dm_config_value **result);
+int dm_config_get_section(const struct dm_config_node *cn, const char *path,
+			  const struct dm_config_node **result);
 
 unsigned dm_config_maybe_section(const char *str, unsigned len);
 
--- LVM2/libdm/libdm-config.c	2011/08/31 12:39:58	1.2
+++ LVM2/libdm/libdm-config.c	2011/08/31 15:19:20	1.3
@@ -973,7 +973,7 @@
  * node-based lookup
  **/
 
-struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn,
+struct dm_config_node *dm_config_find_node(struct dm_config_node *cn,
 					   const char *path)
 {
 	return _find_config_node(cn, path);
@@ -1038,11 +1038,11 @@
 
 
 int dm_config_get_uint32(const struct dm_config_node *cn, const char *path,
-			      uint32_t *result)
+			 uint32_t *result)
 {
 	const struct dm_config_node *n;
 
-	n = dm_config_find_node(cn, path);
+	n = _find_config_node(cn, path);
 
 	if (!n || !n->v || n->v->type != DM_CFG_INT)
 		return 0;
@@ -1056,7 +1056,7 @@
 {
 	const struct dm_config_node *n;
 
-	n = dm_config_find_node(cn, path);
+	n = _find_config_node(cn, path);
 
 	if (!n || !n->v || n->v->type != DM_CFG_INT)
 		return 0;
@@ -1070,7 +1070,7 @@
 {
 	const struct dm_config_node *n;
 
-	n = dm_config_find_node(cn, path);
+	n = _find_config_node(cn, path);
 
 	if (!n || !n->v || n->v->type != DM_CFG_STRING)
 		return 0;
@@ -1079,6 +1079,39 @@
 	return 1;
 }
 
+int dm_config_get_list(const struct dm_config_node *cn, const char *path,
+		       const struct dm_config_value **result)
+{
+	const struct dm_config_node *n;
+
+	n = _find_config_node(cn, path);
+	/* TODO when we represent single-item lists consistently, add a check
+	 * for n->v->next != NULL */
+	if (!n || !n->v)
+		return 0;
+
+	*result = n->v;
+	return 1;
+}
+
+int dm_config_get_section(const struct dm_config_node *cn, const char *path,
+			  const struct dm_config_node **result)
+{
+	const struct dm_config_node *n;
+
+	n = _find_config_node(cn, path);
+	if (!n || n->v)
+		return 0;
+
+	*result = n;
+	return 1;
+}
+
+int dm_config_has_node(const struct dm_config_node *cn, const char *path)
+{
+	return _find_config_node(cn, path) ? 1 : 0;
+}
+
 /*
  * Convert a token type to the char it represents.
  */


