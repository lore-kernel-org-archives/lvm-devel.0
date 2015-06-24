From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 09:27:52 +0000 (UTC)
Subject: master - config: regenerate configure.in to accomodate all recent changes
Message-ID: <20150624092752.2519860DF6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=982cf44ff0740c95c4125af1607cf2ed8a2aab69
Commit:        982cf44ff0740c95c4125af1607cf2ed8a2aab69
Parent:        63c5aaaaf22716f8a04df43b7f7ac4611445b677
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 23 15:21:18 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 11:24:10 2015 +0200

config: regenerate configure.in to accomodate all recent changes

Hopefully closer to the ideal.
---
 conf/example.conf.in  |   78 +++++++++++++++++++++++++++----------------------
 conf/lvmlocal.conf.in |    5 +--
 2 files changed, 45 insertions(+), 38 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index e809488..41d219a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -4,6 +4,17 @@
 #
 # Refer to 'man lvm.conf' for further information including the file layout.
 #
+# Refer to 'man lvm.conf' for information about how settings configured in
+# this file are combined with built-in values and command line options to
+# arrive at the final values used by LVM.
+#
+# Refer to 'man lvmconfig' for information about displaying the built-in
+# and configured values used by LVM.
+#
+# If a default value is set in this file (not commented out), then a
+# new version of LVM using this file will continue using that value,
+# even if the new version of LVM changes the built-in default value.
+#
 # To put this file in a different directory and override @DEFAULT_SYS_DIR@ set
 # the environment variable LVM_SYSTEM_DIR before running the tools.
 #
