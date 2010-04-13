From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Apr 2010 17:26:37 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20100413172637.12698.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-13 17:26:36

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Add pv->vg to solidify link between a pv and a vg.
	
	lvm2app needs a link back to the vg in order to use the vg handle for
	memory allocations as well as other things.  This patch adds the field
	to struct physical_volume, and sets pv->vg when reading a vg from disk or
	extending a vg by using the helper function previously added,
	add_pvl_to_vgs().  Moves and renames are handled with separate code
	inside move_pv() and vgmerge().  Add pv->vg check to vg_validate().
	
	A NULL value in pv->vg signifies membership in the orphan VG.
	Note though in the case of pv_read() on a device with metadatacopies == 0,
	more devices may need to be read for an authoritative answer.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.335&r2=1.336

--- LVM2/lib/metadata/metadata-exported.h	2010/04/13 17:25:44	1.140
+++ LVM2/lib/metadata/metadata-exported.h	2010/04/13 17:26:36	1.141
@@ -181,9 +181,20 @@
 	struct id id;
 	struct device *dev;
 	const struct format_type *fmt;
+
+	/*
+	 * vg_name and vgid are used before the parent VG struct exists.
+	 * FIXME: Investigate removal/substitution with 'vg' fields.
+	 */
 	const char *vg_name;
 	struct id vgid;
 
+	/*
+	 * 'vg' is set and maintained when the PV belongs to a 'pvs'
+	 * list in a parent VG struct.
+	 */
+	struct volume_group *vg;
+
 	uint64_t status;
 	uint64_t size;
 
--- LVM2/lib/metadata/metadata.c	2010/04/13 17:26:20	1.335
+++ LVM2/lib/metadata/metadata.c	2010/04/13 17:26:36	1.336
@@ -143,12 +143,14 @@
 {
 	dm_list_add(&vg->pvs, &pvl->list);
 	vg->pv_count++;
+	pvl->pv->vg = vg;
 }
 
 void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
 {
 	vg->pv_count--;
 	dm_list_del(&pvl->list);
+	pvl->pv->vg = NULL; /* orphan */
 }
 
 
@@ -2158,6 +2160,12 @@
 			/* FIXME Dump list structure? */
 			r = 0;
 		}
+		if (pvl->pv->vg != vg) {
+			log_error(INTERNAL_ERROR "VG %s PV list entry points "
+				  "to different VG %s", vg->name,
+				  pvl->pv->vg ? pvl->pv->vg->name : "NULL");
+			r = 0;
+		}
 	}
 
 	loop_counter1 = loop_counter2 = 0;


