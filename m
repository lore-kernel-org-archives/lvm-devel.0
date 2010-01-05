From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Jan 2010 21:06:26 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20100105210626.23371.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-05 21:06:26

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Return error to dm_tree_deactivate_children() callers.
	
	Otherwise deactivate_lv can fail silently.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/libdm/libdm-deptree.c	2010/01/05 21:05:40	1.66
+++ LVM2/libdm/libdm-deptree.c	2010/01/05 21:06:26	1.67
@@ -1006,6 +1006,7 @@
 				   const char *uuid_prefix,
 				   size_t uuid_prefix_len)
 {
+	int r = 1;
 	void *handle = NULL;
 	struct dm_tree_node *child = dnode;
 	struct dm_info info;
@@ -1043,14 +1044,16 @@
 			log_error("Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
+			r = 0;
 			continue;
 		}
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len);
+			if (!dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len))
+				return_0;
 	}
 
-	return 1;
+	return r;
 }
 
 void dm_tree_skip_lockfs(struct dm_tree_node *dnode)


