From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Nov 2011 17:21:03 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111115172103.22715.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-15 17:21:02

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Simplify iteration
	
	Since nothing is removed in dm_list snapshot_segs during the loop,
	there is no reason to use _safe iteration, so switch to simplier
	dm_list_iterate().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.249&r2=1.250

--- LVM2/lib/activate/dev_manager.c	2011/11/15 17:15:03	1.249
+++ LVM2/lib/activate/dev_manager.c	2011/11/15 17:21:02	1.250
@@ -1118,7 +1118,7 @@
 static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv, int origin_only)
 {
 	struct dm_tree *dtree;
-	struct dm_list *snh, *snht;
+	struct dm_list *snh;
 	struct lv_segment *seg;
 	uint32_t s;
 
@@ -1132,7 +1132,7 @@
 
 	/* Add any snapshots of this LV */
 	if (!origin_only && lv_is_origin(lv))
-		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
+		dm_list_iterate(snh, &lv->snapshot_segs)
 			if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, 0))
 				goto_bad;
 


