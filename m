From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 10:02:16 -0000
Subject: LVM2 lib/metadata/metadata.c tools/vgchange.c
Message-ID: <20090709100216.16322.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 10:02:15

Modified files:
	lib/metadata   : metadata.c 
	tools          : vgchange.c 

Log message:
	Update vg_change_pesize() to contain all validity checks.
	
	It would be nice to have one function that does all the validation
	and setting of the VG's pesize.  However, currently some checks
	are in the higher-level function _vgchange_pesize(), and some
	checks are in the lower function vg_change_pesize().
	This patch moves most of the higher-level checks inside
	vg_change_pesize.  In one case a failure return code is
	changed from ECMD_FAILED to EINVALID_CMD_LINE.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.234&r2=1.235
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/lib/metadata/metadata.c	2009/07/08 14:33:17	1.234
+++ LVM2/lib/metadata/metadata.c	2009/07/09 10:02:15	1.235
@@ -636,6 +636,36 @@
 	struct pv_segment *pvseg;
 	uint32_t s;
 
+	if (!(vg_status(vg) & RESIZEABLE_VG)) {
+		log_error("Volume group \"%s\" must be resizeable "
+			  "to change PE size", vg->name);
+		return 0;
+	}
+
+	if (!new_size) {
+		log_error("Physical extent size may not be zero");
+		return 0;
+	}
+
+	if (new_size == vg->extent_size) {
+		log_error("Physical extent size of VG %s is already %s",
+			  vg->name, display_size(vg->cmd, (uint64_t) new_size));
+		return 1;
+	}
+
+	if (new_size & (new_size - 1)) {
+		log_error("Physical extent size must be a power of 2.");
+		return 0;
+	}
+
+	if (new_size > vg->extent_size) {
+		if ((uint64_t) vg->extent_size * vg->extent_count % new_size) {
+			/* FIXME Adjust used PV sizes instead */
+			log_error("New extent size is not a perfect fit");
+			return 0;
+		}
+	}
+
 	vg->extent_size = new_size;
 
 	if (vg->fid->fmt->ops->vg_setup &&
--- LVM2/tools/vgchange.c	2009/07/01 17:00:52	1.74
+++ LVM2/tools/vgchange.c	2009/07/09 10:02:15	1.75
@@ -381,48 +381,25 @@
 {
 	uint32_t extent_size;
 
-	if (!(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" must be resizeable "
-			  "to change PE size", vg->name);
-		return ECMD_FAILED;
-	}
-
 	if (arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
 		log_error("Physical extent size may not be negative");
 		return EINVALID_CMD_LINE;
 	}
 
 	extent_size = arg_uint_value(cmd, physicalextentsize_ARG, 0);
-	if (!extent_size) {
-		log_error("Physical extent size may not be zero");
-		return EINVALID_CMD_LINE;
-	}
-
+	/* FIXME: remove check - redundant with vg_change_pesize */
 	if (extent_size == vg->extent_size) {
 		log_error("Physical extent size of VG %s is already %s",
 			  vg->name, display_size(cmd, (uint64_t) extent_size));
 		return ECMD_PROCESSED;
 	}
 
-	if (extent_size & (extent_size - 1)) {
-		log_error("Physical extent size must be a power of 2.");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (extent_size > vg->extent_size) {
-		if ((uint64_t) vg->extent_size * vg->extent_count % extent_size) {
-			/* FIXME Adjust used PV sizes instead */
-			log_error("New extent size is not a perfect fit");
-			return EINVALID_CMD_LINE;
-		}
-	}
-
 	if (!archive(vg))
 		return ECMD_FAILED;
 
 	if (!vg_change_pesize(cmd, vg, extent_size)) {
 		stack;
-		return ECMD_FAILED;
+		return EINVALID_CMD_LINE;
 	}
 
 	if (!vg_write(vg) || !vg_commit(vg))


