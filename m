From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 20:59:02 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090726205902.721.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 20:59:02

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c to display lvm_lv_is_active and lvm_lv_is_suspended.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/test/api/test.c	2009/07/26 20:58:38	1.15
+++ LVM2/test/api/test.c	2009/07/26 20:59:02	1.16
@@ -315,9 +315,12 @@
 	}
 	printf("LVs in VG %s:\n", lvm_vg_get_name(vg));
 	dm_list_iterate_items(lvl, lvs) {
-		printf("%s/%s (%s): size=%"PRIu64"\n", lvm_vg_get_name(vg),
+		printf("%s/%s (%s): size=%"PRIu64", %sACTIVE / %sSUSPENDED\n",
+			lvm_vg_get_name(vg),
 			lvm_lv_get_name(lvl->lv), lvm_lv_get_uuid(lvl->lv),
-			lvm_lv_get_size(lvl->lv));
+			lvm_lv_get_size(lvl->lv),
+			lvm_lv_is_active(lvl->lv) ? "" : "IN",
+			lvm_lv_is_suspended(lvl->lv) ? "" : "NOT ");
 	}
 }
 


