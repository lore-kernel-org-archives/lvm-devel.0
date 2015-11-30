From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 30 Nov 2015 17:35:29 +0000 (UTC)
Subject: master - lvmcache: include system_id in vginfo cache
Message-ID: <20151130173530.0011C60612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3ca18e489d48cc7c7b2a877b95b5a9a324e8e30
Commit:        d3ca18e489d48cc7c7b2a877b95b5a9a324e8e30
Parent:        1f357532bb8d6094bffecde48ad8d4b8e4fc430c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 30 11:32:17 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 30 11:32:17 2015 -0600

lvmcache: include system_id in vginfo cache

Save system_id just like creation_host and lock_type
strings in vginfo cache.
---
 lib/cache/lvmcache.c          |   36 ++++++++++++++++++++++++++++++------
 lib/cache/lvmcache.h          |    1 +
 lib/format_text/import_vsn1.c |    7 ++++++-
 3 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 8ab1a31..6c86a40 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -56,6 +56,7 @@ struct lvmcache_vginfo {
 	char _padding[7];
 	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
+	char *system_id;
 	char *lock_type;
 	uint32_t mda_checksum;
 	size_t mda_size;
@@ -1448,7 +1449,8 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 }
 
 static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstatus,
-				     const char *creation_host, const char *lock_type)
+				     const char *creation_host, const char *lock_type,
+				     const char *system_id)
 {
 	if (!info || !info->vginfo)
 		return 1;
@@ -1482,20 +1484,41 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 set_lock_type:
 
 	if (!lock_type)
-		goto out;
+		goto set_system_id;
 
 	if (info->vginfo->lock_type && !strcmp(lock_type, info->vginfo->lock_type))
-		goto out;
+		goto set_system_id;
 
 	if (info->vginfo->lock_type)
 		dm_free(info->vginfo->lock_type);
 
 	if (!(info->vginfo->lock_type = dm_strdup(lock_type))) {
-		log_error("cache creation host alloc failed for %s",
-			  lock_type);
+		log_error("cache lock_type alloc failed for %s", lock_type);
+		return 0;
+	}
+
+	log_debug_cache("lvmcache: %s: VG %s: Set lock_type to %s.",
+			dev_name(info->dev), info->vginfo->vgname, lock_type);
+
+set_system_id:
+
+	if (!system_id)
+		goto out;
+
+	if (info->vginfo->system_id && !strcmp(system_id, info->vginfo->system_id))
+		goto out;
+
+	if (info->vginfo->system_id)
+		dm_free(info->vginfo->system_id);
+
+	if (!(info->vginfo->system_id = dm_strdup(system_id))) {
+		log_error("cache system_id alloc failed for %s", system_id);
 		return 0;
 	}
 
+	log_debug_cache("lvmcache: %s: VG %s: Set system_id to %s.",
+			dev_name(info->dev), info->vginfo->vgname, system_id);
+
 out:
 	return 1;
 }
@@ -1561,7 +1584,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 	if (!_lvmcache_update_vgname(info, vgname, vgid, vgsummary->vgstatus,
 				     vgsummary->creation_host, info->fmt) ||
 	    !_lvmcache_update_vgid(info, info->vginfo, vgid) ||
-	    !_lvmcache_update_vgstatus(info, vgsummary->vgstatus, vgsummary->creation_host, vgsummary->lock_type) ||
+	    !_lvmcache_update_vgstatus(info, vgsummary->vgstatus, vgsummary->creation_host, vgsummary->lock_type, vgsummary->system_id) ||
 	    !_lvmcache_update_vg_mda_info(info, vgsummary->mda_checksum, vgsummary->mda_size))
 		return_0;
 
@@ -1577,6 +1600,7 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 		.vgname = vg->name,
 		.vgstatus = vg->status,
 		.vgid = vg->id,
+		.system_id = vg->system_id,
 		.lock_type = vg->lock_type
 	};
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index ccf3eb4..ed1b916 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -55,6 +55,7 @@ struct lvmcache_vgsummary {
 	struct id vgid;
 	uint64_t vgstatus;
 	char *creation_host;
+	const char *system_id;
 	const char *lock_type;
 	uint32_t mda_checksum;
 	size_t mda_size;
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 879aae7..6aa227b 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -1042,6 +1042,7 @@ static int _read_vgname(const struct format_type *fmt, const struct dm_config_tr
 {
 	const struct dm_config_node *vgn;
 	struct dm_pool *mem = fmt->cmd->mem;
+	const char *str;
 	int old_suppress;
 
 	old_suppress = log_suppress(2);
@@ -1073,7 +1074,11 @@ static int _read_vgname(const struct format_type *fmt, const struct dm_config_tr
 		return 0;
 	}
 
-	dm_config_get_str(vgn, "lock_type", &vgsummary->lock_type);
+	if (dm_config_get_str(vgn, "system_id", &str))
+		vgsummary->system_id = dm_pool_strdup(mem, str);
+
+	if (dm_config_get_str(vgn, "lock_type", &str))
+		vgsummary->lock_type = dm_pool_strdup(mem, str);
 
 	return 1;
 }


