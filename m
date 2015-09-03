From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:09 +0000 (UTC)
Subject: master - thin: detect unusable thins
Message-ID: <20150903213609.4D53A60F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a01eb9c451b136ccb12f3baf6b487604a4f209dc
Commit:        a01eb9c451b136ccb12f3baf6b487604a4f209dc
Parent:        81a9da8f6190b567bb26f28ff02be0e6b10cad9a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 2 16:13:31 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:36 2015 +0200

thin: detect unusable thins

Try to detect thin-pool which my block lvm2 command from furher
processing (i.e. lvextend).

Check if pool is read-only or out-of-space and in this case thins
will skipped from being scanned (so user may miss some PVs located
on thin volumes).
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   74 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a7c7267..cb9e1f1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.130 - 
 ===================================
+  Detect blocked thin-pool and avoid scanning their thin volumes.
   Check if dm device is usable before checking its size (2.02.116).
   Extend parsing of cache_check version in configure.
   Make lvpoll error messages visible in lvmpolld's stderr and in syslog.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 101cd36..6a26d37 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -518,6 +518,73 @@ out:
 	return r;
 }
 
+static int _ignore_unusable_thins(struct device *dev)
+{
+	/* TODO make function for thin testing */
+	struct dm_pool *mem;
+	struct dm_status_thin_pool *status;
+	struct dm_task *dmt = NULL;
+	void *next = NULL;
+	uint64_t start, length;
+	char *target_type = NULL;
+	char *params;
+	int minor, major;
+	int r = 0;
+
+	if (!(mem = dm_pool_create("unusable_thins", 128)))
+		return_0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_TABLE)))
+		goto_out;
+	if (!dm_task_no_open_count(dmt))
+		goto_out;
+	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
+		goto_out;
+	if (!dm_task_run(dmt)) {
+		log_error("Failed to get state of mapped device.");
+		goto out;
+	}
+	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
+	if (sscanf(params, "%d:%d", &minor, &major) != 2) {
+		log_error("Failed to get thin-pool major:minor for thin device %d:%d.",
+			  (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
+		goto out;
+	}
+	dm_task_destroy(dmt);
+
+	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
+		goto_out;
+	if (!dm_task_no_flush(dmt))
+		log_warn("Can't set no_flush.");
+	if (!dm_task_no_open_count(dmt))
+		goto_out;
+	if (!dm_task_set_major_minor(dmt, minor, major, 1))
+		goto_out;
+	if (!dm_task_run(dmt)) {
+		log_error("Failed to get state of mapped device.");
+		goto out;
+	}
+
+	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
+	if (!dm_get_status_thin_pool(mem, params, &status))
+		return_0;
+
+	if (status->read_only || status->out_of_data_space) {
+		log_warn("WARNING: %s: Thin's thin-pool needs inspection.",
+			 dev_name(dev));
+		goto out;
+	}
+
+	r = 1;
+out:
+	if (dmt)
+		dm_task_destroy(dmt);
+
+	dm_pool_destroy(mem);
+
+        return r;
+}
+
 /*
  * device_is_usable
  * @dev
@@ -646,6 +713,13 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 			goto out;
 		}
 
+		/* TODO: extend check struct ? */
+		if (target_type && !strcmp(target_type, "thin") &&
+		    !_ignore_unusable_thins(dev)) {
+			log_debug_activation("%s: %s device %s not usable.", dev_name(dev), target_type, name);
+			goto out;
+		}
+
 		if (target_type && strcmp(target_type, "error"))
 			only_error_target = 0;
 	} while (next);


