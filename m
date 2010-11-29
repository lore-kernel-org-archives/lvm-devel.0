From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 11:08:14 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20101129110814.10141.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 11:08:14

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Reset vg pointer after release
	
	Set vg to NULL after releasing it as the following memlock() test may
	lead to goto for the second call of vg_release() with the already
	released vg pointer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1811&r2=1.1812
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.410&r2=1.411

--- LVM2/WHATS_NEW	2010/11/29 10:58:33	1.1811
+++ LVM2/WHATS_NEW	2010/11/29 11:08:14	1.1812
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix missing reset of vg pointer after vg_release() in _vg_read_by_vgid().
   Fix test for empty system_dir string in _init_backup().
   Certain lvconvert invocations are now required to be done in two steps.
   Fix missing context desctruction in err path of lvm1 fallback in lvm2_main().
--- LVM2/lib/metadata/metadata.c	2010/11/23 01:55:59	1.410
+++ LVM2/lib/metadata/metadata.c	2010/11/29 11:08:14	1.411
@@ -3117,6 +3117,7 @@
 			return vg;
 		}
 		vg_release(vg);
+		vg = NULL; /* reset so memlock goto out is safe */
 	}
 
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */


