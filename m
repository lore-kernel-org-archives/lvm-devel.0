From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Jan 2010 16:05:13 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20100105160513.12547.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-05 16:05:12

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c lvm-functions.c lvm-functions.h 

Log message:
	Move processing of VG locks to separate function (similar to LV locks).
	
	And print some debugging info.
	
	No functional change in this patch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1357&r2=1.1358
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/WHATS_NEW	2010/01/05 16:03:37	1.1357
+++ LVM2/WHATS_NEW	2010/01/05 16:05:12	1.1358
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Move processing of VG locks to separate function in clvmd.
   Properly decode flags even for VG locks.
   Properly handle precommitted flag in cache when commited data only present.
   Resume renamed volumes in reverse order to preserve memlock pairing.
--- LVM2/daemons/clvmd/clvmd-command.c	2009/12/09 18:42:03	1.29
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/01/05 16:05:12	1.30
@@ -119,15 +119,12 @@
 		break;
 
 	case CLVMD_CMD_LOCK_VG:
+		lock_cmd = args[0];
+		lock_flags = args[1];
 		lockname = &args[2];
 		/* Check to see if the VG is in use by LVM1 */
 		status = do_check_lvm1(lockname);
-		/* P_#global causes a full cache refresh */
-		if (!strcmp(lockname, "P_" VG_GLOBAL))
-			do_refresh_cache();
-		else
-			drop_metadata(lockname + 2);
-
+		do_lock_vg(lock_cmd, lock_flags, lockname);
 		break;
 
 	case CLVMD_CMD_LOCK_LV:
--- LVM2/daemons/clvmd/lvm-functions.c	2010/01/05 16:03:37	1.79
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/01/05 16:05:12	1.80
@@ -676,12 +676,23 @@
 }
 
 /*
- * Drop lvmcache metadata
+ * Handle VG lock - drop metadata or update lvmcache state
  */
-void drop_metadata(const char *vgname)
+void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 {
-	DEBUGLOG("Dropping metadata for VG %s\n", vgname);
+	char *vgname = resource + 2;
+
+	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
+		 resource, decode_locking_cmd(command), decode_flags(lock_flags), memlock());
+
+	/* P_#global causes a full cache refresh */
+	if (!strcmp(resource, "P_" VG_GLOBAL)) {
+		do_refresh_cache();
+		return;
+	}
+
 	pthread_mutex_lock(&lvm_lock);
+	DEBUGLOG("Dropping metadata for VG %s\n", vgname);
 	lvmcache_drop_metadata(vgname);
 	pthread_mutex_unlock(&lvm_lock);
 }
--- LVM2/daemons/clvmd/lvm-functions.h	2009/06/15 12:15:23	1.11
+++ LVM2/daemons/clvmd/lvm-functions.h	2010/01/05 16:05:12	1.12
@@ -35,6 +35,7 @@
 extern int hold_unlock(char *resource);
 extern int hold_lock(char *resource, int mode, int flags);
 extern char *get_last_lvm_error(void);
-extern void drop_metadata(const char *vgname);
+extern void do_lock_vg(unsigned char command, unsigned char lock_flags,
+		      char *resource);
 
 #endif


