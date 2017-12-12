From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 12 Dec 2017 16:24:52 -0500
Subject: master - format_text: Change metadata alignment from 512 to 4096.
Message-ID: <201712122124.vBCLOqMZ022374@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=78ffa44fc58fba6f4e8d2046798783d7f4f11b41
Commit:        78ffa44fc58fba6f4e8d2046798783d7f4f11b41
Parent:        643df602c7d199c15ba27958e51e61b822a14755
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 12 20:57:36 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 12 20:57:36 2017 +0000

format_text: Change metadata alignment from 512 to 4096.

If there is sufficient space in the metadata area, align the next
metadata to a disk offset that is a multiple of 4096 bytes and
don't write it circularly.  If it doesn't all fit at the end
of the metadata area, go back to the start and write it all there
contiguously.

If there is insufficient space to use the new stricter rules, revert to
the original behaviour, aligning on 512-byte boundaries wrapping around
the circular buffer as required.
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |   70 ++++++++++++++++++++++++++++++++---------
 lib/format_text/layout.h      |    1 +
 3 files changed, 57 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f6ead67..f871377 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Change text format metadata alignment from 512 to 4096 bytes.
   When writing metadata, consistently skip mdas marked as failed.
   Refactor and adjust text format metadata alignment calculation.
   Fix python3 path in lvmdbusd to use value detected by configure.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 0c5dd1b..ea31a2f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -488,7 +488,7 @@ static uint64_t _next_rlocn_offset(struct raw_locn *rlocn, struct mda_header *md
 	if (!rlocn)
 		/* Find an empty slot */
 		/* FIXME Assumes only one VG per mdah for now */
-		return alignment;
+		return ALIGN_ABSOLUTE(MDA_HEADER_SIZE, mdac_area_start, alignment);
 
 	/* First find the end of the old metadata */
 	old_end = rlocn->offset + rlocn->size;
@@ -501,10 +501,21 @@ static uint64_t _next_rlocn_offset(struct raw_locn *rlocn, struct mda_header *md
 	/* Calculate new start position relative to start of buffer rounded up to absolute alignment */
 	new_start_offset = ALIGN_ABSOLUTE(old_end, mdac_area_start, alignment);
 
-	/* If new location is beyond the end of the buffer, wrap around back to start of circular buffer */
-	if (new_start_offset >= mdah->size)
-		new_start_offset -= (mdah->size - MDA_HEADER_SIZE);
+	/* If new location is beyond the end of the buffer, return to start of circular buffer and realign */
+	if (new_start_offset >= mdah->size) {
+		/* If the start of the buffer is occupied, move past it */
+		if (old_wrapped || rlocn->offset == MDA_HEADER_SIZE)
+			new_start_offset = old_end;
+		else
+			new_start_offset = MDA_HEADER_SIZE;
+ 
+		new_start_offset = ALIGN_ABSOLUTE(new_start_offset, mdac_area_start, alignment);
+	}
 
+	/*
+	 * Note that we don't check here that this location isn't inside the existing metadata.
+	 * If it is, then it means this value of alignment cannot be used.
+	 */
 	return new_start_offset;
 }
 
@@ -640,6 +651,15 @@ static int _metadata_fits_into_buffer(struct mda_context *mdac, struct mda_heade
 	uint64_t old_start = 0;	/* The start of the existing metadata */
 	uint64_t new_start = mdac->rlocn.offset;	/* The proposed start of the new metadata */
 
+	/*
+	 * If the (aligned) start of the new metadata is already beyond the end
+	 * of the buffer this means it didn't fit with the given alignment.
+	 * (The caller has already tried to wrap it back to the start
+	 * of the buffer but the alignment pushed it back outside.)
+	 */
+	if (new_start >= mdah->size)
+		return_0;
+
 	/* Does the total amount of metadata, old and new, fit inside the buffer? */
 	if (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)
 		return_0;
@@ -654,7 +674,7 @@ static int _metadata_fits_into_buffer(struct mda_context *mdac, struct mda_heade
 			old_wrap = old_end - mdah->size;
 	}
 
-	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE : (mdac->rlocn.offset + mdac->rlocn.size);
+	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE : new_start + mdac->rlocn.size;
 
 	/* If both wrap around, there's necessarily overlap */
 	if (new_wrap && old_wrap)
@@ -668,6 +688,10 @@ static int _metadata_fits_into_buffer(struct mda_context *mdac, struct mda_heade
 	if ((new_wrap || old_wrap) && (new_end > old_start))
 		return_0;
 
+	/* If there's no wrap, check there's no overlap */
+	if (!new_wrap && !old_wrap && (old_end > new_start) && (old_start < new_end))
+		return_0;
+
 	return 1;
 }
 
@@ -681,7 +705,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	struct pv_list *pvl;
 	int r = 0;
 	uint64_t new_wrap;	/* Number of bytes of new metadata that wrap around to start of buffer */
-	uint64_t alignment = MDA_ORIGINAL_ALIGNMENT;
+	uint64_t alignment = MDA_ALIGNMENT;
 	int found = 0;
 	int noprecommit = 0;
 	const char *old_vg_name = NULL;
@@ -725,16 +749,32 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	/* Find where the new metadata would be written with our preferred alignment */
 	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, alignment);
 
-	/* Does the new metadata wrap around? */
+	/* If metadata extends beyond the buffer, return to the start instead of wrapping it */
 	if (mdac->rlocn.offset + mdac->rlocn.size > mdah->size)
-		new_wrap = (mdac->rlocn.offset + mdac->rlocn.size) - mdah->size;
-	else
-		new_wrap = 0;
+		mdac->rlocn.offset = ALIGN_ABSOLUTE(MDA_HEADER_SIZE, mdac->area.start, alignment);
 
-	if (!_metadata_fits_into_buffer(mdac, mdah, rlocn, new_wrap)) {
-		log_error("VG %s metadata on %s (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes with " FMTu64 " used)",
-			  vg->name, dev_name(mdac->area.dev), mdac->rlocn.size, mdah->size - MDA_HEADER_SIZE, rlocn ? rlocn->size : 0);
-		goto out;
+	/*
+	 * If the metadata doesn't fit into the buffer correctly with these
+	 * settings, fall back to the 512-byte alignment used by the original
+	 * LVM2 code and allow the metadata to be split into two parts,
+	 * wrapping around from the end of the circular buffer back to the
+	 * beginning.
+	 */
+	if (!_metadata_fits_into_buffer(mdac, mdah, rlocn, 0)) {
+		alignment = MDA_ORIGINAL_ALIGNMENT;
+		mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, alignment);
+
+		/* Does the new metadata wrap around? */
+		if (mdac->rlocn.offset + mdac->rlocn.size > mdah->size)
+			new_wrap = (mdac->rlocn.offset + mdac->rlocn.size) - mdah->size;
+		else
+			new_wrap = 0;
+
+		if (!_metadata_fits_into_buffer(mdac, mdah, rlocn, new_wrap)) {
+			log_error("VG %s metadata on %s (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes with " FMTu64 " used)",
+				  vg->name, dev_name(mdac->area.dev), mdac->rlocn.size, mdah->size - MDA_HEADER_SIZE, rlocn ? rlocn->size : 0);
+			goto out;
+		}
 	}
 
 	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64 " aligned to " FMTu64,
@@ -1323,7 +1363,7 @@ int vgname_from_mda(const struct format_type *fmt,
 			   (char *)&vgsummary->vgid);
 
 	if (mda_free_sectors) {
-		current_usage = ALIGN_ABSOLUTE(rlocn->size, dev_area->start + rlocn->offset, MDA_ORIGINAL_ALIGNMENT);
+		current_usage = ALIGN_ABSOLUTE(rlocn->size, dev_area->start + rlocn->offset, MDA_ALIGNMENT);
 
 		buffer_size = mdah->size - MDA_HEADER_SIZE;
 
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 1746b9c..1eed664 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -103,6 +103,7 @@ struct mda_context {
 #define LVM2_LABEL "LVM2 001"
 #define MDA_SIZE_MIN (8 * (unsigned) lvm_getpagesize())
 #define MDA_ORIGINAL_ALIGNMENT 512	/* Original alignment used for start of VG metadata content */
+#define MDA_ALIGNMENT 4096	/* Default alignment in bytes since 2.02.177 for start of VG metadata content. */
 
 int vgname_from_mda(const struct format_type *fmt, struct mda_header *mdah, int primary_mda, 
 		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,


