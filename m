From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Feb 2011 01:58:21 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20110203015821.10450.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-03 01:58:21

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c 

Log message:
	Remove fs_unlock from lv_resume path
	
	Keep it within clvmd until message for SYNC starts to work.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1900&r2=1.1901
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.188&r2=1.189

--- LVM2/WHATS_NEW	2011/02/03 01:41:03	1.1900
+++ LVM2/WHATS_NEW	2011/02/03 01:58:20	1.1901
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Remove fs_unlock() from lv_resume path.
   Fix wipe size when setting up mda.
   Remove unneeded checks for open_count in lv_info().
   Synchronize with udev before checking open_count in lv_info().
--- LVM2/daemons/clvmd/lvm-functions.c	2011/02/02 20:04:39	1.107
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/02/03 01:58:20	1.108
@@ -517,6 +517,7 @@
 	case LCK_UNLOCK:
 	case LCK_LV_RESUME:	/* if active */
 		status = do_resume_lv(resource, lock_flags);
+		fs_unlock();
 		break;
 
 	case LCK_LV_ACTIVATE:
--- LVM2/lib/activate/activate.c	2011/02/03 01:24:46	1.188
+++ LVM2/lib/activate/activate.c	2011/02/03 01:58:21	1.189
@@ -1124,7 +1124,6 @@
 		goto_out;
 
 	memlock_dec(cmd);
-	fs_unlock();
 
 	if (!monitor_dev_for_events(cmd, lv, origin_only, 1))
 		stack;


