From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Apr 2010 17:25:14 -0000
Subject: LVM2/lib/format_pool disk_rep.h format_pool.c ...
Message-ID: <20100413172514.9916.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-13 17:25:14

Modified files:
	lib/format_pool: disk_rep.h format_pool.c import_export.c 

Log message:
	Remove unnecessary parameter from import_pool_pvs().
	
	The dm_list * parameter is unnecessary since we are passing in 'vg'
	and the only caller of import_pool_pvs() passes '&vg->pvs' in the
	dm_list * parameter.  Just use vg->pvs directly in the function.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/lib/format_pool/disk_rep.h	2008/11/03 22:14:28	1.7
+++ LVM2/lib/format_pool/disk_rep.h	2010/04/13 17:25:13	1.8
@@ -141,7 +141,7 @@
 int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem,
 		    struct dm_list *pls);
 int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
-		    struct dm_list *pvs, struct dm_pool *mem, struct dm_list *pls);
+		    struct dm_pool *mem, struct dm_list *pls);
 int import_pool_pv(const struct format_type *fmt, struct dm_pool *mem,
 		   struct volume_group *vg, struct physical_volume *pv,
 		   struct pool_list *pl);
--- LVM2/lib/format_pool/format_pool.c	2009/12/11 13:16:38	1.26
+++ LVM2/lib/format_pool/format_pool.c	2010/04/13 17:25:13	1.27
@@ -129,7 +129,7 @@
 	if (!import_pool_vg(vg, smem, pds))
 		return_NULL;
 
-	if (!import_pool_pvs(fid->fmt, vg, &vg->pvs, smem, pds))
+	if (!import_pool_pvs(fid->fmt, vg, smem, pds))
 		return_NULL;
 
 	if (!import_pool_lvs(vg, smem, pds))
--- LVM2/lib/format_pool/import_export.c	2010/04/08 00:28:58	1.29
+++ LVM2/lib/format_pool/import_export.c	2010/04/13 17:25:13	1.30
@@ -100,7 +100,7 @@
 }
 
 int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
-		    struct dm_list *pvs, struct dm_pool *mem, struct dm_list *pls)
+		    struct dm_pool *mem, struct dm_list *pls)
 {
 	struct pv_list *pvl;
 	struct pool_list *pl;
@@ -120,7 +120,7 @@
 		pl->pv = pvl->pv;
 		pvl->mdas = NULL;
 		pvl->pe_ranges = NULL;
-		dm_list_add(pvs, &pvl->list);
+		dm_list_add(&vg->pvs, &pvl->list);
 	}
 
 	return 1;


