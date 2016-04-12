From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 Apr 2016 11:10:40 +0000 (UTC)
Subject: master - debug: unify some tracing messages
Message-ID: <20160412111040.3622D61B91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a28c81cbae308e371ece31679615d673b29fccec
Commit:        a28c81cbae308e371ece31679615d673b29fccec
Parent:        1be74cfd7f948123544872abb5e80994182e04d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 12 13:06:16 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 12 13:06:16 2016 +0200

debug: unify some tracing messages

Introduce  FMTVGID - although it might be possibly better to ensure
vgid is always \0 ended string.

Unify some lvmcache reported messages.
---
 lib/cache/lvmcache.c          |   35 +++++++++++++++++++----------------
 lib/format_text/format-text.c |    9 +++------
 lib/misc/util.h               |    2 ++
 3 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 394745a..3432ef6 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -504,12 +504,13 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname, const ch
 		return lvmcache_vginfo_from_vgid(vgid);
 
 	if (!_vgname_hash) {
-		log_debug_cache(INTERNAL_ERROR "Internal cache is no yet initialized.");
+		log_debug_cache(INTERNAL_ERROR "Internal lvmcache is no yet initialized.");
 		return NULL;
 	}
 
 	if (!(vginfo = dm_hash_lookup(_vgname_hash, vgname))) {
-		log_debug_cache("Metadata cache has no info for vgname: \"%s\"", vgname);
+		log_debug_cache("lvmcache has no info for vgname \"%s\"%s" FMTVGID ".",
+				vgname, (vgid) ? " with VGID " : "", (vgid) ? : "");
 		return NULL;
 	}
 
@@ -520,8 +521,8 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname, const ch
 		while ((vginfo = vginfo->next));
 
 	if  (!vginfo)
-		log_debug_cache("Metadata cache has not found vgname \"%s\" with vgid \"%."
-				DM_TO_STRING(ID_LEN) "s\".", vgname, vgid ? : "");
+		log_debug_cache("lvmcache has not found vgname \"%s\"%s" FMTVGID ".",
+				vgname, (vgid) ? " with VGID " : "", (vgid) ? : "");
 
 	return vginfo;
 }
@@ -1273,7 +1274,7 @@ static int _lvmcache_update_vgid(struct lvmcache_info *info,
 	}
 
 	if (!is_orphan_vg(vginfo->vgname))
