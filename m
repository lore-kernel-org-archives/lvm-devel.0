From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 4 Jan 2018 22:17:18 -0500
Subject: master - metadata: Change the new data processing fns to void.
Message-ID: <201801050317.w053HIJo029463@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a0ddfad94b92da4c5d21459f17c5f1fb9fe003b3
Commit:        a0ddfad94b92da4c5d21459f17c5f1fb9fe003b3
Parent:        c70c9f65659df846dbc590053569a80935e09d2f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 5 02:31:28 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 5 03:12:22 2018 +0000

metadata: Change the new data processing fns to void.

Move the existing fn return codes into the new structs.
---
 lib/config/config.c           |   22 ++++++++--------
 lib/format_text/format-text.c |   55 ++++++++++++++++++++++++++---------------
 lib/format_text/import.c      |   26 +++++++++++--------
 lib/format_text/text_label.c  |   25 +++++++++---------
 lib/label/label.c             |   20 +++++++++------
 5 files changed, 85 insertions(+), 63 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index bb1d80e..5dc2356 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -500,12 +500,12 @@ struct process_config_file_params {
 	uint32_t checksum;
 	int checksum_only;
 	int no_dup_node_check;
+	int ret;
 };
 
-static int _process_config_file_buffer(struct process_config_file_params *pcfp, char *buffer)
+static void _process_config_file_buffer(struct process_config_file_params *pcfp, char *buffer)
 {
 	char *fb, *fe;
-	int r = 0;
 
 	fb = buffer;
 
@@ -513,6 +513,7 @@ static int _process_config_file_buffer(struct process_config_file_params *pcfp,
 	    (pcfp->checksum_fn(pcfp->checksum_fn(INITIAL_CRC, (const uint8_t *)fb, pcfp->size),
 			 (const uint8_t *)(fb + pcfp->size), pcfp->size2))) {
 		log_error("%s: Checksum error at offset %" PRIu64, dev_name(pcfp->dev), (uint64_t) pcfp->offset);
+		pcfp->ret = 0;
 		goto out;
 	}
 
@@ -520,16 +521,13 @@ static int _process_config_file_buffer(struct process_config_file_params *pcfp,
 		fe = fb + pcfp->size + pcfp->size2;
 		if (pcfp->no_dup_node_check) {
 			if (!dm_config_parse_without_dup_node_check(pcfp->cft, fb, fe))
-				goto_out;
-		} else {
-			if (!dm_config_parse(pcfp->cft, fb, fe))
-				goto_out;
-		}
+				pcfp->ret = 0;
+		} else if (!dm_config_parse(pcfp->cft, fb, fe))
+			pcfp->ret = 0;
 	}
 
-	r = 1;
 out:
-	return r;
+	;
 }
 
 /*
@@ -573,6 +571,7 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 	pcfp->checksum = checksum;
 	pcfp->checksum_only = checksum_only;
 	pcfp->no_dup_node_check = no_dup_node_check;
+	pcfp->ret = 1;
 
 	/* Only use mmap with regular files */
 	if (!(dev->flags & DEV_REGULAR) || circular)
@@ -599,7 +598,8 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 		fb = buf;
 	}
 
-	r = _process_config_file_buffer(pcfp, fb);
+	_process_config_file_buffer(pcfp, fb);
+	r = pcfp->ret;
 
       out:
 	if (!use_mmap)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 798fd66..fb87ae2 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -329,16 +329,18 @@ static void _xlate_mdah(struct mda_header *mdah)
 struct process_raw_mda_header_params {
 	struct mda_header *mdah;
 	struct device_area dev_area;
+	int ret;
 };
 
-static int _process_raw_mda_header(struct process_raw_mda_header_params *prmp)
+static void _process_raw_mda_header(struct process_raw_mda_header_params *prmp)
 {
 	struct mda_header *mdah = prmp->mdah;
 	struct device_area *dev_area = &prmp->dev_area;
-	int r = 0;
 
-	if (!dev_close(dev_area->dev))
+	if (!dev_close(dev_area->dev)) {
+		prmp->ret = 0;
 		goto_out;
+	}
 
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 						  MDA_HEADER_SIZE -
@@ -346,6 +348,7 @@ static int _process_raw_mda_header(struct process_raw_mda_header_params *prmp)
 		log_error("Incorrect metadata area header checksum on %s"
 			  " at offset " FMTu64, dev_name(dev_area->dev),
 			  dev_area->start);
+		prmp->ret = 0;
 		goto out;
 	}
 
