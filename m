From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 6 Mar 2009 11:29:39 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-corosync.c
Message-ID: <20090306112939.16741.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-03-06 11:29:38

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-corosync.c 

Log message:
	Fix unlocks in clvmd-corosync.
	
	The DLM unlock returns EUNLOCK in the lksb on success, not 0

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1062&r2=1.1063
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2009/03/05 16:25:35	1.1062
+++ LVM2/WHATS_NEW	2009/03/06 11:29:38	1.1063
@@ -1,6 +1,7 @@
 Version 2.02.46 - 
 ================================
   Flush memory pool and fix locking in clvmd refresh and backup command.
+  Fix unlocks in clvmd-corosync. Broken in 2.02.45.
 
 Version 2.02.45 - 3rd March 2009
 ================================
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/02/25 14:33:01	1.6
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/03/06 11:29:38	1.7
@@ -510,7 +510,7 @@
 		DEBUGLOG("Unlock returned %d\n", err);
 		return err;
 	}
-	if (lksb.sb_status != 0)
+	if (lksb.sb_status != EUNLOCK)
 	{
 		DEBUGLOG("dlm_ls_unlock_wait returns lksb.sb_status: %d\n", lksb.sb_status);
 		errno = lksb.sb_status;


