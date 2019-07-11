From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Jul 2019 12:42:54 -0400
Subject: master - enable full md component detection at the right time
Message-ID: <201907111642.x6BGgs0C028710@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4567c6a2b2f4f2662ef909887640681c8bba0e02
Commit:        4567c6a2b2f4f2662ef909887640681c8bba0e02
Parent:        b16abb3816408a296343a75658d4be0ef688390b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 9 14:48:31 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 10 13:30:50 2019 -0500

enable full md component detection at the right time

An active md device with an end superblock causes lvm to
enable full md component detection.  This was being done
within the filter loop instead of before, so the full
filtering of some devs could be missed.

Also incorporate the recently added config setting that
controls the md component detection.
---
 lib/device/dev-cache.c |   19 +++++++++++++++++++
 lib/device/dev-cache.h |    3 +++
 lib/device/dev-md.c    |    6 +++---
 lib/label/label.c      |   27 ++++++++++++++-------------
 tools/pvscan.c         |    7 +++++++
 5 files changed, 46 insertions(+), 16 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 1492181..980dd3c 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -15,6 +15,7 @@
 
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
+#include "lib/device/dev-type.h"
 #include "lib/datastruct/btree.h"
 #include "lib/config/config.h"
 #include "lib/commands/toolcontext.h"
@@ -1634,3 +1635,21 @@ const char *dev_name(const struct device *dev)
 	return (dev && dev->aliases.n) ? dm_list_item(dev->aliases.n, struct dm_str_list)->str :
 	    unknown_device_name();
 }
+
+bool dev_cache_has_md_with_end_superblock(struct dev_types *dt)
+{
+	struct btree_iter *iter = btree_first(_cache.devices);
+	struct device *dev;
+
+	while (iter) {
+		dev = btree_get_data(iter);
+
+		if (dev_is_md_with_end_superblock(dt, dev))
+			return true;
+
+		iter = btree_next(iter);
+	}
+
+	return false;
+}
+
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 8a1c277..46c86c2 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -17,6 +17,7 @@
 #define _LVM_DEV_CACHE_H
 
 #include "lib/device/device.h"
+#include "lib/device/dev-type.h"
 #include "lib/misc/lvm-wrappers.h"
 
 struct cmd_context;
@@ -71,4 +72,6 @@ void dev_reset_error_count(struct cmd_context *cmd);
 
 void dev_cache_failed_path(struct device *dev, const char *path);
 
+bool dev_cache_has_md_with_end_superblock(struct dev_types *dt);
+
 #endif
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 08143b7..9d0a363 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -302,12 +302,12 @@ static int _md_sysfs_attribute_scanf(struct dev_types *dt,
 		return ret;
 
 	if (!(fp = fopen(path, "r"))) {
-		log_sys_error("fopen", path);
+		log_debug("_md_sysfs_attribute_scanf fopen failed %s", path);
 		return ret;
 	}
 
 	if (!fgets(buffer, sizeof(buffer), fp)) {
-		log_sys_error("fgets", path);
+		log_debug("_md_sysfs_attribute_scanf fgets failed %s", path);
 		goto out;
 	}
 
@@ -449,7 +449,7 @@ int dev_is_md_with_end_superblock(struct dev_types *dt, struct device *dev)
 
 	if (_md_sysfs_attribute_scanf(dt, dev, attribute,
 				      "%s", &version_string) != 1)
-		return -1;
+		return 0;
 
 	log_very_verbose("Device %s %s is %s.",
 			 dev_name(dev), attribute, version_string);
diff --git a/lib/label/label.c b/lib/label/label.c
index 8b841f6..fb7ad1d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -894,6 +894,20 @@ int label_scan(struct cmd_context *cmd)
 	dev_cache_scan();
 
 	/*
+	 * If we know that there will be md components with an end
+	 * superblock, then enable the full md filter before label
+	 * scan begins.  FIXME: we could skip the full md check on
+	 * devs that are not identified as PVs, but then we'd need
+	 * to do something other than using the standard md filter.
+	 */
+	if (cmd->md_component_detection && !cmd->use_full_md_check &&
+	    !strcmp(cmd->md_component_checks, "auto") &&
+	    dev_cache_has_md_with_end_superblock(cmd->dev_types)) {
+		log_debug("Enable full md component check.");
+		cmd->use_full_md_check = 1;
+	}
+
+	/*
 	 * Set up the iterator that is needed to step through each device in
 	 * dev cache.
 	 */
@@ -931,19 +945,6 @@ int label_scan(struct cmd_context *cmd)
 			bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
 			_scan_dev_close(dev);
 		}
-
-		/*
-		 * When md devices exist that use the old superblock at the
-		 * end of the device, then in order to detect and filter out
-		 * the component devices of those md devs, we enable the full
-		 * md filter which scans both the start and the end of every
-		 * device.  This doubles the amount of scanning i/o, which we
-		 * want to avoid.  FIXME: this forces start+end scanning of
-		 * every device, but it would be more efficient to limit the
-		 * end scan only to PVs.
-		 */
-		if (dev_is_md_with_end_superblock(cmd->dev_types, dev))
-			cmd->use_full_md_check = 1;
 	};
 	dev_iter_destroy(iter);
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index facc70c..2a88eaa 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -938,6 +938,13 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	/* Creates a list of dev names from /dev, sysfs, etc; does not read any. */
 	dev_cache_scan();
 
+	if (cmd->md_component_detection && !cmd->use_full_md_check &&
+	    !strcmp(cmd->md_component_checks, "auto") &&
+	    dev_cache_has_md_with_end_superblock(cmd->dev_types)) {
+		log_debug("Enable full md component check.");
+		cmd->use_full_md_check = 1;
+	}
+
 	/*
 	 * For each device command arg (from either position or --major/--minor),
 	 * decide if that device is being added to the system (a dev node exists


