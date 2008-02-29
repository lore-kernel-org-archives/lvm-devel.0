From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Feb 2008 00:13:48 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20080229001348.5326.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-02-29 00:13:48

Modified files:
	tools          : vgsplit.c 

Log message:
	Refactor _move_pv() in vgsplit.
	Should be no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/tools/vgsplit.c	2008/01/30 14:00:02	1.50
+++ LVM2/tools/vgsplit.c	2008/02/29 00:13:48	1.51
@@ -15,18 +15,11 @@
 
 #include "tools.h"
 
-static int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
-		    char *pv_name)
+static void _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
+		     struct pv_list *pvl)
 {
-	struct pv_list *pvl;
 	struct physical_volume *pv;
 
-	if (!(pvl = find_pv_in_vg(vg_from, pv_name))) {
-		log_error("Physical volume %s not in volume group %s",
-			  pv_name, vg_from->name);
-		return 0;
-	}
-
 	list_del(&pvl->list);
 	list_add(&vg_to->pvs, &pvl->list);
 
@@ -40,8 +33,6 @@
 
 	vg_from->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg_to->free_count += pv_pe_count(pv) - pv_pe_alloc_count(pv);
-
-	return 1;
 }
 
 /* FIXME Why not (lv->vg == vg) ? */
@@ -230,6 +221,7 @@
 	int opt;
 	int active;
 	int existing_vg;
+	struct pv_list *pvl;
 
 	if (argc < 3) {
 		log_error("Existing VG, new VG and physical volumes required.");
@@ -312,8 +304,13 @@
 
 	/* Move PVs across to new structure */
 	for (opt = 0; opt < argc; opt++) {
-		if (!_move_pv(vg_from, vg_to, argv[opt]))
+		if (!(pvl = find_pv_in_vg(vg_from, argv[opt]))) {
+			log_error("Physical volume %s not in volume group %s",
+				  argv[opt], vg_from->name);
 			goto error;
+		}
+
+		_move_pv(vg_from, vg_to, pvl);
 	}
 
 	/* Move required LVs across, checking consistency */


