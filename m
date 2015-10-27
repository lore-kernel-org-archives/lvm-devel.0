From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 27 Oct 2015 17:06:59 +0000 (UTC)
Subject: master - pvs: don't treat duplicate PVs as missed
Message-ID: <20151027170659.D778C61013@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5886ff64ebcac8c1b53c665c598728e481590964
Commit:        5886ff64ebcac8c1b53c665c598728e481590964
Parent:        a4418b34c150299aa88c6540bb4e3680f8bb4dae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 27 12:03:57 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 27 12:03:57 2015 -0500

pvs: don't treat duplicate PVs as missed

The recent addition to check for PVs that were
missed during the first iteration of processing
was unintentionally catching duplicate PVs because
duplicates were not removed from the all_devices
list when the primary dev was processed.

Also change a message from warn back to verbose.
---
 tools/toollib.c |   24 +++++++++++++++++++++---
 1 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 3804d66..42ac71a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2885,12 +2885,17 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			}
 
 			/*
+			 * We have processed the PV on device pv->dev.  Now
+			 * deal with any duplicates of this PV on other
+			 * devices.
+			 */
+
+			/*
 			 * This is a very rare and obscure case where multiple
 			 * duplicate devices are specified on the command line
 			 * referring to this PV.  In this case we want to
 			 * process this PV once for each specified device.
 			 */
-
 			if (!skip && !dm_list_empty(arg_devices)) {
 				while ((dil = _device_list_find_pvid(arg_devices, pv))) {
 					_device_list_remove(arg_devices, dil->dev);
@@ -2925,7 +2930,6 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			 * we want each of them to be displayed in the context
 			 * of this VG, so that this VG name appears next to it.
 			 */
-
 			if (process_all_devices && lvmcache_found_duplicate_pvs()) {
 				while ((dil = _device_list_find_pvid(all_devices, pv))) {
 					_device_list_remove(all_devices, dil->dev);
@@ -2942,6 +2946,20 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 					lvmcache_replace_dev(cmd, pv, dev_orig);
 				}
 			}
+
+			/*
+			 * Remove any duplicates of the processed device from
+			 * the list of all devices.  If they were left in the
+			 * list of all devices, they would be considered
+			 * "missed" at the end.
+			 */
+			if (process_all_pvs && lvmcache_found_duplicate_pvs()) {
+				while ((dil = _device_list_find_pvid(all_devices, pv))) {
+					log_very_verbose("Skip duplicate device %s of processed device %s",
+							 dev_name(dil->dev), dev_name(pv->dev));
+					_device_list_remove(all_devices, dil->dev);
+				}
+			}
 		}
 
 		/*
@@ -3160,7 +3178,7 @@ int process_each_pv(struct cmd_context *cmd,
 		dm_list_init(&arg_missed_orig);
 		_device_list_copy(cmd, &arg_missed, &arg_missed_orig);
 
-		log_warn("Some PVs were not found in first search, retrying.");
+		log_verbose("Some PVs were not found in first search, retrying.");
 
 		lvmcache_destroy(cmd, 0, 0);
 		lvmcache_init();


