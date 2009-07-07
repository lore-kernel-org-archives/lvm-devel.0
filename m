From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  7 Jul 2009 03:50:06 -0400
Subject: [PATCH 5/7] Add vg_set_max_pv() liblvm function and move vgchange logic inside.
In-Reply-To: <1246953008-27609-5-git-send-email-dwysocha@redhat.com>
References: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-2-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-3-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-4-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1246953008-27609-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add vg_set_max_pv() liblvm function and move vgchange logic inside.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   27 +++++++++++++++++++++++++++
 tools/vgchange.c                 |   25 ++-----------------------
 3 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b817f5f..c95f5f3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -442,6 +442,7 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
 int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
 int vg_set_max_lv(vg_t *vg, uint32_t max_lv);
+int vg_set_max_pv(vg_t *vg, uint32_t max_pv);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ab9a72b..5b563e3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -802,6 +802,33 @@ int vg_set_max_lv(vg_t *vg, uint32_t max_lv)
 	return 1;
 }
 
+int vg_set_max_pv(vg_t *vg, uint32_t max_pv)
+{
+	if (!(vg_status(vg) & RESIZEABLE_VG)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change MaxPhysicalVolumes", vg->name);
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!max_pv)
+			max_pv = 255;
+		else if (max_pv > 255) {
+			log_error("MaxPhysicalVolume limit is 255");
+			return 0;
+		}
+	}
+
+	if (max_pv && max_pv < vg->pv_count) {
+		log_error("MaxPhysicalVolumes is less than the current number "
+			  "%d of PVs for \"%s\"", vg->pv_count,
+			  vg->name);
+		return 0;
+	}
+	vg->max_pv = max_pv;
+	return 1;
+}
+
 /*
  * Separate metadata areas after splitting a VG.
  * Also accepts orphan VG as destination (for vgreduce).
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 6bb837e..a095d9e 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -314,37 +314,16 @@ static int _vgchange_physicalvolumes(struct cmd_context *cmd,
 {
 	uint32_t max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG, 0);
 
-	if (!(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" must be resizeable "
-			  "to change MaxPhysicalVolumes", vg->name);
-		return ECMD_FAILED;
-	}
-
 	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, 0) == SIGN_MINUS) {
 		log_error("MaxPhysicalVolumes may not be negative");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
-		if (!max_pv)
-			max_pv = 255;
-		else if (max_pv > 255) {
-			log_error("MaxPhysicalVolume limit is 255");
-			return ECMD_FAILED;
-		}
-	}
-
-	if (max_pv && max_pv < vg->pv_count) {
-		log_error("MaxPhysicalVolumes is less than the current number "
-			  "%d of PVs for \"%s\"", vg->pv_count,
-			  vg->name);
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg))
 		return ECMD_FAILED;
 
-	vg->max_pv = max_pv;
+	if (!vg_set_max_pv(vg, max_pv))
+		return ECMD_FAILED;
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		return ECMD_FAILED;
-- 
1.6.0.6


