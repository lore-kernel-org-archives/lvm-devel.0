From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 24 Feb 2014 22:54:17 +0000 (UTC)
Subject: master - cache: Disallow vgsplit when there are cache LVs in the VG
Message-ID: <20140224225417.17BF26031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b84797be3278e2ec232b8de7293dcac665d980f0
Commit:        b84797be3278e2ec232b8de7293dcac665d980f0
Parent:        b359b86f88642888116d54d4204d367664fbdcf5
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Feb 24 16:51:02 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Feb 24 16:54:09 2014 -0600

cache: Disallow vgsplit when there are cache LVs in the VG

The code seems to work fine for the most trivial case - moving a
simple cache LV.  However, it can cause problems when trying to
split out other LVs on different VGs and there hasn't been sufficient
testing for LV stacks that contain cache to enable the code.  So,
we actively disable what is already broken and wait for the next
release to fix it.
---
 tools/vgsplit.c |   79 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index dfcb120..150be1d 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+#include "metadata.h"  /* for 'get_only_segment_using_this_lv' */
 
 /* FIXME Why not (lv->vg == vg) ? */
 static int _lv_is_in_vg(struct volume_group *vg, struct logical_volume *lv)
@@ -72,6 +73,10 @@ static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 		    lv_is_thin_volume(lv))
 			continue;
 
+		if (lv_is_cache(lv) || lv_is_cache_pool(lv))
+			/* further checks by _move_cache() */
+			continue;
+
 		/* Ensure all the PVs used by this LV remain in the same */
 		/* VG as each other */
 		vg_with = NULL;
@@ -268,6 +273,77 @@ static int _move_thins(struct volume_group *vg_from,
 	return 1;
 }
 
+static int _move_cache(struct volume_group *vg_from,
+		       struct volume_group *vg_to)
+{
+	int is_moving;
+	struct dm_list *lvh, *lvht;
+	struct logical_volume *lv, *data, *meta, *orig;
+	struct lv_segment *seg, *cache_seg;
+
+	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
+		lv = dm_list_item(lvh, struct lv_list)->lv;
+		data = meta = orig = NULL;
+		seg = first_seg(lv);
+
+		if (!lv_is_cache(lv) && !lv_is_cache_pool(lv))
+			continue;
+
+		/*
+		 * FIXME: The code seems to move cache LVs fine, but it
+		 *        hasn't been well tested and it causes problems
+		 *        when just splitting PVs that don't contain
+		 *        cache LVs.
+		 * Waiting for next release before fixing and enabling.
+		 */
+		log_error("Unable to split VG while it contains cache LVs");
+		return 0;
+
+		if (lv_is_cache(lv)) {
+			orig = seg_lv(seg, 0);
+			data = seg_lv(first_seg(seg->pool_lv), 0);
+			meta = first_seg(seg->pool_lv)->metadata_lv;
+			/* Ensure all components are coming along */
+			is_moving = !!_lv_is_in_vg(vg_to, orig);
+		} else {
+			if (!dm_list_empty(&seg->lv->segs_using_this_lv) &&
+			    !(cache_seg = get_only_segment_using_this_lv(seg->lv)))
+				return_0;
+			orig = seg_lv(cache_seg, 0);
+			data = seg_lv(seg, 0);
+			meta = seg->metadata_lv;
+
+			if (_lv_is_in_vg(vg_to, data) ||
+			    _lv_is_in_vg(vg_to, meta))
+				is_moving = 1;
+		}
+
+		if (orig && (!!_lv_is_in_vg(vg_to, orig) != is_moving)) {
+			log_error("Can't split %s and its origin (%s)"
+				  " into separate VGs", lv->name, orig->name);
+			return 0;
+		}
+
+		if (data && (!!_lv_is_in_vg(vg_to, data) != is_moving)) {
+			log_error("Can't split %s and its cache pool"
+				  " data LV (%s) into separate VGs",
+				  lv->name, data->name);
+			return 0;
+		}
+
+		if (meta && (!!_lv_is_in_vg(vg_to, meta) != is_moving)) {
+			log_error("Can't split %s and its cache pool"
+				  " metadata LV (%s) into separate VGs",
+				  lv->name, meta->name);
+			return 0;
+		}
+		if (!_move_one_lv(vg_from, vg_to, lvh))
+			return_0;
+	}
+
+	return 1;
+}
+
 /*
  * Create or open the destination of the vgsplit operation.
  * Returns
@@ -481,6 +557,9 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!(_move_thins(vg_from, vg_to)))
 		goto_bad;
 
+	if (!(_move_cache(vg_from, vg_to)))
+		goto_bad;
+
 	/* Split metadata areas and check if both vgs have at least one area */
 	if (!(vg_split_mdas(cmd, vg_from, vg_to)) && vg_from->pv_count) {
 		log_error("Cannot split: Nowhere to store metadata for new Volume Group");


