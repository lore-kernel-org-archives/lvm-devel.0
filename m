From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 18:17:46 -0400
Subject: [PATCH 1/4] Remove unnecessary parameters from vg_remove_single().
In-Reply-To: <1247177869-12526-1-git-send-email-dwysocha@redhat.com>
References: <1247177869-12526-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1247177869-12526-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use vg_t instead of struct volume_group.
Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    4 +---
 lib/metadata/metadata.c          |    7 +++----
 tools/vgremove.c                 |    3 +--
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5aa0d56..6e085d8 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -425,9 +425,7 @@ uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
 vg_t *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove(struct volume_group *vg);
-int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg,
-		     force_t force);
+int vg_remove_single(vg_t *vg, force_t force);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0c155fd..71cb6ea 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -359,15 +359,14 @@ static int remove_lvs_in_vg(struct cmd_context *cmd,
 	return 1;
 }
 
-/* FIXME: remove redundant vg_name */
-int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg,
-		     force_t force __attribute((unused)))
+int vg_remove_single(vg_t *vg, force_t force)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	unsigned lv_count;
 	int ret = 1;
+	const char *vg_name = vg->name;
+	struct cmd_context *cmd = vg->cmd;
 
 	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
diff --git a/tools/vgremove.c b/tools/vgremove.c
index ff35720..8977ea5 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -19,8 +19,7 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
-	if (!vg_remove_single(cmd, vg_name, vg,
-			      arg_count(cmd, force_ARG)))
+	if (!vg_remove_single(vg, arg_count(cmd, force_ARG)))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;
-- 
1.6.0.6


