From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Jan 2010 21:05:40 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20100105210540.22341.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-05 21:05:40

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Return error to dm_tree_suspend_children() callers.
	
	Otherwise suspend_lv and its variants can fail silently.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/libdm/libdm-deptree.c	2010/01/05 21:04:37	1.65
+++ LVM2/libdm/libdm-deptree.c	2010/01/05 21:05:40	1.66
@@ -1067,6 +1067,7 @@
 			     const char *uuid_prefix,
 			     size_t uuid_prefix_len)
 {
+	int r = 1;
 	void *handle = NULL;
 	struct dm_tree_node *child = dnode;
 	struct dm_info info, newinfo;
@@ -1109,6 +1110,7 @@
 			log_error("Unable to suspend %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
+			r = 0;
 			continue;
 		}
 
@@ -1130,10 +1132,11 @@
 			continue;
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_suspend_children(child, uuid_prefix, uuid_prefix_len);
+			if (!dm_tree_suspend_children(child, uuid_prefix, uuid_prefix_len))
+				return_0;
 	}
 
-	return 1;
+	return r;
 }
 
 int dm_tree_activate_children(struct dm_tree_node *dnode,


