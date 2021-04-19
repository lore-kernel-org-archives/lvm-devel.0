From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:57 +0000 (GMT)
Subject: main - man: typography fixes
Message-ID: <20210419130057.672B2396903A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9164a393de449f285038811d58ade0fb3ecfba30
Commit:        9164a393de449f285038811d58ade0fb3ecfba30
Parent:        0f87b015b5f4251f9584244176b9f7c0579755e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 15 13:16:41 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:54:37 2021 +0200

man: typography fixes

Correcting some usage of Bold and Italics (files).
Adding some missing SEE ALSO.
Fixing missed replaceable paths that are configurable.
Be careful about .P in .TP sections - need to use .sp for space line.
Use .UR/.UE for URL references.
---
 man/blkdeactivate.8_main | 41 +++++++++++----------
 man/dmeventd.8_main      | 13 ++++---
 man/dmfilemapd.8_main    | 24 ++++++-------
 man/dmsetup.8_main       | 55 +++++++++++++++--------------
 man/dmstats.8_main       | 92 ++++++++++++++++++++++++++----------------------
 man/lvconvert.8_des      |  4 +--
 man/lvcreate.8_end       |  2 +-
 man/lvm.8_main           | 30 +++++++++++++---
 man/lvm.conf.5_main      | 20 +++++------
 man/lvmcache.7_main      | 46 ++++++++++++++----------
 man/lvmdevices.8_des     |  4 +--
 man/lvmdump.8_main       | 26 ++++++++------
 man/lvmlockctl.8_main    | 34 +++++++++---------
 man/lvmpolld.8_main      |  6 ++--
 man/lvmthin.7_main       |  8 +++--
 man/lvmvdo.7_main        | 57 ++++++++++++++++--------------
 man/lvs.8_end            | 82 +++++++++++++++++++++---------------------
 man/pvck.8_des           |  2 +-
 man/pvs.8_end            |  6 ++--
 man/see_also.end         | 14 ++++----
 man/vgs.8_end            | 12 +++----
 21 files changed, 314 insertions(+), 264 deletions(-)

diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index a832b1af1..398db37cd 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -45,9 +45,11 @@ MD devices are handled using the \fBmdadm\fP(8) command.
 Comma separated list of device-mapper specific options.
 Accepted \fBdmsetup\fP(8) options are:
 .RS
-.IP \fIretry\fP
+.TP
+.B retry
 Retry removal several times in case of failure.
-.IP \fIforce\fP
+.TP
+.B force
 Force device removal.
 .RE
 .
@@ -66,19 +68,32 @@ Display the help text.
 .BR -l | --lvmoptions " " \fIlvm_options
 Comma-separated list of LVM specific options:
 .RS
-.IP \fIretry\fP
+.TP
+.B retry
 Retry removal several times in case of failure.
-.IP \fIwholevg\fP
+.TP
+.B wholevg
 Deactivate the whole LVM Volume Group when processing a Logical Volume.
 Deactivating the Volume Group as a whole is quicker than deactivating
 each Logical Volume separately.
 .RE
 .
 .TP
+.BR -r | --mdraidoptions " " \fImdraid_options
+Comma-separated list of MD RAID specific options:
+.RS
+.TP
+.B wait
+Wait MD device's resync, recovery or reshape action to complete
+before deactivation.
+.RE
+.
+.TP
 .BR -m | --mpathoptions " " \fImpath_options
 Comma-separated list of device-mapper multipath specific options:
 .RS
-.IP \fIdisablequeueing\fP
+.TP
+.B disablequeueing
 Disable queueing on all multipath devices before deactivation.
 This avoids a situation where blkdeactivate may end up waiting if
 all the paths are unavailable for any underlying device-mapper multipath
@@ -86,19 +101,11 @@ device.
 .RE
 .
 .TP
-.BR -r | --mdraidoptions " " \fImdraid_options
-Comma-separated list of MD RAID specific options:
-.RS
-.IP \fIwait\fP
-Wait MD device's resync, recovery or reshape action to complete
-before deactivation.
-.RE
-.
-.TP
 .BR -o | --vdooptions " " \fIvdo_options
 Comma-separated list of VDO specific options:
 .RS
-.IP \fIconfigfile=file\fP
+.TP
+.BR configfile = \fIfile
 Use specified VDO configuration file.
 .RE
 .
@@ -118,21 +125,18 @@ devices.
 .br
 #
 .B blkdeactivate
-.br
 .P
 Deactivate all supported block devices found in the system, unmounting any
 mounted devices first, if possible.
 .br
 #
 .B blkdeactivate -u
-.br
 .P
 Deactivate the device /dev/vg/lvol0 together with all its holders, unmounting
 any mounted devices first, if possible.
 .br
 #
 .B blkdeactivate -u /dev/vg/lvol0
-.br
 .P
 Deactivate all supported block devices found in the system. If the deactivation
 of a device-mapper device fails, retry it. Deactivate the whole
@@ -140,7 +144,6 @@ Volume Group at once when processing an LVM Logical Volume.
 .br
 #
 .B blkdeactivate -u -d retry -l wholevg
-.br
 .P
 Deactivate all supported block devices found in the system. If the deactivation
 of a device-mapper device fails, retry it and force removal.
diff --git a/man/dmeventd.8_main b/man/dmeventd.8_main
index 123073b18..c03605d9c 100644
--- a/man/dmeventd.8_main
+++ b/man/dmeventd.8_main
@@ -96,11 +96,11 @@ The warning is repeated when more then 85%, 90% and 95%
 of the thin pool is filled. See
 .BR lvm.conf (5).
 When a thin pool fills over 50% (data or metadata) thin plugin calls
-configured \fIdmeventd/thin_command\fP with every 5% increase.
+configured \fBdmeventd/thin_command\fP with every 5% increase.
 With default setting it calls internal
 \fBlvm lvextend --use-policies\fP to resize thin pool
 when it's been filled above configured threshold
-\fIactivation/thin_pool_autoextend_threshold\fP.
+\fBactivation/thin_pool_autoextend_threshold\fP.
 If the command fails, dmeventd thin plugin will keep
 retrying execution with increasing time delay between
 retries upto 42 minutes.
@@ -126,11 +126,11 @@ The warning is repeated when more then 85%, 90% and 95%
 of the VDO pool is filled. See
 .BR lvm.conf (5).
 When a VDO pool fills over 50% vdo plugin calls
-configured \fIdmeventd/vdo_command\fP with every 5% increase.
+configured \fBdmeventd/vdo_command\fP with every 5% increase.
 With default setting it calls internal
 \fBlvm lvextend --use-policies\fP to resize VDO pool
 when it's been filled above the configured threshold
-\fIactivation/vdo_pool_autoextend_threshold\fP.
+\fBactivation/vdo_pool_autoextend_threshold\fP.
 If the command fails, dmeventd vdo plugin will keep
 retrying execution with increasing time delay between
 retries upto 42 minutes.
@@ -173,4 +173,7 @@ a thin_command, vdo_command environment.
 .SH SEE ALSO
 .
 .BR lvm (8),
