From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 10:39:08 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20111020103908.24995.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 10:39:07

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Just replace stack, return 0  with  return_0

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138

--- LVM2/libdm/libdm-deptree.c	2011/10/20 10:35:55	1.137
+++ LVM2/libdm/libdm-deptree.c	2011/10/20 10:39:07	1.138
@@ -2266,19 +2266,13 @@
 				return_0;
 
 		/* FIXME Cope if name exists with no uuid? */
-		if (!child->info.exists) {
-			if (!_create_node(child)) {
-				stack;
-				return 0;
-			}
-		}
+		if (!child->info.exists && !_create_node(child))
+			return_0;
 
-		if (!child->info.inactive_table && child->props.segment_count) {
-			if (!_load_node(child)) {
-				stack;
-				return 0;
-			}
-		}
+		if (!child->info.inactive_table &&
+		    child->props.segment_count &&
+		    !_load_node(child))
+			return_0;
 
 		/* Propagate device size change change */
 		if (child->props.size_changed)


