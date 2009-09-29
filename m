From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 29 Sep 2009 15:17:54 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20090929151754.19072.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-09-29 15:17:54

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Return fail if lv_deactivate did not removed device from kernel.
	
	lv_deactivate now returns always success, because tree deactivation
	functions (see dm_tree_deactivate_children) always returns success.
	
	Because code should return failure in lv_deactivate at least,
	fix it by checking for device existence after real deactivation call.
	
	(After discussion this was prefered solution to dm tree function rewrite
	which affects snapshots and mirrors.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1277&r2=1.1278
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154

--- LVM2/WHATS_NEW	2009/09/28 21:23:02	1.1277
+++ LVM2/WHATS_NEW	2009/09/29 15:17:54	1.1278
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Return fail if lv_deactivate fails to remove device from kernel.
   Provide alternative implementation of obsolete siginterrupt().
   Consolidate LV allocation into alloc_lv().
   Treat input units of both 's' and 'S' as 512-byte sectors.  (2.02.49)
--- LVM2/lib/activate/activate.c	2009/06/01 12:43:32	1.153
+++ LVM2/lib/activate/activate.c	2009/09/29 15:17:54	1.154
@@ -1017,6 +1017,8 @@
 	memlock_dec();
 	fs_unlock();
 
+	if (!lv_info(cmd, lv, &info, 1, 0) || info.exists)
+		r = 0;
 out:
 	if (lv)
 		vg_release(lv->vg);


