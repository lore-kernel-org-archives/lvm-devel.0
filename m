From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 20 Apr 2007 13:42:23 -0400
Subject: [PATCH 1/2] Add pvck ability to scan for labels on any area of disk
Message-ID: <1177090943.11574.9.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add 'start_sector' parameter to label_read and _find_labeller to add
flexibility in searching for disk labels.
Should not change functional behavior.

Index: LVM2/lib/cache/lvmcache.c
===================================================================
--- LVM2.orig/lib/cache/lvmcache.c	2007-04-20 11:26:52.000000000 -0400
+++ LVM2/lib/cache/lvmcache.c	2007-04-20 13:20:28.000000000 -0400
@@ -135,7 +135,7 @@ const struct format_type *fmt_from_vgnam
 
 	list_iterate_safe(devh, tmp, &devs) {
 		devl = list_item(devh, struct device_list);
-		label_read(devl->dev, &label);
+		label_read(devl->dev, &label, UINT64_C(0));
 		list_del(&devl->list);
 		dm_free(devl);
 	}
@@ -205,7 +205,7 @@ static void _rescan_entry(struct lvmcach
 	struct label *label;
 
 	if (info->status & CACHE_INVALID)
-		label_read(info->dev, &label);
+		label_read(info->dev, &label, UINT64_C(0));
 }
 
 static int _scan_invalid(void)
@@ -247,7 +247,7 @@ int lvmcache_label_scan(struct cmd_conte
 	}
 
 	while ((dev = dev_iter_get(iter)))
-		label_read(dev, &label);
+		label_read(dev, &label, UINT64_C(0));
 
 	dev_iter_destroy(iter);
 
