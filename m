From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 11:26:00 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20101129112600.18695.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 11:26:00

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Remove dead assignment in dm_tree_node_add_mirror_target_log
	
	'seg' is never used - remove it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/libdm/libdm-deptree.c	2010/11/23 18:29:06	1.87
+++ LVM2/libdm/libdm-deptree.c	2010/11/29 11:26:00	1.88
@@ -2199,9 +2199,7 @@
 int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
                                       uint64_t size)
 {
-	struct load_segment *seg;
-
-	if (!(seg = _add_segment(node, SEG_MIRRORED, size)))
+	if (!_add_segment(node, SEG_MIRRORED, size))
 		return_0;
 
 	return 1;


