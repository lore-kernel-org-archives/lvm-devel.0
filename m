From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 16 Feb 2010 14:39:45 -0500
Subject: [PATCH 3/7] Refactor lvchange_tag() to call lv_change_tag() library function.
In-Reply-To: <1266349189-23166-3-git-send-email-dwysocha@redhat.com>
References: <1266349189-23166-1-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-2-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1266349189-23166-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Similar refactoring to vgchange - pull out common parts and put into
library function for reuse.  Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/metadata.c          |   24 ++++++++++++++++++++++++
 tools/lvchange.c                 |   19 +------------------
 3 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index fae9551..9540285 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -493,6 +493,8 @@ struct logical_volume *lv_create_empty(const char *name,
 int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
            uint64_t sectors, int value);
 
+int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag);
+
 /* Reduce the size of an LV by extents */
 int lv_reduce(struct logical_volume *lv, uint32_t extents);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 52bbc46..2b8a1be 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -665,6 +665,30 @@ int vg_reduce(struct volume_group *vg, char *pv_name)
 	return 0;
 }
 
+int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag)
+{
+	if (!(lv->vg->fid->fmt->features & FMT_TAGS)) {
+		log_error("Logical volume %s/%s does not support tags",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (add_tag) {
+		if (!str_list_add(lv->vg->vgmem, &lv->tags, tag)) {
+			log_error("Failed to add tag %s to %s/%s",
+				  tag, lv->vg->name, lv->name);
+			return 0;
+		}
+	} else {
+		if (!str_list_del(&lv->tags, tag)) {
+			log_error("Failed to remove tag %s from %s/%s",
+				  tag, lv->vg->name, lv->name);
+			return 0;
+		}
+	}
+	return 1;
+}
+
 int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag)
 {
 	if (!(vg->fid->fmt->features & FMT_TAGS)) {
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 5118e51..862a709 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -500,25 +500,8 @@ static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!(lv->vg->fid->fmt->features & FMT_TAGS)) {
-		log_error("Logical volume %s/%s does not support tags",
-			  lv->vg->name, lv->name);
+	if (!lv_change_tag(lv, tag, arg == addtag_ARG))
 		return 0;
-	}
-
-	if ((arg == addtag_ARG)) {
-		if (!str_list_add(cmd->mem, &lv->tags, tag)) {
-			log_error("Failed to add tag %s to %s/%s",
-				  tag, lv->vg->name, lv->name);
-			return 0;
-		}
-	} else {
-		if (!str_list_del(&lv->tags, tag)) {
-			log_error("Failed to remove tag %s from %s/%s",
-				  tag, lv->vg->name, lv->name);
-			return 0;
-		}
-	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
-- 
1.6.0.6


