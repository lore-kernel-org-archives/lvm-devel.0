From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Oct 2011 14:14:34 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20111017141434.23519.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-17 14:14:33

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Drop old check for transaction_id
	
	(revert)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/libdm/libdm-deptree.c	2011/10/17 13:15:35	1.124
+++ LVM2/libdm/libdm-deptree.c	2011/10/17 14:14:33	1.125
@@ -1512,18 +1512,6 @@
 
 			/* Update cached info */
 			child->info = newinfo;
-
-			/* FIXME: trial version - to avoid use of unsynchronized thin_pool transaction_id */
-			if (child->props.thin_pool_transaction_id &&
-			    !_check_thin_pool_transaction_id(child->name, child->info.major,
-							     child->info.minor,
-							     child->props.thin_pool_transaction_id)) {
-				stack;
-				if (!(dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len)))
-					log_error("Failed to deactivate %s", child->name);
-				r = 0;
-				continue;
-			}
 		}
 	}
 
@@ -2207,18 +2195,6 @@
 		 */
 		if (child->props.immediate_dev_node)
 			update_devs_flag = 1;
-
-		/* FIXME: trial version - to avoid use of unsynchronized thin_pool transaction_id */
-		if (child->props.thin_pool_transaction_id &&
-		    !_check_thin_pool_transaction_id(child->name, child->info.major,
-						     child->info.minor,
-						     child->props.thin_pool_transaction_id)) {
-			stack;
-			if (!(dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len)))
-				log_error("Failed to deactivate %s", child->name);
-			r = 0;
-			continue;
-		}
 	}
 
 	handle = NULL;


