From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:40 +0000 (GMT)
Subject: stable-2.02 - wipe_lv: interruptible wiping
Message-ID: <20201018210240.ADEB23858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9241860a85df1fc42cd958ca4109be850c1f8fd
Commit:        e9241860a85df1fc42cd958ca4109be850c1f8fd
Parent:        e94e0cd0206044780bdde19b833d818da8f3f651
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 19:31:05 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:28:13 2020 +0200

wipe_lv: interruptible wiping

Since we now block signals and wiping may take unexpectedly long
time - support breaking command while wipe is in progress.
---
 WHATS_NEW               |  1 +
 lib/metadata/lv_manip.c | 16 ++++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 764af0da4..e4a61dcbc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Support interruption when wipping LVs.
   Add configure --enable-editline support as an alternative to readline.
   Zero pool metadata on allocation (disable with allocation/zero_metadata=0).
   Failure in zeroing or wiping will fail command (bypass with -Zn, -Wn).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7576eaeba..d24c1984f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -31,6 +31,7 @@
 #include "memlock.h"
 #include "lvmlockd.h"
 #include "label.h"
+#include "lvm-signal.h"
 
 typedef enum {
 	PREFERRED,
@@ -7225,12 +7226,20 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
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
+			label_scan_invalidate(dev);
+			if (sigint_caught()) {
+				log_error("Interrupted initialization logical volume %s.",
+					  display_lvname(lv));
+				return 0;
+			}
 			log_error("Filed to wipe signatures of logical volume %s.",
 				  display_lvname(lv));
 			return 0;
@@ -7262,12 +7271,19 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
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
 


