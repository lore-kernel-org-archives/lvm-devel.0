From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Apr 2007 18:21:03 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/form ...
Message-ID: <20070423182103.704.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-04-23 19:21:01

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/format_text: format-text.c 
	lib/label      : label.c label.h 
	lib/metadata   : metadata.c 
	tools          : lvmdiskscan.c 

Log message:
	Add 'scan_sector' parameter to label_read and _find_labeller to add
	flexibility in searching for disk labels.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.598&r2=1.599
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmdiskscan.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW	2007/04/23 14:55:28	1.598
+++ LVM2/WHATS_NEW	2007/04/23 18:21:01	1.599
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add scan_sector param to label_read and _find_labeller.
   Make clvmd cope with quorum devices on RHEL5
   Add dev_read_circular.
   Add pvck command stub.
--- LVM2/lib/cache/lvmcache.c	2006/11/30 23:11:39	1.29
+++ LVM2/lib/cache/lvmcache.c	2007/04/23 18:21:01	1.30
@@ -135,7 +135,7 @@
 
 	list_iterate_safe(devh, tmp, &devs) {
 		devl = list_item(devh, struct device_list);
-		label_read(devl->dev, &label);
+		label_read(devl->dev, &label, UINT64_C(0));
 		list_del(&devl->list);
 		dm_free(devl);
 	}
@@ -205,7 +205,7 @@
 	struct label *label;
 
 	if (info->status & CACHE_INVALID)
-		label_read(info->dev, &label);
+		label_read(info->dev, &label, UINT64_C(0));
 }
 
 static int _scan_invalid(void)
@@ -247,7 +247,7 @@
 	}
 
 	while ((dev = dev_iter_get(iter)))
-		label_read(dev, &label);
+		label_read(dev, &label, UINT64_C(0));
 
 	dev_iter_destroy(iter);
 
