From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Nov 2019 12:37:27 -0500
Subject: stable-2.02 - fix dev_unset_last_byte after write error
Message-ID: <18418.119111312372200435@us-mta-167.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=245d7fcd590583166f6cdd78a81bac903fea92eb
Commit:        245d7fcd590583166f6cdd78a81bac903fea92eb
Parent:        fa4ce13e3f4077105106ab6c3aa80eba1b7ba284
Author:        Heming Zhao <heming.zhao@suse.com>
AuthorDate:    Wed Nov 13 11:28:22 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 13 11:28:22 2019 -0600

fix dev_unset_last_byte after write error

ev_unset_last_byte() must be called while the fd is still valid.
After a write error, dev_unset_last_byte() must be called before
closing the dev and resetting the fd.

In the write error path, dev_unset_last_byte() was being called
after label_scan_invalidate() which meant that it would not unset
the last_byte values.

After a write error, dev_unset_last_byte() is now called in
dev_write_bytes() before label_scan_invalidate(), instead of by
the caller of dev_write_bytes().

In the common case of a successful write, the sequence is still:
dev_set_last_byte(); dev_write_bytes(); dev_unset_last_byte();

Signed-off-by: Zhao Heming <heming.zhao@suse.com>
---
 lib/format_text/format-text.c |    3 ---
 lib/label/label.c             |    8 ++++----
 lib/metadata/mirror.c         |    1 -
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6eea07f..026f93a 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -402,7 +402,6 @@ static int _raw_write_mda_header(const struct format_type *fmt,
 	dev_set_last_byte(dev, start_byte + MDA_HEADER_SIZE);
 
 	if (!dev_write_bytes(dev, start_byte, MDA_HEADER_SIZE, mdah)) {
-		dev_unset_last_byte(dev);
 		log_error("Failed to write mda header to %s fd %d", dev_name(dev), dev->bcache_fd);
 		return 0;
 	}
@@ -691,7 +690,6 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		                (size_t) (mdac->rlocn.size - new_wrap),
 		                fidtc->raw_metadata_buf)) {
 		log_error("Failed to write metadata to %s fd %d", dev_name(mdac->area.dev), mdac->area.dev->bcache_fd);
-		dev_unset_last_byte(mdac->area.dev);
 		goto out;
 	}
 
@@ -705,7 +703,6 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			                (size_t) new_wrap,
 			                fidtc->raw_metadata_buf + mdac->rlocn.size - new_wrap)) {
 			log_error("Failed to write metadata wrap to %s fd %d", dev_name(mdac->area.dev), mdac->area.dev->bcache_fd);
-			dev_unset_last_byte(mdac->area.dev);
 			goto out;
 		}
 	}
diff --git a/lib/label/label.c b/lib/label/label.c
index e4a1068..ae5c142 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -216,7 +216,7 @@ int label_write(struct device *dev, struct label *label)
 
 	if (!dev_write_bytes(dev, offset, LABEL_SIZE, buf)) {
 		log_debug_devs("Failed to write label to %s", dev_name(dev));
-		r = 0;
+		return 0;
 	}
 
 	dev_unset_last_byte(dev);
@@ -621,7 +621,6 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 	int submit_count;
 	int scan_failed;
 	int is_lvm_device;
-	int error;
 	int ret;
 
 	dm_list_init(&wait_devs);
@@ -668,12 +667,11 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 
 	dm_list_iterate_items_safe(devl, devl2, &wait_devs) {
 		bb = NULL;
-		error = 0;
 		scan_failed = 0;
 		is_lvm_device = 0;
 
 		if (!bcache_get(scan_bcache, devl->dev->bcache_fd, 0, 0, &bb)) {
-			log_debug_devs("Scan failed to read %s error %d.", dev_name(devl->dev), error);
+			log_debug_devs("Scan failed to read %s.", dev_name(devl->dev));
 			scan_failed = 1;
 			scan_read_errors++;
 			scan_failed_count++;
@@ -1385,6 +1383,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
 		log_error("Error writing device %s at %llu length %u.",
 			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+		dev_unset_last_byte(dev);
 		label_scan_invalidate(dev);
 		return false;
 	}
@@ -1392,6 +1391,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	if (!bcache_flush(scan_bcache)) {
 		log_error("Error writing device %s at %llu length %u.",
 			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+		dev_unset_last_byte(dev);
 		label_scan_invalidate(dev);
 		return false;
 	}
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 4e88f25..068ebd2 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -305,7 +305,6 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 	dev_set_last_byte(dev, sizeof(log_header));
 
 	if (!dev_write_bytes(dev, UINT64_C(0), sizeof(log_header), &log_header)) {
-		dev_unset_last_byte(dev);
 		log_error("Failed to write log header to %s.", name);
 		return 0;
 	}



