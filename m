From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:43 +0000 (GMT)
Subject: stable-2.02 - wipe_lv: use BLKZEROOUT when possible
Message-ID: <20201018210243.00B62384B061@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b8454b59e1901404d184f6198c87307711f35471
Commit:        b8454b59e1901404d184f6198c87307711f35471
Parent:        ac5cf1544efef5a585f7e66edf2d3cfbf7bbbe8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 19:32:28 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:28:13 2020 +0200

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
index e4a61dcbc..31f21ce4f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Support using BLKZEROOUT for clearing devices.
   Support interruption when wipping LVs.
   Add configure --enable-editline support as an alternative to readline.
   Zero pool metadata on allocation (disable with allocation/zero_metadata=0).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d24c1984f..4b1b4de61 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -33,6 +33,11 @@
 #include "label.h"
 #include "lvm-signal.h"
 
+#ifdef HAVE_BLKZEROOUT
+#include <sys/ioctl.h>
+#include <linux/fs.h>
+#endif
+
 typedef enum {
 	PREFERRED,
 	USE_AREA,
@@ -7270,6 +7275,33 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
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


