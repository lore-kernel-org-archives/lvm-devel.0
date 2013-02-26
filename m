From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Feb 2013 14:18:17 +0000 (UTC)
Subject: master - pv_header_extension: add support for writing PV header extension (flags & Embedding Area)
Message-ID: <20130226141817.AE7F3A0C57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b778653f03702a967df11d51d842abb9a9b86068
Commit:        b778653f03702a967df11d51d842abb9a9b86068
Parent:        9dbe25709e3805fbbc8024f0be68de2aae815747
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 15 11:02:53 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 26 11:28:00 2013 +0100

pv_header_extension: add support for writing PV header extension (flags & Embedding Area)

The PV header extension information (PV header extension version, flags
and list of Embedding Area locations) is stored just beyond the PV header base.

When calculating the Embedding Area start value (ea_start), the same logic is
used as when calculating the pe_start value for Data Area - the value must
follow exactly the same alignment restrictions for its start value
(the alignment detected automatically or provided via command line using
the --dataalignment and --dataalignmentoffset arguments).

The Embedding Area is placed at the very start of the PV, starting at
ea_start. The Data Area starting at pe_start is placed next. The pe_start is
still properly aligned. Due to the pe_start alignment, it's possible that the
resulting Embedding Area size (ea_size) ends up bigger in size than requested
(but never less than requested).
---
 lib/format1/format1.c            |    2 +
 lib/format_text/export.c         |    5 ++
 lib/format_text/format-text.c    |  108 ++++++++++++++++++++++++++++++-------
 lib/format_text/text_label.c     |   73 ++++++++++++++++++-------
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/metadata.c          |    2 +
 tools/pvcreate.c                 |    2 +
 7 files changed, 153 insertions(+), 41 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index c90c266..f3945bc 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -379,6 +379,8 @@ static int _format1_pv_setup(const struct format_type *fmt,
 	struct pvcreate_restorable_params rp = {.restorefile = NULL,
 						.id = {{0}},
 						.idp = NULL,
+						.ea_start = 0,
+						.ea_size = 0,
 						.pe_start = 0,
 						.extent_count = 0,
 						.extent_size = vg->extent_size};
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index d68daf5..6d83106 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -490,6 +490,11 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 		outsize(f, vg->extent_size * (uint64_t) pv->pe_count,
 			"pe_count = %u", pv->pe_count);
 
+		if (pv->ea_start && pv->ea_size) {
+			outf(f, "ea_start = %" PRIu64, pv->ea_start);
+			outsize(f, pv->ea_size, "ea_size = %" PRIu64, pv->ea_size);
+		}
+
 		_dec_indent(f);
 		outf(f, "}");
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e1fbf99..774f6ce 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1331,6 +1331,9 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 				 mdac->area.start, mdac->area.size, mda_is_ignored(mda));
 	}
 
+	if (!lvmcache_update_eas(info, pv))
+		return_0;
+
 	/*
 	 * FIXME: Allow writing zero offset/size data area to disk.
 	 *        This requires defining a special value since we can't
@@ -1471,12 +1474,7 @@ static int _text_pv_initialise(const struct format_type *fmt,
 			       struct pvcreate_restorable_params *rp,
 			       struct physical_volume *pv)
 {
-	/*
-	 * Try to keep the value of PE start set to a firm value if requested.
-	 * This is usefull when restoring existing PE start value (backups etc.).
-	 */
-	if (rp->pe_start != PV_PE_START_CALC)
-		pv->pe_start = rp->pe_start;
+	unsigned long adjustment, final_alignment = 0;
 
 	if (!data_alignment)
 		data_alignment = find_config_tree_int(pv->fmt->cmd,
@@ -1506,14 +1504,65 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		return 0;
 	}
 