-.BR lvm.conf (5)
+.BR lvm.conf (5),
+.BR lvextend (8),
+.br
+.BR fstrim (8)
diff --git a/man/dmfilemapd.8_main b/man/dmfilemapd.8_main
index 864933609..e317166b6 100644
--- a/man/dmfilemapd.8_main
+++ b/man/dmfilemapd.8_main
@@ -44,7 +44,7 @@ dmfilemapd \(em device-mapper filemap monitoring daemon
 .
 .SH DESCRIPTION
 .
-The dmfilemapd daemon monitors groups of \fBdmstats\fP regions that
+The dmfilemapd daemon monitors groups of \fBdmstats\fP(8) regions that
 correspond to the extents of a file, adding and removing regions to
 reflect the changing state of the file on-disk.
 .P
@@ -174,28 +174,20 @@ verbose logging
 .ad l
 #
 .B dmfilemapd 3 0 /var/tmp/data inode 1 3 3< /var/tmp/data
-.br
+.nf
 Starting dmfilemapd with fd=3, group_id=0 mode=inode, path=/var/tmp/data
-.br
 dm version   [ opencount flush ]   [16384] (*1)
-.br
 dm info   (253:0) [ opencount flush ]   [16384] (*1)
-.br
 dm message   (253:0) [ opencount flush ]  @stats_list dmstats [16384] (*1)
-.br
 Read alias 'data' from aux_data
-.br
 Found group_id 0: alias="data"
-.br
 dm_stats_walk_init: initialised flags to 4000000000000
-.br
 starting stats walk with   GROUP
-.br
 exiting _filemap_monitor_get_events() with deleted=0, check=0
-.br
 Waiting for check interval
-.br
+.fi
 .ad b
+
 .
 .SH AUTHORS
 .
@@ -205,6 +197,10 @@ Bryn M. Reeves <bmr@redhat.com>
 .
 .BR dmstats (8)
 .P
-LVM2 resource page: https://www.sourceware.org/lvm2/
+LVM2 resource page:
+.UR https://www.sourceware.org/lvm2
+.UE
 .br
-Device-mapper resource page: http://sources.redhat.com/dm/
+Device-mapper resource page:
+.UR http://sources.redhat.com/dm
+.UE
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index aa60a0153..359b06ce3 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -389,9 +389,10 @@ dmsetup \(em low level logical volume management
 .  ad b
 ..
 .CMD_WIPE_TABLE
-.PD
-.P
-.PD 0
+.
+.TP
+\ \&
+.
 .TP
 .B devmap_name \fImajor minor
 .TP
@@ -423,7 +424,7 @@ Ensure \fI/dev/mapper\fP node exists after \fBdmsetup create\fP.
 .
 .TP
 .B --addnodeonresume
-Ensure \fI/dev/mapper\fP node exists after \fBdmsetup resume\fP (default with udev).
+Ensure \fI/dev/mapper\fP node exists after \fBdmsetup\ resume\fP (default with udev).
 .
 .TP
 .B --checks
@@ -473,7 +474,7 @@ if already mangled, error on mixed),
 \fBhex\fP (always do the mangling) and
 \fBnone\fP (no mangling).
 Default mode is \fB#DEFAULT_MANGLING#\fP.
-Character whitelist: 0-9, A-Z, a-z, #+-.:=@_. This whitelist is
+Character whitelist: 0-9, A-Z, a-z, #+\-.:=@_. This whitelist is
 also supported by udev. Any character not on a whitelist is replaced
 with its hex value (two digits) prefixed by \\x.
 Mangling mode could be also set through
@@ -924,10 +925,10 @@ e.g. striped 2 32 /dev/hda1 0 /dev/hdb1 0
 will map the first chunk (16k) as follows:
 .RS
 .IP
- LV chunk 1 -> hda1, chunk 1
- LV chunk 2 -> hdb1, chunk 1
- LV chunk 3 -> hda1, chunk 2
- LV chunk 4 -> hdb1, chunk 2
+ LV chunk 1 \[->] hda1, chunk 1
+ LV chunk 2 \[->] hdb1, chunk 1
+ LV chunk 3 \[->] hda1, chunk 2
+ LV chunk 4 \[->] hdb1, chunk 2
  etc.
 .RE
 .TP
@@ -980,21 +981,17 @@ documentation directory for the device-mapper package.)
 .
 .SH EXAMPLES
 .
+.nf
 # A table to join two disks together
-.br
 0 1028160 linear /dev/hda 0
-.br
 1028160 3903762 linear /dev/hdb 0
-.br
+.P
 # A table to stripe across the two disks,
-.br
 # and add the spare space from
-.br
 # hdb to the back of the volume
-.br
 0 2056320 striped 2 32 /dev/hda 0 /dev/hdb 0
-.br
 2056320 2875602 linear /dev/hdb 1028160
+.fi
 .
 .SH CONCISE FORMAT
 .
@@ -1026,33 +1023,33 @@ The minor number of the device.  If empty, the kernel assigns a suitable minor n
 .TP
 .B flags
 Supported flags are:
-.sp
+.br
+.ad l
 .B ro
 Sets the table being loaded for the device read-only
 .br
 .B rw
 Sets the table being loaded for the device read-write (default)
+.ad b
 .TP
 .B table
 One line of the table. See TABLE FORMAT above.
 .
 .SH EXAMPLES
 .
-# A simple linear read-only device
-.br
+.PD 0
 .ad l
 .nh
+# A simple linear read-only device
+.TP
 test-linear-small,,,ro,\:0 2097152 linear /dev/loop0 0,\:2097152 2097152 linear /dev/loop1 0
-.hy
-.ad b
-.sp
+.P
 # Two linear devices
-.br
-.ad l
-.nh
+.TP
 test-linear-small,,,,\:0 2097152 linear /dev/loop0 0;\:test-linear-large,\:,,,\:0 2097152 linear /dev/loop1 0, 2097152 2097152 linear /dev/loop2 0
 .hy
 .ad b
+.PD
 .
 .SH ENVIRONMENT VARIABLES
 .
@@ -1079,6 +1076,10 @@ Original version: Joe Thornber <thornber@redhat.com>
 .BR udev (7),
 .BR udevadm (8)
 .P
-LVM2 resource page: https://www.sourceware.org/lvm2/
+LVM2 resource page:
+.UR https://www.sourceware.org/lvm2
+.UE
 .br
