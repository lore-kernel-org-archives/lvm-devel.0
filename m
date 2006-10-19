From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Oct 2006 12:53:47 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/disk-rep.h lib/fo ...
Message-ID: <20061019125347.28026.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-19 12:53:47

Modified files:
	.              : WHATS_NEW 
	lib/format1    : disk-rep.h format1.c import-export.c 
	lib/format_text: import_vsn1.c 

Log message:
	Set PV size to current device size if it is found to be zero.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.474&r2=1.475
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.h.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2006/10/18 18:01:51	1.474
+++ LVM2/WHATS_NEW	2006/10/19 12:53:46	1.475
@@ -1,5 +1,6 @@
 Version 2.02.13 -
 ===================================
+  Set PV size to current device size if it is found to be zero.
   Add segment parameter to target_present functions.
 
 Version 2.02.12 - 16th October 2006
--- LVM2/lib/format1/disk-rep.h	2006/08/17 19:15:27	1.48
+++ LVM2/lib/format1/disk-rep.h	2006/10/19 12:53:46	1.49
@@ -203,8 +203,8 @@
  * Functions to translate to between disk and in
  * core structures.
  */
-int import_pv(struct dm_pool *mem, struct device *dev,
-	      struct volume_group *vg,
+int import_pv(const struct format_type *fmt, struct dm_pool *mem,
+	      struct device *dev, struct volume_group *vg,
 	      struct physical_volume *pv, struct pv_disk *pvd,
 	      struct vg_disk *vgd);
 int export_pv(struct cmd_context *cmd, struct dm_pool *mem,
--- LVM2/lib/format1/format1.c	2006/08/17 19:15:27	1.98
+++ LVM2/lib/format1/format1.c	2006/10/19 12:53:46	1.99
@@ -312,7 +312,7 @@
 		goto out;
 	}
 
-	if (!import_pv(fmt->cmd->mem, dl->dev, NULL, pv, &dl->pvd, &dl->vgd)) {
+	if (!import_pv(fmt, fmt->cmd->mem, dl->dev, NULL, pv, &dl->pvd, &dl->vgd)) {
 		stack;
 		goto out;
 	}
--- LVM2/lib/format1/import-export.c	2006/08/21 12:54:52	1.83
+++ LVM2/lib/format1/import-export.c	2006/10/19 12:53:46	1.84
@@ -24,6 +24,7 @@
 #include "toolcontext.h"
 #include "segtype.h"
 #include "pv_alloc.h"
+#include "display.h"
 
 #include <time.h>
 
@@ -47,11 +48,13 @@
 	return dm_pool_strdup(mem, ptr);
 }
 
-int import_pv(struct dm_pool *mem, struct device *dev,
-	      struct volume_group *vg,
+int import_pv(const struct format_type *fmt, struct dm_pool *mem,
+	      struct device *dev, struct volume_group *vg,
 	      struct physical_volume *pv, struct pv_disk *pvd,
 	      struct vg_disk *vgd)
 {
+	uint64_t size;
+
 	memset(pv, 0, sizeof(*pv));
 	memcpy(&pv->id, pvd->pv_uuid, ID_LEN);
 
@@ -89,6 +92,25 @@
 	pv->pe_count = pvd->pe_total;
 	pv->pe_alloc_count = 0;
 
+	/* Fix up pv size if missing */
+	if (!pv->size) {
+		if (!dev_get_size(dev, &pv->size)) {
+			log_error("%s: Couldn't get size.", dev_name(pv->dev));
+			return 0;
+		}
+		log_verbose("Fixing up missing format1 size (%s) "
+			    "for PV %s", display_size(fmt->cmd, pv->size),
+			    dev_name(pv->dev));
+		if (vg) {
+			size = pv->pe_count * (uint64_t) vg->extent_size +
+			       pv->pe_start;
+			if (size > pv->size)
+				log_error("WARNING: Physical Volume %s is too "
+					  "large for underlying device",
+					  dev_name(pv->dev));
+		}
+	}
+
 	list_init(&pv->tags);
 	list_init(&pv->segments);
 
@@ -427,7 +449,7 @@
 			return 0;
 		}
 
-		if (!import_pv(mem, dl->dev, vg, pvl->pv, &dl->pvd, &dl->vgd)) {
+		if (!import_pv(fmt, mem, dl->dev, vg, pvl->pv, &dl->pvd, &dl->vgd)) {
 			stack;
 			return 0;
 		}
--- LVM2/lib/format_text/import_vsn1.c	2006/10/07 23:17:17	1.36
+++ LVM2/lib/format_text/import_vsn1.c	2006/10/19 12:53:47	1.37
@@ -116,6 +116,7 @@
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	struct config_node *cn;
+	uint64_t size;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
 	    !(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv)))) {
@@ -213,6 +214,25 @@
 	pv->pe_alloc_count = 0;
 	pv->fmt = fid->fmt;
 
+        /* Fix up pv size if missing */
+        if (!pv->size && pv->dev) {
+                if (!dev_get_size(pv->dev, &pv->size)) {
+                        log_error("%s: Couldn't get size.", dev_name(pv->dev));
+                        return 0;
+                }
+                log_verbose("Fixing up missing format1 size (%s) "
+                            "for PV %s", display_size(fid->fmt->cmd, pv->size),
+                            dev_name(pv->dev));
+                if (vg) {
+                        size = pv->pe_count * (uint64_t) vg->extent_size +
+                               pv->pe_start;
+                        if (size > pv->size)
+                                log_error("WARNING: Physical Volume %s is too "
+                                          "large for underlying device",
+                                          dev_name(pv->dev));
+                }
+        }
+
 	if (!alloc_pv_segment_whole_pv(mem, pv)) {
 		stack;
 		return 0;


