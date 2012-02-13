From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 11:07:57 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c
Message-ID: <20120213110757.12272.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 11:07:55

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 

Log message:
	Add check for failure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2286&r2=1.2287
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/WHATS_NEW	2012/02/13 11:03:59	1.2286
+++ LVM2/WHATS_NEW	2012/02/13 11:07:55	1.2287
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Add check for _mirrored_init_target failure.
   Add free_orphan_vg.
   Skip pv/vg_set_fid processing if the fid is same.
   Check for foreach loop errors in _vg_read_orphans() (2.02.91).
--- LVM2/lib/mirror/mirrored.c	2012/02/08 11:29:14	1.93
+++ LVM2/lib/mirror/mirrored.c	2012/02/13 11:07:55	1.94
@@ -398,8 +398,9 @@
 	uint32_t region_size;
 	int r;
 
-	if (!*target_state)
-		*target_state = _mirrored_init_target(mem, cmd);
+	if (!*target_state &&
+	    !(*target_state = _mirrored_init_target(mem, cmd)))
+                return_0;
 
 	mirr_state = *target_state;
 


