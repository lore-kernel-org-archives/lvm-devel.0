From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 19:01:28 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20091209190128.30634.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 19:01:28

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Add memlock information to do_lock_lv debug output.
	
	This helps a lot to detect that something strange happened.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1347&r2=1.1348
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/WHATS_NEW	2009/12/09 19:00:16	1.1347
+++ LVM2/WHATS_NEW	2009/12/09 19:01:27	1.1348
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Add memlock information to do_lock_lv debug output.
   Never use distributed lock for LV in non-clustered VG.
   Allow implicit lock conversion in pre/post callbacks on local node.
   Allow implicit convert to the same cluster lock mode.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 19:00:16	1.76
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 19:01:28	1.77
@@ -477,8 +477,8 @@
 {
 	int status = 0;
 
-	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s\n",
-		 resource, decode_locking_cmd(command), decode_flags(lock_flags));
+	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
+		 resource, decode_locking_cmd(command), decode_flags(lock_flags), memlock());
 
 	if (!cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
@@ -541,7 +541,7 @@
 	dm_pool_empty(cmd->mem);
 	pthread_mutex_unlock(&lvm_lock);
 
-	DEBUGLOG("Command return is %d\n", status);
+	DEBUGLOG("Command return is %d, memlock is %d\n", status, memlock());
 	return status;
 }
 


