From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Dec 2009 19:23:41 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20091203192341.27445.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-03 19:23:40

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Fix memory lock imbalance in lv_suspend if already suspended.
	
	pvmove suspends all moved LVs + pvmoveX mirrored LV itself.
	
	This suspends even underlying pvmoveX and following explicit
	suspend call is just noop.
	
	But in resume the pvmoveX volume is no longer underlying
	device for moved LVs, so it performs full resume with memlock
	decrease.
	
	Code must call memlock_inc() if suspend is requested, volume
	is already suspended and error is not requested.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1340&r2=1.1341
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.159&r2=1.160

--- LVM2/WHATS_NEW	2009/12/03 19:22:24	1.1340
+++ LVM2/WHATS_NEW	2009/12/03 19:23:40	1.1341
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Fix memory lock imbalance in lv_suspend if already suspended.
   Fix pvmove test mode to not fail and do not poll.
   Fix error message if VG already exist in vgcreate.
   Fix tools to use log_error when stopped by user.
--- LVM2/lib/activate/activate.c	2009/12/01 19:10:23	1.159
+++ LVM2/lib/activate/activate.c	2009/12/03 19:23:40	1.160
@@ -879,7 +879,11 @@
 		goto_out;
 
 	if (!info.exists || info.suspended) {
-		r = error_if_not_suspended ? 0 : 1;
+		if (!error_if_not_suspended) {
+			r = 1;
+			if (info.suspended)
+				memlock_inc();
+		}
 		goto out;
 	}
 


