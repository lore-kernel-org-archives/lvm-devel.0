From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 12 Jun 2009 08:30:20 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20090612083020.20443.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-12 08:30:19

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/locking    : cluster_locking.c locking.h 

Log message:
	Re-instate partial activation support in clustered mode. (mornfall)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1145&r2=1.1146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2009/06/09 15:31:36	1.1145
+++ LVM2/WHATS_NEW	2009/06/12 08:30:19	1.1146
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Re-instate partial activation support in clustered mode. (2.02.40)
   Use 'lvm lvresize' instead of 'lvresize' in fsadm.
   Do not use '-n' realine option in fsadm for busybox compatiblity.
   Update vgrename, vgsplit, and vgcreate to use vg_lock_newname.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/05/19 10:39:00	1.61
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/06/12 08:30:19	1.62
@@ -145,7 +145,8 @@
 {
 	static char buf[128];
 
-	sprintf(buf, "0x%x (%s%s)", flags,
+	sprintf(buf, "0x%x (%s%s%s)", flags,
+		flags & LCK_PARTIAL_MODE	  ? "PARTIAL_MODE " : "",
 		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC " : "",
 		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR " : "");
 
@@ -478,6 +479,8 @@
 	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
 		init_dmeventd_monitor(0);
 
+	cmd->partial_activation = (lock_flags & LCK_PARTIAL_MODE) ? 1 : 0;
+
 	switch (command) {
 	case LCK_LV_EXCLUSIVE:
 		status = do_activate_lv(resource, lock_flags, LKM_EXMODE);
@@ -516,6 +519,8 @@
 	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
 		init_dmeventd_monitor(DEFAULT_DMEVENTD_MONITOR);
 
+	cmd->partial_activation = 0;
+
 	/* clean the pool for another command */
 	dm_pool_empty(cmd->mem);
 	pthread_mutex_unlock(&lvm_lock);
--- LVM2/lib/locking/cluster_locking.c	2009/05/21 03:04:53	1.35
+++ LVM2/lib/locking/cluster_locking.c	2009/06/12 08:30:19	1.36
@@ -24,6 +24,7 @@
 #include "lvm-string.h"
 #include "locking.h"
 #include "locking_types.h"
+#include "toolcontext.h"
 
 #include <assert.h>
 #include <stddef.h>
@@ -298,7 +299,8 @@
 	return 1;
 }
 
-static int _lock_for_cluster(unsigned char clvmd_cmd, uint32_t flags, const char *name)
+static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
+			     uint32_t flags, const char *name)
 {
 	int status;
 	int i;
@@ -324,6 +326,9 @@
 	if (dmeventd_monitor_mode())
 		args[1] |= LCK_DMEVENTD_MONITOR_MODE;
 
+	if (cmd->partial_activation)
+		args[1] |= LCK_PARTIAL_MODE;
+
 	/*
 	 * VG locks are just that: locks, and have no side effects
 	 * so we only need to do them on the local node because all
@@ -389,7 +394,7 @@
 		if (flags == LCK_VG_BACKUP) {
 			log_very_verbose("Requesting backup of VG metadata for %s",
 					 resource);
-			return _lock_for_cluster(CLVMD_CMD_VG_BACKUP,
+			return _lock_for_cluster(cmd, CLVMD_CMD_VG_BACKUP,
 						 LCK_CLUSTER_VG, resource);
 		}
 
@@ -453,7 +458,7 @@
 			 flags);
 
 	/* Send a message to the cluster manager */
-	return _lock_for_cluster(clvmd_cmd, flags, lockname);
+	return _lock_for_cluster(cmd, clvmd_cmd, flags, lockname);
 }
 
 static int decode_lock_type(const char *response)
--- LVM2/lib/locking/locking.h	2009/05/21 03:04:53	1.47
+++ LVM2/lib/locking/locking.h	2009/06/12 08:30:19	1.48
@@ -85,6 +85,7 @@
 /*
  * Additional lock bits for cluster communication
  */
+#define LCK_PARTIAL_MODE        0x00000001U	/* Partial activation? */
 #define LCK_MIRROR_NOSYNC_MODE	0x00000002U	/* Mirrors don't require sync */
 #define LCK_DMEVENTD_MONITOR_MODE	0x00000004U	/* Register with dmeventd */
 


