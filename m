From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri,  3 Feb 2017 21:16:43 +0000 (UTC)
Subject: master - lvconvert: add segtype raid5_n and conversions to/from it
Message-ID: <20170203211644.0217E6053D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e92535d475da7403f2ec8eeb2c5af6209fa2ba8
Commit:        7e92535d475da7403f2ec8eeb2c5af6209fa2ba8
Parent:        60ddd05f163cbf53670e5c8deabfc384168eae0f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 3 22:16:00 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 3 22:16:35 2017 +0100

lvconvert: add segtype raid5_n and conversions to/from it

Change:
- missed a return_0
- use lvseg_name() rather than my own function

Related: rhbz1366296
---
 lib/metadata/raid_manip.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f845164..3543a69 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2227,7 +2227,7 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 		log_debug_metadata("Changing image count to %u on %s.",
 				   new_image_count, display_lvname(lv));
 		if (!_lv_raid_change_image_count(lv, new_image_count, allocate_pvs, removal_lvs, 0, 0))
-			return 0;
+			return_0;
 	}
 
 	/* Remove rmeta LVs */
@@ -2703,15 +2703,6 @@ static const char *_get_segtype_alias(const struct segment_type *segtype)
 	return "";
 }
 
-/* Return "linear" for striped segtype with 1 area instead of "striped" */
-static const char *_get_segtype_name(const struct segment_type *segtype, unsigned new_image_count)
-{
-	if (!segtype || (segtype_is_striped(segtype) && new_image_count == 1))
-		return "linear";
-
-	return segtype->name;
-}
-
 static int _log_possible_conversion_types(const struct logical_volume *lv, const struct segment_type *new_segtype)
 {
 	unsigned possible_conversions = 0;
@@ -2732,7 +2723,7 @@ static int _log_possible_conversion_types(const struct logical_volume *lv, const
 
 			log_error("Converting %s from %s%s%s%s is "
 				  "directly possible to the following layout%s:",
-				  display_lvname(lv), _get_segtype_name(seg->segtype, seg->area_count),
+				  display_lvname(lv), lvseg_name(seg),
 				  *alias ? " (same as " : "", alias, *alias ? ")" : "",
 				  possible_conversions > 1 ? "s" : "");
 


