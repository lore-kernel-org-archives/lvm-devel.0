From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Sep 2018 14:55:52 -0400
Subject: master - metadata: improve write and commit code
Message-ID: <201809111855.w8BItqfK019928@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5fb15b19349af607654f2429850a706bbac4b792
Commit:        5fb15b19349af607654f2429850a706bbac4b792
Parent:        3832329a6b6a6430c84ea1aaacf17fb122a57b2a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 30 10:44:53 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 11 10:06:25 2018 -0500

metadata: improve write and commit code

The vg_write/vg_commit code was imprecise, uncommented, and
hard to understand.  Rewrite it with clearer, cleaner code,
extensive comments, descriptions of how it works, and add
more info in debugging output.

The minor changes in behavior are to things that were
either incorrect or probably unintended:

- vg_write/vg_commit no longer check that the current vgname at
  the start of the text metadata matches the vgname being written.
  This has already been done at least twice by the time they are
  called, and repeating it again against the same cached data has
  no use.

- A fragment of old removed code had been left behind that checked
  if the old unused alignment policy would wrap.  It was still
  being checked to decide if the metadata area was full, which
  could possibly cause an incorrect full metadata failure.

- vg_remove now clears both the raw_locns in the mda_header that
  point to committed metadata (raw_locn slot 0) and precommitted
  metadata (raw_locn slot 1).  Previously it fully cleared the
  committed slot, and would only clear the offset field in the
  precommitted slot if it saw a problem with the metadata in the
  vg being removed.

- read_metadata_location_summary was wrongly comparing the number
  of wrapped bytes with an offset to report an error about the
  metadata being too large.  This wrong check is removed, it
  could have resulted in erroneous errors.
---
 lib/format_text/format-text.c |  605 +++++++++++++++++++++++++++++++----------
 1 files changed, 465 insertions(+), 140 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c7544aa..7857091 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -427,8 +427,21 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	if (*precommitted && rlocn_precommitted->size &&
 	    (rlocn_precommitted->offset != rlocn->offset)) {
 		rlocn = rlocn_precommitted;
-	} else
+		log_debug_metadata("VG %s metadata check %s mda %llu slot1 offset %llu size %llu",
+				   vgname ?: "",
+				   dev_name(dev_area->dev),
+				   (unsigned long long)dev_area->start,
+				   (unsigned long long)rlocn->offset,
+				   (unsigned long long)rlocn->size);
+	} else {
 		*precommitted = 0;
+		log_debug_metadata("VG %s metadata check %s mda %llu slot0 offset %llu size %llu",
+				   vgname ?: "",
+				   dev_name(dev_area->dev),
+				   (unsigned long long)dev_area->start,
+				   (unsigned long long)rlocn->offset,
+				   (unsigned long long)rlocn->size);
+	}
 
 	/* Do not check non-existent metadata. */
 	if (!rlocn->offset && !rlocn->size)
@@ -472,26 +485,58 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 }
 
 /*
- * Determine offset for uncommitted metadata
+ * Determine offset for new metadata
  */
-static uint64_t _next_rlocn_offset(struct raw_locn *rlocn, struct mda_header *mdah, uint64_t mdac_area_start, uint64_t alignment)
+static uint64_t _next_rlocn_offset(struct raw_locn *rlocn_old, uint64_t old_last, struct mda_header *mdah, uint64_t mdac_area_start, uint64_t alignment)
 {
-	uint64_t new_start_offset;
+	uint64_t next_start;
+	uint64_t new_start;
+	uint64_t adjust;
 
-	if (!rlocn)
-		/* Find an empty slot */
-		/* FIXME Assume only one VG per mdah for now */
-		return alignment;
+	/*
+	 * No metadata has been written yet, begin at MDA_HEADER_SIZE offset
+	 * from the start of the area.
+	 */
+	if (!rlocn_old)
+		return MDA_HEADER_SIZE;
 
-	/* Calculate new start position within buffer rounded up to absolute alignment */
-	new_start_offset = rlocn->offset + rlocn->size +
-			   (alignment - (mdac_area_start + rlocn->offset + rlocn->size) % alignment);
+	/*
+	 * If new start would be less than alignment bytes from the end of the
+	 * metadata area, then start at beginning.
+	 */
+	if (mdah->size - old_last < alignment) {
+		log_debug_metadata("new metadata offset adjusted from %llu to beginning %u",
+				   (unsigned long long)(old_last + 1), MDA_HEADER_SIZE);
+		return MDA_HEADER_SIZE;
+	}
 
-	/* If new location is beyond the end of the buffer, wrap around back to start of circular buffer */
-	if (new_start_offset > mdah->size - MDA_HEADER_SIZE)
-		new_start_offset -= (mdah->size - MDA_HEADER_SIZE);
+	/*
+	 * New metadata begins after the old, rounded up to alignment.
+	 */
+
+	next_start = old_last + 1;
+
+	adjust = alignment - (next_start % alignment);
+
+	new_start = next_start + adjust;
+
+	log_debug_metadata("new metadata offset adjusted from %llu to %llu (+%llu) for alignment %llu",
+			   (unsigned long long)next_start,
+			   (unsigned long long)new_start,
+			   (unsigned long long)adjust,
+			   (unsigned long long)alignment);
+
+	/*
+	 * If new_start is beyond the end of the metadata area or within
+	 * alignment bytes of the end, then start at the beginning.
+	 */
+	if (new_start > mdah->size - alignment) {
+		log_debug_metadata("new metadata offset adjusted from %llu to beginning %u",
+				   (unsigned long long)new_start, MDA_HEADER_SIZE);
+		return MDA_HEADER_SIZE;
+	}
 
-	return new_start_offset;
+	return new_start;
 }
 
 static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
