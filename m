From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Sep 2014 12:45:10 +0000 (UTC)
Subject: master - raid: destroy allocation handle on error path
Message-ID: <20140912124510.4E66E6109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08914ed7c1df18dc2a16c6f896ae388ac5e7c299
Commit:        08914ed7c1df18dc2a16c6f896ae388ac5e7c299
Parent:        76c3c94bd2a2ac4d3e255541da515cae8e823621
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 12 11:37:01 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:30 2014 +0200

raid: destroy allocation handle on error path

Don't leak ah memory pool on error path.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   14 +++++++++-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ebbc76f..f127d7d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Don't leak alloc_handle on raid target error path.
   Properly validate raid leg names.
   Archive metadata before starting their modification in raid target.
   Add missing vg_revert in suspend_lv() error path in raid target.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b670058..58bc09b 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -459,15 +459,17 @@ static int _alloc_image_components(struct logical_volume *lv,
 		 * from 's + count'.
 		 */
 		if (!(lvl_array[s + count].lv =
-		      _alloc_image_component(lv, NULL, ah, s + count, RAID_META)))
+		      _alloc_image_component(lv, NULL, ah, s + count, RAID_META))) {
+			alloc_destroy(ah);
 			return_0;
-
+		}
 		dm_list_add(new_meta_lvs, &(lvl_array[s + count].list));
 
 		if (!(lvl_array[s].lv =
-		      _alloc_image_component(lv, NULL, ah, s, RAID_IMAGE)))
+		      _alloc_image_component(lv, NULL, ah, s, RAID_IMAGE))) {
+			alloc_destroy(ah);
 			return_0;
-
+		}
 		dm_list_add(new_data_lvs, &(lvl_array[s].list));
 	}
 
@@ -517,8 +519,10 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 				    &allocatable_pvs, data_lv->alloc, 0, NULL)))
 		return_0;
 
-	if (!(*meta_lv = _alloc_image_component(data_lv, base_name, ah, 0, RAID_META)))
+	if (!(*meta_lv = _alloc_image_component(data_lv, base_name, ah, 0, RAID_META))) {
+		alloc_destroy(ah);
 		return_0;
+	}
 
 	alloc_destroy(ah);
 