@@ -346,7 +346,7 @@
 
 	/* Already cached ? */
 	if ((info = info_from_pvid((char *) pvid))) {
-		if (label_read(info->dev, &label)) {
+		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
 				return info->dev;
@@ -357,7 +357,7 @@
 
 	/* Try again */
 	if ((info = info_from_pvid((char *) pvid))) {
-		if (label_read(info->dev, &label)) {
+		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
 				return info->dev;
@@ -371,7 +371,7 @@
 
 	/* Try again */
 	if ((info = info_from_pvid((char *) pvid))) {
-		if (label_read(info->dev, &label)) {
+		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
 				return info->dev;
--- LVM2/lib/format_text/format-text.c	2007/03/23 12:43:17	1.73
+++ LVM2/lib/format_text/format-text.c	2007/04/23 18:21:01	1.74
@@ -1287,7 +1287,7 @@
 	}
 
 	/* FIXME Optimise out repeated reading when cache lock held */
-	if (!(label_read(dev, &label))) {
+	if (!(label_read(dev, &label, UINT64_C(0)))) {
 		stack;
 		return 0;
 	}
--- LVM2/lib/label/label.c	2006/11/30 23:11:41	1.36
+++ LVM2/lib/label/label.c	2007/04/23 18:21:01	1.37
@@ -107,7 +107,8 @@
 }
 
 static struct labeller *_find_labeller(struct device *dev, char *buf,
-				       uint64_t *label_sector)
+				       uint64_t *label_sector,
+				       uint64_t scan_sector)
 {
 	struct labeller_i *li;
 	struct labeller *r = NULL;
@@ -117,12 +118,13 @@
 	int found = 0;
 	char readbuf[LABEL_SCAN_SIZE] __attribute((aligned(8)));
 
-	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, readbuf)) {
+	if (!dev_read(dev, scan_sector << SECTOR_SHIFT,
+		      LABEL_SCAN_SIZE, readbuf)) {
 		log_debug("%s: Failed to read label area", dev_name(dev));
 		goto out;
 	}
 
-	/* Scan first few sectors for a valid label */
+	/* Scan a few sectors for a valid label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
 		lh = (struct label_header *) (readbuf +
@@ -132,13 +134,14 @@
 			if (found) {
 				log_error("Ignoring additional label on %s at "
 					  "sector %" PRIu64, dev_name(dev),
-					  sector);
+					  sector + scan_sector);
 			}
-			if (xlate64(lh->sector_xl) != sector) {
+			if (xlate64(lh->sector_xl) != sector + scan_sector) {
 				log_info("%s: Label for sector %" PRIu64
 					 " found at sector %" PRIu64
 					 " - ignoring", dev_name(dev),
-					 xlate64(lh->sector_xl), sector);
+					 xlate64(lh->sector_xl),
+					 sector + scan_sector);
 				continue;
 			}
 			if (calc_crc(INITIAL_CRC, &lh->offset_xl, LABEL_SIZE -
@@ -153,19 +156,21 @@
 		}
 
 		list_iterate_items(li, &_labellers) {
-			if (li->l->ops->can_handle(li->l, (char *) lh, sector)) {
+			if (li->l->ops->can_handle(li->l, (char *) lh,
+						   sector + scan_sector)) {
 				log_very_verbose("%s: %s label detected",
 						 dev_name(dev), li->name);
 				if (found) {
 					log_error("Ignoring additional label "
 						  "on %s at sector %" PRIu64,
-						  dev_name(dev), sector);
+						  dev_name(dev),
+						  sector + scan_sector);
 					continue;
 				}
 				r = li->l;
 				memcpy(buf, lh, LABEL_SIZE);
 				if (label_sector)
-					*label_sector = sector;
+					*label_sector = sector + scan_sector;
 				found = 1;
 				break;
 			}
@@ -256,7 +261,8 @@
 }
 
 /* FIXME Avoid repeated re-reading if cache lock held */
-int label_read(struct device *dev, struct label **result)
+int label_read(struct device *dev, struct label **result,
+		uint64_t scan_sector)
 {
 	char buf[LABEL_SIZE] __attribute((aligned(8)));
 	struct labeller *l;
@@ -274,7 +280,7 @@
 		return r;
 	}
 
-	if (!(l = _find_labeller(dev, buf, &sector)))
+	if (!(l = _find_labeller(dev, buf, &sector, scan_sector)))
 		goto_out;
 
 	if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result)
@@ -354,7 +360,7 @@
 		return_0;
 	}
 
-	if (!(l = _find_labeller(dev, buf, &sector)))
+	if (!(l = _find_labeller(dev, buf, &sector, UINT64_C(0))))
 		goto_out;
 
 	r = l->ops->verify ? l->ops->verify(l, buf, sector) : 1;
--- LVM2/lib/label/label.h	2006/11/30 23:11:41	1.18
+++ LVM2/lib/label/label.h	2007/04/23 18:21:01	1.19
@@ -96,7 +96,8 @@
 struct labeller *label_get_handler(const char *name);
 
 int label_remove(struct device *dev);
-int label_read(struct device *dev, struct label **result);
+int label_read(struct device *dev, struct label **result,
+		uint64_t scan_sector);
 int label_write(struct device *dev, struct label *label);
 int label_verify(struct device *dev);
 struct label *label_create(struct labeller *labeller);
--- LVM2/lib/metadata/metadata.c	2007/03/23 12:43:17	1.104
+++ LVM2/lib/metadata/metadata.c	2007/04/23 18:21:01	1.105
@@ -1403,7 +1403,7 @@
 		return NULL;
 	}
 
-	if (!(label_read(dev, &label))) {
+	if (!(label_read(dev, &label, UINT64_C(0)))) {
 		if (warnings)
 			log_error("No physical volume label read from %s",
 				  pv_name);
--- LVM2/tools/lvmdiskscan.c	2006/05/09 21:23:51	1.16
+++ LVM2/tools/lvmdiskscan.c	2007/04/23 18:21:01	1.17
@@ -112,7 +112,7 @@
 	/* Do scan */
 	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter)) {
 		/* Try if it is a PV first */
-		if ((label_read(dev, &label))) {
+		if ((label_read(dev, &label, UINT64_C(0)))) {
 			if (!dev_get_size(dev, &size)) {
 				log_error("Couldn't get size of \"%s\"",
 					  dev_name(dev));