@@ -355,6 +358,7 @@ static int _process_raw_mda_header(struct process_raw_mda_header_params *prmp)
 		log_error("Wrong magic number in metadata area header on %s"
 			  " at offset " FMTu64, dev_name(dev_area->dev),
 			  dev_area->start);
+		prmp->ret = 0;
 		goto out;
 	}
 
@@ -362,6 +366,7 @@ static int _process_raw_mda_header(struct process_raw_mda_header_params *prmp)
 		log_error("Incompatible metadata area header version: %d on %s"
 			  " at offset " FMTu64, mdah->version,
 			  dev_name(dev_area->dev), dev_area->start);
+		prmp->ret = 0;
 		goto out;
 	}
 
@@ -369,13 +374,12 @@ static int _process_raw_mda_header(struct process_raw_mda_header_params *prmp)
 		log_error("Incorrect start sector in metadata area header: "
 			  FMTu64 " on %s at offset " FMTu64, mdah->start,
 			  dev_name(dev_area->dev), dev_area->start);
+		prmp->ret = 0;
 		goto out;
 	}
 
-	r = 1;
-
 out:
-	return r;
+	;
 }
 
 static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda)
@@ -401,6 +405,7 @@ static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct devic
 
 	prmp->mdah = mdah;
 	prmp->dev_area = *dev_area;
+	prmp->ret = 1;
 
 	if (!dev_read_buf(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
 		if (!dev_close(dev_area->dev))
@@ -408,7 +413,9 @@ static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct devic
 		return_NULL;
 	}
 
-	if (!_process_raw_mda_header(prmp))
+	_process_raw_mda_header(prmp);
+
+	if (!prmp->ret)
 		return_NULL;
 
 	return mdah;
@@ -1337,9 +1344,10 @@ struct vgname_from_mda_params{
 	uint64_t *mda_free_sectors;
 	uint32_t wrap;
 	unsigned used_cached_metadata;
+	int ret;
 };
 
-static int _vgname_from_mda_process(struct vgname_from_mda_params *vfmp)
+static void _vgname_from_mda_process(struct vgname_from_mda_params *vfmp)
 {
 	struct mda_header *mdah = vfmp->mdah;
 	struct device_area *dev_area = vfmp->dev_area;
@@ -1347,11 +1355,12 @@ static int _vgname_from_mda_process(struct vgname_from_mda_params *vfmp)
 	uint64_t *mda_free_sectors = vfmp->mda_free_sectors;
 	struct raw_locn *rlocn = mdah->raw_locns;
 	uint64_t buffer_size, current_usage;
-	int r = 0;
 
 	/* Ignore this entry if the characters aren't permissible */
-	if (!validate_name(vgsummary->vgname))
+	if (!validate_name(vgsummary->vgname)) {
+		vfmp->ret = 0;
 		goto_out;
+	}
 
 	log_debug_metadata("%s: %s metadata at " FMTu64 " size " FMTu64 " with wrap " FMTu32
 			   " (in area at " FMTu64 " size " FMTu64
@@ -1373,13 +1382,11 @@ static int _vgname_from_mda_process(struct vgname_from_mda_params *vfmp)
 			*mda_free_sectors = ((buffer_size - 2 * current_usage) / 2) >> SECTOR_SHIFT;
 	}
 
-	r = 1;
-
 out:
-	return r;
+	;
 }
 
-static int _vgname_from_mda_validate(struct vgname_from_mda_params *vfmp, char *buffer)
+static void _vgname_from_mda_validate(struct vgname_from_mda_params *vfmp, char *buffer)
 {
 	const struct format_type *fmt = vfmp->fmt;
 	struct mda_header *mdah = vfmp->mdah;
@@ -1398,8 +1405,10 @@ static int _vgname_from_mda_validate(struct vgname_from_mda_params *vfmp, char *
 	buf[len] = '\0';
 
 	/* Ignore this entry if the characters aren't permissible */
-	if (!validate_name(buf))
+	if (!validate_name(buf)) {
+		vfmp->ret = 0;
 		goto_out;
+	}
 
 	/* We found a VG - now check the metadata */
 	if (rlocn->offset + rlocn->size > mdah->size)
@@ -1408,6 +1417,7 @@ static int _vgname_from_mda_validate(struct vgname_from_mda_params *vfmp, char *
 	if (vfmp->wrap > rlocn->offset) {
 		log_error("%s: metadata (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes)",
 			  dev_name(dev_area->dev), rlocn->size, mdah->size - MDA_HEADER_SIZE);
+		vfmp->ret = 0;
 		goto out;
 	}
 
@@ -1424,13 +1434,15 @@ static int _vgname_from_mda_validate(struct vgname_from_mda_params *vfmp, char *
 				(uint32_t) (rlocn->size - vfmp->wrap),
 				(off_t) (dev_area->start + MDA_HEADER_SIZE),
 				vfmp->wrap, calc_crc, vgsummary->vgname ? 1 : 0,
-				vgsummary))
+				vgsummary)) {
+		vfmp->ret = 0;
 		goto_out;
+	}
 
-	return _vgname_from_mda_process(vfmp);
+	_vgname_from_mda_process(vfmp);
 
 out:
-	return 0;
+	;
 }
 
 int vgname_from_mda(const struct format_type *fmt,
@@ -1472,6 +1484,7 @@ int vgname_from_mda(const struct format_type *fmt,
 	vfmp->vgsummary = vgsummary;
 	vfmp->primary_mda = primary_mda;
 	vfmp->mda_free_sectors = mda_free_sectors;
+	vfmp->ret = 1;
 
 	/* Do quick check for a vgname */
 	/* We cannot read the full metadata here because the name has to be validated before we use the size field */
@@ -1479,7 +1492,9 @@ int vgname_from_mda(const struct format_type *fmt,
 			  NAME_LEN, MDA_CONTENT_REASON(primary_mda), buf))
 		return_0;
 
-	return _vgname_from_mda_validate(vfmp, buf);
+	_vgname_from_mda_validate(vfmp, buf);
+
+	return vfmp->ret;
 }
 
 static int _scan_raw(const struct format_type *fmt, const char *vgname __attribute__((unused)))
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index d729659..580c1f3 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -38,18 +38,16 @@ struct import_vgsummary_params {
 	struct dm_config_tree *cft;
 	int checksum_only;
 	struct lvmcache_vgsummary *vgsummary;
+	int ret;
 };
 
