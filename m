From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed,  9 Mar 2011 13:22:38 +0100
Subject: [PATCH 6/7] Various cleanups for fid mem and ref_count changes.
In-Reply-To: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
References: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1299673359-6784-7-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Well, I've encountered these by chance:

Missing free_vg on error_paths in lvmcache_get_vg and _vg_read_orphans
fn. Call destroy_instance only if the fid is not part of the vg in
backup_read_vg fn (otherwise it's part of the VG we're returning and
we definitely don't want to destroy it!).

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/cache/lvmcache.c       |   19 ++++++++++---------
 lib/format_text/archive.c  |    1 -
 lib/format_text/archiver.c |    5 ++++-
 lib/metadata/metadata.c    |    3 ++-
 4 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0a8693c..b75039d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -627,7 +627,7 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
-	struct volume_group *vg;
+	struct volume_group *vg = NULL;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
 
@@ -663,20 +663,21 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	if (!vginfo->cft &&
 	    !(vginfo->cft =
 	      create_config_tree_from_string(fid->fmt->cmd,
-					     vginfo->vgmetadata))) {
-		_free_cached_vgmetadata(vginfo);
-		return_NULL;
-	}
+					     vginfo->vgmetadata)))
+		goto_bad;
 
-	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid))) {
-		_free_cached_vgmetadata(vginfo);
-		return_NULL;
-	}
+	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
+		goto_bad;
 
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
 
 	return vg;
+
+bad:
+	free_vg(vg);
+	_free_cached_vgmetadata(vginfo);
+	return NULL;
 }
 
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index e23cb2d..4e7c8f1 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -333,7 +333,6 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
 	log_print("Backup Time:\t%s", ctime(&when));
 
 	free_vg(vg);
-	tf->fmt->ops->destroy_instance(tf);
 }
 
 int archive_list(struct cmd_context *cmd, const char *dir, const char *vgname)
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 3d33e24..e3e9fe0 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -289,7 +289,9 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 		break;
 	}
 
-	tf->fmt->ops->destroy_instance(tf);
+	if (!vg)
+		tf->fmt->ops->destroy_instance(tf);
+
 	return vg;
 }
 
@@ -401,6 +403,7 @@ int backup_to_file(const char *file, const char *desc, struct volume_group *vg)
 
 	if (!dm_list_size(&tf->metadata_areas_in_use)) {
 		log_error(INTERNAL_ERROR "No in use metadata areas to write.");
+		tf->fmt->ops->destroy_instance(tf);
 		return 0;
 	}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3a72c96..c6a0b27 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2641,7 +2641,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 	struct pv_list *pvl;
-	struct volume_group *vg;
+	struct volume_group *vg = NULL;
 	struct physical_volume *pv = NULL;
 	struct dm_pool *mem;
 
@@ -2694,6 +2694,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	return vg;
 bad:
 	free_pv_fid(pv);
+	free_vg(vg);
 	dm_pool_destroy(mem);
 	return NULL;
 }
-- 
1.7.4


