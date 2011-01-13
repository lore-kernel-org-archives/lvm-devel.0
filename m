From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Jan 2011 14:51:39 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/m ...
Message-ID: <20110113145139.10590.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-13 14:51:35

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/misc       : lvm-exec.c lvm-exec.h 
	tools          : lvresize.c 

Log message:
	Add exec_cmd paramater  sync_needed
	
	As sync_local_dev_names() cannot be called within activation context,
	add new parametr which allows to select if the sync call is needed
	before executing new command.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1878&r2=1.1879
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.185&r2=1.186
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/WHATS_NEW	2011/01/12 20:42:50	1.1878
+++ LVM2/WHATS_NEW	2011/01/13 14:51:32	1.1879
@@ -1,5 +1,6 @@
 Version 2.02.81 -
 ===================================
+  Extend exec_cmd params to specify, when device sync is needed.
   Replace fs_unlock by sync_local_dev_names to notify local clvmd. (2.02.80)
   Introduce sync_local_dev_names and CLVMD_CMD_SYNC_NAMES to issue fs_unlock.
   Accept fusion fio in device type filter.
--- LVM2/lib/activate/activate.c	2011/01/10 14:02:31	1.185
+++ LVM2/lib/activate/activate.c	2011/01/13 14:51:33	1.186
@@ -424,7 +424,7 @@
 	argv[1] = module;
 	argv[2] = NULL;
 
-	ret = exec_cmd(cmd, argv, NULL);
+	ret = exec_cmd(cmd, argv, NULL, 0);
 #endif
 	return ret;
 }
--- LVM2/lib/misc/lvm-exec.c	2011/01/12 20:42:51	1.11
+++ LVM2/lib/misc/lvm-exec.c	2011/01/13 14:51:33	1.12
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -47,7 +47,8 @@
 /*
  * Execute and wait for external command
  */
-int exec_cmd(struct cmd_context *cmd, const char *const argv[], int *rstatus)
+int exec_cmd(struct cmd_context *cmd, const char *const argv[],
+	     int *rstatus, int sync_needed)
 {
 	pid_t pid;
 	int status;
@@ -55,7 +56,12 @@
 
 	log_verbose("Executing: %s", _verbose_args(argv, buf, sizeof(buf)));
 
-	sync_local_dev_names(cmd); /* Flush ops and reset dm cookie */
+	if (rstatus)
+		*rstatus = -1;
+
+	if (sync_needed)
+		if (!sync_local_dev_names(cmd)) /* Flush ops and reset dm cookie */
+			return_0;
 
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));
@@ -74,9 +80,6 @@
 		_exit(errno);
 	}
 
-	if (rstatus)
-		*rstatus = -1;
-
 	/* Parent */
 	if (wait4(pid, &status, 0, NULL) != pid) {
 		log_error("wait4 child process %u failed: %s", pid,
--- LVM2/lib/misc/lvm-exec.h	2010/11/01 14:17:36	1.6
+++ LVM2/lib/misc/lvm-exec.h	2011/01/13 14:51:33	1.7
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -19,6 +19,22 @@
 #include "lib.h"
 
 struct cmd_context;
-int exec_cmd(struct cmd_context *cmd, const char *const argv[], int *rstatus);
+
+/**
+ * Execute command with paramaters and return status
+ *
+ * \param rstatus
+ * Returns command's exit status code.
+ *
+ * \param sync_needed
+ * Bool specifying whether local devices needs to be synchronized
+ * before executing command.
+ * Note: You cannot synchronize devices within activation context.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int exec_cmd(struct cmd_context *cmd, const char *const argv[],
+	     int *rstatus, int sync_needed);
 
 #endif
--- LVM2/tools/lvresize.c	2010/12/08 20:50:51	1.127
+++ LVM2/tools/lvresize.c	2011/01/13 14:51:34	1.128
@@ -179,7 +179,7 @@
 
 	argv[i] = NULL;
 
-	return exec_cmd(cmd, argv, status);
+	return exec_cmd(cmd, argv, status, 1);
 }
 
 static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,


