From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:03:13 -0400
Subject: master - cleanup: all tests needs target_type
Message-ID: <201803131203.w2DC3DKq002127@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8a579b154432ea3438a8844a724c5a9f3d2548a
Commit:        a8a579b154432ea3438a8844a724c5a9f3d2548a
Parent:        0646fd465eef51f3cfbd2219a0992af27d61ae14
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 8 13:01:12 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:53:59 2018 +0100

cleanup: all tests needs target_type

Simplify code.
---
 lib/activate/dev_manager.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index f4d602f..e0d1fa1 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -448,7 +448,11 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
-		if (!target_type || !strcmp(target_type, TARGET_NAME_SNAPSHOT)) {
+
+		if (!target_type)
+			continue;
+
+		if (!strcmp(target_type, TARGET_NAME_SNAPSHOT)) {
 			if (!params || sscanf(params, "%d:%d %d:%d", &major1, &minor1, &major2, &minor2) != 4) {
 				log_warn("WARNING: Incorrect snapshot table found for %d:%d.",
 					 (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
@@ -615,7 +619,10 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
 
-		if (check.check_blocked && target_type && !strcmp(target_type, TARGET_NAME_MIRROR)) {
+		if (!target_type)
+			continue;
+
+		if (check.check_blocked && !strcmp(target_type, TARGET_NAME_MIRROR)) {
 			if (ignore_lvm_mirrors()) {
 				log_debug_activation("%s: Scanning mirror devices is disabled.", dev_name(dev));
 				goto out;
@@ -649,27 +656,27 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 		 * correctly, not just snapshots but any cobimnation possible
 		 * in a stack - use proper dm tree to check this instead.
 		 */
-		if (check.check_suspended && target_type &&
+		if (check.check_suspended &&
 		    (!strcmp(target_type, TARGET_NAME_SNAPSHOT) || !strcmp(target_type, TARGET_NAME_SNAPSHOT_ORIGIN)) &&
 		    _ignore_suspended_snapshot_component(dev)) {
 			log_debug_activation("%s: %s device %s not usable.", dev_name(dev), target_type, name);
 			goto out;
 		}
 
-		if (target_type && !strcmp(target_type, TARGET_NAME_SNAPSHOT) &&
+		if (!strcmp(target_type, TARGET_NAME_SNAPSHOT) &&
 		    _ignore_invalid_snapshot(params)) {
 			log_debug_activation("%s: Invalid %s device %s not usable.", dev_name(dev), target_type, name);
 			goto out;
 		}
 
 		/* TODO: extend check struct ? */
-		if (target_type && !strcmp(target_type, TARGET_NAME_THIN) &&
+		if (!strcmp(target_type, TARGET_NAME_THIN) &&
 		    !_ignore_unusable_thins(dev)) {
 			log_debug_activation("%s: %s device %s not usable.", dev_name(dev), target_type, name);
 			goto out;
 		}
 
-		if (target_type && strcmp(target_type, TARGET_NAME_ERROR))
+		if (strcmp(target_type, TARGET_NAME_ERROR))
 			only_error_target = 0;
 	} while (next);
 


