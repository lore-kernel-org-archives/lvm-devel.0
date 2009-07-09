From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 03:08:44 -0400
Subject: [PATCH 6/9] Add vg_set_max_lv() liblvm function and move vgchange logic inside.
In-Reply-To: <1247123327-26141-6-git-send-email-dwysocha@redhat.com>
References: <1247123327-26141-1-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-2-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-3-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-4-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-5-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1247123327-26141-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add vg_set_max_lv() liblvm function and move vgchange logic inside.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   28 ++++++++++++++++++++++++++++
 tools/vgchange.c                 |   25 ++-----------------------
 3 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index bdad97f..05ca4f3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -435,6 +435,7 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
 int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
+int vg_set_max_lv(vg_t *vg, uint32_t max_lv);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 848e2db..273a62b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -769,6 +769,34 @@ int vg_set_extent_size(vg_t *vg, uint32_t new_size)
 	return 1;
 }
 
+int vg_set_max_lv(vg_t *vg, uint32_t max_lv)
+{
+	if (!(vg_status(vg) & RESIZEABLE_VG)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change MaxLogicalVolume", vg->name);
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!max_lv)
+			max_lv = 255;
+		else if (max_lv > 255) {
+			log_error("MaxLogicalVolume limit is 255");
+			return 0;
+		}
+	}
+
+	if (max_lv && max_lv < vg_visible_lvs(vg)) {
+		log_error("MaxLogicalVolume is less than the current number "
+			  "%d of LVs for %s", vg_visible_lvs(vg),
+			  vg->name);
+		return 0;
+	}
+	vg->max_lv = max_lv;
+
+	return 1;
+}
+
 /*
  * Separate metadata areas after splitting a VG.
  * Also accepts orphan VG as destination (for vgreduce).
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 4e77390..14df2f3 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -293,32 +293,11 @@ static int _vgchange_logicalvolume(struct cmd_context *cmd,
 {
 	uint32_t max_lv = arg_uint_value(cmd, logicalvolume_ARG, 0);
 
-	if (!(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" must be resizeable "
-			  "to change MaxLogicalVolume", vg->name);
-		return ECMD_FAILED;
-	}
-
-	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
-		if (!max_lv)
-			max_lv = 255;
-		else if (max_lv > 255) {
-			log_error("MaxLogicalVolume limit is 255");
-			return ECMD_FAILED;
-		}
-	}
-
-	if (max_lv && max_lv < vg_visible_lvs(vg)) {
-		log_error("MaxLogicalVolume is less than the current number "
-			  "%d of LVs for %s", vg_visible_lvs(vg),
-			  vg->name);
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg))
 		return ECMD_FAILED;
 
-	vg->max_lv = max_lv;
+	if (!vg_set_max_lv(vg, max_lv))
+		return ECMD_FAILED;
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		return ECMD_FAILED;
-- 
1.6.0.6


