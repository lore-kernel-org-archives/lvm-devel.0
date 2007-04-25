From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Apr 2007 21:10:56 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c ...
Message-ID: <20070425211056.14083.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-04-25 22:10:55

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Update pvck to include text metadata area and record detection.
	
	--

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.604&r2=1.605
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.155&r2=1.156

--- LVM2/WHATS_NEW	2007/04/25 20:38:39	1.604
+++ LVM2/WHATS_NEW	2007/04/25 21:10:55	1.605
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Update pvck to include text metadata area and record detection
   Add support functions for analysis of config sections
   Update pvck to read labels on disk, with --labelsector parameter
   Add count_chars and count_chars_len functions
--- LVM2/lib/format_text/format-text.c	2007/04/23 18:21:01	1.74
+++ LVM2/lib/format_text/format-text.c	2007/04/25 21:10:55	1.75
@@ -39,6 +39,9 @@
 #define FMT_TEXT_NAME "lvm2"
 #define FMT_TEXT_ALIAS "text"
 
+static struct mda_header *_raw_read_mda_header(const struct format_type *fmt,
+					       struct device_area *dev_area);
+
 static struct format_instance *_text_create_text_instance(const struct format_type
 						     *fmt, const char *vgname,
 						     const char *vgid,
@@ -96,6 +99,148 @@
 	return 0;
 }
 
+/*
+ * For circular region between region_start and region_start + region_size,
+ * back up one SECTOR_SIZE from 'region_ptr' and return the value.
+ * This allows reverse traversal through text metadata area to find old
+ * metadata.
+ *
+ * Parameters:
+ *   region_start: start of the region (bytes)
+ *   region_size: size of the region (bytes)
+ *   region_ptr: pointer within the region (bytes)
+ *   NOTE: region_start <= region_ptr <= region_start + region_size
+ */
+static uint64_t _get_prev_sector_circular(uint64_t region_start,
+					  uint64_t region_size,
+					  uint64_t region_ptr)
+{
+	if (region_ptr >= region_start + SECTOR_SIZE)
+		return region_ptr - SECTOR_SIZE;
+	else
+		return (region_start + region_size - SECTOR_SIZE);
+}
+
+/*
+ * Analyze a metadata area for old metadata records in the circular buffer.
+ * This function just looks through and makes a first pass at the data in
+ * the sectors for particular things.
+ * FIXME: do something with each metadata area (try to extract vg, write
+ * raw data to file, etc)
+ */
+static int _pv_analyze_mda_raw (const struct format_type * fmt,
+				struct metadata_area *mda)
+{
+	struct mda_header *mdah;
+	struct raw_locn *rlocn;
+	uint64_t area_start;
+	uint64_t area_size;
+	uint64_t prev_sector;
+	uint64_t latest_mrec_offset;
+	int i;
+	uint64_t offset;
+	uint64_t offset2;
+	uint64_t size;
+	uint64_t size2;
+	char *buf=NULL;
+	struct device_area *area;
+	struct mda_context *mdac;
+	int r=0;
+
+	mdac = (struct mda_context *) mda->metadata_locn;
+
+	log_print("Found text metadata area, offset=%"PRIu64", size=%"PRIu64,
+		  mdac->area.start,
+		  mdac->area.size);
+	area = &mdac->area;
+
+	if (!dev_open(area->dev))
+		return_0;
+
+	if (!(mdah = _raw_read_mda_header(fmt, area)))
+		goto_out;
+
+	rlocn = mdah->raw_locns;
+
+	/*
+	 * The device area includes the metadata header as well as the
+	 * records, so remove the metadata header from the start and size
+	 */
+	area_start = area->start + MDA_HEADER_SIZE;
+	area_size = area->size - MDA_HEADER_SIZE;
+	latest_mrec_offset = rlocn->offset + area->start;
+
+	/*
+	 * Start searching at rlocn (point of live metadata) and go
+	 * backwards.
+	 */
+	prev_sector = _get_prev_sector_circular(area_start, area_size,
+					       latest_mrec_offset);
+	offset = prev_sector;
+	size = SECTOR_SIZE;
+	offset2 = size2 = 0;
+	i = 0;
+	while (prev_sector != latest_mrec_offset) {
+		prev_sector = _get_prev_sector_circular(area_start, area_size,
+							prev_sector);
+		/*
+		 * FIXME: for some reason, the whole metadata region from
+		 * area->start to area->start+area->size is not used.
+		 * Only ~32KB seems to contain valid metadata records
+		 * (LVM2 format - format_text).  As a result, I end up with
+		 * "maybe_config_section" returning true when there's no valid
+		 * metadata in a sector (sectors with all nulls).
+		 */
+		if (!(buf = dm_pool_alloc(fmt->cmd->mem, size + size2)))
+			goto_out;
+
+		if (!dev_read_circular(area->dev, offset, size,
+				       offset2, size2, buf))
+			goto_out;
+
+		/*
+		 * FIXME: We could add more sophisticated metadata detection
+		 */
+		if (maybe_config_section(buf, size+size2)) {
+			/* FIXME: Validate region, pull out timestamp?, etc */
+			/* FIXME: Do something with this region */
+			log_verbose ("Found LVM2 metadata record at "
+				     "offset=%"PRIu64", size=%"PRIu64", "
+				     "offset2=%"PRIu64" size2=%"PRIu64,
+				     offset, size, offset2, size2);
+			offset = prev_sector;
+			size = SECTOR_SIZE;
+			offset2 = size2 = 0;
+		} else {
+			/*
+			 * Not a complete metadata record, assume we have
+			 * metadata and just increase the size and offset.
+			 * Start the second region if the previous sector is
+			 * wrapping around towards the end of the disk.
+			 */
+			if (prev_sector > offset) {
+				offset2 = prev_sector;
+				size2 += SECTOR_SIZE;
+			} else {
+				offset = prev_sector;
+				size += SECTOR_SIZE;
+			}
+		}
+		dm_pool_free(fmt->cmd->mem, buf);
+		buf = NULL;
+	}
+
+	r = 1;
+ out:
+	if (buf)
+		dm_pool_free(fmt->cmd->mem, buf);
+	if (!dev_close(area->dev))
+		stack;
+	return r;
+}
+
+
+
 static int _text_lv_setup(struct format_instance *fid __attribute((unused)),
 			  struct logical_volume *lv)
 {
@@ -1413,6 +1558,7 @@
 	.vg_commit = _vg_commit_raw,
 	.vg_revert = _vg_revert_raw,
 	.mda_in_vg = _mda_in_vg_raw,
+	.pv_analyze_mda = _pv_analyze_mda_raw,
 };
 
 /* pvmetadatasize in sectors */
