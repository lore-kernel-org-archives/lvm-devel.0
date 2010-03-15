From: Milan Broz <mbroz@redhat.com>
Date: Mon, 15 Mar 2010 19:37:42 +0100
Subject: [PATCH 1/2] [RFC] Run only one full device rescan.
Message-ID: <1268678263-18037-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There is several situation when we do crazy rescans
of all devices.

For example, VG with 20 missing pvs rescan more
the 400 times in pvs command.

This "RFC" patch just tries scan only once.

Beware: there are some places in code, where we should
put lvmcache_allow_full_scan() to allow extra rescan.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/cache/lvmcache.c |   20 ++++++++++++++++----
 lib/cache/lvmcache.h |    3 +++
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 35ee05b..29fd1df 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -33,7 +33,7 @@ static struct dm_hash_table *_vgname_hash = NULL;
 static struct dm_hash_table *_lock_hash = NULL;
 static struct dm_list _vginfos;
 static int _scanning_in_progress = 0;
-static int _has_scanned = 0;
+static enum { NOT_SCANNED = 0, ALLOW_RESCAN, SCANNED } _has_scanned = NOT_SCANNED;
 static int _vgs_locked = 0;
 static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
 
@@ -69,6 +69,8 @@ int lvmcache_init(void)
 		_vg_global_lock_held = 0;
 	}
 
+	lvmcache_allow_full_scan();
+
 	return 1;
 }
 
@@ -514,13 +516,18 @@ static int _scan_invalid(void)
 	return 1;
 }
 
+void lvmcache_allow_full_scan(void)
+{
+	if (_has_scanned == SCANNED)
+		_has_scanned = ALLOW_RESCAN;
+}
+
 int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 {
 	struct label *label;
 	struct dev_iter *iter;
 	struct device *dev;
 	struct format_type *fmt;
-
 	int r = 0;
 
 	/* Avoid recursion when a PVID can't be found! */
@@ -539,6 +546,11 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 		goto out;
 	}
 
+	if (!cmd->is_long_lived && _has_scanned == SCANNED && full_scan) {
+		r = _scan_invalid();
+		goto out;
+	}
+
 	if (full_scan == 2 && !refresh_filters(cmd)) {
 		log_error("refresh filters failed");
 		goto out;
@@ -554,7 +566,7 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 
 	dev_iter_destroy(iter);
 
-	_has_scanned = 1;
+	_has_scanned = SCANNED;
 
 	/* Perform any format-specific scanning e.g. text files */
 	dm_list_iterate_items(fmt, &cmd->formats) {
@@ -1341,7 +1353,7 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans)
 	struct dm_hash_node *n;
 	log_verbose("Wiping internal VG cache");
 
-	_has_scanned = 0;
+	_has_scanned = NOT_SCANNED;
 
 	if (_vgid_hash) {
 		dm_hash_destroy(_vgid_hash);
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 2c14b6c..d37bff2 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -68,6 +68,9 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans);
  * 2 to rescan /dev for new devices */
 int lvmcache_label_scan(struct cmd_context *cmd, int full_scan);
 
+int lvmcache_device_scan(struct cmd_context *cmd, struct lvmcache_info *info);
+void lvmcache_allow_full_scan(void);
+
 /* Add/delete a device */
 struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				   struct device *dev,
-- 
1.7.0