-Device-mapper resource page: http://sources.redhat.com/dm/
+Device-mapper resource page:
+.UR http://sources.redhat.com/dm
+.UE
diff --git a/man/dmstats.8_main b/man/dmstats.8_main
index f77ca05c8..bf492c554 100644
--- a/man/dmstats.8_main
+++ b/man/dmstats.8_main
@@ -90,7 +90,7 @@ dmstats \(em device-mapper statistics management
 .  ad l
 .  nh
 .  BR create
-.  IR device_name... | file_path... | \fB--alldevices
+.  IR device_name ...| file_path ...| \fB--alldevices
 .  RB [ --areas
 .  IR nr_areas | \fB--areasize
 .  IR area_size ]
@@ -334,7 +334,7 @@ groups. Normally the device-mapper filemap monitoring daemon,
 \fBdmfilemapd\fP, is started for each file mapped group to update the
 set of regions as the file changes on-disk: use of this option
 disables this behaviour.
-.P
+.sp
 Regions in the group may still be updated with the
 \fBupdate_filemap\fP command, or by starting the daemon manually.
 .
@@ -345,29 +345,29 @@ monitoring daemon can monitor files in two distinct ways: the mode
 affects the behaviour of the daemon when a file under monitoring is
 renamed or unlinked, and the conditions which cause the daemon to
 terminate.
-.P
+.sp
 The \fBfollow_mode\fP argument is either "inode", for follow-inode
 mode, or "path", for follow-path.
-.P
+.sp
 If follow-inode mode is used, the daemon will hold the file open, and
 continue to update regions from the same file descriptor. This means
 that the mapping will follow rename, move (within the same file
 system), and unlink operations. This mode is useful if the file is
 expected to be moved, renamed, or unlinked while it is being
 monitored.
-.P
+.sp
 In follow-inode mode, the daemon will exit once it detects that the
 file has been unlinked and it is the last holder of a reference to it.
-.P
+.sp
 If follow-path is used, the daemon will re-open the provided path on
 each monitoring iteration. This means that the group will be updated
 to reflect a new file being moved to the same path as the original
 file. This mode is useful for files that are expected to be updated
 via unlink and rename.
-.P
+.sp
 In follow-path mode, the daemon will exit if the file is removed and
 not replaced within a brief tolerance interval.
-.P
+.sp
 In either mode, the daemon exits automatically if the monitored group
 is removed.
 .
@@ -494,7 +494,7 @@ optional suffix selects units of:
 When used with \fBcreate\fP, create a new statistics region for each
 target contained in the given device(s). This causes a separate region
 to be allocated for each segment of the device.
-.P
+.sp
 The newly created regions are automatically placed into a group unless
 the \fB--nogroup\fP option is given. When grouping is enabled a group
 alias may be specified using the \fB--alias\fP option.
@@ -537,23 +537,23 @@ regions (with the exception of in-flight IO counters).
 .CMD_CREATE
 .br
 Creates one or more new statistics regions on the specified device(s).
-.P
+.sp
 The region will span the entire device unless \fB--start\fP and
 \fB--length\fP or \fB--segments\fP are given. The \fB--start\fP an
 \fB--length\fP options allow a region of arbitrary length to be placed
 at an arbitrary offset into the device. The \fB--segments\fP option
 causes a new region to be created for each target in the corresponding
 device-mapper device's table.
-.P
+.sp
 If the \fB--precise\fP option is used the command will attempt to
 create a region using nanosecond precision counters.
-.P
+.sp
 If \fB--bounds\fP is given a latency histogram will be tracked for
 the new region. The boundaries of the histogram bins are given as a
 comma separated list of latency values. There is an implicit lower bound
 of zero on the first bin and an implicit upper bound of infinity (or the
 configured interval duration) on the final bin.
-.P
+.sp
 Latencies are given in nanoseconds. An optional unit suffix of ns, us,
 ms, or s may be given after each value to specify units of nanoseconds,
 microseconds, miliseconds or seconds respectively, so for example, 10ms
@@ -561,19 +561,19 @@ is equivalent to 10000000. Latency values with a precision of less than
 one milisecond can only be used when precise timestamps are enabled: if
 \fB--precise\fP is not given and values less than one milisecond are
 used it will be enabled automatically.
-.P
+.sp
 An optional \fBprogram_id\fP or \fBuser_data\fP string may be associated
 with the region. A \fBprogram_id\fP may then be used to select regions
 for subsequent list, print, and report operations. The \fBuser_data\fP
 stores an arbitrary string and is not used by dmstats or the
 device-mapper kernel statistics subsystem.
-.P
+.sp
 By default dmstats creates regions with a \fBprogram_id\fP of
 "dmstats".
-.P
+.sp
 On success the \fBregion_id\fP of the newly created region is printed
 to stdout.
-.P
+.sp
 If the \fB--filemap\fP option is given with a regular file, or list
 of files, as the \fBfile_path\fP argument, instead of creating regions
 with parameters specified on the command line, \fBdmstats\fP will open
@@ -581,20 +581,20 @@ the files located at \fBfile_path\fP and create regions corresponding to
 the physical extents allocated to the file. This can be used to monitor
 statistics for individual files in the file system, for example, virtual
 machine images, swap areas, or large database files.
-.P
+.sp
 To work with the \fB--filemap\fP option, files must be located on a
 local file system, backed by a device-mapper device, that supports
 physical extent data using the FIEMAP ioctl (Ext4 and XFS for e.g.).
-.P
+.sp
 By default regions that map a file are placed into a group and the
 group alias is set to the basename of the file. This behaviour can be
 overridden with the \fB--alias\fP and \fB--nogroup\fP options.
-.P
+.sp
 Creating a group that maps a file automatically starts a daemon,
 \fBdmfilemapd\fP to monitor the file and update the mapping as the
 extents allocated to the file change. This behaviour can be disabled
 using the \fB--nomonitor\fP option.
-.P
+.sp
 Use the \fB--group\fP option to only display information for groups
 when listing and reporting.
 .
@@ -604,17 +604,17 @@ when listing and reporting.
 Delete the specified statistics region. All counters and resources used
 by the region are released and the region will not appear in the output
 of subsequent list, print, or report operations.
-.P
+.sp
 All regions registered on a device may be removed using
 \fB--allregions\fP.
-.P
+.sp
 To remove all regions on all devices both \fB--allregions\fP and
 \fB--alldevices\fP must be used.
-.P
+.sp
 If a \fB--groupid\fP is given instead of a \fB--regionid\fP the
 command will attempt to delete the group and all regions that it
 contains.
-.P
+.sp
 If a deleted region is the first member of a group of regions the group
 will also be removed.
 .
@@ -623,19 +623,19 @@ will also be removed.
 .br
 Combine one or more statistics regions on the specified device into a
 group.
-.P
+.sp
 The list of regions to be grouped is specified with \fB--regions\fP
 and an optional alias may be assigned with \fB--alias\fP. The set of
 regions is given as a comma-separated list of region identifiers. A
 continuous range of identifers spanning from \fBR1\fP to \fBR2\fP may
 be expressed as '\fBR1\fP-\fBR2\fP'.
-.P
+.sp
 Regions that have a histogram configured can be grouped: in this case
 the number of histogram bins and their bounds must match exactly.
-.P
+.sp
 On success the group list and newly created \fBgroup_id\fP are
 printed to stdout.
-.P
+.sp
 The group metadata is stored with the first (lowest numbered)
 \fBregion_id\fP in the group: deleting this region will also delete
 the group and other group members will be returned to their prior
@@ -653,20 +653,21 @@ the list of report fields.
 List the statistics regions, areas, or groups registered on the device.
 If the \fB--allprograms\fP switch is given all regions will be listed
 regardless of region program ID values.
-.P
+.sp
 By default only regions and groups are included in list output. If
 \fB-v\fP or \fB--verbose\fP is given the report will also include a
 row of information for each configured group and for each area contained
 in each region displayed.
-.P
+.sp
 Regions that contain a single area are by default omitted from the
 verbose list since their properties are identical to the area that they
 contain - to view all regions regardless of the number of areas present
 use \fB--region\fP). To also view the areas contained within regions
 use \fB--area\fP.
-.P
+.sp
 If \fB--histogram\fP is given the report will include the bin count
 and latency boundary values for any configured histograms.
+.
 .HP
 .CMD_PRINT
 .br
@@ -680,16 +681,16 @@ Start a report for the specified object or for all present objects. If
 the count argument is specified, the report will repeat at a fixed
 interval set by the \fB--interval\fP option. The default interval is
 one second.
-.P
+.sp
 If the \fB--allprograms\fP switch is given, all regions will be
 listed, regardless of region program ID values.
-.P
+.sp
 If the \fB--histogram\fP is given the report will include the histogram
 values and latency boundaries.
-.P
+.sp
 If the \fB--relative\fP is used the default histogram field displays
 bin values as a percentage of the total number of I/Os.
-.P
+.sp
 Object types (areas, regions and groups) to include in the report are
 selected using the \fB--area\fP, \fB--region\fP, and \fB--group\fP
 options.
