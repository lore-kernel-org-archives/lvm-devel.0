From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2009 04:15:31 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090724041531.7466.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-24 04:15:30

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c to not segfault if null lists of pvs/lvs returned.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/api/test.c	2009/07/23 23:40:50	1.3
+++ LVM2/test/api/test.c	2009/07/24 04:15:30	1.4
@@ -124,14 +124,28 @@
 	}
 	return vg;
 }
+static void _add_lvs_to_lvname_hash(struct dm_list *lvs)
+{
+	struct lvm_lv_list *lvl;
+	dm_list_iterate_items(lvl, lvs) {
+		/* Concatenate VG name with LV name */
+		dm_hash_insert(_lvname_hash, lvm_lv_get_name(lvl->lv), lvl->lv);
+	}
+}
+
+static void _add_pvs_to_pvname_hash(struct dm_list *pvs)
+{
+	struct lvm_pv_list *pvl;
+	dm_list_iterate_items(pvl, pvs) {
+		dm_hash_insert(_pvname_hash, lvm_pv_get_name(pvl->pv), pvl->pv);
+	}
+}
 
 static void _vg_open(char **argv, int argc, lvm_t libh)
 {
 	vg_t *vg;
 	struct dm_list *lvs;
-	struct lvm_lv_list *lvl;
 	struct dm_list *pvs;
-	struct lvm_pv_list *pvl;
 
 	if (argc < 2) {
 		printf ("Please enter vg_name\n");
@@ -157,14 +171,11 @@
 	 * Add the LVs and PVs into the hashes for lookups
 	 */
 	lvs = lvm_vg_list_lvs(vg);
-	dm_list_iterate_items(lvl, lvs) {
-		/* Concatenate VG name with LV name */
-		dm_hash_insert(_lvname_hash, lvm_lv_get_name(lvl->lv), lvl->lv);
-	}
+	if (lvs && !dm_list_empty(lvs))
+		_add_lvs_to_lvname_hash(lvs);
 	pvs = lvm_vg_list_pvs(vg);
-	dm_list_iterate_items(pvl, pvs) {
-		dm_hash_insert(_pvname_hash, lvm_pv_get_name(pvl->pv), pvl->pv);
-	}
+	if (pvs && !dm_list_empty(pvs))
+		_add_pvs_to_pvname_hash(pvs);
 }
 
 static void _vg_close(char **argv, int argc)


