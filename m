From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 12 Dec 2017 16:24:46 -0500
Subject: master - format_text: Refactor and document metadata offset calculation.
Message-ID: <201712122124.vBCLOkRS022353@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4002f5e206ae89db28eb60bdfb3685bd926fed57
Commit:        4002f5e206ae89db28eb60bdfb3685bd926fed57
Parent:        e932c5da50a22e585a3cd08edb3d849e7715e244
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 12 18:36:54 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 12 18:36:54 2017 +0000

format_text: Refactor and document metadata offset calculation.

---
 lib/format_text/format-text.c |   47 +++++++++++++++++++++++++++-------------
 1 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 154d748..174a579 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -476,7 +476,9 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 }
 
 /*
- * Determine offset for uncommitted metadata
+ * Find first aligned offset after end of existing metadata.
+ * Based on the alignment provided, this is the exact offset to use for the new metadata.
+ * The caller is responsible for validating the result.
  */
 static uint64_t _next_rlocn_offset(struct raw_locn *rlocn, struct mda_header *mdah, uint64_t mdac_area_start, uint64_t alignment)
 {
@@ -484,7 +486,7 @@ static uint64_t _next_rlocn_offset(struct raw_locn *rlocn, struct mda_header *md
 
 	if (!rlocn)
 		/* Find an empty slot */
-		/* FIXME Assume only one VG per mdah for now */
+		/* FIXME Assumes only one VG per mdah for now */
 		return alignment;
 
 	/* Calculate new start position relative to start of buffer rounded up to absolute alignment */
@@ -626,23 +628,28 @@ static int _metadata_fits_into_buffer(struct mda_context *mdac, struct mda_heade
 	uint64_t old_wrap = 0;	/* Amount of wrap around in existing metadata */
 	uint64_t new_end;	/* The end location of the new metadata */
 
-	/* Do we have existing metadata that ends beyond the end of the buffer? */
-	if (rlocn && (rlocn->offset + rlocn->size > mdah->size))
-		old_wrap = (rlocn->offset + rlocn->size) - mdah->size;
+	/* Does the total amount of metadata, old and new, fit inside the buffer? */
+	if (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)
+		return_0;
 
-	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE :
-			    mdac->rlocn.offset + mdac->rlocn.size;
+	/* Does the existing metadata wrap around the end of the buffer? */
+	if (rlocn) {
+		if (rlocn->offset + rlocn->size > mdah->size)
+			old_wrap = (rlocn->offset + rlocn->size) - mdah->size;
+	}
+
+	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE : (mdac->rlocn.offset + mdac->rlocn.size);
 
 	/* If both wrap around, there's necessarily overlap */
 	if (new_wrap && old_wrap)
 		return_0;
 
-	/* If either wraps around, does the new end fall beyond the old start? */
-	if (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset))
-		return_0;
+	/* If there's no existing metadata, we're OK */
+	if (!rlocn)
+		return 1;
 
-	/* Does the total amount of metadata, old and new, fit inside the buffer? */
-	if (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)
+	/* If either wraps around, there's overlap if the new end falls beyond the old start */
+	if ((new_wrap || old_wrap) && (new_end > rlocn->offset))
 		return_0;
 
 	return 1;
@@ -658,6 +665,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	struct pv_list *pvl;
 	int r = 0;
 	uint64_t new_wrap;	/* Number of bytes of new metadata that wrap around to start of buffer */
+	uint64_t alignment = MDA_ORIGINAL_ALIGNMENT;
 	int found = 0;
 	int noprecommit = 0;
 	const char *old_vg_name = NULL;
@@ -675,6 +683,12 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!found)
 		return 1;
 
+	/*
+	 * This is paired with the following closes:
+	 *  - at the end of this fn if returning 0
+	 *  - in _vg_commit_raw_rlocn regardless of return code
+	 *    which handles commit (but not pre-commit) and revert.
+	 */
 	if (!dev_open(mdac->area.dev))
 		return_0;
 
@@ -692,8 +706,10 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	mdac->rlocn.size = fidtc->raw_metadata_buf_size;
 
-	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, MDA_ORIGINAL_ALIGNMENT);
+	/* Find where the new metadata would be written with our preferred alignment */
+	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, alignment);
 
+	/* Does the new metadata wrap around? */
 	if (mdac->rlocn.offset + mdac->rlocn.size > mdah->size)
 		new_wrap = (mdac->rlocn.offset + mdac->rlocn.size) - mdah->size;
 	else
@@ -705,9 +721,9 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		goto out;
 	}
 
-	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64,
+	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64 " aligned to " FMTu64,
 			    vg->name, dev_name(mdac->area.dev), mdac->area.start +
-			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap, mdac->rlocn.size);
+			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap, mdac->rlocn.size, alignment);
 
 	/* Write text out, circularly */
 	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
@@ -837,6 +853,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 
       out:
 	if (!precommit) {
+		/* This is an paired with the open at the start of _vg_write_raw */
 		if (!dev_close(mdac->area.dev))
 			stack;
 


