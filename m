From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Feb 2010 12:28:57 -0500
Subject: [PATCH 1/8] Refactor _vgchange_tag() to vg_change_tag() library function.
In-Reply-To: <1266427744-30327-1-git-send-email-dwysocha@redhat.com>
References: <1266427744-30327-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1266427744-30327-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Pull out common code to be called from tools as well as lvm2app.
Leave archive() at tool level so we can use from vgcreate
as well as vgchange.  Should be no functional change.
- add stack macro in vgchange

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   23 +++++++++++++++++++++++
 tools/vgchange.c                 |   20 +++-----------------
 3 files changed, 27 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 164ce36..fae9551 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -463,6 +463,7 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
 	      struct pvcreate_params *pp);
 int vg_reduce(struct volume_group *vg, char *pv_name);
+int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag);
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size);
 int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv);
 int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b3b3778..52bbc46 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -665,6 +665,29 @@ int vg_reduce(struct volume_group *vg, char *pv_name)
 	return 0;
 }
 
+int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag)
+{
+	if (!(vg->fid->fmt->features & FMT_TAGS)) {
+		log_error("Volume group %s does not support tags", vg->name);
+		return 0;
+	}
+
+	if (add_tag) {
+		if (!str_list_add(vg->vgmem, &vg->tags, tag)) {
+			log_error("Failed to add tag %s to volume group %s",
+				  tag, vg->name);
+			return 0;
+		}
+	} else {
+		if (!str_list_del(&vg->tags, tag)) {
+			log_error("Failed to remove tag %s from volume group "
+				  "%s", tag, vg->name);
+			return 0;
+		}
+	}
+	return 1;
+}
+
 const char *strip_dir(const char *vg_name, const char *dev_dir)
 {
 	size_t len = strlen(dev_dir);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index b4f5d00..6d869f9 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -447,28 +447,14 @@ static int _vgchange_tag(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	if (!(vg->fid->fmt->features & FMT_TAGS)) {
-		log_error("Volume group %s does not support tags", vg->name);
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
 
-	if ((arg == addtag_ARG)) {
-		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
-			log_error("Failed to add tag %s to volume group %s",
-				  tag, vg->name);
-			return ECMD_FAILED;
-		}
-	} else {
-		if (!str_list_del(&vg->tags, tag)) {
-			log_error("Failed to remove tag %s from volume group "
-				  "%s", tag, vg->name);
-			return ECMD_FAILED;
-		}
+	if (!vg_change_tag(vg, tag, arg == addtag_ARG)) {
+		stack;
+		return ECMD_FAILED;
 	}
 
 	if (!vg_write(vg) || !vg_commit(vg)) {
-- 
1.6.0.6


