From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 29 Jul 2015 19:49:10 +0000 (UTC)
Subject: master - lvmcache: add lock_type to VG summary and info structs
Message-ID: <20150729194910.63D6860DD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e593213b875e96a3de77594f7ce8dd1809a930a0
Commit:        e593213b875e96a3de77594f7ce8dd1809a930a0
Parent:        3cd644aeb5cac432a92ad50584973a3430168ed6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 24 15:20:37 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 29 14:27:32 2015 -0500

lvmcache: add lock_type to VG summary and info structs

vgsummary information contains provisional VG information
that is obtained without holding the VG lock.  This info
can be used to lock the VG, and then read it with vg_read().
After the VG is read properly, the vgsummary info should
be verified.

Add the VG lock_type to the vgsummary.  It needs to be
known before the VG can be locked and read.
---
 lib/cache/lvmcache.c          |   30 +++++++++++++++++++++++++-----
 lib/cache/lvmcache.h          |   12 ++++++++++++
 lib/format_text/import_vsn1.c |    7 +++++++
 3 files changed, 44 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 9f5b83a..36926f2 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -56,6 +56,7 @@ struct lvmcache_vginfo {
 	char _padding[7];
 	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
+	char *lock_type;
 	uint32_t mda_checksum;
 	size_t mda_size;
 	size_t vgmetadata_size;
@@ -1447,7 +1448,7 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 }
 
 static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstatus,
-				     const char *creation_host)
+				     const char *creation_host, const char *lock_type)
 {
 	if (!info || !info->vginfo)
 		return 1;
@@ -1460,11 +1461,11 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 	info->vginfo->status = vgstatus;
 
 	if (!creation_host)
-		return 1;
+		goto set_lock_type;
 
 	if (info->vginfo->creation_host && !strcmp(creation_host,
 						   info->vginfo->creation_host))
-		return 1;
+		goto set_lock_type;
 
 	if (info->vginfo->creation_host)
 		dm_free(info->vginfo->creation_host);
@@ -1478,6 +1479,24 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 	log_debug_cache("lvmcache: %s: VG %s: Set creation host to %s.",
 			dev_name(info->dev), info->vginfo->vgname, creation_host);
 
+set_lock_type:
+
+	if (!lock_type)
+		goto out;
+
+	if (info->vginfo->lock_type && !strcmp(lock_type, info->vginfo->lock_type))
+		goto out;
+
+	if (info->vginfo->lock_type)
+		dm_free(info->vginfo->lock_type);
+
+	if (!(info->vginfo->lock_type = dm_strdup(lock_type))) {
+		log_error("cache creation host alloc failed for %s",
+			  lock_type);
+		return 0;
+	}
+
+out:
 	return 1;
 }
 
@@ -1546,7 +1565,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 	if (!_lvmcache_update_vgname(info, vgname, vgid, vgsummary->vgstatus,
 				     vgsummary->creation_host, info->fmt) ||
 	    !_lvmcache_update_vgid(info, info->vginfo, vgid) ||
-	    !_lvmcache_update_vgstatus(info, vgsummary->vgstatus, vgsummary->creation_host) ||
+	    !_lvmcache_update_vgstatus(info, vgsummary->vgstatus, vgsummary->creation_host, vgsummary->lock_type) ||
 	    !_lvmcache_update_vg_mda_info(info, vgsummary->mda_checksum, vgsummary->mda_size))
 		return_0;
 
@@ -1561,7 +1580,8 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 	struct lvmcache_vgsummary vgsummary = {
 		.vgname = vg->name,
 		.vgstatus = vg->status,
-		.vgid = vg->id
+		.vgid = vg->id,
+		.lock_type = vg->lock_type
 	};
 
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 780325a..008b194 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -39,11 +39,23 @@ struct disk_locn;
 
 struct lvmcache_vginfo;
 
+/*
+ * vgsummary represents a summary of the VG that is read
+ * without a lock.  The info does not come through vg_read(),
+ * but through reading mdas.  It provides information about
+ * the VG that is needed to lock the VG and then read it fully
+ * with vg_read(), after which the VG summary should be checked
+ * against the full VG metadata to verify it was correct (since
+ * it was read without a lock.)
+ *
+ * Once read, vgsummary information is saved in lvmcache_vginfo.
+ */
 struct lvmcache_vgsummary {
 	const char *vgname;
 	struct id vgid;
 	uint64_t vgstatus;
 	char *creation_host;
+	const char *lock_type;
 	uint32_t mda_checksum;
 	size_t mda_size;
 };
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index a4dcdf1..7888695 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -1031,6 +1031,11 @@ static void _read_desc(struct dm_pool *mem,
 	*when = u;
 }
 
+/*
+ * It would be more accurate to call this _read_vgsummary().
+ * It is used to read vgsummary information about a VG
+ * before locking and reading the VG via vg_read().
+ */
 static int _read_vgname(const struct format_type *fmt, const struct dm_config_tree *cft, 
 			struct lvmcache_vgsummary *vgsummary)
 {
@@ -1067,6 +1072,8 @@ static int _read_vgname(const struct format_type *fmt, const struct dm_config_tr
 		return 0;
 	}
 
+	dm_config_get_str(vgn, "lock_type", &vgsummary->lock_type);
+
 	return 1;
 }
 


