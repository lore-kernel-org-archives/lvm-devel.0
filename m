From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  7 Jul 2009 03:50:02 -0400
Subject: [PATCH 1/7] Update vg_change_pesize() to contain all validity checks.
In-Reply-To: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
References: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1246953008-27609-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update vg_change_pesize() to contain all validity checks.
It would be nice to have one function that does all the validation
and setting of the VG's pesize.  However, currently some checks
are in the higher-level function _vgchange_pesize(), and some
checks are in the lower function vg_change_pesize().
This patch moves most of the higher-level checks inside
vg_change_pesize.  In one case a failure return code is
changed from ECMD_FAILED to EINVALID_CMD_LINE.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   30 ++++++++++++++++++++++++++++++
 tools/vgchange.c        |   27 ++-------------------------
 2 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index fda07be..c042d60 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -636,6 +636,36 @@ int vg_change_pesize(struct cmd_context *cmd __attribute((unused)),
 	struct pv_segment *pvseg;
 	uint32_t s;
 
+	if (!(vg_status(vg) & RESIZEABLE_VG)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change PE size", vg->name);
+		return 0;
+	}
+
+	if (!new_size) {
+		log_error("Physical extent size may not be zero");
+		return 0;
+	}
+
+	if (new_size == vg->extent_size) {
+		log_error("Physical extent size of VG %s is already %s",
+			  vg->name, display_size(vg->cmd, (uint64_t) new_size));
+		return 1;
+	}
+
+	if (new_size & (new_size - 1)) {
+		log_error("Physical extent size must be a power of 2.");
+		return 0;
+	}
+
+	if (new_size > vg->extent_size) {
+		if ((uint64_t) vg->extent_size * vg->extent_count % new_size) {
+			/* FIXME Adjust used PV sizes instead */
+			log_error("New extent size is not a perfect fit");
+			return 0;
+		}
+	}
+
 	vg->extent_size = new_size;
 
 	if (vg->fid->fmt->ops->vg_setup &&
diff --git a/tools/vgchange.c b/tools/vgchange.c
index a5121fc..1609e01 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -381,48 +381,25 @@ static int _vgchange_pesize(struct cmd_context *cmd, struct volume_group *vg)
 {
 	uint32_t extent_size;
 
-	if (!(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" must be resizeable "
-			  "to change PE size", vg->name);
-		return ECMD_FAILED;
-	}
-
 	if (arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
 		log_error("Physical extent size may not be negative");
 		return EINVALID_CMD_LINE;
 	}
 
 	extent_size = arg_uint_value(cmd, physicalextentsize_ARG, 0);
-	if (!extent_size) {
-		log_error("Physical extent size may not be zero");
-		return EINVALID_CMD_LINE;
-	}
-
+	/* FIXME: remove check - redundant with vg_change_pesize */
 	if (extent_size == vg->extent_size) {
 		log_error("Physical extent size of VG %s is already %s",
 			  vg->name, display_size(cmd, (uint64_t) extent_size));
 		return ECMD_PROCESSED;
 	}
 
-	if (extent_size & (extent_size - 1)) {
-		log_error("Physical extent size must be a power of 2.");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (extent_size > vg->extent_size) {
-		if ((uint64_t) vg->extent_size * vg->extent_count % extent_size) {
-			/* FIXME Adjust used PV sizes instead */
-			log_error("New extent size is not a perfect fit");
-			return EINVALID_CMD_LINE;
-		}
-	}
-
 	if (!archive(vg))
 		return ECMD_FAILED;
 
 	if (!vg_change_pesize(cmd, vg, extent_size)) {
 		stack;
-		return ECMD_FAILED;
+		return EINVALID_CMD_LINE;
 	}
 
 	if (!vg_write(vg) || !vg_commit(vg))
-- 
1.6.0.6


