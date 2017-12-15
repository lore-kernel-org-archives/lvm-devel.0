From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 15 Dec 2017 16:18:33 -0500
Subject: master - format_text: Separate out code paths for buffer wraparound
Message-ID: <201712152118.vBFLIXsv015351@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=beee9940a503dd6165afd73835d3a6935afcce60
Commit:        beee9940a503dd6165afd73835d3a6935afcce60
Parent:        145ded10c29a2e76ea12aab98a797e79135d6d44
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Dec 15 21:12:19 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Dec 15 21:12:19 2017 +0000

format_text: Separate out code paths for buffer wraparound

The creation of wrapped around metadata - where the start of metadata is
written up to the end of the buffer and the remainder follows back at
the start of the buffer - is now restricted to cases where writing the
metadata in one piece wouldn't fit.  This shouldn't happen in 'normal'
usage so let's begin treating the code for this as a special case that
can be ignored when optimising 'normal' cases.
---
 lib/config/config.c           |   27 +++++++++++++++++++--------
 lib/device/dev-io.c           |    9 +--------
 lib/format_text/format-text.c |   10 ++++++++--
 3 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 8fca372..f634e5b 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -504,6 +504,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 	int use_mmap = 1;
 	off_t mmap_offset = 0;
 	char *buf = NULL;
+	unsigned circular = size2 ? 1 : 0;	/* Wrapped around end of disk metadata buffer? */
 	struct config_source *cs = dm_config_get_custom(cft);
 
 	if (!_is_file_based_config_source(cs->type)) {
@@ -514,7 +515,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 	}
 
 	/* Only use mmap with regular files */
-	if (!(dev->flags & DEV_REGULAR) || size2)
+	if (!(dev->flags & DEV_REGULAR) || circular)
 		use_mmap = 0;
 
 	if (use_mmap) {
@@ -528,13 +529,23 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 		}
 		fb = fb + mmap_offset;
 	} else {
-		if (!(buf = dm_malloc(size + size2))) {
-			log_error("Failed to allocate circular buffer.");
-			return 0;
-		}
-		if (!dev_read_circular(dev, (uint64_t) offset, size,
-				       (uint64_t) offset2, size2, reason, buf)) {
-			goto out;
+		if (circular) {
+			if (!(buf = dm_malloc(size + size2))) {
+				log_error("Failed to allocate circular buffer.");
+				return 0;
+			}
+			if (!dev_read_circular(dev, (uint64_t) offset, size,
+					       (uint64_t) offset2, size2, reason, buf)) {
+				goto out;
+			}
+		} else {
+			if (!(buf = dm_malloc(size))) {
+				log_error("Failed to allocate buffer for metadata read.");
+				return 0;
+			}
+			if (!dev_read(dev, (uint64_t) offset, size, reason, buf)) {
+				goto out;
+			}
 		}
 		fb = buf;
 	}
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index c321e61..1adf2ad 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -745,7 +745,7 @@ int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t re
 }
 
 /*
- * Read from 'dev' into 'buf', possibly in 2 distinct regions, denoted
+ * Read from 'dev' into 'buf' in 2 distinct regions, denoted
  * by (offset,len) and (offset2,len2).  Thus, the total size of
  * 'buf' should be len+len2.
  */
@@ -757,13 +757,6 @@ int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 		return 0;
 	}
 
-	/*
-	 * The second region is optional, and allows for
-	 * a circular buffer on the device.
-	 */
-	if (!len2)
-		return 1;
-
 	if (!dev_read(dev, offset2, len2, reason, buf + len)) {
 		log_error("Circular read from %s failed",
 			  dev_name(dev));
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index ab610ad..ebc2dbb 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -185,6 +185,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 	char *buf=NULL;
 	struct device_area *area;
 	struct mda_context *mdac;
+	unsigned circular = 0;
 	int r=0;
 
 	mdac = (struct mda_context *) mda->metadata_locn;
@@ -236,7 +237,12 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		if (!(buf = dm_malloc(size + size2)))
 			goto_out;
 
-		if (!dev_read_circular(area->dev, offset, size, offset2, size2, MDA_CONTENT_REASON(mda_is_primary(mda)), buf))
+		circular = size2 ? 1 : 0;
+
+		if (circular) {
+			if (!dev_read_circular(area->dev, offset, size, offset2, size2, MDA_CONTENT_REASON(mda_is_primary(mda)), buf))
+				goto_out;
+		} else if (!dev_read(area->dev, offset, size, MDA_CONTENT_REASON(mda_is_primary(mda)), buf))
 			goto_out;
 
 		/*
@@ -708,7 +714,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	int found = 0;
 	int noprecommit = 0;
 	const char *old_vg_name = NULL;
-	uint64_t new_size_rounded;
+	uint64_t new_size_rounded = 0;
 
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
 	dm_list_iterate_items(pvl, &vg->pvs) {


