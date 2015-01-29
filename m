From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Jan 2015 10:50:26 +0000 (UTC)
Subject: master - raid: preload splitted LV only when active
Message-ID: <20150129105026.7908461125@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bfeabea631782b3f0b8ec6494c4490663c412774
Commit:        bfeabea631782b3f0b8ec6494c4490663c412774
Parent:        c3bb6d77dd6193755070c62c6f3adb93c1976f19
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 28 18:30:08 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 28 18:30:08 2015 +0100

raid: preload splitted LV only when active

Check splitted leg is active before preload.
(Since splitmirrors currently only does work active raid volumes
it's not a change for current code flow).

Minor optimization included - when already positively checked
for raid image don't check again for raid metadata.
---
 lib/activate/activate.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 00d3a10..fc9bc4b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1760,18 +1760,15 @@ static int _preload_detached_lv(struct logical_volume *lv, void *data)
 	struct detached_lv_data *detached = data;
 	struct lv_list *lvl_pre;
 
-        /* Check and preload removed raid image leg */
+	/* Check and preload removed raid image leg or metadata */
 	if (lv_is_raid_image(lv)) {
 		if ((lvl_pre = find_lv_in_vg_by_lvid(detached->lv_pre->vg, &lv->lvid)) &&
-		    !lv_is_raid_image(lvl_pre->lv) &&
+		    !lv_is_raid_image(lvl_pre->lv) && lv_is_active(lv) &&
 		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
 			return_0;
-	}
-
-        /* Check and preload removed of raid metadata */
-	if (lv_is_raid_metadata(lv)) {
+	} else if (lv_is_raid_metadata(lv)) {
 		if ((lvl_pre = find_lv_in_vg_by_lvid(detached->lv_pre->vg, &lv->lvid)) &&
-		    !lv_is_raid_metadata(lvl_pre->lv) &&
+		    !lv_is_raid_metadata(lvl_pre->lv) && lv_is_active(lv) &&
 		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
 			return_0;
 	}


