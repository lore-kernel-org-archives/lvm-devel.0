From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Sep 2010 13:45:25 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c test/t- ...
Message-ID: <20100922134525.893.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-09-22 13:45:23

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	test           : t-vgcfgbackup-usage.sh 

Log message:
	Fix handling of partial VG for lvm1 format metadata
	
	If some lvm1 device is missing, lvm fails on all operations
	# vgcfgbackup -f bck -P vg_test
	Partial mode. Incomplete volume groups will be activated read-only.
	3 PV(s) found for VG vg_test: expected 4
	PV segment VG free_count mismatch: 152599 != 228909
	PV segment VG extent_count mismatch: 152600 != 228910
	Internal error: PV segments corrupted in vg_test.
	Volume group "vg_test" not found
	
	Allow loading of lvm1 partial VG by allocating "new" missing PV,
	which covers lost space. Also this fake mising PV inform code
	that it is partial VG.
	
	https://bugzilla.redhat.com/show_bug.cgi?id=501390

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1732&r2=1.1733
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcfgbackup-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2010/09/22 01:36:13	1.1732
+++ LVM2/WHATS_NEW	2010/09/22 13:45:21	1.1733
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 =====================================
+  Fix partial mode operations for lvm1 metadata format.
   Track recursive filter iteration to avoid refreshing while in use. (2.02.56)
   Revert to old glibc vsnprintf behaviour in emit_to_buffer() to catch overflow.
   Allocate buffer for metadata tags dynamically to remove 4k limit.
--- LVM2/lib/format1/format1.c	2010/07/09 15:34:44	1.121
+++ LVM2/lib/format1/format1.c	2010/09/22 13:45:22	1.122
@@ -21,9 +21,10 @@
 #include "lvm1-label.h"
 #include "format1.h"
 #include "segtype.h"
+#include "pv_alloc.h"
 
 /* VG consistency checks */
-static int _check_vgs(struct dm_list *pvs)
+static int _check_vgs(struct dm_list *pvs, struct volume_group *vg)
 {
 	struct dm_list *pvh, *t;
 	struct disk_list *dl = NULL;
@@ -105,11 +106,53 @@
 	if (pv_count != first->vgd.pv_cur) {
 		log_error("%d PV(s) found for VG %s: expected %d",
 			  pv_count, first->pvd.vg_name, first->vgd.pv_cur);
+		vg->status |= PARTIAL_VG;
 	}
 
 	return 1;
 }
 
+static int _fix_partial_vg(struct volume_group *vg, struct dm_list *pvs)
+{
+	uint32_t extent_count = 0;
+	struct disk_list *dl;
+	struct dm_list *pvh;
+	struct pv_list *pvl;
+
+	dm_list_iterate(pvh, pvs) {
+		dl = dm_list_item(pvh, struct disk_list);
+		extent_count += dl->pvd.pe_total;
+	}
+
+	/* FIXME: move this to one place to pv_manip */
+	if (!(pvl = dm_pool_zalloc(vg->vgmem, sizeof(*pvl))) ||
+	    !(pvl->pv = dm_pool_zalloc(vg->vgmem, sizeof(*pvl->pv))))
+		return_0;
+
+	if (!id_create(&pvl->pv->id))
+		goto_out;
+	if (!(pvl->pv->vg_name = dm_pool_strdup(vg->vgmem, vg->name)))
+		goto_out;
+	memcpy(&pvl->pv->vgid, &vg->id, sizeof(vg->id));
+	pvl->pv->status |= MISSING_PV;
+	dm_list_init(&pvl->pv->tags);
+	dm_list_init(&pvl->pv->segments);
+
+	pvl->pv->pe_size = vg->extent_size;
+	pvl->pv->pe_count = vg->extent_count - extent_count;
+	if (!alloc_pv_segment_whole_pv(vg->vgmem, pvl->pv))
+		goto_out;
+
+	add_pvl_to_vgs(vg, pvl);
+	log_debug("%s: partial VG, allocated missing PV using %d extents.",
+		  vg->name, pvl->pv->pe_count);
+
+	return 1;
+out:
+	dm_pool_free(vg->vgmem, pvl);
+	return 0;
+}
+
 static struct volume_group *_build_vg(struct format_instance *fid,
 				      struct dm_list *pvs,
 				      struct dm_pool *mem)
@@ -134,7 +177,7 @@
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
 
-	if (!_check_vgs(pvs))
+	if (!_check_vgs(pvs, vg))
 		goto_bad;
 
 	dl = dm_list_item(pvs->n, struct disk_list);
@@ -154,6 +197,10 @@
 	if (!import_snapshots(mem, vg, pvs))
 		goto_bad;
 
+	/* Fix extents counts by adding missing PV if partial VG */
+	if ((vg->status & PARTIAL_VG) && !_fix_partial_vg(vg, pvs))
+		goto_bad;
+
 	return vg;
 
       bad:
--- LVM2/test/t-vgcfgbackup-usage.sh	2010/08/12 04:09:00	1.4
+++ LVM2/test/t-vgcfgbackup-usage.sh	2010/09/22 13:45:23	1.5
@@ -40,3 +40,12 @@
 pvcreate -ff -y --norestorefile -u $pv1_uuid $dev1
 pvcreate -ff -y --norestorefile -u $pv2_uuid $dev2
 vgcfgrestore -f "$(pwd)/backup.$$1" $vg
+vgremove -ff $vg
+
+# vgcfgbackup correctly stores metadata LVM1 with missing PVs
+pvcreate -M1 $devs
+vgcreate -M1 -c n $vg $devs
+lvcreate -l1 -n $lv1 $vg $dev1
+pvremove -ff -y $dev2
+not lvcreate -l1 -n $lv1 $vg $dev3
+vgcfgbackup -f "$(pwd)/backup.$$" $vg


