From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:05:50 -0400
Subject: [PATCH 17/35] Use mdas_empty_or_ignored() in place of checks for empty mda list.
In-Reply-To: <1277175968-9661-17-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-13-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-14-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-15-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-16-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-17-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-18-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

With the addition of ignored mdas, we replace all checks for an empty
mda list with a new function to look for either an empty mda list or
ignored mdas.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/cache/lvmcache.c    |    3 ++-
 lib/metadata/metadata.c |   31 ++++++++++++++++++-------------
 2 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 213f3cf..a7b11cc 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1197,7 +1197,8 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 	}
 
 	/* If PV without mdas is already in a real VG, don't make it orphan */
-	if (is_orphan_vg(vgname) && info->vginfo && !dm_list_size(&info->mdas) &&
+	if (is_orphan_vg(vgname) && info->vginfo &&
+	    mdas_empty_or_ignored(&info->mdas) &&
 	    !is_orphan_vg(info->vginfo->vgname) && memlock())
 		return 1;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6b7931e..d1d2fed 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1305,7 +1305,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	 * this means checking every VG by scanning every PV on the
 	 * system.
 	 */
-	if (pv && is_orphan(pv) && !dm_list_size(&mdas)) {
+	if (pv && is_orphan(pv) && mdas_empty_or_ignored(&mdas)) {
 		if (!scan_vgs_for_pvs(cmd))
 			return_0;
 		pv = pv_read(cmd, name, NULL, NULL, 0, 0);
@@ -1798,7 +1798,7 @@ static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (is_orphan_vg(pv->vg_name) && !dm_list_size(&mdas)) {
+	if (is_orphan_vg(pv->vg_name) && mdas_empty_or_ignored(&mdas)) {
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd))
 			return_NULL;
@@ -2722,8 +2722,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	/* Ensure every PV in the VG was in the cache */
 	if (correct_vg) {
 		/*
-		 * If the VG has PVs without mdas, they may still be
-		 * orphans in the cache: update the cache state here.
+		 * If the VG has PVs without mdas, or ignored mdas, they may
+		 * still be orphans in the cache: update the cache state here.
 		 */
 		if (!inconsistent &&
 		    dm_list_size(&correct_vg->pvs) > dm_list_size(pvids)) {
@@ -2738,11 +2738,12 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 				/*
 				 * PV not marked as belonging to this VG in cache.
-				 * Check it's an orphan without metadata area.
+				 * Check it's an orphan without metadata area
+				 * not ignored.
 				 */
 				if (!(info = info_from_pvid(pvl->pv->dev->pvid, 1)) ||
 				   !info->vginfo || !is_orphan_vg(info->vginfo->vgname) ||
-				   dm_list_size(&info->mdas)) {
+				   !mdas_empty_or_ignored(&info->mdas)) {
 					inconsistent_pvs = 1;
 					break;
 				}
@@ -3128,20 +3129,24 @@ const char *find_vgname_from_pvid(struct cmd_context *cmd,
 			return_NULL;
 		}
 		/*
-		 * If an orphan PV has no MDAs it may appear to be an
-		 * orphan until the metadata is read off another PV in
-		 * the same VG.  Detecting this means checking every VG
-		 * by scanning every PV on the system.
+		 * If an orphan PV has no MDAs, or it has MDAs but the
+		 * MDA is ignored, it may appear to be an orphan until
+		 * the metadata is read off another PV in the same VG.
+		 * Detecting this means checking every VG by scanning
+		 * every PV on the system.
 		 */
-		if (!dm_list_size(&info->mdas)) {
+		if (mdas_empty_or_ignored(&info->mdas)) {
 			if (!scan_vgs_for_pvs(cmd)) {
 				log_error("Rescan for PVs without "
 					  "metadata areas failed.");
 				return NULL;
 			}
+			/*
+			 * Ask lvmcache again - we may have a non-orphan
+			 * name now
+			 */
+			vgname = lvmcache_vgname_from_pvid(cmd, pvid);
 		}
-		/* Ask lvmcache again - we may have a non-orphan name now */
-		vgname = lvmcache_vgname_from_pvid(cmd, pvid);
 	}
 	return vgname;
 }
-- 
1.6.0.6


