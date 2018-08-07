From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Aug 2018 12:01:19 -0400
Subject: master - mirror: fix splitmirrors for mirror type
Message-ID: <201808071601.w77G1Jma026717@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=acab59137869e2f8119d8faa09fdab5074b8c4b2
Commit:        acab59137869e2f8119d8faa09fdab5074b8c4b2
Parent:        c34291e3bf61cc2644389cbce77e9953f67a843a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 7 10:34:17 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 7 17:58:30 2018 +0200

mirror: fix splitmirrors for mirror type

With improved mirror activation code --splitmirror issue poppedup
since there was missing proper preload code and deactivation
for splitted mirror leg.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    5 +++++
 lib/metadata/mirror.c   |    2 +-
 3 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2cf7969..0a0b6e9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Fix lvconvert --splitmirror for mirror type (2.02.178).
   Do not pair cache policy and cache metadata format.
   lvconvert: reject conversions on raid1 LVs with split tracked SubLVs
   lvconvert: reject conversions on raid1 split tracked SubLVs
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d4a20c9..ead3b8d 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2001,6 +2001,11 @@ static int _preload_detached_lv(struct logical_volume *lv, void *data)
 		    !lv_is_raid_metadata(lv_pre) && lv_is_active(lv) &&
 		    !_lv_preload(lv_pre, detached->laopts, detached->flush_required))
 			return_0;
+	} else if (lv_is_mirror_image(lv)) {
+		if ((lv_pre = find_lv_in_vg_by_lvid(detached->lv_pre->vg, &lv->lvid)) &&
+		    !lv_is_mirror_image(lv_pre) && lv_is_active(lv) &&
+		    !_lv_preload(lv_pre, detached->laopts, detached->flush_required))
+			return_0;
 	}
 
 	if (!lv_is_visible(lv) && (lv_pre = find_lv(detached->lv_pre->vg, lv->name)) &&
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 58615d8..c86ff90 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -774,7 +774,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 
 	act = lv_is_active(lv_lock_holder(lv));
 
-	if (act && !_activate_lv_like_model(lv, new_lv)) {
+	if (act && (!deactivate_lv(cmd, new_lv) || !_activate_lv_like_model(lv, new_lv))) {
 		log_error("Failed to rename newly split LV in the kernel");
 		return 0;
 	}