@@ -699,27 +700,28 @@ options.
 .br
 Remove an existing group and return all the group's regions to their
 original state.
-.P
+.sp
 The group to be removed is specified using \fB--groupid\fP.
+.
 .HP
 .CMD_UPDATE_FILEMAP
 .br
 Update a group of \fBdmstats\fP regions specified by \fBgroup_id\fP,
 that were previously created with \fB--filemap\fP, either directly,
 or by starting the monitoring daemon, \fBdmfilemapd\fP.
-.P
+.sp
 This will add and remove regions to reflect changes in the allocated
 extents of the file on-disk, since the time that it was crated or last
 updated.
-.P
+.sp
 Use of this command is not normally needed since the \fBdmfilemapd\fP
 daemon will automatically monitor filemap groups and perform these
 updates when required.
-.P
+.sp
 If a filemapped group was created with \fB--nomonitor\fP, or the
 daemon has been killed, the \fBupdate_filemap\fP can be used to
 manually force an update or start a new daemon.
-.P
+.sp
 Use \fB--nomonitor\fP to force a direct update and disable starting
 the monitoring daemon.
 .
@@ -1229,9 +1231,13 @@ Bryn M. Reeves <bmr@redhat.com>
 .
 .BR dmsetup (8)
 .P
-LVM2 resource page: https://www.sourceware.org/lvm2/
+LVM2 resource page:
+.UR https://www.sourceware.org/lvm2
+.UE
 .br
-Device-mapper resource page: http://sources.redhat.com/dm/
+Device-mapper resource page:
+.UR http://sources.redhat.com/dm
+.UE
 .P
 Device-mapper statistics kernel documentation
 .br
diff --git a/man/lvconvert.8_des b/man/lvconvert.8_des
index 6fd1ed9cd..cc233fb1d 100644
--- a/man/lvconvert.8_des
+++ b/man/lvconvert.8_des
@@ -67,5 +67,5 @@ Striped raid types support converting the layout, their stripesize and
 their number of stripes.
 
 The striped raid types combined with raid1 allow for conversion from
-linear -> striped/raid0/raid0_meta and vice-versa by e.g. linear <-> raid1
-<-> raid5_n (then adding stripes) <-> striped/raid0/raid0_meta.
+linear \[->] striped/raid0/raid0_meta and vice-versa by e.g. linear \[<>] raid1
+\[<>] raid5_n (then adding stripes) \[<>] striped/raid0/raid0_meta.
diff --git a/man/lvcreate.8_end b/man/lvcreate.8_end
index 19e24610a..9be3426da 100644
--- a/man/lvcreate.8_end
+++ b/man/lvcreate.8_end
@@ -66,7 +66,7 @@ to the first image).
 
 Create a 1TiB thin LV mythin, with 256GiB thinpool tpool0 in vg00.
 .br
-.B lvcreate --T --size 256G --name mythin vg00/tpool0
+.B lvcreate -T -V 1T --size 256G --name mythin vg00/tpool0
 
 Create a 1TiB thin LV, first creating a new thin pool for it, where
 the thin pool has 100MiB of space, uses 2 stripes, has a 64KiB stripe
diff --git a/man/lvm.8_main b/man/lvm.8_main
index 08af2ee33..509a635ef 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -258,7 +258,7 @@ The valid characters for VG and LV names are:
 .BR a - z
 .BR A - Z
 .BR 0 - 9
-.BR "+ _ . -"
+.B + _ . -
 .P
 VG names cannot begin with a hyphen.
 The name of a new LV also cannot begin with a hyphen.  However, if the
@@ -274,11 +274,31 @@ argument.)
 .P
 There are also various reserved names that are used internally by lvm that can
 not be used as LV or VG names. A VG cannot be called anything that exists in
-\fI/dev/\fP at the time of creation, nor can it be called '.' or '..'.
-An LV cannot be called '.', '..', 'snapshot' or 'pvmove'.
+\fI/dev/\fP at the time of creation, nor can it be called
+.RB ' . '
+or
+.RB ' .. '.
+An LV cannot be called
+.RB ' . ',
+.RB ' .. ',
+.RB ' snapshot '
+or
+.RB ' pvmove '.
 The LV name may also not contain any of the following strings:
-\fR'_cdata', '_cmeta', '_corig', '_mlog', '_mimage', '_pmspare',
-\fR'_rimage', '_rmeta', '_tdata', '_tmeta', '_vorigin' or '_vdata'.
+.RB ' _cdata ',
+.RB ' _cmeta ',
+.RB ' _corig ',
+.RB ' _mimage ',
+.RB ' _mlog ',
+.RB ' _pmspare ',
+.RB ' _rimage ',
+.RB ' _rmeta ',
+.RB ' _tdata ',
+.RB ' _tmeta ',
+.RB ' _vdata ',
+.RB ' _vorigin '
+or
+.RB ' _wcorig '.
 A directory bearing the name of each Volume Group is created under
 \fI/dev\fP when any of its Logical Volumes are activated.
 Each active Logical Volume is accessible from this directory as a symbolic
diff --git a/man/lvm.conf.5_main b/man/lvm.conf.5_main
index 63945ea2f..4289a94d6 100644
--- a/man/lvm.conf.5_main
+++ b/man/lvm.conf.5_main
@@ -1,4 +1,4 @@
-.TH LVM.CONF 5 "LVM TOOLS #VERSION#" "Red Hat, Inc." \" -*- nroff -*-
+.TH LVM.CONF 5 "LVM TOOLS #VERSION#" "Red Hat, Inc."
 .
 .SH NAME
 .
