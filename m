From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 11 Dec 2017 11:09:40 -0500
Subject: master - format_text: Replace PRI with FMT.
Message-ID: <201712111609.vBBG9egw030380@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49d486319fa6cb48e693c364ee6d72e4b6c364d2
Commit:        49d486319fa6cb48e693c364ee6d72e4b6c364d2
Parent:        75d4d8e9a42a4709ed40348395b1e75dff4197e8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Dec 11 15:32:53 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Dec 11 15:39:25 2017 +0000

format_text: Replace PRI with FMT.

---
 lib/format_text/archiver.c    |    2 +-
 lib/format_text/export.c      |   16 +++++-----
 lib/format_text/format-text.c |   58 ++++++++++++++++++++--------------------
 lib/format_text/text_label.c  |    6 ++--
 4 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 3e519ca..1eb6654 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -413,7 +413,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 			new_pvl->pv = pv;
 			dm_list_add(&new_pvs, &new_pvl->list);
 
-			log_verbose("Set up physical volume for \"%s\" with %" PRIu64
+			log_verbose("Set up physical volume for \"%s\" with " FMTu64
 				    " available sectors.", pv_dev_name(pv), pv_size(pv));
 		}
 
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 9fede20..e535237 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -121,7 +121,7 @@ static int _extend_buffer(struct formatter *f)
 {
 	char *newbuf;
 
-	log_debug_metadata("Doubling metadata output buffer to %" PRIu32,
+	log_debug_metadata("Doubling metadata output buffer to " FMTu32,
 			   f->data.buf.size * 2);
 	if (!(newbuf = dm_realloc(f->data.buf.start,
 				   f->data.buf.size * 2))) {
@@ -561,15 +561,15 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 		if (!_out_list(f, &pv->tags, "tags"))
 			return_0;
 
-		outsize(f, pv->size, "dev_size = %" PRIu64, pv->size);
+		outsize(f, pv->size, "dev_size = " FMTu64, pv->size);
 
-		outf(f, "pe_start = %" PRIu64, pv->pe_start);
+		outf(f, "pe_start = " FMTu64, pv->pe_start);
 		outsize(f, vg->extent_size * (uint64_t) pv->pe_count,
 			"pe_count = %u", pv->pe_count);
 
 		if (pv->ba_start && pv->ba_size) {
-			outf(f, "ba_start = %" PRIu64, pv->ba_start);
-			outsize(f, pv->ba_size, "ba_size = %" PRIu64, pv->ba_size);
+			outf(f, "ba_start = " FMTu64, pv->ba_start);
+			outsize(f, pv->ba_size, "ba_size = " FMTu64, pv->ba_size);
 		}
 
 		_dec_indent(f);
@@ -631,7 +631,7 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 		switch (seg_type(seg, s)) {
 		case AREA_PV:
 			if (!(pv = seg_pv(seg, s))) {
-				log_error(INTERNAL_ERROR "Missing PV for area %" PRIu32 " of %s segment of LV %s.",
+				log_error(INTERNAL_ERROR "Missing PV for area " FMTu32 " of %s segment of LV %s.",
 					  s, type, display_lvname(seg->lv));
 				return 0;
 			}
@@ -670,7 +670,7 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 
 			break;
 		case AREA_UNASSIGNED:
-			log_error(INTERNAL_ERROR "Invalid type for area %" PRIu32 " of %s segment of LV %s.",
+			log_error(INTERNAL_ERROR "Invalid type for area " FMTu32 " of %s segment of LV %s.",
 				  s, type, display_lvname(seg->lv));
 			return 0;
 		}
@@ -694,7 +694,7 @@ static int _print_timestamp(struct formatter *f,
 			      "%Y-%m-%d %T %z", local_tm))
 			buf[0] = 0;
 
-		outfc(f, buf, "%s = %" PRIu64, name, (uint64_t) ts);
+		outfc(f, buf, "%s = " FMTu64, name, (uint64_t) ts);
 	}
 
 	return 1;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c96fad9..adaf0a8 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -183,8 +183,8 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 
 	mdac = (struct mda_context *) mda->metadata_locn;
 
-	log_print("Found text metadata area: offset=%" PRIu64 ", size=%"
-		  PRIu64, mdac->area.start, mdac->area.size);
+	log_print("Found text metadata area: offset=" FMTu64 ", size="
+		  FMTu64, mdac->area.start, mdac->area.size);
 	area = &mdac->area;
 
 	if (!dev_open_readonly(area->dev))
@@ -240,8 +240,8 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 			/* FIXME: Validate region, pull out timestamp?, etc */
 			/* FIXME: Do something with this region */
 			log_verbose ("Found LVM2 metadata record at "
-				     "offset=%"PRIu64", size=%"PRIsize_t", "
-				     "offset2=%"PRIu64" size2=%"PRIsize_t,
+				     "offset=" FMTu64 ", size=" FMTsize_t ", "
+				     "offset2=" FMTu64 " size2=" FMTsize_t,
 				     offset, size, offset2, size2);
 			offset = prev_sector;
 			size = SECTOR_SIZE;
@@ -333,7 +333,7 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 						  MDA_HEADER_SIZE -
 						  sizeof(mdah->checksum_xl)))) {
 		log_error("Incorrect metadata area header checksum on %s"
-			  " at offset %"PRIu64, dev_name(dev_area->dev),
+			  " at offset " FMTu64, dev_name(dev_area->dev),
 			  dev_area->start);
 		return 0;
 	}
