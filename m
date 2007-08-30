From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Aug 2007 20:30:42 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20070830203042.24556.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-30 20:30:41

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h pv_manip.c 
	tools          : pvresize.c 

Log message:
	move guts of pvresize into library

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.700&r2=1.701
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2007/08/30 19:34:18	1.700
+++ LVM2/WHATS_NEW	2007/08/30 20:30:41	1.701
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Move guts of pvresize into library.
   Avoid error when --corelog is provided without --mirrorlog. (2.02.28)
   Correct --mirrorlog argument name in man pages (not --log).
   Clear MIRROR_NOTSYNCED LV flag when converting from mirror to linear.
--- LVM2/lib/metadata/metadata-exported.h	2007/08/22 14:38:17	1.13
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/30 20:30:41	1.14
@@ -322,6 +322,10 @@
 		      uint64_t pvmetadatasize, struct list *mdas);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
              uint32_t new_pe_count);
+int pv_resize_single(struct cmd_context *cmd,
+		     struct volume_group *vg,
+		     struct physical_volume *pv,
+		     uint64_t new_size);
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 	       uint64_t label_sector);
 
--- LVM2/lib/metadata/pv_manip.c	2007/08/20 20:55:26	1.11
+++ LVM2/lib/metadata/pv_manip.c	2007/08/30 20:30:41	1.12
@@ -17,6 +17,9 @@
 #include "metadata.h"
 #include "pv_alloc.h"
 #include "toolcontext.h"
+#include "archiver.h"
+#include "locking.h"
+#include "lvmcache.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,
@@ -396,3 +399,158 @@
 	else
 		return _reduce_pv(pv, vg, new_pe_count);
 }
+
+int pv_resize_single(struct cmd_context *cmd,
+		     struct volume_group *vg,
+		     struct physical_volume *pv,
+		     uint64_t new_size)
+{
+	struct pv_list *pvl;
+	int consistent = 1;
+	uint64_t size = 0;
+	uint32_t new_pe_count = 0;
+	struct list mdas;
+	const char *pv_name = dev_name(pv_dev(pv));
+	const char *vg_name;
+
+	list_init(&mdas);
+
+	if (!*pv_vg_name(pv)) {
+		vg_name = ORPHAN;
+
+		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
+			log_error("Can't get lock for orphans");
+			return 0;
+		}
+
+		if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1))) {
+			unlock_vg(cmd, vg_name);
+			log_error("Unable to read PV \"%s\"", pv_name);
+			return 0;
+		}
+
+		/* FIXME Create function to test compatibility properly */
+		if (list_size(&mdas) > 1) {
+			log_error("%s: too many metadata areas for pvresize",
+				  pv_name);
+			unlock_vg(cmd, vg_name);
+			return 0;
+		}
+	} else {
+		vg_name = pv_vg_name(pv);
+
+		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
+			log_error("Can't get lock for %s", pv_vg_name(pv));
+			return 0;
+		}
+
+		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
+			unlock_vg(cmd, vg_name);
+			log_error("Unable to find volume group of \"%s\"",
+				  pv_name);
+			return 0;
+		}
+
+		if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
+			unlock_vg(cmd, vg_name);
+			return 0;
+		}
+
+		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
+			unlock_vg(cmd, vg_name);
+			log_error("Unable to find \"%s\" in volume group \"%s\"",
+				  pv_name, vg->name);
+			return 0;
+		}
+
+		pv = pvl->pv;
+
+		if (!archive(vg))
+			return 0;
+	}
+
+	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
+		log_error("Physical volume %s format does not support resizing.",
+			  pv_name);
+		unlock_vg(cmd, vg_name);
+		return 0;
+	}
+
+	/* Get new size */
+	if (!dev_get_size(pv_dev(pv), &size)) {
+		log_error("%s: Couldn't get size.", pv_name);
+		unlock_vg(cmd, vg_name);
+		return 0;
+	}
+	
+	if (new_size) {
+		if (new_size > size)
+			log_warn("WARNING: %s: Overriding real size. "
+				  "You could lose data.", pv_name);
+		log_verbose("%s: Pretending size is %" PRIu64 " not %" PRIu64
+			    " sectors.", pv_name, new_size, pv_size(pv));
+		size = new_size;
+	}
+
+	if (size < PV_MIN_SIZE) {
+		log_error("%s: Size must exceed minimum of %ld sectors.",
+			  pv_name, PV_MIN_SIZE);
+		unlock_vg(cmd, vg_name);
+		return 0;
+	}
+
+	if (size < pv_pe_start(pv)) {
+		log_error("%s: Size must exceed physical extent start of "
+			  "%" PRIu64 " sectors.", pv_name, pv_pe_start(pv));
+		unlock_vg(cmd, vg_name);
+		return 0;
+	}
+
+	pv->size = size;
+
+	if (vg) {
+		pv->size -= pv_pe_start(pv);
+		new_pe_count = pv_size(pv) / vg->extent_size;
+		
+ 		if (!new_pe_count) {
+			log_error("%s: Size must leave space for at "
+				  "least one physical extent of "
+				  "%" PRIu32 " sectors.", pv_name,
+				  pv_pe_size(pv));
+			unlock_vg(cmd, vg_name);
+			return 0;
+		}
+
+		if (!pv_resize(pv, vg, new_pe_count)) {
+			stack;
+			unlock_vg(cmd, vg_name);
+			return 0;
+		}
+	}
+
+	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
+		    pv_name, pv_size(pv));
+
+	log_verbose("Updating physical volume \"%s\"", pv_name);
+	if (*pv_vg_name(pv)) {
+		if (!vg_write(vg) || !vg_commit(vg)) {
+			unlock_vg(cmd, pv_vg_name(pv));
+			log_error("Failed to store physical volume \"%s\" in "
+				  "volume group \"%s\"", pv_name, vg->name);
+			return 0;
+		}
+		backup(vg);
+		unlock_vg(cmd, vg_name);
+	} else {
+		if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
+			unlock_vg(cmd, ORPHAN);
+			log_error("Failed to store physical volume \"%s\"",
+				  pv_name);
+			return 0;
+		}
+		unlock_vg(cmd, vg_name);
+	}
+
+	log_print("Physical volume \"%s\" changed", pv_name);
+	return 1;
+}
--- LVM2/tools/pvresize.c	2007/08/30 20:16:01	1.14
+++ LVM2/tools/pvresize.c	2007/08/30 20:30:41	1.15
@@ -23,162 +23,6 @@
 	unsigned total;
 };
 