@@ -6,7 +6,7 @@ lvm.conf \(em Configuration file for LVM2
 .
 .SH SYNOPSIS
 .
-.B #DEFAULT_SYS_DIR#/lvm.conf
+.I #DEFAULT_SYS_DIR#/lvm.conf
 .
 .SH DESCRIPTION
 .
@@ -16,7 +16,7 @@ being loaded - settings read in later override earlier
 settings.  File timestamps are checked between commands and if
 any have changed, all the files are reloaded.
 .P
-For a description of each lvm.conf setting, run:
+For a description of each \fBlvm.conf\fP(5) setting, run:
 .P
 .B lvmconfig --typeconfig default --withcomments --withspaces
 .P
@@ -97,11 +97,11 @@ When several configuration methods are used at the same time
 and when LVM looks for the value of a particular setting, it traverses
 this \fBconfig cascade\fP from left to right:
 .P
-\fBdirect config override on command line\fP ->
-\fBcommand profile config\fP ->
-\fBmetadata profile config\fP ->
-\fBtag config\fP ->
-\fBlvmlocal.conf\fP ->
+\fBdirect config override on command line\fP \[->]
+\fBcommand profile config\fP \[->]
+\fBmetadata profile config\fP \[->]
+\fBtag config\fP \[->]
+\fBlvmlocal.conf\fP \[->]
 \fBlvm.conf\fP
 .P
 No part of this cascade is compulsory. If there's no setting value found at
@@ -214,9 +214,9 @@ e.g. umask:
 .br
 .I #DEFAULT_CACHE_DIR#/.cache
 .br
-.I #DEFAULT_LOCK_DIR#
-.br
 .I #DEFAULT_PROFILE_DIR#
+.br
+.I #DEFAULT_LOCK_DIR#
 .
 .SH SEE ALSO
 .
diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 20463a548..48cf7b492 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -341,7 +341,8 @@ caching the main LV.
 .nf
 # lvcreate -n fast -L DataSize vg /dev/fast_ssd1
 # lvcreate -n fastmeta -L MetadataSize vg /dev/fast_ssd2
-# lvconvert --type cache --cachepool fast --poolmetadata fastmeta vg/main
+# lvconvert --type cache --cachepool fast \\
+        --poolmetadata fastmeta vg/main
 .fi
 .
 .SS dm-cache cache modes
@@ -397,7 +398,7 @@ Command to display the chunk size:
 .B lvs -o+chunksize VG/LV
 .P
 .BR lvm.conf (5)
-.B cache_pool_chunk_size
+.B allocation/cache_pool_chunk_size
 .P
 controls the default chunk size.
 .P
@@ -470,7 +471,7 @@ defines the default cache settings.
 .
 Cache pools allows to set a variety of options. Lots of these settings
 can be specified in lvm.conf or profile settings. You can prepare
-a number of different profiles in the #DEFAULT_SYS_DIR#/profile directory
+a number of different profiles in the \fI#DEFAULT_SYS_DIR#/profile\fP directory
 and just specify the metadata profile file name when caching LV or creating cache-pool.
 Check the output of \fBlvmconfig --type default --withcomments\fP
 for a detailed description of all individual cache settings.
@@ -479,22 +480,31 @@ for a detailed description of all individual cache settings.
 .nf
 # cat <<EOF > #DEFAULT_SYS_DIR#/profile/cache_big_chunk.profile
 allocation {
-	cache_pool_metadata_require_separate_pvs=0
-	cache_pool_chunk_size=512
-	cache_metadata_format=2
-	cache_mode="writethrough"
-	cache_policy="smq"
-	cache_settings {
-		smq {
-			migration_threshold=8192
-			random_threshold=4096
-		}
-	}
+.RS
+cache_pool_metadata_require_separate_pvs=0
+cache_pool_chunk_size=512
+cache_metadata_format=2
+cache_mode="writethrough"
+cache_policy="smq"
+cache_settings {
+.RS
+smq {
+.RS
+migration_threshold=8192
+random_threshold=4096
+.RE
+}
+.RE
+}
+.RE
 }
 EOF
 .P
-# lvcreate --cache -L10G --metadataprofile cache_big_chunk vg/main  /dev/fast_ssd
-# lvcreate --cache -L10G --config 'allocation/cache_pool_chunk_size=512' vg/main /dev/fast_ssd
+
+# lvcreate --cache -L10G --metadataprofile cache_big_chunk vg/main \\
+        /dev/fast_ssd
+# lvcreate --cache -L10G vg/main --config \\
+        'allocation/cache_pool_chunk_size=512' /dev/fast_ssd
 .fi
 .
 .SS dm-cache spare metadata LV
@@ -538,7 +548,7 @@ or the longer variant
 .P
 .nf
 # lvcreate --type cache --size CacheDataSize \\
-	--name NameCachePool VG/LV [FastPVs]
+        --name NameCachePool VG/LV [FastPVs]
 .fi
 .P
 In this command, the specified LV already exists, and is the main LV to be
@@ -575,6 +585,6 @@ and the existing main LV is being converted to type cache.)
 .BR vgreduce (8),
 .BR vgsplit (8),
 .P
-.BR cache_dump (8),
 .BR cache_check (8),
+.BR cache_dump (8),
 .BR cache_repair (8)
diff --git a/man/lvmdevices.8_des b/man/lvmdevices.8_des
index a04a66683..52885fb59 100644
--- a/man/lvmdevices.8_des
+++ b/man/lvmdevices.8_des
@@ -1,5 +1,5 @@
 The LVM devices file lists devices that lvm can use.  The default file is
-/etc/lvm/devices/system.devices, and the lvmdevices(8) command is used to
+\fI#DEFAULT_SYS_DIR#/devices/system.devices\fP, and the \fBlvmdevices\fP(8) command is used to
 add or remove device entries.  If the file does not exist, or if lvm.conf
 includes use_devicesfile=0, then lvm will not use a devices file.
 
@@ -34,7 +34,7 @@ overriding the devices file.  The listed devices act as a sort of devices
 file in terms of limiting which devices lvm will see and use.  Devices
 that are not listed will appear to be missing to the lvm command.
     
-Multiple devices files can be kept in /etc/lvm/devices, which allows lvm
+Multiple devices files can be kept in \fI#DEFAULT_SYS_DIR#/devices\fP, which allows lvm
 to be used with different sets of devices, e.g. system devices do not need
 to be exposed to a specific application, and the application can use lvm on
 its own devices that are not exposed to the system.  The option
diff --git a/man/lvmdump.8_main b/man/lvmdump.8_main
index 1fa6d817d..22675905d 100644
--- a/man/lvmdump.8_main
+++ b/man/lvmdump.8_main
@@ -32,15 +32,15 @@ dmsetup info
 .IP \[bu]
 table of currently running processes
 .IP \[bu]
-recent entries from /var/log/messages (containing system messages)
+recent entries from \fI/var/log/messages\fP (containing system messages)
 .IP \[bu]
