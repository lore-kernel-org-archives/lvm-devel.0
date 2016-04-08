From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 Apr 2016 18:22:15 +0000 (UTC)
Subject: master - cleanup: reuse _setup_task
Message-ID: <20160408182215.9E81560E1A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74e704bb4465960b361711c890733cbae1f06e42
Commit:        74e704bb4465960b361711c890733cbae1f06e42
Parent:        a09d65891fcf97130dd595eba320b647638d9a07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 8 19:28:35 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 8 20:20:16 2016 +0200

cleanup: reuse _setup_task

Shorten code and use common code from _setup_task.
Reorder naming of major:minor sscanf (as later it's been
also used swapped there was no real bug).
---
 lib/activate/dev_manager.c |   58 ++++++++++++-------------------------------
 1 files changed, 16 insertions(+), 42 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index f2e3826..8c01b43 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -337,13 +337,8 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 	 * We avoid another system call if we can, but if a device is
 	 * dead, we have no choice but to look up the table too.
 	 */
-	if (!(dmt = dm_task_create(DM_DEVICE_TABLE)))
-		goto_out;
-
-	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
-		goto_out;
-
-	if (activation_checks() && !dm_task_enable_checks(dmt))
+	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_TABLE,
+				MAJOR(dev->dev), MINOR(dev->dev), 0)))
 		goto_out;
 
 	if (!dm_task_run(dmt))
@@ -384,13 +379,8 @@ static int _device_is_suspended(int major, int minor)
 	struct dm_info info;
 	int r = 0;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
-		return 0;
-
-	if (!dm_task_set_major_minor(dmt, major, minor, 1))
-		goto_out;
-
-	if (activation_checks() && !dm_task_enable_checks(dmt))
+	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_INFO,
+				major, minor, 0)))
 		goto_out;
 
 	if (!dm_task_run(dmt) ||
@@ -414,13 +404,8 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 	int major1, minor1, major2, minor2;
 	int r = 0;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_TABLE)))
-		return_0;
-
-	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
-		goto_out;
-
-	if (activation_checks() && !dm_task_enable_checks(dmt))
+	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_TABLE,
+				MAJOR(dev->dev), MINOR(dev->dev), 0)))
 		goto_out;
 
 	if (!dm_task_run(dmt)) {
@@ -466,32 +451,29 @@ static int _ignore_unusable_thins(struct device *dev)
 	if (!(mem = dm_pool_create("unusable_thins", 128)))
 		return_0;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_TABLE)))
-		goto_out;
-	if (!dm_task_no_open_count(dmt))
-		goto_out;
-	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
+	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_TABLE,
+				MAJOR(dev->dev), MINOR(dev->dev), 0)))
 		goto_out;
+
 	if (!dm_task_run(dmt)) {
 		log_error("Failed to get state of mapped device.");
 		goto out;
 	}
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
-	if (!params || sscanf(params, "%d:%d", &minor, &major) != 2) {
+	if (!params || sscanf(params, "%d:%d", &major, &minor) != 2) {
 		log_error("Failed to get thin-pool major:minor for thin device %d:%d.",
 			  (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
 		goto out;
 	}
 	dm_task_destroy(dmt);
 
-	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
+	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_STATUS,
+				major, minor, 0)))
 		goto_out;
+
 	if (!dm_task_no_flush(dmt))
 		log_warn("Can't set no_flush.");
-	if (!dm_task_no_open_count(dmt))
-		goto_out;
-	if (!dm_task_set_major_minor(dmt, minor, major, 1))
-		goto_out;
+
 	if (!dm_task_run(dmt)) {
 		log_error("Failed to get state of mapped device.");
 		goto out;
@@ -545,22 +527,14 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 	int only_error_target = 1;
 	int r = 0;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
-		return_0;
-
-	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
-		goto_out;
-
-	if (activation_checks() && !dm_task_enable_checks(dmt))
+	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_STATUS,
+				MAJOR(dev->dev), MINOR(dev->dev), 0)))
 		goto_out;
 
 	/* Non-blocking status read */
 	if (!dm_task_no_flush(dmt))
 		log_warn("WARNING: Can't set no_flush for dm status.");
 
-	if (!dm_task_no_open_count(dmt))
-		goto_out;
-
 	if (!dm_task_run(dmt)) {
 		log_error("Failed to get state of mapped device");
 		goto out;


