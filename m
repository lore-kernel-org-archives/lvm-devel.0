From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Dec 2010 10:45:38 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20101208104538.28788.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-08 10:45:37

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Remove reset of vg->vgmem pointer as it is access of already release memory
	
	This reset of vgmem pointer causes access of already released memory.
	(_vg_make_handle allocates vg from vgmem pool itself - which is a bit tricky)
	
	Interestingly this memory fault was missed by our test suite.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1829&r2=1.1830
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.413&r2=1.414

--- LVM2/WHATS_NEW	2010/12/06 22:13:10	1.1829
+++ LVM2/WHATS_NEW	2010/12/08 10:45:37	1.1830
@@ -1,5 +1,6 @@
 Version 2.02.79 -
 ===================================
+  Fix write to released memory in vg_relase().  (2.02.78)
 
 Version 2.02.78 - 6th December 2010
 ===================================
--- LVM2/lib/metadata/metadata.c	2010/11/30 11:15:54	1.413
+++ LVM2/lib/metadata/metadata.c	2010/12/08 10:45:37	1.414
@@ -3094,7 +3094,6 @@
 			  vg->name);
 
 	dm_pool_destroy(vg->vgmem);
-	vg->vgmem = NULL;
 }
 
 /* This is only called by lv_from_lvid, which is only called from


