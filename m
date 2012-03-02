From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 21:43:27 -0000
Subject: LVM2 lib/thin/thin.c libdm/libdm-deptree.c
Message-ID: <20120302214327.19411.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 21:43:27

Modified files:
	lib/thin       : thin.c 
	libdm          : libdm-deptree.c 

Log message:
	Purge remaining trim bits from code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.159&r2=1.160

--- LVM2/lib/thin/thin.c	2012/03/02 13:26:09	1.48
+++ LVM2/lib/thin/thin.c	2012/03/02 21:43:26	1.49
@@ -53,7 +53,7 @@
 	uint32_t delete_id = 0;
 	dm_thin_message_t type;
 
-	/* Message must have only one from: create, trim, delete */
+	/* Message must have only one from: create, delete */
 	if (dm_config_get_str(sn, "create", &lv_name)) {
 		if (!(lv = find_lv(seg->lv->vg, lv_name)))
 			return SEG_LOG_ERROR("Unknown LV %s for create message in",
--- LVM2/libdm/libdm-deptree.c	2012/03/02 17:31:22	1.159
+++ LVM2/libdm/libdm-deptree.c	2012/03/02 21:43:27	1.160
@@ -122,10 +122,6 @@
 			uint64_t current_id;
 			uint64_t new_id;
 		} m_set_transaction_id;
-		struct {
-			uint32_t device_id;
-			uint64_t new_size;
-		} m_trim;
 	} u;
 };
 


