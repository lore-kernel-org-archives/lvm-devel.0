From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 03:08:46 -0400
Subject: [PATCH 8/9] Add vg_set_alloc_policy() liblvm function and move vgchange logic inside.
In-Reply-To: <1247123327-26141-8-git-send-email-dwysocha@redhat.com>
References: <1247123327-26141-1-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-2-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-3-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-4-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-5-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-6-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-7-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1247123327-26141-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add vg_set_alloc_policy() liblvm function and move vgchange logic inside.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   18 ++++++++++++++++++
 tools/vgchange.c                 |   15 ++-------------
 3 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a9274c4..474b3a7 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -437,6 +437,7 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
 int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
 int vg_set_max_lv(vg_t *vg, uint32_t max_lv);
 int vg_set_max_pv(vg_t *vg, uint32_t max_pv);
+int vg_set_alloc_policy(vg_t *vg, alloc_policy_t alloc);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 738423d..da09de5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -824,6 +824,24 @@ int vg_set_max_pv(vg_t *vg, uint32_t max_pv)
 	return 1;
 }
 
+int vg_set_alloc_policy(vg_t *vg, alloc_policy_t alloc)
+{
+	if (alloc == ALLOC_INHERIT) {
+		log_error("Volume Group allocation policy cannot inherit "
+			  "from anything");
+		return 0;
+	}
+
+	if (alloc == vg->alloc) {
+		log_print("Volume group allocation policy is already %s",
+			  get_alloc_string(vg->alloc));
+		return 1;
+	}
+	vg->alloc = alloc;
+	return 1;
+}
+
+
 /*
  * Separate metadata areas after splitting a VG.
  * Also accepts orphan VG as destination (for vgreduce).
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 356b805..7652864 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -179,22 +179,11 @@ static int _vgchange_alloc(struct cmd_context *cmd, struct volume_group *vg)
 
 	alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
 
-	if (alloc == ALLOC_INHERIT) {
-		log_error("Volume Group allocation policy cannot inherit "
-			  "from anything");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (alloc == vg->alloc) {
-		log_print("Volume group allocation policy is already %s",
-			  get_alloc_string(vg->alloc));
-		return ECMD_PROCESSED;
-	}
-
 	if (!archive(vg))
 		return ECMD_FAILED;
 
-	vg->alloc = alloc;
+	if (!vg_set_alloc_policy(vg, alloc))
+		return ECMD_FAILED;
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		return ECMD_FAILED;
-- 
1.6.0.6


