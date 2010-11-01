From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  1 Nov 2010 13:53:53 +0100
Subject: [PATCH 3/3] Handle new return code from fsadm check
In-Reply-To: <cover.1288614451.git.zkabelac@redhat.com>
References: <cover.1288614451.git.zkabelac@redhat.com>
Message-ID: <8eaa0e63e647d6c820e6ab67d961f85911d3c692.1288614451.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch updated  exec_cmd and adds 3rd parameter with pointer for
status value, so caller might examine returned status from exec.
If the passed arguments is NULL, behavior is unmodified.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |    2 +-
 lib/misc/lvm-exec.c     |   14 ++++++++++++--
 lib/misc/lvm-exec.h     |    4 ++--
 tools/lvresize.c        |   20 +++++++++++++-------
 4 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 40c0fde..474b70b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -425,7 +425,7 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 	argv[1] = module;
 	argv[2] = NULL;
 
-	ret = exec_cmd(cmd, argv);
+	ret = exec_cmd(cmd, argv, NULL);
 #endif
 	return ret;
 }
diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index d332aaa..5cad79e 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -46,7 +46,7 @@ static char *_verbose_args(const char *const argv[], char *buf, size_t sz)
 /*
  * Execute and wait for external command
  */
-int exec_cmd(struct cmd_context *cmd, const char *const argv[])
+int exec_cmd(struct cmd_context *cmd, const char *const argv[], int *rstatus)
 {
 	pid_t pid;
 	int status;
@@ -71,6 +71,9 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[])
 		_exit(errno);
 	}
 
+	if (rstatus)
+		*rstatus = -1;
+
 	/* Parent */
 	if (wait4(pid, &status, 0, NULL) != pid) {
 		log_error("wait4 child process %u failed: %s", pid,
@@ -84,9 +87,16 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[])
 	}
 
 	if (WEXITSTATUS(status)) {
-		log_error("%s failed: %u", argv[0], WEXITSTATUS(status));
+		if (rstatus) {
+			*rstatus = WEXITSTATUS(status);
+			log_verbose("%s failed: %u", argv[0], *rstatus);
+		} else
+			log_error("%s failed: %u", argv[0], WEXITSTATUS(status));
 		return 0;
 	}
 
+	if (rstatus)
+		*rstatus = 0;
+
 	return 1;
 }
diff --git a/lib/misc/lvm-exec.h b/lib/misc/lvm-exec.h
index 6afc3a7..6d984f8 100644
--- a/lib/misc/lvm-exec.h
+++ b/lib/misc/lvm-exec.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -19,6 +19,6 @@
 #include "lib.h"
 
 struct cmd_context;
-int exec_cmd(struct cmd_context *cmd, const char *const argv[]);
+int exec_cmd(struct cmd_context *cmd, const char *const argv[], int *rstatus);
 
 #endif
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 018dfc2..ca707f4 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -129,6 +129,7 @@ static int _request_confirmation(struct cmd_context *cmd,
 enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
 #define FSADM_CMD "fsadm"
 #define FSADM_CMD_MAX_ARGS 6
+#define FSADM_CHECK_FAILS_FOR_MOUNTED 3 /* shell exist status code */
 
 /*
  * FSADM_CMD --dry-run --verbose --force check lv_path
@@ -137,7 +138,8 @@ enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
 static int _fsadm_cmd(struct cmd_context *cmd,
 		      const struct volume_group *vg,
 		      const struct lvresize_params *lp,
-		      enum fsadm_cmd_e fcmd)
+		      enum fsadm_cmd_e fcmd,
+		      int *status)
 {
 	char lv_path[PATH_MAX];
 	char size_buf[SIZE_BUF];
@@ -177,7 +179,7 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 
 	argv[i] = NULL;
 
-	return exec_cmd(cmd, argv);
+	return exec_cmd(cmd, argv, status);
 }
 
 static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
@@ -321,6 +323,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	struct lv_segment *seg, *uninitialized_var(mirr_seg);
 	uint32_t seg_extents;
 	uint32_t sz, str;
+	int status;
 	struct dm_list *pvh = NULL;
 	int use_policy = arg_count(cmd, use_policies_ARG);
 
@@ -637,13 +640,16 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (lp->resizefs) {
 		if (!lp->nofsck &&
-		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK)) {
-			stack;
-			return ECMD_FAILED;
+		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK, &status)) {
+			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
+				stack;
+				return ECMD_FAILED;
+			}
+                        /* some filesystems supports online resize */
 		}
 
 		if ((lp->resize == LV_REDUCE) &&
-		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE)) {
+		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
 			stack;
 			return ECMD_FAILED;
 		}
@@ -711,7 +717,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	log_print("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
-	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE)) {
+	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
 		stack;
 		return ECMD_FAILED;
 	}
-- 
1.7.3.2


