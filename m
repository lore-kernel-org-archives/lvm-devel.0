From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Oct 2011 18:29:49 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20111003182949.2073.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-03 18:29:49

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Move priority check in front
	
	Just a minor code mode - make a test for priority before
	more complex uuid checks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/libdm/libdm-deptree.c	2011/10/03 18:28:25	1.117
+++ LVM2/libdm/libdm-deptree.c	2011/10/03 18:29:48	1.118
@@ -1419,6 +1419,9 @@
 
 	for (priority = 0; priority < 3; priority++) {
 		while ((child = dm_tree_next_child(&handle, dnode, 0))) {
+			if (priority != child->activation_priority)
+				continue;
+
 			if (!(uuid = dm_tree_node_get_uuid(child))) {
 				stack;
 				continue;
@@ -1427,9 +1430,6 @@
 			if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
 				continue;
 
-			if (priority != child->activation_priority)
-				continue;
-
 			if (!(name = dm_tree_node_get_name(child))) {
 				stack;
 				continue;


