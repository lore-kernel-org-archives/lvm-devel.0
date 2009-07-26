From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 12:41:09 -0000
Subject: LVM2/lib metadata/metadata-exported.h metadata ...
Message-ID: <20090726124109.14909.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 12:41:09

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	lib/report     : report.c 

Log message:
	Refactor a few report field calculations into separate functions.
	
	For liblvm 'get' functions, we should share code with the reporting functions.
	This means we need common code to return the values for the fields.
	In this patch we refactor a few of the fields needed in liblvm.
	Unfortunately, for the simple fields that do derefernces of structure
	members (for example, vg_extent_count), we cannot call the common function
	from the reporting infrastructure without more refactoring.  The reason is
	that the dereference of the simple fields is done deep inside the reporting
	code (to get the generic "data" pointer), and the display function is a
	generic 'size32' function.  We can fix these issues later with more
	refactoring.
	
	Should be no functional change and the testsuite should cover any possible
	regressions.  The only fields in the report affected by this patch are:
	vg_size, vg_free, and pv_mda_count.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.267&r2=1.268
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/lib/metadata/metadata-exported.h	2009/07/26 02:34:09	1.101
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/26 12:41:09	1.102
@@ -693,9 +693,18 @@
 uint64_t pv_pe_start(const pv_t *pv);
 uint32_t pv_pe_count(const pv_t *pv);
 uint32_t pv_pe_alloc_count(const pv_t *pv);
+uint32_t pv_mda_count(const pv_t *pv);
+
+uint64_t lv_size(const lv_t *lv);
 
 int vg_missing_pv_count(const vg_t *vg);
 uint32_t vg_status(const vg_t *vg);
+uint64_t vg_size(const vg_t *vg);
+uint64_t vg_free(const vg_t *vg);
+uint64_t vg_extent_size(const vg_t *vg);
+uint64_t vg_extent_count(const vg_t *vg);
+uint64_t vg_free_count(const vg_t *vg);
+uint64_t vg_pv_count(const vg_t *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 
 struct vgcreate_params {
--- LVM2/lib/metadata/metadata.c	2009/07/26 02:34:09	1.267
+++ LVM2/lib/metadata/metadata.c	2009/07/26 12:41:09	1.268
@@ -3364,11 +3364,54 @@
 	return pv_field(pv, pe_alloc_count);
 }
 
+uint32_t pv_mda_count(const pv_t *pv)
+{
+	struct lvmcache_info *info;
+
+	info = info_from_pvid((const char *)&pv->id.uuid, 0);
+	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
+}
+
 uint32_t vg_status(const vg_t *vg)
 {
 	return vg->status;
 }
 
+uint64_t vg_size(const vg_t *vg)
+{
+	return (uint64_t) vg->extent_count * vg->extent_size;
+}
+
+uint64_t vg_free(const vg_t *vg)
+{
+	return (uint64_t) vg->free_count * vg->extent_size;
+}
+
+uint64_t vg_extent_size(const vg_t *vg)
+{
+	return (uint64_t) vg->extent_size;
+}
+
+uint64_t vg_extent_count(const vg_t *vg)
+{
+	return (uint64_t) vg->extent_count;
+}
+
+uint64_t vg_free_count(const vg_t *vg)
+{
+	return (uint64_t) vg->free_count;
+}
+
+uint64_t vg_pv_count(const vg_t *vg)
+{
+	return (uint64_t) vg->pv_count;
+}
+
+uint64_t lv_size(const lv_t *lv)
+{
+	return lv->size;
+}
+
 /**
  * pv_by_path - Given a device path return a PV handle if it is a PV
  * @cmd - handle to the LVM command instance
--- LVM2/lib/report/report.c	2009/05/13 21:27:44	1.99
+++ LVM2/lib/report/report.c	2009/07/26 12:41:09	1.100
@@ -672,7 +672,7 @@
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t size;
 
-	size = (uint64_t) vg->extent_count * vg->extent_size;
+	size = (uint64_t) vg_size(vg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
@@ -812,7 +812,7 @@
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t freespace;
 
-	freespace = (uint64_t) vg->free_count * vg->extent_size;
+	freespace = (uint64_t) vg_free(vg);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
@@ -853,12 +853,11 @@
 			struct dm_report_field *field,
 			const void *data, void *private)
 {
-	struct lvmcache_info *info;
 	uint32_t count;
-	const char *pvid = (const char *)(&((struct id *) data)->uuid);
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
 
-	info = info_from_pvid(pvid, 0);
-	count = info ? dm_list_size(&info->mdas) : 0;
+	count = pv_mda_count(pv);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }


