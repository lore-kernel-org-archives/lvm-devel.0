From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 11 Dec 2017 12:11:12 -0500
Subject: master - format_text: Move metadata size checking into separate fn.
Message-ID: <201712111711.vBBHBC09007959@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2db67a8ea09a6f1073583e135bfb7b66228d3526
Commit:        2db67a8ea09a6f1073583e135bfb7b66228d3526
Parent:        46393bfca0692ebddbecdfb1f3b8699c3caa4f16
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Dec 11 17:08:29 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Dec 11 17:08:29 2017 +0000

format_text: Move metadata size checking into separate fn.

Move checks into _metadata_fits_into_buffer() and add macro for alignment.
---
 lib/format_text/format-text.c |   55 +++++++++++++++++++++++++++++++---------
 1 files changed, 42 insertions(+), 13 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 0dbab11..881fd4d 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -37,6 +37,12 @@
 #include <dirent.h>
 #include <ctype.h>
 
+/*
+ * Round up offset within buffer to next location that is an exact multiple of alignment.
+ * (We shouldn't assume the start of the metadata area was aligned the same way when it was created.)
+ */
+#define ALIGN_ABSOLUTE(offset, buffer_start, alignment) ((offset) + (alignment) - UINT64_C(1) - ((buffer_start) + (offset) + (alignment) - UINT64_C(1)) % (alignment))
+
 static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
 							  const struct format_instance_ctx *fic);
 
@@ -615,6 +621,34 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	return vg;
 }
 
+static int _metadata_fits_into_buffer(struct mda_context *mdac, struct mda_header *mdah,
+				      struct raw_locn *rlocn, uint64_t new_wrap)
+{
+	uint64_t old_wrap = 0;	/* Amount of wrap around in existing metadata */
+	uint64_t new_end;	/* The end location of the new metadata */
+
+	/* Do we have existing metadata that ends beyond the end of the buffer? */
+	if (rlocn && (rlocn->offset + rlocn->size > mdah->size))
+		old_wrap = (rlocn->offset + rlocn->size) - mdah->size;
+
+	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE :
+			    mdac->rlocn.offset + mdac->rlocn.size;
+
+	/* If both wrap around, there's necessarily overlap */
+	if (new_wrap && old_wrap)
+		return_0;
+
+	/* If either wraps around, does the new end fall beyond the old start? */
+	if (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset))
+		return_0;
+
+	/* Does the total amount of metadata, old and new, fit inside the buffer? */
+	if (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)
+		return_0;
+
+	return 1;
+}
+
 static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			 struct metadata_area *mda)
 {
@@ -624,7 +658,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	struct mda_header *mdah;
 	struct pv_list *pvl;
 	int r = 0;
-	uint64_t new_wrap = 0, old_wrap = 0, new_end;
+	uint64_t new_wrap;	/* Number of bytes of new metadata that wrap around to start of buffer */
 	int found = 0;
 	int noprecommit = 0;
 	const char *old_vg_name = NULL;
@@ -657,21 +691,16 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit);
 
-	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, MDA_ORIGINAL_ALIGNMENT);
 	mdac->rlocn.size = fidtc->raw_metadata_buf_size;
 
+	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, MDA_ORIGINAL_ALIGNMENT);
+
 	if (mdac->rlocn.offset + mdac->rlocn.size > mdah->size)
 		new_wrap = (mdac->rlocn.offset + mdac->rlocn.size) - mdah->size;
+	else
+		new_wrap = 0;
 
-	if (rlocn && (rlocn->offset + rlocn->size > mdah->size))
-		old_wrap = (rlocn->offset + rlocn->size) - mdah->size;
-
-	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE :
-			    mdac->rlocn.offset + mdac->rlocn.size;
-
-	if ((new_wrap && old_wrap) ||
-	    (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset)) ||
-	    (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)) {
+	if (!_metadata_fits_into_buffer(mdac, mdah, rlocn, new_wrap)) {
 		log_error("VG %s metadata on %s (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes with " FMTu64 " used)",
 			  vg->name, dev_name(mdac->area.dev), mdac->rlocn.size, mdah->size - MDA_HEADER_SIZE, rlocn ? rlocn->size : 0);
 		goto out;
@@ -1263,8 +1292,8 @@ int vgname_from_mda(const struct format_type *fmt,
 			   (char *)&vgsummary->vgid);
 
 	if (mda_free_sectors) {
-		current_usage = (rlocn->size + SECTOR_SIZE - UINT64_C(1)) -
-				 (rlocn->size + SECTOR_SIZE - UINT64_C(1)) % SECTOR_SIZE;
+		current_usage = ALIGN_ABSOLUTE(rlocn->size, 0, MDA_ORIGINAL_ALIGNMENT);
+
 		buffer_size = mdah->size - MDA_HEADER_SIZE;
 
 		if (current_usage * 2 >= buffer_size)


