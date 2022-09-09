From: David Teigland <teigland@sourceware.org>
Date: Fri,  9 Sep 2022 21:18:11 +0000 (GMT)
Subject: main - remove libblkid flag BLKID_SUBLKS_FSINFO
Message-ID: <20220909211811.B3CD33858429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55e9494e5fe3e3d2790fca6330b848a577e0b1c0
Commit:        55e9494e5fe3e3d2790fca6330b848a577e0b1c0
Parent:        b869a6ff7a3d254a56ad78444e7d7f8af93d6844
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 9 16:14:27 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 9 16:14:27 2022 -0500

remove libblkid flag BLKID_SUBLKS_FSINFO

This flag is not needed in fs_block_size_and_type()
added in the previous commit.
---
 lib/device/dev-type.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 1e97f6c85..b1cf5b431 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -842,7 +842,7 @@ int fs_block_size_and_type(const char *pathname, uint32_t *fs_block_size_bytes,
 			BLKID_SUBLKS_UUID | BLKID_SUBLKS_UUIDRAW |
 			BLKID_SUBLKS_TYPE | BLKID_SUBLKS_SECTYPE |
 			BLKID_SUBLKS_USAGE | BLKID_SUBLKS_VERSION |
-			BLKID_SUBLKS_MAGIC | BLKID_SUBLKS_FSINFO);
+			BLKID_SUBLKS_MAGIC);
 	rc = blkid_do_safeprobe(probe);
 	if (rc < 0) {
 		log_debug("Failed libblkid probe for %s", pathname);

