From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:27 -0400
Subject: master - scan: drop bcache between lvm shell commands
Message-ID: <201804231352.w3NDqRsE000803@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae21305ee7fa60edbd85824d83ce554989161189
Commit:        ae21305ee7fa60edbd85824d83ce554989161189
Parent:        a01a8d71723740577e5fe9635412940d941b5da9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 6 13:05:17 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

scan: drop bcache between lvm shell commands

A running lvm shell keeps all lvm devices open
unless the bcache is dropped.
---
 lib/cache/lvmcache.c |   22 ++++++++++++++++++++--
 tools/lvmcmdline.c   |    7 +++----
 tools/toollib.c      |    1 -
 3 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6479080..78665bf 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -406,7 +406,7 @@ int lvmcache_verify_lock_order(const char *vgname)
 		return 1;
 
 	if (!_lock_hash)
-		return_0;
+		return 1;
 
 	dm_hash_iterate(n, _lock_hash) {
 		if (!dm_hash_get_data(_lock_hash, n))
@@ -836,6 +836,9 @@ static int _label_scan_invalid(struct cmd_context *cmd)
 		dev_count++;
 	}
 
+	if (dm_list_empty(&devs))
+		return 1;
+
 	log_debug_cache("Scanning %d devs with invalid info.", dev_count);
 
 	ret = label_scan_devs(cmd, &devs);
@@ -1236,8 +1239,10 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	struct dm_list del_cache_devs;
 	struct dm_list add_cache_devs;
 	struct lvmcache_info *info;
+	struct lvmcache_vginfo *vginfo;
 	struct device_list *devl;
 	struct format_type *fmt;
+	int vginfo_count = 0;
 
 	int r = 0;
 
@@ -1247,6 +1252,8 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		return 1;
 	}
 
+	log_debug_cache("Finding VG info");
+
 	/* Avoid recursion when a PVID can't be found! */
 	if (_scanning_in_progress)
 		return 0;
@@ -1315,6 +1322,8 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		dm_list_init(&del_cache_devs);
 		dm_list_init(&add_cache_devs);
 
+		log_debug_cache("Resolving duplicate devices");
+
 		_choose_preferred_devs(cmd, &del_cache_devs, &add_cache_devs);
 
 		dm_list_iterate_items(devl, &del_cache_devs) {
@@ -1354,6 +1363,14 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	_scanning_in_progress = 0;
 	_force_label_scan = 0;
 
+	dm_list_iterate_items(vginfo, &_vginfos) {
+		if (is_orphan_vg(vginfo->vgname))
+			continue;
+		vginfo_count++;
+	}
+
+	log_debug_cache("Found VG info for %d VGs", vginfo_count);
+
 	return r;
 }
 
@@ -2291,7 +2308,8 @@ static void _lvmcache_destroy_lockname(struct dm_hash_node *n)
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 {
 	struct dm_hash_node *n;
-	log_verbose("Wiping internal VG cache");
+
+	log_debug_cache("Dropping VG info");
 
 	_has_scanned = 0;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index fc96b8d..3774014 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3013,10 +3013,9 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		lvmnotify_send(cmd);
 
       out:
-	if (test_mode()) {
-		log_verbose("Test mode: Wiping internal cache");
-		lvmcache_destroy(cmd, 1, 0);
-	}
+
+	lvmcache_destroy(cmd, 1, 1);
+	label_scan_destroy(cmd);
 
 	if ((config_string_cft = remove_config_tree_by_source(cmd, CONFIG_STRING)))
 		dm_config_destroy(config_string_cft);
diff --git a/tools/toollib.c b/tools/toollib.c
index c8dd9d3..7e3b021 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4508,7 +4508,6 @@ int process_each_pv(struct cmd_context *cmd,
 	 * before process_each_pv is called.
 	 */
 	if (!trust_cache() && !orphans_locked) {
-		log_debug("Scanning for available devices");
 		lvmcache_destroy(cmd, 1, 0);
 
 		/*


