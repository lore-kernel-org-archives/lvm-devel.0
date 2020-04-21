From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 Apr 2020 19:51:06 +0000 (GMT)
Subject: master - lvmcache: rework handling of VGs with duplicate vgnames
Message-ID: <20200421195106.D0FCD384B0C1@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d79afd408446e3eb922d16954ae630a7af995e66
Commit:        d79afd408446e3eb922d16954ae630a7af995e66
Parent:        cc4051eec051aef8912279a598c2cb491e68b508
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 28 11:47:37 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 21 14:40:34 2020 -0500

lvmcache: rework handling of VGs with duplicate vgnames

The previous method of managing duplicate vgnames prevented
vgreduce from working if a foreign vg with the same name
existed.
---
 lib/cache/lvmcache.c                         | 499 ++++++++++----------
 lib/cache/lvmcache.h                         |   3 +-
 lib/commands/toolcontext.c                   |   2 +-
 lib/metadata/metadata.c                      |  51 ++-
 test/shell/duplicate-vgnames.sh              | 660 +++++++++++++++++++++++++++
 test/shell/duplicate-vgrename.sh             | 319 +++++++++++++
 test/shell/process-each-duplicate-vgnames.sh |  55 ---
 tools/toollib.c                              |   2 -
 8 files changed, 1264 insertions(+), 327 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f7af4c28d..bcb893346 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -49,7 +49,7 @@ struct lvmcache_info {
 
 /* One per VG */
 struct lvmcache_vginfo {
-	struct dm_list list;	/* Join these vginfos together */
+	struct dm_list list;	 /* _vginfos */
 	struct dm_list infos;	/* List head for lvmcache_infos */
 	struct dm_list outdated_infos; /* vg_read moves info from infos to outdated_infos */
 	struct dm_list pvsummaries; /* pv_list taken directly from vgsummary */
@@ -58,7 +58,6 @@ struct lvmcache_vginfo {
 	uint32_t status;
 	char vgid[ID_LEN + 1];
 	char _padding[7];
-	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
 	char *system_id;
 	char *lock_type;
@@ -66,8 +65,16 @@ struct lvmcache_vginfo {
 	size_t mda_size;
 	int seqno;
 	bool scan_summary_mismatch; /* vgsummary from devs had mismatching seqno or checksum */
+	bool has_duplicate_local_vgname;   /* this local vg and another local vg have same name */
+	bool has_duplicate_foreign_vgname; /* this foreign vg and another foreign vg have same name */
 };
 
+/*
+ * Each VG found during scan gets a vginfo struct.
+ * Each vginfo is in _vginfos and _vgid_hash, and
+ * _vgname_hash (unless disabled due to duplicate vgnames).
+ */
+
 static struct dm_hash_table *_pvid_hash = NULL;
 static struct dm_hash_table *_vgid_hash = NULL;
 static struct dm_hash_table *_vgname_hash = NULL;
@@ -262,16 +269,6 @@ void lvmcache_get_mdas(struct cmd_context *cmd,
 	}
 }
 
-static void _vginfo_attach_info(struct lvmcache_vginfo *vginfo,
-				struct lvmcache_info *info)
-{
-	if (!vginfo)
-		return;
-
-	info->vginfo = vginfo;
-	dm_list_add(&vginfo->infos, &info->list);
-}
-
 static void _vginfo_detach_info(struct lvmcache_info *info)
 {
 	if (!dm_list_empty(&info->list)) {
@@ -282,57 +279,80 @@ static void _vginfo_detach_info(struct lvmcache_info *info)
 	info->vginfo = NULL;
 }
 
-/* If vgid supplied, require a match. */
-struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname, const char *vgid)
+static struct lvmcache_vginfo *_search_vginfos_list(const char *vgname, const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
 
-	if (!vgname)
-		return lvmcache_vginfo_from_vgid(vgid);
-
-	if (!_vgname_hash) {
-		log_debug_cache(INTERNAL_ERROR "Internal lvmcache is no yet initialized.");
-		return NULL;
-	}
-
-	if (!(vginfo = dm_hash_lookup(_vgname_hash, vgname))) {
-		log_debug_cache("lvmcache has no info for vgname \"%s\"%s" FMTVGID ".",
-				vgname, (vgid) ? " with VGID " : "", (vgid) ? : "");
-		return NULL;
-	}
-
-	if (vgid)
-		do
-			if (!strncmp(vgid, vginfo->vgid, ID_LEN))
+	if (vgid) {
+		dm_list_iterate_items(vginfo, &_vginfos) {
+			if (!strcmp(vgid, vginfo->vgid))
 				return vginfo;
-		while ((vginfo = vginfo->next));
-
-	if  (!vginfo)
-		log_debug_cache("lvmcache has not found vgname \"%s\"%s" FMTVGID ".",
-				vgname, (vgid) ? " with VGID " : "", (vgid) ? : "");
-
-	return vginfo;
+		}
+	} else {
+		dm_list_iterate_items(vginfo, &_vginfos) {
+			if (!strcmp(vgname, vginfo->vgname))
+				return vginfo;
+		}
+	}
+	return NULL;
 }
 
-struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid)
+static struct lvmcache_vginfo *_vginfo_lookup(const char *vgname, const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
 	char id[ID_LEN + 1] __attribute__((aligned(8)));
 
-	if (!_vgid_hash || !vgid) {
-		log_debug_cache(INTERNAL_ERROR "Internal cache cannot lookup vgid.");
-		return NULL;
+	if (vgid) {
+		/* vgid not necessarily NULL-terminated */
+		(void) dm_strncpy(id, vgid, sizeof(id));
+
+		if ((vginfo = dm_hash_lookup(_vgid_hash, id))) {
+			if (vgname && strcmp(vginfo->vgname, vgname)) {
+				/* should never happen */
+				log_error(INTERNAL_ERROR "vginfo_lookup vgid %s has two names %s %s",
+					  id, vginfo->vgname, vgname);
+				return NULL;
+			}
+			return vginfo;
+		} else {
+			/* lookup by vgid that doesn't exist */
+			return NULL;
+		}
 	}
 
-	/* vgid not necessarily NULL-terminated */
-	(void) dm_strncpy(id, vgid, sizeof(id));
+	if (vgname && !_found_duplicate_vgnames) {
+		if ((vginfo = dm_hash_lookup(_vgname_hash, vgname))) {
+			if (vginfo->has_duplicate_local_vgname) {
+				/* should never happen, found_duplicate_vgnames should be set */
+				log_error(INTERNAL_ERROR "vginfo_lookup %s %s has_duplicate_local_vgname", vgname, vgid);
+				return NULL;
+			}
+			return vginfo;
+		}
+	}
 
-	if (!(vginfo = dm_hash_lookup(_vgid_hash, id))) {
-		log_debug_cache("lvmcache has no info for vgid \"%s\"", id);
-		return NULL;
+	if (vgname && _found_duplicate_vgnames) {
+		if ((vginfo = _search_vginfos_list(vgname, vgid))) {
+			if (vginfo->has_duplicate_local_vgname) {
+				log_debug("vginfo_lookup %s %s has_duplicate_local_vgname return none", vgname, vgid);
+				return NULL;
+			}
+			return vginfo;
+		}
 	}
 
-	return vginfo;
+	/* lookup by vgname that doesn't exist */
+	return NULL;
+}
+
+struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname, const char *vgid)
+{
+	return _vginfo_lookup(vgname, vgid);
+}
+
+struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid)
+{
+	return _vginfo_lookup(NULL, vgid);
 }
 
 const char *lvmcache_vgname_from_vgid(struct dm_pool *mem, const char *vgid)
@@ -353,17 +373,43 @@ const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgnam
 {
 	struct lvmcache_vginfo *vginfo;
 
-	if (!(vginfo = dm_hash_lookup(_vgname_hash, vgname)))
-		return_NULL;
+	if (_found_duplicate_vgnames) {
+		if (!(vginfo = _search_vginfos_list(vgname, NULL)))
+			return_NULL;
+	} else {
+		if (!(vginfo = dm_hash_lookup(_vgname_hash, vgname)))
+			return_NULL;
+	}
 
-	if (!vginfo->next)
-		return dm_pool_strdup(cmd->mem, vginfo->vgid);
+	if (vginfo->has_duplicate_local_vgname) {
+		/*
+		 * return NULL if there is a local VG with the same name since
+		 * we don't know which to use.
+		 */
+		return NULL;
+	}
 
-	/*
-	 * There are multiple VGs with this name to choose from.
-	 * Return an error because we don't know which VG is intended.
-	 */
-	return NULL;
+	if (vginfo->has_duplicate_foreign_vgname)
+		return NULL;
+
+	return dm_pool_strdup(cmd->mem, vginfo->vgid);
+}
+
+bool lvmcache_has_duplicate_local_vgname(const char *vgid, const char *vgname)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (_found_duplicate_vgnames) {
+		if (!(vginfo = _search_vginfos_list(vgname, vgid)))
+			return false;
+	} else {
+		if (!(vginfo = dm_hash_lookup(_vgname_hash, vgname)))
+			return false;
+	}
+
+	if (vginfo->has_duplicate_local_vgname)
+		return true;
+	return false;
 }
 
 /*
@@ -1148,49 +1194,18 @@ int lvmcache_pvid_in_unused_duplicates(const char *pvid)
 	return 0;
 }
 
-static int _free_vginfo(struct lvmcache_vginfo *vginfo)
+static void _free_vginfo(struct lvmcache_vginfo *vginfo)
 {
-	struct lvmcache_vginfo *primary_vginfo, *vginfo2;
-	int r = 1;
-
-	vginfo2 = primary_vginfo = lvmcache_vginfo_from_vgname(vginfo->vgname, NULL);
-
-	if (vginfo == primary_vginfo) {
-		dm_hash_remove(_vgname_hash, vginfo->vgname);
-		if (vginfo->next && !dm_hash_insert(_vgname_hash, vginfo->vgname,
-						    vginfo->next)) {
-			log_error("_vgname_hash re-insertion for %s failed",
-				  vginfo->vgname);
-			r = 0;
-		}
-	} else
-		while (vginfo2) {
-			if (vginfo2->next == vginfo) {
-				vginfo2->next = vginfo->next;
-				break;
-			}
-			vginfo2 = vginfo2->next;
-		}
-
-	free(vginfo->system_id);
 	free(vginfo->vgname);
+	free(vginfo->system_id);
 	free(vginfo->creation_host);
-
-	if (*vginfo->vgid && _vgid_hash &&
-	    lvmcache_vginfo_from_vgid(vginfo->vgid) == vginfo)
-		dm_hash_remove(_vgid_hash, vginfo->vgid);
-
-	dm_list_del(&vginfo->list);
-
 	free(vginfo);
-
-	return r;
 }
 
 /*
- * vginfo must be info->vginfo unless info is NULL
+ * Remove vginfo from standard lists/hashes.
  */
