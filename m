From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 7 Dec 2017 20:20:59 -0500
Subject: master - format_text: Use explicit alignment in wrapping calc.
Message-ID: <201712080120.vB81KxHS015312@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14b1e5270dbca71870a79b37d6614e2cb96b180f
Commit:        14b1e5270dbca71870a79b37d6614e2cb96b180f
Parent:        4c88c4626d9870d4fa146f7596a37853cf965a39
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Dec 8 01:11:34 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Dec 8 01:18:46 2017 +0000

format_text: Use explicit alignment in wrapping calc.

Expand out the metadata wrapping calculations to prepare
to support a larger alignment.

The current alignment is 512 bytes so
(mdac_area_start + rlocn->offset) % alignment is zero.
---
 lib/format_text/format-text.c |   29 +++++++++++++++++------------
 lib/format_text/layout.h      |    1 +
 2 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 09ce693..c96fad9 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -472,19 +472,24 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 /*
  * Determine offset for uncommitted metadata
  */
-static uint64_t _next_rlocn_offset(struct raw_locn *rlocn,
-				   struct mda_header *mdah)
+static uint64_t _next_rlocn_offset(struct raw_locn *rlocn, struct mda_header *mdah, uint64_t mdac_area_start, uint64_t alignment)
 {
+	uint64_t new_start_offset;
+
 	if (!rlocn)
 		/* Find an empty slot */
 		/* FIXME Assume only one VG per mdah for now */
-		return MDA_HEADER_SIZE;
+		return alignment;
+
+	/* Calculate new start position within buffer rounded up to absolute alignment */
+	new_start_offset = rlocn->offset + rlocn->size +
+			   (alignment - (mdac_area_start + rlocn->offset + rlocn->size) % alignment);
 
-	/* Start of free space - round up to next sector; circular */
-	return ((rlocn->offset + rlocn->size +
-		(SECTOR_SIZE - rlocn->size % SECTOR_SIZE) -
-		MDA_HEADER_SIZE) % (mdah->size - MDA_HEADER_SIZE))
-	       + MDA_HEADER_SIZE;
+	/* If new location is beyond the end of the buffer, wrap around back to start of circular buffer */
+	if (new_start_offset > mdah->size - MDA_HEADER_SIZE)
+		new_start_offset -= (mdah->size - MDA_HEADER_SIZE);
+
+	return new_start_offset;
 }
 
 static int _raw_holds_vgname(struct format_instance *fid,
@@ -643,9 +648,6 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
-	rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit);
-	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah);
-
 	if (!fidtc->raw_metadata_buf &&
 	    !(fidtc->raw_metadata_buf_size =
 			text_vg_export_raw(vg, "", &fidtc->raw_metadata_buf))) {
@@ -653,6 +655,9 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		goto out;
 	}
 
+	rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit);
+
+	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, MDA_ORIGINAL_ALIGNMENT);
 	mdac->rlocn.size = fidtc->raw_metadata_buf_size;
 
 	if (mdac->rlocn.offset + mdac->rlocn.size > mdah->size)
@@ -683,7 +688,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		goto_out;
 
 	if (new_wrap) {
-		log_debug_metadata("Writing metadata to %s at %" PRIu64 " len %" PRIu64,
+		log_debug_metadata("Writing wrapped metadata to %s at %" PRIu64 " len %" PRIu64,
 				  dev_name(mdac->area.dev), mdac->area.start +
 				  MDA_HEADER_SIZE, new_wrap);
 
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index c88812f..1746b9c 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -102,6 +102,7 @@ struct mda_context {
 #define MDA_HEADER_SIZE 512
 #define LVM2_LABEL "LVM2 001"
 #define MDA_SIZE_MIN (8 * (unsigned) lvm_getpagesize())
+#define MDA_ORIGINAL_ALIGNMENT 512	/* Original alignment used for start of VG metadata content */
 
 int vgname_from_mda(const struct format_type *fmt, struct mda_header *mdah, int primary_mda, 
 		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,


