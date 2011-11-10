From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2011 15:31:00 -0000
Subject: LVM2 lib/thin/thin.c test/t-lvcreate-thin.sh
Message-ID: <20111110153100.17579.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-10 15:31:00

Modified files:
	lib/thin       : thin.c 
	test           : t-lvcreate-thin.sh 

Log message:
	Thin send create_snap message
	
	Start creating snapshots for real.
	Update test suite to check it happens.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-thin.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/thin/thin.c	2011/11/07 11:03:48	1.31
+++ LVM2/lib/thin/thin.c	2011/11/10 15:30:59	1.32
@@ -222,6 +222,7 @@
 {
 	char *metadata_dlid, *pool_dlid;
 	const struct lv_thin_message *lmsg;
+	const struct logical_volume *origin;
 
 	if (!laopts->real_pool) {
 		if (!(pool_dlid = build_dm_uuid(mem, seg->lv->lvid.s, "tpool"))) {
@@ -258,22 +259,13 @@
 
 	dm_list_iterate_items(lmsg, &seg->thin_messages) {
 		switch (lmsg->type) {
-		case DM_THIN_MESSAGE_CREATE_SNAP:
-			/* FIXME: to be implemented */
-			log_debug("Thin pool create_snap %s.", lmsg->u.lv->name);
-			if (!dm_tree_node_add_thin_pool_message(node,
-								lmsg->type,
-								first_seg(lmsg->u.lv)->device_id,
-								0))//first_seg(first_seg(lmsg->u.lv)->origin)->device_id;
-				return_0;
-			log_error("Sorry SNAPSHOT is not yet supported.");
-			return 0;
 		case DM_THIN_MESSAGE_CREATE_THIN:
-			log_debug("Thin pool create_thin %s.", lmsg->u.lv->name);
+			origin = first_seg(lmsg->u.lv)->origin;
+			log_debug("Thin pool create_%s %s.", (!origin) ? "thin" : "snap", lmsg->u.lv->name);
 			if (!dm_tree_node_add_thin_pool_message(node,
-								lmsg->type,
+								(!origin) ? lmsg->type : DM_THIN_MESSAGE_CREATE_SNAP,
 								first_seg(lmsg->u.lv)->device_id,
-								0))
+								(!origin) ? 0 : first_seg(origin)->device_id))
 				return_0;
 			break;
 		case DM_THIN_MESSAGE_DELETE:
--- LVM2/test/t-lvcreate-thin.sh	2011/11/10 12:44:33	1.2
+++ LVM2/test/t-lvcreate-thin.sh	2011/11/10 15:31:00	1.3
@@ -145,10 +145,11 @@
 lvremove -ff $vg
 check vg_field $vg lv_count 0
 
-
 # Create thin snapshot of thinLV
-lvcreate -L4M -V2G -T $vg/pool --name lv1
+lvcreate -L10M -V10M -T $vg/pool --name lv1
+mkfs.ext4 $DM_DEV_DIR/$vg/lv1
 lvcreate -s $vg/lv1
+fsck -p $DM_DEV_DIR/$vg/lvol0
 lvcreate -s $vg/lv1 --name lv2
 lvcreate -s $vg/lv1 --name $vg/lv3
 lvcreate --type snapshot $vg/lv1


