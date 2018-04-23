From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:50:34 -0400
Subject: master - scan: always setup bcache for commands using lvmetad
Message-ID: <201804231350.w3NDoYxP031920@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=28255e3eeef13a0e73a40d533623b22dd9db89cb
Commit:        28255e3eeef13a0e73a40d533623b22dd9db89cb
Parent:        f328532f05877fc04e7f67c751ef95a844831b9b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 14 16:21:27 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

scan: always setup bcache for commands using lvmetad

Do this at the start of the command so that it doesn't
need to be checked and set up in every function that
could need it.
---
 lib/cache/lvmcache.c |    5 ++++-
 lib/label/label.c    |   29 +++++++++++++++++------------
 lib/label/label.h    |    1 +
 3 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 87bcc37..53254f4 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1241,8 +1241,11 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	int r = 0;
 
-	if (lvmetad_used())
+	if (lvmetad_used()) {
+		if (!label_scan_setup_bcache())
+			return 0;
 		return 1;
+	}
 
 	/* Avoid recursion when a PVID can't be found! */
 	if (_scanning_in_progress)
diff --git a/lib/label/label.c b/lib/label/label.c
index 3359b4d..dc14beb 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -678,18 +678,6 @@ int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs)
 {
 	struct device_list *devl;
 
-	if (!scan_bcache) {
-		/*
-		 * This is only needed when commands are using lvmetad, in
-		 * which case they don't do an initial label_scan, but may
-		 * later need to rescan certain devs from disk and call this
-		 * function.
-		 * FIXME: is there some better number to choose here?
-		 */
-		if (!_setup_bcache(32))
-			return 0;
-	}
-
 	dm_list_iterate_items(devl, devs) {
 		if (_in_bcache(devl->dev)) {
 			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
@@ -841,3 +829,20 @@ void label_scan_confirm(struct device *dev)
 		label_read(dev, NULL, 0);
 }
 
+/*
+ * This is only needed when commands are using lvmetad, in which case they
+ * don't do an initial label_scan, but may later need to rescan certain devs
+ * from disk and call this function.  FIXME: is there some better number to
+ * choose here?
+ */
+
+int label_scan_setup_bcache(void)
+{
+	if (!scan_bcache) {
+		if (!_setup_bcache(32))
+			return 0;
+	}
+
+	return 1;
+}
+
diff --git a/lib/label/label.h b/lib/label/label.h
index e265a6b..107bd30 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -110,5 +110,6 @@ void label_scan_destroy(struct cmd_context *cmd);
 int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector);
 int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_sector);
 void label_scan_confirm(struct device *dev);
+int label_scan_setup_bcache(void);
 
 #endif


