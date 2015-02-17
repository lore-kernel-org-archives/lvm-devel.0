From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Feb 2015 12:42:39 +0000 (UTC)
Subject: master - cleanup: drop !! from code
Message-ID: <20150217124239.ABDB460090@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4bb60c05bfc5b1be101807302e0697a4508dd98c
Commit:        4bb60c05bfc5b1be101807302e0697a4508dd98c
Parent:        cb144c0097fe111d9881457de7c686c190c07944
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 17 13:39:47 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 17 13:39:47 2015 +0100

cleanup: drop !! from code

It's unused piece of code - but gcc5 noticed problem with
usage of !! on the leftside.
---
 tools/vgsplit.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 362f854..607f8e0 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -350,7 +350,7 @@ static int _move_cache(struct volume_group *vg_from,
 			data = seg_lv(first_seg(seg->pool_lv), 0);
 			meta = first_seg(seg->pool_lv)->metadata_lv;
 			/* Ensure all components are coming along */
-			is_moving = !!_lv_is_in_vg(vg_to, orig);
+			is_moving = _lv_is_in_vg(vg_to, orig);
 		} else {
 			if (!dm_list_empty(&seg->lv->segs_using_this_lv) &&
 			    !(cache_seg = get_only_segment_using_this_lv(seg->lv)))
@@ -364,20 +364,20 @@ static int _move_cache(struct volume_group *vg_from,
 				is_moving = 1;
 		}
 
-		if (orig && (!!_lv_is_in_vg(vg_to, orig) != is_moving)) {
+		if (orig && (_lv_is_in_vg(vg_to, orig) != is_moving)) {
 			log_error("Can't split %s and its origin (%s)"
 				  " into separate VGs", lv->name, orig->name);
 			return 0;
 		}
 
-		if (data && (!!_lv_is_in_vg(vg_to, data) != is_moving)) {
+		if (data && (_lv_is_in_vg(vg_to, data) != is_moving)) {
 			log_error("Can't split %s and its cache pool"
 				  " data LV (%s) into separate VGs",
 				  lv->name, data->name);
 			return 0;
 		}
 
-		if (meta && (!!_lv_is_in_vg(vg_to, meta) != is_moving)) {
+		if (meta && (_lv_is_in_vg(vg_to, meta) != is_moving)) {
 			log_error("Can't split %s and its cache pool"
 				  " metadata LV (%s) into separate VGs",
 				  lv->name, meta->name);


