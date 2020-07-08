From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  8 Jul 2020 09:45:26 +0000 (GMT)
Subject: master - raid: no wiping when zeroing raid metadata device
Message-ID: <20200708094526.450D13851C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b9bf8786fb423a4430cc676301edadf2310098d
Commit:        9b9bf8786fb423a4430cc676301edadf2310098d
Parent:        b7f3667ce20b731bbda9b1d61df49abbcd1bd20e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 8 10:59:51 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 8 11:40:55 2020 +0200

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
index 5956d032c..f0ba3f0db 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7731,12 +7731,10 @@ int activate_and_wipe_lvlist(struct dm_list *lv_list, int commit)
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


