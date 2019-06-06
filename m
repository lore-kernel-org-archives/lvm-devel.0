From: David Teigland <teigland@sourceware.org>
Date: Thu, 6 Jun 2019 11:17:30 -0400
Subject: master - pvck: use new dump routines for old output
Message-ID: <201906061517.x56FHUBZ003770@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b241eb1f666e93f47917f2495e900bf80c9d5ff
Commit:        2b241eb1f666e93f47917f2495e900bf80c9d5ff
Parent:        356ea897ccfca5a80b00a0a6b2479042f6efd144
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 5 16:23:23 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 5 16:28:52 2019 -0500

pvck: use new dump routines for old output

Use the recently added dump routines to produce the
old/traditional pvck output, and remove the code that
had been used for that.

The validation/checking done by the new routines means
that new lines prefixed with CHECK are printed for
incorrect values.
---
 lib/format_text/format-text.c |  152 -----------------------------------------
 lib/label/label.c             |   60 ----------------
 lib/metadata/metadata.c       |   35 ----------
 tools/pvck.c                  |  151 +++++++++++++++++++++++++----------------
 4 files changed, 92 insertions(+), 306 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 3828d5f..2831a53 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -121,157 +121,6 @@ static struct device *_mda_get_device_raw(struct metadata_area *mda)
 	return mdac->area.dev;
 }
 
-/*
- * For circular region between region_start and region_start + region_size,
- * back up one SECTOR_SIZE from 'region_ptr' and return the value.
- * This allows reverse traversal through text metadata area to find old
- * metadata.
- *
- * Parameters:
- *   region_start: start of the region (bytes)
- *   region_size: size of the region (bytes)
- *   region_ptr: pointer within the region (bytes)
- *   NOTE: region_start <= region_ptr <= region_start + region_size
- */
-static uint64_t _get_prev_sector_circular(uint64_t region_start,
-					  uint64_t region_size,
-					  uint64_t region_ptr)
-{
-	if (region_ptr >= region_start + SECTOR_SIZE)
-		return region_ptr - SECTOR_SIZE;
-
-	return (region_start + region_size - SECTOR_SIZE);
-}
-
-/*
- * Analyze a metadata area for old metadata records in the circular buffer.
- * This function just looks through and makes a first pass at the data in
- * the sectors for particular things.
- * FIXME: do something with each metadata area (try to extract vg, write
- * raw data to file, etc)
- */
-static int _pv_analyze_mda_raw (const struct format_type * fmt,
-				struct metadata_area *mda)
-{
-	struct mda_header *mdah;
-	struct raw_locn *rlocn;
-	uint64_t area_start;
-	uint64_t area_size;
-	uint64_t prev_sector, prev_sector2;
-	uint64_t latest_mrec_offset;
-	uint64_t offset;
-	uint64_t offset2;
-	size_t size;
-	size_t size2;
-	char *buf=NULL;
-	struct device_area *area;
-	struct mda_context *mdac;
-	int r=0;
-
-	mdac = (struct mda_context *) mda->metadata_locn;
-
-	log_print("Found text metadata area: offset=" FMTu64 ", size="
-		  FMTu64, mdac->area.start, mdac->area.size);
-	area = &mdac->area;
-
-	if (!(mdah = raw_read_mda_header(fmt, area, mda_is_primary(mda))))
-		goto_out;
-
-	rlocn = mdah->raw_locns;
-
-	/*
-	 * The device area includes the metadata header as well as the
-	 * records, so remove the metadata header from the start and size
-	 */
-	area_start = area->start + MDA_HEADER_SIZE;
-	area_size = area->size - MDA_HEADER_SIZE;
-	latest_mrec_offset = rlocn->offset + area->start;
-
-	/*
-	 * Start searching at rlocn (point of live metadata) and go
-	 * backwards.
-	 */
-	prev_sector = _get_prev_sector_circular(area_start, area_size,
-					       latest_mrec_offset);
-	offset = prev_sector;
-	size = SECTOR_SIZE;
-	offset2 = size2 = 0;
-
-	while (prev_sector != latest_mrec_offset) {
-		prev_sector2 = prev_sector;
-		prev_sector = _get_prev_sector_circular(area_start, area_size,
-							prev_sector);
-		if (prev_sector > prev_sector2)
-			goto_out;
-		/*
-		 * FIXME: for some reason, the whole metadata region from
-		 * area->start to area->start+area->size is not used.
-		 * Only ~32KB seems to contain valid metadata records
-		 * (LVM2 format - format_text).  As a result, I end up with
-		 * "dm_config_maybe_section" returning true when there's no valid
-		 * metadata in a sector (sectors with all nulls).
-		 */
-		if (!(buf = malloc(size + size2)))
-			goto_out;
-
-		if (!dev_read_bytes(area->dev, offset, size, buf)) {
-			log_error("Failed to read dev %s offset %llu size %llu",
-				  dev_name(area->dev),
-				  (unsigned long long)offset,
-				  (unsigned long long)size);
-			goto out;
-		}
-
-		if (size2) {
-			if (!dev_read_bytes(area->dev, offset2, size2, buf + size)) {
-				log_error("Failed to read dev %s offset %llu size %llu",
-				  	  dev_name(area->dev),
-					  (unsigned long long)offset2,
-				          (unsigned long long)size2);
-				goto out;
-			}
-		}
-
-		/*
-		 * FIXME: We could add more sophisticated metadata detection
-		 */
-		if (dm_config_maybe_section(buf, size + size2)) {
-			/* FIXME: Validate region, pull out timestamp?, etc */
-			/* FIXME: Do something with this region */
-			log_verbose ("Found LVM2 metadata record at "
-				     "offset=" FMTu64 ", size=" FMTsize_t ", "
-				     "offset2=" FMTu64 " size2=" FMTsize_t,
-				     offset, size, offset2, size2);
-			offset = prev_sector;
-			size = SECTOR_SIZE;
-			offset2 = size2 = 0;
-		} else {
-			/*
-			 * Not a complete metadata record, assume we have
-			 * metadata and just increase the size and offset.
-			 * Start the second region if the previous sector is
-			 * wrapping around towards the end of the disk.
-			 */
-			if (prev_sector > offset) {
-				offset2 = prev_sector;
-				size2 += SECTOR_SIZE;
-			} else {
-				offset = prev_sector;
-				size += SECTOR_SIZE;
-			}
-		}
-		free(buf);
-		buf = NULL;
-	}
-
-	r = 1;
- out:
-	free(buf);
-	return r;
-}
-
-
-
 static int _text_lv_setup(struct format_instance *fid __attribute__((unused)),
 			  struct logical_volume *lv)
 {
@@ -1962,7 +1811,6 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 	.mda_free_sectors = _mda_free_sectors_raw,
 	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
-	.pv_analyze_mda = _pv_analyze_mda_raw,
 	.mda_locns_match = _mda_locns_match_raw,
 	.mda_get_device = _mda_get_device_raw,
 };
diff --git a/lib/label/label.c b/lib/label/label.c
index 43b05a2..10c1c4c 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1198,66 +1198,6 @@ int label_read(struct device *dev)
 	return 1;
 }
 
-/*
- * Read a label from a specfic, non-zero sector.  This is used in only
- * one place: pvck/pv_analyze.
- */
-
-int label_read_sector(struct device *dev, uint64_t read_sector)
-{
-	struct block *bb = NULL;
-	uint64_t block_num;
-	uint64_t block_sector;
-	uint64_t start_sector;
-	int is_lvm_device = 0;
-	int result;
-	int ret;
-
-	block_num = read_sector / BCACHE_BLOCK_SIZE_IN_SECTORS;
-	block_sector = block_num * BCACHE_BLOCK_SIZE_IN_SECTORS;
-	start_sector = read_sector % BCACHE_BLOCK_SIZE_IN_SECTORS;
-
-	if (!label_scan_open(dev)) {
-		log_error("Error opening device %s for prefetch %llu sector.",
-			  dev_name(dev), (unsigned long long)block_num);
-		return false;
-	}
-
-	bcache_prefetch(scan_bcache, dev->bcache_fd, block_num);
-
-	if (!bcache_get(scan_bcache, dev->bcache_fd, block_num, 0, &bb)) {
-		log_error("Scan failed to read %s at %llu",
-			  dev_name(dev), (unsigned long long)block_num);
-		ret = 0;
-		goto out;
-	}
-
-	/*
-	 * TODO: check if scan_sector is larger than the bcache block size.
-	 * If it is, we need to fetch a later block from bcache.
-	 */
-
-	result = _process_block(NULL, NULL, dev, bb, block_sector, start_sector, &is_lvm_device);
-
-	if (!result && is_lvm_device) {
-		log_error("Scan failed to process %s", dev_name(dev));
-		ret = 0;
-		goto out;
-	}
-
-	if (!result || !is_lvm_device) {
-		log_error("Could not find LVM label on %s", dev_name(dev));
-		ret = 0;
-		goto out;
-	}
-
-	ret = 1;
-out:
-	if (bb)
-		bcache_put(bb);
-	return ret;
-}
-
 int label_scan_setup_bcache(void)
 {
 	if (!scan_bcache) {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8f6de26..65da7e1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4664,41 +4664,6 @@ int is_real_vg(const char *vg_name)
 	return (vg_name && *vg_name != '#');
 }
 
-static int _analyze_mda(struct metadata_area *mda, void *baton)
-{
-	const struct format_type *fmt = baton;
-	mda->ops->pv_analyze_mda(fmt, mda);
-	return 1;
-}
-
-/*
- * Returns:
- *  0 - fail
- *  1 - success
- */
-int pv_analyze(struct cmd_context *cmd, struct device *dev,
-	       uint64_t label_sector)
-{
-	struct label *label;
-	struct lvmcache_info *info;
-
-	if (!(label = lvmcache_get_dev_label(dev))) {
-		log_error("Could not find LVM label on %s", dev_name(dev));
-		return 0;
-	}
-
-	log_print("Found label on %s, sector %"PRIu64", type=%.8s",
-		  dev_name(dev), label->sector, label->type);
-
-	/*
-	 * Next, loop through metadata areas
-	 */
-	info = label->info;
-	lvmcache_foreach_mda(info, _analyze_mda, (void *)lvmcache_fmt(info));
-
-	return 1;
-}
-
 /* FIXME: remove / combine this with locking? */
 int vg_check_write_mode(struct volume_group *vg)
 {
diff --git a/tools/pvck.c b/tools/pvck.c
index c9b833a..3437164 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -83,13 +83,16 @@ static char *_chars_to_hexstr(void *in, void *out, int num, int max, const char
 	return out;
 }
 
-static int _check_label_header(struct label_header *lh, uint64_t labelsector)
+static int _check_label_header(struct label_header *lh, uint64_t labelsector,
+			       int *found_label)
 {
 	uint32_t crc;
+	int good_id = 1, good_type = 1;
 	int bad = 0;
 
 	if (memcmp(lh->id, LABEL_ID, sizeof(lh->id))) {
 		log_print("CHECK: label_header.id expected %s", LABEL_ID);
+		good_id = 0;
 		bad++;
 	}
 
@@ -113,9 +116,14 @@ static int _check_label_header(struct label_header *lh, uint64_t labelsector)
 
 	if (memcmp(lh->type, LVM2_LABEL, sizeof(lh->type))) {
 		log_print("CHECK: label_header.type expected %s", LVM2_LABEL);
+		good_type = 0;
 		bad++;
 	}
 
+	/* Report a label is found if at least id and type are correct. */
+	if (found_label && good_id && good_type)
+		*found_label = 1;
+
 	if (bad)
 		return 0;
 	return 1;
@@ -140,10 +148,11 @@ static int _check_pv_header(struct pv_header *ph)
  * mda_offset/mda_size are from the pv_header/disk_locn and could
  * be incorrect.
  */
-static int _check_mda_header(struct mda_header *mh, int mda_num, uint64_t mda_offset, uint64_t mda_size)
+static int _check_mda_header(struct mda_header *mh, int mda_num, uint64_t mda_offset, uint64_t mda_size, int *found_header)
 {
 	char str[256];
 	uint32_t crc;
+	int good_magic = 1;
 	int bad = 0;
 
 	crc = calc_crc(INITIAL_CRC, (uint8_t *)mh->magic,
@@ -156,6 +165,7 @@ static int _check_mda_header(struct mda_header *mh, int mda_num, uint64_t mda_of
 
 	if (memcmp(mh->magic, FMTT_MAGIC, sizeof(mh->magic))) {
 		log_print("CHECK: mda_header_%d.magic expected 0x%s", mda_num, _chars_to_hexstr((void *)&FMTT_MAGIC, str, 16, 256, "mda_header.magic"));
+		good_magic = 0;
 		bad++;
 	}
 
@@ -174,6 +184,10 @@ static int _check_mda_header(struct mda_header *mh, int mda_num, uint64_t mda_of
 		bad++;
 	}
 
+	/* Report a header is found if at least magic is correct. */
+	if (found_header && good_magic)
+		*found_header = 1;
+
 	if (bad)
 		return 0;
 	return 1;
@@ -684,9 +698,10 @@ static int _dump_meta_text(struct device *dev,
 		config_destroy(cft);
 	}
 
-	log_print("metadata text at %llu crc 0x%x # vgname %s seqno %u",
-		  (unsigned long long)(mda_offset + meta_offset), crc,
-		  vgname ? vgname : "?", seqno);
+	if (print_fields || print_metadata)
+		log_print("metadata text at %llu crc 0x%x # vgname %s seqno %u",
+			  (unsigned long long)(mda_offset + meta_offset), crc,
+			  vgname ? vgname : "?", seqno);
 
 	if (!print_metadata)
 		goto out;
@@ -720,6 +735,7 @@ static int _dump_meta_text(struct device *dev,
 
 static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
 				     struct device *dev,
+				     int *found_label,
 				     uint64_t *mda1_offset, uint64_t *mda1_size,
 				     uint64_t *mda2_offset, uint64_t *mda2_size)
 {
@@ -771,7 +787,7 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
 		log_print("label_header.type %s", _chars_to_str(lh->type, str, 8, 256, "label_header.type"));
 	}
 
-	if (!_check_label_header(lh, labelsector))
+	if (!_check_label_header(lh, labelsector, found_label))
 		bad++;
 
 	/*
@@ -972,7 +988,8 @@ static int _dump_mda_header(struct cmd_context *cmd,
 			    const char *tofile,
 			    struct device *dev,
 			    uint64_t mda_offset, uint64_t mda_size,
-			    uint32_t *checksum0_ret)
+			    uint32_t *checksum0_ret,
+			    int *found_header)
 {
 	char str[256];
 	char *buf;
@@ -1018,7 +1035,7 @@ static int _dump_mda_header(struct cmd_context *cmd,
 		log_print("mda_header_%d.size %llu", mda_num, (unsigned long long)xlate64(mh->size));
 	}
 
-	if (!_check_mda_header(mh, mda_num, mda_offset, mda_size))
+	if (!_check_mda_header(mh, mda_num, mda_offset, mda_size, found_header))
 		bad++;
 
 	if (print_area) {
@@ -1108,7 +1125,7 @@ static int _dump_headers(struct cmd_context *cmd,
 
 	label_scan_setup_bcache();
 
-	if (!_dump_label_and_pv_header(cmd, 1, dev,
+	if (!_dump_label_and_pv_header(cmd, 1, dev, NULL,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size))
 		bad++;
 
@@ -1125,7 +1142,7 @@ static int _dump_headers(struct cmd_context *cmd,
 	 * which may have been corrupted.
 	 */
 
-	if (!_dump_mda_header(cmd, 1, 0, 0, NULL, dev, 4096, mda1_size, &mda1_checksum))
+	if (!_dump_mda_header(cmd, 1, 0, 0, NULL, dev, 4096, mda1_size, &mda1_checksum, NULL))
 		bad++;
 
 	/*
@@ -1136,7 +1153,7 @@ static int _dump_headers(struct cmd_context *cmd,
 	 * but there is a valid header elsewhere.
 	 */
 	if (mda2_offset) {
-		if (!_dump_mda_header(cmd, 1, 0, 0, NULL, dev, mda2_offset, mda2_size, &mda2_checksum))
+		if (!_dump_mda_header(cmd, 1, 0, 0, NULL, dev, mda2_offset, mda2_size, &mda2_checksum, NULL))
 			bad++;
 
 		/* This probably indicates that one was committed and the other not. */
@@ -1181,7 +1198,7 @@ static int _dump_metadata(struct cmd_context *cmd,
 
 	label_scan_setup_bcache();
 
-	if (!_dump_label_and_pv_header(cmd, 0, dev,
+	if (!_dump_label_and_pv_header(cmd, 0, dev, NULL,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size))
 		bad++;
 
@@ -1204,14 +1221,14 @@ static int _dump_metadata(struct cmd_context *cmd,
 	 */
 
 	if (mda_num == 1) {
-		if (!_dump_mda_header(cmd, 0, print_metadata, print_area, tofile, dev, 4096, mda1_size, &mda1_checksum))
+		if (!_dump_mda_header(cmd, 0, print_metadata, print_area, tofile, dev, 4096, mda1_size, &mda1_checksum, NULL))
 			bad++;
 	} else if (mda_num == 2) {
 		if (!mda2_offset) {
 			log_print("CHECK: second mda not found");
 			bad++;
 		} else {
-			if (!_dump_mda_header(cmd, 0, print_metadata, print_area, tofile, dev, mda2_offset, mda2_size, &mda2_checksum))
+			if (!_dump_mda_header(cmd, 0, print_metadata, print_area, tofile, dev, mda2_offset, mda2_size, &mda2_checksum, NULL))
 				bad++;
 		}
 	}
@@ -1223,16 +1240,59 @@ static int _dump_metadata(struct cmd_context *cmd,
 	return ECMD_PROCESSED;
 }
 
+static int _dump_found(struct cmd_context *cmd, struct device *dev,
+		       uint64_t labelsector)
+{
+	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
+	uint32_t mda1_checksum = 0, mda2_checksum = 0;
+	int found_label = 0, found_header1 = 0, found_header2 = 0;
+	int bad = 0;
+
+	if (!_dump_label_and_pv_header(cmd, 0, dev, &found_label,
+			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size))
+		bad++;
+
+	if (found_label && mda1_offset) {
+		if (!_dump_mda_header(cmd, 0, 0, 0, NULL, dev, 4096, mda1_size, &mda1_checksum, &found_header1))
+			bad++;
+	}
+
+	if (found_label && mda2_offset) {
+		if (!_dump_mda_header(cmd, 0, 0, 0, NULL, dev, mda2_offset, mda2_size, &mda2_checksum, &found_header2))
+			bad++;
+	}
+
+	if (found_label)
+		log_print("Found label on %s, sector %llu, type=LVM2 001",
+			  dev_name(dev), (unsigned long long)labelsector);
+	else {
+		log_error("Could not find LVM label on %s", dev_name(dev));
+		return 0;
+	}
+
+	if (found_header1)
+		log_print("Found text metadata area: offset=%llu, size=%llu",
+			  (unsigned long long)mda1_offset,
+			  (unsigned long long)mda1_size);
+
+	if (found_header2)
+		log_print("Found text metadata area: offset=%llu, size=%llu",
+			  (unsigned long long)mda2_offset,
+			  (unsigned long long)mda2_size);
+
+	if (bad)
+		return 0;
+	return 1;
+}
+
 int pvck(struct cmd_context *cmd, int argc, char **argv)
 {
-	struct dm_list devs;
-	struct device_list *devl;
 	struct device *dev;
 	const char *dump;
 	const char *pv_name;
-	uint64_t labelsector;
+	uint64_t labelsector = 1;
+	int bad = 0;
 	int i;
-	int ret_max = ECMD_PROCESSED;
 
 	if (arg_is_set(cmd, dump_ARG)) {
 		dump = arg_str_value(cmd, dump_ARG, NULL);
@@ -1253,56 +1313,29 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	labelsector = arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0));
+	/*
+	 * The old/original form of pvck, which did not do much,
+	 * but this is here to preserve the historical output.
+	 */
 
-	dm_list_init(&devs);
+	if (arg_is_set(cmd, labelsector_ARG))
+		labelsector = arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0));
 
-	for (i = 0; i < argc; i++) {
-		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
+	label_scan_setup_bcache();
 
+	for (i = 0; i < argc; i++) {
 		pv_name = argv[i];
 
-		dev = dev_cache_get(cmd, pv_name, cmd->filter);
-
-		if (!dev) {
+		if (!(dev = dev_cache_get(cmd, argv[i], cmd->filter))) {
 			log_error("Device %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
 			continue;
 		}
 
-		if (!(devl = zalloc(sizeof(*devl))))
-			continue;
-
-		devl->dev = dev;
-		dm_list_add(&devs, &devl->list);
-	}
-
-	label_scan_setup_bcache();
-	label_scan_devs(cmd, cmd->filter, &devs);
-
-	dm_list_iterate_items(devl, &devs) {
-		/*
-		 * The scan above will populate lvmcache with any info from the
-		 * standard locations at the start of the device.  Now populate
-		 * lvmcache with any info from non-standard offsets.
-		 *
-		 * FIXME: is it possible for a real lvm label sector to be
-		 * anywhere other than the first four sectors of the disk?
-		 * If not, drop the code in label_read_sector/find_lvm_header
-		 * that supports searching at any sector.
-		 */
-		if (labelsector) {
-			if (!label_read_sector(devl->dev, labelsector)) {
-				stack;
-				ret_max = ECMD_FAILED;
-				continue;
-			}
-		}
-
-		if (!pv_analyze(cmd, devl->dev, labelsector)) {
-			stack;
-			ret_max = ECMD_FAILED;
-		}
+		if (!_dump_found(cmd, dev, labelsector))
+			bad++;
 	}
 
-	return ret_max;
+	if (bad)
+		return ECMD_FAILED;
+	return ECMD_PROCESSED;
 }


