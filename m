From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 10:07:47 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090709100747.11620.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 10:07:47

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgchange.c 

Log message:
	Add vg_set_max_pv() liblvm function and move vgchange logic inside.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.238&r2=1.239
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:06:00	1.84
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:07:47	1.85
@@ -436,6 +436,7 @@
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
 int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
 int vg_set_max_lv(vg_t *vg, uint32_t max_lv);
+int vg_set_max_pv(vg_t *vg, uint32_t max_pv);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
--- LVM2/lib/metadata/metadata.c	2009/07/09 10:06:00	1.238
+++ LVM2/lib/metadata/metadata.c	2009/07/09 10:07:47	1.239
@@ -802,6 +802,33 @@
 	return 1;
 }
 
+int vg_set_max_pv(vg_t *vg, uint32_t max_pv)
+{
+	if (!(vg_status(vg) & RESIZEABLE_VG)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change MaxPhysicalVolumes", vg->name);
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!max_pv)
+			max_pv = 255;
+		else if (max_pv > 255) {
+			log_error("MaxPhysicalVolume limit is 255");
+			return 0;
+		}
+	}
+
+	if (max_pv && max_pv < vg->pv_count) {
+		log_error("MaxPhysicalVolumes is less than the current number "
+			  "%d of PVs for \"%s\"", vg->pv_count,
+			  vg->name);
+		return 0;
+	}
+	vg->max_pv = max_pv;
+	return 1;
+}
+
 /*
  * Separate metadata areas after splitting a VG.
  * Also accepts orphan VG as destination (for vgreduce).
--- LVM2/tools/vgchange.c	2009/07/09 10:06:01	1.78
+++ LVM2/tools/vgchange.c	2009/07/09 10:07:47	1.79
@@ -314,37 +314,16 @@
 {
 	uint32_t max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG, 0);
 
-	if (!(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" must be resizeable "
-			  "to change MaxPhysicalVolumes", vg->name);
-		return ECMD_FAILED;
-	}
-
 	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, 0) == SIGN_MINUS) {
 		log_error("MaxPhysicalVolumes may not be negative");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
-		if (!max_pv)
-			max_pv = 255;
-		else if (max_pv > 255) {
-			log_error("MaxPhysicalVolume limit is 255");
-			return ECMD_FAILED;
-		}
-	}
-
-	if (max_pv && max_pv < vg->pv_count) {
-		log_error("MaxPhysicalVolumes is less than the current number "
-			  "%d of PVs for \"%s\"", vg->pv_count,
-			  vg->name);
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg))
 		return ECMD_FAILED;
 
-	vg->max_pv = max_pv;
+	if (!vg_set_max_pv(vg, max_pv))
+		return ECMD_FAILED;
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		return ECMD_FAILED;


