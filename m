From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:19 +0000 (GMT)
Subject: master - wipe: dev_set_bytes resolves zeroing
Message-ID: <20200915212119.A2D793983A5A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b36542f419ca66c0ee7de4537b5a9dd7a902e3d
Commit:        2b36542f419ca66c0ee7de4537b5a9dd7a902e3d
Parent:        d588de77aa720b31ea54594b75a1182b7e3a5255
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 20:35:48 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 23:07:06 2020 +0200

wipe: dev_set_bytes resolves zeroing

Since dev_write_zeros() is just subset of dev_set_bytes()
use it directly and simplify code.
---
 lib/metadata/lv_manip.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e3a1cbaff..063ff3e03 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7641,6 +7641,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			log_debug("Metadata logical volume %s will be fully zeroed.",
 				  display_lvname(lv));
 			zero_sectors = lv->size;
+			wp.zero_value = 0;
 		} else {
 			if (wp.is_metadata) /* Verbosely notify metadata will not be fully zeroed */
 				log_verbose("Metadata logical volume %s not fully zeroed and may contain stale data.",
@@ -7657,11 +7658,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			    display_size(lv->vg->cmd, zero_sectors),
 			    display_lvname(lv), wp.zero_value);
 
-		if ((!wp.is_metadata &&
-		     wp.zero_value && !dev_set_bytes(dev, UINT64_C(0),
-						     (size_t) zero_sectors << SECTOR_SHIFT,
-						     (uint8_t)wp.zero_value)) ||
-		    !dev_write_zeros(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT)) {
+		if (!dev_set_bytes(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp.zero_value)) {
 			label_scan_invalidate(dev);
 			log_error("Failed to initialize %s of logical volume %s with value %d.",
 				  display_size(lv->vg->cmd, zero_sectors),


