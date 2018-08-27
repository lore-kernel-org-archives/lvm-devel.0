From: David Teigland <teigland@sourceware.org>
Date: Mon, 27 Aug 2018 15:42:01 -0400
Subject: 2018-06-01-stable - lvmetad: fix pvs for many devices
Message-ID: <201808271942.w7RJg1Ki025440@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5502f72e41dceb85d11ec562819ad6c5db6758ae
Commit:        5502f72e41dceb85d11ec562819ad6c5db6758ae
Parent:        c527a0cbfc391645d30407d2dc4a30275c6472f1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 27 11:42:25 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 27 14:39:49 2018 -0500

lvmetad: fix pvs for many devices

When using lvmetad, 'pvs' still evaluates full filters
on all devices (lvmetad only provides info about PVs,
but pvs needs to report info about all devices, at
least sometimes.)

Because some filters read the devices, pvs still reads
every device, even with lvmetad (i.e. lvmetad is no help
for the pvs command.)  Because the device reads are not
being managed by the standard label scan layer, but only
happen incidentally through the filters, there is nothing
to control and limit the bcache content and the open file
descriptors for the devices.  When there are a lot of devs
on the system, the number of open fd's excedes the limit
and all opens begin failing.

The proper solution for this would be for pvs to really
use lvmetad and not scan devs, or for pvs to do a proper
label scan even when lvmetad is enabled.  To avoid any
major changes to the way this has worked, just work around
this problem by dropping bcache and closing the fd after
pvs evaluates the filter on each device.
---
 tools/toollib.c |   60 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 59 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 6ae78bd..3221e5f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3931,7 +3931,7 @@ static int _get_arg_devices(struct cmd_context *cmd,
 	return ret_max;
 }
 
-static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices)
+static int _get_all_devices_lvmetad(struct cmd_context *cmd, struct dm_list *all_devices)
 {
 	struct dev_iter *iter;
 	struct device *dev;
@@ -3947,6 +3947,56 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 		return ECMD_FAILED;
 	}
 
+	/*
+	 * The dev_iter_get applies the filter, which means it reads the device
+	 * (since some filters read devices).  The read is called from the
+	 * filter, and done without label_scan_open, so the dev_read_bytes does
+	 * the open.  Since the open and read are not done from the label scan
+	 * layer, there's nothing to do label_scan_invalidate and close devs
+	 * that are not lvms.  Hack around this by doing label_scan_invalidate
+	 * here.  It's dumb that we are reading all disks here when we're meant
+	 * to be using lvmetad.  process_each_pv with lvmetad should either
+	 * just do a proper label_scan or find a way to not need to read devs
+	 * at all.  If we didn't close each dev here, all devs would remain
+	 * open and lvm will have too many open fds.  It's all because we're
+	 * not using the label scan layer to do the scanning, but pretending a
+	 * label scan isn't needed (because of lvmetad) and then secretly doing
+	 * a scan anyway hidden down in the filters.
+	 */
+
+	while ((dev = dev_iter_get(iter))) {
+		if (!(dil = dm_pool_alloc(cmd->mem, sizeof(*dil)))) {
+			log_error("device_id_list alloc failed.");
+			goto out;
+		}
+
+		strncpy(dil->pvid, dev->pvid, ID_LEN);
+		dil->dev = dev;
+		dm_list_add(all_devices, &dil->list);
+
+		label_scan_invalidate(dev);
+	}
+
+	r = ECMD_PROCESSED;
+out:
+	dev_iter_destroy(iter);
+	return r;
+}
+
+static int _get_all_devices_normal(struct cmd_context *cmd, struct dm_list *all_devices)
+{
+	struct dev_iter *iter;
+	struct device *dev;
+	struct device_id_list *dil;
+	int r = ECMD_FAILED;
+
+	log_debug("Getting list of all devices");
+
+	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
+		log_error("dev_iter creation failed.");
+		return ECMD_FAILED;
+	}
+
 	while ((dev = dev_iter_get(iter))) {
 		if (!(dil = dm_pool_alloc(cmd->mem, sizeof(*dil)))) {
 			log_error("device_id_list alloc failed.");
@@ -3964,6 +4014,14 @@ out:
 	return r;
 }
 
+static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices)
+{
+	if (lvmetad_used())
+		return _get_all_devices_lvmetad(cmd, all_devices);
+	else
+		return _get_all_devices_normal(cmd, all_devices);
+}
+
 static int _device_list_remove(struct dm_list *devices, struct device *dev)
 {
 	struct device_id_list *dil;