@@ -585,100 +630,273 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	return vg;
 }
 
+/*
+ * VG metadata updates:
+ *
+ * [mda_header] [raw_locn_0] [raw_locn_1] [text metadata circular buffer]
+ *
+ * raw_locn.offset points into the metadata circular buffer to the
+ * start of metadata.
+ *
+ * When vg_read wants to read metadata from disk, it looks at the
+ * raw_locn_0 offset and reads the text metadata from that location
+ * in the circular buffer.
+ *
+ * Two full copies of the text metadata always exist in the circular
+ * buffer.  When new metadata needs to be written, the following
+ * process is followed:
+ *
+ * - vg_write is called and writes the new text metadata into the
+ *   circular buffer after the end of the current copy.  vg_write saves
+ *   an in-memory raw_locn struct (mdac->rlocn) pointing to the new
+ *   metadata in the buffer.  No raw_locn structs are written to disk.
+ *
+ * - vg_precommit is called and writes the in-memory raw_locn struct that
+ *   was saved by vg_write into raw_locn_1 (slot 1, the "precommit" slot.)
+ *   raw_locn_0 still points to the old metadata, and raw_locn_1 points
+ *   to the new metadata.
+ *
+ * - vg_commit is called and writes the new raw_locn struct into raw_locn_0
+ *   (slot 0, the "committed" slot).
+ */
+
+/*
+ * Writes new text metadata into the circular metadata buffer following the
+ * current (old) text metadata that's already in the metadata buffer.
+ *
+ * vg_write does *not* write new raw_locn fields pointing to the new metadata.
+ * The new raw_locn fields for the new metadata are saved in mdac->rlocn and
+ * are written later by both vg_precommit and vg_commit.  vg_precommit will
+ * write the new raw_locn into slot 1 and vg_commit will write the new raw_locn
+ * into slot 0.
+ */
+
 static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			 struct metadata_area *mda)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct text_fid_context *fidtc = (struct text_fid_context *) fid->private;
-	struct raw_locn *rlocn;
+	struct raw_locn *rlocn_old;
+	struct raw_locn *rlocn_new;
 	struct mda_header *mdah;
 	struct pv_list *pvl;
-	int r = 0;
-	uint64_t new_wrap = 0, old_wrap = 0, new_end;
+	uint64_t old_start = 0, old_last = 0, old_size = 0, old_wrap = 0;
+	uint64_t new_start = 0, new_last = 0, new_size = 0, new_wrap = 0;
+	char *new_buf = NULL;
+	int overlap;
 	int found = 0;
-	int noprecommit = 0;
-	const char *old_vg_name = NULL;
+	int r = 0;
 
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->dev == mdac->area.dev) {
 			found = 1;
-			if (pvl->pv->status & PV_MOVED_VG)
-				old_vg_name = vg->old_name;
 			break;
 		}
 	}
-
 	if (!found)
 		return 1;
 
 	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
