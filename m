From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Feb 2010 03:23:08 -0000
Subject: LVM2 ./WHATS_NEW test/api/test.c
Message-ID: <20100214032308.8896.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-14 03:23:07

Modified files:
	.              : WHATS_NEW 
	test/api       : test.c 

Log message:
	Update simple lvm2app unit test for new size apis.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1425&r2=1.1426
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2010/02/10 15:56:20	1.1425
+++ LVM2/WHATS_NEW	2010/02/14 03:23:07	1.1426
@@ -1,5 +1,7 @@
 Version 2.02.61 - 
 ===================================
+  Add lvm2app exports lvm_pv_get_size(), lvm_pv_get_free(), and lvm_pv_get_dev_size().
+  Fix off by 512 sizes for lvm2app.
   Add 'fail_if_percent_unsupported' arg to _percent() and _percent_run().
   Remove false "failed to find tree node for" error when activating merging origin.
   Make lvconvert --repair --use-policies exit with success when no action is needed.
--- LVM2/test/api/test.c	2009/08/13 12:17:32	1.27
+++ LVM2/test/api/test.c	2010/02/14 03:23:07	1.28
@@ -450,8 +450,11 @@
 	}
 	printf("PVs in VG %s:\n", lvm_vg_get_name(vg));
 	dm_list_iterate_items(pvl, pvs) {
-		printf("%s (%s): mda_count=%"PRIu64"\n",
-		       lvm_pv_get_name(pvl->pv), lvm_pv_get_uuid(pvl->pv),
+		printf("%s (%s): size=%"PRIu64", free=%"PRIu64
+			", dev_size=%"PRIu64", mda_count=%"PRIu64"\n",
+			lvm_pv_get_name(pvl->pv), lvm_pv_get_uuid(pvl->pv),
+			lvm_pv_get_size(pvl->pv), lvm_pv_get_free(pvl->pv),
+			lvm_pv_get_dev_size(pvl->pv),
 			lvm_pv_get_mda_count(pvl->pv));
 	}
 }


