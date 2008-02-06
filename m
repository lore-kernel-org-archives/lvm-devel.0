From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Feb 2008 15:47:30 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20080206154730.17825.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-02-06 15:47:28

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/display    : display.c 
	lib/format1    : disk-rep.c format1.c format1.h import-export.c 
	                 lvm1-label.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c format-text.h text_label.c 
	lib/label      : label.c 
	lib/metadata   : metadata-exported.h metadata.c 
	lib/report     : report.c 
	tools          : pvchange.c vgreduce.c 

Log message:
	split orphan VG by format type

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.789&r2=1.790
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/WHATS_NEW	2008/02/06 12:45:32	1.789
+++ LVM2/WHATS_NEW	2008/02/06 15:47:27	1.790
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Divide up internal orphan volume group by format type.
   Update usage message for clvmd.
   Fix clvmd man page printing <br>, clarified debug options.
   Fix lvresize to support /dev/mapper prefix in the lvname
--- LVM2/lib/cache/lvmcache.c	2008/01/30 16:18:37	1.37
+++ LVM2/lib/cache/lvmcache.c	2008/02/06 15:47:27	1.38
@@ -208,9 +208,6 @@
 	struct lvmcache_vginfo *vginfo;
 	const char *vgname = NULL;
 
-	if (!*vgid)
-		vgname = ORPHAN;
-
 	if ((vginfo = vginfo_from_vgid(vgid)))
 		vgname = vginfo->vgname;
 
@@ -530,8 +527,10 @@
 		return 0;
 	}
 
-	log_debug("lvmcache: %s: setting %s VGID to %s", dev_name(info->dev),
-		  info->vginfo->vgname, info->vginfo->vgid);
+	if (!is_orphan_vg(info->vginfo->vgname))
+		log_debug("lvmcache: %s: setting %s VGID to %s",
+			  dev_name(info->dev), info->vginfo->vgname,
+			  info->vginfo->vgid);
 
 	return 1;
 }
@@ -627,15 +626,6 @@
 	struct lvmcache_vginfo *vginfo, *primary_vginfo;
 	// struct lvmcache_vginfo  *old_vginfo, *next;
 
-	/* If vgname is NULL and we don't already have a vgname,
-	 * assume ORPHAN - we want every entry to have a vginfo
-	 * attached for scanning reasons.
-	 */
-	if (!vgname && !info->vginfo) {
-		vgname = ORPHAN;
-		vgid = ORPHAN;
-	}
-
 	if (!vgname || (info->vginfo && !strcmp(info->vginfo->vgname, vgname)))
 		return 1;
 
@@ -716,9 +706,8 @@
 	/* FIXME Check consistency of list! */
 	vginfo->fmt = info->fmt;
 
