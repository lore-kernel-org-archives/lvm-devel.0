From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Nov 2019 10:38:47 -0500
Subject: master - fix dev_unset_last_byte after write error
Message-ID: <59846.119111310384300175@us-mta-184.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=13c254fc05386d05ab6bbda2806f9ca4d3358a0c
Commit:        13c254fc05386d05ab6bbda2806f9ca4d3358a0c
Parent:        9cad26be321844868a904c7b07bebe37be4e0169
Author:        Heming Zhao <heming.zhao@suse.com>
AuthorDate:    Wed Nov 13 09:15:07 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 13 09:36:58 2019 -0600

fix dev_unset_last_byte after write error

dev_unset_last_byte() must be called while the fd is still valid.
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
index 6ec47bf..894a710 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -277,7 +277,6 @@ static int _raw_write_mda_header(const struct format_type *fmt,
 	dev_set_last_byte(dev, start_byte + MDA_HEADER_SIZE);
 
 	if (!dev_write_bytes(dev, start_byte, MDA_HEADER_SIZE, mdah)) {
-		dev_unset_last_byte(dev);
 		log_error("Failed to write mda header to %s fd %d", dev_name(dev), dev->bcache_fd);
 		return 0;
 	}
@@ -989,7 +988,6 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	if (!dev_write_bytes(mdac->area.dev, write1_start, (size_t)write1_size, write_buf)) {
 		log_error("Failed to write metadata to %s fd %d", devname, mdac->area.dev->bcache_fd);
-		dev_unset_last_byte(mdac->area.dev);
 		goto out;
 	}
 
@@ -1002,7 +1000,6 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		if (!dev_write_bytes(mdac->area.dev, write2_start, write2_size,
 				     write_buf + new_size - new_wrap)) {
 			log_error("Failed to write metadata wrap to %s fd %d", devname, mdac->area.dev->bcache_fd);
-			dev_unset_last_byte(mdac->area.dev);
 			goto out;
 		}
 	}
diff --git a/lib/label/label.c b/lib/label/label.c
index 7dcaf8a..05986cb 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -218,7 +218,7 @@ int label_write(struct device *dev, struct label *label)
 
 	if (!dev_write_bytes(dev, offset, LABEL_SIZE, buf)) {
 		log_debug_devs("Failed to write label to %s", dev_name(dev));
-		r = 0;
+		return 0;
 	}
 
 	dev_unset_last_byte(dev);
@@ -655,7 +655,6 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 	int submit_count;
 	int scan_failed;
 	int is_lvm_device;
-	int error;
 	int ret;
 
 	dm_list_init(&wait_devs);
@@ -702,12 +701,11 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 
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
@@ -1451,6 +1449,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
 		log_error("Error writing device %s at %llu length %u.",
 			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+		dev_unset_last_byte(dev);
 		label_scan_invalidate(dev);
 		return false;
 	}
@@ -1458,6 +1457,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	if (!bcache_flush(scan_bcache)) {
 		log_error("Error writing device %s at %llu length %u.",
 			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
+		dev_unset_last_byte(dev);
 		label_scan_invalidate(dev);
 		return false;
 	}
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 01f0246..d8803b3 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -266,7 +266,6 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 	dev_set_last_byte(dev, sizeof(log_header));
 
 	if (!dev_write_bytes(dev, UINT64_C(0), sizeof(log_header), &log_header)) {
-		dev_unset_last_byte(dev);
 		log_error("Failed to write log header to %s.", name);
 		return 0;
 	}



