From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:55 +0000 (UTC)
Subject: master - debug: missing stack traces
Message-ID: <20161211223455.E12656038F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=794093722c657780171486dbfd8cd0ec392e4019
Commit:        794093722c657780171486dbfd8cd0ec392e4019
Parent:        dc7d3dd5eda43186829ac4237ab049fe50cbc12a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 10 22:37:34 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:19 2016 +0100

debug: missing stack traces

---
 lib/metadata/raid_manip.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 58e3bcf..98f30e2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3248,24 +3248,24 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 		log_debug_metadata("Converting LV %s from %s to %s",
 				   display_lvname(lv), SEG_TYPE_NAME_STRIPED, SEG_TYPE_NAME_RAID0);
 		if (!(seg = _convert_striped_to_raid0(lv, 1 /* alloc_metadata_devs */, 0 /* update_and_reload */, allocate_pvs)))
-			return 0;
+			return_0;
 	}
 
 	/* Add metadata LVs */
 	if (seg_is_raid0(seg)) {
 		log_debug_metadata("Adding metadata LVs to %s", display_lvname(lv));
 		if (!_raid0_add_or_remove_metadata_lvs(lv, 1 /* update_and_reload */, allocate_pvs, NULL))
-			return 0;
+			return_0;
 	/* raid0_meta -> raid4 needs clearing of MetaLVs in order to avoid raid disk role cahnge issues in the kernel */
 	} else if (segtype_is_raid4(new_segtype) &&
 		   !_clear_meta_lvs(lv))
-		return 0;
+		return_0;
 
 	/* Add the additional component LV pairs */
 	log_debug_metadata("Adding %" PRIu32 " component LV pair(s) to %s", new_image_count - lv_raid_image_count(lv),
 			   display_lvname(lv));
 	if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, NULL, 0, 1))
-		return 0;
+		return_0;
 
 	if (segtype_is_raid4(new_segtype) &&
 	    (!_shift_parity_dev(seg) ||
@@ -3289,7 +3289,7 @@ static int _striped_or_raid0_to_raid45610_wrapper(TAKEOVER_FN_ARGS)
 	if (segtype_is_raid4(new_segtype)) {
 		/* We had to rename SubLVs because of collision free sgifting, rename back... */
 		if (!_rename_area_lvs(lv, NULL))
-			return 0;
+			return_0;
 		if (!lv_update_and_reload(lv))
 			return_0;
 	}