-static int pv_resize_single(struct cmd_context *cmd,
-			    struct volume_group *vg,
-			    struct physical_volume *pv,
-			    uint64_t new_size)
-{
-	struct pv_list *pvl;
-	int consistent = 1;
-	uint64_t size = 0;
-	uint32_t new_pe_count = 0;
-	struct list mdas;
-	const char *pv_name = dev_name(pv_dev(pv));
-	const char *vg_name;
-
-	list_init(&mdas);
-
-	if (!*pv_vg_name(pv)) {
-		vg_name = ORPHAN;
-
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphans");
-			return 0;
-		}
-
-		if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Unable to read PV \"%s\"", pv_name);
-			return 0;
-		}
-
-		/* FIXME Create function to test compatibility properly */
-		if (list_size(&mdas) > 1) {
-			log_error("%s: too many metadata areas for pvresize",
-				  pv_name);
-			unlock_vg(cmd, vg_name);
-			return 0;
-		}
-	} else {
-		vg_name = pv_vg_name(pv);
-
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for %s", pv_vg_name(pv));
-			return 0;
-		}
-
-		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Unable to find volume group of \"%s\"",
-				  pv_name);
-			return 0;
-		}
-
-		if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
-			unlock_vg(cmd, vg_name);
-			return 0;
-		}
-
-		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Unable to find \"%s\" in volume group \"%s\"",
-				  pv_name, vg->name);
-			return 0;
-		}
-
-		pv = pvl->pv;
-
-		if (!archive(vg))
-			return 0;
-	}
-
-	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
-		log_error("Physical volume %s format does not support resizing.",
-			  pv_name);
-		unlock_vg(cmd, vg_name);
-		return 0;
-	}
-
-	/* Get new size */
-	if (!dev_get_size(pv_dev(pv), &size)) {
-		log_error("%s: Couldn't get size.", pv_name);
-		unlock_vg(cmd, vg_name);
-		return 0;
-	}
-	
-	if (new_size) {
-		if (new_size > size)
-			log_warn("WARNING: %s: Overriding real size. "
-				  "You could lose data.", pv_name);
-		log_verbose("%s: Pretending size is %" PRIu64 " not %" PRIu64
-			    " sectors.", pv_name, new_size, pv_size(pv));
-		size = new_size;
-	}
-
-	if (size < PV_MIN_SIZE) {
-		log_error("%s: Size must exceed minimum of %ld sectors.",
-			  pv_name, PV_MIN_SIZE);
-		unlock_vg(cmd, vg_name);
-		return 0;
-	}
-
-	if (size < pv_pe_start(pv)) {
-		log_error("%s: Size must exceed physical extent start of "
-			  "%" PRIu64 " sectors.", pv_name, pv_pe_start(pv));
-		unlock_vg(cmd, vg_name);
-		return 0;
-	}
-
-	pv->size = size;
-
-	if (vg) {
-		pv->size -= pv_pe_start(pv);
-		new_pe_count = pv_size(pv) / vg->extent_size;
-		
- 		if (!new_pe_count) {
-			log_error("%s: Size must leave space for at "
-				  "least one physical extent of "
-				  "%" PRIu32 " sectors.", pv_name,
-				  pv_pe_size(pv));
-			unlock_vg(cmd, vg_name);
-			return 0;
-		}
-
-		if (!pv_resize(pv, vg, new_pe_count)) {
-			stack;
-			unlock_vg(cmd, vg_name);
-			return 0;
-		}
-	}
-
-	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
-		    pv_name, pv_size(pv));
-
-	log_verbose("Updating physical volume \"%s\"", pv_name);
-	if (*pv_vg_name(pv)) {
-		if (!vg_write(vg) || !vg_commit(vg)) {
-			unlock_vg(cmd, pv_vg_name(pv));
-			log_error("Failed to store physical volume \"%s\" in "
-				  "volume group \"%s\"", pv_name, vg->name);
-			return 0;
-		}
-		backup(vg);
-		unlock_vg(cmd, vg_name);
-	} else {
-		if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
-			unlock_vg(cmd, ORPHAN);
-			log_error("Failed to store physical volume \"%s\"",
-				  pv_name);
-			return 0;
-		}
-		unlock_vg(cmd, vg_name);
-	}
-
-	log_print("Physical volume \"%s\" changed", pv_name);
-	return 1;
-}
-
-
 static int _pvresize_single(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct physical_volume *pv,