-static int _drop_vginfo(struct lvmcache_info *info, struct lvmcache_vginfo *vginfo)
+static void _drop_vginfo(struct lvmcache_info *info, struct lvmcache_vginfo *vginfo)
 {
 	if (info)
 		_vginfo_detach_info(info);
@@ -1198,12 +1213,16 @@ static int _drop_vginfo(struct lvmcache_info *info, struct lvmcache_vginfo *vgin
 	/* vginfo still referenced? */
 	if (!vginfo || is_orphan_vg(vginfo->vgname) ||
 	    !dm_list_empty(&vginfo->infos))
-		return 1;
+		return;
 
-	if (!_free_vginfo(vginfo))
-		return_0;
+	if (dm_hash_lookup(_vgname_hash, vginfo->vgname) == vginfo)
+		dm_hash_remove(_vgname_hash, vginfo->vgname);
 
-	return 1;
+	dm_hash_remove(_vgid_hash, vginfo->vgid);
+
+	dm_list_del(&vginfo->list); /* _vginfos list */
+
+	_free_vginfo(vginfo);
 }
 
 void lvmcache_del(struct lvmcache_info *info)
@@ -1261,180 +1280,150 @@ static int _lvmcache_update_vgid(struct lvmcache_info *info,
 	return 1;
 }
 
-static int _insert_vginfo(struct lvmcache_vginfo *new_vginfo, const char *vgid,
-			  uint32_t vgstatus, const char *creation_host,
-			  struct lvmcache_vginfo *primary_vginfo)
+static int _lvmcache_update_vgname(struct cmd_context *cmd,
+				   struct lvmcache_info *info,
+				   const char *vgname, const char *vgid,
+				   const char *system_id,
+				   const struct format_type *fmt)
 {
-	struct lvmcache_vginfo *last_vginfo = primary_vginfo;
-	char uuid_primary[64] __attribute__((aligned(8)));
-	char uuid_new[64] __attribute__((aligned(8)));
-	int use_new = 0;
-
-	/* Pre-existing VG takes precedence. Unexported VG takes precedence. */
-	if (primary_vginfo) {
-		if (!id_write_format((const struct id *)vgid, uuid_new, sizeof(uuid_new)))
-			return_0;
+	char vgid_str[64] __attribute__((aligned(8)));
+	char other_str[64] __attribute__((aligned(8)));
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_vginfo *other;
+	int vginfo_is_allowed;
+	int other_is_allowed;
 
-		if (!id_write_format((const struct id *)&primary_vginfo->vgid, uuid_primary,
-				     sizeof(uuid_primary)))
-			return_0;
+	if (!vgname || (info && info->vginfo && !strcmp(info->vginfo->vgname, vgname)))
+		return 1;
 
-		_found_duplicate_vgnames = 1;
+	if (!id_write_format((const struct id *)vgid, vgid_str, sizeof(vgid_str)))
+		stack;
 
-		/*
-		 * vginfo is kept for each VG with the same name.
-		 * They are saved with the vginfo->next list.
-		 * These checks just decide the ordering of
-		 * that list.
-		 *
-		 * FIXME: it should no longer matter what order
-		 * the vginfo's are kept in, so we can probably
-		 * remove these comparisons and reordering entirely.
-		 *
-		 * If   Primary not exported, new exported => keep
-		 * Else Primary exported, new not exported => change
-		 * Else Primary has hostname for this machine => keep
-		 * Else Primary has no hostname, new has one => change
-		 * Else New has hostname for this machine => change
-		 * Else Keep primary.
-		 */
-		if (!(primary_vginfo->status & EXPORTED_VG) &&
-		    (vgstatus & EXPORTED_VG))
-			log_verbose("Cache: Duplicate VG name %s: "
-				    "Existing %s takes precedence over "
-				    "exported %s", new_vginfo->vgname,
-				    uuid_primary, uuid_new);
-		else if ((primary_vginfo->status & EXPORTED_VG) &&
-			   !(vgstatus & EXPORTED_VG)) {
-			log_verbose("Cache: Duplicate VG name %s: "
-				    "%s takes precedence over exported %s",
-				    new_vginfo->vgname, uuid_new,
-				    uuid_primary);
-			use_new = 1;
-		} else if (primary_vginfo->creation_host &&
-			   !strcmp(primary_vginfo->creation_host,
-				   primary_vginfo->fmt->cmd->hostname))
-			log_verbose("Cache: Duplicate VG name %s: "
-				    "Existing %s (created here) takes precedence "
-				    "over %s", new_vginfo->vgname, uuid_primary,
-				    uuid_new);
-		else if (!primary_vginfo->creation_host && creation_host) {
-			log_verbose("Cache: Duplicate VG name %s: "
-				    "%s (with creation_host) takes precedence over %s",
-				    new_vginfo->vgname, uuid_new,
-				    uuid_primary);
-			use_new = 1;
-		} else if (creation_host &&
-			   !strcmp(creation_host,
-				   primary_vginfo->fmt->cmd->hostname)) {
-			log_verbose("Cache: Duplicate VG name %s: "
-				    "%s (created here) takes precedence over %s",
-				    new_vginfo->vgname, uuid_new,
-				    uuid_primary);
-			use_new = 1;
-		} else {
-			log_verbose("Cache: Duplicate VG name %s: "
-				    "Prefer existing %s vs new %s",
-				    new_vginfo->vgname, uuid_primary, uuid_new);
+	/*
+	 * Add vginfo for orphan VG
+	 */
+	if (!info) {
+		if (!(vginfo = zalloc(sizeof(*vginfo)))) {
+			log_error("lvmcache adding vg list alloc failed %s", vgname);
+			return 0;
 		}
-
-		if (!use_new) {
-			while (last_vginfo->next)
-				last_vginfo = last_vginfo->next;
-			last_vginfo->next = new_vginfo;
-			return 1;
+		if (!(vginfo->vgname = strdup(vgname))) {
+			free(vginfo);
+			log_error("lvmcache adding vg name alloc failed %s", vgname);
+			return 0;
 		}
+		dm_list_init(&vginfo->infos);
+		dm_list_init(&vginfo->outdated_infos);
+		dm_list_init(&vginfo->pvsummaries);
+		vginfo->fmt = fmt;
 
-		dm_hash_remove(_vgname_hash, primary_vginfo->vgname);
-	}
-
-	if (!dm_hash_insert(_vgname_hash, new_vginfo->vgname, new_vginfo)) {
-		log_error("cache_update: vg hash insertion failed: %s",
-		  	new_vginfo->vgname);
-		return 0;
-	}
-
-	if (primary_vginfo)
-		new_vginfo->next = primary_vginfo;
-
-	return 1;
-}
+		if (!dm_hash_insert(_vgname_hash, vgname, vginfo)) {
+			free(vginfo->vgname);
+			free(vginfo);
+			return_0;
+		}
 
-static int _lvmcache_update_vgname(struct lvmcache_info *info,
-				   const char *vgname, const char *vgid,
-				   uint32_t vgstatus, const char *creation_host,
-				   const struct format_type *fmt)
-{
-	struct lvmcache_vginfo *vginfo, *primary_vginfo;
-	char mdabuf[32];
+		if (!_lvmcache_update_vgid(NULL, vginfo, vgid)) {
+			free(vginfo->vgname);
+			free(vginfo);
+			return_0;
+		}
 
-	if (!vgname || (info && info->vginfo && !strcmp(info->vginfo->vgname, vgname)))
+		/* Ensure orphans appear last on list_iterate */
+		dm_list_add(&_vginfos, &vginfo->list);
 		return 1;
+	}
 
-	/* Remove existing vginfo entry */
-	if (info)
-		_drop_vginfo(info, info->vginfo);
+	_drop_vginfo(info, info->vginfo);
 
-	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
+	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid))) {
 		/*
 	 	 * Create a vginfo struct for this VG and put the vginfo
 	 	 * into the hash table.
 	 	 */
 
+		log_debug_cache("lvmcache adding vginfo for %s %s", vgname, vgid_str);
+
 		if (!(vginfo = zalloc(sizeof(*vginfo)))) {
-			log_error("lvmcache_update_vgname: list alloc failed");
+			log_error("lvmcache adding vg list alloc failed %s", vgname);
 			return 0;
 		}
 		if (!(vginfo->vgname = strdup(vgname))) {
 			free(vginfo);
-			log_error("cache vgname alloc failed for %s", vgname);
+			log_error("lvmcache adding vg name alloc failed %s", vgname);
 			return 0;
 		}
 		dm_list_init(&vginfo->infos);
 		dm_list_init(&vginfo->outdated_infos);
 		dm_list_init(&vginfo->pvsummaries);
 
-		/*
-		 * A different VG (different uuid) can exist with the same name.
-		 * In this case, the two VGs will have separate vginfo structs,
-		 * but the second will be linked onto the existing vginfo->next,
-		 * not in the hash.
-		 */
-		primary_vginfo = lvmcache_vginfo_from_vgname(vgname, NULL);
+		if ((other = dm_hash_lookup(_vgname_hash, vgname))) {
+			log_debug_cache("lvmcache adding vginfo found duplicate VG name %s", vgname);
 
-		if (!_insert_vginfo(vginfo, vgid, vgstatus, creation_host, primary_vginfo)) {
-			free(vginfo->vgname);
-			free(vginfo);
-			return 0;
+			/*
+			 * A different VG (different uuid) can exist with the
+			 * same name.  In this case, the two VGs will have
+			 * separate vginfo structs, but one will be in the
+			 * vgname_hash.  If both vginfos are local/accessible,
+			 * then _found_duplicate_vgnames is set which will
+			 * disable any further use of the vgname_hash.
+			 */
+
+			if (!memcmp(other->vgid, vgid, ID_LEN)) {
+				/* shouldn't happen since we looked up by vgid above */
+				log_error(INTERNAL_ERROR "lvmcache_update_vgname %s %s %s %s",
+					  vgname, vgid_str, other->vgname, other->vgid);
+				free(vginfo->vgname);
+				free(vginfo);
+				return 0;
+			}
+
+			vginfo_is_allowed = is_system_id_allowed(cmd, system_id);
+			other_is_allowed = is_system_id_allowed(cmd, other->system_id);
+
+			if (vginfo_is_allowed && other_is_allowed) {
+				if (!id_write_format((const struct id *)other->vgid, other_str, sizeof(other_str)))
+					stack;
+
+				vginfo->has_duplicate_local_vgname = 1;
+				other->has_duplicate_local_vgname = 1;
+				_found_duplicate_vgnames = 1;
+
+				log_warn("WARNING: VG name %s is used by VGs %s and %s.",
+					 vgname, vgid_str, other_str);
+				log_warn("Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.");
+			}
+
+			if (!vginfo_is_allowed && !other_is_allowed) {
+				vginfo->has_duplicate_foreign_vgname = 1;
+				other->has_duplicate_foreign_vgname = 1;
+			}
+
+			if (!other_is_allowed && vginfo_is_allowed) {
+				/* the accessible vginfo must be in vgnames_hash */
+				dm_hash_remove(_vgname_hash, vgname);
+				if (!dm_hash_insert(_vgname_hash, vgname, vginfo)) {
+					log_error("lvmcache adding vginfo to name hash failed %s", vgname);
+					return 0;
+				}
+			}
+		} else {
+			if (!dm_hash_insert(_vgname_hash, vgname, vginfo)) {
+				log_error("lvmcache adding vg to name hash failed %s", vgname);
+				free(vginfo->vgname);
+				free(vginfo);
+				return 0;
+			}
 		}
 
-		/* Ensure orphans appear last on list_iterate */
-		if (is_orphan_vg(vgname))
-			dm_list_add(&_vginfos, &vginfo->list);
-		else
-			dm_list_add_h(&_vginfos, &vginfo->list);
+		dm_list_add_h(&_vginfos, &vginfo->list);
 	}
 
-	if (info)
-		_vginfo_attach_info(vginfo, info);
-	else if (!_lvmcache_update_vgid(NULL, vginfo, vgid)) /* Orphans */
-		return_0;
-
-	/* FIXME Check consistency of list! */
 	vginfo->fmt = fmt;
+	info->vginfo = vginfo;
+	dm_list_add(&vginfo->infos, &info->list);
 
-	if (info) {
-		if (info->mdas.n)
-			sprintf(mdabuf, " with %u mda(s)", dm_list_size(&info->mdas));
-		else
-			mdabuf[0] = '\0';
-		log_debug_cache("lvmcache %s: now in VG %s%s%s%s%s.",
-				dev_name(info->dev),
-				vgname, vginfo->vgid[0] ? " (" : "",
-				vginfo->vgid[0] ? vginfo->vgid : "",
-				vginfo->vgid[0] ? ")" : "", mdabuf);
-	} else
-		log_debug_cache("lvmcache: Initialised VG %s.", vgname);
+	log_debug_cache("lvmcache %s: now in VG %s %s", dev_name(info->dev), vgname, vgid_str);
 
 	return 1;
 }
@@ -1511,9 +1500,9 @@ out:
 	return 1;
 }
 