-	log_debug("lvmcache: %s: now %s%s%s%s%s", dev_name(info->dev),
-		  !is_orphan_vg(vgname) ? "in VG " : "orphaned", vgname,
-		  vginfo->vgid[0] ? " (" : "",
+	log_debug("lvmcache: %s: now in VG %s%s%s%s", dev_name(info->dev),
+		  vgname, vginfo->vgid[0] ? " (" : "",
 		  vginfo->vgid[0] ? vginfo->vgid : "",
 		  vginfo->vgid[0] ? ")" : "");
 
@@ -764,6 +753,12 @@
 				  const char *vgname, const char *vgid,
 				  uint32_t vgstatus, const char *creation_host)
 {
+	if (!vgname && !info->vginfo) {
+		log_error("Internal error: NULL vgname handed to cache");
+		/* FIXME Remove this */
+		vgname = info->fmt->orphan_vg_name;
+		vgid = vgname;
+	}
 	if (!_lvmcache_update_vgname(info, vgname, vgid, vgstatus,
 				     creation_host) ||
 	    !_lvmcache_update_vgid(info, vgid) ||
--- LVM2/lib/cache/lvmcache.h	2008/01/29 23:45:47	1.16
+++ LVM2/lib/cache/lvmcache.h	2008/02/06 15:47:27	1.17
@@ -20,7 +20,8 @@
 #include "uuid.h"
 #include "label.h"
 
-#define ORPHAN ""
+#define ORPHAN_PREFIX "#"
+#define ORPHAN_VG_NAME(fmt) ORPHAN_PREFIX "orphans_" fmt
 
 #define CACHE_INVALID	0x00000001
 #define CACHE_LOCKED	0x00000002
--- LVM2/lib/display/display.c	2008/01/30 13:59:58	1.85
+++ LVM2/lib/display/display.c	2008/02/06 15:47:27	1.86
@@ -307,7 +307,8 @@
 
 	log_print("--- %sPhysical volume ---", pv->pe_size ? "" : "NEW ");
 	log_print("PV Name               %s", pv_dev_name(pv));
-	log_print("VG Name               %s%s", pv->vg_name,
+	log_print("VG Name               %s%s",
+		  is_orphan(pv) ? "" : pv->vg_name,
 		  pv->status & EXPORTED_VG ? " (exported)" : "");
 
 	data_size = (uint64_t) pv->pe_count * pv->pe_size;
--- LVM2/lib/format1/disk-rep.c	2008/01/30 13:59:59	1.72
+++ LVM2/lib/format1/disk-rep.c	2008/02/06 15:47:27	1.73
@@ -326,10 +326,11 @@
 			      unsigned exported)
 {
 	struct lvmcache_info *info;
+	const char *vgname = *((char *)dl->pvd.vg_name) ?
+			     (char *)dl->pvd.vg_name : fmt->orphan_vg_name;
 
 	if (!(info = lvmcache_add(fmt->labeller, (char *)dl->pvd.pv_uuid, dev,
-				  (char *)dl->pvd.vg_name, vgid,
-				  exported ? EXPORTED_VG : 0))) {
+				  vgname, vgid, exported ? EXPORTED_VG : 0))) {
 		stack;
 		return;
 	}
@@ -363,20 +364,20 @@
 	if (!*dl->pvd.vg_name) {
 		log_very_verbose("%s is not a member of any format1 VG", name);
 
-		__update_lvmcache(fmt, dl, dev, NULL, 0);
+		__update_lvmcache(fmt, dl, dev, fmt->orphan_vg_name, 0);
 		return (vg_name) ? NULL : dl;
 	}
 
 	if (!read_vgd(dl->dev, &dl->vgd, &dl->pvd)) {
 		log_error("Failed to read VG data from PV (%s)", name);
-		__update_lvmcache(fmt, dl, dev, NULL, 0);
+		__update_lvmcache(fmt, dl, dev, fmt->orphan_vg_name, 0);
 		goto bad;
 	}
 
 	if (vg_name && strcmp(vg_name, (char *)dl->pvd.vg_name)) {
 		log_very_verbose("%s is not a member of the VG %s",
 				 name, vg_name);
-		__update_lvmcache(fmt, dl, dev, NULL, 0);
+		__update_lvmcache(fmt, dl, dev, fmt->orphan_vg_name, 0);
 		goto bad;
 	}
 
--- LVM2/lib/format1/format1.c	2008/01/30 13:59:59	1.105
+++ LVM2/lib/format1/format1.c	2008/02/06 15:47:27	1.106
@@ -18,13 +18,10 @@
 #include "limits.h"
 #include "display.h"
 #include "toolcontext.h"
-#include "lvmcache.h"
 #include "lvm1-label.h"
 #include "format1.h"
 #include "segtype.h"
 
-#define FMT_LVM1_NAME "lvm1"
-
 /* VG consistency checks */
 static int _check_vgs(struct list *pvs, int *partial)
 {
@@ -523,6 +520,7 @@
 	fmt->ops = &_format1_ops;
 	fmt->name = FMT_LVM1_NAME;
 	fmt->alias = NULL;
+	fmt->orphan_vg_name = FMT_LVM1_ORPHAN_VG_NAME;
 	fmt->features = FMT_RESTRICTED_LVIDS | FMT_ORPHAN_ALLOCATABLE |
 			FMT_RESTRICTED_READAHEAD;
 	fmt->private = NULL;
--- LVM2/lib/format1/format1.h	2007/08/20 20:55:25	1.12
+++ LVM2/lib/format1/format1.h	2008/02/06 15:47:27	1.13
@@ -17,6 +17,10 @@
 #define _LVM_FORMAT1_H
 
 #include "metadata.h"
+#include "lvmcache.h"
+
+#define FMT_LVM1_NAME "lvm1"
+#define FMT_LVM1_ORPHAN_VG_NAME ORPHAN_VG_NAME(FMT_LVM1_NAME)
 
 #ifdef LVM1_INTERNAL
 struct format_type *init_lvm1_format(struct cmd_context *cmd);
--- LVM2/lib/format1/import-export.c	2008/01/30 13:59:59	1.94
+++ LVM2/lib/format1/import-export.c	2008/02/06 15:47:27	1.95
@@ -26,6 +26,7 @@
 #include "pv_alloc.h"
 #include "display.h"
 #include "lvmcache.h"
+#include "metadata.h"
 
 #include <time.h>
 
@@ -61,7 +62,7 @@
 
 	pv->dev = dev;
 	if (!*pvd->vg_name)
-		pv->vg_name = ORPHAN;
+		pv->vg_name = fmt->orphan_vg_name;
 	else if (!(pv->vg_name = dm_pool_strdup(mem, (char *)pvd->vg_name))) {
 		log_error("Volume Group name allocation failed.");
 		return 0;
@@ -147,7 +148,7 @@
 
 	memcpy(pvd->pv_uuid, pv->id.uuid, ID_LEN);
 
-	if (pv->vg_name) {
+	if (pv->vg_name && !is_orphan(pv)) {
 		if (!_check_vg_name(pv->vg_name))
 			return_0;
 		strncpy((char *)pvd->vg_name, pv->vg_name, sizeof(pvd->vg_name));
--- LVM2/lib/format1/lvm1-label.c	2008/01/30 13:59:59	1.18
+++ LVM2/lib/format1/lvm1-label.c	2008/02/06 15:47:27	1.19
@@ -19,7 +19,7 @@
 #include "label.h"
 #include "metadata.h"
 #include "xlate.h"
-#include "lvmcache.h"
+#include "format1.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -60,17 +60,21 @@
 	struct pv_disk *pvd = (struct pv_disk *) buf;
 	struct vg_disk vgd;
 	struct lvmcache_info *info;
-	const char *vgid = NULL;
+	const char *vgid = FMT_LVM1_ORPHAN_VG_NAME;
+	const char *vgname = FMT_LVM1_ORPHAN_VG_NAME;
 	unsigned exported = 0;
 
 	munge_pvd(dev, pvd);
 
-	if (*pvd->vg_name && read_vgd(dev, &vgd, pvd)) {
+	if (*pvd->vg_name) {
+		if (!read_vgd(dev, &vgd, pvd))
+			return_0;
 		vgid = (char *) vgd.vg_uuid;
+		vgname = (char *) pvd->vg_name;
 		exported = pvd->pv_status & VG_EXPORTED;
 	}
 
-	if (!(info = lvmcache_add(l, (char *)pvd->pv_uuid, dev, (char *)pvd->vg_name, vgid,
+	if (!(info = lvmcache_add(l, (char *)pvd->pv_uuid, dev, vgname, vgid,
 				  exported)))
 		return_0;
 	*label = info->label;
--- LVM2/lib/format_pool/format_pool.c	2008/01/30 13:59:59	1.13
+++ LVM2/lib/format_pool/format_pool.c	2008/02/06 15:47:27	1.14
@@ -316,6 +316,7 @@
 	fmt->ops = &_format_pool_ops;
 	fmt->name = FMT_POOL_NAME;
 	fmt->alias = NULL;
+	fmt->orphan_vg_name = ORPHAN_VG_NAME(FMT_POOL_NAME);
 	fmt->features = 0;
 	fmt->private = NULL;
 
--- LVM2/lib/format_text/format-text.c	2008/01/30 13:59:59	1.88
+++ LVM2/lib/format_text/format-text.c	2008/02/06 15:47:27	1.89
@@ -36,9 +36,6 @@
 #include <dirent.h>
 #include <ctype.h>
 
-#define FMT_TEXT_NAME "lvm2"
-#define FMT_TEXT_ALIAS "text"
-
 static struct mda_header *_raw_read_mda_header(const struct format_type *fmt,
 					       struct device_area *dev_area);
 
@@ -387,7 +384,8 @@
 
       bad:
 	if ((info = info_from_pvid(dev_area->dev->pvid, 0)))
-		lvmcache_update_vgname_and_id(info, ORPHAN, ORPHAN, 0, NULL);
+		lvmcache_update_vgname_and_id(info, FMT_TEXT_ORPHAN_VG_NAME,
+					      FMT_TEXT_ORPHAN_VG_NAME, 0, NULL);
 
 	return NULL;
 }
@@ -1293,7 +1291,7 @@
 	/* FIXME Test mode don't update cache? */
 
 	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
-				  ORPHAN, NULL, 0)))
+				  FMT_TEXT_ORPHAN_VG_NAME, NULL, 0)))
 		return_0;
 	label = info->label;
 
@@ -1438,7 +1436,7 @@
 	pv->dev = info->dev;
 	pv->fmt = info->fmt;
 	pv->size = info->device_size >> SECTOR_SHIFT;
-	pv->vg_name = ORPHAN;
+	pv->vg_name = FMT_TEXT_ORPHAN_VG_NAME;
 	memcpy(&pv->id, &info->dev->pvid, sizeof(pv->id));
 
 	/* Currently only support exactly one data area */
@@ -1887,6 +1885,7 @@
 	fmt->ops = &_text_handler;
 	fmt->name = FMT_TEXT_NAME;
 	fmt->alias = FMT_TEXT_ALIAS;
+	fmt->orphan_vg_name = ORPHAN_VG_NAME(FMT_TEXT_NAME);
 	fmt->features = FMT_SEGMENTS | FMT_MDAS | FMT_TAGS | FMT_PRECOMMIT |
 			FMT_UNLIMITED_VOLS | FMT_RESIZE_PV |
 			FMT_UNLIMITED_STRIPESIZE;
--- LVM2/lib/format_text/format-text.h	2007/11/05 17:17:55	1.23
+++ LVM2/lib/format_text/format-text.h	2008/02/06 15:47:27	1.24
@@ -19,6 +19,10 @@
 #include "lvm-types.h"
 #include "metadata.h"
 
+#define FMT_TEXT_NAME "lvm2"
+#define FMT_TEXT_ALIAS "text"
+#define FMT_TEXT_ORPHAN_VG_NAME ORPHAN_VG_NAME(FMT_TEXT_NAME)
+
 /*
  * Archives a vg config.  'retain_days' is the minimum number of
  * days that an archive file must be held for.  'min_archives' is
--- LVM2/lib/format_text/text_label.c	2008/01/30 13:59:59	1.20
+++ LVM2/lib/format_text/text_label.c	2008/02/06 15:47:27	1.21
@@ -207,7 +207,9 @@
 
 	pvhdr = (struct pv_header *) ((void *) buf + xlate32(lh->offset_xl));
 
-	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev, NULL, NULL, 0)))
+	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev,
+				  FMT_TEXT_ORPHAN_VG_NAME,
+				  FMT_TEXT_ORPHAN_VG_NAME, 0)))
 		return_0;
 	*label = info->label;
 
--- LVM2/lib/label/label.c	2008/01/31 12:35:31	1.41
+++ LVM2/lib/label/label.c	2008/02/06 15:47:28	1.42
@@ -178,7 +178,8 @@
       out:
 	if (!found) {
 		if ((info = info_from_pvid(dev->pvid, 0)))
-			lvmcache_update_vgname_and_id(info, ORPHAN, ORPHAN,
+			lvmcache_update_vgname_and_id(info, info->fmt->orphan_vg_name,
+						      info->fmt->orphan_vg_name,
 						      0, NULL);
 		log_very_verbose("%s: No label detected", dev_name(dev));
 	}
@@ -275,7 +276,8 @@
 		stack;
 
 		if ((info = info_from_pvid(dev->pvid, 0)))
-			lvmcache_update_vgname_and_id(info, ORPHAN, ORPHAN,
+			lvmcache_update_vgname_and_id(info, info->fmt->orphan_vg_name,
+						      info->fmt->orphan_vg_name,
 						      0, NULL);
 
 		return r;
@@ -351,7 +353,8 @@
 
 	if (!dev_open(dev)) {
 		if ((info = info_from_pvid(dev->pvid, 0)))
-			lvmcache_update_vgname_and_id(info, ORPHAN, ORPHAN,
+			lvmcache_update_vgname_and_id(info, info->fmt->orphan_vg_name,
+						      info->fmt->orphan_vg_name,
 						      0, NULL);
 
 		return_0;
--- LVM2/lib/metadata/metadata-exported.h	2008/01/26 00:25:04	1.42
+++ LVM2/lib/metadata/metadata-exported.h	2008/02/06 15:47:28	1.43
@@ -133,6 +133,7 @@
 	struct labeller *labeller;
 	const char *name;
 	const char *alias;
+	const char *orphan_vg_name;
 	uint32_t features;
 	void *library;
 	void *private;
--- LVM2/lib/metadata/metadata.c	2008/01/30 14:00:00	1.156
+++ LVM2/lib/metadata/metadata.c	2008/02/06 15:47:28	1.157
@@ -356,7 +356,7 @@
 		pv = pvl->pv;
 		log_verbose("Removing physical volume \"%s\" from "
 			    "volume group \"%s\"", pv_dev_name(pv), vg_name);
-		pv->vg_name = ORPHAN;
+		pv->vg_name = vg->fid->fmt->orphan_vg_name;
 		pv->status = ALLOCATABLE_PV;
 
 		if (!dev_get_size(pv_dev(pv), &pv->size)) {
@@ -833,6 +833,7 @@
 	}
 
 	pv->fmt = fmt;
+	pv->vg_name = fmt->orphan_vg_name;
 
 	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
 				existing_extent_size,
@@ -1324,7 +1325,8 @@
 }
 
 /* Make orphan PVs look like a VG */
-static struct volume_group *_vg_read_orphans(struct cmd_context *cmd)
+static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
+					     const char *orphan_vgname)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
@@ -1332,7 +1334,7 @@
 	struct volume_group *vg;
 	struct physical_volume *pv;
 
-	if (!(vginfo = vginfo_from_vgname(ORPHAN, NULL)))
+	if (!(vginfo = vginfo_from_vgname(orphan_vgname, NULL)))
 		return_NULL;
 
 	if (!(vg = dm_pool_zalloc(cmd->mem, sizeof(*vg)))) {
@@ -1343,7 +1345,7 @@
 	list_init(&vg->lvs);
 	list_init(&vg->tags);
 	vg->cmd = cmd;
-	if (!(vg->name = dm_pool_strdup(cmd->mem, ORPHAN))) {
+	if (!(vg->name = dm_pool_strdup(cmd->mem, orphan_vgname))) {
 		log_error("vg name allocation failed");
 		return NULL;
 	}
@@ -1421,7 +1423,7 @@
 			return NULL;
 		}
 		*consistent = 1;
-		return _vg_read_orphans(cmd);
+		return _vg_read_orphans(cmd, vgname);
 	}
 
 	/* Find the vgname in the cache */
@@ -1942,7 +1944,7 @@
 {
 	const char *old_vg_name = pv->vg_name;
 
-	pv->vg_name = ORPHAN;
+	pv->vg_name = cmd->fmt->orphan_vg_name;
 	pv->status = ALLOCATABLE_PV;
 
 	if (!dev_get_size(pv->dev, &pv->size)) {
@@ -1966,7 +1968,7 @@
  */
 int is_orphan_vg(const char *vg_name)
 {
-	return (!strcmp(vg_name, ORPHAN) ? 1 : 0);
+	return (vg_name && vg_name[0] == ORPHAN_PREFIX[0]) ? 1 : 0;
 }
 
 /**
--- LVM2/lib/report/report.c	2008/01/31 12:19:36	1.76
+++ LVM2/lib/report/report.c	2008/02/06 15:47:28	1.77
@@ -1004,7 +1004,7 @@
 
 /* necessary for displaying something for PVs not belonging to VG */
 static struct volume_group _dummy_vg = {
-	.name = (char *) ORPHAN,
+	.name = (char *) "",
 };
 
 static void *_obj_get_vg(void *obj)
--- LVM2/tools/pvchange.c	2008/01/30 14:00:02	1.58
+++ LVM2/tools/pvchange.c	2008/02/06 15:47:28	1.59
@@ -171,7 +171,7 @@
 		if (!is_orphan(pv)) {
 			orig_vg_name = pv_vg_name(pv);
 			orig_pe_alloc_count = pv_pe_alloc_count(pv);
-			pv->vg_name = ORPHAN;
+			pv->vg_name = pv->fmt->orphan_vg_name;
 			pv->pe_alloc_count = 0;
 			if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
 				log_error("pv_write with new uuid failed "
--- LVM2/tools/vgreduce.c	2008/01/30 14:17:29	1.78
+++ LVM2/tools/vgreduce.c	2008/02/06 15:47:28	1.79
@@ -376,7 +376,7 @@
 	if (pvl)
 		list_del(&pvl->list);
 
-	pv->vg_name = ORPHAN;
+	pv->vg_name = vg->fid->fmt->orphan_vg_name;
 	pv->status = ALLOCATABLE_PV;
 
 	if (!dev_get_size(pv_dev(pv), &pv->size)) {


