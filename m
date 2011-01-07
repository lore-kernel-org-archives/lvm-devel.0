From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 Jan 2011 12:17:31 +0100
Subject: [PATCH 3/8] Change import_vg_from_buffer to use config_tree
In-Reply-To: <cover.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
Message-ID: <c9446c5e5a74735278f5aae34f72d4947828eb6e.1294398815.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Change function import_vg_from_buffer() to import_vg_from_config_tree().
Instead of creating config tree inside the function allow cft to
be passed as parameter - usable later for caching.

Patch only moves the code and presents no functional change.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c     |   13 +++++++++++--
 lib/cache/lvmcache.h     |    2 ++
 lib/format_text/import.c |    9 ++-------
 lib/metadata/metadata.h  |    3 +++
 4 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d545563..ebd6d44 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -26,6 +26,7 @@
 #include "format-text.h"
 #include "format_pool.h"
 #include "format1.h"
+#include "config.h"
 
 static struct dm_hash_table *_pvid_hash = NULL;
 static struct dm_hash_table *_vgid_hash = NULL;
@@ -650,12 +651,20 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 						      vgid, NULL)))
 		return_NULL;
 
-	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid))) {
+	if (!(vginfo->cft =
+	      create_config_tree_from_string(fid->fmt->cmd,
+					     vginfo->vgmetadata))) {
 		_free_cached_vgmetadata(vginfo);
-		free_vg(vg);
 		return_NULL;
 	}
 
+	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid))) {
+		_free_cached_vgmetadata(vginfo);
+		destroy_config_tree(vginfo->cft);
+		return_NULL;
+	}
+	destroy_config_tree(vginfo->cft);
+
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 06838dc..8c07a26 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -33,6 +33,7 @@
 struct cmd_context;
 struct format_type;
 struct volume_group;
+struct config_tree;
 
 /* One per VG */
 struct lvmcache_vginfo {
@@ -46,6 +47,7 @@ struct lvmcache_vginfo {
 	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
+	struct config_tree *cft; /* Config tree created from vgmetadata */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 60f465f..aa8c807 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -131,18 +131,14 @@ struct volume_group *text_vg_import_file(struct format_instance *fid,
 				 when, desc);
 }
 
-struct volume_group *import_vg_from_buffer(const char *buf,
-                                           struct format_instance *fid)
+struct volume_group *import_vg_from_config_tree(const struct config_tree *cft,
+						struct format_instance *fid)
 {
 	struct volume_group *vg = NULL;
-	struct config_tree *cft;
 	struct text_vg_version_ops **vsn;
 
 	_init_text_import();
 
-	if (!(cft = create_config_tree_from_string(fid->fmt->cmd, buf)))
-		return_NULL;
-
 	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
 		if (!(*vsn)->check_version(cft))
 			continue;
@@ -155,6 +151,5 @@ struct volume_group *import_vg_from_buffer(const char *buf,
 		break;
 	}
 
-	destroy_config_tree(cft);
 	return vg;
 }
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 08bff4a..c0f9148 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -100,6 +100,7 @@
 //#define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
 //#define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 
+struct config_tree;
 struct metadata_area;
 
 /* Per-format per-metadata area operations */
@@ -388,6 +389,8 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
 struct volume_group *import_vg_from_buffer(const char *buf,
 					   struct format_instance *fid);
+struct volume_group *import_vg_from_config_tree(const struct config_tree *cft,
+						struct format_instance *fid);
 
 /*
  * Mirroring functions
-- 
1.7.3.4


