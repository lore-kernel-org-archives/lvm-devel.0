From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 11 Dec 2017 16:00:37 -0500
Subject: master - format_text: Adjust metadata alignment calculation.
Message-ID: <201712112100.vBBL0bhO008041@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b76c6951aa5c41b19fc34342ea2e946d7e0a3d24
Commit:        b76c6951aa5c41b19fc34342ea2e946d7e0a3d24
Parent:        053d35de473aafe641f595b1182626ea39fc0ab0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Dec 11 20:25:03 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Dec 11 20:25:03 2017 +0000

format_text: Adjust metadata alignment calculation.

Use new ALIGN_ABSOLUTE macro when calculating the start location
of new metadata and adjust the end of buffer detection so that
there is no longer an imposed gap between old and new metadata.
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |   18 ++++++++----------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6f13fe3..9ff8b51 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Refactor and adjust text format metadata alignment calculation.
   Fix python3 path in lvmdbusd to use value detected by configure.
   Reduce checks for active LVs in vgchange before background polling.
   Ensure _node_send_message always uses clean status of thin pool.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c226131..154d748 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -487,12 +487,11 @@ static uint64_t _next_rlocn_offset(struct raw_locn *rlocn, struct mda_header *md
 		/* FIXME Assume only one VG per mdah for now */
 		return alignment;
 
-	/* Calculate new start position within buffer rounded up to absolute alignment */
-	new_start_offset = rlocn->offset + rlocn->size +
-			   (alignment - (mdac_area_start + rlocn->offset + rlocn->size) % alignment);
+	/* Calculate new start position relative to start of buffer rounded up to absolute alignment */
+	new_start_offset = ALIGN_ABSOLUTE(rlocn->offset + rlocn->size, mdac_area_start, alignment);
 
 	/* If new location is beyond the end of the buffer, wrap around back to start of circular buffer */
-	if (new_start_offset > mdah->size - MDA_HEADER_SIZE)
+	if (new_start_offset >= mdah->size)
 		new_start_offset -= (mdah->size - MDA_HEADER_SIZE);
 
 	return new_start_offset;
@@ -816,10 +815,9 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 		rlocn->offset = mdac->rlocn.offset;
 		rlocn->size = mdac->rlocn.size;
 		rlocn->checksum = mdac->rlocn.checksum;
-		log_debug_metadata("%sCommitting %s %smetadata (%u) to %s header at "
-			  FMTu64, precommit ? "Pre-" : "", vg->name, 
-			  mda_is_ignored(mda) ? "(ignored) " : "", vg->seqno,
-			  dev_name(mdac->area.dev), mdac->area.start);
+		log_debug_metadata("%sCommitting %s %smetadata (%u) to %s header at " FMTu64 " (offset " FMTu64 ", size " FMTu64 ")",
+				   precommit ? "Pre-" : "", vg->name, mda_is_ignored(mda) ? "(ignored) " : "", vg->seqno,
+				   dev_name(mdac->area.dev), mdac->area.start, mdac->rlocn.offset, mdac->rlocn.size);
 	} else
 		log_debug_metadata("Wiping pre-committed %s %smetadata from %s "
 				   "header at " FMTu64, vg->name,
@@ -1282,13 +1280,13 @@ int vgname_from_mda(const struct format_type *fmt,
 	if (!validate_name(vgsummary->vgname))
 		return_0;
 
-	log_debug_metadata("%s: %s metadata at " FMTu64 " size " FMTu64
+	log_debug_metadata("%s: %s metadata at " FMTu64 " size " FMTu64 " with wrap " FMTu32
 			   " (in area at " FMTu64 " size " FMTu64
 			   ") for %s (" FMTVGID ")",
 			   dev_name(dev_area->dev),
 			   used_cached_metadata ? "Using cached" : "Found",
 			   dev_area->start + rlocn->offset,
-			   rlocn->size, dev_area->start, dev_area->size, vgsummary->vgname,
+			   rlocn->size, wrap, dev_area->start, dev_area->size, vgsummary->vgname,
 			   (char *)&vgsummary->vgid);
 
 	if (mda_free_sectors) {


