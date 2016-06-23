From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:51 +0000 (UTC)
Subject: master - lvresize: pass only needed params to _fsadm_cmd
Message-ID: <20160623130151.97A10608F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5013999c8bd3f2b455ab6fe436df4884da6ebaf5
Commit:        5013999c8bd3f2b455ab6fe436df4884da6ebaf5
Parent:        d30c2cec880e22ac2ce6cb6a1ee09584f2dc6aae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 15 15:46:03 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:09 2016 +0200

lvresize: pass only needed params to _fsadm_cmd

Do not pass whole lvresize_params into _fsadm_cmd,
and give it only needed args.
---
 lib/metadata/lv_manip.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f4abc4f..487d7f9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4387,12 +4387,14 @@ enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
  * FSADM_CMD --dry-run --verbose --force check lv_path
  * FSADM_CMD --dry-run --verbose --force resize lv_path size
  */
-static int _fsadm_cmd(struct cmd_context *cmd,
-		      const struct volume_group *vg,
-		      const struct lvresize_params *lp,
-		      enum fsadm_cmd_e fcmd,
+static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
+		      struct logical_volume *lv,
+		      uint32_t extents,
+		      int force,
 		      int *status)
 {
+	struct volume_group *vg = lv->vg;
+	struct cmd_context *cmd = vg->cmd;
 	char lv_path[PATH_MAX];
 	char size_buf[SIZE_BUF];
 	const char *argv[FSADM_CMD_MAX_ARGS + 2];
@@ -4406,7 +4408,7 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 	if (verbose_level() >= _LOG_NOTICE)
 		argv[i++] = "--verbose";
 
-	if (lp->force)
+	if (force)
 		argv[i++] = "--force";
 
 	argv[i++] = (fcmd == FSADM_CMD_RESIZE) ? "resize" : "check";
@@ -4415,8 +4417,8 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 		*status = -1;
 
 	if (dm_snprintf(lv_path, sizeof(lv_path), "%s%s/%s", cmd->dev_dir,
-			vg->name, lp->lv_name) < 0) {
-		log_error("Couldn't create LV path for %s", lp->lv_name);
+			vg->name, lv->name) < 0) {
+		log_error("Couldn't create LV path for %s.", display_lvname(lv));
 		return 0;
 	}
 
@@ -4424,8 +4426,8 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 
 	if (fcmd == FSADM_CMD_RESIZE) {
 		if (dm_snprintf(size_buf, sizeof(size_buf), FMTu64 "K",
-				(uint64_t) lp->extents * (vg->extent_size / 2)) < 0) {
-			log_error("Couldn't generate new LV size string");
+				(uint64_t) extents * (vg->extent_size / 2)) < 0) {
+			log_error("Couldn't generate new LV size string.");
 			return 0;
 		}
 
@@ -5238,7 +5240,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 
 	if (lp->resizefs) {
 		if (!lp->nofsck &&
-		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK, &status)) {
+		    !_fsadm_cmd(FSADM_CMD_CHECK, lv, 0, lp->force, &status)) {
 			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
 				log_error("Filesystem check failed.");
 				return NULL;
@@ -5248,7 +5250,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 
 		/* FIXME forks here */
 		if ((lp->resize == LV_REDUCE) &&
-		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
+		    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->force, NULL)) {
 			log_error("Filesystem resize failed.");
 			return NULL;
 		}
@@ -5412,7 +5414,7 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 				display_lvname(lv));
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
-	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL))
+	    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->force, NULL))
 		return_0;
 
 	return 1;