@@ -92,7 +103,7 @@ devices {
 	# Example:
 	# preferred_names = [ "^/dev/mpath/", "^/dev/mapper/mpath", "^/dev/[hs]d" ]
 	# This configuration option does not have a default value defined.
-	# preferred_names=[]
+	# preferred_names = [ ]
 
 	# Configuration option devices/filter.
 	# Limit the block devices that are used by LVM commands.
@@ -128,8 +139,7 @@ devices {
 	# Example:
 	# Use anchors to be very specific.
 	# filter = [ "a|^/dev/hda8$|", "r|.*/|" ]
-	# This configuration option does not have a default value defined.
-	# filter = []
+	# filter = [ "a|.*/|" ]
 
 	# Configuration option devices/global_filter.
 	# Limit the block devices that are used by LVM system components.
@@ -138,8 +148,7 @@ devices {
 	# and lvmetad. Use global_filter to hide devices from these LVM
 	# system components. The syntax is the same as devices/filter.
 	# Devices rejected by global_filter are not opened by LVM.
-	# This configuration option does not have a default value defined.
-	# global_filter = []
+	# global_filter = [ "a|.*/|" ]
 
 	# Configuration option devices/cache_dir.
 	# Directory in which to store the device cache file.
@@ -167,7 +176,7 @@ devices {
 	# types = [ "fd", 16 ]
 	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
-	# types = []
+	# types = [ ]
 
 	# Configuration option devices/sysfs_scan.
 	# Restrict device scanning to block devices appearing in sysfs.
@@ -316,7 +325,7 @@ allocation {
 	# they are situated.
 	# cling_tag_list = [ "@site1", "@site2" ]
 	# This configuration option does not have a default value defined.
-	# cling_tag_list = []
+	# cling_tag_list = [ ]
 
 	# Configuration option allocation/maximise_cling.
 	# Use a previous allocation algorithm.
@@ -336,7 +345,7 @@ allocation {
 	# MD device signatures, swap signature, and LUKS signatures.
 	# To see the list of signatures recognized by blkid, check the
 	# output of the 'blkid -k' command.
-	use_blkid_wiping = 1
+	use_blkid_wiping = @DEFAULT_USE_BLKID_WIPING@
 
 	# Configuration option allocation/wipe_signatures_when_zeroing_new_lvs.
 	# Look for and erase any signatures while zeroing a new LV.
@@ -492,7 +501,7 @@ log {
 	# Configuration option log/activation.
 	# Log messages during activation.
 	# Don't use this in low memory situations (can deadlock).
-	# activation = 0
+	activation = 0
 
 	# Configuration option log/debug_classes.
 	# Select log messages by class.
@@ -502,8 +511,7 @@ log {
 	# memory, devices, activation, allocation,
 	# lvmetad, metadata, cache, locking, lvmpolld.
 	# Use "all" to see everything.
-	debug_classes = ["memory", "devices", "activation", "allocation",
-			 "lvmetad", "metadata", "cache", "locking", "lvmpolld"]
+	debug_classes = [ "memory", "devices", "activation", "allocation", "lvmetad", "metadata", "cache", "locking", "lvmpolld" ]
 }
 
 # Configuration section backup.
@@ -600,7 +608,7 @@ global {
 	# The LVM1 tools need to be installed with .lvm1 suffices,
 	# e.g. vgscan.lvm1. They will stop working once the lvm2
 	# on-disk metadata format is used.
-	# fallback_to_lvm1 = 0
+	# fallback_to_lvm1 = 1
 
 	# Configuration option global/format.
 	# The default metadata format that commands should use.
@@ -613,11 +621,11 @@ global {
 	# If support for LVM1 metadata was compiled as a shared library use
 	# format_libraries = "liblvm2format1.so"
 	# This configuration option does not have a default value defined.
-	# format_libraries = []
+	# format_libraries = [ ]
 
 	# Configuration option global/segment_libraries.
 	# This configuration option does not have a default value defined.
-	# segment_libraries = []
+	# segment_libraries = [ ]
 
 	# Configuration option global/proc.
 	# Location of proc filesystem.
@@ -856,12 +864,12 @@ global {
 	# ignorable errors and fix them later.
 	# With thin_check version 3.2 or newer you should add
 	# --clear-needs-check-flag.
-	# thin_check_options = ["-q", "--clear-needs-check-flag"]
+	# thin_check_options = [ "-q" ]
 
 	# Configuration option global/thin_repair_options.
 	# List of options passed to the thin_repair command.
 	# This configuration option does not have a default value defined.
-	# thin_repair_options = ""
+	# thin_repair_options = [ ]
 
 	# Configuration option global/thin_disabled_features.
 	# Features to not use in the thin driver.
@@ -873,7 +881,7 @@ global {
 	# Example:
 	# thin_disabled_features = [ "discards", "block_size" ]
 	# This configuration option does not have a default value defined.
-	# thin_disabled_features = []
+	# thin_disabled_features = [ ]
 
 	# Configuration option global/cache_check_executable.
 	# The full path to the cache_check command.
@@ -904,12 +912,12 @@ global {
 
 	# Configuration option global/cache_check_options.
 	# List of options passed to the cache_check command.
-	# cache_check_options = "-q"
+	# cache_check_options = [ "-q" ]
 
 	# Configuration option global/cache_repair_options.
 	# List of options passed to the cache_repair command.
 	# This configuration option does not have a default value defined.
-	# cache_repair_options = ""
+	# cache_repair_options = [ ]
 
 	# Configuration option global/system_id_source.
 	# The method LVM uses to set the local system ID.
@@ -925,12 +933,12 @@ global {
 	# 'local' section of an lvm configuration file, e.g. lvmlocal.conf.
 	# uname - Set the system ID from the hostname (uname) of the system.
 	# System IDs beginning localhost are not permitted.
-	# machineid - Use the contents of the file @CONFDIR@/machine-id to set the
+	# machineid - Use the contents of the machine-id file to set the
 	# system ID.  Some systems create this file at installation time.
-	# See 'man machine-id'.
+	# See 'man machine-id' and global/etc.
 	# file - Use the contents of another file (system_id_file) to set
 	# the system ID.
-	# system_id_source = "none"
+	system_id_source = "none"
 
 	# Configuration option global/system_id_file.
 	# The full path to the file containing a system ID.
@@ -939,15 +947,16 @@ global {
 	# This configuration option does not have a default value defined.
 	# system_id_file = ""
 
+	# Configuration option global/use_lvmpolld.
 	# Use lvmpolld to supervise long running LVM commands.
 	# When enabled, control of long running LVM commands is transferred
-	# from the original LVM command to the lvmpolld daemon. This allows
+	# from the original LVM command to the lvmpolld daemon.  This allows
 	# the operation to continue independent of the original LVM command.
 	# After lvmpolld takes over, the LVM command displays the progress
-	# of the ongoing operation. lvmpolld itself runs LVM commands to manage
-	# the progress of ongoing operations. lvmpolld can be used as a native
+	# of the ongoing operation.  lvmpolld itself runs LVM commands to manage
+	# the progress of ongoing operations.  lvmpolld can be used as a native
 	# systemd service, which allows it to be started on demand, and to use
-	# its own control group. When this option is disabled, LVM commands will
+	# its own control group.  When this option is disabled, LVM commands will
 	# supervise long running operations by forking themselves.
 	use_lvmpolld = @DEFAULT_USE_LVMPOLLD@
 }
@@ -1048,7 +1057,7 @@ activation {
 	# Example:
 	# volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 	# This configuration option does not have a default value defined.
-	# volume_list = []
+	# volume_list = [ ]
 
 	# Configuration option activation/auto_activation_volume_list.
 	# Only LVs selected by this list are auto-activated.
@@ -1080,7 +1089,7 @@ activation {
 	# Possible options are: vgname, vgname/lvname, @tag, @*
 	# See volume_list for how these options are matched to LVs.
 	# This configuration option does not have a default value defined.
-	# auto_activation_volume_list = []
+	# auto_activation_volume_list = [ ]
 
 	# Configuration option activation/read_only_volume_list.
 	# LVs in this list are activated in read-only mode.
@@ -1092,7 +1101,7 @@ activation {
 	# Possible options are: vgname, vgname/lvname, @tag, @*
 	# See volume_list for how these options are matched to LVs.
 	# This configuration option does not have a default value defined.
-	# read_only_volume_list = []
+	# read_only_volume_list = [ ]
 
 	# Configuration option activation/raid_region_size.
 	# Size in KiB of each raid or mirror synchronization region.
@@ -1221,7 +1230,7 @@ activation {
 	# Auto-extending a thin pool adds this percent extra space.
 	# The amount of additional space added to a thin pool is this
 	# percent of its current size.
-	thin_pool_autoextend_percent=20
+	thin_pool_autoextend_percent = 20
 
 	# Configuration option activation/mlock_filter.
 	# Do not mlock these memory areas.
@@ -1240,7 +1249,7 @@ activation {
 	# mlock_filter = [ "locale/locale-archive", "gconv/gconv-modules.cache" ]
 	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
-	# mlock_filter = []
+	# mlock_filter = [ ]
 
 	# Configuration option activation/use_mlockall.
 	# Use the old behavior of mlockall to pin all memory.
@@ -1361,7 +1370,7 @@ activation {
 	# dirs = [ "/etc/lvm/metadata", "/mnt/disk2/lvm/metadata2" ]
 	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
-	# dirs = []
+	# dirs = [ ]
 # }
 
 # Configuration section report.
@@ -1410,7 +1419,7 @@ activation {
 
 	# Configuration option report/colums_as_rows.
 	# Output each column as a row.
-	# If set, this also implies report/prefixes = 1.
+	# If set, this also implies report/prefixes=1.
 	# colums_as_rows = 0
 
 	# Configuration option report/binary_values_as_numeric.
@@ -1572,7 +1581,6 @@ dmeventd {
 	# bar is given to the hosts named machine1 and machine2.
 	# tags { foo { } bar { host_list = [ "machine1", "machine2" ] } }
 	# This configuration section has variable name.
-	# This configuration section does not have a default value defined.
 	# tag {
 
 		# Configuration option tags/<tag>/host_list.
@@ -1582,6 +1590,6 @@ dmeventd {
 		# matches an entry in this list, the name of the
 		# subsection is applied to the machine as a 'host tag'.
 		# This configuration option does not have a default value defined.
-		# host_list = ""
+		# host_list = [ ]
 	# }
 # }
diff --git a/conf/lvmlocal.conf.in b/conf/lvmlocal.conf.in
index e151b50..ec3b081 100644
--- a/conf/lvmlocal.conf.in
+++ b/conf/lvmlocal.conf.in
@@ -36,8 +36,7 @@ local {
 	# Example:
 	# Set the system_id to the string 'host1'.
 	# system_id = "host1"
-	# This configuration option does not have a default value defined.
-	# system_id=""
+	# system_id = ""
 
 	# Configuration option local/extra_system_ids.
 	# A list of extra VG system IDs the local host can access.
@@ -49,5 +48,5 @@ local {
 	# Use this only after consulting 'man lvmsystemid'
 	# to be certain of correct usage and possible dangers.
 	# This configuration option does not have a default value defined.
-	# extra_system_ids=[]
+	# extra_system_ids = [ ]
 }


