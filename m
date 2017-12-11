From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 11 Dec 2017 11:09:40 -0500
Subject: master - format_text: Log additional circular buffer information.
Message-ID: <201712111609.vBBG9ex7030379@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46393bfca0692ebddbecdfb1f3b8699c3caa4f16
Commit:        46393bfca0692ebddbecdfb1f3b8699c3caa4f16
Parent:        49d486319fa6cb48e693c364ee6d72e4b6c364d2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Dec 11 15:59:40 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Dec 11 16:07:34 2017 +0000

format_text: Log additional circular buffer information.

---
 lib/format_text/format-text.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index adaf0a8..0dbab11 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -541,8 +541,8 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
 	if (wrap > rlocn->offset) {
-		log_error("VG %s metadata too large for circular buffer",
-			  vgname);
+		log_error("VG %s metadata on %s (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes)",
+			  vgname, dev_name(area->dev), rlocn->size, mdah->size - MDA_HEADER_SIZE);
 		goto out;
 	}
 
@@ -672,14 +672,14 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if ((new_wrap && old_wrap) ||
 	    (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset)) ||
 	    (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)) {
-		log_error("VG %s metadata too large for circular buffer",
-			  vg->name);
+		log_error("VG %s metadata on %s (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes with " FMTu64 " used)",
+			  vg->name, dev_name(mdac->area.dev), mdac->rlocn.size, mdah->size - MDA_HEADER_SIZE, rlocn ? rlocn->size : 0);
 		goto out;
 	}
 
-	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64,
+	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64,
 			    vg->name, dev_name(mdac->area.dev), mdac->area.start +
-			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap);
+			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap, mdac->rlocn.size);
 
 	/* Write text out, circularly */
 	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
@@ -688,9 +688,9 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		goto_out;
 
 	if (new_wrap) {
-		log_debug_metadata("Writing wrapped metadata to %s at " FMTu64 " len " FMTu64,
+		log_debug_metadata("Writing wrapped metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64,
 				  dev_name(mdac->area.dev), mdac->area.start +
-				  MDA_HEADER_SIZE, new_wrap);
+				  MDA_HEADER_SIZE, new_wrap, mdac->rlocn.size);
 
 		if (!dev_write(mdac->area.dev, mdac->area.start + MDA_HEADER_SIZE,
 			       (size_t) new_wrap, MDA_CONTENT_REASON(mda_is_primary(mda)),
@@ -1228,8 +1228,8 @@ int vgname_from_mda(const struct format_type *fmt,
 		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
 	if (wrap > rlocn->offset) {
-		log_error("%s: metadata too large for circular buffer",
-			  dev_name(dev_area->dev));
+		log_error("%s: metadata (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes)",
+			  dev_name(dev_area->dev), rlocn->size, mdah->size - MDA_HEADER_SIZE);
 		return 0;
 	}
 


