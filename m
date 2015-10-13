From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:24 +0000 (UTC)
Subject: master - thin: check for overflown pool earlier
Message-ID: <20151013140324.F1F3860E41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7b4359ff41634096770d464d362d43d2e82bbda
Commit:        c7b4359ff41634096770d464d362d43d2e82bbda
Parent:        5695c6aca63b2312e76f8b3fbbea95601269f8c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 7 15:10:03 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 14:37:07 2015 +0200

thin: check for overflown pool earlier

Check for pool early before we actually start to modify metadata.
This requires locally active thin-pool.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   18 ++++++++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f683456..348c099 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Check for enough space in thin-pool in command before creating new thin.
   Make libblkid detect all copies of the same signature if use_blkid_wiping=1.
   Fix vgimportclone with -n to not add number unnecessarily to base VG name.
   Cleanup vgimportclone script and remove dependency on awk, grep, cut and tr.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3e870d5..8a0bbcd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7087,12 +7087,18 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			}
 		}
 
-		if (seg_is_thin_volume(lp) &&
-		    lv_is_new_thin_pool(pool_lv)) {
-			thin_pool_was_active = lv_is_active(pool_lv);
-			if (!check_new_thin_pool(pool_lv))
-				return_NULL;
-			/* New pool is now inactive */
+		if (seg_is_thin_volume(lp)) {
+			if (lv_is_new_thin_pool(pool_lv)) {
+				thin_pool_was_active = lv_is_active(pool_lv);
+				if (!check_new_thin_pool(pool_lv))
+					return_NULL;
+				/* New pool is now inactive */
+			} else if (!pool_below_threshold(first_seg(pool_lv))) {
+				log_error("Cannot create new thin volume, free space in "
+					  "thin pool %s reached threshold.",
+					  display_lvname(pool_lv));
+				return NULL;
+			}
 		}
 
 		if (seg_is_cache(lp) &&


