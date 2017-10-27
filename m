From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 27 Oct 2017 17:55:42 -0400
Subject: master - metadata: Avoid accessing ignored metadata.
Message-ID: <201710272155.v9RLtg5L007412@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52fd66210b120bf1185fbbc91b6bc487d99dd33a
Commit:        52fd66210b120bf1185fbbc91b6bc487d99dd33a
Parent:        84aca4201e3588159e75fa8e047e997c2fad13d2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 27 22:42:00 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 27 22:53:43 2017 +0100

metadata: Avoid accessing ignored metadata.

When an ignored metadata area gets flagged for use again, make sure the
code doesn't try to parse its old metadata.  Firstly by trying to detect
this situation and skipping the read (while still remembering the
position reached in the circular buffer), and secondly by clearing the
invalid live metadata location on disk as a precaution when subsequently
writing out the precommitted metadata.

Problems showed up when a metadata area in one VG got moved to
another VG in ignored state (still holding metadata for the original
VG) and then later got brought into use in the new VG - only the header
should be read in this case, not any of the metadata content.
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |   28 ++++++++++++++++++++++++----
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3e13d8c..4d1a6a8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Avoid reading ignored metadata when mda gets used again.
   Fix detection of moved PVs in vgsplit. (2.02.175)
   Ignore --stripes/--stripesize on RAID takeover
   Improve used paths for generated systemd units and init shells.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 3e1ca19..797ead0 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -414,12 +414,15 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	struct lvmcache_vgsummary vgsummary_orphan = {
 		.vgname = FMT_TEXT_ORPHAN_VG_NAME,
 	};
+	int rlocn_was_ignored;
 
 	memcpy(&vgsummary_orphan.vgid, FMT_TEXT_ORPHAN_VG_NAME, sizeof(FMT_TEXT_ORPHAN_VG_NAME));
 
 	rlocn = mdah->raw_locns;	/* Slot 0 */
 	rlocn_precommitted = rlocn + 1;	/* Slot 1 */
 
+	rlocn_was_ignored = rlocn_is_ignored(rlocn);
+
 	/* Should we use precommitted metadata? */
 	if (*precommitted && rlocn_precommitted->size &&
 	    (rlocn_precommitted->offset != rlocn->offset)) {
@@ -438,6 +441,12 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	if (!*vgname)
 		return rlocn;
 
+	/*
+	 * If live rlocn has ignored flag, data will be out-of-date so skip further checks.
+	 */
+	if (rlocn_was_ignored)
+		return rlocn;
+
 	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
 	/* FIXME Ignore if checksum incorrect!!! */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
@@ -448,8 +457,9 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
 		return rlocn;
 
-	log_debug_metadata("Volume group name found in metadata on %s at %" PRIu64 " does "
+	log_debug_metadata("Volume group name found in %smetadata on %s at %" PRIu64 " does "
 			   "not match expected name %s.", 
+			   *precommitted ? "precommitted " : "",
 			   dev_name(dev_area->dev), dev_area->start + rlocn->offset, vgname);
 
       bad:
@@ -750,6 +760,14 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 		mdah->raw_locns[2].size = 0;
 		mdah->raw_locns[2].checksum = 0;
 		rlocn = &mdah->raw_locns[0];
+	} else if (precommit && rlocn_is_ignored(rlocn) && !mda_is_ignored(mda)) {
+		/*
+		 * If precommitting into a previously-ignored mda, wipe the live rlocn
+		 * as a precaution so that nothing can use it by mistake.
+		 */
+		mdah->raw_locns[0].offset = 0;
+		mdah->raw_locns[0].size = 0;
+		mdah->raw_locns[0].checksum = 0;
 	}
 
 	if (precommit)
@@ -766,12 +784,14 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 		rlocn->offset = mdac->rlocn.offset;
 		rlocn->size = mdac->rlocn.size;
 		rlocn->checksum = mdac->rlocn.checksum;
-		log_debug_metadata("%sCommitting %s metadata (%u) to %s header at %"
-			  PRIu64, precommit ? "Pre-" : "", vg->name, vg->seqno,
+		log_debug_metadata("%sCommitting %s %smetadata (%u) to %s header at %"
+			  PRIu64, precommit ? "Pre-" : "", vg->name, 
+			  mda_is_ignored(mda) ? "(ignored) " : "", vg->seqno,
 			  dev_name(mdac->area.dev), mdac->area.start);
 	} else
-		log_debug_metadata("Wiping pre-committed %s metadata from %s "
+		log_debug_metadata("Wiping pre-committed %s %smetadata from %s "
 				   "header at %" PRIu64, vg->name,
+				   mda_is_ignored(mda) ? "(ignored) " : "",
 				   dev_name(mdac->area.dev), mdac->area.start);
 
 	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));


