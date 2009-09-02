From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:39:50 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090902213950.18611.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:39:49

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Update vg_remove_single_* functions to use the removed_pvs list.
	
	Now that we've split vg_remove_single into two routines, in the first routine
	that only manipulates memory, we move the PVs from the vg->pvs list to the
	vg->removed_pvs list.  Then later, we iterate through this list to write the
	removed PVs to disk, which removes them from the volume group and places them
	into the internal ORPHAN VG.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.281&r2=1.282

--- LVM2/lib/metadata/metadata.c	2009/09/02 21:39:29	1.281
+++ LVM2/lib/metadata/metadata.c	2009/09/02 21:39:49	1.282
@@ -471,6 +471,7 @@
 int vg_remove_check(struct volume_group *vg)
 {
 	unsigned lv_count;
+	struct pv_list *pvl, *tpvl;
 
 	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
@@ -494,6 +495,10 @@
 	if (!archive(vg))
 		return 0;
 
+	dm_list_iterate_items_safe(pvl, tpvl, &vg->pvs) {
+		dm_list_del(&pvl->list);
+		dm_list_add(&vg->removed_pvs, &pvl->list);
+	}
 	return 1;
 }
 
@@ -515,7 +520,7 @@
 	}
 
 	/* init physical volumes */
-	dm_list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vg->removed_pvs) {
 		pv = pvl->pv;
 		log_verbose("Removing physical volume \"%s\" from "
 			    "volume group \"%s\"", pv_dev_name(pv), vg->name);


