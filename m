From: David Teigland <teigland@sourceware.org>
Date: Wed, 22 Apr 2020 21:26:16 +0000 (GMT)
Subject: master - use refresh_filters only where needed
Message-ID: <20200422212616.C44BB3952501@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4047a321285fc0d1a70fd519fb53fc778fe6093b
Commit:        4047a321285fc0d1a70fd519fb53fc778fe6093b
Parent:        a509776588a5c0c0bfc2394e4d1ed717531b0257
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 22 14:08:54 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 22 14:08:54 2020 -0500

use refresh_filters only where needed

Filters are changed and need refresh in only one
place (vgimportclone), so avoid doing the refresh
for every other command that doesn't need it.
---
 lib/cache/lvmcache.c  | 10 ----------
 tools/vgimportclone.c |  4 +++-
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index bcb893346..b8575ff62 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1032,15 +1032,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	log_debug_cache("Finding VG info");
 
-	/* FIXME: can this happen? */
-	if (!cmd->filter) {
-		log_error("label scan is missing filter");
-		goto out;
-	}
-
-	if (!refresh_filters(cmd))
-		log_error("Scan failed to refresh device filter.");
-
 	/*
 	 * Duplicates found during this label scan are added to _initial_duplicates.
 	 */
@@ -1103,7 +1094,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	r = 1;
 
-      out:
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (is_orphan_vg(vginfo->vgname))
 			continue;
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index be0186101..ee1c28fae 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -315,6 +315,8 @@ retry_name:
 		goto_out;
 	log_debug("Using new VG name %s.", vp.new_vgname);
 
+	lvmcache_destroy(cmd, 1, 0);
+
 	/*
 	 * Create a device filter so that we are only working with the devices
 	 * in arg_import.  With the original devs hidden (that arg_import were
@@ -325,7 +327,7 @@ retry_name:
 	init_internal_filtering(1);
 	dm_list_iterate_items(vd, &vp.arg_import)
 		internal_filter_allow(cmd->mem, vd->dev);
-	lvmcache_destroy(cmd, 1, 0);
+	refresh_filters(cmd);
 
 	log_debug("Changing VG %s to %s.", vp.old_vgname, vp.new_vgname);
 



