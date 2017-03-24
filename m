From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 23 Mar 2017 21:48:38 -0400
Subject: master - man: escape all single '-'
Message-ID: <201703240148.v2O1mcLN018511@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5eec3de41f6860bbbc45e5929ddcf7d584c6e75b
Commit:        5eec3de41f6860bbbc45e5929ddcf7d584c6e75b
Parent:        93467f0d9f08333a7b7c9e0e112a9c9df454f887
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 24 02:46:11 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 24 02:46:11 2017 +0100

man: escape all single '-'

---
 man/blkdeactivate.8_main             |   16 +-
 man/clvmd.8_main                     |    8 +-
 man/cmirrord.8_main                  |    2 +-
 man/dmeventd.8_main                  |    8 +-
 man/dmfilemapd.8_main                |   16 +-
 man/dmsetup.8_main                   |   64 ++++----
 man/dmstats.8_main                   |  102 +++++-----
 man/lvm.8_main                       |   20 +-
 man/lvm.conf.5_main                  |   12 +-
 man/lvm2-activation-generator.8_main |   24 ++--
 man/lvmcache.7_main                  |   40 ++--
 man/lvmconf.8_main                   |   20 +-
 man/lvmdbusd.8_main                  |    6 +-
 man/lvmdump.8_main                   |    2 +-
 man/lvmetad.8_main                   |    4 +-
 man/lvmlockd.8_main                  |   18 +-
 man/lvmpolld.8_main                  |    6 +-
 man/lvmraid.7_main                   |  334 +++++++++++++++++-----------------
 man/lvmreport.7_main                 |   90 +++++-----
 man/lvmsadc.8_main                   |    2 +-
 man/lvmsar.8_main                    |    2 +-
 man/lvmsystemid.7_main               |   16 +-
 man/lvmthin.7_main                   |  142 +++++++-------
 23 files changed, 477 insertions(+), 477 deletions(-)

diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index 89f48ba..fbfd025 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -15,15 +15,15 @@ blkdeactivate \(em utility to deactivate block devices
 The blkdeactivate utility deactivates block devices. For mounted
 block devices, it attempts to unmount it automatically before
 trying to deactivate. The utility currently supports
-device-mapper devices (DM), including LVM volumes and
+device\-mapper devices (DM), including LVM volumes and
 software RAID MD devices. LVM volumes are handled directly
-using the \fBlvm\fP(8) command, the rest of device-mapper
+using the \fBlvm\fP(8) command, the rest of device\-mapper
 based devices are handled using the \fBdmsetup\fP(8) command.
 MD devices are handled using the \fBmdadm\fP(8) command.
 .SH OPTIONS
 .TP
 .BR \-d ", " \-\-dmoption \ \fIdm_options\fP
-Comma separated list of device-mapper specific options.
+Comma separated list of device\-mapper specific options.
 Accepted \fBdmsetup\fP(8) options are:
 .RS
 .IP \fIretry\fP
@@ -42,7 +42,7 @@ the device was skipped.
 Display the help text.
 .TP
 .BR \-l ", " \-\-lvmoption \ \fIlvm_options\fP
-Comma-separated list of LVM specific options:
+Comma\-separated list of LVM specific options:
 .RS
 .IP \fIretry\fP
 Retry removal several times in case of failure.
@@ -53,12 +53,12 @@ each Logical Volume separately.
 .RE
 .TP
 .BR \-m ", " \-\-mpathoption \ \fImpath_options\fP
-Comma-separated list of device-mapper multipath specific options:
+Comma\-separated list of device\-mapper multipath specific options:
 .RS
 .IP \fIdisablequeueing\fP
 Disable queueing on all multipath devices before deactivation.
 This avoids a situation where blkdeactivate may end up waiting if
-all the paths are unavailable for any underlying device-mapper multipath
+all the paths are unavailable for any underlying device\-mapper multipath
 device.
 .RE
 .TP
@@ -92,7 +92,7 @@ any mounted devices first, if possible.
 .BR
 .P
 Deactivate all supported block devices found in the system. If the deactivation
-of a device-mapper device fails, retry it. Deactivate the whole
+of a device\-mapper device fails, retry it. Deactivate the whole
 Volume Group at once when processing an LVM Logical Volume.
 .BR
 #
@@ -100,7 +100,7 @@ Volume Group at once when processing an LVM Logical Volume.
 .BR
 .P
 Deactivate all supported block devices found in the system. If the deactivation
-of a device-mapper device fails, retry it and force removal.
+of a device\-mapper device fails, retry it and force removal.
 .BR
 #
 .B blkdeactivate \-d force,retry
diff --git a/man/clvmd.8_main b/man/clvmd.8_main
index e629665..2e027c5 100644
--- a/man/clvmd.8_main
+++ b/man/clvmd.8_main
@@ -42,9 +42,9 @@ Tells all clvmds in a cluster to enable/disable debug logging.
 Without this switch, only the local clvmd will change its debug level to that
 given with \fB\-d\fP.
 .br
-This does not work correctly if specified on the command-line that starts clvmd.
+This does not work correctly if specified on the command\-line that starts clvmd.
 If you want to start clvmd \fBand\fP
-enable cluster-wide logging then the command needs to be issued twice, eg:
+enable cluster\-wide logging then the command needs to be issued twice, eg:
 .br
 .BR clvmd
 .br
@@ -94,7 +94,7 @@ communications. As it is quite possible to have multiple managers available on
 the same system you might have to manually specify this option to override the
 search.
 
-By default, omit \fB-I\fP is equivalent to \fB\-Iauto\fP.
+By default, omit \fB\-I\fP is equivalent to \fB\-Iauto\fP.
 Clvmd will use the first cluster manager that succeeds,
 and it checks them in a predefined order
 .BR cman ,
@@ -107,7 +107,7 @@ The available managers will be listed by order as part of the
 .BR \-R
 .br
 Tells all the running instance of \fBclvmd\fP in the cluster to reload their device cache and
-re-read the lvm configuration file \fBlvm.conf\fP(5). This command should be run whenever the
+re\-read the lvm configuration file \fBlvm.conf\fP(5). This command should be run whenever the
 devices on a cluster system are changed.
 .
 .HP
diff --git a/man/cmirrord.8_main b/man/cmirrord.8_main
index ad604c7..dab13cc 100644
--- a/man/cmirrord.8_main
+++ b/man/cmirrord.8_main
@@ -7,7 +7,7 @@ cmirrord \(em cluster mirror log daemon
 
 .SH DESCRIPTION
 \fBcmirrord\fP is the daemon that tracks mirror log information in a cluster.
-It is specific to device-mapper based mirrors (and by extension, LVM
+It is specific to device\-mapper based mirrors (and by extension, LVM
 cluster mirrors).  Cluster mirrors are not possible without this daemon
 running.
 
diff --git a/man/dmeventd.8_main b/man/dmeventd.8_main
index c3b6954..0c1bb81 100644
--- a/man/dmeventd.8_main
+++ b/man/dmeventd.8_main
@@ -2,7 +2,7 @@
 .
 .SH NAME
 .
-dmeventd \(em Device-mapper event daemon
+dmeventd \(em Device\-mapper event daemon
 .
 .SH SYNOPSIS
 .
@@ -19,7 +19,7 @@ dmeventd \(em Device-mapper event daemon
 .
 .SH DESCRIPTION
 .
-dmeventd is the event monitoring daemon for device-mapper devices.
+dmeventd is the event monitoring daemon for device\-mapper devices.
 Library plugins can register and carry out actions triggered when
 particular events occur.
 .
@@ -106,7 +106,7 @@ of the thin pool is filled. See
 When a thin pool fills over 50% (data or metadata) thin plugin calls
 configured \fIdmeventd/thin_command\fP with every 5% increase.
 With default setting it calls internal
-\fBlvm lvextend \-\-use-policies\fP to resize thin pool
+\fBlvm lvextend \-\-use\-policies\fP to resize thin pool
 when it's been filled above configured threshold
 \fIactivation/thin_pool_autoextend_threshold\fP.
 If the command fails, dmeventd thin plugin will keep
@@ -116,7 +116,7 @@ User may also configure external command to support more advanced
 maintenance operations of a thin pool.
 Such external command can e.g. remove some unneeded snapshots,
 use \fBfstrim\fP(8) to free recover space in a thin pool,
-but also can use \fBlvextend \-\-use-policies\fP if other actions
+but also can use \fBlvextend \-\-use\-policies\fP if other actions
 have not released enough space.
 Command is executed with environmental variable
 \fBLVM_RUN_BY_DMEVENTD=1\fP so any lvm2 command executed
diff --git a/man/dmfilemapd.8_main b/man/dmfilemapd.8_main
index 8e19e4b..c782025 100644
--- a/man/dmfilemapd.8_main
+++ b/man/dmfilemapd.8_main
@@ -21,7 +21,7 @@
 .
 .SH NAME
 .
-dmfilemapd \(em device-mapper filemap monitoring daemon
+dmfilemapd \(em device\-mapper filemap monitoring daemon
 .
 .SH SYNOPSIS
 .
@@ -44,7 +44,7 @@ dmfilemapd \(em device-mapper filemap monitoring daemon
 .
 The dmfilemapd daemon monitors groups of \fIdmstats\fP regions that
 correspond to the extents of a file, adding and removing regions to
-reflect the changing state of the file on-disk.
+reflect the changing state of the file on\-disk.
 
 The daemon is normally launched automatically by the \fPdmstats
 create\fP command, but can be run manually, either to create a new
@@ -86,8 +86,8 @@ and the \fBmode\fP option for more information.
 .br
 The filemap monitoring mode the daemon should use: either "inode"
 (\fBDM_FILEMAP_FOLLOW_INODE\fP), or "path"
-(\fBDM_FILEMAP_FOLLOW_PATH\fP), to enable follow-inode or
-follow-path mode respectively.
+(\fBDM_FILEMAP_FOLLOW_PATH\fP), to enable follow\-inode or
+follow\-path mode respectively.
 .
 .HP
 .BR [foreground]
@@ -130,7 +130,7 @@ within the file system, while it is being monitored.
 .B Follow path
 .P
 The daemon follows the path that was given on the daemon command
-line. The file descriptor referencing the file is re-opened on each
+line. The file descriptor referencing the file is re\-opened on each
 iteration of the daemon, and the daemon will exit if no file exists
 at this location (a tolerance is allowed so that a brief delay
 between removal and replacement is permitted).
@@ -164,13 +164,13 @@ Normally the daemon is started automatically by the \fBdmstats\fP
 \fBcreate\fP or \fBupdate_filemap\fP commands but it can be run
 manually for debugging or testing purposes.
 .P
-Start the daemon in the background, in follow-path mode
+Start the daemon in the background, in follow\-path mode
 .br
 #
 .B dmfilemapd 3 0 /srv/images/vm.img path 0 0 3< /srv/images/vm.img
 .br
 .P
-Start the daemon in follow-inode mode, disable forking and enable
+Start the daemon in follow\-inode mode, disable forking and enable
 verbose logging
 .br
 #
@@ -208,5 +208,5 @@ Bryn M. Reeves <bmr@redhat.com>
 
 LVM2 resource page: https://www.sourceware.org/lvm2/
 .br
-Device-mapper resource page: http://sources.redhat.com/dm/
+Device\-mapper resource page: http://sources.redhat.com/dm/
 .br
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 4261fc4..e03b50c 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -373,7 +373,7 @@ dmsetup \(em low level logical volume management
 .
 .SH DESCRIPTION
 .
-dmsetup manages logical devices that use the device-mapper driver.
+dmsetup manages logical devices that use the device\-mapper driver.
 Devices are created by loading a table that specifies a target for
 each sector (512 bytes) in the logical device.
 
@@ -450,7 +450,7 @@ The default interval is one second.
 .BR auto | hex | none
 .br
 Mangle any character not on a whitelist using mangling_mode when
-processing device-mapper device names and UUIDs. The names and UUIDs
+processing device\-mapper device names and UUIDs. The names and UUIDs
 are mangled on input and unmangled on output where the mangling mode
 is one of:
 \fBauto\fP (only do the mangling if not mangled yet, do nothing
@@ -458,7 +458,7 @@ if already mangled, error on mixed),
 \fBhex\fP (always do the mangling) and
 \fBnone\fP (no mangling).
 Default mode is \fB#DEFAULT_MANGLING#\fP.
-Character whitelist: 0-9, A-Z, a-z, #+-.:=@_. This whitelist is
+Character whitelist: 0-9, A\-Z, a\-z, #+-.:=@_. This whitelist is
 also supported by udev. Any character not on a whitelist is replaced
 with its hex value (two digits) prefixed by \\x.
 Mangling mode could be also set through
@@ -499,7 +499,7 @@ Suppress the headings line when using columnar output.
 .HP
 .BR \-\-noflush
 Do not flush outstading I/O when suspending a device, or do not
-commit thin-pool metadata when obtaining thin-pool status.
+commit thin\-pool metadata when obtaining thin\-pool status.
 .
 .HP
 .BR \-\-nolockfs
@@ -514,7 +514,7 @@ Tell the kernel not to supply the open reference count for the device.
 .HP
 .BR \-\-noudevrules
 .br
-Do not allow udev to manage nodes for devices in device-mapper directory.
+Do not allow udev to manage nodes for devices in device\-mapper directory.
 .
 .HP
 .BR \-\-noudevsync
@@ -541,14 +541,14 @@ The value \fBnone\fP is equivalent to specifying zero.
 .HP
 .BR \-r | \-\-readonly
 .br
-Set the table being loaded read-only.
+Set the table being loaded read\-only.
 .
 .HP
 .BR \-S | \-\-select
 .IR selection
 .br
 Display only rows that match \fIselection\fP criteria. All rows are displayed
-with the additional "selected" column (\fB-o selected\fP) showing 1 if the row
+with the additional "selected" column (\fB\-o selected\fP) showing 1 if the row
 matches the \fIselection\fP and 0 otherwise. The selection criteria are defined
 by specifying column names and their valid values while making use of
 supported comparison operators. As a quick help and to see full list of
@@ -560,7 +560,7 @@ command.
 .BR \-\-table
 .IR table
 .br
-Specify a one-line table directly on the command line.
+Specify a one\-line table directly on the command line.
 See below for more information on the table format.
 .
 .HP
@@ -626,7 +626,7 @@ Outputs a list of devices referenced by the live table for the specified
 device. Device names on output can be customised by following \fIoptions\fP:
 \fBdevno\fP (major and minor pair, used by default),
 \fBblkdevname\fP (block device name),
-\fBdevname\fP (map name for device-mapper devices, equal to blkdevname otherwise).
+\fBdevname\fP (map name for device\-mapper devices, equal to blkdevname otherwise).
 .
 .HP
 .CMD_HELP
@@ -640,7 +640,7 @@ the list of report fields.
 Outputs some brief information about the device in the form:
 .RS
 .RS
- State: SUSPENDED|ACTIVE, READ-ONLY
+ State: SUSPENDED|ACTIVE, READ\-ONLY
  Tables present: LIVE and/or INACTIVE
  Open reference count
  Last event sequence number (used by \fBwait\fP)
@@ -653,7 +653,7 @@ Outputs some brief information about the device in the form:
 .CMD_INFOLONG
 .br
 Output you can customise.
-Fields are comma-separated and chosen from the following list:
+Fields are comma\-separated and chosen from the following list:
 .BR name ,
 .BR major ,
 .BR minor ,
@@ -666,11 +666,11 @@ Attributes are:
 .RI ( L )ive,
 .RI ( I )nactive,
 .RI ( s )uspended,
-.RI ( r )ead-only,
-.RI read-( w )rite.
+.RI ( r )ead\-only,
+.RI read\-( w )rite.
 Precede the list with '\fB+\fP' to append
 to the default selection of columns instead of replacing it.
-Precede any sort field with '\fB-\fP' for a reverse sort on that column.
+Precede any sort field with '\fB\-\fP' for a reverse sort on that column.
 .
 .HP
 .CMD_LS
@@ -681,9 +681,9 @@ each device.  The device name is appended to the supplied command.
 Device names on output can be customised by following options:
 \fBdevno\fP (major and minor pair, used by default),
 \fBblkdevname\fP (block device name),
-\fBdevname\fP (map name for device-mapper devices, equal to blkdevname otherwise).
+\fBdevname\fP (map name for device\-mapper devices, equal to blkdevname otherwise).
 \fB\-\-tree\fP displays dependencies between devices as a tree.
-It accepts a comma-separate list of \fIoptions\fP.
+It accepts a comma\-separate list of \fIoptions\fP.
 Some specify the information displayed against each node:
 .BR device / nodevice ;
 .BR blkdevname ;
@@ -702,7 +702,7 @@ If neither is supplied, reads a table from standard input.
 .HP
 .CMD_MANGLE
 .br
-Ensure existing device-mapper \fIdevice_name\fP and UUID is in the correct mangled
+Ensure existing device\-mapper \fIdevice_name\fP and UUID is in the correct mangled
 form containing only whitelisted characters (supported by udev) and do
 a rename if necessary. Any character not on the whitelist will be mangled
 based on the \fB\-\-manglename\fP setting. Automatic rename works only for device
@@ -721,7 +721,7 @@ Send message to target. If sector not needed use 0.
 .br
 Ensure that the node in \fI/dev/mapper\fP for \fIdevice_name\fP is correct.
 If no device_name is supplied, ensure that all nodes in \fI/dev/mapper\fP
-correspond to mapped devices currently loaded by the device-mapper kernel
+correspond to mapped devices currently loaded by the device\-mapper kernel
 driver, adding, changing or removing nodes as necessary.
 .
 .HP
@@ -731,7 +731,7 @@ Removes a device.  It will no longer be visible to dmsetup.  Open devices
 cannot be removed, but adding \fB\-\-force\fP will replace the table with one
 that fails all I/O.  \fB\-\-deferred\fP will enable deferred removal of open
 devices - the device will be removed when the last user closes it. The deferred
-removal feature is supported since version 4.27.0 of the device-mapper
+removal feature is supported since version 4.27.0 of the device\-mapper
 driver available in upstream kernel version 3.13.  (Use \fBdmsetup version\fP
 to check this.)  If an attempt to remove a device fails, perhaps because a process run
 from a quick udev rule temporarily opened the device, the \fB\-\-retry\fP
@@ -749,7 +749,7 @@ Attempts to remove all device definitions i.e. reset the driver.  This also runs
 adding \fB\-\-force\fP will replace the table with one that fails all I/O.
 \fB\-\-deferred\fP will enable deferred removal of open devices - the device
 will be removed when the last user closes it.  The deferred removal feature is
-supported since version 4.27.0 of the device-mapper driver available in
+supported since version 4.27.0 of the device\-mapper driver available in
 upstream kernel version 3.13.
 .
 .HP
@@ -766,9 +766,9 @@ After a uuid has been set it cannot be changed.
 .HP
 .CMD_RESUME
 .br
-Un-suspends a device.
+Un\-suspends a device.
 If an inactive table has been loaded, it becomes live.
-Postponed I/O then gets re-queued for processing.
+Postponed I/O then gets re\-queued for processing.
 .
 .HP
 .CMD_SETGEOMETRY
@@ -828,7 +828,7 @@ displayed always.
 .HP
 .CMD_TARGETS
 .br
-Displays the names and versions of the currently-loaded targets.
+Displays the names and versions of the currently\-loaded targets.
 .
 .HP
 .CMD_UDEVCOMPLETE
@@ -844,7 +844,7 @@ Any process waiting on a cookie will be resumed immediately.
 .HP
 .CMD_UDEVCOOKIES
 .br
-List all existing cookies. Cookies are system-wide semaphores with keys
+List all existing cookies. Cookies are system\-wide semaphores with keys
 prefixed by two predefined bytes (0x0D4D).
 .
 .HP
@@ -858,7 +858,7 @@ cookie instead. We can define a cookie to use for each relevant command by using
 \fB\-\-udevcookie\fP option. Alternatively, we can export this value into the environment
 of the dmsetup process as \fBDM_UDEV_COOKIE\fP variable and it will be used automatically
 with all subsequent commands until it is unset.
-Invoking this command will create system-wide semaphore that needs to be cleaned
+Invoking this command will create system\-wide semaphore that needs to be cleaned
 up explicitly by calling udevreleasecookie command.
 .
 .HP
@@ -897,7 +897,7 @@ any outstanding changes to disk before reporting its statistics.
 .HP
 .CMD_WIPE_TABLE
 .br
-Wait for any I/O in-flight through the device to complete, then
+Wait for any I/O in\-flight through the device to complete, then
 replace the table with a new table that fails any new I/O
 sent to the device.  If successful, this should release any devices
 held open by the device's table(s).
@@ -937,8 +937,8 @@ for creating devices with holes in them.
 .TP
 .B zero
 Returns blocks of zeroes on reads.  Any data written is discarded silently.
-This is a block-device equivalent of the \fI/dev/zero\fP
-character-device data sink described in \fBnull\fP(4).
+This is a block\-device equivalent of the \fI/dev/zero\fP
+character\-device data sink described in \fBnull\fP(4).
 .P
 More complex targets include:
 .TP
@@ -969,14 +969,14 @@ Offers an interface to the kernel's software raid driver, md.
 .B snapshot
 Supports snapshots of devices.
 .TP
-.BR thin ", " thin-pool
+.BR thin ", " thin\-pool
 Supports thin provisioning of devices and also provides a better snapshot support.
 .P
 To find out more about the various targets and their table formats and status
-lines, please read the files in the Documentation/device-mapper directory in
+lines, please read the files in the Documentation/device\-mapper directory in
 the kernel source tree.
 (Your distribution might include a copy of this information in the
-documentation directory for the device-mapper package.)
+documentation directory for the device\-mapper package.)
 .
 .SH EXAMPLES
 .
@@ -1023,4 +1023,4 @@ Original version: Joe Thornber <thornber@redhat.com>
 .P
 LVM2 resource page: https://www.sourceware.org/lvm2/
 .br
-Device-mapper resource page: http://sources.redhat.com/dm/
+Device\-mapper resource page: http://sources.redhat.com/dm/
diff --git a/man/dmstats.8_main b/man/dmstats.8_main
index e7e8203..b1dda64 100644
--- a/man/dmstats.8_main
+++ b/man/dmstats.8_main
@@ -40,7 +40,7 @@
 .
 .SH NAME
 .
-dmstats \(em device-mapper statistics management
+dmstats \(em device\-mapper statistics management
 .
 .SH SYNOPSIS
 .
@@ -235,7 +235,7 @@ dmstats \(em device-mapper statistics management
 .SH DESCRIPTION
 .
 The dmstats program manages IO statistics regions for devices that use
-the device-mapper driver. Statistics regions may be created, deleted,
+the device\-mapper driver. Statistics regions may be created, deleted,
 listed and reported on using the tool.
 
 The first argument to dmstats is a \fIcommand\fP.
@@ -247,7 +247,7 @@ Further options permit the selection of regions, output format
 control, and reporting behaviour.
 
 When no device argument is given dmstats will by default operate on all
-device-mapper devices present. The \fBcreate\fP and \fBdelete\fP
+device\-mapper devices present. The \fBcreate\fP and \fBdelete\fP
 commands require the use of \fB\-\-alldevices\fP when used in this way.
 .
 .SH OPTIONS
@@ -320,16 +320,16 @@ results.
 .br
 Instead of creating regions on a device as specified by command line
 options, open the file found at each \fBfile_path\fP argument, and
-create regions corresponding to the locations of the on-disk extents
+create regions corresponding to the locations of the on\-disk extents
 allocated to the file(s).
 .
 .HP
 .BR \-\-nomonitor
 .br
 Disable the \fBdmfilemapd\fP daemon when creating new file mapped
-groups. Normally the device-mapper filemap monitoring daemon,
+groups. Normally the device\-mapper filemap monitoring daemon,
 \fBdmfilemapd\fP, is started for each file mapped group to update the
-set of regions as the file changes on-disk: use of this option
+set of regions as the file changes on\-disk: use of this option
 disables this behaviour.
 
 Regions in the group may still be updated with the
@@ -345,26 +345,26 @@ affects the behaviour of the daemon when a file under monitoring is
 renamed or unlinked, and the conditions which cause the daemon to
 terminate.
 
-The \fBfollow_mode\fP argument is either "inode", for follow-inode
-mode, or "path", for follow-path.
+The \fBfollow_mode\fP argument is either "inode", for follow\-inode
+mode, or "path", for follow\-path.
 
-If follow-inode mode is used, the daemon will hold the file open, and
+If follow\-inode mode is used, the daemon will hold the file open, and
 continue to update regions from the same file descriptor. This means
 that the mapping will follow rename, move (within the same file
 system), and unlink operations. This mode is useful if the file is
 expected to be moved, renamed, or unlinked while it is being
 monitored.
 
-In follow-inode mode, the daemon will exit once it detects that the
+In follow\-inode mode, the daemon will exit once it detects that the
 file has been unlinked and it is the last holder of a reference to it.
 
-If follow-path is used, the daemon will re-open the provided path on
+If follow\-path is used, the daemon will re\-open the provided path on
 each monitoring iteration. This means that the group will be updated
 to reflect a new file being moved to the same path as the original
 file. This mode is useful for files that are expected to be updated
 via unlink and rename.
 
-In follow-path mode, the daemon will exit if the file is removed and
+In follow\-path mode, the daemon will exit if the file is removed and
 not replaced within a brief tolerance interval.
 
 In either mode, the daemon exits automatically if the monitored group
@@ -462,7 +462,7 @@ Specify which report fields to display.
 .IR sort_fields
 .br
 Sort output according to the list of fields given. Precede any
-sort field with '\fB-\fP' for a reverse sort on that column.
+sort field with '\fB\-\fP' for a reverse sort on that column.
 .
 .HP
 .BR \-\-precise
@@ -477,7 +477,7 @@ statistics regions.
 Specify a program ID string. When creating new statistics regions this
 string is stored with the region. Subsequent operations may supply a
 program ID in order to select only regions with a matching value. The
-default program ID for dmstats-managed regions is "dmstats".
+default program ID for dmstats\-managed regions is "dmstats".
 .
 .HP
 .BR \-\-region
@@ -495,7 +495,7 @@ Specify the region to operate on.
 .BR \-\-regions
 .IR region_list
 .br
-Specify a list of regions to group. The group list is a comma-separated
+Specify a list of regions to group. The group list is a comma\-separated
 list of region identifiers. Continuous sequences of identifiers may be
 expressed as a hyphen separated range, for example: '1-10'.
 .
@@ -544,7 +544,7 @@ alias may be specified using the \fB\-\-alias\fP option.
 .br
 Set the display units for report output.
 All sizes are output in these units:
-.RB ( h )uman-readable,
+.RB ( h )uman\-readable,
 .HELP_UNITS
 Can also specify custom units e.g. \fB\-\-units\ 3M\fP.
 .
@@ -573,7 +573,7 @@ Produce additional output.
 .CMD_CLEAR
 .br
 Instructs the kernel to clear statistics counters for the speficied
-regions (with the exception of in-flight IO counters).
+regions (with the exception of in\-flight IO counters).
 .
 .HP
 .CMD_CREATE
@@ -585,7 +585,7 @@ The region will span the entire device unless \fB\-\-start\fP and
 \fB\-\-length\fP options allow a region of arbitrary length to be placed
 at an arbitrary offset into the device. The \fB\-\-segments\fP option
 causes a new region to be created for each target in the corresponding
-device-mapper device's table.
+device\-mapper device's table.
 
 If the \fB\-\-precise\fP option is used the command will attempt to
 create a region using nanosecond precision counters.
@@ -608,7 +608,7 @@ An optional \fBprogram_id\fP or \fBuser_data\fP string may be associated
 with the region. A \fBprogram_id\fP may then be used to select regions
 for subsequent list, print, and report operations. The \fBuser_data\fP
 stores an arbitrary string and is not used by dmstats or the
-device-mapper kernel statistics subsystem.
+device\-mapper kernel statistics subsystem.
 
 By default dmstats creates regions with a \fBprogram_id\fP of
 "dmstats".
@@ -625,7 +625,7 @@ statistics for individual files in the file system, for example, virtual
 machine images, swap areas, or large database files.
 
 To work with the \fB\-\-filemap\fP option, files must be located on a
-local file system, backed by a device-mapper device, that supports
+local file system, backed by a device\-mapper device, that supports
 physical extent data using the FIEMAP ioctl (Ext4 and XFS for e.g.).
 
 By default regions that map a file are placed into a group and the
@@ -668,9 +668,9 @@ group.
 
 The list of regions to be grouped is specified with \fB\-\-regions\fP
 and an optional alias may be assigned with \fB\-\-alias\fP. The set of
-regions is given as a comma-separated list of region identifiers. A
+regions is given as a comma\-separated list of region identifiers. A
 continuous range of identifers spanning from \fBR1\fP to \fBR2\fP may
-be expressed as '\fBR1\fP-\fBR2\fP'.
+be expressed as '\fBR1\fP\-\fBR2\fP'.
 
 Regions that have a histogram configured can be grouped: in this case
 the number of histogram bins and their bounds must match exactly.
@@ -751,7 +751,7 @@ that were previously created with \fB\-\-filemap\fP, either directly,
 or by starting the monitoring daemon, \fBdmfilemapd\fP.
 
 This will add and remove regions to reflect changes in the allocated
-extents of the file on-disk, since the time that it was crated or last
+extents of the file on\-disk, since the time that it was crated or last
 updated.
 
 Use of this command is not normally needed since the \fBdmfilemapd\fP
@@ -767,10 +767,10 @@ the monitoring daemon.
 .
 .SH REGIONS, AREAS, AND GROUPS
 .
-The device-mapper statistics facility allows separate performance
+The device\-mapper statistics facility allows separate performance
 counters to be maintained for arbitrary regions of devices. A region may
 span any range: from a single sector to the whole device. A region may
-be further sub-divided into a number of distinct areas (one or more),
+be further sub\-divided into a number of distinct areas (one or more),
 each with its own counter set. In this case a summary value for the
 entire region is also available for use in reports.
 
@@ -793,10 +793,10 @@ location on the device.
 Using offsets it is possible to create regions that map individual
 objects within a block device (for example: partitions, files in a file
 system, or stripes or other structures in a RAID volume). Groups allow
-several non-contiguous regions to be assembled together for reporting
+several non\-contiguous regions to be assembled together for reporting
 and data aggregation.
 
-A region may be either divided into the specified number of equal-sized
+A region may be either divided into the specified number of equal\-sized
 areas, or into areas of the given size by specifying one of
 \fB\-\-areas\fP or \fB\-\-areasize\fP when creating a region with the
 \fBcreate\fP command. Depending on the size of the areas and the device
@@ -829,12 +829,12 @@ reference the group.
 .
 Using \fB\-\-filemap\fP, it is possible to create regions that
 correspond to the extents of a file in the file system. This allows
-IO statistics to be monitored on a per-file basis, for example to
+IO statistics to be monitored on a per\-file basis, for example to
 observe large database files, virtual machine images, or other files
 of interest.
 
 To be able to use file mapping, the file must be backed by a
-device-mapper device, and in a file system that supports the FIEMAP
+device\-mapper device, and in a file system that supports the FIEMAP
 ioctl (and which returns data describing the physical location of
 extents). This currently includes \fBxfs(5)\fP and \fBext4(5)\fP.
 
@@ -854,29 +854,29 @@ either manually or automatically.
 .B File follow modes
 .P
 The file map monitoring daemon can monitor files in two distinct ways:
-follow-inode mode, and follow-path mode.
+follow\-inode mode, and follow\-path mode.
 
 The mode affects the behaviour of the daemon when a file under
 monitoring is renamed or unlinked, and the conditions which cause the
 daemon to terminate.
 
-If follow-inode mode is used, the daemon will hold the file open, and
+If follow\-inode mode is used, the daemon will hold the file open, and
 continue to update regions from the same file descriptor. This means
 that the mapping will follow rename, move (within the same file
 system), and unlink operations. This mode is useful if the file is
 expected to be moved, renamed, or unlinked while it is being
 monitored.
 
-In follow-inode mode, the daemon will exit once it detects that the
+In follow\-inode mode, the daemon will exit once it detects that the
 file has been unlinked and it is the last holder of a reference to it.
 
-If follow-path is used, the daemon will re-open the provided path on
+If follow\-path is used, the daemon will re\-open the provided path on
 each monitoring iteration. This means that the group will be updated
 to reflect a new file being moved to the same path as the original
 file. This mode is useful for files that are expected to be updated
 via unlink and rename.
 
-In follow-path mode, the daemon will exit if the file is removed and
+In follow\-path mode, the daemon will exit if the file is removed and
 not replaced within a brief tolerance interval (one second).
 
 To stop the daemon, delete the group containing the mapped regions:
@@ -884,8 +884,8 @@ the daemon will automatically shut down.
 
 The daemon can also be safely killed at any time and the group kept:
 if the file is still being allocated the mapping will become
-progressively out-of-date as extents are added and removed (in this
-case the daemon can be re-started or the group updated manually with
+progressively out\-of\-date as extents are added and removed (in this
+case the daemon can be re\-started or the group updated manually with
 the \fBupdate_filemap\fP command).
 
 See the \fBcreate\fP command and \fB\-\-filemap\fP, \fB\-\-follow\fP,
@@ -899,7 +899,7 @@ extents and the regions contained in the group, however, since it can
 only react to new allocations once they have been written, there are
 inevitably some IO events that cannot be counted when a file is
 growing, particularly if the file is being extended by a single thread
-writing beyond end-of-file (for example, the \fBdd\fP program).
+writing beyond end\-of\-file (for example, the \fBdd\fP program).
 
 There is a further loss of events in that there is currently no way
 to atomically resize a \fBdmstats\fP region and preserve its current
@@ -917,7 +917,7 @@ these limitations when kernel support is available.
 The dmstats report provides several types of field that may be added to
 the default field set, or used to create custom reports.
 
-All performance counters and metrics are calculated per-area.
+All performance counters and metrics are calculated per\-area.
 .
 .SS Derived metrics
 .
@@ -979,7 +979,7 @@ identifier, start, length, and counts, as well as the program ID and
 user data values.
 .TP
 .B region_id
-Region identifier. This is a non-negative integer returned by the kernel
+Region identifier. This is a non\-negative integer returned by the kernel
 when a statistics region is created.
 .TP
 .B region_start
@@ -991,7 +991,7 @@ The length of the region. Display units are selected by the
 \fB\-\-units\fP option.
 .TP
 .B area_id
-Area identifier. Area identifiers are assigned by the device-mapper
+Area identifier. Area identifiers are assigned by the device\-mapper
 statistics library and uniquely identify each area within a region. Each
 ID corresponds to a distinct set of performance counters for that area
 of the statistics region. Area identifiers are always monotonically
@@ -1017,7 +1017,7 @@ The program ID value associated with this region.
 The user data value associated with this region.
 .TP
 .B group_id
-Group identifier. This is a non-negative integer returned by the dmstats
+Group identifier. This is a non\-negative integer returned by the dmstats
 \fBgroup\fP command when a statistics group is created.
 .TP
 .B interval_ns
@@ -1139,7 +1139,7 @@ indicating the unit.
 .B hist_ranges
 A list of the histogram bin ranges for the current statistics area in
 order of ascending latency value.  The values are expressed as
-"LOWER-UPPER" in whole units of seconds, miliseconds, microseconds or
+"LOWER\-UPPER" in whole units of seconds, miliseconds, microseconds or
 nanoseconds with a suffix indicating the unit.
 .TP
 .B hist_bins
@@ -1147,7 +1147,7 @@ The number of latency histogram bins configured for the area.
 .
 .SH EXAMPLES
 .
-Create a whole-device region with one area on vg00/lvol1
+Create a whole\-device region with one area on vg00/lvol1
 .br
 #
 .B dmstats create vg00/lvol1
@@ -1161,7 +1161,7 @@ Create a 32M region 1G into device d0
 .br
 d0: Created new region with 1 area(s) as region ID 0
 .P
-Create a whole-device region with 8 areas on every device
+Create a whole\-device region with 8 areas on every device
 .br
 .br
 #
@@ -1185,7 +1185,7 @@ Delete all regions on all devices
 #
 .B dmstats delete \-\-alldevices \-\-allregions
 .P
-Create a whole-device region with areas 10GiB in size on vg00/lvol1
+Create a whole\-device region with areas 10GiB in size on vg00/lvol1
 using dmsetup
 .br
 .br
@@ -1225,11 +1225,11 @@ Display five statistics reports for vg00/lvol1 at an interval of one second
 .br
 Name             RgID  ArID  AStart ASize  RRqM/s   WRqM/s   R/s   W/s    RSz/s WSz/s   AvRqSz  QSize Util%      AWait RdAWa WrAWa
 .br
-vg_hex-lv_home       0     0      0 61.00g     0.00     0.00  0.00 218.00     0   1.04m   4.50k  2.97      81.70 13.62  0.00 13.62
+vg_hex\-lv_home       0     0      0 61.00g     0.00     0.00  0.00 218.00     0   1.04m   4.50k  2.97      81.70 13.62  0.00 13.62
 .br
-vg_hex-lv_home       1     0 61.00g 19.20g     0.00     0.00  0.00   5.00     0 548.00k 109.50k  0.14      11.00 27.40  0.00 27.40
+vg_hex\-lv_home       1     0 61.00g 19.20g     0.00     0.00  0.00   5.00     0 548.00k 109.50k  0.14      11.00 27.40  0.00 27.40
 .br
-vg_hex-lv_home       2     0 80.20g  2.14g     0.00     0.00  0.00  14.00     0   1.15m  84.00k  0.39      18.70 27.71  0.00 27.71
+vg_hex\-lv_home       2     0 80.20g  2.14g     0.00     0.00  0.00  14.00     0   1.15m  84.00k  0.39      18.70 27.71  0.00 27.71
 .P
 Create one region for reach target contained in device vg00/lvol1
 .br
@@ -1276,9 +1276,9 @@ Bryn M. Reeves <bmr@redhat.com>
 
 LVM2 resource page: https://www.sourceware.org/lvm2/
 .br
-Device-mapper resource page: http://sources.redhat.com/dm/
+Device\-mapper resource page: http://sources.redhat.com/dm/
 .br
 
-Device-mapper statistics kernel documentation
+Device\-mapper statistics kernel documentation
 .br
-.I Documentation/device-mapper/statistics.txt
+.I Documentation/device\-mapper/statistics.txt
diff --git a/man/lvm.8_main b/man/lvm.8_main
index aa80d05..a1da382 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -11,7 +11,7 @@ lvm \(em LVM2 tools
 .
 .SH DESCRIPTION
 .
-lvm provides the command-line tools for LVM2.  A separate
+lvm provides the command\-line tools for LVM2.  A separate
 manual page describes each command in detail.
 .P
 If \fBlvm\fP is invoked with no arguments it presents a readline prompt
@@ -38,7 +38,7 @@ but a VG is given, a list of all the LVs in that VG will be substituted.
 So \fBlvdisplay vg0\fP will display all the LVs in "vg0".
 Tags can also be used - see \fB\-\-addtag\fP below.
 .P
-One advantage of using the built-in shell is that configuration
+One advantage of using the built\-in shell is that configuration
 information gets cached internally between commands.
 .P
 A file containing a simple script with one command per line
@@ -49,7 +49,7 @@ path of \fBlvm\fP.
 Additional hyphens within option names are ignored.  For example,
 \fB\-\-readonly\fP and \fB\-\-read\-only\fP are both accepted.
 .
-.SH BUILT-IN COMMANDS
+.SH BUILT\-IN COMMANDS
 .
 The following commands are built into lvm without links
 normally being created in the filesystem for them.
@@ -60,7 +60,7 @@ normally being created in the filesystem for them.
 The same as \fBlvmconfig\fP(8) below.
 .TP
 .B devtypes
-Display the recognised built-in block device types.
+Display the recognised built\-in block device types.
 .TP
 .B dumpconfig
 The same as \fBlvmconfig\fP(8) below.
@@ -234,7 +234,7 @@ Scan (all disks) for Logical Volumes.
 The following LVM1 commands are not implemented in LVM2:
 .BR lvmchange ", " lvmsadc ", " lvmsar ", " pvdata .
 For performance metrics, use \fBdmstats\fP(8) or to manipulate the kernel
-device-mapper driver used by LVM2 directly, use \fBdmsetup\fP(8).
+device\-mapper driver used by LVM2 directly, use \fBdmsetup\fP(8).
 .
 .SH VALID NAMES
 .
@@ -315,7 +315,7 @@ Then they try each allocation policy in turn, starting with the strictest
 policy (\fBcontiguous\fP) and ending with the allocation policy specified
 using \fB\-\-alloc\fP or set as the default for the particular Logical
 Volume or Volume Group concerned.  For each policy, working from the
-lowest-numbered Logical Extent of the empty Logical Volume space that
+lowest\-numbered Logical Extent of the empty Logical Volume space that
 needs to be filled, they allocate as much space as possible according to
 the restrictions imposed by the policy.  If more space is needed,
 they move on to the next policy.
@@ -384,8 +384,8 @@ and thin provisioning (\fBlvmthin\fP(7)) types are examples of this.
 .
 .SH DIAGNOSTICS
 .
-All tools return a status code of zero on success or non-zero on failure.
-The non-zero codes distinguish only between the broad categories of
+All tools return a status code of zero on success or non\-zero on failure.
+The non\-zero codes distinguish only between the broad categories of
 unrecognised commands, problems processing the command line arguments
 and any other failures.  As LVM remains under active development, the
 code used in a specific case occasionally changes between releases.
@@ -464,7 +464,7 @@ Used to suppress warning messages when the configured locking is known
 to be unavailable.
 .TP
 .B DM_ABORT_ON_INTERNAL_ERRORS
-Abort processing if the code detects a non-fatal internal error.
+Abort processing if the code detects a non\-fatal internal error.
 .TP
 .B DM_DISABLE_UDEV
 Avoid interaction with udev.  LVM will manage the relevant nodes in /dev
@@ -525,7 +525,7 @@ directly.
 .BR lvs (8)
 .BR lvscan (8)
 
-.BR lvm2-activation-generator (8)
+.BR lvm2-activation\-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
 
diff --git a/man/lvm.conf.5_main b/man/lvm.conf.5_main
index d21cf71..0c70299 100644
--- a/man/lvm.conf.5_main
+++ b/man/lvm.conf.5_main
@@ -49,8 +49,8 @@ attached/detached by using the \fBlvchange\fP and \fBvgchange\fP commands
 and their \fB\-\-metadataprofile ProfileName\fP and
 \fB\-\-detachprofile\fP options or the \fB\-\-metadataprofile\fP
 option during creation when using \fBvgcreate\fP or \fBlvcreate\fP command.
-The \fBvgs\fP and \fBlvs\fP reporting commands provide \fB-o vg_profile\fP
-and \fB-o lv_profile\fP output options to show the metadata profile
+The \fBvgs\fP and \fBlvs\fP reporting commands provide \fB\-o vg_profile\fP
+and \fB\-o lv_profile\fP output options to show the metadata profile
 currently attached to a Volume Group or a Logical Volume.
 
 The set of options allowed for command profiles is mutually exclusive
@@ -65,8 +65,8 @@ For this purpose, there's the \fBcommand_profile_template.profile\fP
 (for metadata profiles) which contain all settings that are customizable
 by profiles of certain type. Users are encouraged to copy these template
 profiles and edit them as needed. Alternatively, the
-\fBlvmconfig \-\-file <ProfileName.profile> \-\-type profilable-command <section>\fP
-or \fBlvmconfig \-\-file <ProfileName.profile> \-\-type profilable-metadata <section>\fP
+\fBlvmconfig \-\-file <ProfileName.profile> \-\-type profilable\-command <section>\fP
+or \fBlvmconfig \-\-file <ProfileName.profile> \-\-type profilable\-metadata <section>\fP
 can be used to generate a configuration with profilable settings in either
 of the type for given section and save it to new ProfileName.profile
 (if the section is not specified, all profilable settings are reported).
@@ -174,12 +174,12 @@ default values, and a full description of each as a comment:
 .B lvmconfig \-\-type default \-\-withcomments
 
 Command to print a list of all possible config settings, with their
-current values (configured, non-default values are shown):
+current values (configured, non\-default values are shown):
 .br
 .B lvmconfig \-\-type current
 
 Command to print all config settings that have been configured with a
-different value than the default (configured, non-default values are
+different value than the default (configured, non\-default values are
 shown):
 .br
 .B lvmconfig \-\-type diff
diff --git a/man/lvm2-activation-generator.8_main b/man/lvm2-activation-generator.8_main
index e1be5e1..ffd5a63 100644
--- a/man/lvm2-activation-generator.8_main
+++ b/man/lvm2-activation-generator.8_main
@@ -1,22 +1,22 @@
-.TH "LVM2-ACTIVATION-GENERATOR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.TH "LVM2-ACTIVATION\-GENERATOR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 .SH "NAME"
-lvm2-activation-generator \- generator for systemd units to activate LVM2 volumes on boot
+lvm2-activation\-generator \- generator for systemd units to activate LVM2 volumes on boot
 .SH SYNOPSIS
-.B #SYSTEMD_GENERATOR_DIR#/lvm2-activation-generator
+.B #SYSTEMD_GENERATOR_DIR#/lvm2-activation\-generator
 .sp
 .SH DESCRIPTION
-The lvm2-activation-generator is called by \fBsystemd\fP(1) on boot
+The lvm2-activation\-generator is called by \fBsystemd\fP(1) on boot
 to generate systemd units at runtime to activate LVM2 volumes if
 \fBlvmetad\fP(8) is disabled (global/use_lvmetad=0 \fBlvm.conf\fP(5)
 option is used). Otherwise, if \fBlvmetad\fP(8) is enabled,
-the lvm2-activation-generator exits immediately without generating
-any systemd units and LVM2 fully relies on event-based activation
+the lvm2-activation\-generator exits immediately without generating
+any systemd units and LVM2 fully relies on event\-based activation
 to activate the LVM2 volumes instead using the \fBpvscan\fP(8)
 (pvscan \-\-cache -aay) call that is a part of \fBudev\fP(8) rules.
 
-These systemd units are generated by lvm2-activation-generator:
+These systemd units are generated by lvm2-activation\-generator:
 .sp
-\fIlvm2-activation-early.service\fP
+\fIlvm2-activation\-early.service\fP
 used for activation of LVM2 volumes that is ordered before systemd's
 special \fBcryptsetup.target\fP to support LVM2 volumes which are not
 layered on top of encrypted devices.
@@ -26,21 +26,21 @@ used for activation of LVM2 volumes that is ordered after systemd's
 special \fBcryptsetup.target\fP to support LVM2 volumes which are
 layered on top of encrypted devices.
 
-\fIlvm2-activation-net.service\fP
+\fIlvm2-activation\-net.service\fP
 used for activation of LVM2 volumes that is ordered after systemd's
-special \fBremote-fs-pre.target\fP to support LVM2 volumes which are
+special \fBremote\-fs\-pre.target\fP to support LVM2 volumes which are
 layered on attached remote devices.
 
 Note that all the underlying devices (Physical Volumes) need to be present
 when the service is run. If the there are any devices presented in the system
 anytime later, any LVM2 volumes on top of such devices need to be activated
 directly by \fBlvchange\fP(8) or \fBvgchange\fP(8). This limitation does
-not exist when using \fBlvmetad\fP(8) and accompanying event-based activation
+not exist when using \fBlvmetad\fP(8) and accompanying event\-based activation
 since such LVM volumes are activated automatically as soon as the Volume Group
 is ready (all the Physical Volumes making up the Volume Group are present
 in the system).
 
-The lvm2-activation-generator implements the \fBGenerators Specification\fP
+The lvm2-activation\-generator implements the \fBGenerators Specification\fP
 as referenced in \fBsystemd\fP(1).
 .sp
 .SH SEE ALSO
diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 4ba9449..6f246dc 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -8,7 +8,7 @@ The \fBcache\fP logical volume type uses a small and fast LV to improve
 the performance of a large and slow LV.  It does this by storing the
 frequently used blocks on the faster LV.
 LVM refers to the small fast LV as a \fBcache pool LV\fP.  The large
-slow LV is called the \fBorigin LV\fP.  Due to requirements from dm-cache
+slow LV is called the \fBorigin LV\fP.  Due to requirements from dm\-cache
 (the kernel driver), LVM further splits the cache pool LV into two
 devices - the \fBcache data LV\fP and \fBcache metadata LV\fP.  The cache
 data LV is where copies of data blocks are kept from the
@@ -71,9 +71,9 @@ a minimum size of 8MiB.
 .nf
 # lvs -a vg
   LV         VG   Attr       LSize   Pool Origin
-  cache0     vg   -wi-a\-\-\-\--  10.00g                                                    
-  cache0meta vg   -wi-a\-\-\-\--  12.00m                                                    
-  lvol0      vg   -wi-a\-\-\-\-- 100.00g
+  cache0     vg   -wi\-a\-\-\-\-\-  10.00g                                                    
+  cache0meta vg   -wi\-a\-\-\-\-\-  12.00m                                                    
+  lvol0      vg   -wi\-a\-\-\-\-\- 100.00g
 .fi
 
 
@@ -88,7 +88,7 @@ CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
 .br
 CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 
-.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV
+.B lvconvert \-\-type cache\-pool \-\-poolmetadata VG/CacheMetaLV
 .RS
 .B VG/CacheDataLV
 .RE
@@ -100,10 +100,10 @@ CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 .nf
 # lvs -a vg
   LV              VG   Attr       LSize   Pool Origin
-  cache0          vg   Cwi\-\--C\-\--  10.00g
-  [cache0_cdata]  vg   Cwi\-\-\-\-\-\--  10.00g
-  [cache0_cmeta]  vg   ewi\-\-\-\-\-\--  12.00m
-  lvol0           vg   -wi-a\-\-\-\-- 100.00g
+  cache0          vg   Cwi\-\-\-C\-\-\-  10.00g
+  [cache0_cdata]  vg   Cwi\-\-\-\-\-\-\-  10.00g
+  [cache0_cmeta]  vg   ewi\-\-\-\-\-\-\-  12.00m
+  lvol0           vg   -wi\-a\-\-\-\-\- 100.00g
 .fi
 
 
@@ -127,11 +127,11 @@ OriginLV is renamed OriginLV_corig and becomes hidden.
 .nf
 # lvs -a vg
   LV              VG   Attr       LSize   Pool   Origin
-  cache0          vg   Cwi\-\--C\-\--  10.00g                                                             
-  [cache0_cdata]  vg   Cwi-ao\-\-\-\-  10.00g                                                             
-  [cache0_cmeta]  vg   ewi-ao\-\-\-\-  12.00m                                                             
-  lvol0           vg   Cwi-a-C\-\-- 100.00g cache0 [lvol0_corig]                                        
-  [lvol0_corig]   vg   -wi-ao\-\-\-\- 100.00g                                                             
+  cache0          vg   Cwi\-\-\-C\-\-\-  10.00g                                                             
+  [cache0_cdata]  vg   Cwi\-ao\-\-\-\-  10.00g                                                             
+  [cache0_cmeta]  vg   ewi\-ao\-\-\-\-  12.00m                                                             
+  lvol0           vg   Cwi\-a\-C\-\-\- 100.00g cache0 [lvol0_corig]                                        
+  [lvol0_corig]   vg   -wi\-ao\-\-\-\- 100.00g                                                             
 .fi
 
 
@@ -165,14 +165,14 @@ LV, and deletes the cache pool:
 .nf
 # lvs vg
   LV     VG   Attr       LSize   Pool   Origin
-  cache0 vg   Cwi\-\--C\-\--  10.00g
-  lvol0  vg   Cwi-a-C\-\-- 100.00g cache0 [lvol0_corig]
+  cache0 vg   Cwi\-\-\-C\-\-\-  10.00g
+  lvol0  vg   Cwi\-a\-C\-\-\- 100.00g cache0 [lvol0_corig]
 
 # lvremove vg/cache0
 
 # lvs vg
   LV    VG   Attr       LSize   Pool Origin
-  lvol0 vg   -wi-a\-\-\-\-- 100.00g
+  lvol0 vg   -wi\-a\-\-\-\-\- 100.00g
 .fi
 
 .SS Removing a cache LV: both origin LV and the cache pool LV
@@ -193,7 +193,7 @@ LV.
 
 Users who are concerned about the possibility of failures in their fast
 devices that could lead to data loss might consider making their cache
-pool sub-LVs redundant.
+pool sub\-LVs redundant.
 
 .I Example
 .nf
@@ -265,7 +265,7 @@ defines the default cache mode.
 
 \&
 
-The cache subsystem has additional per-LV parameters: the cache policy to
+The cache subsystem has additional per\-LV parameters: the cache policy to
 use, and possibly tunable parameters for the cache policy.  Three policies
 are currently available: "smq" is the default policy, "mq" is an older
 implementation, and "cleaner" is used to force the cache to write back
@@ -398,7 +398,7 @@ This is equivalent to:
 .br
 .B lvcreate -n CacheDataLV -L CacheSize VG
 .br
-.B lvconvert \-\-type cache-pool VG/CacheDataLV
+.B lvconvert \-\-type cache\-pool VG/CacheDataLV
 .br
 .B lvconvert \-\-type cache \-\-cachepool VG/CachePoolLV VG/OriginLV
 
diff --git a/man/lvmconf.8_main b/man/lvmconf.8_main
index 44cb52b..5ca80f3 100644
--- a/man/lvmconf.8_main
+++ b/man/lvmconf.8_main
@@ -4,10 +4,10 @@
 lvmconf \(em LVM configuration modifier
 .SH "SYNOPSIS"
 .B lvmconf
-.RB [ \-\-disable-cluster ]
-.RB [ \-\-enable-cluster ]
-.RB [ \-\-enable-halvm ]
-.RB [ \-\-disable-halvm ]
+.RB [ \-\-disable\-cluster ]
+.RB [ \-\-enable\-cluster ]
+.RB [ \-\-enable\-halvm ]
+.RB [ \-\-disable\-halvm ]
 .RB [ \-\-file
 .RI < configfile >]
 .RB [ \-\-lockinglib
@@ -26,19 +26,19 @@ changes in the lvm configuration if needed.
 
 .SH "OPTIONS"
 .TP
-.BR \-\-disable-cluster
-Set \fBlocking_type\fR to the default non-clustered type. Also reset
+.BR \-\-disable\-cluster
+Set \fBlocking_type\fR to the default non\-clustered type. Also reset
 lvmetad use to its default.
 .TP
-.BR \-\-enable-cluster
+.BR \-\-enable\-cluster
 Set \fBlocking_type\fR to the default clustered type on this system.
 Also disable lvmetad use as it is not yet supported in clustered environment.
 .TP
-.BR \-\-disable-halvm
-Set \fBlocking_type\fR to the default non-clustered type. Also reset
+.BR \-\-disable\-halvm
+Set \fBlocking_type\fR to the default non\-clustered type. Also reset
 lvmetad use to its default.
 .TP
-.BR \-\-enable-halvm
+.BR \-\-enable\-halvm
 Set \fBlocking_type\fR suitable for HA LVM use.
 Also disable lvmetad use as it is not yet supported in HA LVM environment.
 .TP
diff --git a/man/lvmdbusd.8_main b/man/lvmdbusd.8_main
index 9e035f5..3bf46c1 100644
--- a/man/lvmdbusd.8_main
+++ b/man/lvmdbusd.8_main
@@ -2,7 +2,7 @@
 .
 .SH NAME
 .
-lvmdbusd \(em LVM D-Bus daemon
+lvmdbusd \(em LVM D\-Bus daemon
 .
 .SH SYNOPSIS
 .
@@ -14,7 +14,7 @@ lvmdbusd \(em LVM D-Bus daemon
 .
 .SH DESCRIPTION
 .
-lvmdbusd is a service which provides a D-Bus API to the logical volume manager (LVM).
+lvmdbusd is a service which provides a D\-Bus API to the logical volume manager (LVM).
 Run 
 .BR lvmdbusd (8)
 as root.
@@ -34,5 +34,5 @@ Use udev events to trigger updates
 .SH SEE ALSO
 .
 .nh
-.BR dbus-send (1),
+.BR dbus\-send (1),
 .BR lvm (8)
diff --git a/man/lvmdump.8_main b/man/lvmdump.8_main
index d0e102e..d62c736 100644
--- a/man/lvmdump.8_main
+++ b/man/lvmdump.8_main
@@ -80,7 +80,7 @@ However, the metadata dump may represent a valuable diagnostic resource.
 .TP
 .B \-p
 Include \fBlvmpolld\fP(8) daemon dump if it is running. The dump contains
-all in-progress operation currently monitored by the daemon and partial
+all in\-progress operation currently monitored by the daemon and partial
 history for all yet uncollected results of polling operations already finished
 including reason.
 .TP
diff --git a/man/lvmetad.8_main b/man/lvmetad.8_main
index c665e18..16e3d52 100644
--- a/man/lvmetad.8_main
+++ b/man/lvmetad.8_main
@@ -94,13 +94,13 @@ Additionally, when \-f is given they are also sent to standard error.
 Possible levels are: all, fatal, error, warn, info, wire, debug.
 .TP
 .B \-p \fIpidfile_path
-Path to the pidfile. This overrides both the built-in default
+Path to the pidfile. This overrides both the built\-in default
 (#DEFAULT_PID_DIR#/lvmetad.pid) and the environment variable
 \fBLVM_LVMETAD_PIDFILE\fP.  This file is used to prevent more
 than one instance of the daemon running simultaneously.
 .TP
 .B \-s \fIsocket_path
-Path to the socket file. This overrides both the built-in default
+Path to the socket file. This overrides both the built\-in default
 (#DEFAULT_RUN_DIR#/lvmetad.socket) and the environment variable
 \fBLVM_LVMETAD_SOCKET\fP.  To communicate successfully with lvmetad,
 all LVM2 processes should use the same socket path.
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index bca8ecd..6c8f3f0 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -353,7 +353,7 @@ lockd VGs need to be "started" and "stopped", unlike other types of VGs.
 See the following section for a full description of starting and stopping.
 
 vgremove of a lockd VG will fail if other hosts have the VG started.
-Run vgchange \-\-lock-stop <vgname> on all other hosts before vgremove.
+Run vgchange \-\-lock\-stop <vgname> on all other hosts before vgremove.
 (It may take several seconds before vgremove recognizes that all hosts
 have stopped a sanlock VG.)
 
@@ -390,9 +390,9 @@ A lockd VG can be stopped if all LVs are deactivated.
 
 All lockd VGs can be started/stopped using:
 .br
-vgchange \-\-lock-start
+vgchange \-\-lock\-start
 .br
-vgchange \-\-lock-stop
+vgchange \-\-lock\-stop
 
 
 Individual VGs can be started/stopped using:
@@ -687,7 +687,7 @@ original cluster:
 .IP \[bu] 2
 Stop the VG on all hosts:
 .br
-vgchange \-\-lock-stop <vgname>
+vgchange \-\-lock\-stop <vgname>
 
 .IP \[bu] 2
 Change the VG lock type to none:
@@ -709,7 +709,7 @@ vgchange \-\-lock\-type dlm <vgname>
 .IP \[bu] 2
 Start the VG on hosts to use it:
 .br
-vgchange \-\-lock-start <vgname>
+vgchange \-\-lock\-start <vgname>
 
 .P
 
@@ -738,7 +738,7 @@ vgchange \-\-lock\-type dlm <vgname>
 .IP \[bu] 2
 Start the VG on hosts to use it:
 .br
-vgchange \-\-lock-start <vgname>
+vgchange \-\-lock\-start <vgname>
 
 
 .SS changing a local VG to a lockd VG
@@ -856,13 +856,13 @@ lvmlockd saves the cluster name for a lockd VG using dlm.  Only hosts in
 the matching cluster can use the VG.
 
 .IP \[bu] 2
-lvmlockd requires starting/stopping lockd VGs with vgchange \-\-lock-start
-and \-\-lock-stop.
+lvmlockd requires starting/stopping lockd VGs with vgchange \-\-lock\-start
+and \-\-lock\-stop.
 
 .IP \[bu] 2
 vgremove of a sanlock VG may fail indicating that all hosts have not
 stopped the VG lockspace.  Stop the VG on all hosts using vgchange
-\-\-lock-stop.
+\-\-lock\-stop.
 
 .IP \[bu] 2
 vgreduce or pvmove of a PV in a sanlock VG will fail if it holds the
diff --git a/man/lvmpolld.8_main b/man/lvmpolld.8_main
index 00ee1ab..c5cbce4 100644
--- a/man/lvmpolld.8_main
+++ b/man/lvmpolld.8_main
@@ -50,16 +50,16 @@ Select the type of log messages to generate.
 Messages are logged by syslog.
 Additionally, when \-f is given they are also sent to standard error.
 There are two classes of messages: wire and debug. Selecting 'all' supplies both
-and is equivalent to a comma-separated list \-l wire,debug.
+and is equivalent to a comma\-separated list \-l wire,debug.
 .TP
 .BR \-p ", " \-\-pidfile " " \fIpidfile_path
-Path to the pidfile. This overrides both the built-in default
+Path to the pidfile. This overrides both the built\-in default
 (#DEFAULT_PID_DIR#/lvmpolld.pid) and the environment variable
 \fBLVM_LVMPOLLD_PIDFILE\fP.  This file is used to prevent more
 than one instance of the daemon running simultaneously.
 .TP
 .BR \-s ", " \-\-socket " " \fIsocket_path
-Path to the socket file. This overrides both the built-in default
+Path to the socket file. This overrides both the built\-in default
 (#DEFAULT_RUN_DIR#/lvmpolld.socket) and the environment variable
 \fBLVM_LVMPOLLD_SOCKET\fP.
 .TP
diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 3d75e79..98630f0 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -130,7 +130,7 @@ data that is written to one device before moving to the next.
 \fIPVs\fP specifies the devices to use.  If not specified, lvm will choose
 \fINumber\fP+1 separate devices.
 
-raid4 is called non-rotating parity because the parity blocks are always
+raid4 is called non\-rotating parity because the parity blocks are always
 stored on the same device.
 
 .SS raid5
@@ -165,7 +165,7 @@ data that is written to one device before moving to the next.
 \fINumber\fP+1 separate devices.
 
 raid5 is called rotating parity because the parity blocks are placed on
-different devices in a round-robin sequence.  There are variations of
+different devices in a round\-robin sequence.  There are variations of
 raid5 with different algorithms for placing the parity blocks.  The
 default variant is raid5_ls (raid5 left symmetric, which is a rotating
 parity 0 with data restart.)  See \fBRAID5 variants\fP below.
@@ -296,7 +296,7 @@ Scrubbing assumes that RAID metadata and bitmaps may be inaccurate, so it
 verifies all RAID metadata, LV data, and parity blocks.  Scrubbing can
 find inconsistencies caused by hardware errors or degradation.  These
 kinds of problems may be undetected by automatic synchronization which
-excludes areas outside of the RAID write-intent bitmap.
+excludes areas outside of the RAID write\-intent bitmap.
 
 The command to scrub a RAID LV can operate in two different modes:
 
@@ -355,7 +355,7 @@ Also, if mismatches were found, the lvs attr field will display the letter
 .nf
 # lvs -o name,vgname,segtype,attr vg/lvol0
   LV    VG   Type  Attr
-  lvol0 vg   raid1 Rwi-a-r-m-
+  lvol0 vg   raid1 Rwi\-a\-r\-m\-
 .fi
 
 
@@ -381,7 +381,7 @@ Allowing a user to choose the correct version of data during repair.
 Using a majority of devices to determine the correct version of data to
 use in a 3-way RAID1 or RAID6 LV.
 
-Using a checksumming device to pin-point when and where an error occurs,
+Using a checksumming device to pin\-point when and where an error occurs,
 allowing it to be rewritten.
 
 
@@ -568,7 +568,7 @@ is composed of a raid1 set, without LV data loss.
 
 .P
 
-If a RAID LV is missing devices, or has other device-related problems, lvs
+If a RAID LV is missing devices, or has other device\-related problems, lvs
 reports this in the health_status (and attr) fields:
 
 .B lvs -o name,lv_health_status
@@ -596,7 +596,7 @@ See
 Most commands will also print a warning if a device is missing, e.g.
 .br
 .nf
-WARNING: Device for PV uItL3Z-wBME-DQy0-... not found or rejected ...
+WARNING: Device for PV uItL3Z\-wBME\-DQy0-... not found or rejected ...
 .fi
 
 This warning will go away if the device returns or is removed from the
@@ -683,18 +683,18 @@ the lvchange command to refresh an LV:
 .nf
 # lvs -o name,vgname,segtype,attr,size vg
   LV    VG   Type  Attr       LSize
-  raid1 vg   raid1 Rwi-a-r-r- 100.00g
+  raid1 vg   raid1 Rwi\-a\-r\-r\- 100.00g
 
 # lvchange \-\-refresh vg/raid1
 
 # lvs -o name,vgname,segtype,attr,size vg
   LV    VG   Type  Attr       LSize
-  raid1 vg   raid1 Rwi-a-r\-\-- 100.00g
+  raid1 vg   raid1 Rwi\-a\-r\-\-\- 100.00g
 .fi
 
 .SS Automatic repair
 
-If a device in a RAID LV fails, device-mapper in the kernel notifies the
+If a device in a RAID LV fails, device\-mapper in the kernel notifies the
 .BR dmeventd (8)
 monitoring process (see \fBMonitoring\fP).
 dmeventd can be configured to automatically respond using:
@@ -746,7 +746,7 @@ on multiple PVs.
 
 When a RAID LV is activated the \fBdmeventd\fP(8) process is started to
 monitor the health of the LV.  Various events detected in the kernel can
-cause a notification to be sent from device-mapper to the monitoring
+cause a notification to be sent from device\-mapper to the monitoring
 process, including device failures and synchronization completion (e.g.
 for initialization or scrubbing).
 
@@ -850,7 +850,7 @@ striped volume results in raid4/5/6.
 .P
 
 Unnatural conversions that are not recommended include converting between
-striped and non-striped types.  This is because file systems often
+striped and non\-striped types.  This is because file systems often
 optimize I/O patterns based on device striping values.  If those values
 change, it can decrease performance.
 
@@ -1085,7 +1085,7 @@ traditional RAID6.
 .fi
 
 The DataLVs are larger (additional segment in each) which provides space
-for out-of-place reshaping.  The result is:
+for out\-of\-place reshaping.  The result is:
 
 .nf
 # lvs -a -o lv_name,segtype,seg_pe_ranges,dataoffset
@@ -1106,12 +1106,12 @@ for out-of-place reshaping.  The result is:
   [lv_rmeta_3]  linear   /dev/sdac:0-0
 .fi
 
-All segments with PE ranges '33-33' provide the out-of-place reshape space.
+All segments with PE ranges '33-33' provide the out\-of\-place reshape space.
 The dataoffset column shows that the data was moved from initial offset 0 to
 2048 sectors on each component DataLV.
 
 For performance reasons the raid6_nr RaidLV can be restriped.
-Convert it from 3-way striped to 5-way-striped.
+Convert it from 3-way striped to 5-way\-striped.
 
 .nf
 # lvconvert \-\-stripes 5 -y tb/lv
@@ -1122,34 +1122,34 @@ Convert it from 3-way striped to 5-way-striped.
 
 # lvs
   LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
-  root fedora -wi-ao\-\-\-\-  15.00g
-  swap fedora -wi-ao\-\-\-\-   3.99g
-  lv   tb     rwi-a-r-s- 652.00m                                    52.94
+  root fedora -wi\-ao\-\-\-\-  15.00g
+  swap fedora -wi\-ao\-\-\-\-   3.99g
+  lv   tb     rwi\-a\-r\-s\- 652.00m                                    52.94
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV            Attr       Type     PE Ranges                                                                                   DOff
-  lv            rwi-a-r\-\-- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
-  [lv_rimage_0] iwi-aor\-\-- linear   /dev/sda:0-32                                                                               0
-  [lv_rimage_0] iwi-aor\-\-- linear   /dev/sda:34-34
-  [lv_rimage_1] iwi-aor\-\-- linear   /dev/sdaa:0-32                                                                              0
-  [lv_rimage_1] iwi-aor\-\-- linear   /dev/sdaa:34-34
-  [lv_rimage_2] iwi-aor\-\-- linear   /dev/sdab:0-32                                                                              0
-  [lv_rimage_2] iwi-aor\-\-- linear   /dev/sdab:34-34
-  [lv_rimage_3] iwi-aor\-\-- linear   /dev/sdac:1-34                                                                              0
-  [lv_rimage_4] iwi-aor\-\-- linear   /dev/sdad:1-34                                                                              0
-  [lv_rimage_5] iwi-aor\-\-- linear   /dev/sdae:1-34                                                                              0
-  [lv_rimage_6] iwi-aor\-\-- linear   /dev/sdaf:1-34                                                                              0
-  [lv_rmeta_0]  ewi-aor\-\-- linear   /dev/sda:33-33
-  [lv_rmeta_1]  ewi-aor\-\-- linear   /dev/sdaa:33-33
-  [lv_rmeta_2]  ewi-aor\-\-- linear   /dev/sdab:33-33
-  [lv_rmeta_3]  ewi-aor\-\-- linear   /dev/sdac:0-0
-  [lv_rmeta_4]  ewi-aor\-\-- linear   /dev/sdad:0-0
-  [lv_rmeta_5]  ewi-aor\-\-- linear   /dev/sdae:0-0
-  [lv_rmeta_6]  ewi-aor\-\-- linear   /dev/sdaf:0-0
+  lv            rwi\-a\-r\-\-\- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
+  [lv_rimage_0] iwi\-aor\-\-\- linear   /dev/sda:0-32                                                                               0
+  [lv_rimage_0] iwi\-aor\-\-\- linear   /dev/sda:34-34
+  [lv_rimage_1] iwi\-aor\-\-\- linear   /dev/sdaa:0-32                                                                              0
+  [lv_rimage_1] iwi\-aor\-\-\- linear   /dev/sdaa:34-34
+  [lv_rimage_2] iwi\-aor\-\-\- linear   /dev/sdab:0-32                                                                              0
+  [lv_rimage_2] iwi\-aor\-\-\- linear   /dev/sdab:34-34
+  [lv_rimage_3] iwi\-aor\-\-\- linear   /dev/sdac:1-34                                                                              0
+  [lv_rimage_4] iwi\-aor\-\-\- linear   /dev/sdad:1-34                                                                              0
+  [lv_rimage_5] iwi\-aor\-\-\- linear   /dev/sdae:1-34                                                                              0
+  [lv_rimage_6] iwi\-aor\-\-\- linear   /dev/sdaf:1-34                                                                              0
+  [lv_rmeta_0]  ewi\-aor\-\-\- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi\-aor\-\-\- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi\-aor\-\-\- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi\-aor\-\-\- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi\-aor\-\-\- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi\-aor\-\-\- linear   /dev/sdae:0-0
+  [lv_rmeta_6]  ewi\-aor\-\-\- linear   /dev/sdaf:0-0
 .fi
 
 Stripes also can be removed from raid5 and 6.
-Convert the 5-way striped raid6_nr LV to 4-way-striped.
+Convert the 5-way striped raid6_nr LV to 4-way\-striped.
 The force option needs to be used, because removing stripes
 (i.e. image SubLVs) from a RaidLV will shrink its size.
 
@@ -1165,24 +1165,24 @@ The force option needs to be used, because removing stripes
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV            Attr       Type     PE Ranges                                                                                   DOff
-  lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
-  [lv_rimage_0] Iwi-aor\-\-- linear   /dev/sda:0-32                                                                               0
-  [lv_rimage_0] Iwi-aor\-\-- linear   /dev/sda:34-34
-  [lv_rimage_1] Iwi-aor\-\-- linear   /dev/sdaa:0-32                                                                              0
-  [lv_rimage_1] Iwi-aor\-\-- linear   /dev/sdaa:34-34
-  [lv_rimage_2] Iwi-aor\-\-- linear   /dev/sdab:0-32                                                                              0
-  [lv_rimage_2] Iwi-aor\-\-- linear   /dev/sdab:34-34
-  [lv_rimage_3] Iwi-aor\-\-- linear   /dev/sdac:1-34                                                                              0
-  [lv_rimage_4] Iwi-aor\-\-- linear   /dev/sdad:1-34                                                                              0
-  [lv_rimage_5] Iwi-aor\-\-- linear   /dev/sdae:1-34                                                                              0
-  [lv_rimage_6] Iwi-aor-R- linear   /dev/sdaf:1-34                                                                              0
-  [lv_rmeta_0]  ewi-aor\-\-- linear   /dev/sda:33-33
-  [lv_rmeta_1]  ewi-aor\-\-- linear   /dev/sdaa:33-33
-  [lv_rmeta_2]  ewi-aor\-\-- linear   /dev/sdab:33-33
-  [lv_rmeta_3]  ewi-aor\-\-- linear   /dev/sdac:0-0
-  [lv_rmeta_4]  ewi-aor\-\-- linear   /dev/sdad:0-0
-  [lv_rmeta_5]  ewi-aor\-\-- linear   /dev/sdae:0-0
-  [lv_rmeta_6]  ewi-aor-R- linear   /dev/sdaf:0-0
+  lv            rwi\-a\-r\-s\- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
+  [lv_rimage_0] Iwi\-aor\-\-\- linear   /dev/sda:0-32                                                                               0
+  [lv_rimage_0] Iwi\-aor\-\-\- linear   /dev/sda:34-34
+  [lv_rimage_1] Iwi\-aor\-\-\- linear   /dev/sdaa:0-32                                                                              0
+  [lv_rimage_1] Iwi\-aor\-\-\- linear   /dev/sdaa:34-34
+  [lv_rimage_2] Iwi\-aor\-\-\- linear   /dev/sdab:0-32                                                                              0
+  [lv_rimage_2] Iwi\-aor\-\-\- linear   /dev/sdab:34-34
+  [lv_rimage_3] Iwi\-aor\-\-\- linear   /dev/sdac:1-34                                                                              0
+  [lv_rimage_4] Iwi\-aor\-\-\- linear   /dev/sdad:1-34                                                                              0
+  [lv_rimage_5] Iwi\-aor\-\-\- linear   /dev/sdae:1-34                                                                              0
+  [lv_rimage_6] Iwi\-aor\-R\- linear   /dev/sdaf:1-34                                                                              0
+  [lv_rmeta_0]  ewi\-aor\-\-\- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi\-aor\-\-\- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi\-aor\-\-\- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi\-aor\-\-\- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi\-aor\-\-\- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi\-aor\-\-\- linear   /dev/sdae:0-0
+  [lv_rmeta_6]  ewi\-aor\-R\- linear   /dev/sdaf:0-0
 .fi
 
 The 's' in column 9 of the attribute field shows the RaidLV is still reshaping.
@@ -1191,7 +1191,7 @@ The 'R' in the same column of the attribute field shows the freed image Sub LVs
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV   Attr       Type     PE Ranges                                                                                DOff
-  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33 8192
+  lv   rwi\-a\-r\-R\- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33 8192
 .fi
 
 Now that the reshape is finished the 'R' atribute on the RaidLV shows images can be removed.
@@ -1199,7 +1199,7 @@ Now that the reshape is finished the 'R' atribute on the RaidLV shows images can
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV   Attr       Type     PE Ranges                                                                                 DOff
-  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ...  lv_rimage_5:0-33 lv_rimage_6:0-33 8192
+  lv   rwi\-a\-r\-R\- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ...  lv_rimage_5:0-33 lv_rimage_6:0-33 8192
 .fi
 
 This is achieved by repeating the command ("lvconvert \-\-stripes 4 tb/lv" would be sufficient).
@@ -1211,41 +1211,41 @@ This is achieved by repeating the command ("lvconvert \-\-stripes 4 tb/lv" would
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV            Attr       Type     PE Ranges                                                               DOff
-  lv            rwi-a-r\-\-- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 8192
-  [lv_rimage_0] iwi-aor\-\-- linear   /dev/sda:0-32                                                           8192
-  [lv_rimage_0] iwi-aor\-\-- linear   /dev/sda:34-34
-  [lv_rimage_1] iwi-aor\-\-- linear   /dev/sdaa:0-32                                                          8192
-  [lv_rimage_1] iwi-aor\-\-- linear   /dev/sdaa:34-34
-  [lv_rimage_2] iwi-aor\-\-- linear   /dev/sdab:0-32                                                          8192
-  [lv_rimage_2] iwi-aor\-\-- linear   /dev/sdab:34-34
-  [lv_rimage_3] iwi-aor\-\-- linear   /dev/sdac:1-34                                                          8192
-  [lv_rimage_4] iwi-aor\-\-- linear   /dev/sdad:1-34                                                          8192
-  [lv_rimage_5] iwi-aor\-\-- linear   /dev/sdae:1-34                                                          8192
-  [lv_rmeta_0]  ewi-aor\-\-- linear   /dev/sda:33-33
-  [lv_rmeta_1]  ewi-aor\-\-- linear   /dev/sdaa:33-33
-  [lv_rmeta_2]  ewi-aor\-\-- linear   /dev/sdab:33-33
-  [lv_rmeta_3]  ewi-aor\-\-- linear   /dev/sdac:0-0
-  [lv_rmeta_4]  ewi-aor\-\-- linear   /dev/sdad:0-0
-  [lv_rmeta_5]  ewi-aor\-\-- linear   /dev/sdae:0-0
+  lv            rwi\-a\-r\-\-\- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 8192
+  [lv_rimage_0] iwi\-aor\-\-\- linear   /dev/sda:0-32                                                           8192
+  [lv_rimage_0] iwi\-aor\-\-\- linear   /dev/sda:34-34
+  [lv_rimage_1] iwi\-aor\-\-\- linear   /dev/sdaa:0-32                                                          8192
+  [lv_rimage_1] iwi\-aor\-\-\- linear   /dev/sdaa:34-34
+  [lv_rimage_2] iwi\-aor\-\-\- linear   /dev/sdab:0-32                                                          8192
+  [lv_rimage_2] iwi\-aor\-\-\- linear   /dev/sdab:34-34
+  [lv_rimage_3] iwi\-aor\-\-\- linear   /dev/sdac:1-34                                                          8192
+  [lv_rimage_4] iwi\-aor\-\-\- linear   /dev/sdad:1-34                                                          8192
+  [lv_rimage_5] iwi\-aor\-\-\- linear   /dev/sdae:1-34                                                          8192
+  [lv_rmeta_0]  ewi\-aor\-\-\- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi\-aor\-\-\- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi\-aor\-\-\- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi\-aor\-\-\- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi\-aor\-\-\- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi\-aor\-\-\- linear   /dev/sdae:0-0
 
 # lvs -a -o lv_name,attr,segtype,reshapelen tb
   LV            Attr       Type     RSize
-  lv            rwi-a-r\-\-- raid6_nr 24.00m
-  [lv_rimage_0] iwi-aor\-\-- linear    4.00m
-  [lv_rimage_0] iwi-aor\-\-- linear
-  [lv_rimage_1] iwi-aor\-\-- linear    4.00m
-  [lv_rimage_1] iwi-aor\-\-- linear
-  [lv_rimage_2] iwi-aor\-\-- linear    4.00m
-  [lv_rimage_2] iwi-aor\-\-- linear
-  [lv_rimage_3] iwi-aor\-\-- linear    4.00m
-  [lv_rimage_4] iwi-aor\-\-- linear    4.00m
-  [lv_rimage_5] iwi-aor\-\-- linear    4.00m
-  [lv_rmeta_0]  ewi-aor\-\-- linear
-  [lv_rmeta_1]  ewi-aor\-\-- linear
-  [lv_rmeta_2]  ewi-aor\-\-- linear
-  [lv_rmeta_3]  ewi-aor\-\-- linear
-  [lv_rmeta_4]  ewi-aor\-\-- linear
-  [lv_rmeta_5]  ewi-aor\-\-- linear
+  lv            rwi\-a\-r\-\-\- raid6_nr 24.00m
+  [lv_rimage_0] iwi\-aor\-\-\- linear    4.00m
+  [lv_rimage_0] iwi\-aor\-\-\- linear
+  [lv_rimage_1] iwi\-aor\-\-\- linear    4.00m
+  [lv_rimage_1] iwi\-aor\-\-\- linear
+  [lv_rimage_2] iwi\-aor\-\-\- linear    4.00m
+  [lv_rimage_2] iwi\-aor\-\-\- linear
+  [lv_rimage_3] iwi\-aor\-\-\- linear    4.00m
+  [lv_rimage_4] iwi\-aor\-\-\- linear    4.00m
+  [lv_rimage_5] iwi\-aor\-\-\- linear    4.00m
+  [lv_rmeta_0]  ewi\-aor\-\-\- linear
+  [lv_rmeta_1]  ewi\-aor\-\-\- linear
+  [lv_rmeta_2]  ewi\-aor\-\-\- linear
+  [lv_rmeta_3]  ewi\-aor\-\-\- linear
+  [lv_rmeta_4]  ewi\-aor\-\-\- linear
+  [lv_rmeta_5]  ewi\-aor\-\-\- linear
 .fi
 
 If the reshape space shall be removed any lvconvert command not changing the layout can be used:
@@ -1258,22 +1258,22 @@ If the reshape space shall be removed any lvconvert command not changing the lay
 
 # lvs -a -o lv_name,attr,segtype,reshapelen tb
   LV            Attr       Type     RSize
-  lv            rwi-a-r\-\-- raid6_nr    0
-  [lv_rimage_0] iwi-aor\-\-- linear      0
-  [lv_rimage_0] iwi-aor\-\-- linear
-  [lv_rimage_1] iwi-aor\-\-- linear      0
-  [lv_rimage_1] iwi-aor\-\-- linear
-  [lv_rimage_2] iwi-aor\-\-- linear      0
-  [lv_rimage_2] iwi-aor\-\-- linear
-  [lv_rimage_3] iwi-aor\-\-- linear      0
-  [lv_rimage_4] iwi-aor\-\-- linear      0
-  [lv_rimage_5] iwi-aor\-\-- linear      0
-  [lv_rmeta_0]  ewi-aor\-\-- linear
-  [lv_rmeta_1]  ewi-aor\-\-- linear
-  [lv_rmeta_2]  ewi-aor\-\-- linear
-  [lv_rmeta_3]  ewi-aor\-\-- linear
-  [lv_rmeta_4]  ewi-aor\-\-- linear
-  [lv_rmeta_5]  ewi-aor\-\-- linear
+  lv            rwi\-a\-r\-\-\- raid6_nr    0
+  [lv_rimage_0] iwi\-aor\-\-\- linear      0
+  [lv_rimage_0] iwi\-aor\-\-\- linear
+  [lv_rimage_1] iwi\-aor\-\-\- linear      0
+  [lv_rimage_1] iwi\-aor\-\-\- linear
+  [lv_rimage_2] iwi\-aor\-\-\- linear      0
+  [lv_rimage_2] iwi\-aor\-\-\- linear
+  [lv_rimage_3] iwi\-aor\-\-\- linear      0
+  [lv_rimage_4] iwi\-aor\-\-\- linear      0
+  [lv_rimage_5] iwi\-aor\-\-\- linear      0
+  [lv_rmeta_0]  ewi\-aor\-\-\- linear
+  [lv_rmeta_1]  ewi\-aor\-\-\- linear
+  [lv_rmeta_2]  ewi\-aor\-\-\- linear
+  [lv_rmeta_3]  ewi\-aor\-\-\- linear
+  [lv_rmeta_4]  ewi\-aor\-\-\- linear
+  [lv_rmeta_5]  ewi\-aor\-\-\- linear
 .fi
 
 In case the RaidLV should be converted to striped:
@@ -1301,8 +1301,8 @@ Are you sure you want to convert raid6_nr LV tb/lv? [y/n]: y
 
 [root at vm46 ~]# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV   Attr       Type    PE Ranges                                                      DOff
-  lv   -wi-a\-\-\-\-- striped /dev/sda:2-32 /dev/sdaa:2-32 /dev/sdab:2-32 /dev/sdac:3-33
-  lv   -wi-a\-\-\-\-- striped /dev/sda:34-35 /dev/sdaa:34-35 /dev/sdab:34-35 /dev/sdac:34-35
+  lv   -wi\-a\-\-\-\-\- striped /dev/sda:2-32 /dev/sdaa:2-32 /dev/sdab:2-32 /dev/sdac:3-33
+  lv   -wi\-a\-\-\-\-\- striped /dev/sda:34-35 /dev/sdaa:34-35 /dev/sdab:34-35 /dev/sdac:34-35
 .fi
 
 From striped we can convert to raid10
@@ -1314,31 +1314,31 @@ From striped we can convert to raid10
 
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV   Attr       Type   PE Ranges                                                                                   DOff
-  lv   rwi-a-r\-\-- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
+  lv   rwi\-a\-r\-\-\- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   WARNING: Cannot find matching striped segment for tb/lv_rimage_3.
   LV            Attr       Type   PE Ranges                                                                                   DOff
-  lv            rwi-a-r\-\-- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
-  [lv_rimage_0] iwi-aor\-\-- linear /dev/sda:2-32                                                                                                                              0
-  [lv_rimage_0] iwi-aor\-\-- linear /dev/sda:34-35
-  [lv_rimage_1] iwi-aor\-\-- linear /dev/sdaa:2-32                                                                                                                             0
-  [lv_rimage_1] iwi-aor\-\-- linear /dev/sdaa:34-35
-  [lv_rimage_2] iwi-aor\-\-- linear /dev/sdab:2-32                                                                                                                             0
-  [lv_rimage_2] iwi-aor\-\-- linear /dev/sdab:34-35
-  [lv_rimage_3] iwi-XXr\-\-- linear /dev/sdac:3-35                                                                                                                             0
-  [lv_rimage_4] iwi-aor\-\-- linear /dev/sdad:1-33                                                                                                                             0
-  [lv_rimage_5] iwi-aor\-\-- linear /dev/sdae:1-33                                                                                                                             0
-  [lv_rimage_6] iwi-aor\-\-- linear /dev/sdaf:1-33                                                                                                                             0
-  [lv_rimage_7] iwi-aor\-\-- linear /dev/sdag:1-33                                                                                                                             0
-  [lv_rmeta_0]  ewi-aor\-\-- linear /dev/sda:0-0
-  [lv_rmeta_1]  ewi-aor\-\-- linear /dev/sdaa:0-0
-  [lv_rmeta_2]  ewi-aor\-\-- linear /dev/sdab:0-0
-  [lv_rmeta_3]  ewi-aor\-\-- linear /dev/sdac:0-0
-  [lv_rmeta_4]  ewi-aor\-\-- linear /dev/sdad:0-0
-  [lv_rmeta_5]  ewi-aor\-\-- linear /dev/sdae:0-0
-  [lv_rmeta_6]  ewi-aor\-\-- linear /dev/sdaf:0-0
-  [lv_rmeta_7]  ewi-aor\-\-- linear /dev/sdag:0-0
+  lv            rwi\-a\-r\-\-\- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
+  [lv_rimage_0] iwi\-aor\-\-\- linear /dev/sda:2-32                                                                                                                              0
+  [lv_rimage_0] iwi\-aor\-\-\- linear /dev/sda:34-35
+  [lv_rimage_1] iwi\-aor\-\-\- linear /dev/sdaa:2-32                                                                                                                             0
+  [lv_rimage_1] iwi\-aor\-\-\- linear /dev/sdaa:34-35
+  [lv_rimage_2] iwi\-aor\-\-\- linear /dev/sdab:2-32                                                                                                                             0
+  [lv_rimage_2] iwi\-aor\-\-\- linear /dev/sdab:34-35
+  [lv_rimage_3] iwi\-XXr\-\-\- linear /dev/sdac:3-35                                                                                                                             0
+  [lv_rimage_4] iwi\-aor\-\-\- linear /dev/sdad:1-33                                                                                                                             0
+  [lv_rimage_5] iwi\-aor\-\-\- linear /dev/sdae:1-33                                                                                                                             0
+  [lv_rimage_6] iwi\-aor\-\-\- linear /dev/sdaf:1-33                                                                                                                             0
+  [lv_rimage_7] iwi\-aor\-\-\- linear /dev/sdag:1-33                                                                                                                             0
+  [lv_rmeta_0]  ewi\-aor\-\-\- linear /dev/sda:0-0
+  [lv_rmeta_1]  ewi\-aor\-\-\- linear /dev/sdaa:0-0
+  [lv_rmeta_2]  ewi\-aor\-\-\- linear /dev/sdab:0-0
+  [lv_rmeta_3]  ewi\-aor\-\-\- linear /dev/sdac:0-0
+  [lv_rmeta_4]  ewi\-aor\-\-\- linear /dev/sdad:0-0
+  [lv_rmeta_5]  ewi\-aor\-\-\- linear /dev/sdae:0-0
+  [lv_rmeta_6]  ewi\-aor\-\-\- linear /dev/sdaf:0-0
+  [lv_rmeta_7]  ewi\-aor\-\-\- linear /dev/sdag:0-0
 .fi
 
 raid10 allows to add stripes but can't remove them.
@@ -1353,7 +1353,7 @@ We start with the linear LV.
 .nf
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV   Attr       LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
-  lv   -wi-a\-\-\-\-- 128.00m linear              1     0        /dev/sda(0)
+  lv   -wi\-a\-\-\-\-\- 128.00m linear              1     0        /dev/sda(0)
 .fi
 
 Then convert it to a 2-way raid1.
@@ -1364,11 +1364,11 @@ Then convert it to a 2-way raid1.
 
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV            Attr       LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
-  lv            rwi-a-r\-\-- 128.00m raid1  100.00       2     0        lv_rimage_0(0),lv_rimage_1(0)
-  [lv_rimage_0] iwi-aor\-\-- 128.00m linear              1     0        /dev/sda(0)
-  [lv_rimage_1] iwi-aor\-\-- 128.00m linear              1     0        /dev/sdhx(1)
-  [lv_rmeta_0]  ewi-aor\-\--   4.00m linear              1     0        /dev/sda(32)
-  [lv_rmeta_1]  ewi-aor\-\--   4.00m linear              1     0        /dev/sdhx(0)
+  lv            rwi\-a\-r\-\-\- 128.00m raid1  100.00       2     0        lv_rimage_0(0),lv_rimage_1(0)
+  [lv_rimage_0] iwi\-aor\-\-\- 128.00m linear              1     0        /dev/sda(0)
+  [lv_rimage_1] iwi\-aor\-\-\- 128.00m linear              1     0        /dev/sdhx(1)
+  [lv_rmeta_0]  ewi\-aor\-\-\-   4.00m linear              1     0        /dev/sda(32)
+  [lv_rmeta_1]  ewi\-aor\-\-\-   4.00m linear              1     0        /dev/sdhx(0)
 .fi
 
 Once the raid1 LV is fully synchronized we convert it to raid5_n (only 2-way raid1
@@ -1383,11 +1383,11 @@ conversion.
 
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV            Attr       LSize   Type    Cpy%Sync #DStr Stripe RSize Devices
-  lv            rwi-a-r\-\-- 128.00m raid5_n 100.00       1 64.00k     0 lv_rimage_0(0),lv_rimage_1(0)
-  [lv_rimage_0] iwi-aor\-\-- 128.00m linear               1     0      0 /dev/sda(0)
-  [lv_rimage_1] iwi-aor\-\-- 128.00m linear               1     0      0 /dev/sdhx(1)
-  [lv_rmeta_0]  ewi-aor\-\--   4.00m linear               1     0        /dev/sda(32)
-  [lv_rmeta_1]  ewi-aor\-\--   4.00m linear               1     0        /dev/sdhx(0)
+  lv            rwi\-a\-r\-\-\- 128.00m raid5_n 100.00       1 64.00k     0 lv_rimage_0(0),lv_rimage_1(0)
+  [lv_rimage_0] iwi\-aor\-\-\- 128.00m linear               1     0      0 /dev/sda(0)
+  [lv_rimage_1] iwi\-aor\-\-\- 128.00m linear               1     0      0 /dev/sdhx(1)
+  [lv_rmeta_0]  ewi\-aor\-\-\-   4.00m linear               1     0        /dev/sda(32)
+  [lv_rmeta_1]  ewi\-aor\-\-\-   4.00m linear               1     0        /dev/sdhx(0)
 .fi
 
 Now we'll change the number of data stripes from 1 to 5 and request 128K stripe size
@@ -1404,25 +1404,25 @@ or the LV can be reduced in size after the reshaping conversion has finished.
 
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV            Attr       LSize   Type    Cpy%Sync #DStr Stripe  RSize Devices
-  lv            rwi-a-r\-\-- 640.00m raid5_n 100.00       5 128.00k     6 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0),lv_rimage_3(0),lv_rimage_4(0),lv_rimage_5(0)
-  [lv_rimage_0] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sda(33)
-  [lv_rimage_0] iwi-aor\-\-- 132.00m linear               1      0        /dev/sda(0)
-  [lv_rimage_1] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sdhx(33)
-  [lv_rimage_1] iwi-aor\-\-- 132.00m linear               1      0        /dev/sdhx(1)
-  [lv_rimage_2] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sdhw(33)
-  [lv_rimage_2] iwi-aor\-\-- 132.00m linear               1      0        /dev/sdhw(1)
-  [lv_rimage_3] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sdhv(33)
-  [lv_rimage_3] iwi-aor\-\-- 132.00m linear               1      0        /dev/sdhv(1)
-  [lv_rimage_4] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sdhu(33)
-  [lv_rimage_4] iwi-aor\-\-- 132.00m linear               1      0        /dev/sdhu(1)
-  [lv_rimage_5] iwi-aor\-\-- 132.00m linear               1      0      1 /dev/sdht(33)
-  [lv_rimage_5] iwi-aor\-\-- 132.00m linear               1      0        /dev/sdht(1)
-  [lv_rmeta_0]  ewi-aor\-\--   4.00m linear               1      0        /dev/sda(32)
-  [lv_rmeta_1]  ewi-aor\-\--   4.00m linear               1      0        /dev/sdhx(0)
-  [lv_rmeta_2]  ewi-aor\-\--   4.00m linear               1      0        /dev/sdhw(0)
-  [lv_rmeta_3]  ewi-aor\-\--   4.00m linear               1      0        /dev/sdhv(0)
-  [lv_rmeta_4]  ewi-aor\-\--   4.00m linear               1      0        /dev/sdhu(0)
-  [lv_rmeta_5]  ewi-aor\-\--   4.00m linear               1      0        /dev/sdht(0)
+  lv            rwi\-a\-r\-\-\- 640.00m raid5_n 100.00       5 128.00k     6 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0),lv_rimage_3(0),lv_rimage_4(0),lv_rimage_5(0)
+  [lv_rimage_0] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sda(33)
+  [lv_rimage_0] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sda(0)
+  [lv_rimage_1] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sdhx(33)
+  [lv_rimage_1] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sdhx(1)
+  [lv_rimage_2] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sdhw(33)
+  [lv_rimage_2] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sdhw(1)
+  [lv_rimage_3] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sdhv(33)
+  [lv_rimage_3] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sdhv(1)
+  [lv_rimage_4] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sdhu(33)
+  [lv_rimage_4] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sdhu(1)
+  [lv_rimage_5] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sdht(33)
+  [lv_rimage_5] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sdht(1)
+  [lv_rmeta_0]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sda(32)
+  [lv_rmeta_1]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sdhx(0)
+  [lv_rmeta_2]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sdhw(0)
+  [lv_rmeta_3]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sdhv(0)
+  [lv_rmeta_4]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sdhu(0)
+  [lv_rmeta_5]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sdht(0)
 .fi
 
 Once the conversion has finished we can can convert to striped.
@@ -1433,8 +1433,8 @@ Once the conversion has finished we can can convert to striped.
 
 [root at vm46 ~]# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg|sed 's/  *$//'
   LV   Attr       LSize   Type    Cpy%Sync #DStr Stripe  RSize Devices
-  lv   -wi-a\-\-\-\-- 640.00m striped              5 128.00k       /dev/sda(33),/dev/sdhx(33),/dev/sdhw(33),/dev/sdhv(33),/dev/sdhu(33)
-  lv   -wi-a\-\-\-\-- 640.00m striped              5 128.00k       /dev/sda(0),/dev/sdhx(1),/dev/sdhw(1),/dev/sdhv(1),/dev/sdhu(1)
+  lv   -wi\-a\-\-\-\-\- 640.00m striped              5 128.00k       /dev/sda(33),/dev/sdhx(33),/dev/sdhw(33),/dev/sdhv(33),/dev/sdhu(33)
+  lv   -wi\-a\-\-\-\-\- 640.00m striped              5 128.00k       /dev/sda(0),/dev/sdhx(1),/dev/sdhw(1),/dev/sdhv(1),/dev/sdhu(1)
 .fi
 
 Reversing these steps wil convert a given striped LV to linear.
@@ -1554,7 +1554,7 @@ raid6_n_6
 RAID6 N continue
 .br
 \[bu]
-Fixed P-Syndrome N-1 and Q-Syndrome N with striped data
+Fixed P\-Syndrome N\-1 and Q\-Syndrome N with striped data
 .br
 \[bu]
 Used for RAID Takeover
@@ -1565,7 +1565,7 @@ raid6_ls_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_ls for N-1 disks with fixed Q-Syndrome N
+Same as raid5_ls for N\-1 disks with fixed Q\-Syndrome N
 .br
 \[bu]
 Used for RAID Takeover
@@ -1576,7 +1576,7 @@ raid6_la_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_la for N-1 disks with fixed Q-Syndrome N
+Same as raid5_la for N\-1 disks with fixed Q\-Syndrome N
 .br
 \[bu]
 Used forRAID Takeover
@@ -1587,7 +1587,7 @@ raid6_rs_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_rs for N-1 disks with fixed Q-Syndrome N
+Same as raid5_rs for N\-1 disks with fixed Q\-Syndrome N
 .br
 \[bu]
 Used for RAID Takeover
@@ -1598,7 +1598,7 @@ raid6_ra_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_ra for N-1 disks with fixed Q-Syndrome N
+Same as raid5_ra for N\-1 disks with fixed Q\-Syndrome N
 .br
 \[bu]
 Used for RAID Takeover
@@ -1704,9 +1704,9 @@ TODO
 
 .SH History
 
-The 2.6.38-rc1 version of the Linux kernel introduced a device-mapper
+The 2.6.38-rc1 version of the Linux kernel introduced a device\-mapper
 target to interface with the software RAID (MD) personalities.  This
-provided device-mapper with RAID 4/5/6 capabilities and a larger
+provided device\-mapper with RAID 4/5/6 capabilities and a larger
 development community.  Later, support for RAID1, RAID10, and RAID1E (RAID
 10 variants) were added.  Support for these new kernel RAID targets was
 added to LVM version 2.02.87.  The capabilities of the LVM \fBraid1\fP
diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index 7026b24..e2fa812 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -12,16 +12,16 @@ options to customize report and filter the report's output.
 
 Based on functionality, commands which make use of the reporting infrastructure
 are divided in two groups:
-.IP \fBReport-oriented commands\fP
+.IP \fBReport\-oriented commands\fP
 These commands inform about current LVM state and their primary role is to
 display this information in compendious way. To make a distinction, we will
-name this report as \fBmain report\fP. The set of report-only commands include:
+name this report as \fBmain report\fP. The set of report\-only commands include:
 pvs, vgs, lvs, pvdisplay, vgdisplay, lvdisplay, lvm devtypes, lvm fullreport.
 For further information about main report, see \fBmain report specifics\fP.
-.IP \fBProcessing-oriented commands\fP
+.IP \fBProcessing\-oriented commands\fP
 These commands are responsible for changing LVM state and they do not contain
-any main report as identified for report-oriented commands, they only perform
-some kind of processing. The set of processing-oriented commands includes:
+any main report as identified for report\-oriented commands, they only perform
+some kind of processing. The set of processing\-oriented commands includes:
 pvcreate, vgcreate, lvcreate, pvchange, vgchange, lvchange, pvremove, vgremove,
 lvremove, pvresize, vgextend, vgreduce, lvextend, lvreduce, lvresize, lvrename,
 pvscan, vgscan, lvscan, pvmove, vgcfgbackup, vgck, vgconvert, vgexport,
@@ -29,9 +29,9 @@ vgimport, vgmknodes.
 
 .RE
 If enabled, so called \fBlog report\fP is either displayed solely
-(for processing-oriented commands) or in addition to main report
-(for report-oriented commands). The log report contains a log of operations,
-messages and per-object status with complete object identification collected
+(for processing\-oriented commands) or in addition to main report
+(for report\-oriented commands). The log report contains a log of operations,
+messages and per\-object status with complete object identification collected
 during LVM command execution. See \fBlog report specifics\fP for more
 information about this report type.
 
@@ -137,7 +137,7 @@ Fields to include to current field set. See \fBmain report specifics\fP\ and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option extends.
 .IP - 3
-\-\-options|-o- FieldSet
+\-\-options|-o\- FieldSet
 .br
 Fields to exclude from current field set. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
@@ -159,7 +159,7 @@ Fields to sort by in ascending order. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option overrides.
 .IP - 3
-\-\-sort|-O- FieldSet
+\-\-sort|-O\- FieldSet
 .br
 Fields to sort by in descending order. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about fields sets configured with
@@ -249,7 +249,7 @@ Overrides report/bufffered configuration setting.
 
 The \fBFieldSet\fP mentioned in the lists above is a set of field names where
 each field name is delimited by "," character. Field set definition, sorting
-and selection may be repeated on command line (-o+/-o- includes/excludes fields
+and selection may be repeated on command line (-o+/-o\- includes/excludes fields
 to/from current list, for all the other repeatable options, the last value
 typed for the option on the command line is used). The \fBSelection\fP
 is a string with \fBselection criteria\fP, see also \fBSelection\fP paragraph
@@ -356,7 +356,7 @@ which case LVM will issue an error.
 
 For all main report subtypes except \fBfull\fP, it's not necessary to use
 \fB\-\-configreport ReportName\fP to denote which report any subsequent
-\fB-o, -O or -S\fP option applies to as they always apply to the single main
+\fB\-o, -O or -S\fP option applies to as they always apply to the single main
 report type. Currently, \fBlvm fullreport\fP is the only command that
 includes more than one \fBmain report\fP subtype. Therefore, the \-\-configreport
 is particularly suitable for the full report if you need to configure each of
@@ -387,20 +387,20 @@ log/command_log_selection
 
 .RE
 
-You always need to use \fB\-\-configreport log\fP together with \fB-o|\-\-options,
+You always need to use \fB\-\-configreport log\fP together with \fB\-o|\-\-options,
 -O|\-\-sort or -S|\-\-selection\fP to override configuration settings directly on
 command line for \fBlog report\fP. When compared to \fBmain report\fP, in
 addition to usual configuration settings for report fields and sorting, the
 \fBlog report\fP has also configuration option for selection -
 \fBreport/command_log_selection\fP. This configuration setting is provided for
-convenience so it's not necessary to use \fB-S|\-\-select\fP on command line
+convenience so it's not necessary to use \fB\-S|\-\-select\fP on command line
 each time an LVM command is executed and we need the same selection criteria
 to be applied for \fBlog report\fP. Default selection criteria used for
 \fBlog report\fP are
 \fBlog/command_log_selection="!(log_type=status && message=success)"\fP.
 This means that, by default, \fBlog report\fP doesn't display status messages
 about successful operation and it displays only rows with error, warning,
-print-type messages and messages about failure states (for more information,
+print\-type messages and messages about failure states (for more information,
 see \fBlog report content\fP below).
 
 .B Log report coverage
@@ -411,7 +411,7 @@ entities are iterated and processed one by one. It does not cover any command
 initialization nor command finalization stage. If there is any message issued
 out of log report's coverage range, such message goes directly to output,
 bypassing the \fBlog report\fP. By default, that is \fBstandard error output\fP
-for error and warning messages and \fBstandard output\fP for common print-like
+for error and warning messages and \fBstandard output\fP for common print\-like
 messages.
 
 When running LVM commands in \fBLVM shell\fP, the log report covers the whole
@@ -430,7 +430,7 @@ For these reasons and for completeness, it's not possible to rely fully on
 \fBlog report\fP as the only indicator of LVM command's status and the only
 place where all messages issued during LVM command execution are collected.
 You always need to check whether the command has not failed out of log
-report's range by checking the non-report output too.
+report's range by checking the non\-report output too.
 
 To help with this, LVM can separate output which you can then redirect to
 any \fBcustom file descriptor\fP that you prepare before running an LVM
@@ -441,7 +441,7 @@ descriptor numbers. See also \fBLVM_OUT_FD\fP, \fBLVM_ERR_FD\fP and
 man page.
 
 Also note that, by default, reports use the same file descriptor as
-common print-like messages, which is \fBstandard output\fP. If you plan to
+common print\-like messages, which is \fBstandard output\fP. If you plan to
 use \fBlog report\fP in your scripts or any external tool, you should use
 \fBLVM_OUT_FD\fP, \fBLVM_ERR_FD\fP and \fBLVM_REPORT_FD\fP to separate all
 output types to different file descriptors. For example, with bash, that
@@ -578,7 +578,7 @@ to display complete list of fields that you may use for the \fBlog report\fP.
 .SH Selection
 Selection is used for a report to display only rows that match
 \fBselection criteria\fP. All rows are displayed with the additional
-\fBselected\fP field (\fB-o selected\fP) displaying 1 if the row matches the
+\fBselected\fP field (\fB\-o selected\fP) displaying 1 if the row matches the
 \fISelection\fP and 0 otherwise. The \fBselection criteria\fP are a set of
 \fBstatements\fP combined by \fBlogical and grouping operators\fP.
 The \fBstatement\fP consists of a \fBfield\fP name for which a set of valid
@@ -708,9 +708,9 @@ demonstrating time expressions in selection criteria, see \fBEXAMPLES\fP section
 date
 .RS
 .IP
-YYYY-MM-DD
+YYYY\-MM\-DD
 .IP
-YYYY-MM, auto DD=1
+YYYY\-MM, auto DD=1
 .IP
 YYYY, auto MM=01 and DD=01
 .RE
@@ -735,7 +735,7 @@ timezone
 +hh or -hh
 .RE
 
-The full date/time specification is YYYY-MM-DD hh:mm:ss. Users are able
+The full date/time specification is YYYY\-MM\-DD hh:mm:ss. Users are able
 to leave date/time parts from right to left. Whenever these parts are left out,
 a range is assumed automatically with second granularity. For example:
 
@@ -795,12 +795,12 @@ month names ("January" - "December" or abbreviated as "Jan" - "Dec")
 .IP
 .BR VALUE " = " [VALUE " log_op " VALUE]
 .br
-For list-based types: string list. Matches strictly.
+For list\-based types: string list. Matches strictly.
 The log_op must always be of one type within the whole list value.
 .IP
 .BR VALUE " = " {VALUE " log_op " VALUE}
 .br
-For list-based types: string list. Matches a subset.
+For list\-based types: string list. Matches a subset.
 The log_op must always be of one type within the whole list value.
 .IP
 .BR VALUE " = " value
@@ -840,7 +840,7 @@ prefixes=0
 quoted=1
 columns_as_rows=0
 binary_values_as_numeric=0
-time_format="%Y-%m-%d %T %z"
+time_format="%Y\-%m\-%d %T %z"
 mark_hidden_devices=1
 two_word_unknown_device=0
 buffered=1
@@ -890,17 +890,17 @@ segs_sort="vg_name,lv_name,seg_start"
 
 # vgs
   VG #PV #LV #SN Attr   VSize   VFree  
-  vg   2   2   0 wz\-\-n- 200.00m 180.00m
+  vg   2   2   0 wz\-\-n\- 200.00m 180.00m
 
 # lvs
   LV    VG Attr       LSize Pool Origin Move Log Cpy%Sync Convert
-  lvol0 vg -wi-a\-\-\-\-- 4.00m                                    
-  lvol1 vg rwi-a-r\-\-- 4.00m                      100.00          
+  lvol0 vg -wi\-a\-\-\-\-\- 4.00m                                    
+  lvol1 vg rwi\-a\-r\-\-\- 4.00m                      100.00          
 
 # lvs \-\-segments
   LV    VG Attr       #Str Type   SSize
-  lvol0 vg -wi-a\-\-\-\--    1 linear 4.00m
-  lvol1 vg rwi-a-r\-\--    2 raid1  4.00m
+  lvol0 vg -wi\-a\-\-\-\-\-    1 linear 4.00m
+  lvol1 vg rwi\-a\-r\-\-\-    2 raid1  4.00m
 .fi
 
 We will use \fBreport/lvs_cols\fP and \fBreport/lvs_sort\fP configuration
@@ -921,7 +921,7 @@ lvs_sort="-lv_time"
   lvol0 4.00m  
 .fi
 
-You can use \fB-o|\-\-options\fP command line option to override current
+You can use \fB\-o|\-\-options\fP command line option to override current
 configuration directly on command line.
 
 .nf
@@ -935,12 +935,12 @@ configuration directly on command line.
   lvol1 4.00m             100.00   raid,raid1
   lvol0 4.00m                      linear    
 
-# lvs -o-origin
+# lvs -o\-origin
   LV    LSize Pool Cpy%Sync
   lvol1 4.00m      100.00  
   lvol0 4.00m              
 
-# lvs -o lv_name,lv_size,origin -o+lv_layout -o-origin -O lv_name
+# lvs -o lv_name,lv_size,origin -o+lv_layout -o\-origin -O lv_name
   LV    LSize Layout    
   lvol0 4.00m linear    
   lvol1 4.00m raid,raid1
@@ -1021,7 +1021,7 @@ compact_output=1
 .fi
 
 Alternatively, you can define which fields should be compacted by configuring
-\fBreport/compact_output_cols\fP configuration setting (or \fB-o|\-\-options #\fP
+\fBreport/compact_output_cols\fP configuration setting (or \fB\-o|\-\-options #\fP
 command line option).
 
 .nf
@@ -1048,7 +1048,7 @@ We will use \fBreport/compact_output=1\fP for subsequent examples.
 
 .SS Further formatting options
 
-By default, LVM displays sizes in reports in human-readable form which means
+By default, LVM displays sizes in reports in human\-readable form which means
 that the most suitable unit is used so it's easy to read. You can use
 \fBreport/units\fP configuration setting (or \fB\-\-units\fP option directly
 on command line) and \fBreport/suffix\fP
@@ -1166,7 +1166,7 @@ and time is displayed, including timezone.
 
 .nf
 # lvmconfig \-\-type full report/time_format
-time_format="%Y-%m-%d %T %z"
+time_format="%Y\-%m\-%d %T %z"
 
 # lvs -o+time
   LV    LSize Cpy%Sync CTime                     
@@ -1186,12 +1186,12 @@ time_format="%s"
 
 # lvs
   LV    Attr       LSize Cpy%Sync LV Tags   CTime                     
-  lvol1 rwi-a-r\-\-- 4.00m 100.00             1472468016                
-  lvol0 -wi-a\-\-\-\-- 4.00m          tagA,tagB 1472458517     
+  lvol1 rwi\-a\-r\-\-\- 4.00m 100.00             1472468016                
+  lvol0 -wi\-a\-\-\-\-\- 4.00m          tagA,tagB 1472458517     
 .fi
 
 The \fBlvs\fP does not display hidden LVs by default - to include these LVs
-in the output, you need to use \fB-a|\-\-all\fP command line option. Names for
+in the output, you need to use \fB\-a|\-\-all\fP command line option. Names for
 these hidden LVs are displayed within square brackets.
 
 .nf
@@ -1315,7 +1315,7 @@ look at the bottom of the help output, you can see section about
 # lvs -S help
  ...
 Selection operators
-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--
+\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-
 Comparison operators:
    =~  - Matching regular expression. [regex]
    !~  - Not matching regular expression. [regex]
@@ -1384,7 +1384,7 @@ together.
   lvol2 8.00m       
 .fi
 
-You can also use selection together with processing-oriented commands.
+You can also use selection together with processing\-oriented commands.
 
 .nf
 # lvchange \-\-addtag test -S 'size < 5000k'
@@ -1593,8 +1593,8 @@ Examples below demonstrates using freeform time expressions.
 .SS Command log reporting
 
 As described in \fBcategorization based on reporting facility\fP section
-at the beginning of this document, both \fBreport-oriented\fP and
-\fBprocessing-oriented\fP LVM commands can report the command log if
+at the beginning of this document, both \fBreport\-oriented\fP and
+\fBprocessing\-oriented\fP LVM commands can report the command log if
 this is enabled with \fBlog/report_command_log\fP configuration setting.
 Just like any other report, we can set the set of fields to display
 (\fBlog/command_log_cols\fP) and to sort by (\fBlog/command_log_sort\fP)
@@ -1659,8 +1659,8 @@ command_log_selection="all"
 .SS Handling multiple reports per single command
 
 To configure the log report directly on command line, we need to use
-\fB\-\-configreport\fP option before we start any \fB-o|\-\-options\fP,
-\fB-O|\-\-sort\fP or \fB-S|\-\-select\fP that is targeted for log report.
+\fB\-\-configreport\fP option before we start any \fB\-o|\-\-options\fP,
+\fB\-O|\-\-sort\fP or \fB\-S|\-\-select\fP that is targeted for log report.
 
 .nf
 # lvs -o lv_name,lv_size \-\-configreport log -o log_object_type, \\
diff --git a/man/lvmsadc.8_main b/man/lvmsadc.8_main
index c2781b8..43d24af 100644
--- a/man/lvmsadc.8_main
+++ b/man/lvmsadc.8_main
@@ -4,7 +4,7 @@ lvmsadc \(em LVM system activity data collector
 .SH "SYNOPSIS"
 .B lvmsadc
 .SH "DESCRIPTION"
-lvmsadc is not supported under LVM2. The device-mapper statistics
+lvmsadc is not supported under LVM2. The device\-mapper statistics
 facility provides similar performance metrics using the \fBdmstats(8)\fP
 command.
 .SH "SEE ALSO"
diff --git a/man/lvmsar.8_main b/man/lvmsar.8_main
index 0bbcbf3..765d8e7 100644
--- a/man/lvmsar.8_main
+++ b/man/lvmsar.8_main
@@ -4,7 +4,7 @@ lvmsar \(em LVM system activity reporter
 .SH "SYNOPSIS"
 .B lvmsar
 .SH "DESCRIPTION"
-lvmsar is not supported under LVM2. The device-mapper statistics
+lvmsar is not supported under LVM2. The device\-mapper statistics
 facility provides similar performance metrics using the \fBdmstats(8)\fP
 command.
 .SH "SEE ALSO"
diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index 6e59bb3..e773ebf 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -15,12 +15,12 @@ from accidental use by other hosts.
 The system_id is not a dynamic property, and can only be changed in very
 limited circumstances (see vgexport and vgimport).  Even limited changes
 to the VG system_id are not perfectly reflected across hosts.  A more
-coherent view of shared storage requires using an inter-host locking
+coherent view of shared storage requires using an inter\-host locking
 system to coordinate access and update caches.
 
 The system_id is a string uniquely identifying a host.  It can be manually
 set to a custom value or it can be assigned automatically by lvm using a
-unique identifier already available on the host, e.g. machine-id or uname.
+unique identifier already available on the host, e.g. machine\-id or uname.
 
 In vgcreate, the local system_id is saved in the new VG metadata.  The
 local host owns the new VG, and other hosts cannot use it.
@@ -72,7 +72,7 @@ A host using an old version of lvm without the system_id feature will not
 recognize a new system_id in VGs from other hosts.  Even though the old
 version of lvm is not blocked from reading a VG with a system_id, it is
 blocked from writing to the VG (or its LVs).  The new system_id changes
-the write mode of a VG, making it appear read-only to previous lvm
+the write mode of a VG, making it appear read\-only to previous lvm
 versions.
 
 This also means that if a host downgrades its version of lvm, it would
@@ -144,12 +144,12 @@ global {
 .B machineid
 .br
 
-The content of /etc/machine-id is used as the system_id if available.
+The content of /etc/machine\-id is used as the system_id if available.
 See
-.BR machine-id (5)
+.BR machine\-id (5)
 and
-.BR systemd-machine-id-setup (1)
-to check if machine-id is available on the host.
+.BR systemd\-machine\-id\-setup (1)
+to check if machine\-id is available on the host.
 
 .I lvm.conf
 .nf
@@ -348,7 +348,7 @@ could be pvscan \-\-cache, or vgs \-\-foreign.
 .BR vgimport (8),
 .BR vgexport (8),
 .BR lvm.conf (5),
-.BR machine-id (5),
+.BR machine\-id (5),
 .BR uname (2),
 .BR vgs (8)
 
diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index b0e3aa0..cefe943 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -117,8 +117,8 @@ Create an LV that will hold thin pool metadata.
 
 # lvs
   LV        VG Attr       LSize
-  pool0     vg -wi-a\-\-\-\-- 10.00g
-  pool0meta vg -wi-a\-\-\-\-- 1.00g
+  pool0     vg -wi\-a\-\-\-\-\- 10.00g
+  pool0meta vg -wi\-a\-\-\-\-\- 1.00g
 
 .SS 3. create ThinPoolLV
 
@@ -129,21 +129,21 @@ ThinMetaLV is renamed to hidden ThinPoolLV_tmeta.
 The new ThinPoolLV takes the previous name of ThinDataLV.
 .fi
 
-.B lvconvert \-\-type thin-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.B lvconvert \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
 
 .I Example
 .br
-# lvconvert \-\-type thin-pool \-\-poolmetadata vg/pool0meta vg/pool0
+# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
 
 # lvs vg/pool0
   LV    VG Attr       LSize  Pool Origin Data% Meta%
-  pool0 vg twi-a-tz\-\- 10.00g      0.00   0.00
+  pool0 vg twi\-a\-tz\-\- 10.00g      0.00   0.00
 
 # lvs \-a
   LV            VG Attr       LSize
-  pool0         vg twi-a-tz\-\- 10.00g
-  [pool0_tdata] vg Twi-ao\-\-\-\- 10.00g
-  [pool0_tmeta] vg ewi-ao\-\-\-\- 1.00g
+  pool0         vg twi\-a\-tz\-\- 10.00g
+  [pool0_tdata] vg Twi\-ao\-\-\-\- 10.00g
+  [pool0_tmeta] vg ewi\-ao\-\-\-\- 1.00g
 
 .SS 4. create ThinLV
 
@@ -171,8 +171,8 @@ Create another thin LV in the same thin pool:
 
 # lvs vg/thin1 vg/thin2
   LV    VG Attr       LSize Pool  Origin Data%
-  thin1 vg Vwi-a-tz\-\- 1.00t pool0        0.00
-  thin2 vg Vwi-a-tz\-\- 1.00t pool0        0.00
+  thin1 vg Vwi\-a\-tz\-\- 1.00t pool0        0.00
+  thin2 vg Vwi\-a\-tz\-\- 1.00t pool0        0.00
 
 .SS 5. create SnapLV
 
@@ -204,9 +204,9 @@ Create a snapshot of the first snapshot:
 
 # lvs vg/thin1s1 vg/thin1s2 vg/thin1s1s1
   LV        VG Attr       LSize Pool  Origin
-  thin1s1   vg Vwi\-\--tz-k 1.00t pool0 thin1
-  thin1s2   vg Vwi\-\--tz-k 1.00t pool0 thin1
-  thin1s1s1 vg Vwi\-\--tz-k 1.00t pool0 thin1s1
+  thin1s1   vg Vwi\-\-\-tz\-k 1.00t pool0 thin1
+  thin1s2   vg Vwi\-\-\-tz\-k 1.00t pool0 thin1
+  thin1s1s1 vg Vwi\-\-\-tz\-k 1.00t pool0 thin1s1
 
 .SS 6. activate SnapLV
 
@@ -222,7 +222,7 @@ or vgchange to activate thin snapshots with the "k" attribute.
 
 # lvs vg/thin1s1
   LV      VG Attr       LSize Pool  Origin
-  thin1s1 vg Vwi-a-tz-k 1.00t pool0 thin1
+  thin1s1 vg Vwi\-a\-tz\-k 1.00t pool0 thin1
 
 .SH Thin Topics
 
@@ -297,9 +297,9 @@ same VG.
 # lvconvert \-\-type thin\-pool vg/pool0
 
 # lvs \-a
-  pool0           vg          twi-a-tz\-\-  10.00g
-  [pool0_tdata]   vg          Twi-ao\-\-\-\-  10.00g
-  [pool0_tmeta]   vg          ewi-ao\-\-\-\-  16.00m
+  pool0           vg          twi\-a\-tz\-\-  10.00g
+  [pool0_tdata]   vg          Twi\-ao\-\-\-\-  10.00g
+  [pool0_tmeta]   vg          ewi\-ao\-\-\-\-  16.00m
 .fi
 
 
@@ -381,10 +381,10 @@ explicitly.
 # lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
 
 # lvs \-a
-  [lvol0_pmspare] vg          ewi\-\-\-\-\-\--
-  pool0           vg          twi\-\--tz\-\-
-  [pool0_tdata]   vg          Twi\-\-\-\-\-\--
-  [pool0_tmeta]   vg          ewi\-\-\-\-\-\--
+  [lvol0_pmspare] vg          ewi\-\-\-\-\-\-\-
+  pool0           vg          twi\-\-\-tz\-\-
+  [pool0_tdata]   vg          Twi\-\-\-\-\-\-\-
+  [pool0_tmeta]   vg          ewi\-\-\-\-\-\-\-
 .fi
 
 The "Metadata check and repair" section describes the use of
@@ -466,7 +466,7 @@ displayed by lvs:
 .nf
 # lvs vg/thin1s1
   LV         VG  Attr       LSize Pool  Origin
-  thin1s1    vg  Vwi\-\--tz-k 1.00t pool0 thin1
+  thin1s1    vg  Vwi\-\-\-tz\-k 1.00t pool0 thin1
 .fi
 
 This flag causes the snapshot LV to be skipped, i.e. not activated,
@@ -539,7 +539,7 @@ Command to extend thin pool data space:
 1. A thin pool LV is using 26.96% of its data blocks.
 # lvs
   LV    VG           Attr       LSize   Pool  Origin Data%
-  pool0 vg           twi-a-tz\-\-  10.00g               26.96
+  pool0 vg           twi\-a\-tz\-\-  10.00g               26.96
 
 2. Double the amount of physical space in the thin pool LV.
 # lvextend \-L+10G vg/pool0
@@ -547,7 +547,7 @@ Command to extend thin pool data space:
 3. The percentage of used data blocks is half the previous value.
 # lvs
   LV    VG           Attr       LSize   Pool  Origin Data%
-  pool0 vg           twi-a-tz\-\-  20.00g               13.48
+  pool0 vg           twi\-a\-tz\-\-  20.00g               13.48
 .fi
 
 Other methods of increasing free data space in a thin pool LV
@@ -579,9 +579,9 @@ Command to extend thin pool metadata space:
 .nf
 # lvs \-a \-oname,attr,size vg
   LV              Attr       LSize
-  pool0           twi-a-tz\-\-  20.00g
-  [pool0_tdata]   Twi-ao\-\-\-\-  20.00g
-  [pool0_tmeta]   ewi-ao\-\-\-\-  12.00m
+  pool0           twi\-a\-tz\-\-  20.00g
+  [pool0_tdata]   Twi\-ao\-\-\-\-  20.00g
+  [pool0_tmeta]   ewi\-ao\-\-\-\-  12.00m
 .fi
 
 3. Double the amount of physical space in the thin metadata LV.
@@ -621,36 +621,36 @@ thin pool.  The fstrim command restores the physical space to the thin pool.
 .nf
 # lvs \-a \-oname,attr,size,pool_lv,origin,data_percent,metadata_percent vg
 LV              Attr       LSize   Pool  Origin Data%  Meta%
-pool0           twi-a-tz\-\-  10.00g               47.01  21.03
-thin1           Vwi-aotz\-\- 100.00g pool0          2.70
+pool0           twi\-a\-tz\-\-  10.00g               47.01  21.03
+thin1           Vwi\-aotz\-\- 100.00g pool0          2.70
 
 # df \-h /mnt/X
 Filesystem            Size  Used Avail Use% Mounted on
-/dev/mapper/vg-thin1   99G  1.1G   93G   2% /mnt/X
+/dev/mapper/vg\-thin1   99G  1.1G   93G   2% /mnt/X
 
 # dd if=/dev/zero of=/mnt/X/1Gfile bs=4096 count=262144; sync
 
 # lvs
-pool0           vg   twi-a-tz\-\-  10.00g               57.01  25.26
-thin1           vg   Vwi-aotz\-\- 100.00g pool0          3.70
+pool0           vg   twi\-a\-tz\-\-  10.00g               57.01  25.26
+thin1           vg   Vwi\-aotz\-\- 100.00g pool0          3.70
 
 # df \-h /mnt/X
-/dev/mapper/vg-thin1   99G  2.1G   92G   3% /mnt/X
+/dev/mapper/vg\-thin1   99G  2.1G   92G   3% /mnt/X
 
 # rm /mnt/X/1Gfile
 
 # lvs
-pool0           vg   twi-a-tz\-\-  10.00g               57.01  25.26
-thin1           vg   Vwi-aotz\-\- 100.00g pool0          3.70
+pool0           vg   twi\-a\-tz\-\-  10.00g               57.01  25.26
+thin1           vg   Vwi\-aotz\-\- 100.00g pool0          3.70
 
 # df \-h /mnt/X
-/dev/mapper/vg-thin1   99G  1.1G   93G   2% /mnt/X
+/dev/mapper/vg\-thin1   99G  1.1G   93G   2% /mnt/X
 
 # fstrim \-v /mnt/X
 
 # lvs
-pool0           vg   twi-a-tz\-\-  10.00g               47.01  21.03
-thin1           vg   Vwi-aotz\-\- 100.00g pool0          2.70
+pool0           vg   twi\-a\-tz\-\-  10.00g               47.01  21.03
+thin1           vg   Vwi\-aotz\-\- 100.00g pool0          2.70
 .fi
 
 The "Discard" section covers an option for automatically freeing data
@@ -773,7 +773,7 @@ return to normal operation.
 While waiting to be extended, the thin pool will queue writes for up to 60
 seconds (the default).  If data space has not been extended after this
 time, the queued writes will return an error to the caller, e.g. the file
-system.  This can result in file system corruption for non-journaled file
+system.  This can result in file system corruption for non\-journaled file
 systems that may require fsck.  When a thin pool returns errors for writes
 to a thin LV, any file system is subject to losing unsynced user data.
 
@@ -799,7 +799,7 @@ the thin pool LV:
 .nf
 # lvs vg/pool0
   LV     VG           Attr       LSize   Pool  Origin Data%
-  pool0  vg           twi-a-tz\-\- 512.00m              100.00
+  pool0  vg           twi\-a\-tz\-\- 512.00m              100.00
 .fi
 
 .I causes
@@ -901,7 +901,7 @@ To see the default values of these settings, run:
 To change these values globally, edit
 .BR lvm.conf (5).
 
-To change these values on a per-VG or per-LV basis, attach a "profile" to
+To change these values on a per\-VG or per\-LV basis, attach a "profile" to
 the VG or LV.  A profile is a collection of config settings, saved in a
 local text file (using the lvm.conf format).  lvm looks for profiles in
 the profile_dir directory, e.g. /etc/lvm/profile/.  Once attached to a VG
@@ -942,7 +942,7 @@ activation {
 
 # lvchange \-\-metadataprofile pool0extend vg/pool0
 
-# lvextend \-\-use-policies vg/pool0
+# lvextend \-\-use\-policies vg/pool0
 .fi
 
 .I Notes
@@ -954,7 +954,7 @@ file with the profile also needs to be moved.
 .IP \[bu] 2
 Only certain settings can be used in a VG or LV profile, see:
 .br
-.B lvmconfig \-\-type profilable-metadata.
+.B lvmconfig \-\-type profilable\-metadata.
 
 .IP \[bu] 2
 An LV without a profile of its own will inherit the VG profile.
@@ -1130,8 +1130,8 @@ to read unwritten parts of the thin snapshot.
 
 # lvs vg/lve vg/snaplve
   LV      VG  Attr       LSize  Pool  Origin Data%
-  lve     vg  ori\-\-\-\-\-\-- 10.00g
-  snaplve vg  Vwi-a-tz\-\- 10.00g pool0 lve      0.00
+  lve     vg  ori\-\-\-\-\-\-\- 10.00g
+  snaplve vg  Vwi\-a\-tz\-\- 10.00g pool0 lve      0.00
 .fi
 
 
@@ -1163,15 +1163,15 @@ name of ExampleLV.
 # lvcreate \-n lv_example \-L 10G vg
 
 # lvs
-  lv_example      vg          -wi-a\-\-\-\--  10.00g
+  lv_example      vg          -wi\-a\-\-\-\-\-  10.00g
 
 # lvconvert \-\-type thin \-\-thinpool vg/pool0
           \-\-originname lv_external \-\-thin vg/lv_example
 
 # lvs
   LV              VG          Attr       LSize   Pool  Origin
-  lv_example      vg          Vwi-a-tz\-\-  10.00g pool0 lv_external
-  lv_external     vg          ori\-\-\-\-\-\--  10.00g
+  lv_example      vg          Vwi\-a\-tz\-\-  10.00g pool0 lv_external
+  lv_external     vg          ori\-\-\-\-\-\-\-  10.00g
 .fi
 
 
@@ -1193,12 +1193,12 @@ and combines the two into a thin pool LV.
 
 # lvs vg/pool0
   LV    VG  Attr       LSize Pool Origin Data%
-  pool0 vg  twi-a-tz\-\- 8.00m               0.00
+  pool0 vg  twi\-a\-tz\-\- 8.00m               0.00
 
 # lvs \-a
-  pool0           vg          twi-a-tz\-\-   8.00m
-  [pool0_tdata]   vg          Twi-ao\-\-\-\-   8.00m
-  [pool0_tmeta]   vg          ewi-ao\-\-\-\-   8.00m
+  pool0           vg          twi\-a\-tz\-\-   8.00m
+  [pool0_tdata]   vg          Twi\-ao\-\-\-\-   8.00m
+  [pool0_tmeta]   vg          ewi\-ao\-\-\-\-   8.00m
 .fi
 
 
@@ -1232,10 +1232,10 @@ Equivalent to:
 # lvcreate \-L8M \-V2G \-n thin1 \-\-thinpool vg/pool0
 
 # lvs \-a
-  pool0           vg          twi-a-tz\-\-   8.00m
-  [pool0_tdata]   vg          Twi-ao\-\-\-\-   8.00m
-  [pool0_tmeta]   vg          ewi-ao\-\-\-\-   8.00m
-  thin1           vg          Vwi-a-tz\-\-   2.00g pool0
+  pool0           vg          twi\-a\-tz\-\-   8.00m
+  [pool0_tdata]   vg          Twi\-ao\-\-\-\-   8.00m
+  [pool0_tmeta]   vg          ewi\-ao\-\-\-\-   8.00m
+  thin1           vg          Vwi\-a\-tz\-\-   2.00g pool0
 .fi
 
 
@@ -1260,16 +1260,16 @@ activated.
 .nf
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
-  pool0   vg twi-a-tz\-\-  10.00g
-  thin1   vg Vwi-a-tz\-\- 100.00g pool0
-  thin1s1 vg Vwi-a-tz-k 100.00g pool0 thin1
+  pool0   vg twi\-a\-tz\-\-  10.00g
+  thin1   vg Vwi\-a\-tz\-\- 100.00g pool0
+  thin1s1 vg Vwi\-a\-tz\-k 100.00g pool0 thin1
 
 # lvconvert \-\-merge vg/thin1s1
 
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
-  pool0   vg twi-a-tz\-\-  10.00g
-  thin1   vg Vwi-a-tz\-\- 100.00g pool0
+  pool0   vg twi\-a\-tz\-\-  10.00g
+  thin1   vg Vwi\-a\-tz\-\- 100.00g pool0
 .fi
 
 .I Example
@@ -1279,13 +1279,13 @@ Delayed merging of open LVs.
 
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
-  pool0   vg twi-a-tz\-\-  10.00g
-  thin1   vg Vwi-aotz\-\- 100.00g pool0
-  thin1s1 vg Vwi-aotz-k 100.00g pool0 thin1
+  pool0   vg twi\-a\-tz\-\-  10.00g
+  thin1   vg Vwi\-aotz\-\- 100.00g pool0
+  thin1s1 vg Vwi\-aotz\-k 100.00g pool0 thin1
 
 # df
-/dev/mapper/vg-thin1            100G   33M  100G   1% /mnt/X
-/dev/mapper/vg-thin1s1          100G   33M  100G   1% /mnt/Xs
+/dev/mapper/vg\-thin1            100G   33M  100G   1% /mnt/X
+/dev/mapper/vg\-thin1s1          100G   33M  100G   1% /mnt/Xs
 
 # ls /mnt/X
 file1 file2 file3
@@ -1302,11 +1302,11 @@ Merging of thin snapshot thin1s1 will occur on next activation.
 
 # lvs \-a vg
   LV              VG   Attr       LSize   Pool  Origin
-  pool0           vg   twi-a-tz\-\-  10.00g
-  [pool0_tdata]   vg   Twi-ao\-\-\-\-  10.00g
-  [pool0_tmeta]   vg   ewi-ao\-\-\-\-   1.00g
-  thin1           vg   Owi-a-tz\-\- 100.00g pool0
-  [thin1s1]       vg   Swi-a-tz-k 100.00g pool0 thin1
+  pool0           vg   twi\-a\-tz\-\-  10.00g
+  [pool0_tdata]   vg   Twi\-ao\-\-\-\-  10.00g
+  [pool0_tmeta]   vg   ewi\-ao\-\-\-\-   1.00g
+  thin1           vg   Owi\-a\-tz\-\- 100.00g pool0
+  [thin1s1]       vg   Swi\-a\-tz\-k 100.00g pool0 thin1
 
 # lvchange \-an vg/thin1
 # lvchange \-ay vg/thin1


