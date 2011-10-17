From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Oct 2011 14:15:28 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20111017141528.24059.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-17 14:15:27

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Add _thin_validate_device_id

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/libdm/libdm-deptree.c	2011/10/17 14:15:01	1.126
+++ LVM2/libdm/libdm-deptree.c	2011/10/17 14:15:26	1.127
@@ -2687,6 +2687,17 @@
 	return 1;
 }
 
+static int _thin_validate_device_id(uint32_t device_id)
+{
+	if (device_id > DM_THIN_MAX_DEVICE_ID) {
+		log_error("Device id %u is higher then %u.",
+			  device_id, DM_THIN_MAX_DEVICE_ID);
+		return 0;
+	}
+
+	return 1;
+}
+
 int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 				      uint64_t size,
 				      uint64_t transaction_id,
@@ -2744,11 +2755,8 @@
 {
 	struct load_segment *seg;
 
-	if (device_id > DM_THIN_MAX_DEVICE_ID) {
-		log_error("Device id %u is higher then %u.",
-			  device_id, DM_THIN_MAX_DEVICE_ID);
-		return 0;
-	}
+	if (!_thin_validate_device_id(device_id))
+		return_0;
 
 	if (!(seg = _add_segment(node, SEG_THIN, size)))
 		return_0;


