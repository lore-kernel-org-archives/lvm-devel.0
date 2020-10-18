From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:28 +0000 (GMT)
Subject: stable-2.02 - wipe_lv: make error a fatal event
Message-ID: <20201018210228.26F0A3858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a06bc240001a18db8da8a9befa5b6e9ddbcdcb5
Commit:        7a06bc240001a18db8da8a9befa5b6e9ddbcdcb5
Parent:        84f03e2b630c5266ed553fd7699955b4c52cbf7f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 23 13:56:15 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:27:51 2020 +0200

wipe_lv: make error a fatal event

Failure in wiping/zeroing stop the command.
If user wants to avoid command abortion he should use -Zn or -Wn
to avoid wiping.

Note: there is no easy way to distinguish which kind of failure has
happend - so it's safe to not proceed any futher.
---
 WHATS_NEW               |  1 +
 lib/metadata/lv_manip.c | 43 ++++++++++++++++++++++++-------------------
 2 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0a916438a..e7245447b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Failure in zeroing or wiping will fail command (bypass with -Zn, -Wn).
   Fix support for lvconvert --repair used by foreign apps (i.e. Docker).
   Support interruption for bcache waiting.
   Fix bcache when device has too many failing writes.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0751a7a2b..c4fabf5a0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7189,14 +7189,14 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		return 1;
 
 	if (!lv_is_active_locally(lv)) {
-		log_error("Volume \"%s/%s\" is not active locally (volume_list activation filter?).",
-			  lv->vg->name, lv->name);
+		log_error("Volume %s is not active locally (volume_list activation filter?).",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	/* Wait until devices are available */
 	if (!sync_local_dev_names(lv->vg->cmd)) {
-		log_error("Failed to sync local devices before wiping LV %s.",
+		log_error("Failed to sync local devices before wiping volume %s.",
 			  display_lvname(lv));
 		return 0;
 	}
@@ -7220,17 +7220,20 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 	}
 
 	if (!label_scan_open_rw(dev)) {
-		log_error("Failed to open %s/%s for wiping and zeroing.", lv->vg->name, lv->name);
-		goto out;
+		log_error("Failed to open %s for wiping and zeroing.", display_lvname(lv));
+		return 0;
 	}
 
 	if (wp.do_wipe_signatures) {
-		log_verbose("Wiping known signatures on logical volume \"%s/%s\"",
-			     lv->vg->name, lv->name);
+		log_verbose("Wiping known signatures on logical volume %s.",
+			    display_lvname(lv));
 		if (!wipe_known_signatures(lv->vg->cmd, dev, name, 0,
 					   TYPE_DM_SNAPSHOT_COW,
-					   wp.yes, wp.force, NULL))
-			stack;
+					   wp.yes, wp.force, NULL)) {
+			log_error("Filed to wipe signatures of logical volume %s.",
+				  display_lvname(lv));
+			return 0;
+		}
 	}
 
 	if (wp.do_zero) {
@@ -7239,21 +7242,23 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		if (zero_sectors > lv->size)
 			zero_sectors = lv->size;
 
-		log_verbose("Initializing %s of logical volume \"%s/%s\" with value %d.",
+		log_verbose("Initializing %s of logical volume %s with value %d.",
 			    display_size(lv->vg->cmd, zero_sectors),
-			    lv->vg->name, lv->name, wp.zero_value);
-
-		if (!wp.zero_value) {
-			if (!dev_write_zeros(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT))
-				stack;
-		} else {
-			if (!dev_set_bytes(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, (uint8_t)wp.zero_value))
-				stack;
+			    display_lvname(lv), wp.zero_value);
+
+		if ((wp.zero_value && !dev_set_bytes(dev, UINT64_C(0),
+						     (size_t) zero_sectors << SECTOR_SHIFT,
+						     (uint8_t)wp.zero_value)) ||
+		    !dev_write_zeros(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT)) {
+			log_error("Failed to initialize %s of logical volume %s with value %d.",
+				  display_size(lv->vg->cmd, zero_sectors),
+				  display_lvname(lv), wp.zero_value);
+			return 0;
 		}
 	}
 
 	label_scan_invalidate(dev);
-out:
+
 	lv->status &= ~LV_NOSCAN;
 
 	return 1;