-		log_debug_cache("lvmcache: %s: setting %s VGID to %s",
+		log_debug_cache("lvmcache %s: VG %s: set VGID to " FMTVGID ".",
 				(info) ? dev_name(info->dev) : "",
 				vginfo->vgname, vginfo->vgid);
 
@@ -1504,16 +1505,16 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 
 	if (info) {
 		if (info->mdas.n)
-			sprintf(mdabuf, " with %u mdas", dm_list_size(&info->mdas));
+			sprintf(mdabuf, " with %u mda(s)", dm_list_size(&info->mdas));
 		else
 			mdabuf[0] = '\0';
-		log_debug_cache("lvmcache: %s: now in VG %s%s%s%s%s",
+		log_debug_cache("lvmcache %s: now in VG %s%s%s%s%s.",
 				dev_name(info->dev),
 				vgname, vginfo->vgid[0] ? " (" : "",
 				vginfo->vgid[0] ? vginfo->vgid : "",
 				vginfo->vgid[0] ? ")" : "", mdabuf);
 	} else
-		log_debug_cache("lvmcache: initialised VG %s", vgname);
+		log_debug_cache("lvmcache initialised VG %s.", vgname);
 
 	return 1;
 }
@@ -1526,7 +1527,7 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 		return 1;
 
 	if ((info->vginfo->status & EXPORTED_VG) != (vgstatus & EXPORTED_VG))
-		log_debug_cache("lvmcache: %s: VG %s %s exported",
+		log_debug_cache("lvmcache %s: VG %s %s exported.",
 				dev_name(info->dev), info->vginfo->vgname,
 				vgstatus & EXPORTED_VG ? "now" : "no longer");
 
@@ -1543,12 +1544,12 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 		dm_free(info->vginfo->creation_host);
 
 	if (!(info->vginfo->creation_host = dm_strdup(creation_host))) {
-		log_error("cache creation host alloc failed for %s",
+		log_error("cache creation host alloc failed for %s.",
 			  creation_host);
 		return 0;
 	}
 
-	log_debug_cache("lvmcache: %s: VG %s: Set creation host to %s.",
+	log_debug_cache("lvmcache %s: VG %s: set creation host to %s.",
 			dev_name(info->dev), info->vginfo->vgname, creation_host);
 
 set_lock_type:
@@ -1567,7 +1568,7 @@ set_lock_type:
 		return 0;
 	}
 
-	log_debug_cache("lvmcache: %s: VG %s: Set lock_type to %s.",
+	log_debug_cache("lvmcache %s: VG %s: set lock_type to %s.",
 			dev_name(info->dev), info->vginfo->vgname, lock_type);
 
 set_system_id:
@@ -1586,7 +1587,7 @@ set_system_id:
 		return 0;
 	}
 
-	log_debug_cache("lvmcache: %s: VG %s: Set system_id to %s.",
+	log_debug_cache("lvmcache %s: VG %s: set system_id to %s.",
 			dev_name(info->dev), info->vginfo->vgname, system_id);
 
 out:
@@ -1607,8 +1608,10 @@ static int _lvmcache_update_vg_mda_info(struct lvmcache_info *info, uint32_t mda
 
 	/* FIXME Add checksum index */
 
-	log_debug_cache("lvmcache: %s: VG %s: Stored metadata checksum %" PRIu32 " with size %" PRIsize_t ".",
-			dev_name(info->dev), info->vginfo->vgname, mda_checksum, mda_size);
+	log_debug_cache("lvmcache %s: VG %s: stored metadata checksum 0x%08"
+			PRIx32 " with size %" PRIsize_t ".",
+			dev_name(info->dev), info->vginfo->vgname,
+			mda_checksum, mda_size);
 
 	return 1;
 }
@@ -1961,7 +1964,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 			 * device already exists?  Things don't seem to work
 			 * if we do that for some reason.
 			 */
-			log_debug_cache("Found same device %s with same pvid %s",
+			log_debug_cache("Found same device %s with same pvid %s.",
 					dev_name(existing->dev), pvid_s);
 		}
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6053610..bd20670 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1153,7 +1153,6 @@ int vgname_from_mda(const struct format_type *fmt,
 	uint32_t wrap = 0;
 	unsigned int len = 0;
 	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
-	char uuid[64] __attribute__((aligned(8)));
 	uint64_t buffer_size, current_usage;
 	unsigned used_cached_metadata = 0;
 
@@ -1222,16 +1221,14 @@ int vgname_from_mda(const struct format_type *fmt,
 	if (!validate_name(vgsummary->vgname))
 		return_0;
 
-	if (!id_write_format((struct id *)&vgsummary->vgid, uuid, sizeof(uuid)))
-		return_0;
-
 	log_debug_metadata("%s: %s metadata at %" PRIu64 " size %" PRIu64
 			   " (in area at %" PRIu64 " size %" PRIu64
-			   ") for %s (%s)",
+			   ") for %s (" FMTVGID ")",
 			   dev_name(dev_area->dev),
 			   used_cached_metadata ? "Using cached" : "Found",
 			   dev_area->start + rlocn->offset,
-			   rlocn->size, dev_area->start, dev_area->size, vgsummary->vgname, uuid);
+			   rlocn->size, dev_area->start, dev_area->size, vgsummary->vgname,
+			   (char *)&vgsummary->vgid);
 
 	if (mda_free_sectors) {
 		current_usage = (rlocn->size + SECTOR_SIZE - UINT64_C(1)) -
diff --git a/lib/misc/util.h b/lib/misc/util.h
index b08b95d..1011fdd 100644
--- a/lib/misc/util.h
+++ b/lib/misc/util.h
@@ -72,4 +72,6 @@
 #define FMTx32 "%" PRIx32
 #define FMTx64 "%" PRIx64
 
+#define FMTVGID "%." DM_TO_STRING(ID_LEN) "s"
+
 #endif


