From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 21:25:08 +0000 (GMT)
Subject: stable-2.02 - debug: shorten error message
Message-ID: <20201020212508.CB7A3385DC37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f0913c6482c8be53221540f6fa4b82f0eda264ff
Commit:        f0913c6482c8be53221540f6fa4b82f0eda264ff
Parent:        b9d2aa9488931203f851d93324485b26375b9742
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 14:28:58 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 20 22:48:02 2020 +0200

debug: shorten error message

Just check for sigint during log_error().
---
 lib/metadata/lv_manip.c | 26 ++++++++------------------
 1 file changed, 8 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 42d18abb8..7fc20b2fc 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7240,12 +7240,9 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 					   wp.yes, wp.force, NULL)) {
 			sigint_restore();
 			label_scan_invalidate(dev);
-			if (sigint_caught()) {
-				log_error("Interrupted initialization logical volume %s.",
-					  display_lvname(lv));
-				return 0;
-			}
-			log_error("Filed to wipe signatures of logical volume %s.",
+			log_error("%s logical volume %s.",
+				  sigint_caught() ?
+				  "Interrupted initialization of" : "Failed to wipe signatures on",
 				  display_lvname(lv));
 			return 0;
 		}
@@ -7290,12 +7287,9 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 					log_sys_debug("ioctl", "BLKZEROOUT");
 					sigint_restore();
 					label_scan_invalidate(dev);
-					if (sigint_caught())
-						log_error("Interrupted initialization logical volume %s.",
-							  display_lvname(lv));
-					else
-						log_error("Failed to initialize logical volume %s at position " FMTu64 " and size " FMTu64 ".",
-							  display_lvname(lv), range[0], range[1]);
+					log_error("%s logical volume %s at position " FMTu64 " and size " FMTu64 ".",
+						  sigint_caught() ? "Interrupted initialization of" : "Failed to initialize",
+						  display_lvname(lv), range[0], range[1]);
 					return 0;
 				}
 			}
@@ -7304,12 +7298,8 @@ retry_with_dev_set:
 #endif
 		if (!dev_set_bytes(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp.zero_value)) {
 			sigint_restore();
-			if (sigint_caught()) {
-				log_error("Interrupted initialization logical volume %s.",
-					  display_lvname(lv));
-				return 0;
-			}
-			log_error("Failed to initialize %s of logical volume %s with value %d.",
+			log_error("%s %s of logical volume %s with value %d.",
+				  sigint_caught() ? "Interrupted initialization" : "Failed to initialize",
 				  display_size(lv->vg->cmd, zero_sectors),
 				  display_lvname(lv), wp.zero_value);
 			return 0;


