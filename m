From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Aug 2018 12:06:54 -0400
Subject: 2018-06-01-stable - mirror: fix splitmirrors for mirror type
Message-ID: <201808071606.w77G6s6J028664@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=672b8c196b91e4cf6567223ce44dfb902281b791
Commit:        672b8c196b91e4cf6567223ce44dfb902281b791
Parent:        cc96eea0298e537bb6299a3ecc9c68737cae2e68
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 7 10:34:17 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 7 18:04:39 2018 +0200

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
index e31aca2..e98fec0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.182 - 
 ==============================
+  Fix lvconvert --splitmirror for mirror type (2.02.178).
   Do not pair cache policy and cache metadata format.
 
 Version 2.02.181 - 01 August 2018
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 70cce30..2a85ef9 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2112,6 +2112,11 @@ static int _preload_detached_lv(struct logical_volume *lv, void *data)
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
index 7f38d4f..c7d8a9e 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -786,7 +786,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 
 	act = lv_is_active(lv_lock_holder(lv));
 
-	if (act && !_activate_lv_like_model(lv, new_lv)) {
+	if (act && (!deactivate_lv(cmd, new_lv) || !_activate_lv_like_model(lv, new_lv))) {
 		log_error("Failed to rename newly split LV in the kernel");
 		return 0;
 	}


