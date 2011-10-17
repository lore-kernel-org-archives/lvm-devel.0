From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Oct 2011 14:15:01 -0000
Subject: LVM2/libdm libdevmapper.h libdm-deptree.c
Message-ID: <20111017141501.23741.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-17 14:15:01

Modified files:
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Swap parameters
	
	Use metadata uuid first (match kernel target).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/libdm/libdevmapper.h	2011/10/06 14:45:42	1.159
+++ LVM2/libdm/libdevmapper.h	2011/10/17 14:15:01	1.160
@@ -549,8 +549,8 @@
 int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t size,
 				      uint64_t transaction_id,
-				      const char *pool_uuid,
 				      const char *metadata_uuid,
+				      const char *pool_uuid,
 				      uint32_t data_block_size,
 				      uint64_t low_water_mark_size,
 				      unsigned skip_block_zeroing);
--- LVM2/libdm/libdm-deptree.c	2011/10/17 14:14:33	1.125
+++ LVM2/libdm/libdm-deptree.c	2011/10/17 14:15:01	1.126
@@ -2690,8 +2690,8 @@
 int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t size,
 				      uint64_t transaction_id,
-				      const char *pool_uuid,
 				      const char *metadata_uuid,
+				      const char *pool_uuid,
 				      uint32_t data_block_size,
 				      uint64_t low_water_mark_size,
 				      unsigned skip_block_zeroing)


