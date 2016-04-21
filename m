From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 23:18:36 +0000 (UTC)
Subject: master - coverity: fix error paths
Message-ID: <20160421231836.A09D7616D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99e96f3ce9d14e30b7150d3d4614cf9ab810e264
Commit:        99e96f3ce9d14e30b7150d3d4614cf9ab810e264
Parent:        cbf99be43a70e872b5040ffa0193a8f4961a7068
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 20:19:24 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 01:12:34 2016 +0200

coverity: fix error paths

Patch 74e704bb4465960b361711c890733cbae1f06e42 missed to update
error path. Since now we just need to 'return_0' as 'dmt is NULL
and thus may not be destroyed.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ffc83f5..d088560 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.151 -
 =================================
+  Fix error path after reusing of _setup_task (2.02.150).
   Fix memory access for empty sysfs values (2.02.149).
   Disable lvmetad when lvm1 metadata is seen, so commands revert to scanning.
   Suppress errors when snapshot merge gets delayed because volume is in use.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5b1e226..c07af2d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -381,7 +381,7 @@ static int _device_is_suspended(int major, int minor)
 
 	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_INFO,
 				major, minor, 0)))
-		goto_out;
+		return_0;
 
 	if (!dm_task_run(dmt) ||
 	    !dm_task_get_info(dmt, &info)) {
@@ -406,7 +406,7 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 
 	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_TABLE,
 				MAJOR(dev->dev), MINOR(dev->dev), 0)))
-		goto_out;
+		return_0;
 
 	if (!dm_task_run(dmt)) {
 		log_error("Failed to get state of snapshot or snapshot origin device");
@@ -529,7 +529,7 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 
 	if (!(dmt = _setup_task(NULL, NULL, NULL, DM_DEVICE_STATUS,
 				MAJOR(dev->dev), MINOR(dev->dev), 0)))
-		goto_out;
+		return_0;
 
 	/* Non-blocking status read */
 	if (!dm_task_no_flush(dmt))


