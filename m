From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  6 Apr 2023 11:47:36 +0000 (GMT)
Subject: main - cleanup: rename function
Message-ID: <20230406114736.7342A3858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=334117ee00aa6751ff7589b983497e1b7eee9d76
Commit:        334117ee00aa6751ff7589b983497e1b7eee9d76
Parent:        1fb3e08033570365580b576777e312d2f9c2d86d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 6 14:52:28 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 6 11:06:04 2023 +0200

cleanup: rename function

Rename _thin_lv_has_device_id and use common function naming
with _lv_has_thin_device_id().
---
 lib/activate/dev_manager.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 689305f7b..c4bd6ab7b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1070,7 +1070,7 @@ bad:
 	return r;
 }
 
-static int _thin_lv_has_device_id(struct dm_pool *mem, const struct logical_volume *lv,
+static int _lv_has_thin_device_id(struct dm_pool *mem, const struct logical_volume *lv,
 				  const char *layer, unsigned device_id)
 {
 	char *dlid;
@@ -3529,7 +3529,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		 */
 		if ((dinfo = _cached_dm_info(dm->mem, dtree, lv, NULL))) {
 			/* Merging origin LV is present, check if mergins is already running. */
-			if ((seg_is_thin_volume(seg) && _thin_lv_has_device_id(dm->mem, lv, NULL, seg->device_id)) ||
+			if ((seg_is_thin_volume(seg) && _lv_has_thin_device_id(dm->mem, lv, NULL, seg->device_id)) ||
 			    (!seg_is_thin_volume(seg) && lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) {
 				log_debug_activation("Merging of snapshot volume %s to origin %s is in progress.",
 						     display_lvname(seg->lv), display_lvname(seg->lv));

