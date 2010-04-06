From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Apr 2010 14:04:21 -0000
Subject: LVM2/lib/format1 disk-rep.h format1.c import-e ...
Message-ID: <20100406140421.24209.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-06 14:04:20

Modified files:
	lib/format1    : disk-rep.h format1.c import-export.c 

Log message:
	Refactor format1 vg->pvs list add and vg->pv_count.
	
	Refactor adding to the vg->pvs list and incrementing the count, which
	will allow further refactoring.  Should be no functional change.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.h.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/lib/format1/disk-rep.h	2009/05/13 21:24:12	1.54
+++ LVM2/lib/format1/disk-rep.h	2010/04/06 14:04:20	1.55
@@ -224,8 +224,7 @@
 		   struct logical_volume *lv, struct physical_volume *pv);
 
 int import_pvs(const struct format_type *fmt, struct dm_pool *mem,
-	       struct volume_group *vg,
-	       struct dm_list *pvds, struct dm_list *results, uint32_t *count);
+	       struct volume_group *vg, struct dm_list *pvds);
 
 int import_lvs(struct dm_pool *mem, struct volume_group *vg, struct dm_list *pvds);
 int export_lvs(struct disk_list *dl, struct volume_group *vg,
--- LVM2/lib/format1/format1.c	2009/12/11 13:16:38	1.115
+++ LVM2/lib/format1/format1.c	2010/04/06 14:04:20	1.116
@@ -142,7 +142,7 @@
 	if (!import_vg(mem, vg, dl))
 		goto_bad;
 
-	if (!import_pvs(fid->fmt, mem, vg, pvs, &vg->pvs, &vg->pv_count))
+	if (!import_pvs(fid->fmt, mem, vg, pvs))
 		goto_bad;
 
 	if (!import_lvs(mem, vg, pvs))
--- LVM2/lib/format1/import-export.c	2010/04/01 10:34:10	1.111
+++ LVM2/lib/format1/import-export.c	2010/04/06 14:04:20	1.112
@@ -422,13 +422,12 @@
 }
 
 int import_pvs(const struct format_type *fmt, struct dm_pool *mem,
-	       struct volume_group *vg,
-	       struct dm_list *pvds, struct dm_list *results, uint32_t *count)
+	       struct volume_group *vg, struct dm_list *pvds)
 {
 	struct disk_list *dl;
 	struct pv_list *pvl;
 
-	*count = 0;
+	vg->pv_count = 0;
 	dm_list_iterate_items(dl, pvds) {
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
 		    !(pvl->pv = dm_pool_alloc(mem, sizeof(*pvl->pv))))
@@ -438,8 +437,8 @@
 			return_0;
 
 		pvl->pv->fmt = fmt;
-		dm_list_add(results, &pvl->list);
-		(*count)++;
+		dm_list_add(&vg->pvs, &pvl->list);
+		vg->pv_count++;
 	}
 
 	return 1;


