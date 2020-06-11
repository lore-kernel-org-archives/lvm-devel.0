From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Jun 2020 18:06:38 +0000 (GMT)
Subject: master - fix libblkid BLOCK_SIZE check
Message-ID: <20200611180638.C594F383F859@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9fbad5bb0fdc7d9a9dca8539e4cd217c5ef1fede
Commit:        9fbad5bb0fdc7d9a9dca8539e4cd217c5ef1fede
Parent:        6ea3654868e3727b9197113f973e1c7edeed38b2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 11 12:43:07 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 11 12:43:07 2020 -0500

fix libblkid BLOCK_SIZE check

---
 lib/device/dev-type.c | 36 ++++++++++++------------------------
 1 file changed, 12 insertions(+), 24 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index deb5d6a0f..e3fa9babb 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -649,37 +649,25 @@ out:
 #ifdef BLKID_WIPING_SUPPORT
 int get_fs_block_size(struct device *dev, uint32_t *fs_block_size)
 {
-	blkid_probe probe = NULL;
-	const char *block_size_str = NULL;
+	char *block_size_str = NULL;
 	uint64_t block_size_val;
-	int r = 0;
 
-	*fs_block_size = 0;
-
-	if (!(probe = blkid_new_probe_from_filename(dev_name(dev)))) {
-		log_error("Failed to create a new blkid probe for device %s.", dev_name(dev));
-		goto out;
+	if ((block_size_str = blkid_get_tag_value(NULL, "BLOCK_SIZE", dev_name(dev)))) {
+		block_size_val = strtoull(block_size_str, NULL, 10);
+		*fs_block_size = (uint32_t)block_size_val;
+		free(block_size_str);
+		log_debug("Found blkid BLOCK_SIZE %u for fs on %s", *fs_block_size, dev_name(dev));
+		return 1;
+	} else {
+		log_debug("No blkid BLOCK_SIZE for fs on %s", dev_name(dev));
+		*fs_block_size = 0;
+		return 0;
 	}
-
-	blkid_probe_enable_partitions(probe, 1);
-
-	(void) blkid_probe_lookup_value(probe, "BLOCK_SIZE", &block_size_str, NULL);
-
-	if (!block_size_str)
-		goto out;
-
-	block_size_val = strtoull(block_size_str, NULL, 10);
-
-	*fs_block_size = (uint32_t)block_size_val;
-	r = 1;
-out:
-	if (probe)
-		blkid_free_probe(probe);
-	return r;
 }
 #else
 int get_fs_block_size(struct device *dev, uint32_t *fs_block_size)
 {
+	log_debug("Disabled blkid BLOCK_SIZE for fs.");
 	*fs_block_size = 0;
 	return 0;
 }


