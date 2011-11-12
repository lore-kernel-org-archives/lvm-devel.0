From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Nov 2011 22:53:23 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111112225323.28989.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-12 22:53:23

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Add missing stack reporting
	
	also remove unneeded {}

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.332&r2=1.333

--- LVM2/lib/metadata/lv_manip.c	2011/11/12 22:52:18	1.332
+++ LVM2/lib/metadata/lv_manip.c	2011/11/12 22:53:23	1.333
@@ -3248,12 +3248,11 @@
 
 	if (lv_is_origin(lv)) {
 		/* remove snapshot LVs first */
-		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs) {
+		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!lv_remove_with_dependencies(cmd, dm_list_struct_base(snh, struct lv_segment,
 										  origin_list)->cow,
 							 force, level + 1))
-				return 0;
-		}
+				return_0;
 	}
 
 	if (lv_is_used_thin_pool(lv)) {


