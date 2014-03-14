From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 14 Mar 2014 09:49:53 +0000 (UTC)
Subject: master - autoactivation: issue a VG refresh before autoactivation only if 'change' lvmetad flag is set
Message-ID: <20140314094953.5147161124@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca880a4f130a0d6111613e23f926c344217581a2
Commit:        ca880a4f130a0d6111613e23f926c344217581a2
Parent:        900cb6717b9d06e2b40049e4da2b25e8b98375a7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 14 10:44:14 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 14 10:48:56 2014 +0100

autoactivation: issue a VG refresh before autoactivation only if 'change' lvmetad flag is set

This prevents numerous VG refreshes on each "pvscan --cache -aay" call
if the VG is found complete. We need to issue the refresh only if the PV:
  - is new
  - was gone before and now it reappears (device "unplug/plug back" scenario)
  - the metadata has changed
---
 WHATS_NEW           |    2 ++
 lib/cache/lvmetad.c |    6 ++++--
 lib/cache/lvmetad.h |    3 ++-
 tools/pvscan.c      |   21 ++++++++++++---------
 4 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ed15f33..6d70a0b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.106 - 
 ====================================
+  Issue a VG refresh before autoactivation only if the PV has changed/is new.
+  Add flag to lvmetad protocol to indicate the PV scanned has changed/is new.
   Add man page for lvm2-activation-generator.
   Don't print an error and accept empty value for global/thin_disabled_features.
   Update API for internal function build_dm_uuid().
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 600fc19..a9c3100 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -750,6 +750,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 	struct lvmcache_info *info;
 	struct dm_config_tree *pvmeta, *vgmeta;
 	const char *status, *vgid;
+	int64_t changed;
 	int result;
 
 	if (!lvmetad_active() || test_mode())
@@ -819,10 +820,11 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 	if (result && handler) {
 		status = daemon_reply_str(reply, "status", "<missing>");
 		vgid = daemon_reply_str(reply, "vgid", "<missing>");
+		changed = daemon_reply_int(reply, "changed", 0);
 		if (!strcmp(status, "partial"))
-			handler(_lvmetad_cmd, vgid, 1, CHANGE_AAY);
+			handler(_lvmetad_cmd, vgid, 1, changed, CHANGE_AAY);
 		else if (!strcmp(status, "complete"))
-			handler(_lvmetad_cmd, vgid, 0, CHANGE_AAY);
+			handler(_lvmetad_cmd, vgid, 0, changed, CHANGE_AAY);
 		else if (!strcmp(status, "orphan"))
 			;
 		else
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 85b71c2..fcc4b7d 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -23,7 +23,8 @@ struct dm_config_tree;
 enum activation_change;
 
 typedef int (*activation_handler) (struct cmd_context *cmd,
-				   const char *vgid, int partial,
+				   const char *vgid,
+				   int partial, int changed,
 				   enum activation_change activate);
 
 #ifdef LVMETAD_SUPPORT
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 4f99f45..b6b3067 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -95,7 +95,8 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 #define REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY 100000
 
 static int _auto_activation_handler(struct cmd_context *cmd,
-				    const char *vgid, int partial,
+				    const char *vgid,
+				    int partial, int changed,
 				    activation_change_t activate)
 {
 	unsigned int refresh_retries = REFRESH_BEFORE_AUTOACTIVATION_RETRIES;
@@ -139,16 +140,18 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	 *
 	 * Remove this workaround with "refresh_retries" once we have proper locking in!
 	 */
-	while (refresh_retries--) {
-		if (vg_refresh_visible(vg->cmd, vg)) {
-			refresh_done = 1;
-			break;
+	if (changed) {
+		while (refresh_retries--) {
+			if (vg_refresh_visible(vg->cmd, vg)) {
+				refresh_done = 1;
+				break;
+			}
+			usleep(REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY);
 		}
-		usleep(REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY);
-	}
 
-	if (!refresh_done)
-		log_warn("%s: refresh before autoactivation failed.", vg->name);
+		if (!refresh_done)
+			log_warn("%s: refresh before autoactivation failed.", vg->name);
+	}
 
 	if (!vgchange_activate(vg->cmd, vg, activate)) {
 		log_error("%s: autoactivation failed.", vg->name);


