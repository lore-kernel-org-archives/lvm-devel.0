From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:28 +0000 (GMT)
Subject: dev-next - raid: interruptible usleep when waiting for sync
Message-ID: <20210322153928.E46F3385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=076e1556978dfb216176d319d2498ec571fcc908
Commit:        076e1556978dfb216176d319d2498ec571fcc908
Parent:        b4ab2a10511cba2f7679cf12929438b6d2d6232d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 23:00:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 19 23:17:03 2021 +0100

raid: interruptible usleep when waiting for sync

Whiel waiting for raid to return consistent status,
use interruptible sleep - so command can break quickly.

Use lv_raid_status() to get percentage easily from status.
---
 lib/metadata/raid_manip.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a43e36141..dc3bce201 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -22,6 +22,7 @@
 #include "lib/metadata/lv_alloc.h"
 #include "lib/misc/lvm-string.h"
 #include "lib/locking/lvmlockd.h"
+#include "lib/misc/lvm-signal.h"
 
 typedef int (*fn_on_lv_t)(struct logical_volume *lv, void *data);
 static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
@@ -392,6 +393,7 @@ static int _raid_in_sync(const struct logical_volume *lv)
 {
 	int retries = _RAID_IN_SYNC_RETRIES;
 	dm_percent_t sync_percent;
+	struct lv_status_raid *raid_status;
 
 	if (seg_is_striped(first_seg(lv)))
 		return 1;
@@ -403,17 +405,21 @@ static int _raid_in_sync(const struct logical_volume *lv)
 		 * the array is 100% in sync.
 		 * https://bugzilla.redhat.com/1210637
 		 */
-		if (!lv_raid_percent(lv, &sync_percent)) {
+		if (!lv_raid_status(lv, &raid_status)) {
 			log_error("Unable to determine sync status of %s.",
 				  display_lvname(lv));
 			return 0;
 		}
+		sync_percent = raid_status->in_sync;
+		dm_pool_destroy(raid_status->mem);
+
 		if (sync_percent > DM_PERCENT_0)
 			break;
 		if (retries == _RAID_IN_SYNC_RETRIES)
 			log_warn("WARNING: Sync status for %s is inconsistent.",
 				 display_lvname(lv));
-		usleep(500000);
+		if (interruptible_usleep(500000))
+			return_0;
 	} while (--retries);
 
 	return (sync_percent == DM_PERCENT_100) ? 1 : 0;


