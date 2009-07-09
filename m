From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 10:06:01 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090709100601.11014.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 10:06:01

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgchange.c 

Log message:
	Add vg_set_max_lv() liblvm function and move vgchange logic inside.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.237&r2=1.238
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:04:52	1.83
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:06:00	1.84
@@ -435,6 +435,7 @@
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
 int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
+int vg_set_max_lv(vg_t *vg, uint32_t max_lv);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
--- LVM2/lib/metadata/metadata.c	2009/07/09 10:04:52	1.237
+++ LVM2/lib/metadata/metadata.c	2009/07/09 10:06:00	1.238
@@ -774,6 +774,34 @@
 	return 1;
 }
 
+int vg_set_max_lv(vg_t *vg, uint32_t max_lv)
+{
+	if (!(vg_status(vg) & RESIZEABLE_VG)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change MaxLogicalVolume", vg->name);
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!max_lv)
+			max_lv = 255;
+		else if (max_lv > 255) {
+			log_error("MaxLogicalVolume limit is 255");
+			return 0;
+		}
+	}
+
+	if (max_lv && max_lv < vg_visible_lvs(vg)) {
+		log_error("MaxLogicalVolume is less than the current number "
+			  "%d of LVs for %s", vg_visible_lvs(vg),
+			  vg->name);
+		return 0;
+	}
+	vg->max_lv = max_lv;
+
+	return 1;
+}
+
 /*
  * Separate metadata areas after splitting a VG.
  * Also accepts orphan VG as destination (for vgreduce).
--- LVM2/tools/vgchange.c	2009/07/09 10:04:52	1.77
+++ LVM2/tools/vgchange.c	2009/07/09 10:06:01	1.78
@@ -293,32 +293,11 @@
 {
 	uint32_t max_lv = arg_uint_value(cmd, logicalvolume_ARG, 0);
 
-	if (!(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" must be resizeable "
-			  "to change MaxLogicalVolume", vg->name);
-		return ECMD_FAILED;
-	}
-
-	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS)) {
-		if (!max_lv)
-			max_lv = 255;
-		else if (max_lv > 255) {
-			log_error("MaxLogicalVolume limit is 255");
-			return ECMD_FAILED;
-		}
-	}
-
-	if (max_lv && max_lv < vg_visible_lvs(vg)) {
-		log_error("MaxLogicalVolume is less than the current number "
-			  "%d of LVs for %s", vg_visible_lvs(vg),
-			  vg->name);
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg))
 		return ECMD_FAILED;
 
-	vg->max_lv = max_lv;
+	if (!vg_set_max_lv(vg, max_lv))
+		return ECMD_FAILED;
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		return ECMD_FAILED;


