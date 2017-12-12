From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 12 Dec 2017 16:24:47 -0500
Subject: master - format_text: More refactoring of metadata offset calcs
Message-ID: <201712122124.vBCLOl9D022364@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=643df602c7d199c15ba27958e51e61b822a14755
Commit:        643df602c7d199c15ba27958e51e61b822a14755
Parent:        4002f5e206ae89db28eb60bdfb3685bd926fed57
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 12 18:46:25 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 12 18:51:32 2017 +0000

format_text: More refactoring of metadata offset calcs

---
 lib/format_text/format-text.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 174a579..0c5dd1b 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -482,15 +482,24 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
  */
 static uint64_t _next_rlocn_offset(struct raw_locn *rlocn, struct mda_header *mdah, uint64_t mdac_area_start, uint64_t alignment)
 {
-	uint64_t new_start_offset;
+	uint64_t old_end, new_start_offset;
+	int old_wrapped = 0;	/* Does the old metadata wrap around? */
 
 	if (!rlocn)
 		/* Find an empty slot */
 		/* FIXME Assumes only one VG per mdah for now */
 		return alignment;
 
+	/* First find the end of the old metadata */
+	old_end = rlocn->offset + rlocn->size;
+
+	if (old_end > mdah->size) {
+		old_wrapped = 1;
+		old_end -= (mdah->size - MDA_HEADER_SIZE);
+	}
+
 	/* Calculate new start position relative to start of buffer rounded up to absolute alignment */
-	new_start_offset = ALIGN_ABSOLUTE(rlocn->offset + rlocn->size, mdac_area_start, alignment);
+	new_start_offset = ALIGN_ABSOLUTE(old_end, mdac_area_start, alignment);
 
 	/* If new location is beyond the end of the buffer, wrap around back to start of circular buffer */
 	if (new_start_offset >= mdah->size)
@@ -626,16 +635,23 @@ static int _metadata_fits_into_buffer(struct mda_context *mdac, struct mda_heade
 				      struct raw_locn *rlocn, uint64_t new_wrap)
 {
 	uint64_t old_wrap = 0;	/* Amount of wrap around in existing metadata */
-	uint64_t new_end;	/* The end location of the new metadata */
+	uint64_t old_end = 0;	/* The (byte after the) end of the existing metadata */
+	uint64_t new_end;	/* The (byte after the) end of the new metadata */
+	uint64_t old_start = 0;	/* The start of the existing metadata */
+	uint64_t new_start = mdac->rlocn.offset;	/* The proposed start of the new metadata */
 
 	/* Does the total amount of metadata, old and new, fit inside the buffer? */
 	if (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)
 		return_0;
 
-	/* Does the existing metadata wrap around the end of the buffer? */
+	/* If there's existing metadata, set old_start, old_end and old_wrap. */
 	if (rlocn) {
-		if (rlocn->offset + rlocn->size > mdah->size)
-			old_wrap = (rlocn->offset + rlocn->size) - mdah->size;
+		old_start = rlocn->offset;
+		old_end = old_start + rlocn->size;
+
+		/* Does the existing metadata wrap around the end of the buffer? */
+		if (old_end > mdah->size)
+			old_wrap = old_end - mdah->size;
 	}
 
 	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE : (mdac->rlocn.offset + mdac->rlocn.size);
@@ -649,7 +665,7 @@ static int _metadata_fits_into_buffer(struct mda_context *mdac, struct mda_heade
 		return 1;
 
 	/* If either wraps around, there's overlap if the new end falls beyond the old start */
-	if ((new_wrap || old_wrap) && (new_end > rlocn->offset))
+	if ((new_wrap || old_wrap) && (new_end > old_start))
 		return_0;
 
 	return 1;