-	if (!fidtc->raw_metadata_buf &&
-	    !(fidtc->raw_metadata_buf_size =
-			text_vg_export_raw(vg, "", &fidtc->raw_metadata_buf))) {
+	/*
+	 * Create a text metadata representation of struct vg in buffer.
+	 * This buffer is written to disk below.  This function is called
+	 * to write metadata to each device/mda in the VG.  The first time
+	 * the metadata text is saved in raw_metadata_buf and subsequent
+	 * mdas use that.
+	 */
+	if (fidtc->raw_metadata_buf) {
+		new_buf = fidtc->raw_metadata_buf;
+		new_size = fidtc->raw_metadata_buf_size;
+	} else {
+		new_size = text_vg_export_raw(vg, "", &new_buf);
+		fidtc->raw_metadata_buf = new_buf;
+		fidtc->raw_metadata_buf_size = new_size;
+	}
+
+	if (!new_size || !new_buf) {
 		log_error("VG %s metadata writing failed", vg->name);
 		goto out;
 	}
 
-	rlocn = _read_metadata_location_vg(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit);
+	/*
+	 * rlocn_old is the current, committed, raw_locn data in slot0 on disk.
+	 *
+	 * rlocn_new (mdac->rlocn) is the new, in-memory, raw_locn data for the
+	 * new metadata.  It is in-memory only, not yet written to disk.
+	 *
+	 * rlocn_new is not written to disk by vg_write.  vg_write only writes
+	 * the new text metadata into the circular buffer, it does not update any
+	 * raw_locn slot to point to that new metadata.  vg_write saves raw_locn
+	 * values for the new metadata in memory at mdac->rlocn so that
+	 * vg_precommit and vg_commit can find it later and write it to disk.
+	 *
+	 * rlocn/raw_locn values, old_start, old_last, old_size, new_start,
+	 * new_last, new_size, are all in bytes.
+	 *
+	 * The start and last values are the first and last bytes that hold
+	 * the metadata inclusively, e.g.
+	 * metadata_v1 start = 512, last = 611, size = 100
+	 * metadata_v2 start = 612, last = 711, size = 100
+	 *
+	 * {old,new}_{start,last} values are all offset values from the
+	 * beginning of the metadata area mdac->area.start.  At the beginning
+	 * of the metadata area (area.start), the first 512 bytes
+	 * (MDA_HEADER_SIZE) is reserved for the mda_header/raw_locn structs,
+	 * after which the circular buffer of text metadata begins.
+	 * So, the when the text metadata wraps around, it starts again at
+	 * area.start + MDA_HEADER_SIZE.
+	 */
+
+	rlocn_old = &mdah->raw_locns[0];  /* slot0, committed metadata */
+
+	if (rlocn_is_ignored(rlocn_old))
+		rlocn_old = NULL;
+
+	else if (!rlocn_old->offset && !rlocn_old->size)
+		rlocn_old = NULL;
+
+	else {
+		old_start = rlocn_old->offset;
+		old_size = rlocn_old->size;
+
+		if (rlocn_old->offset + rlocn_old->size > mdah->size) {
+			old_wrap = (old_start + old_size) - mdah->size;
+			old_last = old_wrap + MDA_HEADER_SIZE - 1;
+		} else {
+			old_wrap = 0;
+			old_last = old_start + old_size - 1;
+		}
+	}
+
+	/*
+	 * _next_rlocn_offset returns the new offset to use for the new
+	 * metadata.  It is set to follow the end of the old metadata, plus
+	 * some adjustment to start the new metadata on a 512 byte alignment.
+	 * If the new metadata would start beyond the end of the metadata area,
+	 * or would start less than 512 bytes before the end of the metadata
+	 * area, then the new start is set back at the beginning
+	 * (metadata begins MDA_HEADER_SIZE after start of metadata area).
+	 */
+	new_start = _next_rlocn_offset(rlocn_old, old_last, mdah, mdac->area.start, MDA_ORIGINAL_ALIGNMENT);
+
+	if (new_start + new_size > mdah->size) {
+		new_wrap = (new_start + new_size) - mdah->size;
+		new_last = new_wrap + MDA_HEADER_SIZE - 1;
+	} else {
+		new_wrap = 0;
+		new_last = new_start + new_size - 1;
+	}
+
+	/*
+	 * Save the new metadata location in memory for vg_precommit and
+	 * vg_commit.  The new location is not written to disk here.
+	 */
+	rlocn_new = &mdac->rlocn;
+	rlocn_new->offset = new_start;
+	rlocn_new->size = new_size;
+
+	log_debug_metadata("VG %s metadata offsets: old start %llu last %llu size %llu wrap %llu",
+			   vg->name,
+			   (unsigned long long)old_start,
+			   (unsigned long long)old_last,
+			   (unsigned long long)old_size,
+			   (unsigned long long)old_wrap);
+
+	log_debug_metadata("VG %s metadata offsets: new start %llu last %llu size %llu wrap %llu",
+			   vg->name,
+			   (unsigned long long)new_start,
+			   (unsigned long long)new_last,
+			   (unsigned long long)new_size,
+			   (unsigned long long)new_wrap);
+
+
+	/*
+	 * If the new copy of the metadata would overlap the old copy of the
+	 * metadata, it means that the circular metadata buffer is full.
+	 */
+
+	if (new_wrap && old_wrap) {
+
+		/* old and new can't both wrap without overlapping */
+		overlap = 1;
 
-	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, MDA_ORIGINAL_ALIGNMENT);
-	mdac->rlocn.size = fidtc->raw_metadata_buf_size;
+	} else if (!new_wrap && !old_wrap &&
+		(new_start > old_last) && (new_last > new_start)) {
 
-	if (mdac->rlocn.offset + mdac->rlocn.size > mdah->size)
-		new_wrap = (mdac->rlocn.offset + mdac->rlocn.size) - mdah->size;
+		/* new metadata is located entirely after the old metadata */
+		overlap = 0;
 
-	if (rlocn && (rlocn->offset + rlocn->size > mdah->size))
-		old_wrap = (rlocn->offset + rlocn->size) - mdah->size;
+	} else if (!new_wrap && !old_wrap &&
+		(new_start < old_start) && (new_last < old_start)) {
 
-	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE :
-			    mdac->rlocn.offset + mdac->rlocn.size;
+		/* new metadata is located entirely before the old metadata */
+		overlap = 0;
 
-	if ((new_wrap && old_wrap) ||
-	    (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset)) ||
-	    (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)) {
-		log_error("VG %s metadata on %s (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes with " FMTu64 " used)",
-			  vg->name, dev_name(mdac->area.dev), mdac->rlocn.size, mdah->size - MDA_HEADER_SIZE, rlocn ? rlocn->size : 0);
+	} else if (old_wrap && !new_wrap &&
+		(old_last < new_start) && (new_start < new_last) && (new_last < old_start)) {
+
+		/* when old wraps and the new doesn't, then no overlap is:
+		   old_last followed by new_start followed by new_last
+		   followed by old_start */
+		overlap = 0;
+
+	} else if (new_wrap && !old_wrap &&
+		(new_last < old_start) && (old_start < old_last) && (old_last < new_start)) {
+
+		/* when new wraps and the old doesn't, then no overlap is:
+		   new_last followed by old_start followed by old_last
+		   followed by new_start. */
+		overlap = 0;
+
+	} else {
+		overlap = 1;
+	}
+
+	if (overlap) {
+		log_error("VG %s metadata on %s (%llu bytes) too large for circular buffer (%llu bytes with %llu used)",
+			  vg->name,
+			  dev_name(mdac->area.dev),
+			  (unsigned long long)new_size,
+			  (unsigned long long)(mdah->size - MDA_HEADER_SIZE),
+			  (unsigned long long)old_size);
 		goto out;
 	}
 