-	if (pv->size < pv->pe_align + pv->pe_align_offset) {
+	final_alignment = pv->pe_align + pv->pe_align_offset;
+
+	if (pv->size < final_alignment) {
 		log_error("%s: Data alignment must not exceed device size.",
 			  pv_dev_name(pv));
 		return 0;
 	}
 
-	if (rp->pe_start == PV_PE_START_CALC)
-		pv->pe_start = pv->pe_align + pv->pe_align_offset;
+	if (pv->size < final_alignment + rp->ea_size) {
+		log_error("%s: Embedding area with data-aligned start must "
+			  "not exceed device size.", pv_dev_name(pv));
+		return 0;
+	}
+
+	if (rp->pe_start == PV_PE_START_CALC) {
+		/*
+		 * Calculate new PE start and embedding area start value.
+		 * Make sure both are properly aligned!
+		 * If PE start can't be aligned because EA is taking
+		 * the whole space, make PE start equal to the PV size
+		 * which effectively disables DA - it will have zero size.
+		 * This needs to be done as we can't have a PV without any DA.
+		 * But we still want to support a PV with EA only!
+		 */
+		if (rp->ea_size) {
+			pv->ea_start = final_alignment;
+			pv->ea_size = rp->ea_size;
+			if ((adjustment = rp->ea_size % pv->pe_align))
+				pv->ea_size += pv->pe_align - adjustment;
+			if (pv->size < pv->ea_start + pv->ea_size)
+				pv->ea_size = pv->size - pv->ea_start;
+			pv->pe_start = pv->ea_start + pv->ea_size;
+		} else
+			pv->pe_start = final_alignment;
+	} else {
+		/*
+		 * Try to keep the value of PE start set to a firm value if
+		 * requested. This is useful when restoring existing PE start
+		 * value (e.g. backups). Also, if creating an EA, try to place
+		 * it in between the final alignment and existing PE start
+		 * if possible.
+		 * TODO: Support restoring existing EA from MDA instead like
+		 *       we do for PE start? This would require adding EA info
+		 *       in MDA then!
+		 */
+		pv->pe_start = rp->pe_start;
+		if (rp->ea_size) {
+			if ((rp->ea_start && rp->ea_start + rp->ea_size > rp->pe_start) ||
+			    (rp->pe_start <= final_alignment) ||
+			    (rp->pe_start - final_alignment < rp->ea_size)) {
+				log_error("%s: Embedding area would overlap "
+					  "data area.", pv_dev_name(pv));
+				return 0;
+			} else {
+				pv->ea_start = rp->ea_start ? : final_alignment;
+				pv->ea_size = rp->ea_size;
+			}
+		}
+	}
 
 	if (rp->extent_size)
 		pv->pe_size = rp->extent_size;
@@ -1938,7 +1987,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 {
 	struct format_instance *fid = pv->fid;
 	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
-	uint64_t pe_start, pe_end;
+	uint64_t ea_size, pe_start, pe_end;
 	uint64_t alignment, alignment_offset;
 	uint64_t disk_size;
 	uint64_t mda_start;
@@ -1959,6 +2008,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 	}
 
 	pe_start = pv->pe_start << SECTOR_SHIFT;
+	ea_size = pv->ea_size << SECTOR_SHIFT;
 	alignment = pv->pe_align << SECTOR_SHIFT;
 	alignment_offset = pv->pe_align_offset << SECTOR_SHIFT;
 	disk_size = pv->size << SECTOR_SHIFT;
@@ -1994,6 +2044,12 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 			limit_name = "disk size";
 		}
 
+		/* Adjust limits for embedding area if present. */
+		if (ea_size) {
+			limit -= ea_size;
+			limit_name = "ea_start";
+		}
+
 		if (limit > disk_size)
 			goto bad;
 
@@ -2053,8 +2109,11 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 		 * start of the area that follows the MDA0 we've just calculated.
 		 */
 		if (!pe_start_locked) {
-			pe_start = mda_start + mda_size;
-			pv->pe_start = pe_start >> SECTOR_SHIFT;
+			if (ea_size) {
+				pv->ea_start = (mda_start + mda_size) >> SECTOR_SHIFT;
+				pv->pe_start = pv->ea_start + pv->ea_size;
+			} else
+				pv->pe_start = (mda_start + mda_size) >> SECTOR_SHIFT;
 		}
 	}
 	/* Second metadata area at the end of the device. */
