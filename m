From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 08:46:22 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20120125084622.21534.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 08:46:22

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Thin send messages on activation resume code path
	
	Using PRELOAD part would lead to problems when the problem
	would happen before vg_write and vg_commit.
	Also this change is necessary for snapshot creation sequence.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152

--- LVM2/libdm/libdm-deptree.c	2012/01/23 17:46:31	1.151
+++ LVM2/libdm/libdm-deptree.c	2012/01/25 08:46:21	1.152
@@ -1768,6 +1768,17 @@
 		}
 	}
 
+	/*
+	 * FIXME: Implement delayed error reporting
+	 * activation should be stopped only in the case,
+	 * the submission of transation_id message fails,
+	 * resume should continue further, just whole command
+	 * has to report failure.
+	 */
+	if (r && dnode->props.send_messages &&
+	    !(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len)))
+		stack;
+
 	handle = NULL;
 
 	return r;
@@ -2434,11 +2445,6 @@
 
 		/* Update cached info */
 		child->info = newinfo;
-		if (child->props.send_messages &&
-		    !(r = _node_send_messages(child, uuid_prefix, uuid_prefix_len))) {
-			stack;
-			continue;
-		}
 		/*
 		 * Prepare for immediate synchronization with udev and flush all stacked
 		 * dev node operations if requested by immediate_dev_node property. But
@@ -2448,23 +2454,12 @@
 			update_devs_flag = 1;
 	}
 
-	if (r && dnode->props.send_messages &&
-	    !(r = _node_send_messages(dnode, uuid_prefix, uuid_prefix_len)))
-		stack;
-
 	if (update_devs_flag) {
 		if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
 			stack;
 		dm_tree_set_cookie(dnode, 0);
 	}
 
-	if (r && !_node_send_messages(dnode, uuid_prefix, uuid_prefix_len)) {
-		stack;
-		if (!(dm_tree_deactivate_children(dnode, uuid_prefix, uuid_prefix_len)))
-			log_error("Failed to deactivate %s", dnode->name);
-		r = 0;
-	}
-
 	return r;
 }
 


