From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 31 Oct 2009 17:26:14 -0000
Subject: LVM2/lib metadata/metadata-exported.h metadata ...
Message-ID: <20091031172614.9150.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-31 17:26:14

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	lib/report     : report.c 

Log message:
	Add vg_mda_count library function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.291&r2=1.292
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106

--- LVM2/lib/metadata/metadata-exported.h	2009/10/16 17:41:52	1.117
+++ LVM2/lib/metadata/metadata-exported.h	2009/10/31 17:26:13	1.118
@@ -730,6 +730,7 @@
 uint64_t vg_pv_count(const struct volume_group *vg);
 uint64_t vg_max_pv(const struct volume_group *vg);
 uint64_t vg_max_lv(const struct volume_group *vg);
+uint32_t vg_mda_count(const struct volume_group *vg);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
--- LVM2/lib/metadata/metadata.c	2009/10/16 17:41:52	1.291
+++ LVM2/lib/metadata/metadata.c	2009/10/31 17:26:13	1.292
@@ -3611,6 +3611,11 @@
 	return (uint64_t) vg->max_lv;
 }
 
+uint32_t vg_mda_count(const struct volume_group *vg)
+{
+	return dm_list_size(&vg->fid->metadata_areas);
+}
+
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
--- LVM2/lib/report/report.c	2009/10/26 10:01:57	1.105
+++ LVM2/lib/report/report.c	2009/10/31 17:26:14	1.106
@@ -870,7 +870,7 @@
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint32_t count;
 
-	count = dm_list_size(&vg->fid->metadata_areas);
+	count = vg_mda_count(vg);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }


