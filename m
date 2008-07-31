From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2008 10:50:19 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20080731105019.32561.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-31 10:50:19

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Refactor _text_pv_read and always return mda list if requested.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.936&r2=1.937
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/WHATS_NEW	2008/07/24 15:39:47	1.936
+++ LVM2/WHATS_NEW	2008/07/31 10:50:12	1.937
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Refactor _text_pv_read and always return mda list if requested.
   Fix configure to work w/o readline unless --enable-readline used. (2.02.39)
   Remove is_lvm_partition template which has not yet been coded.
   Refactor pvcreate to separate parameter parsing from validation logic.
--- LVM2/lib/format_text/format-text.c	2008/07/16 21:32:38	1.91
+++ LVM2/lib/format_text/format-text.c	2008/07/31 10:50:18	1.92
@@ -1396,43 +1396,33 @@
 	return 1;
 }
 
-static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, struct list *mdas)
+static int _get_pv_if_in_vg(struct lvmcache_info *info,
+			    struct physical_volume *pv)
 {
-	struct label *label;
-	struct device *dev;
-	struct lvmcache_info *info;
-	struct metadata_area *mda, *mda_new;
-	struct mda_context *mdac, *mdac_new;
-	struct data_area_list *da;
+	if (info->vginfo && info->vginfo->vgname &&
+	    !is_orphan_vg(info->vginfo->vgname) &&
+	    get_pv_from_vg_by_id(info->fmt, info->vginfo->vgname,
+				 info->vginfo->vgid, info->dev->pvid, pv))
+		return 1;
 
-	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
-		return_0;
+	return 0;
+}
 
-	/* FIXME Optimise out repeated reading when cache lock held */
-	if (!(label_read(dev, &label, UINT64_C(0))))
-		return_0;
-	info = (struct lvmcache_info *) label->info;
+static int _populate_pv_fields(struct lvmcache_info *info,
+			       struct physical_volume *pv)
+{
+	struct data_area_list *da;
 
 	/* Have we already cached vgname? */
-	if (info->vginfo && info->vginfo->vgname &&
-	    !is_orphan_vg(info->vginfo->vgname) &&
-	    get_pv_from_vg_by_id(info->fmt, info->vginfo->vgname,
-				 info->vginfo->vgid, info->dev->pvid, pv)) {
+	if (_get_pv_if_in_vg(info, pv))
 		return 1;
-	}
 
 	/* Perform full scan (just the first time) and try again */
 	if (!memlock() && !full_scan_done()) {
-		lvmcache_label_scan(fmt->cmd, 2);
+		lvmcache_label_scan(info->fmt->cmd, 2);
 
-		if (info->vginfo && info->vginfo->vgname &&
-		    !is_orphan_vg(info->vginfo->vgname) &&
-		    get_pv_from_vg_by_id(info->fmt, info->vginfo->vgname,
-					 info->vginfo->vgid,
-					 info->dev->pvid, pv)) {
+		if (_get_pv_if_in_vg(info, pv))
 			return 1;
-		}
 	}
 
 	/* Orphan */
@@ -1445,13 +1435,35 @@
 	/* Currently only support exactly one data area */
 	if (list_size(&info->das) != 1) {
 		log_error("Must be exactly one data area (found %d) on PV %s",
-			  list_size(&info->das), dev_name(dev));
+			  list_size(&info->das), dev_name(info->dev));
 		return 0;
 	}
 
 	list_iterate_items(da, &info->das)
 		pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
 
+	return 1;
+}
+
+static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
+		    struct physical_volume *pv, struct list *mdas)
+{
+	struct label *label;
+	struct device *dev;
+	struct lvmcache_info *info;
+	struct metadata_area *mda, *mda_new;
+	struct mda_context *mdac, *mdac_new;
+
+	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
+		return_0;
+
+	if (!(label_read(dev, &label, UINT64_C(0))))
+		return_0;
+	info = (struct lvmcache_info *) label->info;
+
+	if (!_populate_pv_fields(info, pv))
+		return 0;
+
 	if (!mdas)
 		return 1;
 


