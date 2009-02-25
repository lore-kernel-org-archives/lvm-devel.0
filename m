From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 25 Feb 2009 14:33:02 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-corosync.c
Message-ID: <20090225143302.4435.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-02-25 14:33:01

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-corosync.c 

Log message:
	Fix error returns in clvmd-corosync interface to DLM.
	
	Thanks to Xinwei Hu for spotting this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1053&r2=1.1054
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2009/02/25 13:17:40	1.1053
+++ LVM2/WHATS_NEW	2009/02/25 14:33:00	1.1054
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Fix error returns in clvmd-corosync interface to DLM.
   Add --refresh to vgchange and vgmknodes man pages.
   Fixed bug where lvresize option -t was not properly passed to fsadm.
   Using argv[] list in exec_cmd() to allow more params for external commands.
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/02/11 10:13:20	1.5
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/02/25 14:33:01	1.6
@@ -478,6 +478,12 @@
 		DEBUGLOG("dlm_ls_lock returned %d\n", errno);
 		return err;
 	}
+	if (lksb.sb_status != 0)
+	{
+		DEBUGLOG("dlm_ls_lock returns lksb.sb_status %d\n", lksb.sb_status);
+		errno = lksb.sb_status;
+		return -1;
+	}
 
 	DEBUGLOG("lock_resource returning %d, lock_id=%x\n", err, lksb.sb_lkid);
 
@@ -504,6 +510,13 @@
 		DEBUGLOG("Unlock returned %d\n", err);
 		return err;
 	}
+	if (lksb.sb_status != 0)
+	{
+		DEBUGLOG("dlm_ls_unlock_wait returns lksb.sb_status: %d\n", lksb.sb_status);
+		errno = lksb.sb_status;
+		return -1;
+	}   
+
 
 	return 0;
 }
@@ -568,7 +581,7 @@
 	confdb_handle_t handle;
 	int result;
 	int namelen = buflen;
-	unsigned int cluster_handle;
+	hdb_handle_t cluster_handle;
 	confdb_callbacks_t callbacks = {
 		.confdb_key_change_notify_fn = NULL,
 		.confdb_object_create_change_notify_fn = NULL,