@@ -342,21 +342,21 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 
 	if (strncmp((char *)mdah->magic, FMTT_MAGIC, sizeof(mdah->magic))) {
 		log_error("Wrong magic number in metadata area header on %s"
-			  " at offset %"PRIu64, dev_name(dev_area->dev),
+			  " at offset " FMTu64, dev_name(dev_area->dev),
 			  dev_area->start);
 		return 0;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
 		log_error("Incompatible metadata area header version: %d on %s"
-			  " at offset %"PRIu64, mdah->version,
+			  " at offset " FMTu64, mdah->version,
 			  dev_name(dev_area->dev), dev_area->start);
 		return 0;
 	}
 
 	if (mdah->start != dev_area->start) {
-		log_error("Incorrect start sector in metadata area header: %"
-			  PRIu64" on %s at offset %"PRIu64, mdah->start,
+		log_error("Incorrect start sector in metadata area header: "
+			  FMTu64 " on %s at offset " FMTu64, mdah->start,
 			  dev_name(dev_area->dev), dev_area->start);
 		return 0;
 	}
@@ -456,7 +456,7 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
 		return rlocn;
 
-	log_debug_metadata("Volume group name found in %smetadata on %s at %" PRIu64 " does "
+	log_debug_metadata("Volume group name found in %smetadata on %s at " FMTu64 " does "
 			   "not match expected name %s.", 
 			   *precommitted ? "precommitted " : "",
 			   dev_name(dev_area->dev), dev_area->start + rlocn->offset, vgname);
@@ -557,13 +557,13 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 		goto_out;
 
 	if (vg)
-		log_debug_metadata("Read %s %smetadata (%u) from %s at %" PRIu64 " size %"
-				   PRIu64, vg->name, precommitted ? "pre-commit " : "",
+		log_debug_metadata("Read %s %smetadata (%u) from %s at " FMTu64 " size "
+				   FMTu64, vg->name, precommitted ? "pre-commit " : "",
 				   vg->seqno, dev_name(area->dev),
 				   area->start + rlocn->offset, rlocn->size);
 	else
-		log_debug_metadata("Skipped reading %smetadata from %s at %" PRIu64 " size %"
-				   PRIu64 " with matching checksum.", precommitted ? "pre-commit " : "",
+		log_debug_metadata("Skipped reading %smetadata from %s at " FMTu64 " size "
+				   FMTu64 " with matching checksum.", precommitted ? "pre-commit " : "",
 				   dev_name(area->dev),
 				   area->start + rlocn->offset, rlocn->size);
 
@@ -677,7 +677,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		goto out;
 	}
 
-	log_debug_metadata("Writing %s metadata to %s at %" PRIu64 " len %" PRIu64,
+	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64,
 			    vg->name, dev_name(mdac->area.dev), mdac->area.start +
 			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap);
 
@@ -688,7 +688,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		goto_out;
 
 	if (new_wrap) {
-		log_debug_metadata("Writing wrapped metadata to %s at %" PRIu64 " len %" PRIu64,
+		log_debug_metadata("Writing wrapped metadata to %s at " FMTu64 " len " FMTu64,
 				  dev_name(mdac->area.dev), mdac->area.start +
 				  MDA_HEADER_SIZE, new_wrap);
 
@@ -787,13 +787,13 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 		rlocn->offset = mdac->rlocn.offset;
 		rlocn->size = mdac->rlocn.size;
 		rlocn->checksum = mdac->rlocn.checksum;
-		log_debug_metadata("%sCommitting %s %smetadata (%u) to %s header at %"
-			  PRIu64, precommit ? "Pre-" : "", vg->name, 
+		log_debug_metadata("%sCommitting %s %smetadata (%u) to %s header at "
+			  FMTu64, precommit ? "Pre-" : "", vg->name, 
 			  mda_is_ignored(mda) ? "(ignored) " : "", vg->seqno,
 			  dev_name(mdac->area.dev), mdac->area.start);
 	} else
 		log_debug_metadata("Wiping pre-committed %s %smetadata from %s "
-				   "header at %" PRIu64, vg->name,
+				   "header at " FMTu64, vg->name,
 				   mda_is_ignored(mda) ? "(ignored) " : "",
 				   dev_name(mdac->area.dev), mdac->area.start);
 
@@ -1253,8 +1253,8 @@ int vgname_from_mda(const struct format_type *fmt,
 	if (!validate_name(vgsummary->vgname))
 		return_0;
 
-	log_debug_metadata("%s: %s metadata at %" PRIu64 " size %" PRIu64
-			   " (in area at %" PRIu64 " size %" PRIu64
+	log_debug_metadata("%s: %s metadata at " FMTu64 " size " FMTu64
+			   " (in area at " FMTu64 " size " FMTu64
 			   ") for %s (" FMTVGID ")",
 			   dev_name(dev_area->dev),
 			   used_cached_metadata ? "Using cached" : "Found",
@@ -1402,8 +1402,8 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 			continue;
 
 		mdac = (struct mda_context *) mda->metadata_locn;
-		log_debug_metadata("Creating metadata area on %s at sector %"
-				   PRIu64 " size %" PRIu64 " sectors",
+		log_debug_metadata("Creating metadata area on %s at sector "
+				   FMTu64 " size " FMTu64 " sectors",
 				   dev_name(mdac->area.dev),
 				   mdac->area.start >> SECTOR_SHIFT,
 				   mdac->area.size >> SECTOR_SHIFT);
@@ -1782,10 +1782,10 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 		return 1; /* pretend the MDA does not exist */
 
 	return config_make_nodes(cft, parent, NULL,
-				 "ignore = %" PRId64, (int64_t) mda_is_ignored(mda),
-				 "start = %" PRId64, (int64_t) mdc->area.start,
-				 "size = %" PRId64, (int64_t) mdc->area.size,
-				 "free_sectors = %" PRId64, (int64_t) mdc->free_sectors,
+				 "ignore = " FMTd64, (int64_t) mda_is_ignored(mda),
+				 "start = " FMTd64, (int64_t) mdc->area.start,
+				 "size = " FMTd64, (int64_t) mdc->area.size,
+				 "free_sectors = " FMTd64, (int64_t) mdc->free_sectors,
 				 NULL) ? 1 : 0;
 }
 
@@ -2306,13 +2306,13 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 
 	if (limit_applied)
 		log_very_verbose("Using limited metadata area size on %s "
-				 "with value %" PRIu64 " (limited by %s of "
+				 "with value " FMTu64 " (limited by %s of "
 				 FMTu64 ").", pv_dev_name(pv),
 				  mda_size, limit_name, limit);
 
 	if (mda_size) {
 		if (mda_size < MDA_SIZE_MIN) {
-			log_error("Metadata area size too small: %" PRIu64" bytes. "
+			log_error("Metadata area size too small: " FMTu64 " bytes. "
 				  "It must be@least %u bytes.", mda_size, MDA_SIZE_MIN);
 			goto bad;
 		}
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index c567709..7058f70 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -148,7 +148,7 @@ static int _text_write(struct label *label, void *buf)
 		 !xlate64(pvhdr->disk_areas_xl[mda2].size))
 		mda2 = 0;
 
-	log_debug_metadata("%s: Preparing PV label header %s size %" PRIu64 " with"
+	log_debug_metadata("%s: Preparing PV label header %s size " FMTu64 " with"
 			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
 			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
 			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
@@ -352,7 +352,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
 	if (mda_is_ignored(mda)) {
-		log_debug_metadata("Ignoring mda on device %s at offset %"PRIu64,
+		log_debug_metadata("Ignoring mda on device %s at offset " FMTu64,
 				   dev_name(mdac->area.dev),
 				   mdac->area.start);
 		if (!dev_close(mdac->area.dev))
@@ -428,7 +428,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	if (!(ext_version = xlate32(pvhdr_ext->version)))
 		goto out;
 
-	log_debug_metadata("%s: PV header extension version %" PRIu32 " found",
+	log_debug_metadata("%s: PV header extension version " FMTu32 " found",
 			   dev_name(dev), ext_version);
 
 	/* Extension version */


