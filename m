From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Jun 2020 13:02:41 +0000 (GMT)
Subject: master - wipe_lv: make error a fatal event
Message-ID: <20200624130241.7D72F3939C28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=edbc5a62b26806e5c4de59b5292609e955303576
Commit:        edbc5a62b26806e5c4de59b5292609e955303576
Parent:        6eb9eba59bf53101b5148ace3ddaf4140592495f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 23 13:56:15 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:01:03 2020 +0200

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
index c6dad99e2..b770455fb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.10 - 
 =================================
+  Failure in zeroing or wiping will fail command (bypass with -Zn, -Wn).
   Fix running out of free buffers for async writing for larger writes.
   Add integrity with raid capability.
   Fix support for lvconvert --repair used by foreign apps (i.e. Docker).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1642b90a0..8250819da 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7582,14 +7582,14 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		return 1;
 
 	if (!lv_is_active(lv)) {
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
@@ -7613,17 +7613,20 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 	}
 
 	if (!label_scan_open_rw(dev)) {
-		log_error("Failed to open %s/%s for wiping and zeroing.", lv->vg->name, lv->name);
-		goto out;
+		log_error("Failed to open %s for wiping and zeroing.", display_lvname(lv));
+		return 0;
 	}
 
 	if (wp.do_wipe_signatures) {
-		log_verbose("Wiping known signatures on logical volume \"%s/%s\"",
-			    lv->vg->name, lv->name);
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
@@ -7632,21 +7635,23 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
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


