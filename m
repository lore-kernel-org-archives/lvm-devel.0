From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 25 May 2009 14:19:36 +0200
Subject: [PATCH 9/9] Udev integration: Add new dir 'udev' with rules and own Makefile
Message-ID: <4A1A8CD8.8030706@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds a new directory called 'udev'. It contains the udev
rules and Makefile to install them. The target installation dir depends
on the configuration. It's /lib/udev/rules.d by default, but could be
prefixed by using the --with-udev-prefix configuration option.

One of the rules, the 10-dm.rules is a template, where we substitute
the value of the directory where the nodes should be created. The value
is taken from dm-ioctl.h where it is defined (DM_DIR).

The "/dev" directory is hardcoded in the rules for now. It's because this
is a little bit problematic -- udevd creates nodes under the directory which
is defined in its own configuration (and I can't define another dir in the
rules).

This model of the rules is also accepted by linux-hotplug guys, so there's
no "last_rule" anymore which they really didn't like :) The rules also contain
parts taken from other packages, so it's maintained by us now (mainly
12-dm-disk.rules which was previously in DeviceKit-disks package).

The rules for permissions are not installed. This part should go into
/etc/udev/rules.d directory. But the file is edited by the users, so we
can't install it by default. Otherwise, the rules would be overwritten
each time an installation is done. So 11-dm-permissions.rules is just
a template/example and can be copied manually then (if desired).

Peter


diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
new file mode 100644
index 0000000..993eca5
--- /dev/null
+++ b/udev/10-dm.rules.in
@@ -0,0 +1,44 @@
+# Udev rules for device-mapper devices.
+#
+# These rules create a DM control node in /dev/mapper directory.
+# The rules also create nodes named dm-x (x is a number) in /dev
+# directory and symlinks to these nodes with names given by
+# the actual DM names. Some udev environment variables are set
+# for use in later rules:
+#   DM_NAME - actual DM device's name
+#   DM_UUID - UUID set for DM device (blank if not specified)
+#   DM_SUSPENDED - suspended state of DM device (0 or 1)
+
+KERNEL=="device-mapper", NAME="(DM_DIR)/control"
+
+SUBSYSTEM!="block", GOTO="dm_end"
+KERNEL!="dm-[0-9]*", GOTO="dm_end"
+ACTION!="add|change", GOTO="dm_end"
+
+# Normally, we operate on "change" events only. But when
+# coldplugging, there's an "add" event present. We have to
+# recognize this and do our actions in this particular
+# situation, too. Also, we don't want the nodes to be
+# created prematurely on "add" events while not coldplugging.
+ACTION=="add", ENV{STARTUP}!="1", NAME="", GOTO="dm_end"
+
+# "dm" sysfs subdirectory is available in newer versions of DM
+# only (kernels >= 2.6.29). We have to check for its existence
+# and use dmsetup tool instead to get the DM name, uuid and 
+# suspended state if the "dm" subdirectory is not present.
+# The "suspended" item was added even later (kernels >= ???),
+# so we also have to call dmsetup if the kernel version used
+# is in between these releases.
+TEST!="dm", ENV{DM_NAME}="$attr{dm/name}", ENV{DM_UUID}="$attr{dm/uuid}", ENV{DM_SUSPENDED}="$attr{dm/suspended}"
+TEST=="dm", IMPORT{program}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid,suspended"
+ENV{DM_SUSPENDED}!="?*", IMPORT{program}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o suspended"
+
+# dmsetup tool provides suspended state information in textual
+# form with values "Suspended"/"Active". We translate it to
+# 0/1 respectively to be consistent with sysfs values.
+ENV{DM_SUSPENDED}=="Active", ENV{DM_SUSPENDED}="0"
+ENV{DM_SUSPENDED}=="Suspended", ENV{DM_SUSPENDED}="1"
+
+ENV{DM_NAME}=="?*", NAME="$kernel", SYMLINK+="(DM_DIR)/$env{DM_NAME}"
+
+LABEL="dm_end"
diff --git a/udev/11-dm-permissions.rules b/udev/11-dm-permissions.rules
new file mode 100644
index 0000000..1e9cdfd
--- /dev/null
+++ b/udev/11-dm-permissions.rules
@@ -0,0 +1,18 @@
+# Udev rules for device-mapper devices.
+#
+# These rules set permissions for DM devices. There are some environment
+# variables set that can be used:
+#   DM_NAME - actual DM device's name
+#   DM_UUID - UUID set for DM device (blank if not specified)
+#   DM_SUSPENDED - suspended state of DM device (0 or 1)
+#   DM_LV_NAME - logical volume name (not set if LVM device not present)
+#   DM_VG_NAME - volume group name (not set if LVM device not present)
+#   DM_LV_LAYER - logical volume layer (not set if LVM device not present)
+
+SUBSYSTEM!="block", GOTO="dm_end"
+KERNEL!="dm-[0-9]*", GOTO="dm_end"
+ACTION!="change", GOTO="dm_end"
+
+#ENV{DM_NAME}=="my_device", OWNER:="peter", GROUP:="peter", MODE:="644"
+
+LABEL="dm_end"
diff --git a/udev/11-lvm.rules b/udev/11-lvm.rules
new file mode 100644
index 0000000..8863124
--- /dev/null
+++ b/udev/11-lvm.rules
@@ -0,0 +1,32 @@
+# Udev rules for LVM.
+#
+# These rules create symlinks for LVM logical volumes in
+# /dev/VG directory (VG is an actual VG name). Some udev
+# environment variables are set (they can be used in later
+# rules as well):
+#   DM_LV_NAME - logical volume name
+#   DM_VG_NAME - volume group name
+#   DM_LV_LAYER - logical volume layer (blank if not set)
+
+SUBSYSTEM!="block", GOTO="lvm_end"
+KERNEL!="dm-[0-9]*", GOTO="lvm_end"
+ACTION!="add|change", GOTO="lvm_end"
+ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"
+
+# Normally, we operate on "change" events only. But when
+# coldplugging, there's an "add" event present. We have
+# to recognize this and do our actions in this particular
+# situation, too.
+ACTION=="add", ENV{STARTUP}!="1", GOTO="lvm_end"
+
+# Use DM name and split it up into its VG/LV/layer constituents.
+IMPORT{program}="/sbin/dmsetup lvmsplit $env{DM_NAME} --nameprefixes --noheadings --rows"
+
+# Do not create symlinks for hidden subdevices.
+ENV{DM_LV_NAME}=="?*_mlog", GOTO="lvm_end"
+ENV{DM_LV_NAME}=="?*_mimage_[0-9]*", GOTO="lvm_end"
+
+# Create symlinks for top-level devices only.
+ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", ENV{DM_LV_LAYER}!="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}"
+
+LABEL="lvm_end"
diff --git a/udev/12-dm-disk.rules b/udev/12-dm-disk.rules
new file mode 100644
index 0000000..4b81420
--- /dev/null
+++ b/udev/12-dm-disk.rules
@@ -0,0 +1,30 @@
+# Udev rules for device-mapper devices.
+#
+# These rules create symlinks in /dev/disk directory.
+# Symlinks that depend on probing filesystem type,
+# label and uuid are created only if the device is not
+# suspended.
+
+SUBSYSTEM!="block", GOTO="dm_end"
+KERNEL!="dm-[0-9]*", GOTO="dm_end"
+ACTION!="add|change", GOTO="dm_end"
+ENV{DM_NAME}!="?*", GOTO="dm_end"
+
+# Normally, we operate on "change" events only. But when
+# coldplugging, there's an "add" event present. We have to
+# recognize this and do our actions in this particular
+# situation, too.
+ACTION=="add", ENV{STARTUP}!="1", GOTO="dm_end"
+
+SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
+ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
+
+ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
+
+IMPORT{program}="vol_id --export $tempnode"
+OPTIONS="link_priority=-100"
+ENV{DM_LV_LAYER}=="?*", OPTIONS="link_priority=-90"
+ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
+ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
+
+LABEL="dm_end"
diff --git a/udev/95-dm-notify.rules b/udev/95-dm-notify.rules
new file mode 100644
index 0000000..344712d
--- /dev/null
+++ b/udev/95-dm-notify.rules
@@ -0,0 +1,16 @@
+# Udev rules for device-mapper devices.
+#
+# These rules are responsible for sending a notification to a process
+# waiting for completion of udev rules. The process is identified by
+# a cookie value sent within "change" and "remove" events (the cookie
+# value is set before by that process for every action requested).
+# Also, it sets default permissions for DM devices if not set already.
+
+SUBSYSTEM!="block", GOTO="dm_end"
+KERNEL!="dm-[0-9]*", GOTO="dm_end"
+ACTION!="change|remove", GOTO="dm_end"
+
+ACTION=="change", OWNER:="root", GROUP:="root", MODE:="600"
+ENV{DM_COOKIE}=="?*", RUN+="/sbin/dmsetup udevnotify $env{DM_COOKIE}"
+
+LABEL="dm_end"
diff --git a/udev/Makefile.in b/udev/Makefile.in
new file mode 100644
index 0000000..19148f9
--- /dev/null
+++ b/udev/Makefile.in
@@ -0,0 +1,45 @@
+#
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = .
+top_srcdir = ..
+
+
+DM_RULES=10-dm.rules 12-dm-disk.rules 95-dm-notify.rules
+LVM_RULES=11-lvm.rules
+DM_DIR=$(shell grep "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | awk '{print $$3}')
+
+CLEAN_TARGETS=10-dm.rules
+
+include $(top_srcdir)/make.tmpl
+
+%: %.in
+	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" $< >$@
+
+install_lvm2: $(LVM_RULES)
+	@echo "Installing $(LVM_RULES) in $(udevdir)"
+	@for f in $(LVM_RULES); \
+	do \
+	   $(RM) $(udevdir)/$$f; \
+	   /usr/bin/install -c -D $(OWNER) $(GROUP) -m 644 $$f $(udevdir)/$$f; \
+	done
+
+install_device-mapper: $(DM_RULES)
+	@echo "Installing $(DM_RULES) in $(udevdir)"
+	@for f in $(DM_RULES); \
+	do \
+	   $(RM) $(udevdir)/$$f; \
+	   /usr/bin/install -c -D $(OWNER) $(GROUP) -m 644 $$f $(udevdir)/$$f; \
+	done
+
+install: install_lvm2 install_device-mapper


