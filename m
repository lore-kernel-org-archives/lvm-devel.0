From: David Teigland <teigland@sourceware.org>
Date: Fri, 12 Jul 2019 16:04:14 -0400
Subject: master - metadata: extend writes to zero space
Message-ID: <201907122004.x6CK4E9t029236@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c22ad12bab1cff6fa4c23cb0242650751716803e
Commit:        c22ad12bab1cff6fa4c23cb0242650751716803e
Parent:        76573137404dafa58795995f5c10dfb5dbc714de
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 1 15:00:34 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 12 15:00:12 2019 -0500

metadata: extend writes to zero space

Previously, consecutive copies of metadata would have garbage
data in the space between them.  After metadata wrapping,
the garbage would be portions of old metadata.  This made
analysis of the metadata area more difficult.

This would happen because the start of new copy of metadata
is advanced from the end of the last copy to start at the
next 512 byte boundary.

Zero the space between consecutive copies of metadata by
extending each metadata write to end at the next 512 byte
boundary.  The size of the metadata itself is not extended,
only the write.  The buffer being written contains the
metadata text followed by the necessary number of zeros.
---
 lib/format_text/export.c        |   10 +-
 lib/format_text/format-text.c   |  303 ++++++++++++++++++++++++++++++---------
 lib/format_text/import-export.h |    2 +-
 3 files changed, 244 insertions(+), 71 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 2a3f844..b5e987e 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -129,6 +129,7 @@ static int _extend_buffer(struct formatter *f)
 		log_error("Buffer reallocation failed.");
 		return 0;
 	}
+	memset(newbuf + f->data.buf.size, 0, f->data.buf.size);
 	f->data.buf.start = newbuf;
 	f->data.buf.size *= 2;
 
@@ -1052,7 +1053,7 @@ int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp)
 }
 
 /* Returns amount of buffer used incl. terminating NUL */