@@ -346,7 +346,7 @@ struct device *device_from_pvid(struct c
 
 	/* Already cached ? */
 	if ((info = info_from_pvid((char *) pvid))) {
-		if (label_read(info->dev, &label)) {
+		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
 				return info->dev;
@@ -357,7 +357,7 @@ struct device *device_from_pvid(struct c
 
 	/* Try again */
 	if ((info = info_from_pvid((char *) pvid))) {
-		if (label_read(info->dev, &label)) {
+		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
 				return info->dev;
@@ -371,7 +371,7 @@ struct device *device_from_pvid(struct c
 
 	/* Try again */
 	if ((info = info_from_pvid((char *) pvid))) {
-		if (label_read(info->dev, &label)) {
+		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
 				return info->dev;
Index: LVM2/lib/format_text/format-text.c
===================================================================
--- LVM2.orig/lib/format_text/format-text.c	2007-04-20 11:26:52.000000000 -0400
+++ LVM2/lib/format_text/format-text.c	2007-04-20 13:20:28.000000000 -0400
@@ -1287,7 +1287,7 @@ static int _text_pv_read(const struct fo
 	}
 
 	/* FIXME Optimise out repeated reading when cache lock held */
-	if (!(label_read(dev, &label))) {
+	if (!(label_read(dev, &label, UINT64_C(0)))) {
 		stack;
 		return 0;
 	}
Index: LVM2/lib/label/label.c
===================================================================
--- LVM2.orig/lib/label/label.c	2007-04-20 11:26:52.000000000 -0400
+++ LVM2/lib/label/label.c	2007-04-20 13:24:47.000000000 -0400
@@ -107,7 +107,8 @@ struct labeller *label_get_handler(const
 }
 
 static struct labeller *_find_labeller(struct device *dev, char *buf,
-				       uint64_t *label_sector)
+				       uint64_t *label_sector,
+				       uint64_t start_sector)
 {
 	struct labeller_i *li;
 	struct labeller *r = NULL;
@@ -117,12 +118,13 @@ static struct labeller *_find_labeller(s
 	int found = 0;
 	char readbuf[LABEL_SCAN_SIZE] __attribute((aligned(8)));
 
-	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, readbuf)) {
+	if (!dev_read(dev, start_sector << SECTOR_SHIFT,
+		      LABEL_SCAN_SIZE, readbuf)) {
 		log_debug("%s: Failed to read label area", dev_name(dev));
 		goto out;
 	}
 
-	/* Scan first few sectors for a valid label */
+	/* Scan a few sectors for a valid label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
 		lh = (struct label_header *) (readbuf +
@@ -132,13 +134,14 @@ static struct labeller *_find_labeller(s
 			if (found) {
 				log_error("Ignoring additional label on %s at "
 					  "sector %" PRIu64, dev_name(dev),
-					  sector);
+					  sector + start_sector);
 			}
-			if (xlate64(lh->sector_xl) != sector) {
+			if (xlate64(lh->sector_xl) != sector + start_sector) {
 				log_info("%s: Label for sector %" PRIu64
 					 " found at sector %" PRIu64
 					 " - ignoring", dev_name(dev),
-					 xlate64(lh->sector_xl), sector);
+					 xlate64(lh->sector_xl),
+					 sector + start_sector);
 				continue;
 			}
 			if (calc_crc(INITIAL_CRC, &lh->offset_xl, LABEL_SIZE -
@@ -153,19 +156,21 @@ static struct labeller *_find_labeller(s
 		}
 
 		list_iterate_items(li, &_labellers) {
-			if (li->l->ops->can_handle(li->l, (char *) lh, sector)) {
+			if (li->l->ops->can_handle(li->l, (char *) lh,
+						   sector + start_sector)) {
 				log_very_verbose("%s: %s label detected",
 						 dev_name(dev), li->name);
 				if (found) {
 					log_error("Ignoring additional label "
 						  "on %s at sector %" PRIu64,
-						  dev_name(dev), sector);
+						  dev_name(dev),
+						  sector + start_sector);
 					continue;
 				}
 				r = li->l;
 				memcpy(buf, lh, LABEL_SIZE);
 				if (label_sector)
-					*label_sector = sector;
+					*label_sector = sector + start_sector;
 				found = 1;
 				break;
 			}
@@ -256,7 +261,8 @@ int label_remove(struct device *dev)
 }
 
 /* FIXME Avoid repeated re-reading if cache lock held */
-int label_read(struct device *dev, struct label **result)
+int label_read(struct device *dev, struct label **result,
+		uint64_t start_sector)
 {
 	char buf[LABEL_SIZE] __attribute((aligned(8)));
 	struct labeller *l;
@@ -274,7 +280,7 @@ int label_read(struct device *dev, struc
 		return r;
 	}
 
-	if (!(l = _find_labeller(dev, buf, &sector)))
+	if (!(l = _find_labeller(dev, buf, &sector, start_sector)))
 		goto_out;
 
 	if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result)
@@ -354,7 +360,7 @@ int label_verify(struct device *dev)
 		return_0;
 	}
 
-	if (!(l = _find_labeller(dev, buf, &sector)))
+	if (!(l = _find_labeller(dev, buf, &sector, UINT64_C(0))))
 		goto_out;
 
 	r = l->ops->verify ? l->ops->verify(l, buf, sector) : 1;
Index: LVM2/lib/label/label.h
===================================================================
--- LVM2.orig/lib/label/label.h	2007-04-20 11:26:52.000000000 -0400
+++ LVM2/lib/label/label.h	2007-04-20 13:20:28.000000000 -0400
@@ -96,7 +96,8 @@ int label_register_handler(const char *n
 struct labeller *label_get_handler(const char *name);
 
 int label_remove(struct device *dev);
-int label_read(struct device *dev, struct label **result);
+int label_read(struct device *dev, struct label **result,
+		uint64_t start_sector);
 int label_write(struct device *dev, struct label *label);
 int label_verify(struct device *dev);
 struct label *label_create(struct labeller *labeller);
Index: LVM2/lib/metadata/metadata.c
===================================================================
--- LVM2.orig/lib/metadata/metadata.c	2007-04-20 11:26:52.000000000 -0400
+++ LVM2/lib/metadata/metadata.c	2007-04-20 13:26:59.000000000 -0400
@@ -1403,7 +1403,7 @@ struct physical_volume *pv_read(struct c
 		return NULL;
 	}
 
-	if (!(label_read(dev, &label))) {
+	if (!(label_read(dev, &label, UINT64_C(0)))) {
 		if (warnings)
 			log_error("No physical volume label read from %s",
 				  pv_name);
Index: LVM2/tools/lvmdiskscan.c
===================================================================
--- LVM2.orig/tools/lvmdiskscan.c	2007-04-20 11:26:52.000000000 -0400
+++ LVM2/tools/lvmdiskscan.c	2007-04-20 13:20:28.000000000 -0400
@@ -112,7 +112,7 @@ int lvmdiskscan(struct cmd_context *cmd,
 	/* Do scan */
 	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter)) {
 		/* Try if it is a PV first */
-		if ((label_read(dev, &label))) {
+		if ((label_read(dev, &label, UINT64_C(0)))) {
 			if (!dev_get_size(dev, &size)) {
 				log_error("Couldn't get size of \"%s\"",
 					  dev_name(dev));
Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-04-20 13:19:01.000000000 -0400
+++ LVM2/WHATS_NEW	2007-04-20 13:21:17.000000000 -0400
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add start_sector param to label_read and _find_labeller.
   Add lib/config support functions.
   Add count_chars_null and count_chars_len.
   Add dev_read_circular.



