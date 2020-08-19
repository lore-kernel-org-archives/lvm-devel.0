From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 19 Aug 2020 13:09:42 +0000 (GMT)
Subject: master - wipe_lv: close devices on error path
Message-ID: <20200819130942.25A8E3857C7C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46d15b5e4d2830fce313d7a58a1498d61b7a8f86
Commit:        46d15b5e4d2830fce313d7a58a1498d61b7a8f86
Parent:        3e9664bacad3b31f074d58ff5ae8e2403a7ba9d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 19 14:40:08 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 19 15:09:09 2020 +0200

wipe_lv: close devices on error path

Device was kept open preventing its deactivated and removed
on error path.
---
 WHATS_NEW               | 1 +
 lib/metadata/lv_manip.c | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index f3cb50692..cdc491c83 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Fix missing device closing on wiping error path.
   Update lvmvdo man page and better explain DISCARD usage.
 
 Version 2.03.10 - 09th August 2020
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f0ba3f0db..bb2ad5beb 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7625,6 +7625,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		if (!wipe_known_signatures(lv->vg->cmd, dev, name, 0,
 					   TYPE_DM_SNAPSHOT_COW,
 					   wp.yes, wp.force, NULL)) {
+			label_scan_invalidate(dev);
 			log_error("Filed to wipe signatures of logical volume %s.",
 				  display_lvname(lv));
 			return 0;
@@ -7659,6 +7660,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 						     (size_t) zero_sectors << SECTOR_SHIFT,
 						     (uint8_t)wp.zero_value)) ||
 		    !dev_write_zeros(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT)) {
+			label_scan_invalidate(dev);
 			log_error("Failed to initialize %s of logical volume %s with value %d.",
 				  display_size(lv->vg->cmd, zero_sectors),
 				  display_lvname(lv), wp.zero_value);


