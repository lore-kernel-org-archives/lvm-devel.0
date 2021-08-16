From: David Teigland <teigland@sourceware.org>
Date: Mon, 16 Aug 2021 16:31:35 +0000 (GMT)
Subject: main - cov: clean up pvid and vgid usage
Message-ID: <20210816163135.7EAC3385742B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96b777167c63eaf2e8ef1a2e7a92dc6c66cbcd6a
Commit:        96b777167c63eaf2e8ef1a2e7a92dc6c66cbcd6a
Parent:        0d572d14ad14afad43a8a3f5fe033ed3996c05c6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 3 15:32:33 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 16 11:31:15 2021 -0500

cov: clean up pvid and vgid usage

pvid and vgid are sometimes a null-terminated string, and
other times a 'struct id', and the two types were often
cast between each other.  When a struct id was cast to a char
pointer, the resulting string would not necessarily be null
terminated.  Casting a null-terminated string id to a
struct id is fine, but is still avoided when possible.

A struct id is:  int8_t uuid[ID_LEN]
A string id is:  char pvid[ID_LEN + 1]

A convention is introduced to help distinguish them:

- variables and struct fields named "pvid" or "vgid"
  should be null-terminated strings.

- variables and struct fields named "pv_id" or "vg_id"
  should be struct id's.

- examples:
  char pvid[ID_LEN + 1];
  char vgid[ID_LEN + 1];
  struct id pv_id;
  struct id vg_id;

Function names also attempt to follow this convention.

Avoid casting between the two types as much as possible,
with limited exceptions when known to be safe and clearly
commented.