-	log_debug_metadata("Writing metadata for VG %s to %s at %llu len %llu (wrap %llu)", 
+	log_debug_metadata("VG %s metadata write to %s at %llu len %llu (wrap %llu)", 
 			    vg->name, dev_name(mdac->area.dev),
-			    (unsigned long long)(mdac->area.start + mdac->rlocn.offset),
-			    (unsigned long long)(mdac->rlocn.size - new_wrap),
+			    (unsigned long long)(mdac->area.start + rlocn_new->offset),
+			    (unsigned long long)(rlocn_new->size - new_wrap),
 			    (unsigned long long)new_wrap);
 
-	if (!dev_write_bytes(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
-		                (size_t) (mdac->rlocn.size - new_wrap),
-		                fidtc->raw_metadata_buf)) {
+	if (!dev_write_bytes(mdac->area.dev, mdac->area.start + rlocn_new->offset,
+		                (size_t) (rlocn_new->size - new_wrap), new_buf)) {
 		log_error("Failed to write metadata to %s fd %d", dev_name(mdac->area.dev), mdac->area.dev->bcache_fd);
 		goto out;
 	}
 
 	if (new_wrap) {
-		log_debug_metadata("Writing metadata for VG %s to %s at %llu len %llu (wrapped)",
+		log_debug_metadata("VG %s metadata write to %s at %llu len %llu (wrapped)",
 				   vg->name, dev_name(mdac->area.dev),
 				   (unsigned long long)(mdac->area.start + MDA_HEADER_SIZE),
 				   (unsigned long long)new_wrap);
 
 		if (!dev_write_bytes(mdac->area.dev, mdac->area.start + MDA_HEADER_SIZE,
-			                (size_t) new_wrap,
-			                fidtc->raw_metadata_buf + mdac->rlocn.size - new_wrap)) {
+			                (size_t) new_wrap, new_buf + rlocn_new->size - new_wrap)) {
 			log_error("Failed to write metadata wrap to %s fd %d", dev_name(mdac->area.dev), mdac->area.dev->bcache_fd);
 			goto out;
 		}
 	}
 
-	mdac->rlocn.checksum = calc_crc(INITIAL_CRC, (uint8_t *)fidtc->raw_metadata_buf,
-					(uint32_t) (mdac->rlocn.size -
-						    new_wrap));
+	rlocn_new->checksum = calc_crc(INITIAL_CRC,
+				       (uint8_t *)new_buf,
+				       (uint32_t)(rlocn_new->size - new_wrap));
 	if (new_wrap)
-		mdac->rlocn.checksum = calc_crc(mdac->rlocn.checksum,
-						(uint8_t *)fidtc->raw_metadata_buf +
-						mdac->rlocn.size -
-						new_wrap, (uint32_t) new_wrap);
+		rlocn_new->checksum = calc_crc(rlocn_new->checksum,
+					(uint8_t *)new_buf + rlocn_new->size - new_wrap,
+					(uint32_t)new_wrap);
 
 	r = 1;
 
@@ -686,11 +904,24 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!r) {
 		free(fidtc->raw_metadata_buf);
 		fidtc->raw_metadata_buf = NULL;
+		fidtc->raw_metadata_buf_size = 0;
 	}
 
 	return r;
 }
 