-complete lvm configuration and cache (content of #DEFAULT_SYS_DIR#)
+complete lvm configuration and cache (content of \fI#DEFAULT_SYS_DIR#\fP)
 .IP \[bu]
-list of device nodes present under /dev
+list of device nodes present under \fI/dev\fP
 .IP \[bu]
-list of files present /sys/block
+list of files present \fI/sys/block\fP
 .IP \[bu]
-list of files present /sys/devices/virtual/block
+list of files present \fI/sys/devices/virtual/block\fP
 .IP \[bu]
 if enabled with -m, metadata dump will be also included
 .IP \[bu]
@@ -99,9 +99,9 @@ controlling LVM functionality and the content of systemd journal for
 current boot.
 .TP
 .B -u
-Gather udev info and context: /etc/udev/udev.conf file, udev daemon version
+Gather udev info and context: \fI/etc/udev/udev.conf\fP file, udev daemon version
 (output of 'udevadm info --version' command), udev rules currently used in the system
-(content of /lib/udev/rules.d and /etc/udev/rules.d directory),
+(content of \fI/lib/udev/rules.d\fP and \fI/etc/udev/rules.d\fP directory),
 list of files in /lib/udev directory and dump of current udev
 database content (the output of 'udevadm info --export-db' command).
 .
@@ -110,13 +110,17 @@ database content (the output of 'udevadm info --export-db' command).
 .TP
 .B LVM_BINARY
 The LVM2 binary to use.
-Defaults to "lvm".
-Sometimes you might need to set this to "#LVM_PATH#.static", for example.
+Defaults to "\fBlvm\fP".
+Sometimes you might need to set this to "\fI#LVM_PATH#.static\fP", for example.
 .TP
 .B DMSETUP_BINARY
 The dmsetup binary to use.
-Defaults to "dmsetup".
+Defaults to "\fBdmsetup\fP".
 .
 .SH SEE ALSO
 .
-.BR lvm (8)
+.BR lvm (8),
+.BR lvmpolld (8),
+.P
+.BR udev (8),
+.BR udevadm (8)
diff --git a/man/lvmlockctl.8_main b/man/lvmlockctl.8_main
index 8b7b00977..d5b9e927c 100644
--- a/man/lvmlockctl.8_main
+++ b/man/lvmlockctl.8_main
@@ -61,54 +61,54 @@ Stop all lockspaces.
 .
 .SH USAGE
 .
-.SS info
-.
+.TP
+.B --info
 This collects and displays lock state from lvmlockd.  The display is
 primitive, incomplete and will change in future version.  To print the raw
 lock state from lvmlockd, combine this option with --dump|-d.
 .
-.SS dump
-.
+.TP
+.B --dump
 This collects the circular log buffer of debug statements from lvmlockd
 and prints it.
 .
-.SS kill
-.
+.TP
+.B --kill
 This is run by sanlock when it loses access to the storage holding leases
 for a VG.  It runs the command specified in lvm.conf
 lvmlockctl_kill_command to deactivate LVs in the VG.  If the specified
 command is successful, locks will be dropped for the VG in lvmlockd
-(the equivalent of lvmlockctl --drop will be run.)  If no command
+(the equivalent of \fBlvmlockctl --drop\fP will be run.)  If no command
 is specified, or the command fails, then the user must intervene
 to forcefully deactivate LVs in the VG, and if successful, run
-lvmlockctl --drop.  For more, see
+\fBlvmlockctl --drop\fP.  For more, see
 .BR lvmlockd (8).
 .
-.SS drop
-.
+.TP
+.B --drop
 This should only be run after a VG has been successfully deactivated
 following an lvmlockctl --kill command.  It clears the stale lockspace
 from lvmlockd.  When lvmlockctl_kill_command is used, the --kill
 command may run drop automatically.  For more, see
 .BR lvmlockd (8).
 .
-.SS gl-enable
-.
+.TP
+.B --gl-enable
 This enables the global lock in a sanlock VG.  This is necessary if the VG
 that previously held the global lock is removed.  For more, see
 .BR lvmlockd (8).
 .
-.SS gl-disable
-.
+.TP
+.B --gl-disable
 This disables the global lock in a sanlock VG.  This is necessary if the
 global lock has mistakenly been enabled in more than one VG.  The global
 lock should be disabled in all but one sanlock VG.  For more, see
 .BR lvmlockd (8).
 .
-.SS stop-lockspaces
-.
+.TP
+.B --stop-lockspaces
 This tells lvmlockd to stop all lockspaces.  It can be useful to stop
-lockspaces for VGs that the vgchange --lock-stop comand can no longer
+lockspaces for VGs that the \fBvgchange --lock-stop\fP command can no longer
 see, or to stop the dlm global lockspace which is not directly stopped by
 the vgchange command.  The wait and force options can be used with this
 command.
diff --git a/man/lvmpolld.8_main b/man/lvmpolld.8_main
index 885c4a2ea..a8d99c9cd 100644
--- a/man/lvmpolld.8_main
+++ b/man/lvmpolld.8_main
@@ -68,14 +68,14 @@ and is equivalent to a comma-separated list \fB-l wire,debug\fP.
 .TP
 .BR -p | --pidfile " " \fIpidfile_path
 Path to the pidfile. This overrides both the built-in default
-(#DEFAULT_PID_DIR#/lvmpolld.pid) and the environment variable
+(\fI#DEFAULT_PID_DIR#/lvmpolld.pid\fP) and the environment variable
 \fBLVM_LVMPOLLD_PIDFILE\fP.  This file is used to prevent more
 than one instance of the daemon running simultaneously.
 .
 .TP
 .BR -s | --socket " " \fIsocket_path
 Path to the socket file. This overrides both the built-in default
-(#DEFAULT_RUN_DIR#/lvmpolld.socket) and the environment variable
+(\fI#DEFAULT_RUN_DIR#/lvmpolld.socket\fP) and the environment variable
 \fBLVM_LVMPOLLD_SOCKET\fP.
 .
 .TP
@@ -85,7 +85,7 @@ option is omitted or the value given is zero the daemon never shutdowns on idle.
 .
 .TP
 .BR -B | --binary " " \fIlvm_binary_path
-Optional path to alternative LVM binary (default: #LVM_PATH#). Use for
+Optional path to alternative LVM binary (default: \fI#LVM_PATH#\fP). Use for
 testing purposes only.
 .
 .TP
diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index 0a9d4698f..8dc023cfe 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -870,7 +870,7 @@ To change these values globally, edit
 To change these values on a per-VG or per-LV basis, attach a "profile" to
 the VG or LV.  A profile is a collection of config settings, saved in a
 local text file (using the lvm.conf format).  lvm looks for profiles in
-the profile_dir directory, e.g. #DEFAULT_SYS_DIR#/profile/.  Once attached to a VG
+the profile_dir directory, e.g. \fI#DEFAULT_SYS_DIR#/profile/\fP.  Once attached to a VG
 or LV, lvm will process the VG or LV using the settings from the attached
 profile.  A profile is named and referenced by its file name.
 .P
@@ -901,8 +901,10 @@ profile_dir="#DEFAULT_SYS_DIR#/profile"
 .P
 # cat #DEFAULT_SYS_DIR#/profile/pool0extend.profile
 activation {
-        thin_pool_autoextend_threshold=50
-        thin_pool_autoextend_percent=10
+.RS
+thin_pool_autoextend_threshold=50
+thin_pool_autoextend_percent=10
+.RE
 }
 .P
 # lvchange --metadataprofile pool0extend vg/pool0
diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 7bc27b189..3b77173c4 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -12,7 +12,8 @@ for primary storage.
 .P
 Deduplication is a technique for reducing the consumption of storage
 resources by eliminating multiple copies of duplicate blocks. Compression
-takes the individual unique blocks and shrinks them. These reduced blocks are then efficiently packed together into
+takes the individual unique blocks and shrinks them. 
+These reduced blocks are then efficiently packed together into
 physical blocks. Thin provisioning manages the mapping from logical blocks
 presented by VDO to where the data has actually been physically stored,
 and also eliminates any blocks of all zeroes.
@@ -135,7 +136,7 @@ that can keep 100% incompressible data there.
 .
 VDO allows to set a large variety of options. Lots of these settings
 can be specified in lvm.conf or profile settings. You can prepare
-a number of different profiles in the #DEFAULT_SYS_DIR#/profile directory
+a number of different profiles in the \fI#DEFAULT_SYS_DIR#/profile\fP directory
 and just specify the profile file name.
 Check the output of \fBlvmconfig --type default --withcomments\fP
 for a detailed description of all individual VDO settings.
@@ -144,25 +145,27 @@ for a detailed description of all individual VDO settings.
 .nf
 # cat <<EOF > #DEFAULT_SYS_DIR#/profile/vdo_create.profile
 allocation {
-	vdo_use_compression=1
-	vdo_use_deduplication=1
-	vdo_use_metadata_hints=1
-	vdo_minimum_io_size=4096
-	vdo_block_map_cache_size_mb=128
-	vdo_block_map_period=16380
-	vdo_check_point_frequency=0
-	vdo_use_sparse_index=0
-	vdo_index_memory_size_mb=256
-	vdo_slab_size_mb=2048
-	vdo_ack_threads=1
-	vdo_bio_threads=1
-	vdo_bio_rotation=64
-	vdo_cpu_threads=2
-	vdo_hash_zone_threads=1
-	vdo_logical_threads=1
-	vdo_physical_threads=1
-	vdo_write_policy="auto"
-	vdo_max_discard=1
+.RS
+vdo_use_compression=1
+vdo_use_deduplication=1
+vdo_use_metadata_hints=1
+vdo_minimum_io_size=4096
+vdo_block_map_cache_size_mb=128
+vdo_block_map_period=16380
+vdo_check_point_frequency=0
+vdo_use_sparse_index=0
+vdo_index_memory_size_mb=256
+vdo_slab_size_mb=2048
+vdo_ack_threads=1
+vdo_bio_threads=1
+vdo_bio_rotation=64
+vdo_cpu_threads=2
+vdo_hash_zone_threads=1
+vdo_logical_threads=1
+vdo_physical_threads=1
+vdo_write_policy="auto"
+vdo_max_discard=1
+.RE
 }
 EOF
 .P
@@ -175,7 +178,7 @@ EOF
 Disable or enable the compression and deduplication for VDOPoolLV
 (the volume that maintains all VDO LV(s) associated with it).
 .P
-.B lvchange --compression [y|n] --deduplication [y|n] VG/VDOPoolLV
+.B lvchange --compression y|n --deduplication y|n VG/VDOPoolLV
 .P
 .I Example
 .nf
@@ -191,7 +194,7 @@ in the content of the virtual data for the VDOLV and how much space is already
 consumed with all the data and metadata blocks in the VDOPoolLV.
 For a detailed description, use the \fBvdostats\fP(8) command.
 .P
-Note: \fBvdostats\fP(8) currently understands only /dev/mapper device names.
+Note: \fBvdostats\fP(8) currently understands only \fI/dev/mapper\fP device names.
 .P
 .I Example
 .nf
@@ -218,11 +221,11 @@ You can add more space to hold VDO data and metadata by
 extending the VDODataLV using the commands
 \fBlvresize\fP(8) and \fBlvextend\fP(8).
 The extension needs to add at least one new VDO slab. You can configure
-the slab size with the \fBallocation/vdo_slab_size_mb\fP setting.
+the slab size with the \fB\%allocation/\:vdo_slab_size_mb\fP setting.
 .P
 You can also enable automatic size extension of a monitored VDOPoolLV
 with the \fBactivation/vdo_pool_autoextend_percent\fP and
-\fBactivation/vdo_pool_autoextend_threshold\fP settings.
+\fB\%activation/\:vdo_pool_autoextend_threshold\fP settings.
 .P
 Note: You cannot reduce the size of a VDOPoolLV.
 .P
@@ -287,9 +290,9 @@ Using a raid type LV for a VDODataLV.
 # lvconvert --type vdo-pool -V 10G vg/vdopool
 .fi
 .
-.SS \n+[step]. Caching a VDODataLV or a VDOPoolLV
+.SS \n+[step]. Caching a VDOPoolLV
 .
-VDODataLV (accepts also VDOPoolLV) caching provides a mechanism
+VDOPoolLV (accepts also VDODataLV volume name) caching provides a mechanism
 to accelerate reads and writes of already compressed and deduplicated
 data blocks together with VDO metadata.
 .P
diff --git a/man/lvs.8_end b/man/lvs.8_end
index 5a4ecc83c..6fdb80459 100644
--- a/man/lvs.8_end
+++ b/man/lvs.8_end
@@ -2,81 +2,81 @@
 .
 The lv_attr bits are:
 .IP 1 3
-Volume type: (C)ache, (m)irrored, (M)irrored without initial sync, (o)rigin,
-(O)rigin with merging snapshot, (r)aid, (R)aid without initial sync,
-(s)napshot, merging (S)napshot, (p)vmove, (v)irtual,
-mirror or raid (i)mage, mirror or raid (I)mage out-of-sync, mirror (l)og device,
-under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data,
-v(d)o pool, v(D)o pool data,
-raid or pool m(e)tadata or pool metadata spare.
+Volume type: (\fBC\fP)ache, (\fBm\fP)irrored, (\fBM\fP)irrored without initial sync, (\fBo\fP)rigin,
+(\fBO\fP)rigin with merging snapshot, (\fBr\fP)aid, (\fBR\fP)aid without initial sync,
+(\fBs\fP)napshot, merging (\fBS\fP)napshot, (\fBp\fP)vmove, (\fBv\fP)irtual,
+mirror or raid (\fBi\fP)mage, mirror or raid (\fBI\fP)mage out-of-sync, mirror (\fBl\fP)og device,
+under (\fBc\fP)onversion, thin (\fBV\fP)olume, (\fBt\fP)hin pool, (\fBT\fP)hin pool data,
+v(\fBd\fP)o pool, v(\fBD\fP)o pool data,
+raid or pool m(\fBe\fP)tadata or pool metadata spare.
 .IP 2 3
-Permissions: (w)riteable, (r)ead-only, (R)ead-only activation of non-read-only
+Permissions: (\fBw\fP)riteable, (\fBr\fP)ead-only, (\fBR\fP)ead-only activation of non-read-only
 volume
 .IP 3 3
-Allocation policy:  (a)nywhere, (c)ontiguous, (i)nherited, c(l)ing, (n)ormal
+Allocation policy:  (\fBa\fP)nywhere, (\fBc\fP)ontiguous, (\fBi\fP)nherited, c(\fBl\fP)ing, (\fBn\fP)ormal
 This is capitalised if the volume is currently locked against allocation
 changes, for example during
 .BR pvmove (8).
 .IP 4 3
-fixed (m)inor
+fixed (\fBm\fP)inor
 .IP 5 3
-State: (a)ctive, (h)istorical, (s)uspended, (I)nvalid snapshot,
-invalid (S)uspended snapshot, snapshot (m)erge failed,
-suspended snapshot (M)erge failed, mapped (d)evice present without tables,
-mapped device present with (i)nactive table, thin-pool (c)heck needed,
-suspended thin-pool (C)heck needed, (X) unknown
+State: (\fBa\fP)ctive, (\fBh\fP)istorical, (\fBs\fP)uspended, (\fBI\fP)nvalid snapshot,
+invalid (\fBS\fP)uspended snapshot, snapshot (\fBm\fP)erge failed,
+suspended snapshot (\fBM\fP)erge failed, mapped (\fBd\fP)evice present without tables,
+mapped device present with (\fBi\fP)nactive table, thin-pool (\fBc\fP)heck needed,
+suspended thin-pool (\fBC\fP)heck needed, (\fBX\fP) unknown
 .IP 6 3
-device (o)pen, (X) unknown
+device (\fBo\fP)pen, (\fBX\fP) unknown
 .IP 7 3
-Target type: (C)ache, (m)irror, (r)aid, (s)napshot, (t)hin, (u)nknown, (v)irtual.
+Target type: (\fBC\fP)ache, (\fBm\fP)irror, (\fBr\fP)aid, (\fBs\fP)napshot, (\fBt\fP)hin, (\fBu\fP)nknown, (\fBv\fP)irtual.
 This groups logical volumes related to the same kernel target together.  So,
 for example, mirror images, mirror logs as well as mirrors themselves appear as
-(m) if they use the original device-mapper mirror kernel driver; whereas the raid
-equivalents using the md raid kernel driver all appear as (r).
-Snapshots using the original device-mapper driver appear as (s); whereas
-snapshots of thin volumes using the new thin provisioning driver appear as (t).
+(\fBm\fP) if they use the original device-mapper mirror kernel driver; whereas the raid
+equivalents using the md raid kernel driver all appear as (\fBr\fP).
+Snapshots using the original device-mapper driver appear as (\fBs\fP); whereas
+snapshots of thin volumes using the new thin provisioning driver appear as (\fBt\fP).
 .IP 8 3
-Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
+Newly-allocated data blocks are overwritten with blocks of (\fBz\fP)eroes before use.
 .IP 9 3
 Volume Health, where there are currently three groups of attributes identified:
 .IP
-Common ones for all Logical Volumes: (p)artial, (X) unknown.
+Common ones for all Logical Volumes: (\fBp\fP)artial, (\fBX\fP) unknown.
 .br
-(p)artial signifies that one or more of the Physical Volumes this Logical
-Volume uses is missing from the system. (X) unknown signifies the status
+(\fBp\fP)artial signifies that one or more of the Physical Volumes this Logical
+Volume uses is missing from the system. (\fBX\fP) unknown signifies the status
 is unknown.
 .IP
-Related to RAID Logical Volumes: (r)efresh needed, (m)ismatches exist, (w)ritemostly.
+Related to RAID Logical Volumes: (\fBr\fP)efresh needed, (\fBm\fP)ismatches exist, (\fBw\fP)ritemostly.
 .br
-(r)efresh signifies that one or more of the Physical Volumes this RAID Logical
+(\fBr\fP)efresh signifies that one or more of the Physical Volumes this RAID Logical
 Volume uses had suffered a write error. The write error could be due to a
 temporary failure of that Physical Volume or an indication that it is failing.
-The device should be refreshed or replaced. (m)ismatches signifies that the
+The device should be refreshed or replaced. (\fBm\fP)ismatches signifies that the
 RAID logical volume has portions of the array that are not coherent.
 Inconsistencies are detected by initiating a "check" on a RAID logical volume.
 (The scrubbing operations, "check" and "repair", can be performed on a RAID
-logical volume via the 'lvchange' command.)  (w)ritemostly signifies the
+logical volume via the 'lvchange' command.)  (\fBw\fP)ritemostly signifies the
 devices in a RAID 1 logical volume that have been marked write-mostly.
-Re(s)haping signifies a RAID Logical Volume is either undergoing a stripe
+Re(\fBs\fP)haping signifies a RAID Logical Volume is either undergoing a stripe
 addition/removal, a stripe size or RAID algorithm change.
-(R)emove after reshape signifies freed striped raid images to be removed.
+(\fBR\fP)emove after reshape signifies freed striped raid images to be removed.
 .IP
-Related to Thin pool Logical Volumes: (F)ailed, out of (D)ata space,
-(M)etadata read only.
+Related to Thin pool Logical Volumes: (\fBF\fP)ailed, out of (\fBD\fP)ata space,
+(\fBM\fP)etadata read only.
 .br
-(F)ailed is set if thin pool encounters serious failures and hence no further I/O
-is permitted at all. The out of (D)ata space is set if thin pool has run out of
-data space. (M)etadata read only signifies that thin pool encounters certain
+(\fBF\fP)ailed is set if thin pool encounters serious failures and hence no further I/O
+is permitted at all. The out of (\fBD\fP)ata space is set if thin pool has run out of
+data space. (\fBM\fP)etadata read only signifies that thin pool encounters certain
 types of failures but it's still possible to do reads at least,
 but no metadata changes are allowed.
 .IP
-Related to Thin Logical Volumes: (F)ailed.
+Related to Thin Logical Volumes: (\fBF\fP)ailed.
 .br
-(F)ailed is set when related thin pool enters Failed state and no further I/O
+(\fBF\fP)ailed is set when related thin pool enters Failed state and no further I/O
 is permitted at all.
 .IP
-Related to writecache logical volumes: (E)rror.
+Related to writecache logical volumes: (\fBE\fP)rror.
 .br
-(E)rror is set dm-writecache reports an error.
+(\fBE\fP)rror is set dm-writecache reports an error.
 .IP 10 3
-s(k)ip activation: this volume is flagged to be skipped during activation.
+s(\fBk\fP)ip activation: this volume is flagged to be skipped during activation.
diff --git a/man/pvck.8_des b/man/pvck.8_des
index b87345e3a..1d9b30a02 100644
--- a/man/pvck.8_des
+++ b/man/pvck.8_des
@@ -48,7 +48,7 @@ Save the entire text metadata area to a file without processing.
 .B --repair
 .br
 Repair headers and metadata on a PV.  This uses a metadata input file that
-was extracted by --dump, or a backup file (from /etc/lvm/backup).  When
+was extracted by --dump, or a backup file (from \fI#DEFAULT_BACKUP_DIR#\fP).  When
 possible, use metadata saved by --dump from another PV in the same VG (or
 from a second metadata area on the PV).
 
diff --git a/man/pvs.8_end b/man/pvs.8_end
index e47d8e889..c18f5518b 100644
--- a/man/pvs.8_end
+++ b/man/pvs.8_end
@@ -2,8 +2,8 @@
 .
 The pv_attr bits are:
 .IP 1 3
-(d)uplicate, (a)llocatable, (u)sed
+(\fBd\fP)uplicate, (\fBa\fP)llocatable, (\fBu\fP)sed
 .IP 2 3
-e(x)ported
+e(\fBx\fP)ported
 .IP 3 3
-(m)issing
+(\fBm\fP)issing
diff --git a/man/see_also.end b/man/see_also.end
index dbe4bc1c1..e740ce588 100644
--- a/man/see_also.end
+++ b/man/see_also.end
@@ -1,11 +1,13 @@
+.
 .SH SEE ALSO
+.
 .nh
 .ad l
 .BR lvm (8),
 .BR lvm.conf (5),
 .BR lvmconfig (8),
 .BR lvmdevices (8),
-
+.P
 .BR pvchange (8),
 .BR pvck (8),
 .BR pvcreate (8),
@@ -15,7 +17,7 @@
 .BR pvresize (8),
 .BR pvs (8),
 .BR pvscan (8),
-
+.P
 .BR vgcfgbackup (8),
 .BR vgcfgrestore (8),
 .BR vgchange (8),
@@ -36,7 +38,7 @@
 .BR vgs (8),
 .BR vgscan (8),
 .BR vgsplit (8),
-
+.P
 .BR lvcreate (8),
 .BR lvchange (8),
 .BR lvconvert (8),
@@ -48,20 +50,20 @@
 .BR lvresize (8),
 .BR lvs (8),
 .BR lvscan (8),
-
+.P
 .BR lvm-fullreport (8),
 .BR lvm-lvpoll (8),
 .BR lvm2-activation-generator (8),
 .BR blkdeactivate (8),
 .BR lvmdump (8),
-
+.P
 .BR dmeventd (8),
 .BR lvmpolld (8),
 .BR lvmlockd (8),
 .BR lvmlockctl (8),
 .BR cmirrord (8),
 .BR lvmdbusd (8),
-
+.P
 .BR lvmsystemid (7),
 .BR lvmreport (7),
 .BR lvmraid (7),
diff --git a/man/vgs.8_end b/man/vgs.8_end
index 09ece2b0d..06699187c 100644
--- a/man/vgs.8_end
+++ b/man/vgs.8_end
@@ -2,15 +2,15 @@
 .
 The vg_attr bits are:
 .IP 1 3
-Permissions: (w)riteable, (r)ead-only
+Permissions: (\fBw\fP)riteable, (\fBr\fP)ead-only
 .IP 2 3
-Resi(z)eable
+Resi(\fBz\fP)eable
 .IP 3 3
-E(x)ported
+E(\fBx\fP)ported
 .IP 4 3
-(p)artial: one or more physical volumes belonging to the volume group
+(\fBp\fP)artial: one or more physical volumes belonging to the volume group
 are missing from the system
 .IP 5 3
-Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
+Allocation policy: (\fBc\fP)ontiguous, c(\fBl\fP)ing, (\fBn\fP)ormal, (\fBa\fP)nywhere
 .IP 6 3
-(c)lustered, (s)hared
+(\fBc\fP)lustered, (\fBs\fP)hared


