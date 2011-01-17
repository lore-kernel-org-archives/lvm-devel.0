From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jan 2011 15:16:56 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-cache.c
Message-ID: <20110117151656.19868.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-17 15:16:56

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-cache.c 

Log message:
	Do not scan devices unnecessarily for reseting error counter
	
	For reseting error counter use directly btree cached elements and do not
	create whole dev_iterator.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1880&r2=1.1881
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/WHATS_NEW	2011/01/13 14:56:17	1.1880
+++ LVM2/WHATS_NEW	2011/01/17 15:16:55	1.1881
@@ -1,5 +1,6 @@
 Version 2.02.81 -
 ===================================
+  Do not scan devices unnecessarily in dev_reset_error_count().
   Skip unnecessary lock_vol() call after volume deactivation.
   Extend exec_cmd params to specify, when device sync is needed.
   Replace fs_unlock by sync_local_dev_names to notify local clvmd. (2.02.80)
--- LVM2/lib/device/dev-cache.c	2010/12/20 13:23:11	1.62
+++ LVM2/lib/device/dev-cache.c	2011/01/17 15:16:55	1.63
@@ -850,18 +850,14 @@
 
 void dev_reset_error_count(struct cmd_context *cmd)
 {
-	struct dev_iter *iter;
-	struct device *dev;
+	struct dev_iter iter;
 
-	if (!(iter = dev_iter_create(cmd->filter, 0))) {
-		log_error("Resetting device error count failed");
+	if (!_cache.devices)
 		return;
-	}
 
-	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter))
-		dev->error_count = 0;
-
-	dev_iter_destroy(iter);
+	iter.current = btree_first(_cache.devices);
+	while (iter.current)
+		_iter_next(&iter)->error_count = 0;
 }
 
 int dev_fd(struct device *dev)


