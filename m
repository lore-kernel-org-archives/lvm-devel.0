From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 4 Oct 2010 18:59:04 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c test/t- ...
Message-ID: <20101004185904.9403.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-10-04 18:59:02

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	test           : t-vgcfgbackup-usage.sh 

Log message:
	Restrict lvm1 partial mode.
	
	Current lvm1 allocation code seems to not properly
	map segments on missing PVs.
	
	For now disable this functionality.
	(It never worked and previous commit just introduced segfault here.)
	
	So the partial mode in lvm1 can only process missing PVs
	with no LV segments only.
	
	Also do not use random PV UUID for missing part but use fixed
	string derived from VG UUID (to not confuse clvmd tests).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1744&r2=1.1745
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcfgbackup-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2010/09/30 21:06:50	1.1744
+++ LVM2/WHATS_NEW	2010/10/04 18:59:01	1.1745
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Avoid segfault by limiting partial mode for lvm1 metadata. (2.02.74)
   Add dm_zalloc and use it and dm_pool_zalloc throughout.
   Add pv_get_property and create generic internal _get_property function.
   Add 'get' functions for pv and vg properties/fields.
--- LVM2/lib/format1/format1.c	2010/09/30 21:06:51	1.123
+++ LVM2/lib/format1/format1.c	2010/10/04 18:59:02	1.124
@@ -118,6 +118,28 @@
 	struct disk_list *dl;
 	struct dm_list *pvh;
 	struct pv_list *pvl;
+	struct lv_list *ll;
+	struct lv_segment *seg;
+
+	/*
+	 * FIXME: code should remap missing segments to error segment.
+	 * Also current mapping code allocates 1 segment per missing extent.
+	 * For now bail out completely - allocated structures are not complete
+	 */
+	dm_list_iterate_items(ll, &vg->lvs)
+		dm_list_iterate_items(seg, &ll->lv->segments) {
+
+			/* area_count is always 1 here, s == 0 */
+			if (seg_type(seg, 0) != AREA_PV)
+				continue;
+
+			if (seg_pv(seg, 0))
+				continue;
+
+			log_error("Partial mode support for missing lvm1 PVs and "
+				  "partially available LVs is currently not implemented.");
+			return 0;
+	}
 
 	dm_list_iterate(pvh, pvs) {
 		dl = dm_list_item(pvh, struct disk_list);
@@ -129,8 +151,10 @@
 	    !(pvl->pv = dm_pool_zalloc(vg->vgmem, sizeof(*pvl->pv))))
 		return_0;
 
-	if (!id_create(&pvl->pv->id))
-		goto_out;
+	/* Use vg uuid with replaced first chars to "missing" as missing PV UUID */
+	memcpy(&pvl->pv->id.uuid, vg->id.uuid, sizeof(pvl->pv->id.uuid));
+	memcpy(&pvl->pv->id.uuid, "missing", 7);
+
 	if (!(pvl->pv->vg_name = dm_pool_strdup(vg->vgmem, vg->name)))
 		goto_out;
 	memcpy(&pvl->pv->vgid, &vg->id, sizeof(vg->id));
--- LVM2/test/t-vgcfgbackup-usage.sh	2010/09/22 13:45:23	1.5
+++ LVM2/test/t-vgcfgbackup-usage.sh	2010/10/04 18:59:02	1.6
@@ -43,6 +43,9 @@
 vgremove -ff $vg
 
 # vgcfgbackup correctly stores metadata LVM1 with missing PVs
+# FIXME: clvmd seems to have problem with metadata format change here
+# fix it and remove this vgscan
+vgscan
 pvcreate -M1 $devs
 vgcreate -M1 -c n $vg $devs
 lvcreate -l1 -n $lv1 $vg $dev1


