From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jun 2017 08:04:20 -0400
Subject: master - lvresize: support passing --yes to fsadm
Message-ID: <201706211204.v5LC4K30005870@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3f63693a4ea76975fb01f8456f1f263b029b07f
Commit:        e3f63693a4ea76975fb01f8456f1f263b029b07f
Parent:        48f06005ab53420241e0c1da3a56a8f5c1a28974
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 21 14:02:57 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 21 14:03:29 2017 +0200

lvresize: support passing --yes to fsadm

Since fsadm now needs --yes to pass prompting operations,
we need to pass --yes from  lvresize to fsadm.
---
 lib/metadata/lv_manip.c          |   12 ++++++++----
 lib/metadata/metadata-exported.h |    1 +
 tools/lvresize.c                 |    1 +
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9e98ee3..c431868 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4578,6 +4578,7 @@ enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
 static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 		      struct logical_volume *lv,
 		      uint32_t extents,
+		      int yes,
 		      int force,
 		      int *status)
 {
@@ -4585,7 +4586,7 @@ static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 	struct cmd_context *cmd = vg->cmd;
 	char lv_path[PATH_MAX];
 	char size_buf[SIZE_BUF];
-	const char *argv[FSADM_CMD_MAX_ARGS + 2];
+	const char *argv[FSADM_CMD_MAX_ARGS + 4];
 	unsigned i = 0;
 
 	argv[i++] = find_config_tree_str(cmd, global_fsadm_executable_CFG, NULL);
@@ -4596,6 +4597,9 @@ static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 	if (verbose_level() >= _LOG_NOTICE)
 		argv[i++] = "--verbose";
 
+	if (yes)
+		argv[i++] = "--yes";
+
 	if (force)
 		argv[i++] = "--force";
 
@@ -5498,7 +5502,7 @@ int lv_resize(struct logical_volume *lv,
 
 	if (lp->resizefs) {
 		if (!lp->nofsck &&
-		    !_fsadm_cmd(FSADM_CMD_CHECK, lv, 0, lp->force, &status)) {
+		    !_fsadm_cmd(FSADM_CMD_CHECK, lv, 0, lp->yes, lp->force, &status)) {
 			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
 				log_error("Filesystem check failed.");
 				return 0;
@@ -5508,7 +5512,7 @@ int lv_resize(struct logical_volume *lv,
 
 		/* FIXME forks here */
 		if ((lp->resize == LV_REDUCE) &&
-		    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->force, NULL)) {
+		    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->yes, lp->force, NULL)) {
 			log_error("Filesystem resize failed.");
 			return 0;
 		}
@@ -5589,7 +5593,7 @@ out:
 				display_lvname(lv));
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
-	    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->force, NULL))
+	    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->yes, lp->force, NULL))
 		return_0;
 
 	ret = 1;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c4bebd0..6c3d8d7 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -649,6 +649,7 @@ struct lvresize_params {
 	int use_policies;
 
 	alloc_policy_t alloc;
+	int yes;
 	int force;
 	int nosync;
 	int nofsck;
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 1d59239..9b061ac 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -147,6 +147,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->argv = ++argv;
 
 	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, 0);
+	lp->yes = arg_is_set(cmd, yes_ARG);
 	lp->force = arg_is_set(cmd, force_ARG);
 	lp->nofsck = arg_is_set(cmd, nofsck_ARG);
 	lp->nosync = arg_is_set(cmd, nosync_ARG);


