From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:44:37 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20100113014437.6963.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:44:37

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Merging device is loaded with "-cow" suffix and with base name of the
	origin.  This is needed so that "-cow" device can be found and removed
	when lvremove is performed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.169&r2=1.170

--- LVM2/lib/activate/dev_manager.c	2010/01/13 01:43:32	1.169
+++ LVM2/lib/activate/dev_manager.c	2010/01/13 01:44:37	1.170
@@ -1062,16 +1062,28 @@
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
 	struct dm_tree_node *dnode;
-	char *name, *dlid;
+	char *name, *dlid, *lv_name;
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
 	uint16_t udev_flags = 0;
 
-	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_MERGE && !layer)
-		return 1;
+	lv_name = lv->name;
+	if (lv_is_cow(lv) && find_cow(lv)->status & SNAPSHOT_MERGE) {
+		if (layer) {
+			/*
+			 * use origin's name as basis for snapshot-merge device names;
+			 * this allows _clean_tree to automatically cleanup "-cow"
+			 * when the origin is resumed (after merge completes)
+			 */
+			lv_name = origin_from_cow(lv)->name;
+		} else {
+			/* top-level snapshot device is not needed during merge */
+			return 1;
+		}
+	}
 
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
+	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv_name, layer)))
 		return_0;
 
 	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
@@ -1084,7 +1096,7 @@
 
 	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
 		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.",
-			  lv->name, layer);
+			  lv_name, layer);
 		return 0;
 	}
 


