From: David Teigland <teigland@sourceware.org>
Date: Thu, 29 Sep 2022 20:28:07 +0000 (GMT)
Subject: main - blkid: fix BLKID_SUBLKS_FSINFO usage
Message-ID: <20220929202807.8B90D3858C55@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b09de683c72b62167fbbd64491708ede652c32a1
Commit:        b09de683c72b62167fbbd64491708ede652c32a1
Parent:        5a0052a1d3b06a071ff6197fc41d9fa312827538
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 29 15:25:32 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 29 15:25:32 2022 -0500

blkid: fix BLKID_SUBLKS_FSINFO usage

Use this flag for all fs info lookups, including BLOCK_SIZE,
if it is defined in blkid.h.
---
 lib/device/dev-type.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index bb8925483..8b51a672a 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -25,12 +25,7 @@
 #include "device_mapper/misc/dm-ioctl.h"
 
 #ifdef BLKID_WIPING_SUPPORT
-#include <blkid.h>
-/*
- * FIXME: recent addition to blkid.h copied here.
- * Remove this and require a recent libblkid version from configure.
- */
-#define BLKID_SUBLKS_FSINFO     (1 << 11) /* read and define fs properties from superblock */
+#include <blkid/blkid.h>
 #endif
 
 #ifdef UDEV_SYNC_SUPPORT
@@ -847,6 +842,9 @@ int fs_block_size_and_type(const char *pathname, uint32_t *fs_block_size_bytes,
 			BLKID_SUBLKS_UUID | BLKID_SUBLKS_UUIDRAW |
 			BLKID_SUBLKS_TYPE | BLKID_SUBLKS_SECTYPE |
 			BLKID_SUBLKS_USAGE | BLKID_SUBLKS_VERSION |
+#ifdef BLKID_SUBLKS_FSINFO
+			BLKID_SUBLKS_FSINFO |
+#endif
 			BLKID_SUBLKS_MAGIC);
 	rc = blkid_do_safeprobe(probe);
 	if (rc < 0) {
@@ -906,7 +904,10 @@ int fs_get_blkid(const char *pathname, struct fs_info *fsi)
 			BLKID_SUBLKS_UUID | BLKID_SUBLKS_UUIDRAW |
 			BLKID_SUBLKS_TYPE | BLKID_SUBLKS_SECTYPE |
 			BLKID_SUBLKS_USAGE | BLKID_SUBLKS_VERSION |
-			BLKID_SUBLKS_MAGIC | BLKID_SUBLKS_FSINFO);
+#ifdef BLKID_SUBLKS_FSINFO
+			BLKID_SUBLKS_FSINFO |
+#endif
+			BLKID_SUBLKS_MAGIC);
 	rc = blkid_do_safeprobe(probe);
 	if (rc < 0) {
 		log_error("Failed libblkid probe for %s", pathname);

