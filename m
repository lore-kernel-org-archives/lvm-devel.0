From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Jun 2017 17:31:13 -0400
Subject: master - thin: restore conversion to raid
Message-ID: <201706192131.v5JLVDO6019728@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19cc03fa5275fa6d00a1f726bae40141559e2913
Commit:        19cc03fa5275fa6d00a1f726bae40141559e2913
Parent:        9e9163618ab36a6b046b6380d6ef58429b219ef8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 19 23:11:11 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 19 23:30:08 2017 +0200

thin: restore conversion to raid

Since commit  1bc546269a7d2cae156827e282715410a4967d51 we've disabled
coversion of raid. This however already got fixed, so reenable
commands like:  'lvconvert --type raid1 vg/pool_tdata'.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   21 ++++++---------------
 2 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 305e185..e60380a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Reenable conversion of data and metadata thin-pool volumes to raid.
   Improve raid status reporting with lvs.
   No longer necessary to '--force' a repair for RAID1
   Linear to RAID1 upconverts now use "recover" sync action, not "resync".
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8fc04fb..56cc592 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2552,14 +2552,6 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (lv_is_active(lv_lock_holder(lv)) &&
-	    (old_count == 1) &&
-	    (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv))) {
-		log_error("Can't add image to active thin pool LV %s yet. Deactivate first.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	if (!archive(lv->vg))
 		return_0;
 
@@ -6278,6 +6270,12 @@ int lv_raid_convert(struct logical_volume *lv,
 		log_error("%s must be active to perform this operation.",
 			  display_lvname(lv));
 		return 0;
+	} else if (vg_is_clustered(lv->vg) &&
+		   !lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
+		/* In clustered VGs, the LV must be active on this node exclusively. */
+		log_error("%s must be active exclusive locally to "
+			  "perform this operation.", display_lvname(lv));
+		return 0;
 	}
 
 	new_segtype = new_segtype ? : seg->segtype;
@@ -6406,13 +6404,6 @@ int lv_raid_convert(struct logical_volume *lv,
 		    (segtype_is_striped_target(new_segtype) &&
 		    (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
-	/* In clustered VGs, the LV must be active on this node exclusively. */
-	if (vg_is_clustered(lv->vg) && !lv_is_active_exclusive_locally(lv)) {
-		log_error("%s must be active exclusive locally to "
-			  "perform this operation.", display_lvname(lv));
-		return 0;
-	}
-
 	/* LV must be in sync. */
 	if (!_raid_in_sync(lv)) {
 		log_error("Unable to convert %s while it is not in-sync.",


