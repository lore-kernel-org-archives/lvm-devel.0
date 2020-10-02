From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:55 +0000 (GMT)
Subject: master - wipe_lv: interruptible wiping
Message-ID: <20201002202755.A233B398E804@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c65d3a6b8a79b7ba68f56194a12d66b9c5f41547
Commit:        c65d3a6b8a79b7ba68f56194a12d66b9c5f41547
Parent:        7396f1cfee0399237aee1ed41f5930746ee31716
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 19:31:05 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 21:03:19 2020 +0200

wipe_lv: interruptible wiping

Since we now block signals and wiping may take unexpectedly long
time - support breaking command while wipe is in progress.
---
 WHATS_NEW               |  1 +
 lib/metadata/lv_manip.c | 15 +++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index d4cf61d71..270b9d0f8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Support interruption when wipping LVs.
   Support interruption for bcache waiting.
   Fix bcache when device has too many failing writes.
   Fix bcache waiting for IO completion with failing disks.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f61705909..b72e08060 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -31,6 +31,7 @@
 #include "lib/mm/memlock.h"
 #include "lib/locking/lvmlockd.h"
 #include "lib/label/label.h"
+#include "lib/misc/lvm-signal.h"
 
 typedef enum {
 	PREFERRED,
@@ -7668,12 +7669,19 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		return 0;
 	}
 
+	sigint_allow();
 	if (wp.do_wipe_signatures) {
 		log_verbose("Wiping known signatures on logical volume %s.",
 			    display_lvname(lv));
 		if (!wipe_known_signatures(lv->vg->cmd, dev, name, 0,
 					   TYPE_DM_SNAPSHOT_COW,
 					   wp.yes, wp.force, NULL)) {
+			sigint_restore();
+			if (sigint_caught()) {
+				log_error("Interrupted initialization logical volume %s.",
+					  display_lvname(lv));
+				return 0;
+			}
 			label_scan_invalidate(dev);
 			log_error("Filed to wipe signatures of logical volume %s.",
 				  display_lvname(lv));
@@ -7706,12 +7714,19 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			    display_lvname(lv), wp.zero_value);
 
 		if (!dev_set_bytes(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp.zero_value)) {
+			sigint_restore();
+			if (sigint_caught()) {
+				log_error("Interrupted initialization logical volume %s.",
+					  display_lvname(lv));
+				return 0;
+			}
 			log_error("Failed to initialize %s of logical volume %s with value %d.",
 				  display_size(lv->vg->cmd, zero_sectors),
 				  display_lvname(lv), wp.zero_value);
 			return 0;
 		}
 	}
+	sigint_restore();
 
 	label_scan_invalidate(dev);
 


