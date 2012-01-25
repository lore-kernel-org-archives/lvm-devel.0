From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 09:17:15 -0000
Subject: LVM2/lib/metadata thin_manip.c
Message-ID: <20120125091715.1071.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 09:17:15

Modified files:
	lib/metadata   : thin_manip.c 

Log message:
	Thin skip activation when there are no thin message
	
	If the list with thin messages is empty, do not touch thin pool device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/metadata/thin_manip.c	2012/01/25 09:13:10	1.31
+++ LVM2/lib/metadata/thin_manip.c	2012/01/25 09:17:15	1.32
@@ -371,6 +371,9 @@
 		return 0;
 	}
 
+	if (dm_list_empty(&(first_seg(lv)->thin_messages)))
+		return 1; /* No messages */
+
 	if (activate) {
 		/* If the pool is not active, do activate deactivate */
 		if (!lv_is_active(lv)) {
@@ -389,14 +392,12 @@
 		}
 	}
 
-	if (!dm_list_empty(&first_seg(lv)->thin_messages)) {
-		dm_list_init(&first_seg(lv)->thin_messages);
+	dm_list_init(&(first_seg(lv)->thin_messages));
 
-		if (!vg_write(lv->vg) || !vg_commit(lv->vg))
-			return_0;
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
 
-		backup(lv->vg);
-	}
+	backup(lv->vg);
 
 	return 1;
 }


