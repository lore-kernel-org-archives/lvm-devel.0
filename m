From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:38 +0000 (GMT)
Subject: stable-2.02 - wipe: dev_set_bytes resolves zeroing
Message-ID: <20201018210238.6B49C3850429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=35104f7ba5c5318b059ed0fd76f47fdd1c04285b
Commit:        35104f7ba5c5318b059ed0fd76f47fdd1c04285b
Parent:        0559ce6be098253fecb8d2cc42d391b270e75894
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 20:35:48 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:28:13 2020 +0200

wipe: dev_set_bytes resolves zeroing

Since dev_write_zeros() is just subset of dev_set_bytes()
use it directly and simplify code.
---
 lib/metadata/lv_manip.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 660e742dd..7576eaeba 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7244,6 +7244,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			log_debug("Metadata logical volume %s will be fully zeroed.",
 				  display_lvname(lv));
 			zero_sectors = lv->size;
+			wp.zero_value = 0;
 		} else {
 			if (wp.is_metadata) /* Verbosely notify metadata will not be fully zeroed */
 				log_verbose("Metadata logical volume %s not fully zeroed and may contain stale data.",
@@ -7260,11 +7261,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			    display_size(lv->vg->cmd, zero_sectors),
 			    display_lvname(lv), wp.zero_value);
 
-		if ((!wp.is_metadata &&
-		     wp.zero_value && !dev_set_bytes(dev, UINT64_C(0),
-						     (size_t) zero_sectors << SECTOR_SHIFT,
-						     (uint8_t)wp.zero_value)) ||
-		    !dev_write_zeros(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT)) {
+		if (!dev_set_bytes(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp.zero_value)) {
 			log_error("Failed to initialize %s of logical volume %s with value %d.",
 				  display_size(lv->vg->cmd, zero_sectors),
 				  display_lvname(lv), wp.zero_value);


