From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:56:05 +0000 (UTC)
Subject: master - cleanup: defines
Message-ID: <20161123165605.5337060F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae95937af46989dbce992eace2914ace3b001a4a
Commit:        ae95937af46989dbce992eace2914ace3b001a4a
Parent:        d05668c587348461b1fe86858a7b7044ccf687b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 23 10:54:06 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:55:03 2016 +0100

cleanup: defines

---
 lib/metadata/mirror.c |   26 ++++++++++----------------
 1 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index baa19fa..cb1f8c8 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -793,9 +793,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 		detached_log_lv = detach_mirror_log(mirrored_seg);
 		if (!remove_layer_from_lv(lv, sub_lv))
 			return_0;
-		lv->status &= ~MIRROR;
-		lv->status &= ~MIRRORED;
-		lv->status &= ~LV_NOTSYNCED;
+		lv->status &= ~(MIRROR | MIRRORED | LV_NOTSYNCED);
 	}
 
 	/*
@@ -965,16 +963,14 @@ static int _remove_mirror_images(struct logical_volume *lv,
 			log_error("Failed to add mirror images.");
 			return 0;
 		}
-                /*
-                 * No longer a mirror? Even though new_area_count was 1,
-                 * _merge_mirror_images may have resulted into lv being still a
-                 * mirror. Fix up the flags if we only have one image left.
-                 */
-                if (lv_mirror_count(lv) == 1) {
-                    lv->status &= ~MIRROR;
-                    lv->status &= ~MIRRORED;
-                    lv->status &= ~LV_NOTSYNCED;
-                }
+		/*
+		 * No longer a mirror? Even though new_area_count was 1,
+		 * _merge_mirror_images may have resulted into lv being still a
+		 * mirror. Fix up the flags if we only have one image left.
+		 */
+		if (lv_mirror_count(lv) == 1)
+			lv->status &= ~(MIRROR | MIRRORED | LV_NOTSYNCED);
+
 		mirrored_seg = first_seg(lv);
 		if (remove_log && !detached_log_lv)
 			detached_log_lv = detach_mirror_log(mirrored_seg);
@@ -988,9 +984,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		/* All mirror images are gone.
 		 * It can happen for vgreduce --removemissing. */
 		detached_log_lv = detach_mirror_log(mirrored_seg);
-		lv->status &= ~MIRROR;
-		lv->status &= ~MIRRORED;
-		lv->status &= ~LV_NOTSYNCED;
+		lv->status &= ~(MIRROR | MIRRORED | LV_NOTSYNCED);
 		if (!replace_lv_with_error_segment(lv))
 			return_0;
 	} else if (remove_log)


