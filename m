From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Oct 2011 16:46:34 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111022164634.9225.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-22 16:46:34

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Remove extra empty check
	
	dm_list_splice handles empty list itself, no need to duplicate code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.301&r2=1.302

--- LVM2/lib/metadata/lv_manip.c	2011/10/22 16:42:11	1.301
+++ LVM2/lib/metadata/lv_manip.c	2011/10/22 16:46:34	1.302
@@ -4139,8 +4139,7 @@
 			    lv->minor);
 	}
 
-	if (!dm_list_empty(&lp->tags))
-		dm_list_splice(&lv->tags, &lp->tags);
+	dm_list_splice(&lv->tags, &lp->tags);
 
 	lp->region_size = adjusted_mirror_region_size(vg->extent_size,
 						      lp->extents,


