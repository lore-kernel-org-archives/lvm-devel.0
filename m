From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 23 Feb 2013 09:42:02 +0000 (UTC)
Subject: master - thin: external origin cannot be changed
Message-ID: <20130223094202.B4BE541D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=386f3d5a5e6a8b147793c8e59d72c4496144ec2c
Commit:        386f3d5a5e6a8b147793c8e59d72c4496144ec2c
Parent:        87331dc41979b649d0b0603c26ff421516fe944e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 14:03:43 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 23 10:37:01 2013 +0100

thin: external origin cannot be changed

Do not allow conversion of external origin into writeable LV,
and prohibit changing the external origin size.

If the snapshot origin is also external origin, merge is prohibited.
---
 tools/lvchange.c  |    6 ++++++
 tools/lvconvert.c |    6 ++++++
 tools/lvresize.c  |    9 +++++++++
 3 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 07015e7..67db083 100644
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
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9b41722..962a35a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2109,6 +2109,12 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 				  lv->name);
 			return ECMD_FAILED;
 		}
+		if (lv_is_external_origin(origin_from_cow(lv))) {
+			log_error("Cannot merge snapshot \"%s\" into "
+				  "the read-only external origin \"%s\".",
+				  lv->name, origin_from_cow(lv)->name);
+			return ECMD_FAILED;
+		}
 	        if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)
 		    && info.exists && info.live_table &&
 		    (!lv_snapshot_percent(lv, &snap_percent) ||
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


