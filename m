From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 20:34:11 +0000 (GMT)
Subject: master - debug: shorten error message
Message-ID: <20201020203411.688EC385782B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b75c2dfe1b28efae08be9c7b55e904b8b695a8cd
Commit:        b75c2dfe1b28efae08be9c7b55e904b8b695a8cd
Parent:        b2a326b511950c301fceb7f4901671af53f0e8af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 14:28:58 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 19 16:53:18 2020 +0200

debug: shorten error message

Just check for sigint during log_error().
---
 lib/metadata/lv_manip.c | 26 ++++++++------------------
 1 file changed, 8 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4f59900d1..72c85914d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7682,13 +7682,10 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 					   TYPE_DM_SNAPSHOT_COW,
 					   wp.yes, wp.force, NULL)) {
 			sigint_restore();
-			if (sigint_caught()) {
-				log_error("Interrupted initialization logical volume %s.",
-					  display_lvname(lv));
-				return 0;
-			}
 			label_scan_invalidate(dev);
-			log_error("Filed to wipe signatures of logical volume %s.",
+			log_error("%s logical volume %s.",
+				  sigint_caught() ?
+				  "Interrupted initialization of" : "Failed to wipe signatures on",
 				  display_lvname(lv));
 			return 0;
 		}
@@ -7733,12 +7730,9 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
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
@@ -7747,12 +7741,8 @@ retry_with_dev_set:
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


