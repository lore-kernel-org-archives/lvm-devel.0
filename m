From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Apr 2014 00:40:04 +0000 (UTC)
Subject: master - dev-cache: Improve open device check messages.
Message-ID: <20140404004004.5ACB260CE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f0f5587864e8bb0457089d1cca50b2231b421de
Commit:        3f0f5587864e8bb0457089d1cca50b2231b421de
Parent:        c16c1a9f7071ab91e0f14f42d172adfe0db1e9cf
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 4 01:39:42 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 4 01:39:42 2014 +0100

dev-cache: Improve open device check messages.

---
 lib/device/dev-cache.c |   22 ++++++++++++++--------
 lib/device/dev-cache.h |    5 ++++-
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index b16ace4..f76e527 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -763,26 +763,32 @@ int dev_cache_init(struct cmd_context *cmd)
 	return 0;
 }
 
+/*
+ * Returns number of devices still open.
+ */
 static int _check_for_open_devices(int close_immediate)
 {
 	struct device *dev;
 	struct dm_hash_node *n;
-	int r = 0;
+	int num_open = 0;
 
 	dm_hash_iterate(n, _cache.names) {
 		dev = (struct device *) dm_hash_get_data(_cache.names, n);
 		if (dev->fd >= 0) {
-			log_error("Device '%s' has been left open (%d).",
+			log_error("Device '%s' has been left open (%d remaining references).",
 				  dev_name(dev), dev->open_count);
-			r++;
+			num_open++;
 			if (close_immediate)
 				dev_close_immediate(dev);
 		}
 	}
 
-	return r;
+	return num_open;
 }
 
+/*
+ * Returns number of devices left open.
+ */
 int dev_cache_check_for_open_devices(void)
 {
 	return _check_for_open_devices(0);
@@ -790,11 +796,11 @@ int dev_cache_check_for_open_devices(void)
 
 int dev_cache_exit(void)
 {
-	int cnt = 0;
+	int num_open = 0;
 
 	if (_cache.names)
-		if ((cnt = _check_for_open_devices(1)) > 0)
-			log_error(INTERNAL_ERROR "%d device(s) have been closed.", cnt);
+		if ((num_open = _check_for_open_devices(1)) > 0)
+			log_error(INTERNAL_ERROR "%d device(s) were left open and have been closed.", num_open);
 
 	if (_cache.preferred_names_matcher)
 		_cache.preferred_names_matcher = NULL;
@@ -814,7 +820,7 @@ int dev_cache_exit(void)
 	dm_list_init(&_cache.dirs);
 	dm_list_init(&_cache.files);
 
-	return (cnt == 0);
+	return (!num_open);
 }
 
 int dev_cache_add_dir(const char *path)
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index c18d5f6..fcc69a5 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -36,8 +36,11 @@ struct dev_filter {
  */
 struct cmd_context;
 int dev_cache_init(struct cmd_context *cmd);
-int dev_cache_check_for_open_devices(void);
 int dev_cache_exit(void);
+/*
+ * Returns number of open devices.
+ */
+int dev_cache_check_for_open_devices(void);
 
 /* Trigger(1) or avoid(0) a scan */
 void dev_cache_scan(int do_scan);


