From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 28 Jan 2015 12:45:52 +0000 (UTC)
Subject: master - raid: fix tree preload for splitting raid images
Message-ID: <20150128124552.E4E8360314@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b254d330e4410e3eb10ab65fbe892ba56f95e2e9
Commit:        b254d330e4410e3eb10ab65fbe892ba56f95e2e9
Parent:        3e11d85c774084783520b5cc77e059cfa5e1b254
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 28 13:36:25 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 28 13:44:06 2015 +0100

raid: fix tree preload for splitting raid images

When raid is being splitted, extracted leg & metadata
is still floating in the table - and thus we need to
detect this case and properly preload their matching
table so consequent activation of extracted LVs properly
renames (and FREES) existing raid images, so ongoing
image name shifting will work.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 666c51e..1424fab 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Fix tree preload to handle splitting raid images.
   Do not support unpartitioned DASD devices.
   Improve config validation to check if setting with string value can be empty.
 
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 424786c..151e714 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1760,6 +1760,22 @@ static int _preload_detached_lv(struct logical_volume *lv, void *data)
 	struct detached_lv_data *detached = data;
 	struct lv_list *lvl_pre;
 
+        /* Check and preload removed raid image leg */
+	if (lv_is_raid_image(lv)) {
+		if ((lvl_pre = find_lv_in_vg_by_lvid(detached->lv_pre->vg, &lv->lvid)) &&
+		    !lv_is_raid_image(lvl_pre->lv) &&
+		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
+			return_0;
+	}
+
+        /* Check and preload removed of raid metadata */
+	if (lv_is_raid_metadata(lv)) {
+		if ((lvl_pre = find_lv_in_vg_by_lvid(detached->lv_pre->vg, &lv->lvid)) &&
+		    !lv_is_raid_metadata(lvl_pre->lv) &&
+		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
+			return_0;
+	}
+
 	if ((lvl_pre = find_lv_in_vg(detached->lv_pre->vg, lv->name))) {
 		if (lv_is_visible(lvl_pre->lv) && lv_is_active(lv) &&
 		    (!lv_is_cow(lv) || !lv_is_cow(lvl_pre->lv)) &&


