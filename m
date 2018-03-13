From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:03:51 -0400
Subject: master - raid: skip frozen raid devices
Message-ID: <201803131203.w2DC3pq6002288@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0edd89fadc3725080136e3d5a638d7df4abe9b95
Commit:        0edd89fadc3725080136e3d5a638d7df4abe9b95
Parent:        a8a579b154432ea3438a8844a724c5a9f3d2548a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 8 13:18:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:57:01 2018 +0100

raid: skip frozen raid devices

Some kernel version suffer from bad state transition where a device
steps into 'frozen' mode. Any application that tries to read such
raid gets unfortunatelly bloked.

As some sort of protection try to skip such raid device from being
scanned to minimize chances to block lvm2 command on such scan.

When such device is found, warning gets printed.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   33 +++++++++++++++++++++++++++++++--
 2 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 177a2fe..a27b307 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Skip frozen raid devices from scanning.
   Activate RAID SubLVs on read_only_volume_list readwrite
   Offer convenience type raid5_n converting to raid10
   Automatically avoid reading invalid snapshots during device scan.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e0d1fa1..499bf9a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -531,15 +531,38 @@ static int _ignore_invalid_snapshot(const char *params)
 {
 	struct dm_status_snapshot *s;
 	struct dm_pool *mem;
-	int r;
+	int r = 0;
 
 	if (!(mem = dm_pool_create("invalid snapshots", 128)))
 		return_0;
 
 	if (!dm_get_status_snapshot(mem, params, &s))
+		stack;
+        else
+		r = s->invalid;
+
+	dm_pool_destroy(mem);
+
+	return r;
+}
+
+static int _ignore_frozen_raid(struct device *dev, const char *params)
+{
+	struct dm_status_raid *s;
+	struct dm_pool *mem;
+	int r = 0;
+
+	if (!(mem = dm_pool_create("frozen raid", 128)))
 		return_0;
 
-	r = s->invalid;
+	if (!dm_get_status_raid(mem, params, &s))
+		stack;
+	else if (s->sync_action && !strcmp(s->sync_action, "frozen")) {
+		log_warn("WARNING: %s frozen raid device (%d:%d) needs inspection.",
+			  dev_name(dev), (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
+		r = 1;
+	}
+
 	dm_pool_destroy(mem);
 
 	return r;
@@ -669,6 +692,12 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 			goto out;
 		}
 
+		if (!strncmp(target_type, TARGET_NAME_RAID, 4) && _ignore_frozen_raid(dev, params)) {
+			log_debug_activation("%s: Frozen %s device %s not usable.",
+					     dev_name(dev), target_type, name);
+			goto out;
+		}
+
 		/* TODO: extend check struct ? */
 		if (!strcmp(target_type, TARGET_NAME_THIN) &&
 		    !_ignore_unusable_thins(dev)) {


