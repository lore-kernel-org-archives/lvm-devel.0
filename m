From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:08 -0400
Subject: master - mirror: checking for mirror segtype
Message-ID: <201804201102.w3KB28nb031270@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05f954ee9b6339680c4430721a5c6bbc425fe315
Commit:        05f954ee9b6339680c4430721a5c6bbc425fe315
Parent:        79d214032b21074709cd24669f53b5e24c5c377d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 20 10:01:28 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:16:14 2018 +0200

mirror: checking for mirror segtype

Checking more correctly for mirror segtype here instead of
mirrored one which can be also 'raid'.
---
 lib/metadata/lv_manip.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 707aec3..e377cf8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4187,7 +4187,7 @@ int lv_extend(struct logical_volume *lv,
 	if (segtype_is_pool(segtype)) {
 		if (!(r = create_pool(lv, segtype, ah, stripes, stripe_size)))
 			stack;
-	} else if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype)) {
+	} else if (!segtype_is_mirror(segtype) && !segtype_is_raid(segtype)) {
 		if (!(r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
 					 stripe_size, 0u, 0)))
 			stack;
@@ -7337,7 +7337,7 @@ static int _vg_check_features(struct volume_group *vg,
 	if (!(features & FMT_SEGMENTS) &&
 	    (seg_is_cache(lp) ||
 	     seg_is_cache_pool(lp) ||
-	     seg_is_mirrored(lp) ||
+	     seg_is_mirror(lp) ||
 	     seg_is_raid(lp) ||
 	     seg_is_thin(lp))) {
 		log_error("Metadata does not support %s segments.",
@@ -7778,8 +7778,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return_NULL;
 
 	/* FIXME Log allocation and attachment should have happened inside lv_extend. */
-	if (lp->log_count &&
-	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
+	if (lp->log_count && segtype_is_mirror(create_segtype)) {
 		if (!add_mirror_log(cmd, lv, lp->log_count,
 				    first_seg(lv)->region_size,
 				    lp->pvh, lp->alloc)) {


