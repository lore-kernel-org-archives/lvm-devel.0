From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Apr 2012 00:51:27 -0000
Subject: LVM2 lib/activate/dev_manager.c ./WHATS_NEW
Message-ID: <20120424005127.17627.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-04-24 00:51:26

Modified files:
	lib/activate   : dev_manager.c 
	.              : WHATS_NEW 

Log message:
	Handle replacement of an active device that goes missing with an error device.
	(E.g. lvchange --refresh --partial on striped LV if a PV disappeared.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.277&r2=1.278
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2386&r2=1.2387

--- LVM2/lib/activate/dev_manager.c	2012/04/20 14:17:44	1.277
+++ LVM2/lib/activate/dev_manager.c	2012/04/24 00:51:26	1.278
@@ -1423,10 +1423,11 @@
 static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 			       struct lv_segment *seg, int s)
 {
-	char *id, *name;
+	char *dlid, *name;
 	char errid[32];
 	struct dm_tree_node *node;
 	struct lv_segment *seg_i;
+	struct dm_info info;
 	int segno = -1, i = 0;
 	uint64_t size = (uint64_t) seg->len * seg->lv->vg->extent_size;
 
@@ -1443,18 +1444,35 @@
 
 	sprintf(errid, "missing_%d_%d", segno, s);
 
-	if (!(id = build_dm_uuid(dm->mem, seg->lv->lvid.s, errid)))
+	if (!(dlid = build_dm_uuid(dm->mem, seg->lv->lvid.s, errid)))
 		return_NULL;
 
 	if (!(name = dm_build_dm_name(dm->mem, seg->lv->vg->name,
 				   seg->lv->name, errid)))
 		return_NULL;
-	if (!(node = dm_tree_add_new_dev(dtree, name, id, 0, 0, 0, 0, 0)))
-		return_NULL;
-	if (!dm_tree_node_add_error_target(node, size))
-		return_NULL;
 
-	return id;
+	log_debug("Getting device info for %s [%s]", name, dlid);
+	if (!_info(dlid, 1, 0, &info, NULL)) {
+		log_error("Failed to get info for %s [%s].", name, dlid);
+		return 0;
+	}
+
+	if (!info.exists) {
+		/* Create new node */
+		if (!(node = dm_tree_add_new_dev(dtree, name, dlid, 0, 0, 0, 0, 0)))
+			return_NULL;
+		if (!dm_tree_node_add_error_target(node, size))
+			return_NULL;
+	} else {
+		/* Already exists */
+		if (!dm_tree_add_dev(dtree, info.major, info.minor)) {
+			log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
+				  info.major, info.minor);
+			return_NULL;
+		}
+	}
+
+	return dlid;
 }
 
 static int _add_error_area(struct dev_manager *dm, struct dm_tree_node *node,
--- LVM2/WHATS_NEW	2012/04/20 14:17:44	1.2386
+++ LVM2/WHATS_NEW	2012/04/24 00:51:26	1.2387
@@ -1,6 +1,7 @@
 Version 2.02.96 - 
 ================================
-  Unlike 'mirror' segtype, 'raid1' should perform flush on suspend.
+  Handle replacement of an active device that goes missing with an error device.
+  Change change raid1 segtype always to request a flush when suspending.
   Add udev info and context to lvmdump.
   Fix RAID device replacement code so that it works under snapshot.
   Fix inability to split RAID1 image while specifying a particular PV.


