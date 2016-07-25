From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 25 Jul 2016 15:51:41 +0000 (UTC)
Subject: master - lvmlockd: improve message for lock-start
Message-ID: <20160725155141.3B94960F46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70bad99894003c9e2fcec5db2b1f39cf09f75077
Commit:        70bad99894003c9e2fcec5db2b1f39cf09f75077
Parent:        94141c7797caabe23607a554fa7c6f44a4d570fc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 25 10:40:48 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 25 10:43:06 2016 -0500

lvmlockd: improve message for lock-start

Only print this for shared VGs, and include the
time it may take for sanlock.
---
 tools/vgchange.c |   43 +++++++++++++++++++++++++++++++++++--------
 1 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index fb751a2..910f33a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -15,6 +15,11 @@
 
 #include "tools.h"
 
+struct vgchange_params {
+	int lock_start_count;
+	unsigned int lock_start_sanlock : 1;
+};
+
 /*
  * Increments *count by the number of _new_ monitored devices.
  */
@@ -849,10 +854,12 @@ static int _passes_lock_start_filter(struct cmd_context *cmd,
 	return 0;
 }
 
-static int _vgchange_lock_start(struct cmd_context *cmd, struct volume_group *vg)
+static int _vgchange_lock_start(struct cmd_context *cmd, struct volume_group *vg,
+				struct vgchange_params *vp)
 {
 	const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
 	int auto_opt = 0;
+	int r;
 
 	if (!is_lockd_type(vg->lock_type))
 		return 1;
@@ -878,7 +885,14 @@ static int _vgchange_lock_start(struct cmd_context *cmd, struct volume_group *vg
 	}
 
 do_start:
-	return lockd_start_vg(cmd, vg, 0);
+	r = lockd_start_vg(cmd, vg, 0);
+
+	if (r)
+		vp->lock_start_count++;
+	if (!strcmp(vg->lock_type, "sanlock"))
+		vp->lock_start_sanlock = 1;
+
+	return r;
 }
 
 static int _vgchange_lock_stop(struct cmd_context *cmd, struct volume_group *vg)
@@ -888,8 +902,9 @@ static int _vgchange_lock_stop(struct cmd_context *cmd, struct volume_group *vg)
 
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
-			   struct processing_handle *handle __attribute__((unused)))
+			   struct processing_handle *handle)
 {
+	struct vgchange_params *vp = (struct vgchange_params *)handle->custom_handle;
 	int ret = ECMD_PROCESSED;
 	unsigned i;
 	struct lv_list *lvl;
@@ -1002,7 +1017,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			return_ECMD_FAILED;
 
 	if (arg_is_set(cmd, lockstart_ARG)) {
-		if (!_vgchange_lock_start(cmd, vg))
+		if (!_vgchange_lock_start(cmd, vg, vp))
 			return_ECMD_FAILED;
 	} else if (arg_is_set(cmd, lockstop_ARG)) {
 		if (!_vgchange_lock_stop(cmd, vg))
@@ -1092,6 +1107,8 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct processing_handle *handle;
+	struct vgchange_params vp = { 0 };
 	uint32_t flags = 0;
 	int ret;
 
@@ -1216,24 +1233,34 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, lockstart_ARG) || arg_is_set(cmd, lockstop_ARG))
 		flags |= READ_ALLOW_EXPORTED;
 
-	ret = process_each_vg(cmd, argc, argv, NULL, NULL, flags, 0, NULL, &vgchange_single);
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &vp;
+
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, flags, 0, handle, &vgchange_single);
 
 	/* Wait for lock-start ops that were initiated in vgchange_lockstart. */
 
-	if (arg_is_set(cmd, lockstart_ARG)) {
+	if (arg_is_set(cmd, lockstart_ARG) && vp.lock_start_count) {
 		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
 
 		if (!lockd_gl(cmd, "un", 0))
 			stack;
 
 		if (!start_opt || !strcmp(start_opt, "auto")) {
-			log_print_unless_silent("Starting locking.  Waiting until locks are ready...");
+			if (vp.lock_start_sanlock)
+				log_print_unless_silent("Starting locking.  Waiting for sanlock may take 20 sec to 3 min...");
+			else
+				log_print_unless_silent("Starting locking.  Waiting until locks are ready...");
 			lockd_start_wait(cmd);
-
 		} else if (!strcmp(start_opt, "nowait") || !strcmp(start_opt, "autonowait")) {
 			log_print_unless_silent("Starting locking.  VG can only be read until locks are ready.");
 		}
 	}
 
+	destroy_processing_handle(cmd, handle);
 	return ret;
 }