-int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
+int lvmcache_add_orphan_vginfo(struct cmd_context *cmd, const char *vgname, struct format_type *fmt)
 {
-	return _lvmcache_update_vgname(NULL, vgname, vgname, 0, "", fmt);
+	return _lvmcache_update_vgname(cmd, NULL, vgname, vgname, "", fmt);
 }
 
 static void _lvmcache_update_pvsummaries(struct lvmcache_vginfo *vginfo, struct lvmcache_vgsummary *vgsummary)
@@ -1545,6 +1534,7 @@ int lvmcache_update_vgname_and_id(struct cmd_context *cmd, struct lvmcache_info
 		vgid = vgname;
 	}
 
+	/* FIXME: remove this, it shouldn't be needed */
 	/* If PV without mdas is already in a real VG, don't make it orphan */
 	if (is_orphan_vg(vgname) && info->vginfo &&
 	    mdas_empty_or_ignored(&info->mdas) &&
@@ -1556,7 +1546,7 @@ int lvmcache_update_vgname_and_id(struct cmd_context *cmd, struct lvmcache_info
 	 * and attaches the info struct for the dev to the vginfo.
 	 * Puts the vginfo into the vgname hash table.
 	 */
-	if (!_lvmcache_update_vgname(info, vgname, vgid, vgsummary->vgstatus, vgsummary->creation_host, info->fmt)) {
+	if (!_lvmcache_update_vgname(cmd, info, vgname, vgid, vgsummary->system_id, info->fmt)) {
 		/* shouldn't happen, internal error */
 		log_error("Failed to update VG %s info in lvmcache.", vgname);
 		return 0;
@@ -2055,7 +2045,7 @@ update_vginfo:
 	return info;
 }
 
-static void _lvmcache_destroy_entry(struct lvmcache_info *info)
+static void _lvmcache_destroy_info(struct lvmcache_info *info)
 {
 	_vginfo_detach_info(info);
 	info->dev->pvid[0] = 0;
@@ -2063,20 +2053,11 @@ static void _lvmcache_destroy_entry(struct lvmcache_info *info)
 	free(info);
 }
 
-static void _lvmcache_destroy_vgnamelist(struct lvmcache_vginfo *vginfo)
-{
-	struct lvmcache_vginfo *next;
-
-	do {
-		next = vginfo->next;
-		if (!_free_vginfo(vginfo))
-			stack;
-	} while ((vginfo = next));
-}
-
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 {
-	log_debug_cache("Dropping VG info");
+	struct lvmcache_vginfo *vginfo, *vginfo2;
+
+	log_debug_cache("Destroy lvmcache content");
 
 	if (_vgid_hash) {
 		dm_hash_destroy(_vgid_hash);
@@ -2084,20 +2065,24 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	}
 
 	if (_pvid_hash) {
-		dm_hash_iter(_pvid_hash, (dm_hash_iterate_fn) _lvmcache_destroy_entry);
+		dm_hash_iter(_pvid_hash, (dm_hash_iterate_fn) _lvmcache_destroy_info);
 		dm_hash_destroy(_pvid_hash);
 		_pvid_hash = NULL;
 	}
 
 	if (_vgname_hash) {
-		dm_hash_iter(_vgname_hash,
-			  (dm_hash_iterate_fn) _lvmcache_destroy_vgnamelist);
 		dm_hash_destroy(_vgname_hash);
 		_vgname_hash = NULL;
 	}
 
+	dm_list_iterate_items_safe(vginfo, vginfo2, &_vginfos) {
+		dm_list_del(&vginfo->list);
+		_free_vginfo(vginfo);
+	}
+
 	if (!dm_list_empty(&_vginfos))
-		log_error(INTERNAL_ERROR "_vginfos list should be empty");
+		log_error(INTERNAL_ERROR "vginfos list should be empty");
+
 	dm_list_init(&_vginfos);
 
 	/*
@@ -2109,6 +2094,8 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	 * We want the same preferred devices to be chosen each time, so save
 	 * the unpreferred devs here so that _choose_preferred_devs can use
 	 * this to make the same choice each time.
+	 *
+	 * FIXME: I don't think is is needed any more.
 	 */
 	_destroy_device_list(&_prev_unused_duplicate_devs);
 	dm_list_splice(&_prev_unused_duplicate_devs, &_unused_duplicates);
@@ -2122,7 +2109,7 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 			stack;
 
 		dm_list_iterate_items(fmt, &cmd->formats) {
-			if (!lvmcache_add_orphan_vginfo(fmt->orphan_vg_name, fmt))
+			if (!lvmcache_add_orphan_vginfo(cmd, fmt->orphan_vg_name, fmt))
 				stack;
 		}
 	}
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 3412d2ca9..6cef4d102 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -75,7 +75,7 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
                                    struct device *dev, uint64_t label_sector,
                                    const char *vgname, const char *vgid,
                                    uint32_t vgstatus, int *is_duplicate);
-int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt);
+int lvmcache_add_orphan_vginfo(struct cmd_context *cmd, const char *vgname, struct format_type *fmt);
 void lvmcache_del(struct lvmcache_info *info);
 void lvmcache_del_dev(struct device *dev);
 
@@ -169,6 +169,7 @@ int lvmcache_get_unused_duplicates(struct cmd_context *cmd, struct dm_list *head
 int vg_has_duplicate_pvs(struct volume_group *vg);
 
 int lvmcache_found_duplicate_vgnames(void);
+bool lvmcache_has_duplicate_local_vgname(const char *vgid, const char *vgname);
 
 int lvmcache_contains_lock_type_sanlock(struct cmd_context *cmd);
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 88d5b3eb0..2bd7fabd2 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1276,7 +1276,7 @@ int init_lvmcache_orphans(struct cmd_context *cmd)
 	struct format_type *fmt;
 
 	dm_list_iterate_items(fmt, &cmd->formats)
-		if (!lvmcache_add_orphan_vginfo(fmt->orphan_vg_name, fmt))
+		if (!lvmcache_add_orphan_vginfo(cmd, fmt->orphan_vg_name, fmt))
 			return_0;
 
 	return 1;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6c40cd321..b42d7a9b9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4751,18 +4751,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			lvmcache_label_rescan_vg(cmd, vgname, vgid);
 	}
 
-	/* Now determine the correct vgname if none was supplied */
-	if (!vgname && !(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
-		log_debug_metadata("Cache did not find VG name from vgid %s", vgid);
-		return NULL;
-	}
-
-	/* Determine the correct vgid if none was supplied */
-	if (!vgid && !(vgid = lvmcache_vgid_from_vgname(cmd, vgname))) {
-		log_debug_metadata("Cache did not find VG vgid from name %s", vgname);
-		return NULL;
-	}
-
 	/*
 	 * A "format instance" is an abstraction for a VG location,
 	 * i.e. where a VG's metadata exists on disk.
@@ -4999,6 +4987,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	int missing_pv_dev = 0;
 	int missing_pv_flag = 0;
 	uint32_t failure = 0;
+	int original_vgid_set = vgid ? 1 : 0;
 	int writing = (vg_read_flags & READ_FOR_UPDATE);
 	int activating = (vg_read_flags & READ_FOR_ACTIVATE);
 
@@ -5033,7 +5022,45 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		goto bad;
 	}
 
+	/* I belive this is unused, the name is always set. */
+	if (!vg_name && !(vg_name = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
+		unlock_vg(cmd, NULL, vg_name);
+		log_error("VG name not found for vgid %s", vgid);
+		failure |= FAILED_NOTFOUND;
+		goto_bad;
+	}
+
+	/*
+	 * If the command is process all vgs, process_each will get a list of vgname+vgid
+	 * pairs, and then call vg_read() for each vgname+vigd.  In this case we know
+	 * which VG to read even if there are duplicate names, and we don't fail.
+	 *
+	 * If the user has requested one VG by name, process_each passes only the vgname
+	 * to vg_read(), and we look up the vgid from lvmcache.  lvmcache finds duplicate
+	 * vgnames, doesn't know which is intended, returns a NULL vgid, and we fail.
+	 */
+
+	if (!vgid)
+		vgid = lvmcache_vgid_from_vgname(cmd, vg_name);
+
+	if (!vgid) {
+		unlock_vg(cmd, NULL, vg_name);
+		/* Some callers don't care if the VG doesn't exist and don't want an error message. */
+		if (!(vg_read_flags & READ_OK_NOTFOUND))
+			log_error("Volume group \"%s\" not found", vg_name);
+		failure |= FAILED_NOTFOUND;
+		goto_bad;
+	}
+
+	/*
+	 * vgchange -ay (no vgname arg) will activate multiple local VGs with the same
+	 * name, but if the vgs have the same lv name, activating those lvs will fail.
+	 */
+	if (activating && original_vgid_set && lvmcache_has_duplicate_local_vgname(vgid, vg_name))
+		log_warn("WARNING: activating multiple VGs with the same name is dangerous and may fail.");
+
 	if (!(vg = _vg_read(cmd, vg_name, vgid, 0, writing))) {
+		unlock_vg(cmd, NULL, vg_name);
 		/* Some callers don't care if the VG doesn't exist and don't want an error message. */
 		if (!(vg_read_flags & READ_OK_NOTFOUND))
 			log_error("Volume group \"%s\" not found.", vg_name);
diff --git a/test/shell/duplicate-vgnames.sh b/test/shell/duplicate-vgnames.sh
new file mode 100644
index 000000000..0f98f9c37
--- /dev/null
+++ b/test/shell/duplicate-vgnames.sh
@@ -0,0 +1,660 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 7
+
+# test setups:
+#    # local vgs named foo  # foreign vg named foo
+# a. 0                      1
+# b. 0                      2
+# c. 1                      1
+# d. 1                      2
+# e. 2                      0
+# f. 2                      1
+# g. 2                      2
+# h. 3                      3
+#
+# commands to run for each test setup:
+#
+# vgs
+# all cases show all local
+#
+# vgs --foreign
+# all cases show all local and foreign
+#
+# vgs foo
+# a. not found
+# b. not found
+# c. show 1 local
+# d. show 1 local
+# e-g. dup error
+#
+# vgs --foreign foo
+# a. show 1 foreign
+# b. dup error
+# c. show 1 local
+# d. show 1 local
+# e-g. dup error
+#
+# vgchange -ay
+# a. none
+# b. none
+# c. activate 1 local
+# d. activate 1 local
+# e-g. activate 2 local
+# (if both local vgs have lvs with same name the second will fail to activate)
+#
+# vgchange -ay foo
+# a. none
+# b. none
+# c. activate 1 local
+# d. activate 1 local
+# e-g. dup error
+#
+# lvcreate foo
+# a. none
+# b. none
+# c. create 1 local
+# d. create 1 local
+# e-g. dup error
+#
+# vgremove foo
+# a. none
+# b. none
+# c. remove 1 local
+# d. remove 1 local
+# e-g. dup error
+# (in a couple cases test that vgremove -S vg_uuid=N works for local vg when local dups exist)
+
+
+# a. 0 local, 1 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+
+vgs -o+uuid |tee out
+not grep $vg1 out
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+
+not vgs -o+uuid $vg1 |tee out
+not grep $vg1 out
+vgs --foreign -o+uuid $vg1 |tee out
+grep $vg1 out
+
+vgchange -ay
+lvs --foreign -o vguuid,active |tee out
+not grep active out
+vgchange -an
+
+not vgchange -ay $vg1
+lvs --foreign -o vguuid,active |tee out
+not grep active out
+vgchange -an
+
+not lvcreate -l1 -an -n $lv2 $vg1
+lvs --foreign -o vguuid,name |tee out
+grep $UUID1 out | not grep $lv2
+
+not vgremove $vg1
+vgs --foreign -o+uuid |tee out
+grep $UUID1 out
+vgremove -y -S vg_uuid=$UUID1
+vgs --foreign -o+uuid |tee out
+grep $UUID1 out
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+
+# b. 0 local, 2 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other2" $vg1
+aux enable_dev "$dev1"
+
+vgs -o+uuid |tee out
+not grep $vg1 out
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+
+not vgs -o+uuid $vg1 |tee out
+not grep $vg1 out
+not vgs --foreign -o+uuid $vg1 |tee out
+not grep $vg1 out
+
+vgchange -ay
+lvs --foreign -o vguuid,active |tee out
+not grep active out
+vgchange -an
+
+not vgchange -ay $vg1
+lvs --foreign -o vguuid,active |tee out
+not grep active out
+vgchange -an
+
+not lvcreate -l1 -an -n $lv2 $vg1
+lvs --foreign -o vguuid,name |tee out
+grep $UUID1 out | not grep $lv2
+grep $UUID2 out | not grep $lv2
+
+not vgremove $vg1
+vgs --foreign -o+uuid |tee out
+grep $UUID1 out
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+
+# c. 1 local, 1 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux enable_dev "$dev1"
+
+vgs -o+uuid |tee out
+cat out
+grep $vg1 out
+grep $UUID1 out
+not grep $UUID2 out
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+
+vgs -o+uuid $vg1 |tee out
+grep $vg1 out
+grep $UUID1 out
+not grep $UUID2 out
+vgs --foreign -o+uuid $vg1 |tee out
+grep $vg1 out
+grep $UUID1 out
+not grep $UUID2 out
+
+vgchange -ay
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | grep active
+grep $UUID2 out | not grep active
+vgchange -an
+
+vgchange -ay $vg1
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | grep active
+grep $UUID2 out | not grep active
+vgchange -an
+
+lvcreate -l1 -an -n $lv2 $vg1
+lvs --foreign -o vguuid,name |tee out
+grep $UUID1 out | grep $lv2
+grep $UUID2 out | not grep $lv2
+
+vgremove -y $vg1
+vgs -o+uuid |tee out
+not grep $UUID1 out
+vgs --foreign -o+uuid |tee out
+grep $UUID2 out
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+
+# d. 1 local, 2 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux disable_dev "$dev2"
+vgcreate $vg1 "$dev3"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID3=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other2" $vg1
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+
+vgs -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+not grep $UUID2 out
+not grep $UUID3 out
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+
+vgs -o+uuid $vg1 |tee out
+grep $vg1 out
+grep $UUID1 out
+not grep $UUID2 out
+not grep $UUID3 out
+vgs --foreign -o+uuid $vg1 |tee out
+grep $vg1 out
+grep $UUID1 out
+not grep $UUID2 out
+not grep $UUID3 out
+
+vgchange -ay
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | grep active
+grep $UUID2 out | not grep active
+grep $UUID3 out | not grep active
+vgchange -an
+
+vgchange -ay $vg1
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | grep active
+grep $UUID2 out | not grep active
+grep $UUID3 out | not grep active
+vgchange -an
+
+lvcreate -l1 -an -n $lv2 $vg1
+lvs --foreign -o vguuid,name |tee out
+grep $UUID1 out | grep $lv2
+grep $UUID2 out | not grep $lv2
+grep $UUID3 out | not grep $lv2
+
+vgremove -y $vg1
+vgs -o+uuid |tee out
+not grep $UUID1 out
+vgs --foreign -o+uuid |tee out
+grep $UUID2 out
+grep $UUID3 out
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+aux wipefs_a "$dev4"
+
+# e. 2 local, 0 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+# diff lvname to prevent clash in vgchange -ay
+lvcreate -n ${lv1}_b -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux enable_dev "$dev1"
+
+vgs -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+
+not vgs -o+uuid $vg1 |tee out
+not grep $vg1 out
+not vgs --foreign -o+uuid $vg1 |tee out
+not grep $vg1 out
+
+vgchange -ay
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | grep active
+grep $UUID2 out | grep active
+vgchange -an
+
+not vgchange -ay $vg1
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | not grep active
+grep $UUID2 out | not grep active
+vgchange -an
+
+not lvcreate -l1 -an -n $lv2 $vg1
+lvs --foreign -o vguuid,name |tee out
+grep $UUID1 out | not grep $lv2
+grep $UUID2 out | not grep $lv2
+
+not vgremove $vg1
+vgs -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+vgremove -y -S vg_uuid=$UUID1
+vgs -o+uuid |tee out
+not grep $UUID1 out
+grep $UUID2 out
+vgremove -y -S vg_uuid=$UUID2
+vgs -o+uuid |tee out
+not grep $UUID1 out
+not grep $UUID2 out
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+
+# f. 2 local, 1 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+# diff lvname to prevent clash in vgchange -ay
+lvcreate -n ${lv1}_b -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev2"
+vgcreate $vg1 "$dev3"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID3=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+
+vgs -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+not group $UUID3 out
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+
+not vgs -o+uuid $vg1 |tee out
+not grep $vg1 out
+not vgs --foreign -o+uuid $vg1 |tee out
+not grep $vg1 out
+
+vgchange -ay
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | grep active
+grep $UUID2 out | grep active
+grep $UUID3 out | not grep active
+vgchange -an
+
+not vgchange -ay $vg1
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | not grep active
+grep $UUID2 out | not grep active
+grep $UUID3 out | not grep active
+vgchange -an
+
+not lvcreate -l1 -an -n $lv2 $vg1
+lvs --foreign -o vguuid,name |tee out
+grep $UUID1 out | not grep $lv2
+grep $UUID2 out | not grep $lv2
+grep $UUID3 out | not grep $lv2
+
+not vgremove $vg1
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+vgremove -y -S vg_uuid=$UUID1
+vgs --foreign -o+uuid |tee out
+not grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+vgremove -y -S vg_uuid=$UUID2
+vgs --foreign -o+uuid |tee out
+not grep $UUID1 out
+not grep $UUID2 out
+grep $UUID3 out
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+aux wipefs_a "$dev4"
+
+# g. 2 local, 2 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+# diff lvname to prevent clash in vgchange -ay
+lvcreate -n ${lv1}_b -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev2"
+vgcreate $vg1 "$dev3"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID3=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux disable_dev "$dev3"
+vgcreate $vg1 "$dev4"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID4=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other2" $vg1
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+aux enable_dev "$dev3"
+
+vgs -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+not group $UUID3 out
+not group $UUID4 out
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+grep $UUID4 out
+
+not vgs -o+uuid $vg1 |tee out
+not grep $vg1 out
+not vgs --foreign -o+uuid $vg1 |tee out
+not grep $vg1 out
+
+vgchange -ay
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | grep active
+grep $UUID2 out | grep active
+grep $UUID3 out | not grep active
+grep $UUID4 out | not grep active
+vgchange -an
+
+not vgchange -ay $vg1
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | not grep active
+grep $UUID2 out | not grep active
+grep $UUID3 out | not grep active
+grep $UUID4 out | not grep active
+vgchange -an
+
+not lvcreate -l1 -an -n $lv2 $vg1
+lvs --foreign -o vguuid,name |tee out
+grep $UUID1 out | not grep $lv2
+grep $UUID2 out | not grep $lv2
+grep $UUID3 out | not grep $lv2
+grep $UUID4 out | not grep $lv2
+
+not vgremove $vg1
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+grep $UUID4 out
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+aux wipefs_a "$dev4"
+aux wipefs_a "$dev5"
+
+# h. 3 local, 3 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+# diff lvname to prevent clash in vgchange -ay
+lvcreate -n ${lv1}_b -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev2"
+vgcreate $vg1 "$dev3"
+# diff lvname to prevent clash in vgchange -ay
+lvcreate -n ${lv1}_bb -l1 -an $vg1
+UUID3=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev3"
+vgcreate $vg1 "$dev4"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID4=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux disable_dev "$dev4"
+vgcreate $vg1 "$dev5"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID5=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other2" $vg1
+aux disable_dev "$dev5"
+vgcreate $vg1 "$dev6"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID6=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other3" $vg1
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+aux enable_dev "$dev3"
+aux enable_dev "$dev4"
+aux enable_dev "$dev5"
+
+vgs -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+not group $UUID4 out
+not group $UUID5 out
+not group $UUID6 out
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+grep $UUID4 out
+grep $UUID5 out
+grep $UUID6 out
+
+not vgs -o+uuid $vg1 |tee out
+not grep $vg1 out
+not vgs --foreign -o+uuid $vg1 |tee out
+not grep $vg1 out
+
+vgchange -ay
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | grep active
+grep $UUID2 out | grep active
+grep $UUID3 out | grep active
+grep $UUID4 out | not grep active
+grep $UUID5 out | not grep active
+grep $UUID6 out | not grep active
+vgchange -an
+
+not vgchange -ay $vg1
+lvs --foreign -o vguuid,active |tee out
+grep $UUID1 out | not grep active
+grep $UUID2 out | not grep active
+grep $UUID3 out | not grep active
+grep $UUID4 out | not grep active
+grep $UUID5 out | not grep active
+grep $UUID6 out | not grep active
+vgchange -an
+
+not lvcreate -l1 -an -n $lv2 $vg1
+lvs --foreign -o vguuid,name |tee out
+grep $UUID1 out | not grep $lv2
+grep $UUID2 out | not grep $lv2
+grep $UUID3 out | not grep $lv2
+grep $UUID4 out | not grep $lv2
+grep $UUID5 out | not grep $lv2
+grep $UUID6 out | not grep $lv2
+
+not vgremove $vg1
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+grep $UUID4 out
+grep $UUID5 out
+grep $UUID6 out
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+aux wipefs_a "$dev4"
+aux wipefs_a "$dev5"
+aux wipefs_a "$dev6"
+
+# vgreduce test with 1 local and 1 foreign vg.
+# setup
+vgcreate $vg1 "$dev1" "$dev7"
+lvcreate -n $lv1 -l1 -an $vg1 "$dev1"
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+PV1UUID=$(pvs --noheading -o uuid "$dev1")
+PV7UUID=$(pvs --noheading -o uuid "$dev7")
+aux disable_dev "$dev1"
+aux disable_dev "$dev7"
+vgcreate $vg1 "$dev2"
+PV2UUID=$(pvs --noheading -o uuid "$dev2")
+lvcreate -n $lv1 -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux enable_dev "$dev1"
+aux enable_dev "$dev7"
+
+vgs --foreign -o+uuid |tee out
+grep $vg1 out
+grep $UUID1 out
+grep $UUID2 out
+pvs --foreign -o+uuid |tee out
+grep $PV1UUID out
+grep $PV7UUID out
+grep $PV2UUID out
+
+vgreduce $vg1 "$dev7"
+
+pvs --foreign -o+uuid |tee out
+grep $PV1UUID out
+grep $PV7UUID out
+grep $PV2UUID out
+
+grep $PV7UUID out >out2
+not grep $vg1 out2
+
+vgremove -ff $vg1
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev7"
diff --git a/test/shell/duplicate-vgrename.sh b/test/shell/duplicate-vgrename.sh
new file mode 100644
index 000000000..86282206f
--- /dev/null
+++ b/test/shell/duplicate-vgrename.sh
@@ -0,0 +1,319 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 4
+
+# a. 0 local, 1 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+
+not vgrename $vg1 $vg2
+vgs --foreign -o+uuid |tee out
+grep $UUID1 out
+not vgrename $UUID1 $vg2
+vgs --foreign -o+uuid |tee out
+grep $UUID1 out
+
+lvs --foreign
+
+aux wipefs_a "$dev1"
+
+# b. 0 local, 2 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other2" $vg1
+aux enable_dev "$dev1"
+
+not vgrename $vg1 $vg2
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+not grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+not vgrename $UUID1 $vg2
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+not grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+
+lvs --foreign
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+
+# c. 1 local, 1 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux enable_dev "$dev1"
+
+vgrename $vg1 $vg2
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+not vgrename $vg2 $vg1
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+
+lvs --foreign
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+
+# d. 1 local, 2 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux disable_dev "$dev2"
+vgcreate $vg1 "$dev3"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID3=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other2" $vg1
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+
+vgrename $vg1 $vg2
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+not vgrename $vg2 $vg1
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+
+lvs --foreign
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+
+# e. 2 local, 0 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+lvcreate -n ${lv1}_b -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux enable_dev "$dev1"
+
+not vgrename $vg1 $vg2
+vgs -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+not grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+vgrename $UUID1 $vg2
+vgs -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+not vgrename $UUID2 $vg2
+vgs -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+
+lvs --foreign
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+
+# f. 2 local, 1 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+lvcreate -n ${lv1}_b -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev2"
+vgcreate $vg1 "$dev3"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID3=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+vgchange -y --systemid "other" $vg1
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+lvs --foreign
+
+not vgrename $vg1 $vg2
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+not grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+vgrename $UUID1 $vg2
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+vgrename $vg1 $vg3
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $vg3 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+not vgrename $vg2 $vg1
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $vg3 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+not vgrename $vg2 $vg3
+vgs --foreign -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $vg3 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+
+lvs --foreign
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+
+# g. 3 local, 0 foreign
+# setup
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l1 -an $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev1"
+vgcreate $vg1 "$dev2"
+lvcreate -n ${lv1}_b -l1 -an $vg1
+UUID2=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux disable_dev "$dev2"
+vgcreate $vg1 "$dev3"
+lvcreate -n ${lv1}_c -l1 -an $vg1
+UUID3=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+
+not vgrename $vg1 $vg2
+vgs -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+not grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+vgrename $UUID1 $vg2
+vgs -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+not vgrename $vg1 $vg2
+vgs -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+not vgrename $vg1 $vg3
+vgs -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+not grep $vg3 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+not vgrename $UUID2 $vg2
+vgs -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+not grep $vg3 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+vgrename $UUID2 $vg3
+vgs -o+uuid |tee out
+lvs --foreign
+grep $vg1 out
+grep $vg2 out
+grep $vg3 out
+grep $UUID1 out
+grep $UUID2 out
+grep $UUID3 out
+
+lvs --foreign
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+
diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
deleted file mode 100644
index a59c3bd9b..000000000
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ /dev/null
@@ -1,55 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-
-test_description='Test vgs with duplicate vg names'
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_devs 2
-
-pvcreate "$dev1"
-pvcreate "$dev2"
-
-aux disable_dev "$dev1" "$dev2"
-
-aux enable_dev "$dev1"
-vgcreate $vg1 "$dev1"
-UUID1=$(vgs --noheading -o vg_uuid $vg1)
-aux disable_dev "$dev1"
-
-aux enable_dev "$dev2"
-vgcreate $vg1 "$dev2"
-UUID2=$(vgs --noheading -o vg_uuid $vg1)
-
-aux enable_dev "$dev1"
-pvscan --cache "$dev1"
-pvs "$dev1"
-pvs "$dev2"
-
-vgs -o+vg_uuid | tee err
-grep $UUID1 err
-grep $UUID2 err
-
-# should we specify and test which should be displayed?
-# vgs --noheading -o vg_uuid $vg1 >err
-# grep $UUID1 err
-
-aux disable_dev "$dev2"
-vgs -o+vg_uuid | tee err
-grep $UUID1 err
-not grep $UUID2 err
-aux enable_dev "$dev2"
-pvscan --cache "$dev2"
-
-aux disable_dev "$dev1"
-vgs -o+vg_uuid | tee err
-grep $UUID2 err
-not grep $UUID1 err
-aux enable_dev "$dev1"
diff --git a/tools/toollib.c b/tools/toollib.c
index 96d0d6dff..89b637407 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1853,8 +1853,6 @@ static int _resolve_duplicate_vgnames(struct cmd_context *cmd,
 			if (lvmcache_vg_is_foreign(cmd, vgnl->vg_name, vgnl->vgid)) {
 				if (!id_write_format((const struct id*)vgnl->vgid, uuid, sizeof(uuid)))
 					stack;
-				log_warn("WARNING: Ignoring foreign VG with matching name %s UUID %s.",
-					 vgnl->vg_name, uuid);
 				dm_list_del(&vgnl->list);
 			} else {
 				found++;



