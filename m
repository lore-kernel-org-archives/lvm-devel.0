From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:37:23 -0000
Subject: LVM2/lib/report columns.h report.c
Message-ID: <20100628203723.18396.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:37:23

Modified files:
	lib/report     : columns.h report.c 

Log message:
	Add vg_mda_copies display field to 'vgs' command.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/lib/report/columns.h	2010/06/28 20:33:44	1.40
+++ LVM2/lib/report/columns.h	2010/06/28 20:37:23	1.41
@@ -116,6 +116,7 @@
 FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, "vg_mda_used_count", "Number of metadata areas in use on this VG.")
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, "vg_mda_size", "Size of smallest metadata area for this VG in current units.")
+FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, "vg_mda_copies", "Target number of in use metadata areas in the VG.")
 
 FIELD(SEGS, seg, STR, "Type", list, 4, segtype, "segtype", "Type of LV segment.")
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, "stripes", "Number of stripes or mirror legs.")
--- LVM2/lib/report/report.c	2010/06/28 20:33:44	1.120
+++ LVM2/lib/report/report.c	2010/06/28 20:37:23	1.121
@@ -917,6 +917,18 @@
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint32_t count;
+
+	count = vg_mda_copies(vg);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)