-static int _import_vgsummary(struct import_vgsummary_params *ivsp)
+static void _import_vgsummary(struct import_vgsummary_params *ivsp)
 {
 	struct text_vg_version_ops **vsn;
-	int r = 0;
 
-	if (ivsp->checksum_only) {
+	if (ivsp->checksum_only)
 		/* Checksum matches already-cached content - no need to reparse. */
-		r = 1;
 		goto out;
-	}
 
 	/*
 	 * Find a set of version functions that can read this file
@@ -58,16 +56,19 @@ static int _import_vgsummary(struct import_vgsummary_params *ivsp)
 		if (!(*vsn)->check_version(ivsp->cft))
 			continue;
 
-		if (!(*vsn)->read_vgsummary(ivsp->fmt, ivsp->cft, ivsp->vgsummary))
+		if (!(*vsn)->read_vgsummary(ivsp->fmt, ivsp->cft, ivsp->vgsummary)) {
+			ivsp->ret = 0;
 			goto_out;
+		}
 
-		r = 1;
-		break;
+		goto out;
 	}
 
+	/* Nothing found */
+	ivsp->ret = 0;
+
 out:
 	config_destroy(ivsp->cft);
-	return r;
 }
 
 /*
@@ -96,6 +97,7 @@ int text_vgsummary_import(const struct format_type *fmt,
 	ivsp->fmt = fmt;
 	ivsp->checksum_only = checksum_only;
 	ivsp->vgsummary = vgsummary;
+	ivsp->ret = 1;
 
 	if (!dev && !config_file_read(fmt->cmd->mem, ivsp->cft)) {
 		log_error("Couldn't read volume group metadata.");
@@ -112,7 +114,9 @@ int text_vgsummary_import(const struct format_type *fmt,
 		return 0;
 	}
 
-	return _import_vgsummary(ivsp);
+	_import_vgsummary(ivsp);
+
+	return ivsp->ret;
 }
 
 struct cached_vg_fmtdata {
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 5e370d4..c4ea166 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -330,27 +330,23 @@ struct process_mda_header_params {
 	struct metadata_area *mda;
 	struct device *dev;
 	struct lvmcache_vgsummary vgsummary;
+	int ret;
 };
 
-static int _process_vgsummary(struct process_mda_header_params *pmp, struct lvmcache_vgsummary *vgsummary)
+static void _process_vgsummary(struct process_mda_header_params *pmp, struct lvmcache_vgsummary *vgsummary)
 {
-	int r = 0;
-
 	if (!lvmcache_update_vgname_and_id(pmp->umb->info, vgsummary)) {
 		pmp->umb->ret = 0;
+		pmp->ret = 0;
 		goto_out;
 	}
 
-	r = 1;
-
 out:
 	if (!dev_close(pmp->dev))
 		stack;
-
-	return r;
 }
 
-static int _process_mda_header(struct process_mda_header_params *pmp, struct mda_header *mdah)
+static void _process_mda_header(struct process_mda_header_params *pmp, struct mda_header *mdah)
 {
 	struct update_mda_baton *umb = pmp->umb;
 	const struct format_type *fmt = umb->label->labeller->fmt;
@@ -365,7 +361,7 @@ static int _process_mda_header(struct process_mda_header_params *pmp, struct mda
 				   mdac->area.start);
 		if (!dev_close(pmp->dev))
 			stack;
-		return 1;
+		return;
 	}
 
 	if (!vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &pmp->vgsummary,
@@ -374,10 +370,10 @@ static int _process_mda_header(struct process_mda_header_params *pmp, struct mda
 		stack;
 		if (!dev_close(pmp->dev))
 			stack;
-		return 1;
+		return;
 	}
 
-	return _process_vgsummary(pmp, &pmp->vgsummary);
+	_process_vgsummary(pmp, &pmp->vgsummary);
 }
 
 static int _update_mda(struct metadata_area *mda, void *baton)
@@ -411,6 +407,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 
 	pmp->umb = umb;
 	pmp->mda = mda;
+	pmp->ret = 1;
 
 	if (!(mdah = raw_read_mda_header(fmt->cmd->mem, &mdac->area, mda_is_primary(mda)))) {
 		stack;
@@ -419,7 +416,9 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	return _process_mda_header(pmp, mdah);
+	_process_mda_header(pmp, mdah);
+
+	return pmp->ret;
 }
 
 static int _text_read(struct labeller *l, struct device *dev, void *buf, struct label **label)
diff --git a/lib/label/label.c b/lib/label/label.c
index 26d94cf..5d5bcc5 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -125,6 +125,8 @@ struct find_labeller_params {
 
 	uint64_t label_sector;	/* Sector where label found */
 	struct label **result;
