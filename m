From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 29 Jun 2015 11:43:55 +0000 (UTC)
Subject: master - config: regenerate lvm.conf.in and lvmlocal.conf.in
Message-ID: <20150629114355.7A8C0600D5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f793d34ca8993d1e70df58340d7c1897b368a09
Commit:        6f793d34ca8993d1e70df58340d7c1897b368a09
Parent:        7b45a1fc60859faa4163bde8332ac7c173802640
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 29 13:43:28 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 29 13:43:28 2015 +0200

config: regenerate lvm.conf.in and lvmlocal.conf.in

---
 conf/example.conf.in  |   19 -------------------
 conf/lvmlocal.conf.in |    1 -
 2 files changed, 0 insertions(+), 20 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 41d219a..3433508 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -103,7 +103,6 @@ devices {
 	# Example:
 	# preferred_names = [ "^/dev/mpath/", "^/dev/mapper/mpath", "^/dev/[hs]d" ]
 	# This configuration option does not have a default value defined.
-	# preferred_names = [ ]
 
 	# Configuration option devices/filter.
 	# Limit the block devices that are used by LVM commands.
@@ -176,7 +175,6 @@ devices {
 	# types = [ "fd", 16 ]
 	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
-	# types = [ ]
 
 	# Configuration option devices/sysfs_scan.
 	# Restrict device scanning to block devices appearing in sysfs.
@@ -325,7 +323,6 @@ allocation {
 	# they are situated.
 	# cling_tag_list = [ "@site1", "@site2" ]
 	# This configuration option does not have a default value defined.
-	# cling_tag_list = [ ]
 
 	# Configuration option allocation/maximise_cling.
 	# Use a previous allocation algorithm.
@@ -398,7 +395,6 @@ allocation {
 	# end of the spectrum.  Supported values range from 32(kiB) to
 	# 1048576 in multiples of 32.
 	# This configuration option does not have a default value defined.
-	# cache_pool_chunk_size = 128
 
 	# Configuration option allocation/thin_pool_metadata_require_separate_pvs.
 	# Thin pool metdata and data will always use different PVs.
@@ -436,7 +432,6 @@ allocation {
 	# chunk size starting from 64KB.  Supported values are in
 	# the range 64 to 1048576.
 	# This configuration option does not have a default value defined.
-	# thin_pool_chunk_size = 128
 
 	# Configuration option allocation/physical_extent_size.
 	# Default physical extent size to use for new VGs (in KB).
@@ -470,7 +465,6 @@ log {
 	# Configuration option log/file.
 	# Write error and debug log messages to a file specified here.
 	# This configuration option does not have a default value defined.
-	# file = ""
 
 	# Configuration option log/overwrite.
 	# Overwrite the log file each time the program is run.
@@ -621,11 +615,9 @@ global {
 	# If support for LVM1 metadata was compiled as a shared library use
 	# format_libraries = "liblvm2format1.so"
 	# This configuration option does not have a default value defined.
-	# format_libraries = [ ]
 
 	# Configuration option global/segment_libraries.
 	# This configuration option does not have a default value defined.
-	# segment_libraries = [ ]
 
 	# Configuration option global/proc.
 	# Location of proc filesystem.
@@ -702,7 +694,6 @@ global {
 	# Configuration option global/library_dir.
 	# Search this directory first for shared libraries.
 	# This configuration option does not have a default value defined.
-	# library_dir = ""
 
 	# Configuration option global/locking_library.
 	# The external locking library to use for locking_type 2.
@@ -869,7 +860,6 @@ global {
 	# Configuration option global/thin_repair_options.
 	# List of options passed to the thin_repair command.
 	# This configuration option does not have a default value defined.
-	# thin_repair_options = [ ]
 
 	# Configuration option global/thin_disabled_features.
 	# Features to not use in the thin driver.
@@ -881,7 +871,6 @@ global {
 	# Example:
 	# thin_disabled_features = [ "discards", "block_size" ]
 	# This configuration option does not have a default value defined.
-	# thin_disabled_features = [ ]
 
 	# Configuration option global/cache_check_executable.
 	# The full path to the cache_check command.
@@ -917,7 +906,6 @@ global {
 	# Configuration option global/cache_repair_options.
 	# List of options passed to the cache_repair command.
 	# This configuration option does not have a default value defined.
-	# cache_repair_options = [ ]
 
 	# Configuration option global/system_id_source.
 	# The method LVM uses to set the local system ID.
@@ -945,7 +933,6 @@ global {
 	# This is used when system_id_source is set to 'file'.
 	# Comments starting with the character # are ignored.
 	# This configuration option does not have a default value defined.
-	# system_id_file = ""
 
 	# Configuration option global/use_lvmpolld.
 	# Use lvmpolld to supervise long running LVM commands.
@@ -1057,7 +1044,6 @@ activation {
 	# Example:
 	# volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 	# This configuration option does not have a default value defined.
-	# volume_list = [ ]
 
 	# Configuration option activation/auto_activation_volume_list.
 	# Only LVs selected by this list are auto-activated.
@@ -1089,7 +1075,6 @@ activation {
 	# Possible options are: vgname, vgname/lvname, @tag, @*
 	# See volume_list for how these options are matched to LVs.
 	# This configuration option does not have a default value defined.
-	# auto_activation_volume_list = [ ]
 
 	# Configuration option activation/read_only_volume_list.
 	# LVs in this list are activated in read-only mode.
@@ -1101,7 +1086,6 @@ activation {
 	# Possible options are: vgname, vgname/lvname, @tag, @*
 	# See volume_list for how these options are matched to LVs.
 	# This configuration option does not have a default value defined.
-	# read_only_volume_list = [ ]
 
 	# Configuration option activation/raid_region_size.
 	# Size in KiB of each raid or mirror synchronization region.
@@ -1249,7 +1233,6 @@ activation {
 	# mlock_filter = [ "locale/locale-archive", "gconv/gconv-modules.cache" ]
 	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
-	# mlock_filter = [ ]
 
 	# Configuration option activation/use_mlockall.
 	# Use the old behavior of mlockall to pin all memory.
@@ -1370,7 +1353,6 @@ activation {
 	# dirs = [ "/etc/lvm/metadata", "/mnt/disk2/lvm/metadata2" ]
 	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
-	# dirs = [ ]
 # }
 
 # Configuration section report.
@@ -1590,6 +1572,5 @@ dmeventd {
 		# matches an entry in this list, the name of the
 		# subsection is applied to the machine as a 'host tag'.
 		# This configuration option does not have a default value defined.
-		# host_list = [ ]
 	# }
 # }
diff --git a/conf/lvmlocal.conf.in b/conf/lvmlocal.conf.in
index ec3b081..0e82d5c 100644
--- a/conf/lvmlocal.conf.in
+++ b/conf/lvmlocal.conf.in
@@ -48,5 +48,4 @@ local {
 	# Use this only after consulting 'man lvmsystemid'
 	# to be certain of correct usage and possible dangers.
 	# This configuration option does not have a default value defined.
-	# extra_system_ids = [ ]
 }


