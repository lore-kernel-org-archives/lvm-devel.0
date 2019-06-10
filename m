From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 10 Jun 2019 11:06:59 -0400
Subject: master - build: make generate
Message-ID: <201906101507.x5AF6xT6013244@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a2c309a5c5eb22a94be0ae2919831a10b0493974
Commit:        a2c309a5c5eb22a94be0ae2919831a10b0493974
Parent:        07d41de74c40e6472a708fc0112ad668477305b5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Jun 7 17:59:43 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jun 7 17:59:43 2019 +0200

build: make generate

---
 conf/example.conf.in   |   57 ++++++++++++++++++++++++++++++++++++++--
 man/lvconvert.8_pregen |   61 ++++++++++++++++++++++++++++++++++++++++---
 man/lvcreate.8_pregen  |    5 ++-
 man/pvck.8_pregen      |   67 +++++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 177 insertions(+), 13 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index dfe8006..a5eba01 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -88,6 +88,22 @@ devices {
 	# 
 	external_device_info_source = "none"
 
+	# Configuration option devices/hints.
+	# Use a local file to remember which devices have PVs on them.
+	# Some commands will use this as an optimization to reduce device
+	# scanning, and will only scan the listed PVs. Removing the hint file
+	# will cause lvm to generate a new one. Disable hints if PVs will
+	# be copied onto devices using non-lvm commands, like dd.
+	# 
+	# Accepted values:
+	#   all
+	#     Use all hints.
+	#   none
+	#     Use no hints.
+	# 
+	# This configuration option has an automatic default value.
+	# hints = "all"
+
 	# Configuration option devices/preferred_names.
 	# Select which path name to display for a block device.
 	# If multiple path names exist for a block device, and LVM needs to
@@ -167,8 +183,18 @@ devices {
 	sysfs_scan = 1
 
 	# Configuration option devices/scan_lvs.
-	# Scan LVM LVs for layered PVs.
-	scan_lvs = 1
+	# Scan LVM LVs for layered PVs, allowing LVs to be used as PVs.
+	# When 1, LVM will detect PVs layered on LVs, and caution must be
+	# taken to avoid a host accessing a layered VG that may not belong
+	# to it, e.g. from a guest image. This generally requires excluding
+	# the LVs with device filters. Also, when this setting is enabled,
+	# every LVM command will scan every active LV on the system (unless
+	# filtered), which can cause performance problems on systems with
+	# many active LVs. When this setting is 0, LVM will not detect or
+	# use PVs that exist on LVs, and will not allow a PV to be created on
+	# an LV. The LVs are ignored using a built in device filter that
+	# identifies and excludes LVs.
+	scan_lvs = 0
 
 	# Configuration option devices/multipath_component_detection.
 	# Ignore devices that are components of DM multipath devices.
@@ -720,7 +746,8 @@ log {
 
 	# Configuration option log/indent.
 	# Indent messages according to their severity.
-	indent = 1
+	# This configuration option has an automatic default value.
+	# indent = 0
 
 	# Configuration option log/command_names.
 	# Display the command name on each line of output.
@@ -746,6 +773,20 @@ log {
 	# available: memory, devices, io, activation, allocation,
 	# metadata, cache, locking, lvmpolld. Use "all" to see everything.
 	debug_classes = [ "memory", "devices", "io", "activation", "allocation", "metadata", "cache", "locking", "lvmpolld", "dbus" ]
+
+	# Configuration option log/debug_file_fields.
+	# The fields included in debug output written to log file.
+	# Use "all" to include everything (the default).
+	# This configuration option is advanced.
+	# This configuration option has an automatic default value.
+	# debug_file_fields = [ "time", "command", "fileline", "message" ]
+
+	# Configuration option log/debug_output_fields.
+	# The fields included in debug output written to stderr.
+	# Use "all" to include everything (the default).
+	# This configuration option is advanced.
+	# This configuration option has an automatic default value.
+	# debug_output_fields = [ "time", "command", "fileline", "message" ]
 }
 
 # Configuration section backup.
@@ -1174,6 +1215,16 @@ global {
 	# When enabled, an LVM command that changes PVs, changes VG metadata,
 	# or changes the activation state of an LV will send a notification.
 	notify_dbus = 1
+
+	# Configuration option global/io_memory_size.
+	# The amount of memory in KiB that LVM allocates to perform disk io.
+	# LVM performance may benefit from more io memory when there are many
+	# disks or VG metadata is large. Increasing this size may be necessary
+	# when a single copy of VG metadata is larger than the current setting.
+	# This value should usually not be decreased from the default; setting
+	# it too low can result in lvm failing to read VGs.
+	# This configuration option has an automatic default value.
+	# io_memory_size = 8192
 }
 
 # Configuration section activation.
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 842be37..7252f6f 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -43,6 +43,10 @@ lvconvert - Change logical volume layout
 .ad b
 .br
 .ad l
+    \fB--cachevol\fP \fILV\fP
+.ad b
+.br
+.ad l
  \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .ad b
 .br
@@ -567,7 +571,7 @@ Convert LV to a thin LV, using the original LV as an external origin.
 .br
 -
 
-Attach a cache to an LV, converts the LV to type cache.
+Attach a cache pool to an LV, converts the LV to type cache.
 .br
 .P
 \fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_vdo_vdopool_vdopooldata_raid\fP
@@ -629,7 +633,7 @@ Attach a cache to an LV, converts the LV to type cache.
 Attach a writecache to an LV, converts the LV to type writecache.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBwritecache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_raid\fP
+\fBlvconvert\fP \fB--type\fP \fBwritecache\fP \fB--cachevol\fP \fILV\fP \fILV\fP\fI_linear_striped_raid\fP
 .br
 .RS 4
 .ad l
@@ -641,6 +645,49 @@ Attach a writecache to an LV, converts the LV to type writecache.
 .br
 -
 
+Attach a cache to an LV, converts the LV to type cache.
+.br
+.P
+\fBlvconvert\fP \fB--type\fP \fBcache\fP \fB--cachevol\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
+.br
+.RS 4
+.ad l
+[ \fB-H\fP|\fB--cache\fP ]
+.ad b
+.br
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachepolicy\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
 Convert LV to type thin-pool.
 .br
 .P
@@ -1047,7 +1094,7 @@ See \fBlvmcache\fP(7) for more information.
 .ad l
 \fB--cachepool\fP \fILV\fP
 .br
-The name of a cache pool LV.
+The name of a cache pool.
 .ad b
 .HP
 .ad l
@@ -1063,6 +1110,12 @@ See \fBlvmcache\fP(7) for more information.
 .ad b
 .HP
 .ad l
+\fB--cachevol\fP \fILV\fP
+.br
+The name of a cache volume.
+.ad b
+.HP
+.ad l
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .br
 The size of chunks in a snapshot, cache pool or thin pool.
@@ -1689,7 +1742,7 @@ Convert LV to a thin LV, using the original LV as an external origin
 .br
 -
 
-Attach a cache to an LV (infers --type cache).
+Attach a cache pool to an LV (infers --type cache).
 .br
 .P
 \fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachepool\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_vdo_vdopool_vdopooldata_raid\fP
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index f1d9f13..a80f9f5 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -309,7 +309,8 @@ numeric suffix.
 In the usage section below, when creating a pool and the name is omitted
 the new LV pool name is generated with the
 "vpool" for vdo-pools  for prefix and a unique numeric suffix.
-Also pool name can be specified together with \fIVG\fP name i.e.:
+
+Pool name can be specified together with \fIVG\fP name i.e.:
 vg00/mythinpool.
 .SH USAGE
 Create a linear LV.
@@ -1097,7 +1098,7 @@ See \fBlvmcache\fP(7) for more information.
 .ad l
 \fB--cachepool\fP \fILV\fP
 .br
-The name of a cache pool LV.
+The name of a cache pool.
 .ad b
 .HP
 .ad l
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 5277418..6cdfe42 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -1,26 +1,58 @@
 .TH PVCK 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .SH NAME
-pvck - Check the consistency of physical volume(s)
+pvck - Check metadata on physical volumes
 .
 .SH SYNOPSIS
-\fBpvck\fP \fIposition_args\fP
+\fBpvck\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
 .SH DESCRIPTION
-pvck checks the LVM metadata for consistency on PVs.
+pvck checks LVM metadata on PVs.
+
+Use the --dump option to extract metadata from PVs for debugging.
+With dump, set --pvmetadatacopies 2 to extract metadata from a
+second metadata area at the end of the device. Use the --file
+option to save the raw metadata to a specified file. (The raw
+metadata is not usable with vgcfgbackup and vgcfgrestore.)
+
 .SH USAGE
+Check for metadata on a device
+.br
+.P
 \fBpvck\fP \fIPV\fP ...
 .br
 .RS 4
+[ COMMON_OPTIONS ]
+.RE
+.br
+
+Print metadata from a device
+.br
+.P
+\fBpvck\fP \fB--dump\fP \fIString\fP \fIPV\fP
+.br
+.RS 4
 .ad l
-[    \fB--labelsector\fP \fINumber\fP ]
+[ \fB-f\fP|\fB--file\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP ]
 .ad b
 .br
 [ COMMON_OPTIONS ]
 .RE
 .br
 
+Common options for command:
+.
+.RS 4
+.ad l
+[    \fB--labelsector\fP \fINumber\fP ]
+.ad b
+.RE
+
 Common options for lvm:
 .
 .RS 4
@@ -113,6 +145,21 @@ For testing and debugging.
 .ad b
 .HP
 .ad l
+\fB--dump\fP \fIString\fP
+.br
+Dump metadata from a PV. Option values include \fBmetadata\fP
+to print or save the current text metadata, \fBmetadata_area\fP
+to save the entire text metadata area to a file, \fBmetadata_all\fP
+to save the current and any previous complete versions of metadata
+to a file, and \fBheaders\fP to print and check LVM headers.
+.ad b
+.HP
+.ad l
+\fB-f\fP|\fB--file\fP \fIString\fP
+.br
+.ad b
+.HP
+.ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
@@ -154,6 +201,18 @@ on the command.
 .ad b
 .HP
 .ad l
+\fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
+.br
+The number of metadata areas to set aside on a PV for storing VG metadata.
+When 2, one copy of the VG metadata is stored at the front of the PV
+and a second copy is stored at the end.
+When 1, one copy of the VG metadata is stored at the front of the PV.
+When 0, no copies of the VG metadata are stored on the given PV.
+This may be useful in VGs containing many PVs (this places limitations
+on the ability to use vgsplit later.)
+.ad b
+.HP
+.ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 Suppress output and log messages. Overrides --debug and --verbose.