+/*
+ * Writes new raw_locn to disk that was saved by vg_write_raw (in mdac->rlocn).
+ * The new raw_locn points to the new metadata that was written by vg_write_raw.
+ *
+ * After vg_write writes the new text metadata into the circular buffer,
+ * vg_precommit writes the new raw_locn (pointing to the new metadata)
+ * into slot1 (raw_locns[1]).  Then vg_commit writes the same raw_locn
+ * values again, but into slot0 (raw_locns[0]).  slot0 is the committed
+ * slot, and once slot0 is written, subsequent vg_reads will see the new
+ * metadata.
+ */
+
 static int _vg_commit_raw_rlocn(struct format_instance *fid,
 				struct volume_group *vg,
 				struct metadata_area *mda,
@@ -698,80 +929,159 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct text_fid_context *fidtc = (struct text_fid_context *) fid->private;
-	struct mda_header *mdah;
-	struct raw_locn *rlocn;
+	struct mda_header *mdab;
+	struct raw_locn *rlocn_slot0;
+	struct raw_locn *rlocn_slot1;
+	struct raw_locn *rlocn_new;
 	struct pv_list *pvl;
 	int r = 0;
 	int found = 0;
-	int noprecommit = 0;
-	const char *old_vg_name = NULL;
 
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->dev == mdac->area.dev) {
 			found = 1;
-			if (pvl->pv->status & PV_MOVED_VG)
-				old_vg_name = vg->old_name;
 			break;
 		}
 	}
-
 	if (!found)
 		return 1;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
