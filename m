From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Aug 2009 18:44:56 -0000
Subject: LVM2 libdm/misc/dm-ioctl.h udev/Makefile.in ud ...
Message-ID: <20090803184456.27876.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-03 18:44:55

Modified files:
	libdm/misc     : dm-ioctl.h 
	udev           : Makefile.in 
Added files:
	udev           : 10-dm.rules.in 11-dm-permissions.rules 
	                 11-lvm.rules 12-dm-disk.rules 
	                 95-dm-notify.rules 

Log message:
	Add default udev rules.
	Update dm-ioctl.h comments.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-ioctl.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-dm-permissions.rules.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-lvm.rules.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-disk.rules.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/95-dm-notify.rules.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/libdm/misc/dm-ioctl.h	2008/10/30 15:31:33	1.1
+++ LVM2/libdm/misc/dm-ioctl.h	2009/08/03 18:44:54	1.2
@@ -125,6 +125,16 @@
 	uint32_t target_count;	/* in/out */
 	int32_t open_count;	/* out */
 	uint32_t flags;		/* in/out */
+
+	/*
+	 * event_nr holds either the event number (input and output) or the
+	 * udev cookie value (input only).
+	 * The DM_DEV_WAIT ioctl takes an event number as input.
+	 * The DM_SUSPEND, DM_DEV_REMOVE and DM_DEV_RENAME ioctls
+	 * use the field as a cookie to return in the DM_COOKIE
+	 * variable with the uevents they issue.
+	 * For output, the ioctls return the event number, not the cookie.
+	 */
 	uint32_t event_nr;      	/* in/out */
 	uint32_t padding;
 
@@ -258,9 +268,9 @@
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	14
+#define DM_VERSION_MINOR	15
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2008-04-23)"
+#define DM_VERSION_EXTRA	"-ioctl (2009-04-01)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
/cvs/lvm2/LVM2/udev/10-dm.rules.in,v  -->  standard output
revision 1.1
--- LVM2/udev/10-dm.rules.in
+++ -	2009-08-03 18:44:55.584662000 +0000
@@ -0,0 +1,44 @@
+# Udev rules for device-mapper devices.
+#
+# These rules create a DM control node in /dev/(DM_DIR) directory.
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
+TEST=="dm", ENV{DM_NAME}="$attr{dm/name}", ENV{DM_UUID}="$attr{dm/uuid}", ENV{DM_SUSPENDED}="$attr{dm/suspended}"
+TEST!="dm", IMPORT{program}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid,suspended"
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
/cvs/lvm2/LVM2/udev/11-dm-permissions.rules,v  -->  standard output
revision 1.1
--- LVM2/udev/11-dm-permissions.rules
+++ -	2009-08-03 18:44:55.696036000 +0000
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
/cvs/lvm2/LVM2/udev/11-lvm.rules,v  -->  standard output
revision 1.1
--- LVM2/udev/11-lvm.rules
+++ -	2009-08-03 18:44:55.810941000 +0000
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
+IMPORT{program}="/sbin/dmsetup namesplit --nameprefixes --noheadings --rows $env{DM_NAME}"
+
+# Do not create symlinks for hidden subdevices.
+ENV{DM_LV_NAME}=="?*_mlog", GOTO="lvm_end"
+ENV{DM_LV_NAME}=="?*_mimage_[0-9]*", GOTO="lvm_end"
+
+# Create symlinks for top-level devices only.
+ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", ENV{DM_LV_LAYER}!="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}"
+
+LABEL="lvm_end"
/cvs/lvm2/LVM2/udev/12-dm-disk.rules,v  -->  standard output
revision 1.1
--- LVM2/udev/12-dm-disk.rules
+++ -	2009-08-03 18:44:55.952611000 +0000
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
/cvs/lvm2/LVM2/udev/95-dm-notify.rules,v  -->  standard output
revision 1.1
--- LVM2/udev/95-dm-notify.rules
+++ -	2009-08-03 18:44:56.223676000 +0000
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
+ENV{DM_COOKIE}=="?*", RUN+="/sbin/dmsetup udevcomplete $env{DM_COOKIE}"
+
+LABEL="dm_end"
--- LVM2/udev/Makefile.in	2009/07/31 18:41:19	1.1
+++ LVM2/udev/Makefile.in	2009/08/03 18:44:54	1.2
@@ -14,3 +14,32 @@
 srcdir = .
 top_srcdir = ..
 
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
+	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $$f $(udevdir)/$$f; \
+	done
+
+install_device-mapper: $(DM_RULES)
+	@echo "Installing $(DM_RULES) in $(udevdir)"
+	@for f in $(DM_RULES); \
+	do \
+	   $(RM) $(udevdir)/$$f; \
+	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $$f $(udevdir)/$$f; \
+	done
+
+install: install_lvm2 install_device-mapper


