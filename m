From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 Jun 2007 04:23:33 -0000
Subject: LVM2 ./WHATS_NEW tools/vgscan.c tools/vgimport ...
Message-ID: <20070619042333.28476.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-19 04:23:32

Modified files:
	.              : WHATS_NEW 
	tools          : vgscan.c vgimport.c vgchange.c lvcreate.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Add vg_status function and clean up vg->status in tools directory

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.637&r2=1.638
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgimport.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.164&r2=1.165

--- LVM2/WHATS_NEW	2007/06/18 14:14:33	1.637
+++ LVM2/WHATS_NEW	2007/06/19 04:23:31	1.638
@@ -1,6 +1,8 @@
 Version 2.02.27 - 
 ================================
+  Add vg_status function and clean up vg->status in tools directory.
   Add --ignoremonitoring to disable all dmeventd interaction.
+  Remove get_ prefix from get_pv_* functions.
 
 Version 2.02.26 - 15th June 2007
 ================================
--- LVM2/tools/vgscan.c	2006/05/09 21:23:51	1.25
+++ LVM2/tools/vgscan.c	2007/06/19 04:23:32	1.26
@@ -34,7 +34,7 @@
 	}
 
 	log_print("Found %svolume group \"%s\" using metadata type %s",
-		  (vg->status & EXPORTED_VG) ? "exported " : "", vg_name,
+		  (vg_status(vg) & EXPORTED_VG) ? "exported " : "", vg_name,
 		  vg->fid->fmt->name);
 
 	check_current_backup(vg);
--- LVM2/tools/vgimport.c	2006/05/09 21:23:51	1.14
+++ LVM2/tools/vgimport.c	2007/06/19 04:23:32	1.15
@@ -29,12 +29,12 @@
 		goto error;
 	}
 
-	if (!(vg->status & EXPORTED_VG)) {
+	if (!(vg_status(vg) & EXPORTED_VG)) {
 		log_error("Volume group \"%s\" is not exported", vg_name);
 		goto error;
 	}
 
-	if (vg->status & PARTIAL_VG) {
+	if (vg_status(vg) & PARTIAL_VG) {
 		log_error("Volume group \"%s\" is partially missing", vg_name);
 		goto error;
 	}
--- LVM2/tools/vgchange.c	2007/06/18 14:14:33	1.58
+++ LVM2/tools/vgchange.c	2007/06/19 04:23:32	1.59
@@ -134,7 +134,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (activate && lockingfailed() && (vg->status & CLUSTERED)) {
+	if (activate && lockingfailed() && (vg_status(vg) & CLUSTERED)) {
 		log_error("Locking inactive: ignoring clustered "
 			  "volume group %s", vg->name);
 		return ECMD_FAILED;
@@ -207,13 +207,13 @@
 {
 	int resizeable = !strcmp(arg_str_value(cmd, resizeable_ARG, "n"), "y");
 
-	if (resizeable && (vg->status & RESIZEABLE_VG)) {
+	if (resizeable && (vg_status(vg) & RESIZEABLE_VG)) {
 		log_error("Volume group \"%s\" is already resizeable",
 			  vg->name);
 		return ECMD_FAILED;
 	}
 
-	if (!resizeable && !(vg->status & RESIZEABLE_VG)) {
+	if (!resizeable && !(vg_status(vg) & RESIZEABLE_VG)) {
 		log_error("Volume group \"%s\" is already not resizeable",
 			  vg->name);
 		return ECMD_FAILED;
@@ -243,13 +243,13 @@
 	int clustered = !strcmp(arg_str_value(cmd, clustered_ARG, "n"), "y");
 	struct lv_list *lvl;
 
-	if (clustered && (vg->status & CLUSTERED)) {
+	if (clustered && (vg_status(vg) & CLUSTERED)) {
 		log_error("Volume group \"%s\" is already clustered",
 			  vg->name);
 		return ECMD_FAILED;
 	}
 
-	if (!clustered && !(vg->status & CLUSTERED)) {
+	if (!clustered && !(vg_status(vg) & CLUSTERED)) {
 		log_error("Volume group \"%s\" is already not clustered",
 			  vg->name);
 		return ECMD_FAILED;
@@ -289,7 +289,7 @@
 {
 	uint32_t max_lv = arg_uint_value(cmd, logicalvolume_ARG, 0);
 
-	if (!(vg->status & RESIZEABLE_VG)) {
+	if (!(vg_status(vg) & RESIZEABLE_VG)) {
 		log_error("Volume group \"%s\" must be resizeable "
 			  "to change MaxLogicalVolume", vg->name);
 		return ECMD_FAILED;
@@ -331,7 +331,7 @@
 {
 	uint32_t max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG, 0);
 
-	if (!(vg->status & RESIZEABLE_VG)) {
+	if (!(vg_status(vg) & RESIZEABLE_VG)) {
 		log_error("Volume group \"%s\" must be resizeable "
 			  "to change MaxPhysicalVolumes", vg->name);
 		return ECMD_FAILED;
@@ -377,7 +377,7 @@
 {
 	uint32_t extent_size;
 
-	if (!(vg->status & RESIZEABLE_VG)) {
+	if (!(vg_status(vg) & RESIZEABLE_VG)) {
 		log_error("Volume group \"%s\" must be resizeable "
 			  "to change PE size", vg->name);
 		return ECMD_FAILED;
@@ -525,12 +525,12 @@
 			return ECMD_FAILED;
 	}
 
-	if (!(vg->status & LVM_WRITE) && !arg_count(cmd, available_ARG)) {
+	if (!(vg_status(vg) & LVM_WRITE) && !arg_count(cmd, available_ARG)) {
 		log_error("Volume group \"%s\" is read-only", vg->name);
 		return ECMD_FAILED;
 	}
 
-	if (vg->status & EXPORTED_VG) {
+	if (vg_status(vg) & EXPORTED_VG) {
 		log_error("Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
 	}
--- LVM2/tools/lvcreate.c	2007/06/06 19:40:28	1.135
+++ LVM2/tools/lvcreate.c	2007/06/19 04:23:32	1.136
@@ -587,7 +587,7 @@
 			return 0;
 		}
 		/* FIXME Allow exclusive activation. */
-		if (vg->status & CLUSTERED) {
+		if (vg_status(vg) & CLUSTERED) {
 			log_error("Clustered snapshots are not yet supported.");
 			return 0;
 		}
--- LVM2/lib/metadata/metadata.c	2007/06/19 00:33:43	1.119
+++ LVM2/lib/metadata/metadata.c	2007/06/19 04:23:32	1.120
@@ -1837,3 +1837,8 @@
 {
 	return pv_field(pv, pe_alloc_count);
 }
+
+uint32_t vg_status(vg_t *vg)
+{
+	return vg->status;
+}
--- LVM2/lib/metadata/metadata.h	2007/06/19 00:33:43	1.164
+++ LVM2/lib/metadata/metadata.h	2007/06/19 04:23:32	1.165
@@ -235,6 +235,8 @@
 	struct list tags;
 };
 
+typedef struct volume_group vg_t;
+
 /* There will be one area for each stripe */
 struct lv_segment_area {
 	area_type_t type;
@@ -650,4 +652,6 @@
 uint32_t pv_pe_count(pv_t *pv);
 uint32_t pv_pe_alloc_count(pv_t *pv);
 
+uint32_t vg_status(vg_t *vg);
+
 #endif


