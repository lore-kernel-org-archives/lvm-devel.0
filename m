From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Jun 2020 20:06:40 +0000 (GMT)
Subject: master - improve get_fs_block_size string to number
Message-ID: <20200611200640.79947386F442@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e2938c963bb8226b72297647bef89895e5ae548
Commit:        8e2938c963bb8226b72297647bef89895e5ae548
Parent:        9f38e95a2f84f148dae1a8ec440adc29eb12d513
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 11 15:05:47 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 11 15:05:47 2020 -0500

improve get_fs_block_size string to number

---
 lib/device/dev-type.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index e3fa9babb..896821de8 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -650,11 +650,9 @@ out:
 int get_fs_block_size(struct device *dev, uint32_t *fs_block_size)
 {
 	char *block_size_str = NULL;
-	uint64_t block_size_val;
 
 	if ((block_size_str = blkid_get_tag_value(NULL, "BLOCK_SIZE", dev_name(dev)))) {
-		block_size_val = strtoull(block_size_str, NULL, 10);
-		*fs_block_size = (uint32_t)block_size_val;
+		*fs_block_size = (uint32_t)atoi(block_size_str);
 		free(block_size_str);
 		log_debug("Found blkid BLOCK_SIZE %u for fs on %s", *fs_block_size, dev_name(dev));
 		return 1;


