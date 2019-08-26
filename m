From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Aug 2019 09:40:03 -0400
Subject: stable-2.02 - lv_manip: add synchronizations
Message-ID: <201908261340.x7QDe3Ik005676@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e03bdd7556289ef130c6e173e86207e2a3d765c9
Commit:        e03bdd7556289ef130c6e173e86207e2a3d765c9
Parent:        c4a6b9ded02ffe682285ec4c2706114f6f2bd481
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 26 13:28:17 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 26 15:36:41 2019 +0200

lv_manip: add synchronizations

New udev in rawhide seems to be 'dropping' udev rule operations for devices
that are no longer existing - while this is 'probably' a bug - it's
revealing moments in lvm2 that likely should not run in a single
transaction and we should wait for a cookie before submitting more work.

TODO: it seem more 'error' paths should always include synchronization
before starting deactivating 'just activated' devices.
We should probably figure out some 'automatic' solution for this instead
of placing sync_local_dev_name() all over the place...
---
 lib/metadata/lv_manip.c       |   14 +++++++++++---
 lib/metadata/snapshot_manip.c |    5 +++++
 lib/metadata/thin_manip.c     |    6 ++++++
 tools/lvconvert.c             |   12 ++++++++++++
 4 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 87c81c3..76451ea 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5655,9 +5655,17 @@ out:
 
 	ret = 1;
 bad:
-	if (activated && !deactivate_lv(cmd, lock_lv)) {
-		log_error("Problem deactivating %s.", display_lvname(lock_lv));
-		ret = 0;
+	if (activated) {
+		if (!sync_local_dev_names(lock_lv->vg->cmd)) {
+			log_error("Failed to sync local devices before deactivating LV %s.",
+				  display_lvname(lock_lv));
+			return 0;
+		}
+
+		if (!deactivate_lv(cmd, lock_lv)) {
+			log_error("Problem deactivating %s.", display_lvname(lock_lv));
+			ret = 0;
+		}
 	}
 
 	return ret;
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 81e4703..aeb739c 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -292,6 +292,11 @@ int vg_remove_snapshot(struct logical_volume *cow)
 
 	if (is_origin_active &&
 	    lv_is_virtual_origin(origin)) {
+		if (!sync_local_dev_names(origin->vg->cmd)) {
+			log_error("Failed to sync local devices before deactivating origin LV %s.",
+				  display_lvname(origin));
+			return 0;
+		}
 		if (!deactivate_lv(origin->vg->cmd, origin)) {
 			log_error("Failed to deactivate logical volume \"%s\"",
 				  origin->name);
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 2216927..3aab297 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -531,6 +531,12 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 			}
 		}
 
+		if (!sync_local_dev_names(lv->vg->cmd)) {
+			log_error("Failed to sync local devices LV %s.",
+				  display_lvname(lv));
+			return 0;
+		}
+
 		if (activate &&
 		    !deactivate_lv(lv->vg->cmd, lv)) {
 			log_error("Failed to deactivate %s.", display_lvname(lv));
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index bc666c0..8a07a84 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2529,6 +2529,12 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 	/* TODO: any active validation of cache-pool metadata? */
 
 deactivate_mlv:
+	if (!sync_local_dev_names(cmd)) {
+		log_error("Failed to sync local devices before deactivating LV %s.",
+			  display_lvname(mlv));
+		return 0;
+	}
+
 	if (!deactivate_lv(cmd, mlv)) {
 		log_error("Cannot deactivate pool metadata volume %s.",
 			  display_lvname(mlv));
@@ -2536,6 +2542,12 @@ deactivate_mlv:
 	}
 
 deactivate_pmslv:
+	if (!sync_local_dev_names(cmd)) {
+		log_error("Failed to sync local devices before deactivating LV %s.",
+			  display_lvname(pmslv));
+		return 0;
+	}
+
 	if (!deactivate_lv(cmd, pmslv)) {
 		log_error("Cannot deactivate pool metadata spare volume %s.",
 			  display_lvname(pmslv));


