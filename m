From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 13:07:41 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090726130741.7041.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 13:07:41

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c for liblvm 'get' functions.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/api/test.c	2009/07/26 02:35:47	1.7
+++ LVM2/test/api/test.c	2009/07/26 13:07:41	1.8
@@ -210,9 +210,10 @@
 
 static void _show_one_vg(vg_t *vg)
 {
-	/* FIXME: uuid is not null terminated */
-	printf("%s (%s): mode = %s\n", lvm_vg_get_name(vg),
-	       lvm_vg_get_uuid(vg), "READ");
+	printf("%s (%s): size=%"PRIu64", free=%"PRIu64", #pv=%"PRIu64"\n",
+		lvm_vg_get_name(vg), lvm_vg_get_uuid(vg),
+		lvm_vg_get_size(vg), lvm_vg_get_free(vg),
+		lvm_vg_get_pv_count(vg));
 }
 
 static void _list_open_vgs(void)
@@ -235,8 +236,9 @@
 	}
 	printf("PVs in VG %s:\n", lvm_vg_get_name(vg));
 	dm_list_iterate_items(pvl, pvs) {
-		printf("%s (%s)\n",
-		       lvm_pv_get_name(pvl->pv), lvm_pv_get_uuid(pvl->pv));
+		printf("%s (%s): mda_count=%"PRIu64"\n",
+		       lvm_pv_get_name(pvl->pv), lvm_pv_get_uuid(pvl->pv),
+			lvm_pv_get_mda_count(pvl->pv));
 	}
 }
 
@@ -289,8 +291,9 @@
 	}
 	printf("LVs in VG %s:\n", lvm_vg_get_name(vg));
 	dm_list_iterate_items(lvl, lvs) {
-		printf("%s/%s (%s)\n", lvm_vg_get_name(vg),
-		       lvm_lv_get_name(lvl->lv), lvm_lv_get_uuid(lvl->lv));
+		printf("%s/%s (%s): size=%"PRIu64"\n", lvm_vg_get_name(vg),
+			lvm_lv_get_name(lvl->lv), lvm_lv_get_uuid(lvl->lv),
+			lvm_lv_get_size(lvl->lv));
 	}
 }
 


