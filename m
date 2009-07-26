From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 20:29:29 -0000
Subject: LVM2/liblvm lvm_vg.c
Message-ID: <20090726202929.22632.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 20:29:28

Modified files:
	liblvm         : lvm_vg.c 

Log message:
	Update a few liblvm calls with log_errno.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/liblvm/lvm_vg.c	2009/07/26 20:28:59	1.16
+++ LVM2/liblvm/lvm_vg.c	2009/07/26 20:29:28	1.17
@@ -144,14 +144,15 @@
 		return NULL;
 
 	if (!(list = dm_pool_zalloc(vg->vgmem, sizeof(*list)))) {
-		log_error("Memory allocation fail for dm_list.\n");
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.\n");
 		return NULL;
 	}
 	dm_list_init(list);
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (!(pvs = dm_pool_zalloc(vg->vgmem, sizeof(*pvs)))) {
-			log_error("Memory allocation fail for lvm_pv_list.\n");
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_pv_list.\n");
 			return NULL;
 		}
 		pvs->pv = pvl->pv;
@@ -170,14 +171,15 @@
 		return NULL;
 
 	if (!(list = dm_pool_zalloc(vg->vgmem, sizeof(*list)))) {
-		log_error("Memory allocation fail for dm_list.\n");
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.\n");
 		return NULL;
 	}
 	dm_list_init(list);
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!(lvs = dm_pool_zalloc(vg->vgmem, sizeof(*lvs)))) {
-			log_error("Memory allocation fail for lvm_lv_list.\n");
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_lv_list.\n");
 			return NULL;
 		}
 		lvs->lv = lvl->lv;


