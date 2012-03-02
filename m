From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 17:25:23 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20120302172523.16838.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 17:25:21

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Fix estimation of pool metadata device size
	
	If no size was give the later added minimal size check efectively
	disable this code. Also the argument for size now must be kept
	in sector_size, so adding division by SECTOR_SIZE (moved into
	a const expression)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2332&r2=1.2333
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.258&r2=1.259

--- LVM2/WHATS_NEW	2012/03/01 21:49:32	1.2332
+++ LVM2/WHATS_NEW	2012/03/02 17:25:21	1.2333
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Fix automatic estimation of metadata device size for thin pool.
   Test for alloc fail from _alloc_pv_segment() in _extend_pv().
   Check for alloc fail from get_segtype_from_string() in _lvcreate_params().
   Add _rimage as reserved suffix to lvm.8 man page.
--- LVM2/tools/lvcreate.c	2012/03/01 21:21:55	1.258
+++ LVM2/tools/lvcreate.c	2012/03/02 17:25:21	1.259
@@ -293,10 +293,10 @@
 			break;
 	}
 
-	if (lp->create_thin_pool && !lp->poolmetadatasize)
+	if (lp->create_thin_pool && !arg_count(vg->cmd, poolmetadatasize_ARG))
 		/* Defaults to nr_pool_blocks * 64b */
 		lp->poolmetadatasize =  (uint64_t) lp->extents * vg->extent_size /
-			(uint64_t) lp->chunk_size * UINT64_C(64);
+			(uint64_t) (lp->chunk_size * (SECTOR_SIZE / UINT64_C(64)));
 
 	if (lp->poolmetadatasize &&
 	    !(lp->poolmetadataextents = extents_from_size(vg->cmd, lp->poolmetadatasize,


