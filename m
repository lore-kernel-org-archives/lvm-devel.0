From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:37:24 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20111103143724.16841.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:37:24

Modified files:
	lib/thin       : thin.c 

Log message:
	Thin clean using delete_id consitently

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/lib/thin/thin.c	2011/10/30 22:00:58	1.27
+++ LVM2/lib/thin/thin.c	2011/11/03 14:37:23	1.28
@@ -49,7 +49,7 @@
 {
 	const char *lv_name = NULL;
 	struct logical_volume *lv = NULL;
-	uint32_t device_id = 0;
+	uint32_t delete_id = 0;
 	dm_thin_message_t type;
 
 	/* Message must have only one from: create, trim, delete */
@@ -70,7 +70,7 @@
 		type = DM_THIN_MESSAGE_TRIM;
 	}
 
-	if (!dm_config_get_uint32(sn, "delete", &device_id)) {
+	if (!dm_config_get_uint32(sn, "delete", &delete_id)) {
 		if (!lv)
 			return SEG_LOG_ERROR("Unknown message in");
 	} else {
@@ -79,7 +79,7 @@
 		type = DM_THIN_MESSAGE_DELETE;
 	}
 
-	if (!attach_pool_message(seg, type, lv, device_id, 1))
+	if (!attach_pool_message(seg, type, lv, delete_id, 1))
 		return_0;
 
 	return 1;


