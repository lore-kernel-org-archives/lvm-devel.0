From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:18:32 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111028201832.31340.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:18:32

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Remove thin code from mirror/raid lv_extend

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.305&r2=1.306

--- LVM2/lib/metadata/lv_manip.c	2011/10/28 20:17:56	1.305
+++ LVM2/lib/metadata/lv_manip.c	2011/10/28 20:18:32	1.306
@@ -2596,13 +2596,6 @@
 
 		if (!(r = _lv_extend_layered_lv(ah, lv, extents, 0,
 						stripes, stripe_size)))
-			goto out;
-
-		if (segtype_is_thin_pool(segtype) &&
-		    !(r = lv_add_segment(ah, ah->area_count, 1,
-					 first_seg(lv)->pool_metadata_lv,
-					 get_segtype_from_string(lv->vg->cmd,
-								 "striped"), 0, 0, 0)))
 			goto_out;
 
 		/*