+
+	int ret;
 };
 
 static void _set_label_read_result(int failed, struct find_labeller_params *flp)
@@ -144,7 +146,7 @@ out:
 		stack;
 }
 
-static int _find_labeller(struct find_labeller_params *flp, char *readbuf)
+static void _find_labeller(struct find_labeller_params *flp, char *readbuf)
 {
 	struct device *dev = flp->dev;
 	uint64_t scan_sector = flp->scan_sector;
@@ -155,7 +157,8 @@ static int _find_labeller(struct find_labeller_params *flp, char *readbuf)
 	struct label_header *lh;
 	struct lvmcache_info *info;
 	uint64_t sector;
-	int r = 0;
+
+int r = 0;
 
 	/* Scan a few sectors for a valid label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
@@ -215,12 +218,11 @@ static int _find_labeller(struct find_labeller_params *flp, char *readbuf)
 		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 			_update_lvmcache_orphan(info);
 		log_very_verbose("%s: No label detected", dev_name(dev));
+		flp->ret = 0;
 	} else
-		r = (l->ops->read)(l, dev, labelbuf, result);
+		flp->ret = (l->ops->read)(l, dev, labelbuf, result);
 
-	_set_label_read_result(!r, flp);
-
-	return r;
+	_set_label_read_result(!flp->ret, flp);
 }
 
 /* FIXME Also wipe associated metadata area headers? */
@@ -318,6 +320,7 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 	flp->dev = dev;
 	flp->scan_sector = scan_sector;
 	flp->result = result;
+	flp->ret = 1;
 
 	/* Ensure result is always wiped as a precaution */
 	if (result)
@@ -340,7 +343,8 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		return 0;
 	}
 
-	return _find_labeller(flp, readbuf);
+	_find_labeller(flp, readbuf);
+	return flp->ret;
 }
 
 int label_read(struct device *dev, struct label **result, uint64_t scan_sector)


