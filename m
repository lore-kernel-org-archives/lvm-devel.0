From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 10:33:31 -0000
Subject: LVM2/libdm libdevmapper.h libdm-deptree.c
Message-ID: <20111020103331.31069.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 10:33:31

Modified files:
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Adapt to thin kernel target API
	
	Since kernel target uses low_water_mark - use this name in libdm as well.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.163&r2=1.164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/libdm/libdevmapper.h	2011/10/20 10:31:27	1.163
+++ LVM2/libdm/libdevmapper.h	2011/10/20 10:33:30	1.164
@@ -552,7 +552,7 @@
 				      const char *metadata_uuid,
 				      const char *pool_uuid,
 				      uint32_t data_block_size,
-				      uint64_t low_water_mark_size,
+				      uint64_t low_water_mark,
 				      unsigned skip_block_zeroing);
 
 /* Supported messages for thin provision target */
--- LVM2/libdm/libdm-deptree.c	2011/10/20 10:31:27	1.135
+++ LVM2/libdm/libdm-deptree.c	2011/10/20 10:33:30	1.136
@@ -170,7 +170,7 @@
 	struct dm_tree_node *metadata;	/* Thin_pool */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
 	struct dm_list thin_messages;	/* Thin_pool */
-	uint64_t low_water_mark_size;	/* Thin_pool */
+	uint64_t low_water_mark;	/* Thin_pool */
 	uint32_t data_block_size;       /* Thin_pool */
 	unsigned skip_block_zeroing;	/* Thin_pool */
 	uint32_t device_id;		/* Thin */
@@ -2085,7 +2085,7 @@
 		if (!_build_dev_string(pool, sizeof(pool), seg->pool))
 			return_0;
 		EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %s", metadata, pool,
-			    seg->data_block_size, seg->low_water_mark_size,
+			    seg->data_block_size, seg->low_water_mark,
 			    seg->skip_block_zeroing ? "1 skip_block_zeroing" : "");
 		break;
 	case SEG_THIN:
@@ -2828,7 +2828,7 @@
 				      const char *metadata_uuid,
 				      const char *pool_uuid,
 				      uint32_t data_block_size,
-				      uint64_t low_water_mark_size,
+				      uint64_t low_water_mark,
 				      unsigned skip_block_zeroing)
 {
 	struct load_segment *seg;
@@ -2865,7 +2865,7 @@
 		return_0;
 
 	node->props.thin_pool_transaction_id = transaction_id; // compare on resume
-	seg->low_water_mark_size = low_water_mark_size;
+	seg->low_water_mark = low_water_mark;
 	seg->data_block_size = data_block_size;
 	seg->skip_block_zeroing = skip_block_zeroing;
 	dm_list_init(&seg->thin_messages);