--- LVM2/lib/metadata/metadata.c	2007/04/25 20:03:15	1.106
+++ LVM2/lib/metadata/metadata.c	2007/04/25 21:10:55	1.107
@@ -1565,6 +1565,8 @@
 {
 	struct label *label;
 	struct device *dev;
+	struct metadata_area *mda;
+	struct lvmcache_info *info;
 
 	dev = dev_cache_get(pv_name, cmd->filter);
 	if (!dev) {
@@ -1585,5 +1587,12 @@
 	log_print("Found label on %s, sector %"PRIu64", type=%s",
 		  pv_name, label->sector, label->type);
 
+	/*
+	 * Next, loop through metadata areas
+	 */
+	info = label->info;
+	list_iterate_items(mda, &info->mdas)
+		mda->ops->pv_analyze_mda(info->fmt, mda);
+
 	return 1;
 }
--- LVM2/lib/metadata/metadata.h	2007/04/25 20:03:15	1.155
+++ LVM2/lib/metadata/metadata.h	2007/04/25 21:10:55	1.156
@@ -183,6 +183,12 @@
 	 */
 	int (*mda_in_vg) (struct format_instance * fi,
 			    struct volume_group * vg, struct metadata_area *mda);
+	/*
+	 * Analyze a metadata area on a PV.
+	 */
+	int (*pv_analyze_mda) (const struct format_type * fmt,
+			       struct metadata_area *mda);
+
 };
 
 struct metadata_area {