-size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
+size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf, uint32_t *buf_size)
 {
 	struct formatter *f;
 	size_t r = 0;
@@ -1063,7 +1064,7 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 		return_0;
 
 	f->data.buf.size = 65536;	/* Initial metadata limit */
-	if (!(f->data.buf.start = malloc(f->data.buf.size))) {
+	if (!(f->data.buf.start = zalloc(f->data.buf.size))) {
 		log_error("text_export buffer allocation failed");
 		goto out;
 	}
@@ -1081,6 +1082,9 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 	r = f->data.buf.used + 1;
 	*buf = f->data.buf.start;
 
+	if (buf_size)
+		*buf_size = f->data.buf.size;
+
       out:
 	free(f);
 	return r;
@@ -1088,7 +1092,7 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 
 static size_t _export_vg_to_buffer(struct volume_group *vg, char **buf)
 {
-	return text_vg_export_raw(vg, "", buf);
+	return text_vg_export_raw(vg, "", buf, NULL);
 }
 
 struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6873f19..2a5c8ec 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -38,8 +38,9 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 							  const struct format_instance_ctx *fic);
 
 struct text_fid_context {
-	char *raw_metadata_buf;
-	uint32_t raw_metadata_buf_size;
+	char *write_buf;         /* buffer containing metadata text to write to disk */
+	uint32_t write_buf_size; /* mem size of write_buf, increases in 64K multiples */
+	uint32_t new_metadata_size; /* size of text metadata in buf */
 };
 
 int rlocn_is_ignored(const struct raw_locn *rlocn)
@@ -349,19 +350,25 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 /*
  * Determine offset for new metadata
  *
- * FIXME: The rounding can have a negative effect: when the current metadata
+ * The rounding can have a negative effect: when the current metadata
  * text size is just below the max, a command to remove something, that
  * *reduces* the text metadata size, can still be rejected for being too large,
  * even though it's smaller than the current size.  In this case, the user
  * would need to find something in the VG to remove that uses more text space
  * to compensate for the increase due to rounding.
+ * Update: I think that the new max_size restriction avoids this problem.
  */
 
-static uint64_t _next_rlocn_offset(struct raw_locn *rlocn_old, uint64_t old_last, struct mda_header *mdah, uint64_t mdac_area_start, uint64_t alignment)
+static uint64_t _next_rlocn_offset(struct volume_group *vg, struct raw_locn *rlocn_old, uint64_t old_last, struct mda_header *mdah, uint64_t mdac_area_start, uint64_t alignment)
 {
 	uint64_t next_start;
 	uint64_t new_start;
-	uint64_t adjust;
+	uint64_t adjust = 0;
+
+	/* This has only been designed to work with 512. */
+	if (alignment != 512)
+		log_warn("WARNING: metadata alignment should be 512 not %llu",
+			 (unsigned long long)alignment);
 
 	/*
 	 * No metadata has been written yet, begin at MDA_HEADER_SIZE offset
@@ -375,7 +382,8 @@ static uint64_t _next_rlocn_offset(struct raw_locn *rlocn_old, uint64_t old_last
 	 * metadata area, then start at beginning.
 	 */
 	if (mdah->size - old_last < alignment) {
-		log_debug_metadata("new metadata offset adjusted from %llu to beginning %u",
+		log_debug_metadata("VG %s %u new metadata start align from %llu to beginning %u",
+				   vg->name, vg->seqno,
 				   (unsigned long long)(old_last + 1), MDA_HEADER_SIZE);
 		return MDA_HEADER_SIZE;
 	}
@@ -386,22 +394,24 @@ static uint64_t _next_rlocn_offset(struct raw_locn *rlocn_old, uint64_t old_last
 
 	next_start = old_last + 1;
 
-	adjust = alignment - (next_start % alignment);
+	if (next_start % alignment)
+		adjust = alignment - (next_start % alignment);
 
 	new_start = next_start + adjust;
 
-	log_debug_metadata("new metadata offset adjusted from %llu to %llu (+%llu) for alignment %llu",
+	log_debug_metadata("VG %s %u new metadata start align from %llu to %llu (+%llu)",
+			   vg->name, vg->seqno,
 			   (unsigned long long)next_start,
 			   (unsigned long long)new_start,
-			   (unsigned long long)adjust,
-			   (unsigned long long)alignment);
+			   (unsigned long long)adjust);
 
 	/*
 	 * If new_start is beyond the end of the metadata area or within
 	 * alignment bytes of the end, then start at the beginning.
 	 */
 	if (new_start > mdah->size - alignment) {
-		log_debug_metadata("new metadata offset adjusted from %llu to beginning %u",
+		log_debug_metadata("VG %s %u new metadata start align from %llu to beginning %u",
+				   vg->name, vg->seqno,
 				   (unsigned long long)new_start, MDA_HEADER_SIZE);
 		return MDA_HEADER_SIZE;
 	}
@@ -566,15 +576,43 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	struct raw_locn *rlocn_new;
 	struct mda_header *mdah;
 	struct pv_list *pvl;
+	uint64_t mda_start = mdac->area.start;
+	uint64_t max_size;
 	uint64_t old_start = 0, old_last = 0, old_size = 0, old_wrap = 0;
 	uint64_t new_start = 0, new_last = 0, new_size = 0, new_wrap = 0;
-	uint64_t max_size;
+	uint64_t write1_start = 0, write1_last = 0, write1_size = 0;
+	uint64_t write2_start = 0, write2_last = 0, write2_size = 0;
+	uint32_t write1_over = 0, write2_over = 0;
+	uint32_t write_buf_size;
+	uint32_t extra_size;
 	uint32_t bad_fields = 0;
-	char *new_buf = NULL;
-	int overlap;
+	char *write_buf = NULL;
+	const char *devname = dev_name(mdac->area.dev);
+	bool overlap;
 	int found = 0;
 	int r = 0;
 
+	/*
+	 * old_start/old_last/new_start/new_last are relative to the
+	 * start of the metadata area (mda_start), and specify the first
+	 * and last bytes of old/new metadata copies in the metadata area.
+	 *
+	 * write1_start/write1_last/write2_start/write2_last are
+	 * relative to the start of the disk, and specify the
+	 * first/last bytes written to disk when writing a new
+	 * copy of metadata.  (Will generally be larger than the
+	 * size of the metadata since the write is extended past
+	 * the end of the new metadata to end on a 512 byte boundary.)
+	 *
+	 * So, write1_start == mda_start + new_start.
+	 *
+	 * "last" values are inclusive, so last - start + 1 = size.
+	 * old_last/new_last are the last bytes containing metadata.
+	 * write1_last/write2_last are the last bytes written.
+	 * The next copy of metadata will be written beginning at
+	 * write1_last+1.
+	 */
+
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->dev == mdac->area.dev) {
@@ -592,25 +630,39 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	 * Create a text metadata representation of struct vg in buffer.
 	 * This buffer is written to disk below.  This function is called
 	 * to write metadata to each device/mda in the VG.  The first time
-	 * the metadata text is saved in raw_metadata_buf and subsequent
+	 * the metadata text is saved in write_buf and subsequent
 	 * mdas use that.
+	 *
+	 * write_buf_size is increased in 64K increments, so will generally
+	 * be larger than new_size.  The extra space in write_buf (after
+	 * new_size) is zeroed.  More than new_size can be written from
+	 * write_buf to zero data on disk following the new text metadata,
+	 * up to the next 512 byte boundary.
 	 */
-	if (fidtc->raw_metadata_buf) {
-		new_buf = fidtc->raw_metadata_buf;
-		new_size = fidtc->raw_metadata_buf_size;
+	if (fidtc->write_buf) {
+		write_buf = fidtc->write_buf;
+		write_buf_size = fidtc->write_buf_size;
+		new_size = fidtc->new_metadata_size;
 	} else {
 		char *desc = _build_desc_write(fid->fmt->cmd, vg);
-		new_size = text_vg_export_raw(vg, desc, &new_buf);
-		fidtc->raw_metadata_buf = new_buf;
-		fidtc->raw_metadata_buf_size = new_size;
+		new_size = text_vg_export_raw(vg, desc, &write_buf, &write_buf_size);
+		fidtc->write_buf = write_buf;
+		fidtc->write_buf_size = write_buf_size;
+		fidtc->new_metadata_size = new_size;
 		free(desc);
 	}
 
-	if (!new_size || !new_buf) {
+	if (!new_size || !write_buf) {
 		log_error("VG %s metadata writing failed", vg->name);
 		goto out;
 	}
 
+	log_debug_metadata("VG %s seqno %u metadata write to %s mda_start %llu mda_size %llu mda_last %llu",
+			   vg->name, vg->seqno, devname,
+			   (unsigned long long)mda_start,
+			   (unsigned long long)mdah->size,
+			   (unsigned long long)(mda_start + mdah->size - 1));
+
 	/*
 	 * The max size of a single copy of text metadata.
 	 *
@@ -624,9 +676,8 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	max_size = ((mdah->size - MDA_HEADER_SIZE) / 2) - 512;
 
 	if (new_size > max_size) {
-		log_error("VG %s metadata on %s (%llu bytes) exceeds maximum metadata size (%llu bytes)",
-			  vg->name,
-			  dev_name(mdac->area.dev),
+		log_error("VG %s %u metadata on %s (%llu bytes) exceeds maximum metadata size (%llu bytes)",
+			  vg->name, vg->seqno, devname,
 			  (unsigned long long)new_size,
 			  (unsigned long long)max_size);
 		goto out;
@@ -636,7 +687,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	 * rlocn_old is the current, committed, raw_locn data in slot0 on disk.
 	 *
 	 * rlocn_new (mdac->rlocn) is the new, in-memory, raw_locn data for the
-	 * new metadata.  It is in-memory only, not yet written to disk.
+	 * new metadata.  rlocn_new is in-memory only, not yet written to disk.
 	 *
 	 * rlocn_new is not written to disk by vg_write.  vg_write only writes
 	 * the new text metadata into the circular buffer, it does not update any
@@ -645,7 +696,8 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	 * vg_precommit and vg_commit can find it later and write it to disk.
 	 *
 	 * rlocn/raw_locn values, old_start, old_last, old_size, new_start,
-	 * new_last, new_size, are all in bytes.
+	 * new_last, new_size, are all in bytes, and are all relative to the
+	 * the start of the metadata area (not to the start of the disk.)
 	 *
 	 * The start and last values are the first and last bytes that hold
 	 * the metadata inclusively, e.g.
@@ -659,6 +711,10 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	 * after which the circular buffer of text metadata begins.
 	 * So, the when the text metadata wraps around, it starts again at
 	 * area.start + MDA_HEADER_SIZE.
+	 *
+	 * When pe_start is at 1MB (the default), and mda_start is at 4KB,
+	 * there will be 1MB - 4KB - 512 bytes of circular buffer space for
+	 * text metadata.
 	 */
 
 	rlocn_old = &mdah->raw_locns[0];  /* slot0, committed metadata */
@@ -691,11 +747,18 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	 * area, then the new start is set back at the beginning
 	 * (metadata begins MDA_HEADER_SIZE after start of metadata area).
 	 */
-	new_start = _next_rlocn_offset(rlocn_old, old_last, mdah, mdac->area.start, MDA_ORIGINAL_ALIGNMENT);
+	new_start = _next_rlocn_offset(vg, rlocn_old, old_last, mdah, mda_start, MDA_ORIGINAL_ALIGNMENT);
 
 	if (new_start + new_size > mdah->size) {
 		new_wrap = (new_start + new_size) - mdah->size;
 		new_last = new_wrap + MDA_HEADER_SIZE - 1;
+
+		log_debug_metadata("VG %s %u wrapping metadata new_start %llu new_size %llu to size1 %llu size2 %llu",
+				   vg->name, vg->seqno,
+				   (unsigned long long)new_start,
+				   (unsigned long long)new_size,
+				   (unsigned long long)(new_size - new_wrap),
+				   (unsigned long long)new_wrap);
 	} else {
 		new_wrap = 0;
 		new_last = new_start + new_size - 1;
@@ -709,21 +772,20 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	rlocn_new->offset = new_start;
 	rlocn_new->size = new_size;
 
-	log_debug_metadata("VG %s metadata offsets: old start %llu last %llu size %llu wrap %llu",
-			   vg->name,
+	log_debug_metadata("VG %s %u metadata area location old start %llu last %llu size %llu wrap %llu",
+			   vg->name, vg->seqno,
 			   (unsigned long long)old_start,
 			   (unsigned long long)old_last,
 			   (unsigned long long)old_size,
 			   (unsigned long long)old_wrap);
 
-	log_debug_metadata("VG %s metadata offsets: new start %llu last %llu size %llu wrap %llu",
-			   vg->name,
+	log_debug_metadata("VG %s %u metadata area location new start %llu last %llu size %llu wrap %llu",
+			   vg->name, vg->seqno,
 			   (unsigned long long)new_start,
 			   (unsigned long long)new_last,
 			   (unsigned long long)new_size,
 			   (unsigned long long)new_wrap);
 
-
 	/*
 	 * If the new copy of the metadata would overlap the old copy of the
 	 * metadata, it means that the circular metadata buffer is full.
@@ -739,19 +801,19 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (new_wrap && old_wrap) {
 
 		/* old and new can't both wrap without overlapping */
-		overlap = 1;
+		overlap = true;
 
 	} else if (!new_wrap && !old_wrap &&
 		(new_start > old_last) && (new_last > new_start)) {
 
 		/* new metadata is located entirely after the old metadata */
-		overlap = 0;
+		overlap = false;
 
 	} else if (!new_wrap && !old_wrap &&
 		(new_start < old_start) && (new_last < old_start)) {
 
 		/* new metadata is located entirely before the old metadata */
-		overlap = 0;
+		overlap = false;
 
 	} else if (old_wrap && !new_wrap &&
 		(old_last < new_start) && (new_start < new_last) && (new_last < old_start)) {
@@ -759,7 +821,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		/* when old wraps and the new doesn't, then no overlap is:
 		   old_last followed by new_start followed by new_last
 		   followed by old_start */
-		overlap = 0;
+		overlap = false;
 
 	} else if (new_wrap && !old_wrap &&
 		(new_last < old_start) && (old_start < old_last) && (old_last < new_start)) {
@@ -767,46 +829,150 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		/* when new wraps and the old doesn't, then no overlap is:
 		   new_last followed by old_start followed by old_last
 		   followed by new_start. */
-		overlap = 0;
+		overlap = false;
 
 	} else {
-		overlap = 1;
+		overlap = true;
 	}
 
 	if (overlap) {
-		log_error("VG %s metadata on %s (%llu bytes) too large for circular buffer (%llu bytes with %llu used)",
-			  vg->name,
-			  dev_name(mdac->area.dev),
+		log_error("VG %s %u metadata on %s (%llu bytes) too large for circular buffer (%llu bytes with %llu used)",
+			  vg->name, vg->seqno, devname,
 			  (unsigned long long)new_size,
 			  (unsigned long long)(mdah->size - MDA_HEADER_SIZE),
 			  (unsigned long long)old_size);
 		goto out;
 	}
 
-	log_debug_metadata("VG %s metadata write to %s at %llu len %llu (wrap %llu)", 
-			    vg->name, dev_name(mdac->area.dev),
-			    (unsigned long long)(mdac->area.start + rlocn_new->offset),
-			    (unsigned long long)(rlocn_new->size - new_wrap),
-			    (unsigned long long)new_wrap);
+	if (!new_wrap) {
+		write1_start = mda_start + new_start;
+		write1_size = new_size;
+		write1_last = write1_start + write1_size - 1;
+		write1_over = (write1_last + 1) % 512;
+		write2_start = 0;
+		write2_size = 0;
+		write2_last = 0;
+		write2_over = 0;
+	} else {
+		write1_start = mda_start + new_start;
+		write1_size = new_size - new_wrap;
+		write1_last = write1_start + write1_size - 1;
+		write1_over = 0;
+		write2_start = mda_start + MDA_HEADER_SIZE;
+		write2_size = new_wrap;
+		write2_last = write2_start + write2_size - 1;
+		write2_over = (write2_last + 1) % 512;
+	}
+
+	if (!new_wrap)
+		log_debug_metadata("VG %s %u metadata disk location start %llu size %llu last %llu",
+			  vg->name, vg->seqno,
+			  (unsigned long long)write1_start,
+			  (unsigned long long)write1_size,
+			  (unsigned long long)write1_last);
+	else
+		log_debug_metadata("VG %s %u metadata disk location write1 start %llu size %llu last %llu write2 start %llu size %llu last %llu",
+			  vg->name, vg->seqno,
+			  (unsigned long long)write1_start,
+			  (unsigned long long)write1_size,
+			  (unsigned long long)write1_last,
+			  (unsigned long long)write2_start,
+			  (unsigned long long)write2_size,
+			  (unsigned long long)write2_last);
+
+	/*
+	 * Write more than the size of the new metadata, up to the next
+	 * 512 byte boundary so that the space between this copy and the
+	 * subsequent copy of metadata will be zeroed.
+	 *
+	 * Extend write1_size so that write1_last+1 is a 512 byte multiple.
+	 * The next metadata write should follow immediately after the
+	 * extended write1_last since new metadata tries to begin on a 512
+	 * byte boundary.
+	 *
+	 * write1_size can be extended up to write_buf_size which is the size
+	 * of write_buf (new_size is the portion of write_buf used by the new
+	 * metadata.)
+	 *
+	 * If this metadata write will wrap, the first write is written
+	 * all the way to the end of the metadata area, and it's the
+	 * second wrapped write that is extended up to a 512 byte boundary.
+	 */
+
+	if (write1_over) {
+		extra_size = 512 - write1_over; /* this many extra zero bytes written after metadata text */
+		write1_size += extra_size;
+		write1_last = write1_start + write1_size - 1;
+
+		log_debug_metadata("VG %s %u metadata last align from %llu to %llu (+%u)",
+				   vg->name, vg->seqno,
+				   (unsigned long long)write1_last - extra_size,
+				   (unsigned long long)write1_last, extra_size);
+		  
+		if (write1_size > write_buf_size) {
+			/* sanity check, shouldn't happen */
+			log_error("VG %s %u %s adjusted metadata end %llu extra %u larger than write buffer %llu",
+				  vg->name, vg->seqno, devname,
+				  (unsigned long long)write1_size, extra_size,
+				  (unsigned long long)write_buf_size);
+			write1_size -= extra_size;
+		}
+	}
+
+	if (write2_over) {
+		extra_size = 512 - write2_over; /* this many extra zero bytes written after metadata text */
+		write2_size += extra_size; 
+		write2_last = write2_start + write2_size - 1;
+
+		log_debug_metadata("VG %s %u metadata last align from %llu to %llu (+%u) (wrapped)",
+				   vg->name, vg->seqno,
+				   (unsigned long long)write2_last - extra_size,
+				   (unsigned long long)write2_last, extra_size);
+
+		if (write1_size + write2_size > write_buf_size) {
+			/* sanity check, shouldn't happen */
+			log_error("VG %s %u %s adjusted metadata end %llu wrap %llu extra %u larger than write buffer %llu",
+				  vg->name, vg->seqno, devname,
+				  (unsigned long long)write1_size,
+				  (unsigned long long)write2_size, extra_size,
+				  (unsigned long long)write_buf_size);
+			write2_size -= extra_size;
+		}
+	}
+
+	if ((write1_size > write_buf_size) ||  (write2_size > write_buf_size)) {
+		/* sanity check, shouldn't happen */
+		log_error("VG %s %u %s metadata write size %llu %llu larger than buffer %llu",
+			  vg->name, vg->seqno, devname,
+			  (unsigned long long)write1_size,
+			  (unsigned long long)write2_size,
+			  (unsigned long long)write_buf_size);
+		goto out;
+	}
+
+	dev_set_last_byte(mdac->area.dev, mda_start + mdah->size);
 
-	dev_set_last_byte(mdac->area.dev, mdac->area.start + mdah->size);
+	log_debug_metadata("VG %s %u metadata write at %llu size %llu (wrap %llu)", 
+			   vg->name, vg->seqno,
+			   (unsigned long long)write1_start,
+			   (unsigned long long)write1_size,
+			   (unsigned long long)write2_size);
 
-	if (!dev_write_bytes(mdac->area.dev, mdac->area.start + rlocn_new->offset,
-		                (size_t) (rlocn_new->size - new_wrap), new_buf)) {
-		log_error("Failed to write metadata to %s fd %d", dev_name(mdac->area.dev), mdac->area.dev->bcache_fd);
+	if (!dev_write_bytes(mdac->area.dev, write1_start, (size_t)write1_size, write_buf)) {
+		log_error("Failed to write metadata to %s fd %d", devname, mdac->area.dev->bcache_fd);
 		dev_unset_last_byte(mdac->area.dev);
 		goto out;
 	}
 
-	if (new_wrap) {
-		log_debug_metadata("VG %s metadata write to %s at %llu len %llu (wrapped)",
-				   vg->name, dev_name(mdac->area.dev),
-				   (unsigned long long)(mdac->area.start + MDA_HEADER_SIZE),
-				   (unsigned long long)new_wrap);
+	if (write2_size) {
+		log_debug_metadata("VG %s %u metadata write at %llu size %llu (wrapped)",
+				   vg->name, vg->seqno,
+				   (unsigned long long)write2_start,
+				   (unsigned long long)write2_size);
 
-		if (!dev_write_bytes(mdac->area.dev, mdac->area.start + MDA_HEADER_SIZE,
-			                (size_t) new_wrap, new_buf + rlocn_new->size - new_wrap)) {
-			log_error("Failed to write metadata wrap to %s fd %d", dev_name(mdac->area.dev), mdac->area.dev->bcache_fd);
+		if (!dev_write_bytes(mdac->area.dev, write2_start, write2_size,
+				     write_buf + new_size - new_wrap)) {
+			log_error("Failed to write metadata wrap to %s fd %d", devname, mdac->area.dev->bcache_fd);
 			dev_unset_last_byte(mdac->area.dev);
 			goto out;
 		}
@@ -815,20 +981,21 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	dev_unset_last_byte(mdac->area.dev);
 
 	rlocn_new->checksum = calc_crc(INITIAL_CRC,
-				       (uint8_t *)new_buf,
-				       (uint32_t)(rlocn_new->size - new_wrap));
+				       (uint8_t *)write_buf,
+				       (uint32_t)(new_size - new_wrap));
 	if (new_wrap)
 		rlocn_new->checksum = calc_crc(rlocn_new->checksum,
-					(uint8_t *)new_buf + rlocn_new->size - new_wrap,
+					(uint8_t *)write_buf + new_size - new_wrap,
 					(uint32_t)new_wrap);
 
 	r = 1;
 
       out:
 	if (!r) {
-		free(fidtc->raw_metadata_buf);
-		fidtc->raw_metadata_buf = NULL;
-		fidtc->raw_metadata_buf_size = 0;
+		free(fidtc->write_buf);
+		fidtc->write_buf = NULL;
+		fidtc->write_buf_size = 0;
+		fidtc->new_metadata_size = 0;
 	}
 
 	return r;
@@ -1015,8 +1182,10 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 
       out:
 	if (!precommit) {
-		free(fidtc->raw_metadata_buf);
-		fidtc->raw_metadata_buf = NULL;
+		free(fidtc->write_buf);
+		fidtc->write_buf = NULL;
+		fidtc->write_buf_size = 0;
+		fidtc->new_metadata_size = 0;
 	}
 
 	return r;
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index b7a8fa6..0bfc60b 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -66,7 +66,7 @@ int print_segtype_lvflags(char *buffer, size_t size, uint64_t status);
 int read_segtype_lvflags(uint64_t *status, char *segtype_str);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
-size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
+size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf, uint32_t *alloc_size);
 struct volume_group *text_read_metadata_file(struct format_instance *fid,
 					 const char *file,
 					 time_t *when, char **desc);


