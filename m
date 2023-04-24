From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 24 Apr 2023 22:14:31 +0000 (GMT)
Subject: main - wipe_lv: use zeroing ioctl only for large sizes
Message-ID: <20230424221431.A8E3F3858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8947964f10499cf286985da37973cdbcaff9d7f1
Commit:        8947964f10499cf286985da37973cdbcaff9d7f1
Parent:        31cfcf7ce9aab5dd16ba15e48bfe33be849fad4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 24 23:58:21 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 00:12:31 2023 +0200

wipe_lv: use zeroing ioctl only for large sizes

There is no easy way to detect, whether device supports zeroing,
and kernel also zeroes device when it's not directly supported,
but with extra message:

operation not supported error, dev X, sector Y op 0x9:(WRITE_ZEROES)...

So to avoid generating such message with every 'lvcreate', use for
zeroing of upto 8K just standard write of zeroed page.
(maybe we can go with even larger sizes).
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2a4e0e88a..762a65785 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8718,7 +8718,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			    display_lvname(lv), wp.zero_value);
 
 #ifdef HAVE_BLKZEROOUT
-		if (!test_mode() && !wp.zero_value) {
+		if (!test_mode() && !wp.zero_value && (zero_sectors > 16)) {
 			/* TODO: maybe integrate with bcache_zero_set() */
 			const uint64_t end = zero_sectors << SECTOR_SHIFT;
 			uint64_t range[2] = { 0, 1024 * 1024 }; /* zeroing with 1M steps (for better ^C support) */

