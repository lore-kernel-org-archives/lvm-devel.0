From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Mar 2018 04:43:19 -0500
Subject: master - cleanup: use log_warn
Message-ID: <201803080943.w289hJco019668@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6cb2c35d1654558efc1b37ca44d77f83682446c7
Commit:        6cb2c35d1654558efc1b37ca44d77f83682446c7
Parent:        ee37838b1149f3f8d5c34dc2d459421f8e085bbb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 8 10:29:49 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 8 10:40:27 2018 +0100

cleanup: use log_warn

There message are not causing command failure thus turn them
into warnings.
---
 lib/activate/dev_manager.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index dab1603..6b042fb 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -447,13 +447,15 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 		next = dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 		if (!target_type || !strcmp(target_type, TARGET_NAME_SNAPSHOT)) {
 			if (!params || sscanf(params, "%d:%d %d:%d", &major1, &minor1, &major2, &minor2) != 4) {
-				log_error("Incorrect snapshot table found.");
+				log_warn("WARNING: Incorrect snapshot table found for %d:%d.",
+					 (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
 				goto out;
 			}
 			r = r || _device_is_suspended(major1, minor1) || _device_is_suspended(major2, minor2);
 		} else if (!strcmp(target_type, TARGET_NAME_SNAPSHOT_ORIGIN)) {
 			if (!params || sscanf(params, "%d:%d", &major1, &minor1) != 2) {
-				log_error("Incorrect snapshot-origin table found.");
+				log_warn("WARNING: Incorrect snapshot-origin table found for %d:%d.",
+					 (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
 				goto out;
 			}
 			r = r || _device_is_suspended(major1, minor1);
@@ -488,7 +490,7 @@ static int _ignore_unusable_thins(struct device *dev)
 
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 	if (!params || sscanf(params, "%d:%d", &major, &minor) != 2) {
-		log_error("Failed to get thin-pool major:minor for thin device %d:%d.",
+		log_warn("WARNING: Cannot get thin-pool major:minor for thin device %d:%d.",
 			  (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
 		goto out;
 	}


