From: David Teigland <teigland@sourceware.org>
Date: Fri,  5 Nov 2021 22:10:59 +0000 (GMT)
Subject: main - vgchange -aay: fall back to dev_cache_scan if optimization fails
Message-ID: <20211105221059.32A213857C70@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14b68ea313865041433e18bac92a6dfcf6128b15
Commit:        14b68ea313865041433e18bac92a6dfcf6128b15
Parent:        b4067e84c7884f2b46effdf31418f66cc0b902bb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 5 17:01:34 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 5 17:07:13 2021 -0500

vgchange -aay: fall back to dev_cache_scan if optimization fails

Part of the optimization to avoid a full dev_cache_scan requires
translating major:minor numbers to a device name.  If this devno
translation fails, then fall back to doing a full dev_cache_scan
which is slower but certain to provide the info.  This preserves
the most important part of the label scanning optimization in the
vgchange aay (avoiding dev_cache_scan is a relatively small part
of the optimized activation compared to label scanning.)
---
 lib/label/label.c | 43 +++++++++++++++++++++++++++++++++++++------
 1 file changed, 37 insertions(+), 6 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 709ae8fc1..2f9b5c371 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1037,6 +1037,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname)
 	struct device_list *devl, *devl2;
 	int relax_deviceid_filter = 0;
 	int metadata_pv_count;
+	int try_dev_scan = 0;
 
 	dm_list_init(&pvs_online);
 	dm_list_init(&devs);
@@ -1059,19 +1060,25 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname)
 			goto bad;
 	}
 
-	/* for each po devno add a struct dev to dev-cache */
-
+	/*
+	 * For each po devno add a struct dev to dev-cache.  This is a faster
+	 * alternative to the usual dev_cache_scan() which looks at all
+	 * devices.  If this optimization fails, then fall back to the usual
+	 * dev_cache_scan().
+	 */
 	dm_list_iterate_items(po, &pvs_online) {
 		if (!setup_devno_in_dev_cache(cmd, po->devno)) {
-			log_error("No device set up for %d:%d PVID %s",
+			log_debug("No device set up for quick mapping of %d:%d PVID %s",
 				  (int)MAJOR(po->devno), (int)MINOR(po->devno), po->pvid);
-			goto bad;
+			try_dev_scan = 1;
+			break;
 		}
 
 		if (!(po->dev = dev_cache_get_by_devt(cmd, po->devno, NULL, NULL))) {
-			log_error("No device found for %d:%d PVID %s",
+			log_debug("No device found for quick mapping of %d:%d PVID %s",
 				  (int)MAJOR(po->devno), (int)MINOR(po->devno), po->pvid);
-			goto bad;
+			try_dev_scan = 1;
+			break;
 		}
 
 		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
@@ -1081,6 +1088,30 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname)
 		dm_list_add(&devs, &devl->list);
 	}
 
+	/*
+	 * Translating a devno (major:minor) into a device name can be
+	 * problematic for some devices that have unusual sysfs layouts, so if
+	 * this happens, do a full dev_cache_scan, which is slower, but is
+	 * sure to find the device.
+	 */
+	if (try_dev_scan) {
+		dev_cache_scan(cmd);
+		dm_list_iterate_items(po, &pvs_online) {
+			if (po->dev)
+				continue;
+			if (!(po->dev = dev_cache_get_by_devt(cmd, po->devno, NULL, NULL))) {
+				log_error("No device found for %d:%d PVID %s",
+					  (int)MAJOR(po->devno), (int)MINOR(po->devno), po->pvid);
+				goto bad;
+			}
+			if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+				goto_bad;
+
+			devl->dev = po->dev;
+			dm_list_add(&devs, &devl->list);
+		}
+	}
+
 	/*
 	 * factor code common to pvscan_cache_args
 	 */


