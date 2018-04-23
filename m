From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:51 -0400
Subject: master - scan: check for errors in text layer
Message-ID: <201804231355.w3NDtpu6001835@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=196579af1f7ebe25c0266043c7d966b344699d5d
Commit:        196579af1f7ebe25c0266043c7d966b344699d5d
Parent:        44726ed9cb9559801868ade5440d9e6ea6a61127
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 1 12:42:18 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

scan: check for errors in text layer

The scanning code in the format_text layer
has previously ignored errors.  Start checking
for and returning them.
---
 lib/format_text/format-text.c |    5 ++++-
 lib/format_text/text_label.c  |   38 ++++++++++++++++++++++----------------
 2 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 4a9c303..4146e7c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -536,8 +536,10 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	char *desc;
 	uint32_t wrap = 0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, area, primary_mda)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, area, primary_mda))) {
+		log_error("Failed to read vg %s from %s", vgname, dev_name(area->dev));
 		goto_out;
+	}
 
 	if (!(rlocn = _read_metadata_location_vg(area, mdah, primary_mda, vgname, &precommitted))) {
 		log_debug_metadata("VG %s not found on %s", vgname, dev_name(area->dev));
@@ -1213,6 +1215,7 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		log_debug_metadata("Metadata location on %s at %llu has offset 0.",
 				   dev_name(dev_area->dev),
 				   (unsigned long long)(dev_area->start + rlocn->offset));
+		vgsummary->zero_offset = 1;
 		return 0;
 	}
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 206ae3f..e65079e 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -331,16 +331,9 @@ static int _read_mda_header_and_metadata(struct metadata_area *mda, void *baton)
 	struct mda_header *mdah;
 	struct lvmcache_vgsummary vgsummary = { 0 };
 
-	/*
-	 * Using the labeller struct to preserve info about
-	 * the last parsed vgname, vgid, creation host
-	 *
-	 * TODO: make lvmcache smarter and move this cache logic there
-	 */
-
 	if (!(mdah = raw_read_mda_header(fmt, &mdac->area, mda_is_primary(mda)))) {
-		stack;
-		goto close_dev;
+		log_error("Failed to read mda header from %s", dev_name(mdac->area.dev));
+		goto fail;
 	}
 
 	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
@@ -352,14 +345,25 @@ static int _read_mda_header_and_metadata(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	if (read_metadata_location_summary(fmt, mdah, mda_is_primary(mda), &mdac->area, &vgsummary,
-			     &mdac->free_sectors) &&
-	    !lvmcache_update_vgname_and_id(p->info, &vgsummary)) {
-		return_0;
+	if (!read_metadata_location_summary(fmt, mdah, mda_is_primary(mda), &mdac->area,
+					    &vgsummary, &mdac->free_sectors)) {
+		if (vgsummary.zero_offset)
+			return 1;
+
+		log_error("Failed to read metadata summary from %s", dev_name(mdac->area.dev));
+		goto fail;
+	}
+
+	if (!lvmcache_update_vgname_and_id(p->info, &vgsummary)) {
+		log_error("Failed to save lvm summary for %s", dev_name(mdac->area.dev));
+		goto fail;
 	}
 
-close_dev:
 	return 1;
+
+fail:
+	lvmcache_del(p->info);
+	return 0;
 }
 
 static int _text_read(struct labeller *l, struct device *dev, void *label_buf,
@@ -434,10 +438,12 @@ out:
 	baton.info = info;
 	baton.label = *label;
 
-	lvmcache_foreach_mda(info, _read_mda_header_and_metadata, &baton);
+	if (!lvmcache_foreach_mda(info, _read_mda_header_and_metadata, &baton)) {
+		log_error("Failed to scan VG from %s", dev_name(dev));
+		return 0;
+	}
 
 	lvmcache_make_valid(info);
-
 	return 1;
 }
 


