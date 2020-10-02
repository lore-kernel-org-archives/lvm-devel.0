From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:56 +0000 (GMT)
Subject: master - wipe_lv: use BLKZEROOUT when possible
Message-ID: <20201002202756.C275C3945C25@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7fff97b8dc4c0a9170bed84388f9ccf55b09169
Commit:        e7fff97b8dc4c0a9170bed84388f9ccf55b09169
Parent:        c65d3a6b8a79b7ba68f56194a12d66b9c5f41547
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 19:32:28 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 21:04:16 2020 +0200

wipe_lv: use BLKZEROOUT when possible

Since BLKZEROOUT ioctl should be supposedly fastest
way how to clear block device start using this ioctl
for zeroing a device. Commonly we do zero typically
small portion of a device (8KiB) - however since we now
also started to zero metadata devices, in the case
of i.e. thin-pool metadata this can go upto ~16GiB
and here the performance starts to be noticable.
---
 WHATS_NEW               |  1 +
 lib/metadata/lv_manip.c | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 270b9d0f8..16a8baf34 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Support using BLKZEROOUT for clearing devices.
   Support interruption when wipping LVs.
   Support interruption for bcache waiting.
   Fix bcache when device has too many failing writes.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b72e08060..4f59900d1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -33,6 +33,11 @@
 #include "lib/label/label.h"
 #include "lib/misc/lvm-signal.h"
 
+#ifdef HAVE_BLKZEROOUT
+#include <sys/ioctl.h>
+#include <linux/fs.h>
+#endif
+
 typedef enum {
 	PREFERRED,
 	USE_AREA,
@@ -7713,6 +7718,33 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			    display_size(lv->vg->cmd, zero_sectors),
 			    display_lvname(lv), wp.zero_value);
 
+#ifdef HAVE_BLKZEROOUT
+		if (!test_mode() && !wp.zero_value) {
+			/* TODO: maybe integrate with bcache_zero_set() */
+			const uint64_t end = zero_sectors << SECTOR_SHIFT;
+			uint64_t range[2] = { 0, 1024 * 1024 }; /* zeroing with 1M steps (for better ^C support) */
+			for (/* empty */ ; range[0] < end; range[0] += range[1]) {
+				if ((range[0] + range[1]) > end)
+					range[1] = end - range[0];
+
+				if (ioctl(dev->bcache_fd, BLKZEROOUT, &range)) {
+					if (errno == EINVAL)
+						goto retry_with_dev_set; /* Kernel without support for BLKZEROOUT */
+					log_sys_debug("ioctl", "BLKZEROOUT");
+					sigint_restore();
+					label_scan_invalidate(dev);
+					if (sigint_caught())
+						log_error("Interrupted initialization logical volume %s.",
+							  display_lvname(lv));
+					else
+						log_error("Failed to initialize logical volume %s at position " FMTu64 " and size " FMTu64 ".",
+							  display_lvname(lv), range[0], range[1]);
+					return 0;
+				}
+			}
+		} else
+retry_with_dev_set:
+#endif
 		if (!dev_set_bytes(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp.zero_value)) {
 			sigint_restore();
 			if (sigint_caught()) {


