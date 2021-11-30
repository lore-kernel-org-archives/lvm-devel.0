From: David Teigland <teigland@sourceware.org>
Date: Tue, 30 Nov 2021 16:41:58 +0000 (GMT)
Subject: main - pvscan: match device arg to filter symlink
Message-ID: <20211130164158.D177A3858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d12baba1a9bfe2d82537b20bc768758d84b263b6
Commit:        d12baba1a9bfe2d82537b20bc768758d84b263b6
Parent:        009007484b88fb16e2177deaf4774d0e50576a06
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 29 17:13:44 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 29 17:13:44 2021 -0600

pvscan: match device arg to filter symlink

This fixes an issue related to the optimization in
  "pvscan: only add device args to dev cache"

If the devices file is not used, and the lvm.conf filter
accepts devices via symlink names, then those devices won't
be accepted by pvscan for autoactivation.  To resolve this,
recognize when the filter contains symlinks and disable the
optimization.  When the optimization is disabled, a full
dev_cache_scan is performed, and symlinks are associated
with the device names passed to pvscan.  filter-regex
will accept a device if symlinks to that device are accepted.
---
 test/shell/udev-pvscan-vgchange.sh | 53 ++++++++++++++++++++++++++++++++
 tools/pvscan.c                     | 63 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 116 insertions(+)

diff --git a/test/shell/udev-pvscan-vgchange.sh b/test/shell/udev-pvscan-vgchange.sh
index a82bf8876..a209dc048 100644
--- a/test/shell/udev-pvscan-vgchange.sh
+++ b/test/shell/udev-pvscan-vgchange.sh
@@ -381,8 +381,13 @@ BDEVMD=$(basename "$mddev")
 lvcreate -l1 -an -n $lv1 $vg9
 lvcreate -l1 -an -n $lv2 $vg9
 
+mdadm --stop "$mddev"
+systemctl stop lvm-activate-$vg9 || true
 _clear_online_files
+mdadm --assemble "$mddev" "$dev1" "$dev2"
 
+# this trigger might be redundant because the mdadm --assemble
+# probably triggers an add uevent
 udevadm trigger --settle -c add /sys/block/$BDEVMD
 
 wait_lvm_activate $vg9
@@ -410,3 +415,51 @@ systemctl stop lvm-activate-$vg7
 systemctl stop lvm-activate-$vg8
 systemctl stop lvm-activate-$vg9
 
+
+# no devices file, filter with symlink of PV
+# the pvscan needs to look at all dev names to
+# match the symlink in the filter with the
+# dev name (or major minor) passed to pvscan.
+# This test doesn't really belong in this file
+# because it's not testing lvm-activate.
+
+aux lvmconf 'devices/use_devicesfile = 0'
+_clear_online_files
+rm "$DF"
+vgcreate $vg10 "$dev1"
+lvcreate -l1 -an -n $lv1 $vg10 "$dev1"
+
+PVID1=$(pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}')
+# PVID with dashes
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+
+udevadm trigger --settle -c add /sys/block/$BDEV1
+
+# uevent from the trigger should create this symlink
+ls /dev/disk/by-id/lvm-pv-uuid-$OPVID1
+
+vgchange -an $vg10
+systemctl stop lvm-activate-$vg10
+_clear_online_files
+
+aux lvmconf "devices/filter = [ \"a|/dev/disk/by-id/lvm-pv-uuid-$OPVID1|\", \"r|.*|\" ]"
+aux lvmconf 'devices/global_filter = [ "a|.*|" ]'
+
+pvscan --cache -aay "$dev1"
+
+check lv_field $vg10/$lv1 lv_active "active"
+
+vgchange -an $vg10
+_clear_online_files
+
+aux lvmconf 'devices/filter = [ "a|lvm-pv-uuid|", "r|.*|" ]'
+aux lvmconf 'devices/global_filter = [ "a|.*|" ]'
+
+pvscan --cache -aay "$dev1"
+
+check lv_field $vg10/$lv1 lv_active "active"
+
+vgchange -an $vg10
+vgremove -y $vg10
+wipe_all
+
diff --git a/tools/pvscan.c b/tools/pvscan.c
index d360ec87f..0c25fb542 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -816,6 +816,45 @@ out:
 	return ret;
 }
 
+/*
+ * The optimization in which only the pvscan arg devname is added to dev-cache
+ * does not work if there's an lvm.conf filter containing symlinks to the dev
+ * like /dev/disk/by-id/lvm-pv-uuid-xyz entries.  A full dev_cache_scan will
+ * associate the symlinks with the system dev name passed to pvscan, which lets
+ * filter-regex match the devname with the symlink name in the filter.
+ */
+static int _filter_uses_symlinks(struct cmd_context *cmd, int filter_cfg)
+{
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+
+	if ((cn = find_config_tree_array(cmd, filter_cfg, NULL))) {
+        	for (cv = cn->v; cv; cv = cv->next) {
+			if (cv->type != DM_CFG_STRING)
+				continue;
+			if (!cv->v.str)
+				continue;
+
+			if (!strncmp(cv->v.str, "/dev/disk/", 10))
+				return 1;
+			if (!strncmp(cv->v.str, "/dev/mapper/", 12))
+				return 1;
+			if (cv->v.str[0] == '/')
+				continue;
+
+			/* In case /dev/disk/by was omitted */
+			if (strstr(cv->v.str, "lvm-pv-uuid"))
+				return 1;
+			if (strstr(cv->v.str, "dm-uuid"))
+				return 1;
+			if (strstr(cv->v.str, "wwn-"))
+				return 1;
+		}
+	}
+
+	return 0;
+}
+
 struct pvscan_arg {
 	struct dm_list list;
 	const char *devname;
@@ -880,6 +919,30 @@ static int _get_args_devs(struct cmd_context *cmd, struct dm_list *pvscan_args,
 	struct pvscan_arg *arg;
 	struct device_list *devl;
 
+	/*
+	 * If no devices file is used, and lvm.conf filter is set to
+	 * accept /dev/disk/by-id/lvm-pv-uuid-xyz or another symlink,
+	 * but pvscan --cache is passed devname or major:minor, so
+	 * pvscan needs to match its arg device to the filter symlink.
+	 * setup_dev_in_dev_cache() adds /dev/sda2 to dev-cache which
+	 * does not match a symlink to /dev/sda2, so we need a full
+	 * dev_cache_scan that will associate all symlinks to sda2,
+	 * which allows filter-regex to work.  This case could be
+	 * optimized if needed by adding dev-cache entries for each
+	 * filter "a" entry (filter symlink patterns would still need
+	 * a full dev_cache_scan.)
+	 * (When no devices file is used and 69-dm-lvm.rules is
+	 * used which calls pvscan directly, symlinks may not
+	 * have been created by other rules when pvscan runs, so
+	 * the full dev_cache_scan may still not find them.)
+	 */
+	if (!cmd->enable_devices_file && !cmd->enable_devices_list &&
+	    (_filter_uses_symlinks(cmd, devices_filter_CFG) ||
+	     _filter_uses_symlinks(cmd, devices_global_filter_CFG))) {
+		log_print_pvscan(cmd, "finding all devices for filter symlinks.");
+		dev_cache_scan(cmd);
+	}
+
 	/* pass NULL filter when getting devs from dev-cache, filtering is done separately */
 
 	/* in common usage, no dev will be found for a devno */