+	/*
+	 * Data is read into the mdab buffer, the mdab buffer is then modified
+	 * with new raw_locn values, then the mdab buffer is written.  Note
+	 * this is different than _vg_write_raw, where data is read into the
+	 * mdah buffer, but the mdah buffer is not modified and mdac->rlocn is
+	 * modified.
+	 */
+	if (!(mdab = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
-	if (!(rlocn = _read_metadata_location_vg(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit))) {
-		mdah->raw_locns[0].offset = 0;
-		mdah->raw_locns[0].size = 0;
-		mdah->raw_locns[0].checksum = 0;
-		mdah->raw_locns[1].offset = 0;
-		mdah->raw_locns[1].size = 0;
-		mdah->raw_locns[1].checksum = 0;
-		mdah->raw_locns[2].offset = 0;
-		mdah->raw_locns[2].size = 0;
-		mdah->raw_locns[2].checksum = 0;
-		rlocn = &mdah->raw_locns[0];
-	} else if (precommit && rlocn_is_ignored(rlocn) && !mda_is_ignored(mda)) {
+	/*
+	 * rlocn_slot0/rlocn_slot1 point into mdab which is the buffer that
+	 * will be modified and written.
+	 */
+	rlocn_slot0 = &mdab->raw_locns[0];
+	rlocn_slot1 = &mdab->raw_locns[1];
+
+	if (rlocn_is_ignored(rlocn_slot0) || (!rlocn_slot0->offset && !rlocn_slot0->size)) {
+		rlocn_slot0->offset = 0;
+		rlocn_slot0->size = 0;
+		rlocn_slot0->checksum = 0;
+		rlocn_slot1->offset = 0;
+		rlocn_slot1->size = 0;
+		rlocn_slot1->checksum = 0;
+	}
+
+	/*
+	 * mdac->rlocn is the in-memory copy of the new metadata's location on
+	 * disk.  mdac->rlocn was saved by vg_write after it wrote the new text
+	 * metadata to disk.  This location of the new metadata is now written
+	 * to disk by vg_precommit and vg_commit.  vg_precommit writes the new
+	 * location into the precommit slot (slot1 / raw_locns[1]) and
+	 * vg_commit writes the new location into committed slot (slot0 /
+	 * raw_locns[0]).
+	 *
+	 * vg_revert sets the size of the im-memory mdac->rlocn to 0 and calls
+	 * this function to clear the precommit slot.
+	 */
+
+	rlocn_new = &mdac->rlocn;
+
+	if (!rlocn_new->size) {
 		/*
-		 * If precommitting into a previously-ignored mda, wipe the live rlocn
-		 * as a precaution so that nothing can use it by mistake.
+		 * When there is no new metadata, the precommit slot is
+		 * cleared and the committed slot is left alone. (see revert)
 		 */
-		mdah->raw_locns[0].offset = 0;
-		mdah->raw_locns[0].size = 0;
-		mdah->raw_locns[0].checksum = 0;
-	}
+		rlocn_slot1->offset   = 0;
+		rlocn_slot1->size     = 0;
+		rlocn_slot1->checksum = 0;
 
-	if (precommit)
-		rlocn++;
-	else {
-		/* If not precommitting, wipe the precommitted rlocn */
-		mdah->raw_locns[1].offset = 0;
-		mdah->raw_locns[1].size = 0;
-		mdah->raw_locns[1].checksum = 0;
+	} else if (precommit) {
+		/*
+		 * vg_precommit writes the new raw_locn into slot 1,
+		 * and keeps the existing committed raw_locn in slot 0.
+		 */
+		rlocn_slot1->offset   = rlocn_new->offset;
+		rlocn_slot1->size     = rlocn_new->size;
+		rlocn_slot1->checksum = rlocn_new->checksum;
+	} else {
+		/*
+		 * vg_commit writes the new raw_locn into slot 0,
+		 * and zeros the precommitted values in slot 1.
+		 */
+		rlocn_slot0->offset   = rlocn_new->offset;
+		rlocn_slot0->size     = rlocn_new->size;
+		rlocn_slot0->checksum = rlocn_new->checksum;
+
+		rlocn_slot1->offset   = 0;
+		rlocn_slot1->size     = 0;
+		rlocn_slot1->checksum = 0;
 	}
 
-	/* Is there new metadata to commit? */
+	rlocn_set_ignored(rlocn_slot0, mda_is_ignored(mda));
+
 	if (mdac->rlocn.size) {
-		rlocn->offset = mdac->rlocn.offset;
-		rlocn->size = mdac->rlocn.size;
-		rlocn->checksum = mdac->rlocn.checksum;
-		log_debug_metadata("%sCommitting %s %smetadata (%u) to %s header at "
-			  FMTu64, precommit ? "Pre-" : "", vg->name, 
-			  mda_is_ignored(mda) ? "(ignored) " : "", vg->seqno,
-			  dev_name(mdac->area.dev), mdac->area.start);
-	} else
-		log_debug_metadata("Wiping pre-committed %s %smetadata from %s "
-				   "header at " FMTu64, vg->name,
-				   mda_is_ignored(mda) ? "(ignored) " : "",
-				   dev_name(mdac->area.dev), mdac->area.start);
+		if (precommit) {
+			log_debug_metadata("VG %s metadata precommit seq %u on %s mda header at %llu %s",
+					   vg->name, vg->seqno, dev_name(mdac->area.dev),
+					   (unsigned long long)mdac->area.start,
+					   mda_is_ignored(mda) ? "(ignored)" : "(used)");
+
+			log_debug_metadata("VG %s metadata precommit slot0 offset %llu size %llu slot1 offset %llu size %llu",
+					   vg->name,
+					   (unsigned long long)mdab->raw_locns[0].offset,
+					   (unsigned long long)mdab->raw_locns[0].size,
+					   (unsigned long long)mdab->raw_locns[1].offset,
+					   (unsigned long long)mdab->raw_locns[1].size);
 
-	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
+		} else {
+			log_debug_metadata("VG %s metadata commit seq %u on %s mda header at %llu %s",
+					   vg->name, vg->seqno, dev_name(mdac->area.dev),
+					   (unsigned long long)mdac->area.start,
+					   mda_is_ignored(mda) ? "(ignored)" : "(used)");
+
+			log_debug_metadata("VG %s metadata commit slot0 offset %llu size %llu slot1 offset %llu size %llu",
+					   vg->name,
+					   (unsigned long long)mdab->raw_locns[0].offset,
+					   (unsigned long long)mdab->raw_locns[0].size,
+					   (unsigned long long)mdab->raw_locns[1].offset,
+					   (unsigned long long)mdab->raw_locns[1].size);
+		}
+	} else {
+		if (precommit) {
+			log_debug_metadata("VG %s metadata precommit empty seq %u on %s mda header at %llu %s",
+					   vg->name, vg->seqno, dev_name(mdac->area.dev),
+					   (unsigned long long)mdac->area.start,
+					   mda_is_ignored(mda) ? "(ignored)" : "(used)");
+
+			log_debug_metadata("VG %s metadata precommit empty slot0 offset %llu size %llu slot1 offset %llu size %llu",
+					   vg->name,
+					   (unsigned long long)mdab->raw_locns[0].offset,
+					   (unsigned long long)mdab->raw_locns[0].size,
+					   (unsigned long long)mdab->raw_locns[1].offset,
+					   (unsigned long long)mdab->raw_locns[1].size);
+
+		} else {
+			log_debug_metadata("VG %s metadata commit empty seq %u on %s mda header at %llu %s",
+					   vg->name, vg->seqno, dev_name(mdac->area.dev),
+					   (unsigned long long)mdac->area.start,
+					   mda_is_ignored(mda) ? "(ignored)" : "(used)");
+
+			log_debug_metadata("VG %s metadata commit empty slot0 offset %llu size %llu slot1 offset %llu size %llu",
+					   vg->name,
+					   (unsigned long long)mdab->raw_locns[0].offset,
+					   (unsigned long long)mdab->raw_locns[0].size,
+					   (unsigned long long)mdab->raw_locns[1].offset,
+					   (unsigned long long)mdab->raw_locns[1].size);
+		}
+	}
+
+	rlocn_set_ignored(mdab->raw_locns, mda_is_ignored(mda));
 
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mda_is_primary(mda), mdac->area.start,
-				   mdah)) {
-		dm_pool_free(fid->fmt->cmd->mem, mdah);
+				   mdab)) {
+		dm_pool_free(fid->fmt->cmd->mem, mdab);
 		log_error("Failed to write metadata area header");
 		goto out;
 	}
