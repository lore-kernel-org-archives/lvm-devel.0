From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jan 2019 16:41:19 -0500
Subject: master - cleanup: indent
Message-ID: <201901282141.x0SLfJwt002836@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d19e3727951853093828b072e254e447f7d61c60
Commit:        d19e3727951853093828b072e254e447f7d61c60
Parent:        5cf8888976118cfbc44da28462ebaf9aae3927d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 24 14:12:42 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 28 22:39:10 2019 +0100

cleanup: indent

---
 lib/metadata/lv_manip.c   |    2 +-
 lib/metadata/pool_manip.c |    2 +-
 lib/metadata/thin_manip.c |    2 --
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 00039ef..3b08d05 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7350,7 +7350,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 
 	if (wp.do_wipe_signatures) {
 		log_verbose("Wiping known signatures on logical volume \"%s/%s\"",
-			     lv->vg->name, lv->name);
+			    lv->vg->name, lv->name);
 		if (!wipe_known_signatures(lv->vg->cmd, dev, name, 0,
 					   TYPE_DM_SNAPSHOT_COW,
 					   wp.yes, wp.force, NULL))
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 80d2e07..934bb56 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -790,7 +790,7 @@ int vg_remove_pool_metadata_spare(struct volume_group *vg)
 
 	log_print_unless_silent("Renaming existing pool metadata spare "
 				"logical volume \"%s\" to \"%s/%s\".",
-                                display_lvname(lv), vg->name, new_name);
+				display_lvname(lv), vg->name, new_name);
 
 	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
 		return_0;
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index e1b3179..5e52889 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -266,7 +266,6 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 	if (!lv_thin_pool_percent(pool_seg->lv, 1, &percent))
 		return_0;
 
-
 	if (percent >= min_threshold) {
 		log_warn("WARNING: Remaining free space in metadata of thin pool %s "
 			 "is too low (%s%% >= %s%%). "
@@ -277,7 +276,6 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 		return 0;
 	}
 
-
 	if (percent > threshold) {
 		log_debug("Threshold configured for free metadata space in "
 			  "thin pool %s has been reached (%s%% > %s%%).",


