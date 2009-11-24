From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Nov 2009 16:13:04 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20091124161304.24066.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-24 16:13:03

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Do not try to unlock VG which is not locked.
	
	If the vg_read() returned error, no lock was taken,
	so always call vg_release().
	
	Otherwise this can happen because of missing FAILED_*:
	
	# vgchange -a y x --ignorelockingfailure
	Volume group "x" not found
	Internal error: Attempt to unlock unlocked VG x

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1325&r2=1.1326
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.178&r2=1.179

--- LVM2/WHATS_NEW	2009/11/24 16:11:37	1.1325
+++ LVM2/WHATS_NEW	2009/11/24 16:13:02	1.1326
@@ -1,5 +1,6 @@
 Version 2.02.56 - 
 ====================================
+  Do not try to unlock VG which is not locked in _process_one_vg.
   Move persistent filter dump to more appropriate place.
   Refresh device filters before full device rescan in lvmcache.
   Return error status if vgchange fails to activate some volume.
--- LVM2/tools/toollib.c	2009/11/01 20:03:24	1.178
+++ LVM2/tools/toollib.c	2009/11/24 16:13:03	1.179
@@ -452,8 +452,7 @@
 		ret_max = ret;
 
 out:
-	if ((vg_read_error(vg) == FAILED_ALLOCATION)||
-	    (vg_read_error(vg) == FAILED_LOCKING))
+	if (vg_read_error(vg))
 		vg_release(vg);
 	else
 		unlock_and_release_vg(cmd, vg, vg_name);


