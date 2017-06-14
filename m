From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Wed, 14 Jun 2017 09:41:48 -0400
Subject: master - lvconvert: Don't require a 'force' option during RAID repair.
Message-ID: <201706141341.v5EDfmaG012452@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d34d2068ddf20b7d683ee06205c31ec673b32813
Commit:        d34d2068ddf20b7d683ee06205c31ec673b32813
Parent:        c87907dcd5385337ba96c79b4bee8e3d2f2ea129
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 14 08:39:07 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 14 08:39:07 2017 -0500

lvconvert:  Don't require a 'force' option during RAID repair.

Previously, we were treating non-RAID to RAID up-converts as a "resync"
operation.  (The most common example being 'linear -> RAID1'.)  RAID to
RAID up-converts or rebuilds of specific RAID images are properly treated
as a "recover" operation.

Since we were treating some up-convert operations as "resync", it was
possible to have scenarios where data corruption or data loss were
possibilities if the RAID hadn't been able to sync completely before a
loss of the primary source devices.  In order to ensure that the user took
the proper precautions in such scenarios, we required a '--force' option
to be present.  Unfortuneately, the force option was rendered useless
because there was no way to distiguish the failure state of a potentially
destructive repair from a nominal one - making the '--force' option a
requirement for any RAID1 repair!

We now treat non-RAID to RAID up-converts properly as "recover" operations.
This eliminates the scenarios that can potentially cause data loss or
data corruption; and this eliminates the need for the '--force' requirement.
This patch removes the requirement to specify '--force' for RAID repairs.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   31 +------------------------------
 2 files changed, 2 insertions(+), 30 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c7f8903..b2796f6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  No longer necessary to '--force' a repair for RAID1
   Linear to RAID1 upconverts now use "recover" sync action, not "resync".
   Improve lvcreate --cachepool arg validation.
   Limit maximal size of thin-pool for specific chunk size.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 425abbb..ac0b8f1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -409,23 +409,6 @@ int lv_raid_in_sync(const struct logical_volume *lv)
 	return _raid_in_sync(lv);
 }
 
-/* Check if RaidLV @lv is synced or any raid legs of @lv are not synced */
-static int _raid_devs_sync_healthy(struct logical_volume *lv)
-{
-	char *raid_health;
-
-	if (!_raid_in_sync(lv))
-		return 0;
-
-	if (!seg_is_raid1(first_seg(lv)))
-		return 1;
-
-	if (!lv_raid_dev_health(lv, &raid_health))
-		return_0;
-
-	return (strchr(raid_health, 'a') || strchr(raid_health, 'D')) ? 0 : 1;
-}
-
 /*
  * _raid_remove_top_layer
  * @lv
@@ -2964,20 +2947,8 @@ static int _raid_extract_images(struct logical_volume *lv,
 			if (!lv_is_on_pvs(seg_lv(seg, s), target_pvs) &&
 			    !lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
 				continue;
-
-			/*
-			 * Kernel may report raid LV in-sync but still
-			 * image devices may not be in-sync or faulty.
-			 */
-			if (!_raid_devs_sync_healthy(lv) &&
-			    (!seg_is_mirrored(seg) || (s == 0 && !force))) {
-				log_error("Unable to extract %sRAID image"
-					  " while RAID array is not in-sync%s.",
-					  seg_is_mirrored(seg) ? "primary " : "",
-					  seg_is_mirrored(seg) ? " (use --force option to replace)" : "");
-				return 0;
-			}
 		}
+
 		if (!_extract_image_components(seg, s, &rmeta_lv, &rimage_lv)) {
 			log_error("Failed to extract %s from %s.",
 				  display_lvname(seg_lv(seg, s)),


