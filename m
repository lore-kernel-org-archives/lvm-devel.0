From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 11 Oct 2018 05:07:46 -0400
Subject: master - build: make genrate config file
Message-ID: <201810110907.w9B97kDB028434@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=954b885a08a733308e1117f166d41f4443cd13c3
Commit:        954b885a08a733308e1117f166d41f4443cd13c3
Parent:        48768cc5be64504863c80d61f3d8f6ec4fbfe589
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Oct 11 10:44:09 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Oct 11 11:06:23 2018 +0200

build: make genrate config file

---
 conf/example.conf.in |   48 ++++++++++++------------------------------------
 1 files changed, 12 insertions(+), 36 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 36204d3..2690006 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -123,7 +123,6 @@ devices {
 	# then the device is accepted. Be careful mixing 'a' and 'r' patterns,
 	# as the combination might produce unexpected results (test changes.)
 	# Run vgscan after changing the filter to regenerate the cache.
-	# See the use_lvmetad comment for a special case regarding filters.
 	# 
 	# Example
 	# Accept every block device:
@@ -143,7 +142,7 @@ devices {
 	# Configuration option devices/global_filter.
 	# Limit the block devices that are used by LVM system components.
 	# Because devices/filter may be overridden from the command line, it is
-	# not suitable for system-wide device filtering, e.g. udev and lvmetad.
+	# not suitable for system-wide device filtering, e.g. udev.
 	# Use global_filter to hide devices from these LVM system components.
 	# The syntax is the same as devices/filter. Devices rejected by
 	# global_filter are not opened by LVM.
@@ -179,6 +178,10 @@ devices {
 	# present on the system. sysfs must be part of the kernel and mounted.)
 	sysfs_scan = 1
 
+	# Configuration option devices/scan_lvs.
+	# Scan LVM LVs for layered PVs.
+	scan_lvs = 1
+
 	# Configuration option devices/multipath_component_detection.
 	# Ignore devices that are components of DM multipath devices.
 	multipath_component_detection = 1
@@ -336,7 +339,7 @@ allocation {
 	maximise_cling = 1
 
 	# Configuration option allocation/use_blkid_wiping.
-	# Use blkid to detect existing signatures on new PVs and LVs.
+	# Use blkid to detect and erase existing signatures on new PVs and LVs.
 	# The blkid library can detect more signatures than the native LVM
 	# detection code, but may take longer. LVM needs to be compiled with
 	# blkid wiping support for this setting to apply. LVM native detection
@@ -744,9 +747,9 @@ log {
 	# Select log messages by class.
 	# Some debugging messages are assigned to a class and only appear in
 	# debug output if the class is listed here. Classes currently
-	# available: memory, devices, io, activation, allocation, lvmetad,
+	# available: memory, devices, io, activation, allocation,
 	# metadata, cache, locking, lvmpolld. Use "all" to see everything.
-	debug_classes = [ "memory", "devices", "io", "activation", "allocation", "lvmetad", "metadata", "cache", "locking", "lvmpolld", "dbus" ]
+	debug_classes = [ "memory", "devices", "io", "activation", "allocation", "metadata", "cache", "locking", "lvmpolld", "dbus" ]
 }
 
 # Configuration section backup.
@@ -990,40 +993,13 @@ global {
 	# lvdisplay_shows_full_device_path = 0
 
 	# Configuration option global/use_lvmetad.
-	# Use lvmetad to cache metadata and reduce disk scanning.
-	# When enabled (and running), lvmetad provides LVM commands with VG
-	# metadata and PV state. LVM commands then avoid reading this
-	# information from disks which can be slow. When disabled (or not
-	# running), LVM commands fall back to scanning disks to obtain VG
-	# metadata. lvmetad is kept updated via udev rules which must be set
-	# up for LVM to work correctly. (The udev rules should be installed
-	# by default.) Without a proper udev setup, changes in the system's
-	# block device configuration will be unknown to LVM, and ignored
-	# until a manual 'pvscan --cache' is run. If lvmetad was running
-	# while use_lvmetad was disabled, it must be stopped, use_lvmetad
-	# enabled, and then started. When using lvmetad, LV activation is
-	# switched to an automatic, event-based mode. In this mode, LVs are
-	# activated based on incoming udev events that inform lvmetad when
-	# PVs appear on the system. When a VG is complete (all PVs present),
-	# it is auto-activated. The auto_activation_volume_list setting
-	# controls which LVs are auto-activated (all by default.)
-	# When lvmetad is updated (automatically by udev events, or directly
-	# by pvscan --cache), devices/filter is ignored and all devices are
-	# scanned by default. lvmetad always keeps unfiltered information
-	# which is provided to LVM commands. Each LVM command then filters
-	# based on devices/filter. This does not apply to other, non-regexp,
-	# filtering settings: component filters such as multipath and MD
-	# are checked during pvscan --cache. To filter a device and prevent
-	# scanning from the LVM system entirely, including lvmetad, use
-	# devices/global_filter.
-	use_lvmetad = @DEFAULT_USE_LVMETAD@
+	# This setting is no longer used.
+	use_lvmetad = 0
 
 	# Configuration option global/lvmetad_update_wait_time.
-	# Number of seconds a command will wait for lvmetad update to finish.
-	# After waiting for this period, a command will not use lvmetad, and
-	# will revert to disk scanning.
+	# This setting is no longer used.
 	# This configuration option has an automatic default value.
-	# lvmetad_update_wait_time = 10
+	# lvmetad_update_wait_time = 0
 
 	# Configuration option global/use_lvmlockd.
 	# Use lvmlockd for locking among hosts using LVM on shared storage.