@@ -824,14 +1134,19 @@ static int _vg_revert_raw(struct format_instance *fid, struct volume_group *vg,
 	return _vg_commit_raw_rlocn(fid, vg, mda, 0);
 }
 
+/*
+ * vg_remove clears the two raw_locn slots but leaves the circular metadata
+ * buffer alone.
+ */
+
 static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 			  struct metadata_area *mda)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
-	struct raw_locn *rlocn;
+	struct raw_locn *rlocn_slot0;
+	struct raw_locn *rlocn_slot1;
 	int r = 0;
-	int noprecommit = 0;
 
 	if (!(mdah = dm_pool_alloc(fid->fmt->cmd->mem, MDA_HEADER_SIZE))) {
 		log_error("struct mda_header allocation failed");
@@ -841,26 +1156,24 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	/*
 	 * FIXME: what's the point of reading the mda_header and metadata,
 	 * since we zero the rlocn fields whether we can read them or not.
+	 * Just to print the warning?
 	 */
 
-	if (!_raw_read_mda_header(mdah, &mdac->area, mda_is_primary(mda))) {
+	if (!_raw_read_mda_header(mdah, &mdac->area, mda_is_primary(mda)))
 		log_warn("WARNING: Removing metadata location on %s with bad mda header.",
 			  dev_name(mdac->area.dev));
-		rlocn = &mdah->raw_locns[0];
-		mdah->raw_locns[1].offset = 0;
-	} else {
-		if (!(rlocn = _read_metadata_location_vg(&mdac->area, mdah, mda_is_primary(mda), vg->name, &noprecommit))) {
-			log_warn("WARNING: Removing metadata location on %s with bad metadata.",
-				 dev_name(mdac->area.dev));
-			rlocn = &mdah->raw_locns[0];
-			mdah->raw_locns[1].offset = 0;
-		}
-	}
 
-	rlocn->offset = 0;
-	rlocn->size = 0;
-	rlocn->checksum = 0;
-	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
+	rlocn_slot0 = &mdah->raw_locns[0];
+	rlocn_slot1 = &mdah->raw_locns[1];
+
+	rlocn_slot0->offset = 0;
+	rlocn_slot0->size = 0;
+	rlocn_slot0->checksum = 0;
+	rlocn_set_ignored(rlocn_slot0, mda_is_ignored(mda));
+
+	rlocn_slot1->offset = 0;
+	rlocn_slot1->size = 0;
+	rlocn_slot1->checksum = 0;
 
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mda_is_primary(mda), mdac->area.start,
 				   mdah)) {
@@ -1013,7 +1326,7 @@ static int _vg_commit_file_backup(struct format_instance *fid __attribute__((unu
 			return 0;
 		}
 	} else {
-		log_debug_metadata("Committing %s metadata (%u)", vg->name, vg->seqno);
+		log_debug_metadata("Committing file %s metadata (%u)", vg->name, vg->seqno);
 		log_debug_metadata("Renaming %s to %s", tc->path_edit, tc->path_live);
 		if (rename(tc->path_edit, tc->path_live)) {
 			log_error("%s: rename to %s failed: %s", tc->path_edit,
@@ -1099,8 +1412,14 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	uint32_t wrap = 0;
 	unsigned int len = 0;
 	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
-	uint64_t buffer_size, current_usage;
 
+	/*
+	 * For the case where the metadata area is unused, we say that half of
+	 * it is available, based on the fact that we keep two consecutive
+	 * copies of the metadata in the area, so each copy can be as large as
+	 * half the area.  (Technically, one of those could be less than half
+	 * and another could be more than half.)
+	 */
 	if (mda_free_sectors)
 		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
 
@@ -1109,8 +1428,7 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
-	/* FIXME Cope with returning a list */
-	rlocn = mdah->raw_locns;
+	rlocn = mdah->raw_locns; /* slot0, committed metadata */
 
 	/*
 	 * If no valid offset, do not try to search for vgname
@@ -1131,7 +1449,10 @@ int read_metadata_location_summary(const struct format_type *fmt,
 
 	buf[len] = '\0';
 
-	/* Ignore this entry if the characters aren't permissible */
+	/*
+	 * Check that the text metadata in the circular buffer begins with a
+	 * valid vg name.
+	 */
 	if (!validate_name(buf)) {
 		log_error("Metadata location on %s at %llu begins with invalid VG name.",
 			  dev_name(dev_area->dev),
@@ -1139,17 +1460,16 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
-	/* We found a VG - now check the metadata */
+	/*
+	 * When the current metadata wraps around the end of the metadata area
+	 * (so some is located at the end and some is located at the
+	 * beginning), then "wrap" is the number of bytes that was written back
+	 * at the beginning.  The end of this wrapped metadata is located at an
+	 * offset of wrap+MDA_HEADER_SIZE from area.start.
+	 */
 	if (rlocn->offset + rlocn->size > mdah->size)
 		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
-	if (wrap > rlocn->offset) {
-		log_error("Metadata location on %s at %llu is too large for circular buffer.",
-			  dev_name(dev_area->dev),
-			  (unsigned long long)(dev_area->start + rlocn->offset));
-		return 0;
-	}
-
 	/*
 	 * Did we see this metadata before?
 	 * Look in lvmcache to see if there is vg info matching
@@ -1217,14 +1537,19 @@ int read_metadata_location_summary(const struct format_type *fmt,
 			   vgsummary->vgname);
 
 	if (mda_free_sectors) {
-		current_usage = (rlocn->size + SECTOR_SIZE - UINT64_C(1)) -
-				 (rlocn->size + SECTOR_SIZE - UINT64_C(1)) % SECTOR_SIZE;
-		buffer_size = mdah->size - MDA_HEADER_SIZE;
+		/*
+		 * Report remaining space on the assumption that a single copy
+		 * of metadata can be as large as half the total metadata
+		 * space.  Technically, it can be larger if the other copy is
+		 * less.  511 is subtracted from max because the next copy can
+		 * be rounded up by 511 bytes to start on a sector boundary.
+		 */
+		uint64_t max = (mdah->size - MDA_HEADER_SIZE - 511) / 2;
 
-		if (current_usage * 2 >= buffer_size)
+		if (rlocn->size >= max)
 			*mda_free_sectors = UINT64_C(0);
 		else
-			*mda_free_sectors = ((buffer_size - 2 * current_usage) / 2) >> SECTOR_SHIFT;
+			*mda_free_sectors = (max - rlocn->size) >> SECTOR_SHIFT;
 	}
 
 	return 1;


