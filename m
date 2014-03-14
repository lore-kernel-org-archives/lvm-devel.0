From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 14 Mar 2014 11:10:58 +0000 (UTC)
Subject: master - autoactivation: use VG read lock
Message-ID: <20140314111058.BCC3361154@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ada47c164ae56b586fae7500be2d6aa66f5323b1
Commit:        ada47c164ae56b586fae7500be2d6aa66f5323b1
Parent:        58e812a13ff725d9ca8958fe04b92fef320bce31
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 14 12:07:41 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 14 12:10:52 2014 +0100

autoactivation: use VG read lock

The activation (including the refresh) should take the VG read lock
like the usual activation/refresh.
---
 WHATS_NEW           |    1 +
 lib/cache/lvmetad.c |    7 ++++---
 lib/cache/lvmetad.h |    2 +-
 tools/pvscan.c      |   13 ++++++++-----
 4 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6d70a0b..8571723 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Use VG read lock during 'pvscan --cache -aay' autoactivation.
   Issue a VG refresh before autoactivation only if the PV has changed/is new.
   Add flag to lvmetad protocol to indicate the PV scanned has changed/is new.
   Add man page for lvm2-activation-generator.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a9c3100..cc51258 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -749,7 +749,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 	daemon_reply reply;
 	struct lvmcache_info *info;
 	struct dm_config_tree *pvmeta, *vgmeta;
-	const char *status, *vgid;
+	const char *status, *vgname, *vgid;
 	int64_t changed;
 	int result;
 
@@ -819,12 +819,13 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 
 	if (result && handler) {
 		status = daemon_reply_str(reply, "status", "<missing>");
+		vgname = daemon_reply_str(reply, "vgname", "<missing>");
 		vgid = daemon_reply_str(reply, "vgid", "<missing>");
 		changed = daemon_reply_int(reply, "changed", 0);
 		if (!strcmp(status, "partial"))
-			handler(_lvmetad_cmd, vgid, 1, changed, CHANGE_AAY);
+			handler(_lvmetad_cmd, vgname, vgid, 1, changed, CHANGE_AAY);
 		else if (!strcmp(status, "complete"))
-			handler(_lvmetad_cmd, vgid, 0, changed, CHANGE_AAY);
+			handler(_lvmetad_cmd, vgname, vgid, 0, changed, CHANGE_AAY);
 		else if (!strcmp(status, "orphan"))
 			;
 		else
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index fcc4b7d..d9aa77f 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -23,7 +23,7 @@ struct dm_config_tree;
 enum activation_change;
 
 typedef int (*activation_handler) (struct cmd_context *cmd,
-				   const char *vgid,
+				   const char *vgname, const char *vgid,
 				   int partial, int changed,
 				   enum activation_change activate);
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index b6b3067..5db627a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -95,14 +95,13 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 #define REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY 100000
 
 static int _auto_activation_handler(struct cmd_context *cmd,
-				    const char *vgid,
+				    const char *vgname, const char *vgid,
 				    int partial, int changed,
 				    activation_change_t activate)
 {
 	unsigned int refresh_retries = REFRESH_BEFORE_AUTOACTIVATION_RETRIES;
 	int refresh_done = 0;
 	struct volume_group *vg;
-	int consistent = 0;
 	struct id vgid_raw;
 	int r = 0;
 
@@ -114,8 +113,12 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 		return_0;
 
 	/* NB. This is safe because we know lvmetad is running and we won't hit disk. */
-	if (!(vg = vg_read_internal(cmd, NULL, (const char *) &vgid_raw, 0, &consistent)))
-	    return 1;
+	vg = vg_read(cmd, vgname, (const char *)&vgid_raw, 0);
+	if (vg_read_error(vg)) {
+		log_error("Failed to read Volume Group \"%s\" (%s) during autoactivation.", vgname, vgid);
+		release_vg(vg);
+		return 0;
+	}
 
 	if (vg_is_clustered(vg)) {
 		r = 1; goto out;
@@ -161,7 +164,7 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	r = 1;
 
 out:
-	release_vg(vg);
+	unlock_and_release_vg(cmd, vg, vgname);
 	return r;
 }
 


