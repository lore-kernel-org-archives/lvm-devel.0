From: David Teigland <teigland@sourceware.org>
Date: Fri,  1 Apr 2022 18:38:40 +0000 (GMT)
Subject: main - pvscan: warn about /dev/sda excluded by devices file
Message-ID: <20220401183840.8A2273858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f840dbb3205754db1a339aba8e0f68fa40138ba1
Commit:        f840dbb3205754db1a339aba8e0f68fa40138ba1
Parent:        8db3b11e4ed94974bc25c26e2f1271c34f6ccf15
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 31 14:47:42 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 1 13:38:21 2022 -0500

pvscan: warn about /dev/sda excluded by devices file

In most installations, /dev/sda* or /dev/vda* should be included
in system.devices because the root, home, etc LVs are usually on
sda or vda.

Add a special case warning when a pvscan autoactivation command
sees that /dev/sda* or /dev/vda* are excluded by system.devices,
either not listed or having a different device id.
---
 tools/pvscan.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index cf1772165..1e47d754a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -19,6 +19,7 @@
 #include "lib/metadata/metadata.h"
 #include "lib/label/hints.h"
 #include "lib/device/online.h"
+#include "lib/filters/filter.h"
 
 #include <dirent.h>
 
@@ -1435,6 +1436,27 @@ static int _pvscan_cache_all(struct cmd_context *cmd, int argc, char **argv,
 	return 1;
 }
 
+/*
+ * If /dev/sda* of /dev/vda* is excluded by the devices file
+ * it's usually a misconfiguration that prevents proper booting,
+ * so make it a special case to give extra info to help debugging.
+ */
+static void _warn_excluded_root(struct cmd_context *cmd, struct device *dev)
+{
+	struct dev_use *du;
+	const char *cur_idname;
+
+	if (!(du = get_du_for_devname(cmd, dev_name(dev)))) {
+		log_warn("WARNING: no autoactivation for %s: not found in system.devices.", dev_name(dev));
+		return;
+	}
+
+	cur_idname = device_id_system_read(cmd, dev, du->idtype);
+
+	log_warn("WARNING: no autoactivation for %s: system.devices %s current %s.",
+		 dev_name(dev), du->idname, cur_idname ?: "missing device id");
+}
+
 static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 			      struct dm_list *complete_vgnames)
 {
@@ -1545,6 +1567,12 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 			log_print_pvscan(cmd, "%s excluded: %s.",
 					 dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
+
+			/* Special case warning when probable root dev is missing from system.devices */
+			if ((devl->dev->filtered_flags & DEV_FILTERED_DEVICES_FILE) &&
+			    (!strncmp(dev_name(devl->dev), "/dev/sda", 8) ||
+			     !strncmp(dev_name(devl->dev), "/dev/vda", 8)))
+				_warn_excluded_root(cmd, devl->dev);
 		}
 	}
 

