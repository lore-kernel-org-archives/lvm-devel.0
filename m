From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  5 Feb 2013 14:56:03 +0100
Subject: [PATCH 2/6] thin: external origin cannot be changed
In-Reply-To: <cover.1360072297.git.zkabelac@redhat.com>
References: <cover.1360072297.git.zkabelac@redhat.com>
Message-ID: <811176b798b371d95db2f78cc73bc39d02bbf39a.1360072297.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not allow conversion of external origin into writeable LV,
and prohibit changing the external origin size.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvchange.c | 6 ++++++
 tools/lvresize.c | 9 +++++++++
 2 files changed, 15 insertions(+)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 0ea2e78..7ac4a39 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -36,6 +36,12 @@ static int lvchange_permission(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (lv_is_external_origin(lv)) {
+		log_error("Cannot change permissions of external origin "
+			  "\"%s\".", lv->name);
+		return 0;
+	}
+
 	if ((lv->status & MIRRORED) && (vg_is_clustered(lv->vg)) &&
 	    lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
 		log_error("Cannot change permissions of mirror \"%s\" "
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 4c9580d..d49da8a 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -390,6 +390,15 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
+	if (lv_is_external_origin(lvl->lv)) {
+		/*
+		 * Since external-origin can be activated read-only,
+		 * there is no way to use extended areas.
+		 */
+		log_error("Cannot resize external origin \"%s\".", lvl->lv->name);
+		return EINVALID_CMD_LINE;
+	}
+
 	if (lvl->lv->status & (RAID_IMAGE | RAID_META)) {
 		log_error("Cannot resize a RAID %s directly",
 			  (lvl->lv->status & RAID_IMAGE) ? "image" :
-- 
1.8.1.2


