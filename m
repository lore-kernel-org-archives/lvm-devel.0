From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 17 Dec 2010 11:55:12 +0100
Subject: [PATCH 1/1] Extend lvm cache with config tree
In-Reply-To: <cover.1292582945.git.zkabelac@redhat.com>
References: <cover.1292582945.git.zkabelac@redhat.com>
Message-ID: <1bf4f906aa90e108b9721fa799d7581fff334a29.1292582945.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Idea of this patch - it's easy to handle cached config tree inside
struct lvmcache_vginfo.

Unlide the first version of this patch, that tried to optimize
creation of config_tree from the same string - this version moves
config_tree creation to lvmcache and when the first parsing
of cached metadata should be done - config_tree is stored for the buffer.

So when metadata are droped and same string need to be parsed - tree
will be created - however we do not need to compare string buffers
or do any other time consuming extra hashing - so it's probably faster
(at least on my test set)

As there is no other user of the function import_vg_from_buffer()
it could be removed with another patch unless someone needs that?

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c     |   16 +++++++++++++++-
 lib/cache/lvmcache.h     |    2 ++
 lib/format_text/import.c |   23 +++++++++++++++++++++++
 lib/metadata/metadata.h  |    3 +++
 4 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d545563..085920a 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -26,6 +26,7 @@
 #include "format-text.h"
 #include "format_pool.h"
 #include "format1.h"
+#include "config.h"
 
 static struct dm_hash_table *_pvid_hash = NULL;
 static struct dm_hash_table *_vgid_hash = NULL;
@@ -82,6 +83,11 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 
 	vginfo->vgmetadata = NULL;
 
+	if (vginfo->cft) {
+		destroy_config_tree(vginfo->cft);
+		vginfo->cft = NULL;
+	}
+
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
 }
 
@@ -650,7 +656,15 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 						      vgid, NULL)))
 		return_NULL;
 
-	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid))) {
+	if (!vginfo->cft &&
+	    !(vginfo->cft =
+	      create_config_tree_from_string(fid->fmt->cmd,
+					     vginfo->vgmetadata))) {
+		_free_cached_vgmetadata(vginfo);
+		return_NULL;
+	}
+
+	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid))) {
 		_free_cached_vgmetadata(vginfo);
 		free_vg(vg);
 		return_NULL;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 06838dc..0c474ba 100644
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
+	struct config_tree *cft; /* Config tree created from text metadata */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 3e0df94..7fa2647 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -158,3 +158,26 @@ struct volume_group *import_vg_from_buffer(char *buf,
 	destroy_config_tree(cft);
 	return vg;
 }
+
+struct volume_group *import_vg_from_config_tree(const struct config_tree *cft,
+						struct format_instance *fid)
+{
+	struct volume_group *vg = NULL;
+	struct text_vg_version_ops **vsn;
+
+	_init_text_import();
+
+	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
+		if (!(*vsn)->check_version(cft))
+			continue;
+		/*
+		 * The only path to this point uses cached vgmetadata,
+		 * so it can use cached PV state too.
+		 */
+		if (!(vg = (*vsn)->read_vg(fid, cft, 1)))
+			stack;
+		break;
+	}
+
+	return vg;
+}
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 6ed467e..3fb4295 100644
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
 struct volume_group *import_vg_from_buffer(char *buf,
 					   struct format_instance *fid);
+struct volume_group *import_vg_from_config_tree(const struct config_tree *cft,
+						struct format_instance *fid);
 
 /*
  * Mirroring functions
-- 
1.7.3.3


