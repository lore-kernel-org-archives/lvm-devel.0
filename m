From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 12:56:46 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20111221125646.15600.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 12:56:45

Modified files:
	lib/thin       : thin.c 

Log message:
	Thin remove unused code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/lib/thin/thin.c	2011/12/21 12:54:19	1.35
+++ LVM2/lib/thin/thin.c	2011/12/21 12:56:45	1.36
@@ -372,19 +372,6 @@
 		return 0;
 	}
 
-#if 0
-{
-	/* If we would need to activate 'to be deleted' thin LVs */
-	struct lv_thin_message *tmsg;
-	dm_list_iterate_items(tmsg, &first_seg(seg->pool_lv)->thin_messages)
-		/* If this node is going to be deleted - use the error target */
-		if ((tmsg->type == DM_THIN_MESSAGE_DELETE) &&
-		    (tmsg->u.delete_id == seg->device_id)) {
-			device_id = DM_THIN_ERROR_DEVICE_ID;
-			break;
-		}
-}
-#endif
 	if (!dm_tree_node_add_thin_target(node, len, pool_dlid, device_id))
 		return_0;
 


