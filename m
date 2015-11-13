From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:25 +0000 (UTC)
Subject: master - coverity: add few internal errors
Message-ID: <20151113101925.9AAFD60763@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b2e13ac552b6209c02c6e2c00aa0db2018135523
Commit:        b2e13ac552b6209c02c6e2c00aa0db2018135523
Parent:        3089f5ab15dbab151f18067acbcdf582a90d932d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 13 09:49:59 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:18:27 2015 +0100

coverity: add few internal errors

Mark impossible paths with internal errors.
Also replace 'strcmp() with more readable seg_is...()
---
 lib/metadata/lv_manip.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0022cb7..2582ed5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4903,7 +4903,12 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			return 0;
 		}
 
-		if (!strcmp(mirr_seg->segtype->name, _lv_type_names[LV_TYPE_RAID10])) {
+		if (seg_is_raid10(mirr_seg)) {
+			if (!seg_mirrors) {
+				log_error(INTERNAL_ERROR "Missing mirror segments for %s.",
+					  display_lvname(lv));
+				return 0;
+			}
 			/* FIXME Warn if command line values are being overridden? */
 			lp->stripes = mirr_seg->area_count / seg_mirrors;
 			lp->stripe_size = mirr_seg->stripe_size;
@@ -4916,7 +4921,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 				/* Allow through "striped" and RAID 4/5/6/10 */
 				if (!seg_is_striped(seg) &&
 				    (!seg_is_raid(seg) || seg_is_mirrored(seg)) &&
-				    strcmp(seg->segtype->name, _lv_type_names[LV_TYPE_RAID10]))
+				    !seg_is_raid10(seg))
 					continue;
 	
 				sz = seg->stripe_size;
@@ -5748,7 +5753,11 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			  lv->name);
 		return 0;
 	} else if (lv_is_thin_volume(lv)) {
-		pool_lv = first_seg(lv)->pool_lv;
+		if (!(pool_lv = first_seg(lv)->pool_lv)) {
+			log_error(INTERNAL_ERROR "Thin LV %s without pool.",
+				  display_lvname(lv));
+			return 0;
+		}
 		lock_lv = pool_lv;
 	}
 


