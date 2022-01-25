From: David Teigland <teigland@sourceware.org>
Date: Tue, 25 Jan 2022 16:52:43 +0000 (GMT)
Subject: main - device_id: fix search for renamed device when the wwid is ignored
Message-ID: <20220125165243.5BDBD3857C70@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e9f02acf04a1dd002709b2239a28ac56dd76aba
Commit:        9e9f02acf04a1dd002709b2239a28ac56dd76aba
Parent:        de7892f0af275615d2db0c7e6a4bbc56cd4962e8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 25 10:47:50 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 25 10:47:50 2022 -0600

device_id: fix search for renamed device when the wwid is ignored

When a device has a wwid (from sysfs), but lvm ignores the wwid,
e.g. because it contains an unreliable "QEMU" value, then lvm
falls back to using IDTYPE=devname (the device name) as the
device id.  If the device name changes after reboot, then lvm
automatically searches for the PV on other devices to find the
new device name and correct system.devices.  When searching for
the PV, lvm skips looking at devices that would use other id types,
e.g. if a device would use a wwid and not a devname, then it
skips checking it.  However, it failed to account for the fact
that a device may have wwid that was ignored, in which case it
should be checked.
---
 lib/device/device_id.c | 39 ++++++++++++++++++++++++++++++---------
 1 file changed, 30 insertions(+), 9 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index ad9694b8a..ecf89918d 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -315,7 +315,6 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 		/* qemu wwid begins "t10.ATA     QEMU HARDDISK ..." */
 		if (strstr(sysbuf, "QEMU HARDDISK"))
 			sysbuf[0] = '\0';
-
 	}
 
 	else if (idtype == DEV_ID_TYPE_SYS_SERIAL)
@@ -366,7 +365,6 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 
 	return idname;
  bad:
-	log_debug("No idtype %s for %s", idtype_to_str(idtype), dev_name(dev));
 	return NULL;
 }
 
@@ -378,20 +376,40 @@ static int _dev_has_stable_id(struct cmd_context *cmd, struct device *dev)
 {
 	char sysbuf[PATH_MAX] = { 0 };
 	struct dev_id *id;
+	const char *idname;
 
+	/*
+	 * An idtype other than DEVNAME is stable, i.e. it doesn't change after
+	 * reboot or device reattach.
+	 * An id on dev->ids with idtype set and !idname means that idtype does
+	 * not exist for the dev.  (Optimization to avoid repeated negative
+	 * system_read.)
+	 */
 	dm_list_iterate_items(id, &dev->ids) {
-		if (id->idtype != DEV_ID_TYPE_DEVNAME)
+		if ((id->idtype != DEV_ID_TYPE_DEVNAME) && id->idname)
 			return 1;
 	}
 
-	if (read_sys_block(cmd, dev, "device/wwid", sysbuf, sizeof(sysbuf)))
+	/*
+	 * Use device_id_system_read() instead of read_sys_block() when
+	 * system_read ignores some values from sysfs.
+	 */
+
+	if ((idname = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID))) {
+		free((void*)idname);
 		return 1;
+	}
 
-	if (read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf)))
+	if ((idname = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_SERIAL))) {
+		free((void*)idname);
 		return 1;
+	}
 
-	if (read_sys_block(cmd, dev, "device/serial", sysbuf, sizeof(sysbuf)))
+	if ((MAJOR(dev->dev) == cmd->dev_types->loop_major) &&
+	    (idname = device_id_system_read(cmd, dev, DEV_ID_TYPE_LOOP_FILE))) {
+		free((void*)idname);
 		return 1;
+	}
 
 	if ((MAJOR(dev->dev) == cmd->dev_types->device_mapper_major)) {
 		if (!read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
@@ -409,9 +427,6 @@ static int _dev_has_stable_id(struct cmd_context *cmd, struct device *dev)
 	    read_sys_block(cmd, dev, "md/uuid", sysbuf, sizeof(sysbuf)))
 		return 1;
 
-	if ((MAJOR(dev->dev) == cmd->dev_types->loop_major) &&
-	    read_sys_block(cmd, dev, "loop/backing_file", sysbuf, sizeof(sysbuf)))
-		return 1;
  out:
 	/* DEV_ID_TYPE_DEVNAME would be used for this dev. */
 	return 0;
@@ -2169,6 +2184,12 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 		 *
 		 * TODO: in auto mode should we look in other non-system
 		 * devices files and skip any devs included in those?
+		 *
+		 * Note that a user can override a stable id type and use
+		 * devname for a device's id, in which case this optimization
+		 * can prevent a search from finding a renamed dev.  So, if a
+		 * user forces a devname id, then they should probably also
+		 * set search_for_devnames=all.
 		 */
 		if (search_auto && _dev_has_stable_id(cmd, dev)) {
 			other_idtype++;


