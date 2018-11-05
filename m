From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:10 -0500
Subject: master - cov: overflow before widen
Message-ID: <201811051627.wA5GRAcv005342@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c7789daec06110b7ed3663f1ba8cf91f40c8e572
Commit:        c7789daec06110b7ed3663f1ba8cf91f40c8e572
Parent:        bc1976011adb51951dc0280817b2c047ab22ac7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 2 21:10:21 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 3 16:10:31 2018 +0100

cov: overflow before widen

Evaluate as 64bit arithmetic (instead of doing 32bit mults which can
in this case purely teoretically overflow).
---
 base/data-struct/radix-tree-adaptive.c |    2 +-
 lib/locking/lvmlockd.c                 |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index f5a8606..f8f3322 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -623,7 +623,7 @@ static void _degrade_to_n48(struct node256 *n256, struct value *result)
 }
 
 // Removes an entry in an array by sliding the values above it down.
-static void _erase_elt(void *array, unsigned obj_size, unsigned count, unsigned index)
+static void _erase_elt(void *array, size_t obj_size, unsigned count, unsigned index)
 {
 	if (index == (count - 1))
 		// The simple case
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index d65e06f..969a7fe 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -389,7 +389,7 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		.resize = LV_EXTEND,
 		.force = 1,
 	};
-	int i;
+	uint64_t i;
 
 	extend_bytes = extend_mb * ONE_MB_IN_BYTES;
 	extend_sectors = extend_bytes / SECTOR_SIZE;
@@ -443,8 +443,8 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 
 	for (i = 0; i < extend_mb; i++) {
 		if (!dev_write_zeros(dev, old_size_bytes + (i * ONE_MB_IN_BYTES), ONE_MB_IN_BYTES)) {
-			log_error("Extend sanlock LV %s cannot zero device at %llu.", display_lvname(lv),
-				  (unsigned long long)(old_size_bytes + i * ONE_MB_IN_BYTES));
+			log_error("Extend sanlock LV %s cannot zero device@" FMTu64 ".",
+				  display_lvname(lv), (old_size_bytes + i * ONE_MB_IN_BYTES));
 			label_scan_invalidate(dev);
 			return 0;
 		}


