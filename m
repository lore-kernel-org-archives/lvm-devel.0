From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:41 +0000 (GMT)
Subject: stable-2.02 - raid: no wiping when zeroing raid metadata device
Message-ID: <20201016191041.68A84396EC45@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c4202bf458751fcb646aa411fa32cd0f91a72ce3
Commit:        c4202bf458751fcb646aa411fa32cd0f91a72ce3
Parent:        e397423c419ec5db4137dc671d366ba650be6dde
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 8 10:59:51 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:05 2020 +0200

raid: no wiping when zeroing raid metadata device

Currently lvm2 is not wiping signatures when creating 'metadata' volumes
and raid _rmeta was the only exception - so make the behavior consistent
with other metadata devices and drop wiping ATM.
Drop also some extra debug since they are now more explanatory in
wipe_lv() function.
Also note - although lvm2 now does not wipe signatures - the error
from such wipping used to be actually 'ignored' before wipe_lv()
started to return error (with recent commit) and raid creation
continued with 'unzeroed' metadata device.

TODO: Several issues to resolve:

1. We may want to flip to wipping with all LVs (in that case we need to
support passing --yet & --force).

2. Also we may want to clear whole metadata device - however current
function is also used for wipping i.e. snapshot COW device which
is likely not a good candidate for full device zeroing.
We may also need to think about better logic when extent size is
enforcing very large LVs, when only a small portion of LV is ever
being used.

3. Using TRIM instead of zeroing metadata device might be worth to
implement.

mm
---
 lib/metadata/lv_manip.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0b1fdce27..e7fd43945 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7304,12 +7304,10 @@ int activate_and_wipe_lvlist(struct dm_list *lv_list, int commit)
 		}
 
 	dm_list_iterate_items(lvl, lv_list) {
-		log_verbose("Wiping metadata area %s.", display_lvname(lvl->lv));
 		/* Wipe any know signatures */
-		if (!wipe_lv(lvl->lv, (struct wipe_params) { .do_wipe_signatures = 1, .do_zero = 1, .zero_sectors = 1 })) {
-			log_error("Failed to wipe %s.", display_lvname(lvl->lv));
+		if (!wipe_lv(lvl->lv, (struct wipe_params) { .do_zero = 1 /* TODO: is_metadata = 1 */ })) {
 			r = 0;
-			goto out;
+			goto_out;
 		}
 	}
 out:


