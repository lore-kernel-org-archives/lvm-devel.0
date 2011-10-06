From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Oct 2011 11:06:37 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20111006110637.32681.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-06 11:06:36

Modified files:
	lib/thin       : thin.c 

Log message:
	Add more validation to config parser
	
	Do not leave it for vgvalidate().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/lib/thin/thin.c	2011/10/03 18:26:07	1.14
+++ LVM2/lib/thin/thin.c	2011/10/06 11:06:36	1.15
@@ -76,6 +76,11 @@
 	if (!dm_config_get_uint32(sn, "data_block_size", &seg->data_block_size))
 		return SEG_LOG_ERROR("Could not read data_block_size");
 
+	if ((seg->data_block_size < DM_THIN_MIN_DATA_SIZE) ||
+	    (seg->data_block_size > DM_THIN_MAX_DATA_SIZE))
+		return SEG_LOG_ERROR("Unsupported value %u for data_block_size",
+				     seg->device_id);
+
 	if (dm_config_has_node(sn, "zero_new_blocks") &&
 	    !dm_config_get_uint32(sn, "zero_new_blocks", &seg->zero_new_blocks))
 		return SEG_LOG_ERROR("Could not read zero_new_blocks for");
@@ -168,6 +173,10 @@
 	if (!dm_config_get_uint32(sn, "device_id", &seg->device_id))
 		return SEG_LOG_ERROR("Could not read device_id for");
 
+	if (seg->device_id > DM_THIN_MAX_DEVICE_ID)
+		return SEG_LOG_ERROR("Unsupported value %u for device_id",
+				     seg->device_id);
+
 	return 1;
 }
 


