From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 17 Jun 2015 11:47:50 +0000 (UTC)
Subject: master - filter: filter-usable: consider snapshot and origin LV as unusable if its component is suspended
Message-ID: <20150617114750.4A8FA61021@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e6a926e857d8df767415c6ff91d4dd1de74f363
Commit:        1e6a926e857d8df767415c6ff91d4dd1de74f363
Parent:        a9bc53d5f33afd5c4c3ad36450146f753c568a7c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 17 13:37:53 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 17 13:37:53 2015 +0200

filter: filter-usable: consider snapshot and origin LV as unusable if its component is suspended

Note that this is just a quick fix and it needs more robust fix to
encompass any combination, not just the (old) snapshot one!

This started with this report:
  https://bugzilla.redhat.com/show_bug.cgi?id=1219222

If we have devices/ignore_suspended_devices=1 set based on which we
filter out suspended devices as unusable (or if we ignore suspended
devices by force, e.g. during lvconvert called from dmeventd) and
when we have snapshot and snapshot origin devices in the play, we
need to look at their components unerneath (*-real and *-cow) to
check if they're not suspended. If they are, the snapshot/snapshot
origin is not usable as well and hence it needs to be filtered out
by filter-usable.c code which does suspended device filtering.

Not going into much details here, more details are in the bugzilla
mentioned above. However, this is a quick fix since snapshot
and this exact situation is not the only one. So this is
something that needs to be revisited and fixed properly
with full dm tree and checking the whole stack to state
whether the device at the very top is usable or not.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   96 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 90 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e5a8af7..9e2a3dd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.122 - 
 =================================
+  Consider snapshot and origin LV as unusable if its component is suspended.
   Fix lvmconfig segfault on settings with undefined default value (2.02.120).
 
 Version 2.02.121 - 12th June 2015
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9624feb..8a54bec 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -445,6 +445,78 @@ out:
 	return r;
 }
 
+static int _device_is_suspended(int major, int minor)
+{
+	struct dm_task *dmt;
+	struct dm_info info;
+	int r = 0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
+		return 0;
+
+	if (!dm_task_set_major_minor(dmt, major, minor, 1))
+		goto_out;
+
+	if (activation_checks() && !dm_task_enable_checks(dmt))
+		goto_out;
+
+	if (!dm_task_run(dmt) ||
+	    !dm_task_get_info(dmt, &info)) {
+		log_error("Failed to get info for device %d:%d", major, minor);
+		goto out;
+	}
+
+	r = info.exists && info.suspended;
+out:
+	dm_task_destroy(dmt);
+	return r;
+}
+
+static int _ignore_suspended_snapshot_component(struct device *dev)
+{
+	struct dm_task *dmt;
+	void *next = NULL;
+	char *params, *target_type = NULL;
+	uint64_t start, length;
+	int major1, minor1, major2, minor2;
+	int r = 0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_TABLE)))
+		return_0;
+
+	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
+		goto_out;
+
+	if (activation_checks() && !dm_task_enable_checks(dmt))
+		goto_out;
+
+	if (!dm_task_run(dmt)) {
+		log_error("Failed to get state of snapshot or snapshot origin device");
+		goto out;
+	}
+
+	do {
+		next = dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
+		if (!strcmp(target_type, "snapshot")) {
+			if (sscanf(params, "%d:%d %d:%d", &major1, &minor1, &major2, &minor2) != 4) {
+				log_error("Incorrect snapshot table found");
+				goto_out;
+			}
+			r = r | _device_is_suspended(major1, minor1) | _device_is_suspended(major2, minor2);
+		} else if (!strcmp(target_type, "snapshot-origin")) {
+			if (sscanf(params, "%d:%d", &major1, &minor1) != 2) {
+				log_error("Incorrect snapshot-origin table found");
+				goto_out;
+			}
+			r = r | _device_is_suspended(major1, minor1);
+		}
+	} while (next);
+
+out:
+	dm_task_destroy(dmt);
+	return r;
+}
+
 /*
  * device_is_usable
  * @dev
@@ -553,15 +625,25 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 		 * supported anymore and in general using mirrors in a stack
 		 * is disabled by default (with a warning that if enabled,
 		 * it could cause various deadlocks).
-		 * This is former check used, but it's not correct as it
-		 * disables snapshot-origins to be used in a stack in
-		 * general, not just over mirrors!
+		 * Similar situation can happen with RAID devices where
+		 * a RAID device can be snapshotted.
+		 * If one of the RAID legs are down and we're doing
+		 * lvconvert --repair, there's a time period in which
+		 * snapshot components are (besides other devs) suspended.
+		 * See also https://bugzilla.redhat.com/show_bug.cgi?id=1219222
+		 * for an example where this causes problems.
+		 *
+		 * This is a quick check for now, but replace it with more
+		 * robust and better check that would check the stack
+		 * correctly, not just snapshots but any cobimnation possible
+		 * in a stack - use proper dm tree to check this instead.
 		 */
-		/*if (check.check_suspended && target_type && !strcmp(target_type, "snapshot-origin")) {
-			log_debug_activation("%s: Snapshot-origin device %s not usable.",
-					     dev_name(dev), name);
+		if (check.check_suspended &&
+		    (!strcmp(target_type, "snapshot") || !strcmp(target_type, "snapshot-origin")) &&
+		    _ignore_suspended_snapshot_component(dev)) {
+			log_debug_activation("%s: %s device %s not usable.", dev_name(dev), target_type, name);
 			goto out;
-		}*/
+		}
 
 		if (target_type && strcmp(target_type, "error"))
 			only_error_target = 0;


