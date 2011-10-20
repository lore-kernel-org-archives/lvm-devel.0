From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 10:28:42 -0000
Subject: LVM2 lib/metadata/merge.c lib/thin/thin.c libd ...
Message-ID: <20111020102842.28291.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 10:28:42

Modified files:
	lib/metadata   : merge.c 
	lib/thin       : thin.c 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Add _BLOCK_ to define
	
	Use DM_THIN_MIN_DATA_BLOCK_SIZE and
	DM_THIN_MAX_DATA_BLOCK_SIZE to make it more obvious, for which
	this define is useful in thin API.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.161&r2=1.162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134

--- LVM2/lib/metadata/merge.c	2011/10/06 11:05:56	1.52
+++ LVM2/lib/metadata/merge.c	2011/10/20 10:28:41	1.53
@@ -202,8 +202,8 @@
 					inc_error_count;
 				}
 
-				if (seg->data_block_size < DM_THIN_MIN_DATA_SIZE ||
-				    seg->data_block_size > DM_THIN_MAX_DATA_SIZE) {
+				if (seg->data_block_size < DM_THIN_MIN_DATA_BLOCK_SIZE ||
+				    seg->data_block_size > DM_THIN_MAX_DATA_BLOCK_SIZE) {
 					log_error("LV %s: thin pool segment %u  data block size %d is out of range",
 						  lv->name, seg_count, seg->data_block_size);
 					inc_error_count;
--- LVM2/lib/thin/thin.c	2011/10/17 14:17:30	1.18
+++ LVM2/lib/thin/thin.c	2011/10/20 10:28:41	1.19
@@ -119,8 +119,8 @@
 	if (!dm_config_get_uint32(sn, "data_block_size", &seg->data_block_size))
 		return SEG_LOG_ERROR("Could not read data_block_size");
 
-	if ((seg->data_block_size < DM_THIN_MIN_DATA_SIZE) ||
-	    (seg->data_block_size > DM_THIN_MAX_DATA_SIZE))
+	if ((seg->data_block_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
+	    (seg->data_block_size > DM_THIN_MAX_DATA_BLOCK_SIZE))
 		return SEG_LOG_ERROR("Unsupported value %u for data_block_size",
 				     seg->device_id);
 
--- LVM2/libdm/libdevmapper.h	2011/10/17 14:16:25	1.161
+++ LVM2/libdm/libdevmapper.h	2011/10/20 10:28:42	1.162
@@ -542,8 +542,8 @@
  * DATA_DEV_BLOCK_SIZE_MAX_SECTORS (1024 * 1024 * 1024 >> SECTOR_SHIFT)
  * MAX_DEV_ID ((1 << 24) - 1)
  */
-#define DM_THIN_MIN_DATA_SIZE (UINT32_C(128))
-#define DM_THIN_MAX_DATA_SIZE (UINT32_C(2097152))
+#define DM_THIN_MIN_DATA_BLOCK_SIZE (UINT32_C(128))
+#define DM_THIN_MAX_DATA_BLOCK_SIZE (UINT32_C(2097152))
 #define DM_THIN_MAX_DEVICE_ID (UINT32_C((1 << 24) - 1))
 
 int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
--- LVM2/libdm/libdm-deptree.c	2011/10/19 16:45:02	1.133
+++ LVM2/libdm/libdm-deptree.c	2011/10/20 10:28:42	1.134
@@ -2833,15 +2833,15 @@
 {
 	struct load_segment *seg;
 
-	if (data_block_size < DM_THIN_MIN_DATA_SIZE) {
+	if (data_block_size < DM_THIN_MIN_DATA_BLOCK_SIZE) {
 		log_error("Data block size %u is lower then %u sectors.",
-			  data_block_size, DM_THIN_MIN_DATA_SIZE);
+			  data_block_size, DM_THIN_MIN_DATA_BLOCK_SIZE);
 		return 0;
 	}
 
-	if (data_block_size > DM_THIN_MAX_DATA_SIZE) {
+	if (data_block_size > DM_THIN_MAX_DATA_BLOCK_SIZE) {
 		log_error("Data block size %u is higher then %u sectors.",
-			  data_block_size, DM_THIN_MAX_DATA_SIZE);
+			  data_block_size, DM_THIN_MAX_DATA_BLOCK_SIZE);
 		return 0;
 	}
 


