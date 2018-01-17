From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:46:32 -0500
Subject: master - lvconvert: use excl activation for conversion
Message-ID: <201801171346.w0HDkWJg029802@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e86910b052ef50dfdaad104d17bda679f698e31f
Commit:        e86910b052ef50dfdaad104d17bda679f698e31f
Parent:        c26458339ee3b3bdd0e49127e887c0417cbc1438
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 12 13:34:13 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:43:34 2018 +0100

lvconvert: use excl activation for conversion

Use properly exclusive activation when reactivating origin after
snapshot merge (since origin must have been previously also exlusively
activated).

Same applies when converting volumes to thin-pool or cache.

Previously used 'only' local activation incorrectly allowed local
activation of some targets (i.e. raid) - thus 'leaking' chance to
activate same device on another node - which can be a problem
for device types like raid.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    2 +-
 lib/metadata/pool_manip.c  |    6 +++---
 tools/lvconvert.c          |   16 ++++++++--------
 4 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 489c315..efaa5b3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Preserve exclusive activation during thin snaphost merge.
   Suppress some repeated reads of the same disk data at the device layer.
   Avoid exceeding array bounds in allocation tag processing.
   Refactor metadata reading code to use callback functions.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 55ed724..97a3339 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -960,7 +960,7 @@ int wipe_cache_pool(struct logical_volume *cache_pool_lv)
 	}
 
 	cache_pool_lv->status |= LV_TEMPORARY;
-	if (!activate_lv_local(cache_pool_lv->vg->cmd, cache_pool_lv)) {
+	if (!activate_lv_excl_local(cache_pool_lv->vg->cmd, cache_pool_lv)) {
 		log_error("Aborting. Failed to activate cache pool %s.",
 			  display_lvname(cache_pool_lv));
 		return 0;
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 18e4e65..b832db7 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -526,7 +526,7 @@ int create_pool(struct logical_volume *pool_lv,
 		 * or directly converted to invisible device via suspend/resume
 		 */
 		pool_lv->status |= LV_TEMPORARY;
-		if (!activate_lv_local(pool_lv->vg->cmd, pool_lv)) {
+		if (!activate_lv_excl_local(pool_lv->vg->cmd, pool_lv)) {
 			log_error("Aborting. Failed to activate pool metadata %s.",
 				  display_lvname(pool_lv));
 			goto bad;
@@ -538,7 +538,7 @@ int create_pool(struct logical_volume *pool_lv,
 		}
 		pool_lv->status &= ~LV_TEMPORARY;
 		/* Deactivates cleared metadata LV */
-		if (!deactivate_lv_local(pool_lv->vg->cmd, pool_lv)) {
+		if (!deactivate_lv(pool_lv->vg->cmd, pool_lv)) {
 			log_error("Aborting. Could not deactivate pool metadata %s.",
 				  display_lvname(pool_lv));
 			return 0;
@@ -660,7 +660,7 @@ static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg
 		return_0;
 
 	/* Spare LV should not be active */
-	if (!deactivate_lv_local(vg->cmd, lv)) {
+	if (!deactivate_lv(vg->cmd, lv)) {
 		log_error("Unable to deactivate pool metadata spare LV. "
 			  "Manual intervention required.");
 		return 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index deb7cc9..fee0a4e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1970,14 +1970,14 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		log_warn("WARNING: %s not zeroed.", snap_name);
 	else {
 		lv->status |= LV_TEMPORARY;
-		if (!activate_lv_local(cmd, lv) ||
+		if (!activate_lv_excl_local(cmd, lv) ||
 		    !wipe_lv(lv, (struct wipe_params) { .do_zero = 1 })) {
 			log_error("Aborting. Failed to wipe snapshot exception store.");
 			return 0;
 		}
 		lv->status &= ~LV_TEMPORARY;
 		/* Deactivates cleared metadata LV */
-		if (!deactivate_lv_local(lv->vg->cmd, lv)) {
+		if (!deactivate_lv(lv->vg->cmd, lv)) {
 			log_error("Failed to deactivate zeroed snapshot exception store.");
 			return 0;
 		}
@@ -2170,7 +2170,7 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 		log_print_unless_silent("Volume %s replaced origin %s.",
 					display_lvname(origin), display_lvname(lv));
 
-		if (origin_is_active && !activate_lv(cmd, lv)) {
+		if (origin_is_active && !activate_lv_excl_local(cmd, lv)) {
 			log_error("Failed to reactivate origin %s.",
 				  display_lvname(lv));
 			return 0;
@@ -2278,13 +2278,13 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!activate_lv_local(cmd, pmslv)) {
+	if (!activate_lv_excl_local(cmd, pmslv)) {
 		log_error("Cannot activate pool metadata spare volume %s.",
 			  pmslv->name);
 		return 0;
 	}
 
-	if (!activate_lv_local(cmd, mlv)) {
+	if (!activate_lv_excl_local(cmd, mlv)) {
 		log_error("Cannot activate thin pool metadata volume %s.",
 			  mlv->name);
 		goto deactivate_pmslv;
@@ -2476,13 +2476,13 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!activate_lv_local(cmd, pmslv)) {
+	if (!activate_lv_excl_local(cmd, pmslv)) {
 		log_error("Cannot activate pool metadata spare volume %s.",
 			  pmslv->name);
 		return 0;
 	}
 
-	if (!activate_lv_local(cmd, mlv)) {
+	if (!activate_lv_excl_local(cmd, mlv)) {
 		log_error("Cannot activate cache pool metadata volume %s.",
 			  mlv->name);
 		goto deactivate_pmslv;
@@ -3130,7 +3130,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 		if (zero_metadata) {
 			metadata_lv->status |= LV_TEMPORARY;
-			if (!activate_lv_local(cmd, metadata_lv)) {
+			if (!activate_lv_excl_local(cmd, metadata_lv)) {
 				log_error("Aborting. Failed to activate metadata lv.");
 				goto bad;
 			}