@@ -2072,15 +2131,22 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 		if (pe_start || pe_start_locked) {
 			limit = pe_end ? pe_end : pe_start;
 			limit_name = pe_end ? "pe_end" : "pe_start";
-		}
-		else if ((mda = fid_get_mda_indexed(fid, pvid, ID_LEN, 0)) &&
-			 (mdac = mda->metadata_locn)) {
-			limit = mdac->area.start + mdac->area.size;
-			limit_name = "MDA0 end";
-		}
-		else {
-			limit = LABEL_SCAN_SIZE;
-			limit_name = "label scan size";
+		} else {
+			if ((mda = fid_get_mda_indexed(fid, pvid, ID_LEN, 0)) &&
+				 (mdac = mda->metadata_locn)) {
+				limit = mdac->area.start + mdac->area.size;
+				limit_name = "MDA0 end";
+			}
+			else {
+				limit = LABEL_SCAN_SIZE;
+				limit_name = "label scan size";
+			}
+
+			/* Adjust limits for embedding area if present. */
+			if (ea_size) {
+				limit += ea_size;
+				limit_name = "ea_end";
+			}
 		}
 
 		if (limit > disk_size)
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7ee9022..32f3347 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -35,23 +35,28 @@ static int _text_can_handle(struct labeller *l __attribute__((unused)),
 	return 0;
 }
 
