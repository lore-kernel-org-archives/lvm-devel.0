From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 1 Jul 2010 21:23:48 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20100701212348.13367.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-07-01 21:23:48

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Remove superfluous suspended device counter from clvmd.
	
	Moreover, in current mirror handling, when it calls activate
	on removed but suspended detached log this counter drops below zero
	and confuses debug log.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1646&r2=1.1647
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/WHATS_NEW	2010/07/01 11:04:58	1.1646
+++ LVM2/WHATS_NEW	2010/07/01 21:23:47	1.1647
@@ -1,5 +1,6 @@
 Version 2.02.70 - 
 ================================
+  Remove superfluous suspended device counter from clvmd.
   Fix lvm shell crash when input is entirely whitespace.
   Update partial mode warning message.
   Preserve memlock balance in clvmd when activation triggers a resume.
--- LVM2/daemons/clvmd/lvm-functions.c	2010/06/30 21:40:27	1.95
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/07/01 21:23:48	1.96
@@ -38,7 +38,6 @@
 static pthread_mutex_t lv_hash_lock;
 static pthread_mutex_t lvm_lock;
 static char last_error[1024];
-static int suspended = 0;
 
 struct lv_info {
 	int lock_id;
@@ -498,15 +497,11 @@
 
 	case LCK_LV_SUSPEND:
 		status = do_suspend_lv(resource, lock_flags);
-		if (!status)
-			suspended++;
 		break;
 
 	case LCK_UNLOCK:
 	case LCK_LV_RESUME:	/* if active */
 		status = do_resume_lv(resource, lock_flags);
-		if (!status)
-			suspended--;
 		break;
 
 	case LCK_LV_ACTIVATE:
@@ -844,7 +839,7 @@
 	struct volume_group * vg;
 	int consistent = 0;
 
-	DEBUGLOG("Triggering backup of VG metadata for %s. suspended=%d\n", vgname, suspended);
+	DEBUGLOG("Triggering backup of VG metadata for %s.\n", vgname);
 
 	pthread_mutex_lock(&lvm_lock);
 


