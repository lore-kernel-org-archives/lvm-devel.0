From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:29 -0400
Subject: master - scan: add function to drop bcache blocks
Message-ID: <201804231355.w3NDtTdK001723@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=217f3f8741c1f516ab1f039b8725ac3ce638e302
Commit:        217f3f8741c1f516ab1f039b8725ac3ce638e302
Parent:        da2b155a9da4c4c9caf502b87ad263de6e678b30
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 27 16:35:47 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

scan: add function to drop bcache blocks

which can be a little more efficient that destroy.
---
 lib/label/label.c |   24 ++++++++++++++++--------
 lib/label/label.h |    1 +
 2 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 0514ddf..dd455ec 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -733,20 +733,15 @@ void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv
 }
 
 /*
- * Undo label_scan()
- *
- * Close devices that are open because bcache is holding blocks for them.
- * Destroy the bcache.
+ * Empty the bcache of all blocks and close all open fds,
+ * but keep the bcache set up.
  */
 
-void label_scan_destroy(struct cmd_context *cmd)
+void label_scan_drop(struct cmd_context *cmd)
 {
 	struct dev_iter *iter;
 	struct device *dev;
 
-	if (!scan_bcache)
-		return;
-
 	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
 		return;
 	}
@@ -756,6 +751,19 @@ void label_scan_destroy(struct cmd_context *cmd)
 			_scan_dev_close(dev);
 	}
 	dev_iter_destroy(iter);
+}
+
+/*
+ * Close devices that are open because bcache is holding blocks for them.
+ * Destroy the bcache.
+ */
+
+void label_scan_destroy(struct cmd_context *cmd)
+{
+	if (!scan_bcache)
+		return;
+
+	label_scan_drop(cmd);
 
 	bcache_destroy(scan_bcache);
 	scan_bcache = NULL;
diff --git a/lib/label/label.h b/lib/label/label.h
index 8ef687b..55e92e8 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -107,6 +107,7 @@ int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs);
 int label_scan_devs_excl(struct dm_list *devs);
 void label_scan_invalidate(struct device *dev);
 void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv);
+void label_scan_drop(struct cmd_context *cmd);
 void label_scan_destroy(struct cmd_context *cmd);
 int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector);
 int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_sector);