-struct _da_setup_baton {
+struct _dl_setup_baton {
 	struct disk_locn *pvh_dlocn_xl;
 	struct device *dev;
 };
 
 static int _da_setup(struct disk_locn *da, void *baton)
 {
-	struct _da_setup_baton *p = baton;
+	struct _dl_setup_baton *p = baton;
 	p->pvh_dlocn_xl->offset = xlate64(da->offset);
 	p->pvh_dlocn_xl->size = xlate64(da->size);
 	p->pvh_dlocn_xl++;
 	return 1;
 }
 
+static int _ea_setup(struct disk_locn *ea, void *baton)
+{
+	return _da_setup(ea, baton);
+}
+
 static int _mda_setup(struct metadata_area *mda, void *baton)
 {
-	struct _da_setup_baton *p = baton;
+	struct _dl_setup_baton *p = baton;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 
 	if (mdac->area.dev != p->dev)
@@ -64,15 +69,30 @@ static int _mda_setup(struct metadata_area *mda, void *baton)
 	return 1;
 }
 
+static int _dl_null_termination(void *baton)
+{
+	struct _dl_setup_baton *p = baton;
+
+	p->pvh_dlocn_xl->offset = xlate64(UINT64_C(0));
+	p->pvh_dlocn_xl->size = xlate64(UINT64_C(0));
+	p->pvh_dlocn_xl++;
+
+	return 1;
+}
+
 static int _text_write(struct label *label, void *buf)
 {
 	struct label_header *lh = (struct label_header *) buf;
 	struct pv_header *pvhdr;
+	struct pv_header_extension *pvhdr_ext;
 	struct lvmcache_info *info;
-	struct _da_setup_baton baton;
+	struct _dl_setup_baton baton;
 	char buffer[64] __attribute__((aligned(8)));
-	int da1, mda1, mda2;
+	int ea1, da1, mda1, mda2;
 
+	/*
+	 * PV header base
+	 */
 	/* FIXME Move to where label is created */
 	strncpy(label->type, LVM2_LABEL, sizeof(label->type));
 
@@ -89,29 +109,34 @@ static int _text_write(struct label *label, void *buf)
 	}
 
 	baton.dev = lvmcache_device(info);
+	baton.pvh_dlocn_xl = &pvhdr->disk_areas_xl[0];
 
 	/* List of data areas (holding PEs) */
-	baton.pvh_dlocn_xl = &pvhdr->disk_areas_xl[0];
 	lvmcache_foreach_da(info, _da_setup, &baton);
-
-	/* NULL-termination */
-	baton.pvh_dlocn_xl->offset = xlate64(UINT64_C(0));
-	baton.pvh_dlocn_xl->size = xlate64(UINT64_C(0));
-	baton.pvh_dlocn_xl++;
+	_dl_null_termination(&baton);
 
 	/* List of metadata area header locations */
 	lvmcache_foreach_mda(info, _mda_setup, &baton);
+	_dl_null_termination(&baton);
 
-	/* NULL-termination */
-	baton.pvh_dlocn_xl->offset = xlate64(UINT64_C(0));
-	baton.pvh_dlocn_xl->size = xlate64(UINT64_C(0));
+	/*
+	 * PV header extension
+	 */
+	pvhdr_ext = (struct pv_header_extension *) ((char *) baton.pvh_dlocn_xl);
+	pvhdr_ext->version = xlate32(PV_HEADER_EXTENSION_VSN);
+	pvhdr_ext->flags = 0; /* no flags yet */
+
+	/* List of embedding area locations */
+	baton.pvh_dlocn_xl = &pvhdr_ext->embedding_areas_xl[0];
+	lvmcache_foreach_ea(info, _ea_setup, &baton);
+	_dl_null_termination(&baton);
 
-	/* Create debug message with da and mda locations */
-	if (xlate64(pvhdr->disk_areas_xl[0].offset) ||
-	    xlate64(pvhdr->disk_areas_xl[0].size))
-		da1 = 0;
-	else
-		da1 = -1;
+	/* Create debug message with ea, da and mda locations */
+	ea1 = (xlate64(pvhdr_ext->embedding_areas_xl[0].offset) ||
+	       xlate64(pvhdr_ext->embedding_areas_xl[0].size)) ? 0 : -1;
+
+	da1 = (xlate64(pvhdr->disk_areas_xl[0].offset) ||
+	       xlate64(pvhdr->disk_areas_xl[0].size)) ? 0 : -1;
 
 	mda1 = da1 + 2;
 	mda2 = mda1 + 1;
@@ -126,8 +151,16 @@ static int _text_write(struct label *label, void *buf)
 	log_debug_metadata("%s: Preparing PV label header %s size %" PRIu64 " with"
 			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
 			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
+			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
 			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s",
 			   dev_name(lvmcache_device(info)), buffer, lvmcache_device_size(info),
+			   (ea1 > -1) ? " ea1 (" : "",
+			   (ea1 > -1) ? 1 : 0,
+			   (ea1 > -1) ? xlate64(pvhdr_ext->embedding_areas_xl[ea1].offset) >> SECTOR_SHIFT : 0,
+			   (ea1 > -1) ? "s, " : "",
+			   (ea1 > -1) ? 1 : 0,
+			   (ea1 > -1) ? xlate64(pvhdr_ext->embedding_areas_xl[ea1].size) >> SECTOR_SHIFT : 0,
+			   (ea1 > -1) ? "s)" : "",
 			   (da1 > -1) ? " da1 (" : "",
 			   (da1 > -1) ? 1 : 0,
 			   (da1 > -1) ? xlate64(pvhdr->disk_areas_xl[da1].offset) >> SECTOR_SHIFT : 0,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6624a40..0ce5ad5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -398,6 +398,8 @@ struct pvcreate_restorable_params {
 	const char *restorefile; /* 0 if no --restorefile option */
 	struct id id; /* FIXME: redundant */
 	struct id *idp; /* 0 if no --uuid option */
+	uint64_t ea_start;
+	uint64_t ea_size;
 	uint64_t pe_start;
 	uint32_t extent_count;
 	uint32_t extent_size;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2c071b0..0996184 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1430,6 +1430,8 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 	pp->metadataignore = DEFAULT_PVMETADATAIGNORE;
 	pp->rp.restorefile = 0;
 	pp->rp.idp = 0;
+	pp->rp.ea_start = 0;
+	pp->rp.ea_size = 0;
 	pp->rp.pe_start = PV_PE_START_CALC;
 	pp->rp.extent_count = 0;
 	pp->rp.extent_size = 0;
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index eb2fb5e..5b83a18 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -73,6 +73,8 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 				  uuid, pp->rp.restorefile);
 			return 0;
 		}
+		pp->rp.ea_start = pv_ea_start(existing_pvl->pv);
+		pp->rp.ea_size = pv_ea_size(existing_pvl->pv);
 		pp->rp.pe_start = pv_pe_start(existing_pvl->pv);
 		pp->rp.extent_size = pv_pe_size(existing_pvl->pv);
 		pp->rp.extent_count = pv_pe_count(existing_pvl->pv);


