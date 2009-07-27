From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 21:03:15 -0000
Subject: LVM2/liblvm lvm_lv.c lvm_pv.c lvm_vg.c
Message-ID: <20090727210315.18525.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 21:03:15

Modified files:
	liblvm         : lvm_lv.c lvm_pv.c lvm_vg.c 

Log message:
	Remove unnecessary \n's from log_error in liblvm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/liblvm/lvm_lv.c	2009/07/27 21:00:50	1.8
+++ LVM2/liblvm/lvm_lv.c	2009/07/27 21:03:15	1.9
@@ -133,13 +133,13 @@
 
 	/* FIXME: handle pvmove stuff later */
 	if (lv->status & LOCKED) {
-		log_error("Unable to activate locked LV\n");
+		log_error("Unable to activate locked LV");
 		return -1;
 	}
 
 	/* FIXME: handle lvconvert stuff later */
 	if (lv->status & CONVERTING) {
-		log_error("Unable to activate LV with in-progress lvconvert\n");
+		log_error("Unable to activate LV with in-progress lvconvert");
 		return -1;
 	}
 
@@ -147,14 +147,14 @@
 		log_verbose("Activating logical volume \"%s\" "
 			    "exclusively", lv->name);
 		if (!activate_lv_excl(lv->vg->cmd, lv)) {
-			log_error("Activate exclusive failed.\n");
+			log_error("Activate exclusive failed.");
 			return -1;
 		}
 	} else {
 		log_verbose("Activating logical volume \"%s\"",
 			    lv->name);
 		if (!activate_lv(lv->vg->cmd, lv)) {
-			log_error("Activate failed.\n");
+			log_error("Activate failed.");
 			return -1;
 		}
 	}
@@ -168,7 +168,7 @@
 
 	log_verbose("Deactivating logical volume \"%s\"", lv->name);
 	if (!deactivate_lv(lv->vg->cmd, lv)) {
-		log_error("Deactivate failed.\n");
+		log_error("Deactivate failed.");
 		return -1;
 	}
 	return 0;
@@ -177,6 +177,6 @@
 int lvm_lv_resize(const lv_t *lv, uint64_t new_size)
 {
 	/* FIXME: add lv resize code here */
-	log_error("NOT IMPLEMENTED YET\n");
+	log_error("NOT IMPLEMENTED YET");
 	return -1;
 }
--- LVM2/liblvm/lvm_pv.c	2009/07/27 21:00:50	1.3
+++ LVM2/liblvm/lvm_pv.c	2009/07/27 21:03:15	1.4
@@ -46,6 +46,6 @@
 int lvm_pv_resize(const pv_t *pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */
-	log_error("NOT IMPLEMENTED YET\n");
+	log_error("NOT IMPLEMENTED YET");
 	return -1;
 }
--- LVM2/liblvm/lvm_vg.c	2009/07/27 17:44:29	1.19
+++ LVM2/liblvm/lvm_vg.c	2009/07/27 21:03:15	1.20
@@ -51,7 +51,7 @@
 	/* If device not initialized, pvcreate it */
 	if (!pv_by_path(vg->cmd, device) &&
 	   (!pvcreate_single(vg->cmd, device, NULL))) {
-		log_error("Unable to initialize device for LVM use\n");
+		log_error("Unable to initialize device for LVM use");
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return -1;
 	}
@@ -97,7 +97,7 @@
 
 	if (dm_list_empty(&vg->pvs)) {
 		log_error("Volume group %s does not contain any "
-			  "physical volumes.\n", vg->name);
+			  "physical volumes.", vg->name);
 		return -1;
 	}
 
@@ -179,7 +179,7 @@
 		return NULL;
 
 	if (!(list = dm_pool_zalloc(vg->vgmem, sizeof(*list)))) {
-		log_errno(ENOMEM, "Memory allocation fail for dm_list.\n");
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
 		return NULL;
 	}
 	dm_list_init(list);
@@ -187,7 +187,7 @@
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (!(pvs = dm_pool_zalloc(vg->vgmem, sizeof(*pvs)))) {
 			log_errno(ENOMEM,
-				"Memory allocation fail for lvm_pv_list.\n");
+				"Memory allocation fail for lvm_pv_list.");
 			return NULL;
 		}
 		pvs->pv = pvl->pv;
@@ -206,7 +206,7 @@
 		return NULL;
 
 	if (!(list = dm_pool_zalloc(vg->vgmem, sizeof(*list)))) {
-		log_errno(ENOMEM, "Memory allocation fail for dm_list.\n");
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
 		return NULL;
 	}
 	dm_list_init(list);
@@ -214,7 +214,7 @@
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!(lvs = dm_pool_zalloc(vg->vgmem, sizeof(*lvs)))) {
 			log_errno(ENOMEM,
-				"Memory allocation fail for lvm_lv_list.\n");
+				"Memory allocation fail for lvm_lv_list.");
 			return NULL;
 		}
 		lvs->lv = lvl->lv;


