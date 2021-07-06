From: David Teigland <teigland@sourceware.org>
Date: Tue,  6 Jul 2021 15:10:58 +0000 (GMT)
Subject: main - scan: retry reading metadata on error
Message-ID: <20210706151058.22D1A388CC01@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e035e323508383fdcd9df0ef036d276a9c9909ab
Commit:        e035e323508383fdcd9df0ef036d276a9c9909ab
Parent:        d89942d157e49168d069a65f77a6ecb2c155b3fb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 28 18:10:47 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 6 10:10:23 2021 -0500

scan: retry reading metadata on error

If label_scan encounters bad vg metadata, invalidate
bcache data for the device and reread the mda_header
and metadata text back to back.  With concurrent commands
modifying large metadata, it's possible that the entire
metadata area can be rewritten in the time between a
command reading the mda_header and reading the metadata
text that the header points to.  Since the label_scan
is just assembling an initial overview of devices, it
doesn't use locking to serialize with other commands
that may be modifying the vg metadata at the same time.
---
 lib/format_text/format-text.c |  8 ++++++++
 lib/format_text/text_label.c  | 35 +++++++++++++++++++++++++++++++++++
 lib/label/label.c             |  5 +++++
 lib/label/label.h             |  1 +
 4 files changed, 49 insertions(+)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 64ad4677c..dd550a6eb 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1563,6 +1563,14 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
+	/*
+	 * This code reading the start of the metadata area and verifying that
+	 * it looks like a vgname can be removed.  The checksum verifies it.
+	 */
+	log_debug_metadata("Reading metadata_vgname summary from %s at %llu",
+			   dev_name(dev_area->dev),
+			   (unsigned long long)(dev_area->start + rlocn->offset));
+
 	memset(namebuf, 0, sizeof(namebuf));
 
 	if (!dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, namebuf))
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index be5195039..7bc7a1ed3 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -327,6 +327,9 @@ static int _read_mda_header_and_metadata(const struct format_type *fmt,
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
+	int retries = 0;
+
+ retry:
 
 	if (!(mdah = raw_read_mda_header(fmt, &mdac->area, (mda->mda_num == 1), 0, bad_fields))) {
 		log_warn("WARNING: bad metadata header on %s at %llu.",
@@ -354,6 +357,38 @@ static int _read_mda_header_and_metadata(const struct format_type *fmt,
 		if (vgsummary->zero_offset)
 			return 1;
 
+		/*
+		 * This code is used by label_scan to get a summary of the
+		 * VG metadata that will be properly read later by vg_read.
+		 * The initial read of this device during label_scan
+		 * populates bcache with the first 128K of data from the
+		 * device.  That block of data contains the mda_header
+		 * (at 4k) but will often not include the metadata text,
+		 * which is often located further into the metadata area
+		 * (beyond the 128K block saved in bcache.)
+		 * So read_metadata_location_summary will usually get the
+		 * mda_header from bcache which was read initially, and
+		 * then it will often need to do a new disk read to get
+		 * the actual metadata text that the mda_header points to.
+		 * Since there is no locking around label_scan, it's
+		 * possible (but very rare) that the entire metadata area
+		 * can be rewritten by other commands between the time that
+		 * this command read the mda_header and the time that it
+		 * reads the metadata text.  This means the expected metadata
+		 * text isn't found, and an error is returned here.
+		 * To handle this, invalidate all data in bcache for this
+		 * device and reread the mda_header and metadata text back to
+		 * back, so inconsistency is less likely (without locking
+		 * there's no guarantee, e.g. if the command is blocked
+		 * somehow between the two reads.)
+		 */
+		if (!retries) {
+			log_print("Retrying metadata scan.");
+			retries++;
+			dev_invalidate(mdac->area.dev);
+			goto retry;
+		}
+
 		log_warn("WARNING: bad metadata text on %s in mda%d",
 			 dev_name(mdac->area.dev), mda->mda_num);
 		*bad_fields |= BAD_MDA_TEXT;
diff --git a/lib/label/label.c b/lib/label/label.c
index 50107edc8..ac84b6293 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1704,6 +1704,11 @@ bool dev_invalidate_bytes(struct device *dev, uint64_t start, size_t len)
 	return bcache_invalidate_bytes(scan_bcache, dev->bcache_di, start, len);
 }
 
+void dev_invalidate(struct device *dev)
+{
+	bcache_invalidate_di(scan_bcache, dev->bcache_di);
+}
+
 bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 {
 	return dev_set_bytes(dev, start, len, 0);
diff --git a/lib/label/label.h b/lib/label/label.h
index fcdc309ac..32ceebc34 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -130,6 +130,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 bool dev_write_zeros(struct device *dev, uint64_t start, size_t len);
 bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val);
 bool dev_invalidate_bytes(struct device *dev, uint64_t start, size_t len);
+void dev_invalidate(struct device *dev);
 void dev_set_last_byte(struct device *dev, uint64_t offset);
 void dev_unset_last_byte(struct device *dev);
 


