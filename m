From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Sep 2014 12:45:16 +0000 (UTC)
Subject: master - cleanup: simplify _extract_image_components
Message-ID: <20140912124516.991E060C83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab7977de7b0c3d4586c40eca0179fbae24bc23ba
Commit:        ab7977de7b0c3d4586c40eca0179fbae24bc23ba
Parent:        68981310916114e8659bb7754c5847a178aaea5d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 11 22:55:12 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:31 2014 +0200

cleanup: simplify _extract_image_components

Reorder test - first check for writable flag and then allocate.
---
 lib/metadata/raid_manip.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0c96fd0..6883a68 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1261,8 +1261,13 @@ int lv_raid_merge(struct logical_volume *image_lv)
 	struct lv_segment *seg;
 	struct volume_group *vg = image_lv->vg;
 
-	lv_name = dm_pool_strdup(vg->vgmem, image_lv->name);
-	if (!lv_name)
+	if (image_lv->status & LVM_WRITE) {
+		log_error("%s is not read-only - refusing to merge.",
+			  display_lvname(image_lv));
+		return 0;
+	}
+
+	if (!(lv_name = dm_pool_strdup(vg->vgmem, image_lv->name)))
 		return_0;
 
 	if (!(p = strstr(lv_name, "_rimage_"))) {
@@ -1272,12 +1277,6 @@ int lv_raid_merge(struct logical_volume *image_lv)
 	}
 	*p = '\0'; /* lv_name is now that of top-level RAID */
 
-	if (image_lv->status & LVM_WRITE) {
-		log_error("%s/%s is not read-only - refusing to merge",
-			  vg->name, image_lv->name);
-		return 0;
-	}
-
 	if (!(lvl = find_lv_in_vg(vg, lv_name))) {
 		log_error("Unable to find containing RAID array for %s.",
 			  display_lvname(image_lv));


