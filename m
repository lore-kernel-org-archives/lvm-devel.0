From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Mar 2019 10:25:44 -0400
Subject: stable-2.02 - pvscan: lvmetad init should set updating before scanning
Message-ID: <201903201425.x2KEPikg020584@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dcf8f3111aea1179be1083ace772f3108b06c508
Commit:        dcf8f3111aea1179be1083ace772f3108b06c508
Parent:        ece0b131e51154253e14a938e6c24f4983e77bec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 13 17:10:49 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 7 11:07:27 2019 -0600

pvscan: lvmetad init should set updating before scanning

When pvscan needs to initialize lvmetad (e.g. lvmetad has just
started and is empty), it should set the lvmetad state to "updating"
before it scans any devices.  Otherwise, many parallel pvscans
will try to initialize lvmetad, and in some cases earlier pvscans
with fewer devices information may replace newer pvscans with
more recent information.
---
 lib/cache/lvmetad.c |   34 +++++++++++++++++++++-------------
 tools/pvscan.c      |    9 ++++-----
 2 files changed, 25 insertions(+), 18 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index f068fc6..86a880a 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -313,6 +313,7 @@ retry:
 	 * The caller should do a disk scan to populate lvmetad.
 	 */
 	if (!strcmp(daemon_token, "none")) {
+		log_debug_lvmetad("lvmetad initialization needed.");
 		ret = 0;
 		goto out;
 	}
@@ -324,10 +325,16 @@ retry:
 	 * our global filter.
 	 */
 	if (strcmp(daemon_token, _lvmetad_token)) {
+		log_debug_lvmetad("lvmetad initialization needed for different filter.");
 		ret = 0;
 		goto out;
 	}
 
+	if (wait_start)
+		log_debug_lvmetad("lvmetad initialized during wait.");
+	else
+		log_debug_lvmetad("lvmetad initialized previously.");
+
 out:
 	daemon_reply_destroy(reply);
 	return ret;
@@ -2353,23 +2360,11 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 		replacing_other_update = 1;
 	}
 
-	label_scan_pvscan_all(cmd, &scan_devs);
-
-	lvmcache_pvscan_duplicate_check(cmd);
-
-	if (lvmcache_found_duplicate_pvs()) {
-		log_warn("WARNING: Scan found duplicate PVs.");
-		return 0;
-	}
-
-	log_verbose("Scanning metadata from %d devices to update lvmetad.",
-		    dm_list_size(&scan_devs));
-
 	future_token = _lvmetad_token;
 	_lvmetad_token = (char *) LVMETAD_TOKEN_UPDATE_IN_PROGRESS;
 
 	if (!_token_update(&replaced_update)) {
-		log_error("Failed to update lvmetad which had an update in progress.");
+		log_error("Failed to start lvmetad update.");
 		_lvmetad_token = future_token;
 		return 0;
 	}
@@ -2393,6 +2388,10 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 		return 0;
 	}
 
+	log_verbose("Scanning all devices to initialize lvmetad.");
+
+	label_scan_pvscan_all(cmd, &scan_devs);
+
 	log_debug_lvmetad("Telling lvmetad to clear its cache");
 	reply = _lvmetad_send(cmd, "pv_clear_all", NULL);
 	if (!_lvmetad_handle_reply(reply, "pv_clear_all", "", NULL))
@@ -2402,6 +2401,8 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 	was_silent = silent_mode();
 	init_silent(1);
 
+	log_debug_lvmetad("Sending %d devices to lvmetad.", dm_list_size(&scan_devs));
+
 	dm_list_iterate_items_safe(devl, devl2, &scan_devs) {
 		if (sigint_caught()) {
 			ret = 0;
@@ -2442,6 +2443,13 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 		return 0;
 	}
 
+	/* This will disable lvmetad if label scan found duplicates. */
+	lvmcache_pvscan_duplicate_check(cmd);
+	if (lvmcache_found_duplicate_pvs()) {
+		log_warn("WARNING: Scan found duplicate PVs.");
+		return 0;
+	}
+
 	/*
 	 * If lvmetad is disabled, and no duplicate PVs were seen, then re-enable lvmetad.
 	 */
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 5587928..daac88f 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -381,7 +381,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		all_vgs = 1;
 		goto activate;
 	}
-       
+
 	/*
 	 * FIXME: when specific devs are named, we generally don't want to scan
 	 * any other devs, but if lvmetad is not yet populated, the first
@@ -390,11 +390,10 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	 * never scan any devices other than those specified.
 	 */
 	if (!lvmetad_token_matches(cmd)) {
-		log_verbose("Scanning all devices to initialize lvmetad.");
-
 		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, 0)) {
-			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_make_unused(cmd);
+			log_warn("WARNING: Not updating lvmetad because cache update failed.");
+			ret = ECMD_FAILED;
+			goto out;
 		}
 		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
 			log_warn("WARNING: Not using lvmetad because %s.", reason);


