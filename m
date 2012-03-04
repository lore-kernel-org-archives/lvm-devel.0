From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2012 16:05:42 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20120304160542.18165.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-04 16:05:42

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Remove part of FIXME
	
	(and reindent a code below)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162

--- LVM2/libdm/libdm-deptree.c	2012/03/02 21:53:17	1.161
+++ LVM2/libdm/libdm-deptree.c	2012/03/04 16:05:42	1.162
@@ -1590,16 +1590,12 @@
 
 		if (child->callback &&
 		    !child->callback(child, DM_NODE_CALLBACK_DEACTIVATED,
-				     child->callback_data)) {
-			r = 0;
-			// FIXME: break tree shutdown or continue?
-			// hmm what about _node_clear_table()?
-		}
+				     child->callback_data))
+			r = 0; // FIXME: _node_clear_table() without callback ?
 
-		if (dm_tree_node_num_children(child, 0)) {
-			if (!_dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len, level + 1))
-				return_0;
-		}
+		if (dm_tree_node_num_children(child, 0) &&
+		    !_dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len, level + 1))
+			return_0;
 	}
 
 	return r;


