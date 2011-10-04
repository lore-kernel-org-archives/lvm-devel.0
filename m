From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Oct 2011 16:22:40 -0000
Subject: LVM2/libdm libdevmapper.h libdm-deptree.c
Message-ID: <20111004162240.31335.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-04 16:22:39

Modified files:
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Name changes
	
	typo zeroeing->zeroing
	add size low_water_mark->low_water_mark_size so it's more obvious its sector
	related variable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.156&r2=1.157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/libdm/libdevmapper.h	2011/10/03 18:34:52	1.156
+++ LVM2/libdm/libdevmapper.h	2011/10/04 16:22:38	1.157
@@ -542,8 +542,8 @@
 				      const char *pool_uuid,
 				      const char *metadata_uuid,
 				      uint32_t data_block_size,
-				      uint64_t low_water_mark,
-				      unsigned skip_block_zeroeing); /* Maybe separate _set_ call ? */
+				      uint64_t low_water_mark_size,
+				      unsigned skip_block_zeroing);
 
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
--- LVM2/libdm/libdm-deptree.c	2011/10/03 18:34:52	1.119
+++ LVM2/libdm/libdm-deptree.c	2011/10/04 16:22:39	1.120
@@ -169,9 +169,9 @@
 
 	struct dm_tree_node *metadata;	/* Thin_pool */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
-	uint64_t low_water_mark;	/* Thin_pool */
+	uint64_t low_water_mark_size;	/* Thin_pool */
 	uint32_t data_block_size;       /* Thin_pool */
-	unsigned skip_block_zeroeing;	/* Thin_pool */
+	unsigned skip_block_zeroing;	/* Thin_pool */
 	uint32_t device_id;		/* Thin */
 
 };
@@ -1978,8 +1978,8 @@
 		if (!_build_dev_string(pool, sizeof(pool), seg->pool))
 			return_0;
 		EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %s", metadata, pool,
-			    seg->data_block_size, seg->low_water_mark,
-			    seg->skip_block_zeroeing ? "1 skip_block_zeroing" : "");
+			    seg->data_block_size, seg->low_water_mark_size,
+			    seg->skip_block_zeroing ? "1 skip_block_zeroing" : "");
 		break;
 	case SEG_THIN:
 		if (!_build_dev_string(pool, sizeof(pool), seg->pool))
@@ -2715,8 +2715,8 @@
 				      const char *pool_uuid,
 				      const char *metadata_uuid,
 				      uint32_t data_block_size,
-				      uint64_t low_water_mark,
-				      unsigned skip_block_zeroeing)
+				      uint64_t low_water_mark_size,
+				      unsigned skip_block_zeroing)
 {
 	struct load_segment *seg;
 
@@ -2754,9 +2754,9 @@
 		return_0;
 
 	node->props.thin_pool_transaction_id = transaction_id; // compare on resume
-	seg->low_water_mark = low_water_mark;
+	seg->low_water_mark_size = low_water_mark_size;
 	seg->data_block_size = data_block_size;
-	seg->skip_block_zeroeing = skip_block_zeroeing;
+	seg->skip_block_zeroing = skip_block_zeroing;
 
 	return 1;
 }


