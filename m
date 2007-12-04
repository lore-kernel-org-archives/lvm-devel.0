From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 4 Dec 2007 15:39:27 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvm.h daemons/ ...
Message-ID: <20071204153927.6976.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-12-04 15:39:26

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvm.h clvmd-command.c lvm-functions.c 
	                 lvm-functions.h 
	lib/locking    : cluster_locking.c 

Log message:
	When we unlock a VG tell the clvmds to see if a backup of the metadata needs
	to be done.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.740&r2=1.741
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvm.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2007/11/22 13:57:20	1.740
+++ LVM2/WHATS_NEW	2007/12/04 15:39:25	1.741
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Make clvmd backup vg metadata on remote nodes.
   Refactor pvmove allocation code.
   Decode cluster locking state in log message.
   Change file locking state messages from debug to very verbose.
--- LVM2/daemons/clvmd/clvm.h	2007/08/17 11:51:23	1.5
+++ LVM2/daemons/clvmd/clvm.h	2007/12/04 15:39:26	1.6
@@ -67,4 +67,5 @@
 #define CLVMD_CMD_REFRESH	    40
 #define CLVMD_CMD_GET_CLUSTERNAME   41
 #define CLVMD_CMD_SET_DEBUG	    42
+#define CLVMD_CMD_VG_BACKUP	    43
 #endif
--- LVM2/daemons/clvmd/clvmd-command.c	2007/08/23 15:43:20	1.18
+++ LVM2/daemons/clvmd/clvmd-command.c	2007/12/04 15:39:26	1.19
@@ -153,6 +153,10 @@
 			*retlen = strlen(*buf)+1;
 		break;
 
+	case CLVMD_CMD_VG_BACKUP:
+		lvm_do_backup(&args[2]);
+		break;
+
 	default:
 		/* Won't get here because command is validated in pre_command */
 		break;
@@ -260,6 +264,7 @@
 	case CLVMD_CMD_REFRESH:
 	case CLVMD_CMD_GET_CLUSTERNAME:
 	case CLVMD_CMD_SET_DEBUG:
+	case CLVMD_CMD_VG_BACKUP:
 		break;
 
 	default:
@@ -289,6 +294,7 @@
 		break;
 
 	case CLVMD_CMD_LOCK_VG:
+	case CLVMD_CMD_VG_BACKUP:
 		/* Nothing to do here */
 		break;
 
--- LVM2/daemons/clvmd/lvm-functions.c	2007/11/14 13:37:51	1.35
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/12/04 15:39:26	1.36
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -46,6 +46,7 @@
 #include "log.h"
 #include "activate.h"
 #include "locking.h"
+#include "archiver.h"
 #include "defaults.h"
 
 static struct cmd_context *cmd = NULL;
@@ -550,7 +551,7 @@
 {
 
 	/* Send messages to the normal LVM2 logging system too,
-	   so we get debug output when it's asked for. 
+	   so we get debug output when it's asked for.
  	   We need to NULL the function ptr otherwise it will just call
 	   back into here! */
 	init_log_fn(NULL);
@@ -600,6 +601,21 @@
 	pthread_mutex_init(&lvm_lock, NULL);
 }
 
+/* Backups up the LVM metadata if it's changed */
+void lvm_do_backup(char *vgname)
+{
+	struct volume_group * vg;
+	int consistent;
+
+	DEBUGLOG("Triggering backup of VG metadata for %s\n", vgname);
+
+	vg = vg_read(cmd, vgname, NULL /*vgid*/, &consistent);
+	if (vg)
+		check_current_backup(vg);
+	else
+		log_error("Error backing up metadata, can't find VG for group %s", vgname);
+}
+
 /* Called to initialise the LVM context of the daemon */
 int init_lvm(int using_gulm)
 {
@@ -614,6 +630,9 @@
 	init_debug(cmd->current_settings.debug);
 	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	set_activation(cmd->current_settings.activation);
+	archive_enable(cmd, cmd->current_settings.archive);
+	backup_enable(cmd, cmd->current_settings.backup);
+	cmd->cmd_line = (char *)"clvmd";
 
 	/* Check lvm.conf is setup for cluster-LVM */
 	check_config();
--- LVM2/daemons/clvmd/lvm-functions.h	2007/08/07 09:06:05	1.5
+++ LVM2/daemons/clvmd/lvm-functions.h	2007/12/04 15:39:26	1.6
@@ -28,7 +28,7 @@
 extern int do_refresh_cache(void);
 extern int init_lvm(int using_gulm);
 extern void init_lvhash(void);
-
+extern void lvm_do_backup(char *vgname);
 extern int hold_unlock(char *resource);
 extern int hold_lock(char *resource, int mode, int flags);
 extern void unlock_all(void);
--- LVM2/lib/locking/cluster_locking.c	2007/11/16 21:16:20	1.22
+++ LVM2/lib/locking/cluster_locking.c	2007/12/04 15:39:26	1.23
@@ -295,7 +295,7 @@
 	return 1;
 }
 
-static int _lock_for_cluster(unsigned char cmd, uint32_t flags, char *name)
+static int _lock_for_cluster(unsigned char cmd, uint32_t flags, const char *name)
 {
 	int status;
 	int i;
@@ -378,6 +378,7 @@
 {
 	char lockname[PATH_MAX];
 	int cluster_cmd = 0;
+	int ret;
 	const char *lock_scope;
 	const char *lock_type = "";
 
@@ -447,7 +448,13 @@
 			 flags);
 
 	/* Send a message to the cluster manager */
-	return _lock_for_cluster(cluster_cmd, flags, lockname);
+	ret = _lock_for_cluster(cluster_cmd, flags, lockname);
+
+	/* If we are unlocking a VG, then trigger remote metadata backups */
+	if (ret && cluster_cmd == CLVMD_CMD_LOCK_VG && ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)) {
+		ret = _lock_for_cluster(CLVMD_CMD_VG_BACKUP, LCK_CLUSTER_VG, resource);
+	}
+	return ret;
 }
 
 #ifdef CLUSTER_LOCKING_INTERNAL


