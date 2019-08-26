From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Aug 2019 09:34:22 -0400
Subject: master - lv_manip: add synchronizations
Message-ID: <201908261334.x7QDYMm5005511@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b1dcc2eebb27cae54b4c618ab31072bdb230ea9
Commit:        4b1dcc2eebb27cae54b4c618ab31072bdb230ea9
Parent:        c98e34e4d0edbcb2594e93f06183838de0c6e2bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 26 13:28:17 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 26 15:32:19 2019 +0200

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
index af3a16f..6451368 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5830,9 +5830,17 @@ out:
 
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
index 65d8dbd..d105942 100644
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
index b9c01ee..f947976 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -529,6 +529,12 @@ int update_pool_lv(struct logical_volume *lv, int activate)
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
index ebc2243..31f9296 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2513,6 +2513,12 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
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
@@ -2520,6 +2526,12 @@ deactivate_mlv:
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


