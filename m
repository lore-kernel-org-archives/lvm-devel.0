From: David Teigland <teigland@sourceware.org>
Date: Fri,  1 Apr 2022 18:38:38 +0000 (GMT)
Subject: main - lvmdevices update: correct multipath entries
Message-ID: <20220401183838.49A3E3858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=23a9bd549a27cba63c525e7b3042a67e428c798f
Commit:        23a9bd549a27cba63c525e7b3042a67e428c798f
Parent:        6e22be20c66b85ee161d170571c65b0f383010e4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 30 16:28:35 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 1 13:38:21 2022 -0500

lvmdevices update: correct multipath entries

Remove multipath components.
Add multipath devs that have multipath components listed.
---
 lib/filters/filter-mpath.c |  6 ++++++
 tools/lvmdevices.c         | 43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index fc7cc51fa..854c26a7c 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -21,6 +21,8 @@
 
 #include <dirent.h>
 
+static int _lvmdevices_update_msg;
+
 static int _ignore_mpath_component(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
 	dev_t mpath_devno = 0;
@@ -41,6 +43,10 @@ static int _ignore_mpath_component(struct cmd_context *cmd, struct dev_filter *f
 				log_warn("WARNING: devices file is missing %s (%d:%d) using multipath component %s.",
 					 mpath_dev ? dev_name(mpath_dev) : "unknown",
 					 (int)MAJOR(mpath_devno), (int)MINOR(mpath_devno), dev_name(dev));
+				if (!_lvmdevices_update_msg && strcmp(get_cmd_name(), "lvmdevices")) {
+					log_warn("See lvmdevices --update for devices file update.");
+					_lvmdevices_update_msg = 1;
+				}
 			}
 		}
 
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 662b35f9a..d30f86b75 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -16,6 +16,7 @@
 #include "lib/cache/lvmcache.h"
 #include "lib/device/device_id.h"
 #include "lib/device/dev-type.h"
+#include "lib/filters/filter.h"
 
 /* coverity[unnecessary_header] needed for MuslC */
 #include <sys/file.h>
@@ -182,6 +183,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 	device_ids_match(cmd);
 
 	if (arg_is_set(cmd, check_ARG) || arg_is_set(cmd, update_ARG)) {
+		int update_set = arg_is_set(cmd, update_ARG);
 		int search_count = 0;
 		int update_needed = 0;
 		int invalid = 0;
@@ -230,6 +232,47 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		if (invalid)
 			update_needed = 1;
 
+		/*
+		 * Remove multipath components.
+		 * Add multipath devs that had components listed.
+		 */
+		dm_list_iterate_items_safe(du, du2, &cmd->use_devices) {
+			dev_t mpath_devno;
+			struct device *mpath_dev;
+
+			if (!du->dev)
+				continue;
+			dev = du->dev;
+
+			if (!(dev->filtered_flags & DEV_FILTERED_MPATH_COMPONENT))
+				continue;
+
+			/* redundant given the flag check, but used to get devno */
+			if (!dev_is_mpath_component(cmd, dev, &mpath_devno))
+				continue;
+
+			update_needed = 1;
+			if (update_set) {
+				log_print("Removing multipath component %s.", dev_name(du->dev));
+				dm_list_del(&du->list);
+			}
+
+			if (!(mpath_dev = dev_cache_get_by_devt(cmd, mpath_devno)))
+				continue;
+
+			if (!get_du_for_dev(cmd, mpath_dev)) {
+				if (update_set) {
+					log_print("Adding multipath device %s for multipath component %s.",
+						  dev_name(mpath_dev), dev_name(du->dev));
+					if (!device_id_add(cmd, mpath_dev, dev->pvid, NULL, NULL))
+						stack;
+				} else {
+					log_print("Missing multipath device %s for multipath component %s.",
+						  dev_name(mpath_dev), dev_name(du->dev));
+				}
+			}
+		}
+
 		/*
 		 * Find and fix any devname entries that have moved to a
 		 * renamed device.

