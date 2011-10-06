From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Oct 2011 11:05:57 -0000
Subject: LVM2 lib/metadata/merge.c libdm/libdevmapper.h ...
Message-ID: <20111006110557.32291.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-06 11:05:56

Modified files:
	lib/metadata   : merge.c 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Move defines to header
	
	Make limits for thin data_block_size and device_id part of public API.
	
	FIXME: read them possible from some kernel header file in the future ?
	But we may need to support different values for different versions ?

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/lib/metadata/merge.c	2011/09/29 09:03:36	1.51
+++ LVM2/lib/metadata/merge.c	2011/10/06 11:05:56	1.52
@@ -202,7 +202,8 @@
 					inc_error_count;
 				}
 
-				if (seg->data_block_size < 128 || seg->data_block_size > 2097152) {
+				if (seg->data_block_size < DM_THIN_MIN_DATA_SIZE ||
+				    seg->data_block_size > DM_THIN_MAX_DATA_SIZE) {
 					log_error("LV %s: thin pool segment %u  data block size %d is out of range",
 						  lv->name, seg_count, seg->data_block_size);
 					inc_error_count;
@@ -238,7 +239,7 @@
 					inc_error_count;
 				}
 
-				if (seg->device_id >= (1 << 24)) {
+				if (seg->device_id > DM_THIN_MAX_DEVICE_ID) {
 					log_error("LV %s: thin volume segment %u has too large device id %d",
 						  lv->name, seg_count, seg->device_id);
 					inc_error_count;
--- LVM2/libdm/libdevmapper.h	2011/10/04 16:22:38	1.157
+++ LVM2/libdm/libdevmapper.h	2011/10/06 11:05:56	1.158
@@ -536,6 +536,16 @@
 /* End of Replicator API */
 
 /* API for thin provisioning is experimental, DO NOT USE. */
+/*
+ * FIXME: Defines bellow are based on kernel's dm-thin.c defines
+ * DATA_DEV_BLOCK_SIZE_MIN_SECTORS (64 * 1024 >> SECTOR_SHIFT)
+ * DATA_DEV_BLOCK_SIZE_MAX_SECTORS (1024 * 1024 * 1024 >> SECTOR_SHIFT)
+ * MAX_DEV_ID ((1 << 24) - 1)
+ */
+#define DM_THIN_MIN_DATA_SIZE (UINT32_C(128))
+#define DM_THIN_MAX_DATA_SIZE (UINT32_C(2097152))
+#define DM_THIN_MAX_DEVICE_ID (UINT32_C((1 << 24) - 1))
+
 int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t size,
 				      uint64_t transaction_id,
--- LVM2/libdm/libdm-deptree.c	2011/10/04 16:22:39	1.120
+++ LVM2/libdm/libdm-deptree.c	2011/10/06 11:05:56	1.121
@@ -29,12 +29,6 @@
 
 #define REPLICATOR_LOCAL_SITE 0
 
-#define THIN_MIN_DATA_SIZE 128
-#define THIN_MAX_DATA_SIZE 2097152
-#define THIN_MAX_DEVICE_ID ((1 << 24) - 1)
-
-#define QUOTE(x) #x
-
 /* Supported segment types */
 enum {
 	SEG_CRYPT,
@@ -2720,17 +2714,15 @@
 {
 	struct load_segment *seg;
 
-	if (data_block_size < THIN_MIN_DATA_SIZE) {
-		log_error("Data block size %d is lower then "
-			  QUOTE(THIN_MIN_DATA_SIZE) " sectors.",
-			  data_block_size);
+	if (data_block_size < DM_THIN_MIN_DATA_SIZE) {
+		log_error("Data block size %u is lower then %u sectors.",
+			  data_block_size, DM_THIN_MIN_DATA_SIZE);
 		return 0;
 	}
 
-	if (data_block_size > THIN_MAX_DATA_SIZE) {
-		log_error("Data block size %d is higher then "
-			  QUOTE(THIN_MAX_DATA_SIZE) " sectors.",
-			  data_block_size);
+	if (data_block_size > DM_THIN_MAX_DATA_SIZE) {
+		log_error("Data block size %u is higher then %u sectors.",
+			  data_block_size, DM_THIN_MAX_DATA_SIZE);
 		return 0;
 	}
 
@@ -2768,9 +2760,9 @@
 {
 	struct load_segment *seg;
 
-	if (device_id > THIN_MAX_DEVICE_ID) {
-		log_error("Device id %d is higher then " QUOTE(THIN_MAX_DEVICE_ID) ".",
-			  device_id);
+	if (device_id > DM_THIN_MAX_DEVICE_ID) {
+		log_error("Device id %u is higher then %u.",
+			  device_id, DM_THIN_MAX_DEVICE_ID);
 		return 0;
 	}
 


