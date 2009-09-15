From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Sep 2009 18:35:16 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c lib/for ...
Message-ID: <20090915183516.27197.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-15 18:35:14

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 
	lib/format1    : import-export.c 
	lib/metadata   : metadata-exported.h metadata.c 
	lib/report     : report.c 
	tools          : vgchange.c 

Log message:
	Add vg_is_resizeable() and cleanup references.
	
	Clean up VG_RESIZEABLE flag by creating vg_is_resizeable().
	Update comment - we no longer have ALLOW_RESIZEABLE.
	Also use vg_is_exported() in one place missed by earlier patch.
	Should be no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1265&r2=1.1266
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.283&r2=1.284
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/WHATS_NEW	2009/09/15 13:54:28	1.1265
+++ LVM2/WHATS_NEW	2009/09/15 18:35:13	1.1266
@@ -1,5 +1,6 @@
 Version 2.02.53 - 
 =====================================
+  Add vg_is_resizeable() and cleanup reference to VG_RESIZEABLE.
 
 Version 2.02.52 - 15th September 2009
 =====================================
--- LVM2/lib/display/display.c	2009/09/14 19:44:15	1.100
+++ LVM2/lib/display/display.c	2009/09/15 18:35:14	1.101
@@ -598,7 +598,7 @@
 		  access_str == 0 ? "error" : "");
 	log_print("VG Status             %s%sresizable",
 		  vg_is_exported(vg) ? "exported/" : "",
-		  vg->status & RESIZEABLE_VG ? "" : "NOT ");
+		  vg_is_resizeable(vg) ? "" : "NOT ");
 	/* vg number not part of LVM2 design
 	   log_print ("VG #                  %u\n", vg->vg_number);
 	 */
--- LVM2/lib/format1/import-export.c	2009/09/14 19:44:15	1.108
+++ LVM2/lib/format1/import-export.c	2009/09/15 18:35:14	1.109
@@ -278,7 +278,7 @@
 	if (vg_is_exported(vg))
 		vgd->vg_status |= VG_EXPORTED;
 
-	if (vg->status & RESIZEABLE_VG)
+	if (vg_is_resizeable(vg))
 		vgd->vg_status |= VG_EXTENDABLE;
 
 	vgd->lv_max = vg->max_lv;
--- LVM2/lib/metadata/metadata-exported.h	2009/09/14 19:43:11	1.111
+++ LVM2/lib/metadata/metadata-exported.h	2009/09/15 18:35:14	1.112
@@ -722,6 +722,7 @@
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
+#define vg_is_resizeable(vg) (vg_status((vg)) & RESIZEABLE_VG)
 
 struct vgcreate_params {
 	char *vg_name;
--- LVM2/lib/metadata/metadata.c	2009/09/14 15:45:23	1.283
+++ LVM2/lib/metadata/metadata.c	2009/09/15 18:35:14	1.284
@@ -865,7 +865,7 @@
 	struct pv_segment *pvseg;
 	uint32_t s;
 
-	if (!(vg_status(vg) & RESIZEABLE_VG)) {
+	if (!vg_is_resizeable(vg)) {
 		log_error("Volume group \"%s\" must be resizeable "
 			  "to change PE size", vg->name);
 		return 0;
@@ -1003,7 +1003,7 @@
 
 int vg_set_max_lv(struct volume_group *vg, uint32_t max_lv)
 {
-	if (!(vg_status(vg) & RESIZEABLE_VG)) {
+	if (!vg_is_resizeable(vg)) {
 		log_error("Volume group \"%s\" must be resizeable "
 			  "to change MaxLogicalVolume", vg->name);
 		return 0;
@@ -1031,7 +1031,7 @@
 
 int vg_set_max_pv(struct volume_group *vg, uint32_t max_pv)
 {
-	if (!(vg_status(vg) & RESIZEABLE_VG)) {
+	if (!vg_is_resizeable(vg)) {
 		log_error("Volume group \"%s\" must be resizeable "
 			  "to change MaxPhysicalVolumes", vg->name);
 		return 0;
@@ -3148,7 +3148,7 @@
 	}
 
 	if ((status & EXPORTED_VG) &&
-	    (vg->status & EXPORTED_VG)) {
+	    vg_is_exported(vg)) {
 		log_error("Volume group %s is exported", vg->name);
 		failure |= FAILED_EXPORTED;
 	}
@@ -3160,7 +3160,7 @@
 	}
 
 	if ((status & RESIZEABLE_VG) &&
-	    !(vg->status & RESIZEABLE_VG)) {
+	    !vg_is_resizeable(vg)) {
 		log_error("Volume group %s is not resizeable.", vg->name);
 		failure |= FAILED_RESIZEABLE;
 	}
@@ -3311,8 +3311,7 @@
  *  - metadata inconsistent and automatic correction failed: FAILED_INCONSISTENT
  *  - VG is read-only: FAILED_READ_ONLY
  *  - VG is EXPORTED, unless flags has READ_ALLOW_EXPORTED: FAILED_EXPORTED
- *  - VG is not RESIZEABLE, unless flags has ALLOW_NONRESIZEABLE:
- *    FAILED_RESIZEABLE
+ *  - VG is not RESIZEABLE: FAILED_RESIZEABLE
  *  - locking failed: FAILED_LOCKING
  *
  * On failures, all locks are released, unless one of the following applies:
--- LVM2/lib/report/report.c	2009/09/14 19:44:16	1.101
+++ LVM2/lib/report/report.c	2009/09/15 18:35:14	1.102
@@ -429,7 +429,7 @@
 	else
 		repstr[0] = 'r';
 
-	if (vg->status & RESIZEABLE_VG)
+	if (vg_is_resizeable(vg))
 		repstr[1] = 'z';
 	else
 		repstr[1] = '-';
--- LVM2/tools/vgchange.c	2009/09/15 01:38:59	1.85
+++ LVM2/tools/vgchange.c	2009/09/15 18:35:14	1.86
@@ -212,13 +212,13 @@
 {
 	int resizeable = !strcmp(arg_str_value(cmd, resizeable_ARG, "n"), "y");
 
-	if (resizeable && (vg_status(vg) & RESIZEABLE_VG)) {
+	if (resizeable && vg_is_resizeable(vg)) {
 		log_error("Volume group \"%s\" is already resizeable",
 			  vg->name);
 		return ECMD_FAILED;
 	}
 
-	if (!resizeable && !(vg_status(vg) & RESIZEABLE_VG)) {
+	if (!resizeable && !vg_is_resizeable(vg)) {
 		log_error("Volume group \"%s\" is already not resizeable",
 			  vg->name);
 		return ECMD_FAILED;


