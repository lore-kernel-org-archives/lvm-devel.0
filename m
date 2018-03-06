From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:46:23 -0500
Subject: master - lvconvert: support for convertsion with active component devices
Message-ID: <201803061446.w26EkNGF026778@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6134a71a906744dec2d602f83915f0adb05e77f7
Commit:        6134a71a906744dec2d602f83915f0adb05e77f7
Parent:        f92b6f99305a31fe0e12b836942ec429c4828869
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 2 16:34:09 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:42:07 2018 +0100

lvconvert: support for convertsion with active component devices

If componet devices could be activated alone, ensure they are not breaking
common commands.

TODO: mostly likely this is not a definite list of all needed checks
and more will come later.
---
 lib/metadata/cache_manip.c |    7 ++-----
 lib/metadata/lv_manip.c    |    6 ++++++
 tools/lvconvert.c          |   12 ++++++++++++
 3 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index c46266b..5167760 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -548,11 +548,8 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	/* Localy active volume is needed for writeback */
 	if (!lv_info(cache_lv->vg->cmd, cache_lv, 1, NULL, 0, 0)) {
 		/* Give up any remote locks */
-		if (!deactivate_lv(cache_lv->vg->cmd, cache_lv)) {
-			log_error("Cannot deactivate remotely active cache volume %s.",
-				  display_lvname(cache_lv));
-			return 0;
-		}
+		if (!deactivate_lv_with_sub_lv(cache_lv))
+			return_0;
 
 		switch (first_seg(cache_seg->pool_lv)->cache_mode) {
 		case CACHE_MODE_WRITETHROUGH:
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a1fc0ff..bde2a00 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4872,6 +4872,12 @@ static int _lvresize_check(struct logical_volume *lv,
 		lp->mirrors = 0;
 	}
 
+	if (lv_component_is_active(lv)) {
+		log_error("Cannot resize logical volume %s with active component LV(s).",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	return 1;
 }
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 63f0715..21db0ef 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -833,6 +833,12 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		return 1;
 	}
 
+	if (lv_component_is_active(lv)) {
+		log_error("Cannot convert logical volume %s with active component LV(s).",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	region_size = adjusted_mirror_region_size(cmd, lv->vg->extent_size,
 						  lv->le_count,
 						  lp->region_size ? : seg->region_size, 0,
@@ -1950,6 +1956,12 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	if (!validate_snapshot_origin(org))
 		return_0;
 
+	if (lv_component_is_active(org)) {
+		log_error("Cannot use logical volume %s with active component LVs for snapshot origin.",
+			  display_lvname(org));
+		return 0;
+	}
+
 	log_warn("WARNING: Converting logical volume %s to snapshot exception store.",
 		 snap_name);
 	log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");