Avoid using variations of strcpy and strcmp, and instead
use memcpy/memcmp with ID_LEN (with similar limited
exceptions possible.)
---
 lib/activate/dev_manager.c    |   2 +-
 lib/cache/lvmcache.c          | 224 +++++++++++++++++++++++-------------------
 lib/cache/lvmcache.h          |   7 +-
 lib/device/device_id.c        |   4 +-
 lib/format_text/archiver.c    |   3 +-
 lib/format_text/format-text.c |  57 +++++++++--
 lib/format_text/import_vsn1.c |   8 +-
 lib/format_text/text_label.c  |  10 +-
 lib/label/label.c             |   5 +-
 lib/metadata/metadata.c       |  46 ++++++---
 lib/metadata/metadata.h       |   2 +-
 lib/metadata/pv.c             |  21 ++--
 lib/metadata/pv.h             |   4 +-
 tools/pvchange.c              |   4 +-
 tools/pvck.c                  |  44 ++++-----
 tools/pvscan.c                |  10 +-
 tools/toollib.c               |  28 +++---
 tools/vgimportdevices.c       |   9 +-
 tools/vgrename.c              |  12 ++-
 19 files changed, 296 insertions(+), 204 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c4a673901..2ada9b525 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2118,7 +2118,7 @@ static int _check_holder(struct dev_manager *dm, struct dm_tree *dtree,
 		if (!strncmp(default_uuid_prefix, uuid, default_uuid_prefix_len))
 			uuid += default_uuid_prefix_len;
 
-		if (!strncmp(uuid, (char*)&lv->vg->id, sizeof(lv->vg->id)) &&
+		if (!memcmp(uuid, &lv->vg->id, ID_LEN) &&
 		    !dm_tree_find_node_by_uuid(dtree, uuid)) {
 			/* trims any UUID suffix (i.e. -cow) */
 			(void) dm_strncpy((char*)&id, uuid, 2 * sizeof(struct id) + 1);
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f5df5e10c..655da164c 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -316,7 +316,7 @@ static struct lvmcache_vginfo *_search_vginfos_list(const char *vgname, const ch
 
 	if (vgid) {
 		dm_list_iterate_items(vginfo, &_vginfos) {
-			if (!strcmp(vgid, vginfo->vgid))
+			if (!memcmp(vgid, vginfo->vgid, ID_LEN))
 				return vginfo;
 		}
 	} else {
@@ -328,20 +328,21 @@ static struct lvmcache_vginfo *_search_vginfos_list(const char *vgname, const ch
 	return NULL;
 }
 
-static struct lvmcache_vginfo *_vginfo_lookup(const char *vgname, const char *vgid)
+static struct lvmcache_vginfo *_vginfo_lookup(const char *vgname, const char *vgid_arg)
 {
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct lvmcache_vginfo *vginfo;
-	char id[ID_LEN + 1] __attribute__((aligned(8)));
 
-	if (vgid) {
-		/* vgid not necessarily NULL-terminated */
-		(void) dm_strncpy(id, vgid, sizeof(id));
+	/* In case vgid is not null terminated */
+	if (vgid_arg)
+		memcpy(vgid, vgid_arg, ID_LEN);
 
-		if ((vginfo = dm_hash_lookup(_vgid_hash, id))) {
+	if (vgid_arg) {
+		if ((vginfo = dm_hash_lookup(_vgid_hash, vgid))) {
 			if (vgname && strcmp(vginfo->vgname, vgname)) {
 				/* should never happen */
 				log_error(INTERNAL_ERROR "vginfo_lookup vgid %s has two names %s %s",
-					  id, vginfo->vgname, vgname);
+					  vgid, vginfo->vgname, vgname);
 				return NULL;
 			}
 			return vginfo;
@@ -363,7 +364,7 @@ static struct lvmcache_vginfo *_vginfo_lookup(const char *vgname, const char *vg
 	}
 
 	if (vgname && _found_duplicate_vgnames) {
-		if ((vginfo = _search_vginfos_list(vgname, vgid))) {
+		if ((vginfo = _search_vginfos_list(vgname, vgid[0] ? vgid : NULL))) {
 			if (vginfo->has_duplicate_local_vgname) {
 				log_debug("vginfo_lookup %s has_duplicate_local_vgname return none.", vgname);
 				return NULL;
@@ -450,17 +451,18 @@ bool lvmcache_has_duplicate_local_vgname(const char *vgid, const char *vgname)
  * When the device being worked with is known, pass that dev as the second arg.
  * This ensures that when duplicates exist, the wrong dev isn't used.
  */
-struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, struct device *dev, int valid_only)
+struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid_arg, struct device *dev, int valid_only)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct lvmcache_info *info;
-	char id[ID_LEN + 1] __attribute__((aligned(8)));
 
-	if (!_pvid_hash || !pvid)
+	if (!_pvid_hash || !pvid_arg)
 		return NULL;
 
-	(void) dm_strncpy(id, pvid, sizeof(id));
+	/* For cases where pvid_arg is not null terminated. */
+	memcpy(pvid, pvid_arg, ID_LEN);
 
-	if (!(info = dm_hash_lookup(_pvid_hash, id)))
+	if (!(info = dm_hash_lookup(_pvid_hash, pvid)))
 		return NULL;
 
 	/*
@@ -468,13 +470,23 @@ struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, struct device *d
 	 */
 	if (dev && info->dev && (info->dev != dev)) {
 		log_debug_cache("Ignoring lvmcache info for dev %s because dev %s was requested for PVID %s.",
-				dev_name(info->dev), dev_name(dev), id);
+				dev_name(info->dev), dev_name(dev), pvid);
 		return NULL;
 	}
 
 	return info;
 }
 
+struct lvmcache_info *lvmcache_info_from_pv_id(const struct id *pv_id, struct device *dev, int valid_only)
+{
+	/*
+	 * Since we know that lvmcache_info_from_pvid directly above
+	 * does not assume pvid_arg is null-terminated, we make an
+	 * exception here and cast a struct id to char *.
+	 */
+	return lvmcache_info_from_pvid((const char *)pv_id, dev, valid_only);
+}
+
 const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info)
 {
 	return info->fmt;
@@ -487,16 +499,18 @@ const char *lvmcache_vgname_from_info(struct lvmcache_info *info)
 	return NULL;
 }
 
-static uint64_t _get_pvsummary_size(char *pvid)
+static uint64_t _get_pvsummary_size(const char *pvid_arg)
 {
-	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct lvmcache_vginfo *vginfo;
 	struct pv_list *pvl;
 
+	/* In case pvid_arg is not null terminated. */
+	memcpy(pvid, pvid_arg, ID_LEN);
+
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		dm_list_iterate_items(pvl, &vginfo->pvsummaries) {
-			(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
-			if (!strcmp(pvid_s, pvid))
+			if (!memcmp(pvid, &pvl->pv->id.uuid, ID_LEN))
 				return pvl->pv->size;
 		}
 	}
@@ -504,16 +518,18 @@ static uint64_t _get_pvsummary_size(char *pvid)
 	return 0;
 }
 
-static const char *_get_pvsummary_device_hint(char *pvid)
+static const char *_get_pvsummary_device_hint(const char *pvid_arg)
 {
-	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct lvmcache_vginfo *vginfo;
 	struct pv_list *pvl;
 
+	/* In case pvid_arg is not null terminated. */
+	memcpy(pvid, pvid_arg, ID_LEN);
+
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		dm_list_iterate_items(pvl, &vginfo->pvsummaries) {
-			(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
-			if (!strcmp(pvid_s, pvid))
+			if (!memcmp(pvid, &pvl->pv->id.uuid, ID_LEN))
 				return pvl->pv->device_hint;
 		}
 	}
@@ -521,16 +537,18 @@ static const char *_get_pvsummary_device_hint(char *pvid)
 	return NULL;
 }
 
-static const char *_get_pvsummary_device_id(char *pvid, const char **device_id_type)
+static const char *_get_pvsummary_device_id(const char *pvid_arg, const char **device_id_type)
 {
-	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct lvmcache_vginfo *vginfo;
 	struct pv_list *pvl;
 
+	/* In case pvid_arg is not null terminated. */
+	memcpy(pvid, pvid_arg, ID_LEN);
+
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		dm_list_iterate_items(pvl, &vginfo->pvsummaries) {
-			(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
-			if (!strcmp(pvid_s, pvid)) {
+			if (!memcmp(&pvid, &pvl->pv->id.uuid, ID_LEN)) {
 				*device_id_type = pvl->pv->device_id_type;
 				return pvl->pv->device_id;
 			}
@@ -552,7 +570,7 @@ int vg_has_duplicate_pvs(struct volume_group *vg)
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		dm_list_iterate_items(devl, &_unused_duplicates) {
-			if (id_equal(&pvl->pv->id, (const struct id *)devl->dev->pvid))
+			if (!memcmp(&pvl->pv->id.uuid, devl->dev->pvid, ID_LEN))
 				return 1;
 		}
 	}
@@ -566,15 +584,17 @@ bool lvmcache_dev_is_unused_duplicate(struct device *dev)
 
 static void _warn_unused_duplicates(struct cmd_context *cmd)
 {
-	char uuid[64] __attribute__((aligned(8)));
+	char pvid_dashed[64] __attribute__((aligned(8)));
 	struct lvmcache_info *info;
 	struct device_list *devl;
+	struct id id;
 
 	dm_list_iterate_items(devl, &_unused_duplicates) {
-		if (!id_write_format((const struct id *)devl->dev->pvid, uuid, sizeof(uuid)))
+		memcpy(&id, devl->dev->pvid, ID_LEN);
+		if (!id_write_format(&id, pvid_dashed, sizeof(pvid_dashed)))
 			stack;
 
-		log_warn("WARNING: Not using device %s for PV %s.", dev_name(devl->dev), uuid);
+		log_warn("WARNING: Not using device %s for PV %s.", dev_name(devl->dev), pvid_dashed);
 	}
 
 	dm_list_iterate_items(devl, &_unused_duplicates) {
@@ -582,11 +602,12 @@ static void _warn_unused_duplicates(struct cmd_context *cmd)
 		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
 			continue;
 
-		if (!id_write_format((const struct id *)info->dev->pvid, uuid, sizeof(uuid)))
+		memcpy(&id, info->dev->pvid, ID_LEN);
+		if (!id_write_format(&id, pvid_dashed, sizeof(pvid_dashed)))
 			stack;
 
 		log_warn("WARNING: PV %s prefers device %s because %s.",
-			 uuid, dev_name(info->dev), info->dev->duplicate_prefer_reason);
+			 pvid_dashed, dev_name(info->dev), info->dev->duplicate_prefer_reason);
 	}
 }
 
@@ -636,7 +657,7 @@ static void _choose_duplicates(struct cmd_context *cmd,
 			       struct dm_list *del_cache_devs,
 			       struct dm_list *add_cache_devs)
 {
-	char *pvid;
+	const char *pvid;
 	const char *reason;
 	const char *device_hint;
 	struct dm_list altdevs;
@@ -1370,28 +1391,15 @@ int lvmcache_get_vgnameids(struct cmd_context *cmd,
 	return 1;
 }
 
-static struct device *_device_from_pvid(const struct id *pvid, uint64_t *label_sector)
+struct device *lvmcache_device_from_pv_id(struct cmd_context *cmd, const struct id *pv_id, uint64_t *label_sector)
 {
 	struct lvmcache_info *info;
 
-	if ((info = lvmcache_info_from_pvid((const char *) pvid, NULL, 0))) {
+	if ((info = lvmcache_info_from_pv_id(pv_id, NULL, 0))) {
 		if (info->label && label_sector)
 			*label_sector = info->label->sector;
 		return info->dev;
 	}
-
-	return NULL;
-}
-
-struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid, uint64_t *label_sector)
-{
-	struct device *dev;
-
-	dev = _device_from_pvid(pvid, label_sector);
-	if (dev)
-		return dev;
-
-	log_debug_devs("No device with uuid %s.", (const char *)pvid);
 	return NULL;
 }
 
@@ -1400,7 +1408,7 @@ int lvmcache_pvid_in_unused_duplicates(const char *pvid)
 	struct device_list *devl;
 
 	dm_list_iterate_items(devl, &_unused_duplicates) {
-		if (!strncmp(devl->dev->pvid, pvid, ID_LEN))
+		if (!memcmp(devl->dev->pvid, pvid, ID_LEN))
 			return 1;
 	}
 	return 0;
@@ -1455,7 +1463,7 @@ void lvmcache_del_dev(struct device *dev)
 {
 	struct lvmcache_info *info;
 
-	if ((info = lvmcache_info_from_pvid((const char *)dev->pvid, dev, 0)))
+	if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 		lvmcache_del(info);
 }
 
@@ -1467,7 +1475,7 @@ static int _lvmcache_update_vgid(struct lvmcache_info *info,
 				 const char *vgid)
 {
 	if (!vgid || !vginfo ||
-	    !strncmp(vginfo->vgid, vgid, ID_LEN))
+	    !memcmp(vginfo->vgid, vgid, ID_LEN))
 		return 1;
 
 	if (vginfo && *vginfo->vgid)
@@ -1478,7 +1486,8 @@ static int _lvmcache_update_vgid(struct lvmcache_info *info,
 		return 1;
 	}
 
-	(void) dm_strncpy(vginfo->vgid, vgid, sizeof(vginfo->vgid));
+	memset(vginfo->vgid, 0, sizeof(vginfo->vgid));
+	memcpy(vginfo->vgid, vgid, ID_LEN);
 	if (!dm_hash_insert(_vgid_hash, vginfo->vgid, vginfo)) {
 		log_error("_lvmcache_update: vgid hash insertion failed: %s",
 			  vginfo->vgid);
@@ -1499,8 +1508,8 @@ static int _lvmcache_update_vgname(struct cmd_context *cmd,
 				   const char *system_id,
 				   const struct format_type *fmt)
 {
-	char vgid_str[64] __attribute__((aligned(8)));
-	char other_str[64] __attribute__((aligned(8)));
+	char vgid_dashed[64] __attribute__((aligned(8)));
+	char other_dashed[64] __attribute__((aligned(8)));
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_vginfo *other;
 	int vginfo_is_allowed;
@@ -1509,7 +1518,7 @@ static int _lvmcache_update_vgname(struct cmd_context *cmd,
 	if (!vgname || (info && info->vginfo && !strcmp(info->vginfo->vgname, vgname)))
 		return 1;
 
-	if (!id_write_format((const struct id *)vgid, vgid_str, sizeof(vgid_str)))
+	if (!id_write_format((const struct id *)vgid, vgid_dashed, sizeof(vgid_dashed)))
 		stack;
 
 	/*
@@ -1555,7 +1564,7 @@ static int _lvmcache_update_vgname(struct cmd_context *cmd,
 	 	 * into the hash table.
 	 	 */
 
-		log_debug_cache("lvmcache adding vginfo for %s %s", vgname, vgid_str);
+		log_debug_cache("lvmcache adding vginfo for %s %s", vgname, vgid_dashed);
 
 		if (!(vginfo = zalloc(sizeof(*vginfo)))) {
 			log_error("lvmcache adding vg list alloc failed %s", vgname);
@@ -1585,7 +1594,7 @@ static int _lvmcache_update_vgname(struct cmd_context *cmd,
 			if (!memcmp(other->vgid, vgid, ID_LEN)) {
 				/* shouldn't happen since we looked up by vgid above */
 				log_error(INTERNAL_ERROR "lvmcache_update_vgname %s %s %s %s",
-					  vgname, vgid_str, other->vgname, other->vgid);
+					  vgname, vgid, other->vgname, other->vgid);
 				free(vginfo->vgname);
 				free(vginfo);
 				return 0;
@@ -1595,7 +1604,7 @@ static int _lvmcache_update_vgname(struct cmd_context *cmd,
 			other_is_allowed = is_system_id_allowed(cmd, other->system_id);
 
 			if (vginfo_is_allowed && other_is_allowed) {
-				if (!id_write_format((const struct id *)other->vgid, other_str, sizeof(other_str)))
+				if (!id_write_format((const struct id *)other->vgid, other_dashed, sizeof(other_dashed)))
 					stack;
 
 				vginfo->has_duplicate_local_vgname = 1;
@@ -1603,7 +1612,7 @@ static int _lvmcache_update_vgname(struct cmd_context *cmd,
 				_found_duplicate_vgnames = 1;
 
 				log_warn("WARNING: VG name %s is used by VGs %s and %s.",
-					 vgname, vgid_str, other_str);
+					 vgname, vgid_dashed, other_dashed);
 				log_warn("Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.");
 			}
 
@@ -1636,7 +1645,7 @@ static int _lvmcache_update_vgname(struct cmd_context *cmd,
 	info->vginfo = vginfo;
 	dm_list_add(&vginfo->infos, &info->list);
 
-	log_debug_cache("lvmcache %s: now in VG %s %s", dev_name(info->dev), vgname, vgid_str);
+	log_debug_cache("lvmcache %s: now in VG %s %s", dev_name(info->dev), vgname, vgid);
 
 	return 1;
 }
@@ -1737,7 +1746,7 @@ static void _lvmcache_update_pvsummaries(struct lvmcache_vginfo *vginfo, struct
 int lvmcache_update_vgname_and_id(struct cmd_context *cmd, struct lvmcache_info *info, struct lvmcache_vgsummary *vgsummary)
 {
 	const char *vgname = vgsummary->vgname;
-	const char *vgid = (char *)&vgsummary->vgid;
+	const char *vgid = vgsummary->vgid;
 	struct lvmcache_vginfo *vginfo;
 
 	if (!vgname && !info->vginfo) {
@@ -1926,21 +1935,21 @@ int lvmcache_update_vgname_and_id(struct cmd_context *cmd, struct lvmcache_info
 
 int lvmcache_update_vg_from_write(struct volume_group *vg)
 {
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
-	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
 	struct lvmcache_vgsummary vgsummary = {
 		.vgname = vg->name,
-		.vgid = vg->id,
 		.vgstatus = vg->status,
 		.system_id = vg->system_id,
 		.lock_type = vg->lock_type
 	};
 
+	memcpy(vgid, &vg->id, ID_LEN);
+	memcpy(vgsummary.vgid, vgid, ID_LEN);
+
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
-		/* FIXME Could pvl->pv->dev->pvid ever be different? */
-		if ((info = lvmcache_info_from_pvid(pvid_s, pvl->pv->dev, 0)) &&
+		if ((info = lvmcache_info_from_pv_id(&pvl->pv->id, pvl->pv->dev, 0)) &&
 		    !lvmcache_update_vgname_and_id(vg->cmd, info, &vgsummary))
 			return_0;
 	}
@@ -1961,20 +1970,23 @@ int lvmcache_update_vg_from_write(struct volume_group *vg)
 
 int lvmcache_update_vg_from_read(struct volume_group *vg, unsigned precommitted)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct pv_list *pvl;
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info, *info2;
 	struct metadata_area *mda;
-	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
 	struct lvmcache_vgsummary vgsummary = {
 		.vgname = vg->name,
-		.vgid = vg->id,
 		.vgstatus = vg->status,
 		.system_id = vg->system_id,
 		.lock_type = vg->lock_type
 	};
 
-	if (!(vginfo = lvmcache_vginfo_from_vgname(vg->name, (const char *)&vg->id))) {
+	memcpy(vgid, &vg->id, ID_LEN);
+	memcpy(vgsummary.vgid, vgid, ID_LEN);
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vg->name, vgid))) {
 		log_error(INTERNAL_ERROR "lvmcache_update_vg %s no vginfo", vg->name);
 		return 0;
 	}
@@ -2008,12 +2020,11 @@ int lvmcache_update_vg_from_read(struct volume_group *vg, unsigned precommitted)
 	}
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
+		memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
 
-		if (!(info = lvmcache_info_from_pvid(pvid_s, pvl->pv->dev, 0))) {
+		if (!(info = lvmcache_info_from_pvid(pvid, pvl->pv->dev, 0))) {
 			log_debug_cache("lvmcache_update_vg %s no info for %s %s",
-					vg->name,
-					(char *) &pvl->pv->id,
+					vg->name, pvid,
 					pvl->pv->dev ? dev_name(pvl->pv->dev) : "missing");
 			continue;
 		}
@@ -2137,23 +2148,30 @@ static struct lvmcache_info * _create_info(struct labeller *labeller, struct dev
 }
 
 struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *labeller,
-				   const char *pvid, struct device *dev, uint64_t label_sector,
-				   const char *vgname, const char *vgid, uint32_t vgstatus,
+				   const char *pvid_arg, struct device *dev, uint64_t label_sector,
+				   const char *vgname, const char *vgid_arg, uint32_t vgstatus,
 				   int *is_duplicate)
 {
-	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
-	char uuid[64] __attribute__((aligned(8)));
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char pvid_dashed[64] __attribute__((aligned(8)));
 	struct lvmcache_vgsummary vgsummary = { 0 };
 	struct lvmcache_info *info;
 	struct lvmcache_info *info_lookup;
 	struct device_list *devl;
 	int created = 0;
 
-	(void) dm_strncpy(pvid_s, pvid, sizeof(pvid_s));
+	/* pvid_arg and vgid_arg may not be null terminated */
+	memcpy(pvid, pvid_arg, ID_LEN);
+
+	if (vgid_arg)
+		memcpy(vgid, vgid_arg, ID_LEN);
 
-	if (!id_write_format((const struct id *)&pvid_s, uuid, sizeof(uuid)))
+	if (!id_write_format((const struct id *)&pvid, pvid_dashed, sizeof(pvid_dashed)))
 		stack;
 
+	log_debug_cache("Found PVID %s on %s", pvid, dev_name(dev));
+
 	/*
 	 * Find existing info struct in _pvid_hash or create a new one.
 	 *
@@ -2161,7 +2179,7 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
 	 * devs for the duplicate case is checked below.
 	 */
 
-	info = lvmcache_info_from_pvid(pvid_s, NULL, 0);
+	info = lvmcache_info_from_pvid(pvid, NULL, 0);
 
 	if (!info)
 		info = lvmcache_info_from_pvid(dev->pvid, NULL, 0);
@@ -2180,9 +2198,10 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
 	if (!created) {
 		if (info->dev != dev) {
 			log_debug_cache("Saving initial duplicate device %s previously seen on %s with PVID %s.",
-					dev_name(dev), dev_name(info->dev), uuid);
+					dev_name(dev), dev_name(info->dev), pvid_dashed);
 
-			strncpy(dev->pvid, pvid_s, sizeof(dev->pvid));
+			memset(&dev->pvid, 0, sizeof(dev->pvid));
+			memcpy(dev->pvid, pvid, ID_LEN);
 
 			/* shouldn't happen */
 			if (dev_in_device_list(dev, &_initial_duplicates))
@@ -2209,10 +2228,10 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
 			return NULL;
 		}
 
-		if (info->dev->pvid[0] && pvid[0] && strcmp(pvid_s, info->dev->pvid)) {
+		if (info->dev->pvid[0] && pvid[0] && memcmp(pvid, info->dev->pvid, ID_LEN)) {
 			/* This happens when running pvcreate on an existing PV. */
 			log_debug_cache("Changing pvid on dev %s from %s to %s",
-					dev_name(info->dev), info->dev->pvid, pvid_s);
+					dev_name(info->dev), info->dev->pvid, pvid);
 		}
 
 		if (info->label->labeller != labeller) {
@@ -2231,30 +2250,31 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
 	 * Add or update the _pvid_hash mapping, pvid to info.
 	 */
 
-	info_lookup = dm_hash_lookup(_pvid_hash, pvid_s);
-	if ((info_lookup == info) && !strcmp(info->dev->pvid, pvid_s))
+	info_lookup = dm_hash_lookup(_pvid_hash, pvid);
+	if ((info_lookup == info) && !memcmp(info->dev->pvid, pvid, ID_LEN))
 		goto update_vginfo;
 
 	if (info->dev->pvid[0])
 		dm_hash_remove(_pvid_hash, info->dev->pvid);
 
-	strncpy(info->dev->pvid, pvid_s, sizeof(info->dev->pvid));
+	memset(info->dev->pvid, 0, sizeof(info->dev->pvid));
+	memcpy(info->dev->pvid, pvid, ID_LEN);
 
-	if (!dm_hash_insert(_pvid_hash, pvid_s, info)) {
-		log_error("Adding pvid to hash failed %s", pvid_s);
+	if (!dm_hash_insert(_pvid_hash, pvid, info)) {
+		log_error("Adding pvid to hash failed %s", pvid);
 		return NULL;
 	}
 
 update_vginfo:
 	vgsummary.vgstatus = vgstatus;
 	vgsummary.vgname = vgname;
-	if (vgid)
-		strncpy((char *)&vgsummary.vgid, vgid, sizeof(vgsummary.vgid));
+	if (vgid[0])
+		memcpy(vgsummary.vgid, vgid, ID_LEN);
 
 	if (!lvmcache_update_vgname_and_id(cmd, info, &vgsummary)) {
 		if (created) {
-			dm_hash_remove(_pvid_hash, pvid_s);
-			strcpy(info->dev->pvid, "");
+			dm_hash_remove(_pvid_hash, pvid);
+			info->dev->pvid[0] = 0;
 			free(info->label);
 			free(info);
 		}
@@ -2379,7 +2399,8 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 	pv->fmt = info->fmt;
 	pv->size = info->device_size >> SECTOR_SHIFT;
 	pv->vg_name = FMT_TEXT_ORPHAN_VG_NAME;
-	memcpy(&pv->id, &info->dev->pvid, sizeof(pv->id));
+	memset(&pv->id, 0, sizeof(pv->id));
+	memcpy(&pv->id, &info->dev->pvid, ID_LEN);
 
 	if (!pv->size) {
 		log_error("PV %s size is zero.", dev_name(info->dev));
@@ -2646,9 +2667,8 @@ int lvmcache_lookup_mda(struct lvmcache_vgsummary *vgsummary)
 			vgsummary->creation_host = vginfo->creation_host;
 			vgsummary->vgstatus = vginfo->status;
 			vgsummary->seqno = vginfo->seqno;
-			/* vginfo->vgid has 1 extra byte then vgsummary->vgid */
-			memcpy(&vgsummary->vgid, vginfo->vgid, sizeof(vgsummary->vgid));
-
+			memset(&vgsummary->vgid, 0, sizeof(vgsummary->vgid));
+			memcpy(&vgsummary->vgid, vginfo->vgid, ID_LEN);
 			return 1;
 		}
 	}
@@ -2762,12 +2782,16 @@ uint64_t lvmcache_max_metadata_size(void)
 	return _max_metadata_size;
 }
 
-int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, char *pvid)
+int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, const char *pvid_arg)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct lvmcache_info *info;
 
+	/* In case pvid_arg is not null terminated. */
+	memcpy(pvid, pvid_arg, ID_LEN);
+
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!strcmp(info->dev->pvid, pvid))
+		if (!memcmp(info->dev->pvid, pvid, ID_LEN))
 			return 1;
 	}
 	return 0;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 76429fc5b..d7e10f4f0 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -47,7 +47,7 @@ struct lvmcache_vginfo;
  */
 struct lvmcache_vgsummary {
 	const char *vgname;
-	struct id vgid;
+	char vgid[ID_LEN + 1];
 	uint64_t vgstatus;
 	char *creation_host;
 	const char *system_id;
@@ -96,9 +96,10 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname,
 					   const char *vgid);
 struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid);
 struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, struct device *dev, int valid_only);
+struct lvmcache_info *lvmcache_info_from_pv_id(const struct id *pv_id, struct device *dev, int valid_only);
 const char *lvmcache_vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgname);
-struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid, uint64_t *label_sector);
+struct device *lvmcache_device_from_pv_id(struct cmd_context *cmd, const struct id *pv_id, uint64_t *label_sector);
 const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
 const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info);
 
@@ -181,7 +182,7 @@ int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const ch
 
 bool lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
-int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, char *pvid);
+int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, const char *pvid_arg);
 
 uint64_t lvmcache_max_metadata_size(void);
 void lvmcache_save_metadata_size(uint64_t val);
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 429164062..164a3e2ba 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -867,7 +867,7 @@ struct dev_use *get_du_for_pvid(struct cmd_context *cmd, const char *pvid)
 	dm_list_iterate_items(du, &cmd->use_devices) {
 		if (!du->pvid)
 			continue;
-		if (!strcmp(du->pvid, pvid))
+		if (!memcmp(du->pvid, pvid, ID_LEN))
 			return du;
 	}
 	return NULL;
@@ -1695,7 +1695,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		/*
 		 * A good match based on pvid.
 		 */
-		if (dev->pvid[0] && !strcmp(dev->pvid, du->pvid)) {
+		if (dev->pvid[0] && !memcmp(dev->pvid, du->pvid, ID_LEN)) {
 			const char *devname = dev_name(dev);
 
 			if (strcmp(devname, du->idname)) {
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index f1590b460..fae368784 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -413,7 +413,8 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 				return 0;
 			}
 			pv->vg_name = vg->name;
-			pv->vgid = vg->id;
+			/* both are struct id */
+			memcpy(&pv->vg_id, &vg->id, sizeof(struct id));
 
 			if (!(new_pvl = dm_pool_zalloc(vg->vgmem, sizeof(*new_pvl)))) {
 				log_error("Failed to allocate PV list item for \"%s\".",
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 0441342a1..a274ab543 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1667,8 +1667,9 @@ static int _set_ext_flags(struct physical_volume *pv, struct lvmcache_info *info
 /* Only for orphans - FIXME That's not true any more */
 static int _text_pv_write(struct cmd_context *cmd, const struct format_type *fmt, struct physical_volume *pv)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct format_instance *fid = pv->fid;
-	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	struct label *label;
 	struct lvmcache_info *info;
 	struct mda_context *mdac;
@@ -1676,10 +1677,18 @@ static int _text_pv_write(struct cmd_context *cmd, const struct format_type *fmt
 	struct _write_single_mda_baton baton;
 	unsigned mda_index;
 
+	if (is_orphan_vg(pv->vg_name))
+		memcpy(vgid, pv->vg_name, ID_LEN);
+	else if (pv->vg)
+		memcpy(vgid, &pv->vg->id.uuid, ID_LEN);
+
+	memcpy(pvid, &pv->id.uuid, ID_LEN);
+
 	/* Add a new cache entry with PV info or update existing one. */
-	if (!(info = lvmcache_add(cmd, fmt->labeller, (const char *) &pv->id,
+	if (!(info = lvmcache_add(cmd, fmt->labeller, pvid,
 				  pv->dev,  pv->label_sector, pv->vg_name,
-				  is_orphan_vg(pv->vg_name) ? pv->vg_name : pv->vg ? (const char *) &pv->vg->id : NULL, 0, NULL)))
+				  vgid[0] ? vgid : NULL,
+				  0, NULL)))
 		return_0;
 
 	/* lvmcache_add() creates info and info->label structs for the dev, get info->label. */
@@ -1697,6 +1706,13 @@ static int _text_pv_write(struct cmd_context *cmd, const struct format_type *fmt
 	 * The fid_get_mda_indexed fn can handle that transparently,
 	 * just pass the right format_instance in.
 	 */
+
+	/* FIXME: why is old needed here? */
+	if (*pv->old_id.uuid)
+		memcpy(pvid, &pv->old_id.uuid, ID_LEN);
+	else
+		memcpy(pvid, &pv->id.uuid, ID_LEN);
+
 	for (mda_index = 0; mda_index < FMT_TEXT_MAX_MDAS_PER_PV; mda_index++) {
 		if (!(mda = fid_get_mda_indexed(fid, pvid, ID_LEN, mda_index)))
 			continue;
@@ -1775,7 +1791,7 @@ static int _text_pv_needs_rewrite(const struct format_type *fmt, struct physical
 	if (!pv->dev)
 		return 1;
 
-	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id, pv->dev, 0))) {
+	if (!(info = lvmcache_info_from_pv_id(&pv->id, pv->dev, 0))) {
 		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
 		return 0;
 	}
@@ -2007,8 +2023,8 @@ static int _text_pv_setup(const struct format_type *fmt,
 			  struct physical_volume *pv,
 			  struct volume_group *vg)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct format_instance *fid = pv->fid;
-	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	struct lvmcache_info *info;
 	unsigned mda_index;
 	struct metadata_area *pv_mda, *pv_mda_copy;
@@ -2016,6 +2032,11 @@ static int _text_pv_setup(const struct format_type *fmt,
 	uint64_t pe_count;
 	uint64_t size_reduction = 0;
 
+	if (*pv->old_id.uuid)
+		memcpy(pvid, &pv->old_id.uuid, ID_LEN);
+	else
+		memcpy(pvid, &pv->id.uuid, ID_LEN);
+
 	/* If PV has its own format instance, add mdas from pv->fid to vg->fid. */
 	if (pv->fid != vg->fid) {
 		for (mda_index = 0; mda_index < FMT_TEXT_MAX_MDAS_PER_PV; mda_index++) {
@@ -2181,6 +2202,7 @@ static int _add_metadata_area_to_pv(struct physical_volume *pv,
 				    uint64_t mda_size,
 				    unsigned mda_ignored)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct metadata_area *mda;
 	struct mda_context *mdac;
 	struct mda_lists *mda_lists = (struct mda_lists *) pv->fmt->private;
@@ -2215,7 +2237,9 @@ static int _add_metadata_area_to_pv(struct physical_volume *pv,
 	memset(&mdac->rlocn, 0, sizeof(mdac->rlocn));
 	mda_set_ignored(mda, mda_ignored);
 
-	fid_add_mda(pv->fid, mda, (char *) &pv->id, ID_LEN, mda_index);
+	memcpy(pvid, &pv->id.uuid, ID_LEN);
+
+	fid_add_mda(pv->fid, mda, pvid, ID_LEN, mda_index);
 
 	return 1;
 }
@@ -2231,8 +2255,8 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 				      uint64_t mda_size,
 				      unsigned mda_ignored)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct format_instance *fid = pv->fid;
-	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	uint64_t ba_size, pe_start, first_unallocated;
 	uint64_t alignment, alignment_offset;
 	uint64_t disk_size;
@@ -2246,6 +2270,11 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 	const char *limit_name;
 	int limit_applied = 0;
 
+	if (*pv->old_id.uuid)
+		memcpy(pvid, &pv->old_id.uuid, ID_LEN);
+	else
+		memcpy(pvid, &pv->id.uuid, ID_LEN);
+
 	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
 		log_error(INTERNAL_ERROR "invalid index of value %u used "
 			      "while trying to add metadata area on PV %s. "
@@ -2475,6 +2504,8 @@ bad:
 static int _remove_metadata_area_from_pv(struct physical_volume *pv,
 					 unsigned mda_index)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+
 	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
 		log_error(INTERNAL_ERROR "can't remove metadata area with "
 					 "index %u from PV %s. Metadata "
@@ -2484,8 +2515,9 @@ static int _remove_metadata_area_from_pv(struct physical_volume *pv,
 		return 0;
 	}
 
-	return fid_remove_mda(pv->fid, NULL, (const char *) &pv->id,
-			      ID_LEN, mda_index);
+	memcpy(pvid, &pv->id.uuid, ID_LEN);
+
+	return fid_remove_mda(pv->fid, NULL, pvid, ID_LEN, mda_index);
 }
 
 static int _text_pv_remove_metadata_area(const struct format_type *fmt,
@@ -2500,14 +2532,19 @@ static int _text_pv_resize(const struct format_type *fmt,
 			   struct volume_group *vg,
 			   uint64_t size)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct format_instance *fid = pv->fid;
-	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	struct metadata_area *mda;
 	struct mda_context *mdac;
 	uint64_t size_reduction;
 	uint64_t mda_size;
 	unsigned mda_ignored;
 
+	if (*pv->old_id.uuid)
+		memcpy(pvid, &pv->old_id.uuid, ID_LEN);
+	else
+		memcpy(pvid, &pv->id.uuid, ID_LEN);
+
 	/*
 	 * First, set the new size and update the cache and reset pe_count.
 	 * (pe_count must be reset otherwise it would be considered as
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 946184b4b..dacf5573e 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -219,7 +219,8 @@ static int _read_pv(struct cmd_context *cmd,
 	if (!(pv->vg_name = dm_pool_strdup(mem, vg->name)))
 		return_0;
 
-	memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
+	/* both are struct id */
+	memcpy(&pv->vg_id, &vg->id, sizeof(struct id));
 
 	if (!_read_flag_config(pvn, &pv->status, PV_FLAGS)) {
 		log_error("Couldn't read status flags for physical volume.");
@@ -1302,6 +1303,7 @@ static int _read_vgsummary(const struct format_type *fmt, const struct dm_config
 	const struct dm_config_node *vgn;
 	struct dm_pool *mem = fmt->cmd->mem;
 	const char *str;
+	struct id id;
 
 	if (!dm_config_get_str(cft->root, "creation_host", &str))
 		str = "";
@@ -1322,11 +1324,13 @@ static int _read_vgsummary(const struct format_type *fmt, const struct dm_config
 
 	vgn = vgn->child;
 
-	if (!_read_id(&vgsummary->vgid, vgn, "id")) {
+	if (!_read_id(&id, vgn, "id")) {
 		log_error("Couldn't read uuid for volume group %s.", vgsummary->vgname);
 		return 0;
 	}
 
+	memcpy(vgsummary->vgid, &id, ID_LEN);
+
 	if (!_read_flag_config(vgn, &vgsummary->vgstatus, VG_FLAGS)) {
 		log_error("Couldn't find status flags for volume group %s.",
 			  vgsummary->vgname);
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7bc7a1ed3..f12171eca 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -409,6 +409,7 @@ static int _text_read(struct cmd_context *cmd, struct labeller *labeller, struct
 		      uint64_t label_sector, int *is_duplicate)
 {
 	struct lvmcache_vgsummary vgsummary;
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct lvmcache_info *info;
 	const struct format_type *fmt = labeller->fmt;
 	struct label_header *lh = (struct label_header *) label_buf;
@@ -431,6 +432,8 @@ static int _text_read(struct cmd_context *cmd, struct labeller *labeller, struct
 	 */
 	pvhdr = (struct pv_header *) ((char *) label_buf + xlate32(lh->offset_xl));
 
+	memcpy(pvid, &pvhdr->pv_uuid, ID_LEN);
+
 	/*
 	 * FIXME: stop adding the device to lvmcache initially as an orphan
 	 * (and then moving it later) and instead just add it when we know the
@@ -445,7 +448,7 @@ static int _text_read(struct cmd_context *cmd, struct labeller *labeller, struct
 	 *
 	 * Other reasons for lvmcache_add to return NULL are internal errors.
 	 */
-	if (!(info = lvmcache_add(cmd, labeller, (char *)pvhdr->pv_uuid, dev, label_sector,
+	if (!(info = lvmcache_add(cmd, labeller, pvid, dev, label_sector,
 				  FMT_TEXT_ORPHAN_VG_NAME,
 				  FMT_TEXT_ORPHAN_VG_NAME, 0, is_duplicate)))
 		return_0;
@@ -495,8 +498,9 @@ static int _text_read(struct cmd_context *cmd, struct labeller *labeller, struct
 	if (!(ext_version = xlate32(pvhdr_ext->version)))
 		goto scan_mdas;
 
-	log_debug_metadata("%s: PV header extension version " FMTu32 " found",
-			   dev_name(dev), ext_version);
+	if (ext_version != PV_HEADER_EXTENSION_VSN)
+		log_debug_metadata("Found pv_header_extension version " FMTu32 " on %s",
+				   ext_version, dev_name(dev));
 
 	/* Extension version */
 	lvmcache_set_ext_version(info, xlate32(pvhdr_ext->version));
diff --git a/lib/label/label.c b/lib/label/label.c
index ac84b6293..aeee35259 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -307,9 +307,8 @@ static struct labeller *_find_lvm_header(struct device *dev,
 
 		dm_list_iterate_items(li, &_labellers) {
 			if (li->l->ops->can_handle(li->l, (char *) lh, block_sector + sector)) {
-				log_very_verbose("%s: %s label detected at sector %llu", 
-						 dev_name(dev), li->name,
-						 (unsigned long long)(block_sector + sector));
+				log_debug("Found label at sector %llu on %s",
+					  (unsigned long long)(block_sector + sector), dev_name(dev));
 				if (found) {
 					log_error("Ignoring additional label on %s at sector %llu",
 						  dev_name(dev),
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0cbf67869..b37b91487 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -275,15 +275,17 @@ void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
 
 void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct lvmcache_info *info;
 
 	vg->pv_count--;
 	dm_list_del(&pvl->list);
 
+	memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
+
 	pvl->pv->vg = vg->fid->fmt->orphan_vg; /* orphan */
-	if ((info = lvmcache_info_from_pvid((const char *) &pvl->pv->id, pvl->pv->dev, 0)))
-		lvmcache_fid_add_mdas(info, vg->fid->fmt->orphan_vg->fid,
-				      (const char *) &pvl->pv->id, ID_LEN);
+	if ((info = lvmcache_info_from_pvid(pvid, pvl->pv->dev, 0)))
+		lvmcache_fid_add_mdas(info, vg->fid->fmt->orphan_vg->fid, pvid, ID_LEN);
 	pv_set_fid(pvl->pv, vg->fid->fmt->orphan_vg->fid);
 }
 
@@ -349,7 +351,8 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		return 0;
 	}
 
-	memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
+	/* both are struct id */
+	memcpy(&pv->vg_id, &vg->id, sizeof(struct id));
 
 	/* Units of 512-byte sectors */
 	pv->pe_size = vg->extent_size;
@@ -1662,7 +1665,7 @@ struct logical_volume *find_lv_in_vg_by_lvid(const struct volume_group *vg,
 {
 	struct lv_list *lvl;
 
-	if (memcmp(&lvid->id[0], &vg->id, sizeof(vg->id)))
+	if (memcmp(&lvid->id[0], &vg->id, ID_LEN))
 		return NULL; /* Check VG does not match */
 
 	dm_list_iterate_items(lvl, &vg->lvs)
@@ -2847,6 +2850,7 @@ static int _handle_historical_lvs(struct volume_group *vg)
 
 static void _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg)
 {
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct dm_list devs;
 	struct dm_list *mdas = NULL;
 	struct device_list *devl;
@@ -2865,12 +2869,14 @@ static void _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg)
 	 * vginfo->outdated_infos list.  Here we clear the PVs on that list.
 	 */
 
-	lvmcache_get_outdated_devs(cmd, vg->name, (const char *)&vg->id, &devs);
+	memcpy(vgid, &vg->id.uuid, ID_LEN);
+
+	lvmcache_get_outdated_devs(cmd, vg->name, vgid, &devs);
 
 	dm_list_iterate_items(devl, &devs) {
 		dev = devl->dev;
 
-		lvmcache_get_outdated_mdas(cmd, vg->name, (const char *)&vg->id, dev, &mdas);
+		lvmcache_get_outdated_mdas(cmd, vg->name, vgid, dev, &mdas);
 
 		if (mdas) {
 			dm_list_iterate_items(mda, mdas) {
@@ -2905,7 +2911,7 @@ static void _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg)
 	 * removed) but we only need to wipe pvs once, so clear the outdated
 	 * list so it won't be wiped again.
 	 */
-	lvmcache_del_outdated_devs(cmd, vg->name, (const char *)&vg->id);
+	lvmcache_del_outdated_devs(cmd, vg->name, vgid);
 }
 
 /*
@@ -2914,6 +2920,7 @@ static void _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg)
  */
 int vg_write(struct volume_group *vg)
 {
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct dm_list *mdah;
 	struct pv_list *pvl, *pvl_safe, *new_pvl;
 	struct metadata_area *mda;
@@ -2921,6 +2928,8 @@ int vg_write(struct volume_group *vg)
 	struct device *mda_dev;
 	int revert = 0, wrote = 0;
 
+	memcpy(vgid, &vg->id.uuid, ID_LEN);
+
 	if (vg_is_shared(vg)) {
 		dm_list_iterate_items(lvl, &vg->lvs) {
 			if (lvl->lv->lock_args && !strcmp(lvl->lv->lock_args, "pending")) {
@@ -3031,7 +3040,7 @@ int vg_write(struct volume_group *vg)
 		 * dev, and then it's later changed to not ignored, and
 		 * we see the old metadata.
 		 */
-		if (lvmcache_has_old_metadata(vg->cmd, vg->name, (const char *)&vg->id, mda_dev)) {
+		if (lvmcache_has_old_metadata(vg->cmd, vg->name, vgid, mda_dev)) {
 			log_warn("WARNING: updating old metadata to %u on %s for VG %s.",
 				 vg->seqno, dev_name(mda_dev), vg->name);
 		}
@@ -3438,15 +3447,14 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
 {
 	struct dm_pool *mem;
-	char vgid[ID_LEN + 1];
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct pv_list *pvl;
 	struct lv_list *lvl;
 	struct dm_list *list;
 	struct device_list *dl;
 	int found_inconsistent = 0;
 
-	strncpy(vgid, (const char *) vg->id.uuid, sizeof(vgid));
-	vgid[ID_LEN] = '\0';
+	memcpy(vgid, &vg->id.uuid, ID_LEN);
 
 	/* Mark all PVs in VG as used. */
 	dm_list_iterate_items(pvl, &vg->pvs) {
@@ -3505,6 +3513,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct volume_group *vg,
 					struct lvmcache_info *info)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct physical_volume *pv;
 	struct device *dev = lvmcache_device(info);
 
@@ -3528,7 +3537,9 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 	if (!alloc_pv_segment_whole_pv(vg->vgmem, pv))
 		goto_bad;
 
-	lvmcache_fid_add_mdas(info, vg->fid, (const char *) &pv->id, ID_LEN);
+	memcpy(pvid, &pv->id.uuid, ID_LEN);
+
+	lvmcache_fid_add_mdas(info, vg->fid, pvid, ID_LEN);
 	pv_set_fid(pv, vg->fid);
 	return pv;
 bad:
@@ -3551,7 +3562,7 @@ static void _set_pv_device(struct format_instance *fid,
 	struct device *dev;
 	uint64_t size;
 
-	if (!(dev = lvmcache_device_from_pvid(cmd, &pv->id, &pv->label_sector))) {
+	if (!(dev = lvmcache_device_from_pv_id(cmd, &pv->id, &pv->label_sector))) {
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
 			buffer[0] = '\0';
 
@@ -4447,6 +4458,7 @@ int vg_is_foreign(struct volume_group *vg)
 
 void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
 {
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct dm_list bad_mda_list;
 	struct mda_list *mdal;
 	struct metadata_area *mda;
@@ -4454,7 +4466,9 @@ void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
 
 	dm_list_init(&bad_mda_list);
 
-	lvmcache_get_bad_mdas(cmd, vg->name, (const char *)&vg->id, &bad_mda_list);
+	memcpy(vgid, &vg->id.uuid, ID_LEN);
+
+	lvmcache_get_bad_mdas(cmd, vg->name, vgid, &bad_mda_list);
 
 	dm_list_iterate_items(mdal, &bad_mda_list) {
 		mda = mdal->mda;
@@ -4883,7 +4897,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 */
 	if (found_md_component) {
 		dm_list_iterate_items(pvl, &vg_ret->pvs) {
-			if (!(dev = lvmcache_device_from_pvid(cmd, &pvl->pv->id, NULL)))
+			if (!(dev = lvmcache_device_from_pv_id(cmd, &pvl->pv->id, NULL)))
 				continue;
 
 			/* dev_is_md_component set this flag if it was found */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index dfd576e3c..3b3145d2c 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -531,7 +531,7 @@ int update_pool_metadata_min_max(struct cmd_context *cmd,
  */
 struct id pv_id(const struct physical_volume *pv);
 const struct format_type *pv_format_type(const struct physical_volume *pv);
-struct id pv_vgid(const struct physical_volume *pv);
+struct id pv_vg_id(const struct physical_volume *pv);
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl);
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 855d52594..19de67610 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -71,9 +71,9 @@ const struct format_type *pv_format_type(const struct physical_volume *pv)
 	return pv_field(pv, fmt);
 }
 
-struct id pv_vgid(const struct physical_volume *pv)
+struct id pv_vg_id(const struct physical_volume *pv)
 {
-	return pv_field(pv, vgid);
+	return pv_field(pv, vg_id);
 }
 
 struct device *pv_dev(const struct physical_volume *pv)
@@ -171,7 +171,7 @@ uint32_t pv_mda_count(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info;
 
-	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, pv->dev, 0);
+	info = lvmcache_info_from_pv_id(&pv->id, pv->dev, 0);
 
 	return info ? lvmcache_mda_count(info) : UINT64_C(0);
 }
@@ -191,7 +191,7 @@ uint32_t pv_mda_used_count(const struct physical_volume *pv)
 	struct lvmcache_info *info;
 	uint32_t used_count=0;
 
-	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, pv->dev, 0);
+	info = lvmcache_info_from_pv_id(&pv->id, pv->dev, 0);
 	if (!info)
 		return 0;
 	lvmcache_foreach_mda(info, _count_unignored, &used_count);
@@ -236,7 +236,7 @@ int is_used_pv(const struct physical_volume *pv)
 	if (!(pv->fmt->features & FMT_PV_FLAGS))
 		return 0;
 
-	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id, pv->dev, 0))) {
+	if (!(info = lvmcache_info_from_pv_id(&pv->id, pv->dev, 0))) {
 		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
 		return -1;
 	}
@@ -279,10 +279,9 @@ uint64_t pv_mda_size(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info;
 	uint64_t min_mda_size = 0;
-	const char *pvid = (const char *)(&pv->id.uuid);
 
 	/* PVs could have 2 mdas of different sizes (rounding effect) */
-	if ((info = lvmcache_info_from_pvid(pvid, pv->dev, 0)))
+	if ((info = lvmcache_info_from_pv_id(&pv->id, pv->dev, 0)))
 		min_mda_size = lvmcache_smallest_mda_size(info);
 	return min_mda_size;
 }
@@ -317,10 +316,9 @@ uint64_t lvmcache_info_mda_free(struct lvmcache_info *info)
 
 uint64_t pv_mda_free(const struct physical_volume *pv)
 {
-	const char *pvid = (const char *)&pv->id.uuid;
 	struct lvmcache_info *info;
 
-	if ((info = lvmcache_info_from_pvid(pvid, pv->dev, 0)))
+	if ((info = lvmcache_info_from_pv_id(&pv->id, pv->dev, 0)))
 		return lvmcache_info_mda_free(info);
 
 	return 0;
@@ -373,7 +371,7 @@ unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignor
 	struct _pv_mda_set_ignored_baton baton;
 	struct metadata_area *mda;
 
-	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, pv->dev, 0)))
+	if (!(info = lvmcache_info_from_pv_id(&pv->id, pv->dev, 0)))
 		return_0;
 
 	baton.mda_ignored = mda_ignored;
@@ -418,8 +416,7 @@ unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignor
 
 struct label *pv_label(const struct physical_volume *pv)
 {
-	struct lvmcache_info *info =
-		lvmcache_info_from_pvid((const char *)&pv->id.uuid, pv->dev, 0);
+	struct lvmcache_info *info = lvmcache_info_from_pv_id(&pv->id, pv->dev, 0);
 
 	if (info)
 		return lvmcache_get_label(info);
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 95525a41a..ecea266fe 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -33,11 +33,11 @@ struct physical_volume {
 	struct format_instance *fid;
 
 	/*
-	 * vg_name and vgid are used before the parent VG struct exists.
+	 * vg_name and vg_id are used before the parent VG struct exists.
 	 * FIXME: Investigate removal/substitution with 'vg' fields.
 	 */
 	const char *vg_name;
-	struct id vgid;
+	struct id vg_id; /* variables named "vgid" are char ID_LEN+1 */
 
 	/*
 	 * 'vg' is set and maintained when the PV belongs to a 'pvs'
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 8b4a0643d..c1d3a3783 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -25,6 +25,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct pvchange_params *params = (struct pvchange_params *) handle->custom_handle;
 	const char *pv_name = pv_dev_name(pv);
+	char pvid[ID_LEN + 1]  __attribute__((aligned(8))) = { 0 };
 	char uuid[64] __attribute__((aligned(8)));
 	struct dev_use *du = NULL;
 	unsigned done = 0;
@@ -187,8 +188,9 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (du) {
+		memcpy(pvid, &pv->id.uuid, ID_LEN);
 		free(du->pvid);
-		if (!(du->pvid = strndup((char *)&pv->id, ID_LEN)))
+		if (!(du->pvid = strdup(pvid)))
 			log_error("Failed to set pvid for devices file.");
 		if (!device_ids_write(cmd))
 			log_warn("Failed to update devices file.");
diff --git a/tools/pvck.c b/tools/pvck.c
index 4aab21cee..49bcb5fd3 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -40,7 +40,7 @@ struct settings {
 	uint64_t device_size;      /* bytes */
 	uint64_t data_offset;      /* bytes, start of data (pe_start) */
 	uint32_t seqno;
-	struct id pvid;
+	struct id pv_id;
 
 	int mda_num;               /* 1 or 2 for first or second mda */
 	char *backup_file;
@@ -1820,10 +1820,10 @@ static int _get_one_setting(struct cmd_context *cmd, struct settings *set, char
 
 	if (!strncmp(key, "pv_uuid", strlen("pv_uuid"))) {
 		if (strchr(val, '-') && (strlen(val) == 32)) {
-			memcpy(&set->pvid, val, 32);
+			memcpy(&set->pv_id, val, 32);
 			set->pvid_set = 1;
 			return 1;
-		} else if (id_read_format_try(&set->pvid, val)) {
+		} else if (id_read_format_try(&set->pv_id, val)) {
 			set->pvid_set = 1;
 			return 1;
 		} else {
@@ -1971,19 +1971,15 @@ static int _get_pv_info_from_metadata(struct cmd_context *cmd, struct settings *
 				     uint64_t *device_size_sectors,
 				     uint64_t *pe_start_sectors)
 {
-	int8_t pvid_cur[ID_LEN+1];  /* found in existing pv_header */
-	int8_t pvid_set[ID_LEN+1];  /* set by user in --settings */
-	int8_t pvid_use[ID_LEN+1];  /* the pvid chosen to use */
-	int pvid_cur_valid = 0;     /* pvid_cur is valid */
-	int pvid_use_valid = 0;     /* pvid_use is valid */
+	char pvid_cur[ID_LEN + 1] = { 0 };  /* found in existing pv_header */
+	char pvid_set[ID_LEN + 1] = { 0 };  /* set by user in --settings */
+	char pvid_use[ID_LEN + 1] = { 0 };  /* the pvid chosen to use */
+	int pvid_cur_valid = 0;             /* pvid_cur is valid */
+	int pvid_use_valid = 0;             /* pvid_use is valid */
 	struct dm_config_tree *cft = NULL;
 	struct volume_group *vg = NULL;
 	struct pv_list *pvl;
 
-	memset(pvid_cur, 0, sizeof(pvid_cur));
-	memset(pvid_set, 0, sizeof(pvid_set));
-	memset(pvid_use, 0, sizeof(pvid_use));
-
 	/*
 	 * Check if there's a valid existing PV UUID at the expected location.
 	 */
@@ -1996,14 +1992,14 @@ static int _get_pv_info_from_metadata(struct cmd_context *cmd, struct settings *
 	}
 
 	if (set->pvid_set) {
-		memcpy(&pvid_set, &set->pvid, ID_LEN);
+		memcpy(&pvid_set, &set->pv_id, ID_LEN);
 		memcpy(&pvid_use, &pvid_set, ID_LEN);
 		pvid_use_valid = 1;
 	}
 
 	if (pvid_cur_valid && set->pvid_set && memcmp(&pvid_cur, &pvid_set, ID_LEN)) {
 		log_warn("WARNING: existing PV UUID %s does not match pv_uuid setting %s.",
-			 (char *)&pvid_cur, (char *)&pvid_set);
+			 pvid_cur, pvid_set);
 
 		memcpy(&pvid_use, &pvid_set, ID_LEN);
 		pvid_use_valid = 1;
@@ -2041,7 +2037,7 @@ static int _get_pv_info_from_metadata(struct cmd_context *cmd, struct settings *
 		}
 	} else {
 		dm_list_iterate_items(pvl, &vg->pvs) {
-			if (id_equal(&pvl->pv->id, (struct id *)&pvid_use))
+			if (!memcmp(&pvl->pv->id.uuid, &pvid_use, ID_LEN))
 				goto copy_pv;
 		}
 	}
@@ -2055,9 +2051,9 @@ static int _get_pv_info_from_metadata(struct cmd_context *cmd, struct settings *
 	 * . the metadata has no PV with a device name hint matching this device
 	 */
 	if (set->pvid_set)
-		log_error("PV UUID %s not found in metadata file.", (char *)&pvid_set);
+		log_error("PV UUID %s not found in metadata file.", pvid_set);
 	else if (pvid_cur_valid)
-		log_error("PV UUID %s in existing pv_header not found in metadata file.", (char *)&pvid_cur);
+		log_error("PV UUID %s in existing pv_header not found in metadata file.", pvid_cur);
 	else if (!pvid_use_valid)
 		log_error("PV name %s not found in metadata file.", dev_name(dev));
 
@@ -2216,7 +2212,7 @@ static int _repair_pv_header(struct cmd_context *cmd, const char *repair,
 			     uint64_t labelsector, struct device *dev)
 {
 	char head_buf[512];
-	int8_t pvid[ID_LEN+1];
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct device *dev_with_pvid = NULL;
 	struct label_header *lh;
 	struct pv_header *pvh;
@@ -2234,8 +2230,6 @@ static int _repair_pv_header(struct cmd_context *cmd, const char *repair,
 	int found_label = 0;
 	int di;
 
-	memset(&pvid, 0, ID_LEN+1);
-
 	lh_offset = labelsector * 512; /* from start of disk */
 
 	if (!dev_get_size(dev, &get_size_sectors))
@@ -2346,7 +2340,7 @@ static int _repair_pv_header(struct cmd_context *cmd, const char *repair,
 	if (set->device_size_set && set->pvid_set && set->data_offset_set && !mf->filename) {
 		device_size = set->device_size;
 		pe_start_sectors = set->data_offset >> SECTOR_SHIFT;
-		memcpy(&pvid, &set->pvid, ID_LEN);
+		memcpy(pvid, &set->pv_id, ID_LEN);
 
 		if (get_size && (get_size != device_size)) {
 			log_warn("WARNING: device_size setting %llu bytes does not match device size %llu bytes.",
@@ -2378,7 +2372,7 @@ static int _repair_pv_header(struct cmd_context *cmd, const char *repair,
 	 * dev_size and pe_start from the metadata to use in the pv_header.
 	 */
 	if (!_get_pv_info_from_metadata(cmd, set, dev, pvh, found_label,
-					mf->text_buf, mf->text_size, (char *)&pvid,
+					mf->text_buf, mf->text_size, pvid,
 					&device_size_sectors, &pe_start_sectors))
 		goto fail;
 
@@ -2392,13 +2386,13 @@ static int _repair_pv_header(struct cmd_context *cmd, const char *repair,
 	 * Read all devs to verify the pvid that will be written does not exist
 	 * on another device.
 	 */
-	if (!label_scan_for_pvid(cmd, (char *)&pvid, &dev_with_pvid)) {
+	if (!label_scan_for_pvid(cmd, pvid, &dev_with_pvid)) {
 		log_error("Failed to scan devices to check PV UUID.");
 		goto fail;
 	}
 
 	if (dev_with_pvid && (dev_with_pvid != dev)) {
-		log_error("Cannot use PV UUID %s which exists on %s", (char *)&pvid, dev_name(dev_with_pvid));
+		log_error("Cannot use PV UUID %s which exists on %s", pvid, dev_name(dev_with_pvid));
 		goto fail;
 	}
 
@@ -2466,7 +2460,7 @@ static int _repair_pv_header(struct cmd_context *cmd, const char *repair,
 	 */
 
 	log_print("Writing label_header.crc 0x%08x pv_header uuid %s device_size %llu",
-		  head_crc, (char *)&pvid, (unsigned long long)device_size);
+		  head_crc, pvid, (unsigned long long)device_size);
 
 	log_print("Writing data_offset %llu mda1_offset %llu mda1_size %llu mda2_offset %llu mda2_size %llu",
 		  (unsigned long long)data_offset,
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 229989051..d24ee5724 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -517,7 +517,7 @@ static int _lookup_file_contains_pvid(FILE *fp, char *pvid)
 static void _lookup_file_count_pvid_files(FILE *fp, const char *vgname, int *pvs_online, int *pvs_offline)
 {
 	char line[64];
-	char pvid[ID_LEN+1] = { 0 };
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 
 	log_debug("checking all pvid files using lookup file for %s", vgname);
 
@@ -695,13 +695,15 @@ do_lookup:
 
 static void _count_pvid_files(struct volume_group *vg, int *pvs_online, int *pvs_offline)
 {
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct pv_list *pvl;
 
 	*pvs_online = 0;
 	*pvs_offline = 0;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (_online_pvid_file_exists((const char *)&pvl->pv->id.uuid))
+		memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
+		if (_online_pvid_file_exists(pvid))
 			(*pvs_online)++;
 		else
 			(*pvs_offline)++;
@@ -793,12 +795,12 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 {
 	char path[PATH_MAX];
 	char file_vgname[NAME_LEN];
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	char uuidstr[64] __attribute__((aligned(8)));
 	struct pv_list *pvl;
 	struct device_list *devl;
 	struct device *dev;
 	struct volume_group *vg;
-	const char *pvid;
 	const char *name1, *name2;
 	dev_t devno;
 	int file_major = 0, file_minor = 0;
@@ -814,7 +816,7 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 		goto_bad;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		pvid = (const char *)&pvl->pv->id.uuid;
+		memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
 
 		memset(path, 0, sizeof(path));
 		snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, pvid);
diff --git a/tools/toollib.c b/tools/toollib.c
index 338551015..6d61f49e6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3845,7 +3845,7 @@ static int _get_arg_devices(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 
 	dm_list_iterate_items(sl, arg_pvnames) {
-		if (!(dil = dm_pool_alloc(cmd->mem, sizeof(*dil)))) {
+		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil)))) {
 			log_error("device_id_list alloc failed.");
 			return ECMD_FAILED;
 		}
@@ -3854,7 +3854,7 @@ static int _get_arg_devices(struct cmd_context *cmd,
 			log_error("Cannot use %s: %s", sl->str, devname_error_reason(sl->str));
 			ret_max = EINIT_FAILED;
 		} else {
-			strncpy(dil->pvid, dil->dev->pvid, ID_LEN);
+			memcpy(dil->pvid, dil->dev->pvid, ID_LEN);
 			dm_list_add(arg_devices, &dil->list);
 		}
 	}
@@ -3883,12 +3883,12 @@ static int _get_all_devices(struct cmd_context *cmd,
 			if (!(dev = dev_cache_get(cmd, hint->name, NULL)))
 				continue;
 
-			if (!(dil = dm_pool_alloc(cmd->mem, sizeof(*dil)))) {
+			if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil)))) {
 				log_error("device_id_list alloc failed.");
 				return ECMD_FAILED;
 			}
 
-			strncpy(dil->pvid, hint->pvid, ID_LEN);
+			memcpy(dil->pvid, hint->pvid, ID_LEN);
 			dil->dev = dev;
 			dm_list_add(all_devices, &dil->list);
 		}
@@ -3903,12 +3903,12 @@ static int _get_all_devices(struct cmd_context *cmd,
 	}
 
 	while ((dev = dev_iter_get(cmd, iter))) {
-		if (!(dil = dm_pool_alloc(cmd->mem, sizeof(*dil)))) {
+		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil)))) {
 			log_error("device_id_list alloc failed.");
 			goto out;
 		}
 
-		strncpy(dil->pvid, dev->pvid, ID_LEN);
+		memcpy(dil->pvid, dev->pvid, ID_LEN);
 		dil->dev = dev;
 		dm_list_add(all_devices, &dil->list);
 	}
@@ -4105,6 +4105,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			      process_single_pv_fn_t process_single_pv)
 {
 	log_report_t saved_log_report_state = log_get_report_state();
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	char pv_uuid[64] __attribute__((aligned(8)));
 	char vg_uuid[64] __attribute__((aligned(8)));
 	int handle_supplied = handle != NULL;
@@ -4229,8 +4230,10 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		log_set_report_object_name_and_id(NULL, NULL);
 	}
 
-	if (!is_orphan_vg(vg->name))
-		lvmcache_get_outdated_devs(cmd, vg->name, (const char *)&vg->id, &outdated_devs);
+	if (!is_orphan_vg(vg->name)) {
+		memcpy(vgid, &vg->id, ID_LEN);
+		lvmcache_get_outdated_devs(cmd, vg->name, vgid, &outdated_devs);
+	}
 	dm_list_iterate_items(devl, &outdated_devs)
 		_device_list_remove(all_devices, devl->dev);
 
@@ -5239,6 +5242,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	struct pv_list *pvl;
 	struct pv_list *vgpvl;
 	struct device_list *devl;
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	const char *pv_name;
 	unsigned int physical_block_size, logical_block_size;
 	unsigned int prev_pbs = 0, prev_lbs = 0;
@@ -5411,7 +5415,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 */
 	if (!pp->is_remove && pp->uuid_str) {
 		struct device *dev;
-		if ((dev = lvmcache_device_from_pvid(cmd, &pp->pva.id, NULL))) {
+		if ((dev = lvmcache_device_from_pv_id(cmd, &pp->pva.id, NULL))) {
 			dm_list_iterate_items_safe(pd, pd2, &pp->arg_devices) {
 				if (pd->dev != dev) {
 					log_error("UUID %s already in use on \"%s\".", pp->uuid_str, dev_name(dev));
@@ -5669,7 +5673,8 @@ do_command:
 				dm_list_add(&pp->pvs, &pvl->list);
 
 				/* allow deviceidtype_ARG/deviceid_ARG ? */
-				device_id_add(cmd, pd->dev, (const char *)&pvl->pv->id.uuid, NULL, NULL);
+				memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
+				device_id_add(cmd, pd->dev, pvid, NULL, NULL);
 
 			} else {
 				log_error("Failed to find PV %s", pd->name);
@@ -5708,7 +5713,8 @@ do_command:
 		}
 
 		/* allow deviceidtype_ARG/deviceid_ARG ? */
-		device_id_add(cmd, pd->dev, (const char *)&pv->id.uuid, NULL, NULL);
+		memcpy(pvid, &pv->id.uuid, ID_LEN);
+		device_id_add(cmd, pd->dev, pvid, NULL, NULL);
 
 		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
 			    " available sectors.", pv_name, pv_size(pv));
diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
index 1cf7ad31a..3f315f98f 100644
--- a/tools/vgimportdevices.c
+++ b/tools/vgimportdevices.c
@@ -26,6 +26,7 @@ static int _vgimportdevices_single(struct cmd_context *cmd,
 				   struct processing_handle *handle)
 {
 	struct vgimportdevices_params *vp = (struct vgimportdevices_params *) handle->custom_handle;
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 	int update_vg = 1;
@@ -34,8 +35,9 @@ static int _vgimportdevices_single(struct cmd_context *cmd,
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (is_missing_pv(pvl->pv) || !pvl->pv->dev) {
-			log_error("Not importing devices for VG %s with missing PV %32s.",
-				 vg->name, (const char *)&pvl->pv->id.uuid);
+			memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
+			log_error("Not importing devices for VG %s with missing PV %s.",
+				 vg->name, pvid);
 			goto bad;
 		}
 	}
@@ -58,7 +60,8 @@ static int _vgimportdevices_single(struct cmd_context *cmd,
 		if (!idtypestr && pv->device_id_type)
 			idtypestr = pv->device_id_type;
 
-		device_id_add(cmd, pv->dev, (const char *)&pvl->pv->id.uuid, idtypestr, NULL);
+		memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
+		device_id_add(cmd, pv->dev, pvid, idtypestr, NULL);
 		vp->added_devices++;
 
 		/* We could skip update if the device_id has not changed. */
diff --git a/tools/vgrename.c b/tools/vgrename.c
index d627bd056..b87414d8b 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -40,6 +40,7 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 	struct vgrename_params *vp = (struct vgrename_params *) handle->custom_handle;
 	char old_path[PATH_MAX];
 	char new_path[PATH_MAX];
+	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	struct id id;
 	const char *name;
 	char *dev_dir;
@@ -69,10 +70,13 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 	}
 
-	if (id_read_format_try(&id, vp->vg_name_new) &&
-	    (name = lvmcache_vgname_from_vgid(cmd->mem, (const char *)&id))) {
-		log_error("New VG name \"%s\" matches the UUID of existing VG %s", vp->vg_name_new, name);
-		return ECMD_FAILED;
+	if (id_read_format_try(&id, vp->vg_name_new)) {
+		memcpy(vgid, &id, ID_LEN);
+
+		if ((name = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
+			log_error("New VG name \"%s\" matches the UUID of existing VG %s", vp->vg_name_new, name);
+			return ECMD_FAILED;
+		}
 	}
 
 	/*


