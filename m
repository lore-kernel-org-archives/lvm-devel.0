From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Nov 2010 14:17:37 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/m ...
Message-ID: <20101101141737.16847.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-01 14:17:36

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/misc       : lvm-exec.c lvm-exec.h 
	tools          : lvresize.c 

Log message:
	Use new status code from fsadm check
	
	Patch updates exec_cmd() and adds 3rd parameter with pointer for
	status value, so caller might examine returned status code.
	If the passed pointer is NULL, behavior is unmodified.
	
	Patch allows to confinue with lvresize if the failure from fsadm check is
	caused by mounted filesystem as many of filesystem resize tools do support
	online filesystem resize. (originally user had to use flag '-n' to bypass
	this filesystem check)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1785&r2=1.1786
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.177&r2=1.178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/WHATS_NEW	2010/11/01 14:10:46	1.1785
+++ LVM2/WHATS_NEW	2010/11/01 14:17:35	1.1786
@@ -1,5 +1,6 @@
 Version 2.02.76 - 
 ===================================
+  Fix handling of online filesystem resize (using new fsadm return code).
   Add DIAGNOSTICS section to fsadm man page.
   Modify fsadm to return different status code for check of mounted filesystem.
   Update VG metadata only once in vgchange when making multiple changes.
--- LVM2/lib/activate/activate.c	2010/08/17 16:25:32	1.177
+++ LVM2/lib/activate/activate.c	2010/11/01 14:17:35	1.178
@@ -425,7 +425,7 @@
 	argv[1] = module;
 	argv[2] = NULL;
 
-	ret = exec_cmd(cmd, argv);
+	ret = exec_cmd(cmd, argv, NULL);
 #endif
 	return ret;
 }
--- LVM2/lib/misc/lvm-exec.c	2009/07/13 21:26:41	1.7
+++ LVM2/lib/misc/lvm-exec.c	2010/11/01 14:17:36	1.8
@@ -46,7 +46,7 @@
 /*
  * Execute and wait for external command
  */
-int exec_cmd(struct cmd_context *cmd, const char *const argv[])
+int exec_cmd(struct cmd_context *cmd, const char *const argv[], int *rstatus)
 {
 	pid_t pid;
 	int status;
@@ -71,6 +71,9 @@
 		_exit(errno);
 	}
 
+	if (rstatus)
+		*rstatus = -1;
+
 	/* Parent */
 	if (wait4(pid, &status, 0, NULL) != pid) {
 		log_error("wait4 child process %u failed: %s", pid,
@@ -84,9 +87,16 @@
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
--- LVM2/lib/misc/lvm-exec.h	2009/02/28 00:54:06	1.5
+++ LVM2/lib/misc/lvm-exec.h	2010/11/01 14:17:36	1.6
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
--- LVM2/tools/lvresize.c	2010/10/15 16:28:16	1.124
+++ LVM2/tools/lvresize.c	2010/11/01 14:17:36	1.125
@@ -129,6 +129,7 @@
 enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
 #define FSADM_CMD "fsadm"
 #define FSADM_CMD_MAX_ARGS 6
+#define FSADM_CHECK_FAILS_FOR_MOUNTED 3 /* shell exist status code */
 
 /*
  * FSADM_CMD --dry-run --verbose --force check lv_path
@@ -137,7 +138,8 @@
 static int _fsadm_cmd(struct cmd_context *cmd,
 		      const struct volume_group *vg,
 		      const struct lvresize_params *lp,
-		      enum fsadm_cmd_e fcmd)
+		      enum fsadm_cmd_e fcmd,
+		      int *status)
 {
 	char lv_path[PATH_MAX];
 	char size_buf[SIZE_BUF];
@@ -177,7 +179,7 @@
 
 	argv[i] = NULL;
 
-	return exec_cmd(cmd, argv);
+	return exec_cmd(cmd, argv, status);
 }
 
 static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
@@ -321,6 +323,7 @@
 	struct lv_segment *seg, *uninitialized_var(mirr_seg);
 	uint32_t seg_extents;
 	uint32_t sz, str;
+	int status;
 	struct dm_list *pvh = NULL;
 	int use_policy = arg_count(cmd, use_policies_ARG);
 
@@ -637,13 +640,16 @@
 
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
@@ -711,7 +717,7 @@
 	log_print("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
-	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE)) {
+	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
 		stack;
 		return ECMD_FAILED;
 	}


