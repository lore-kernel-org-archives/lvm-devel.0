From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 14 Apr 2021 09:07:41 +0000 (GMT)
Subject: main - man: typography
Message-ID: <20210414090741.0D03B3987C24@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=353718785fb9da3bebe59d6f1011b1f1df0c61d1
Commit:        353718785fb9da3bebe59d6f1011b1f1df0c61d1
Parent:        0004ffa73a1378993064a94e4ccb785699a2ed79
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 13 15:26:54 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 14 11:04:04 2021 +0200

man: typography

With to use .TP where it's easy and doesn't change layout
(since .HP is marked as deprecated) - but .TP is not always perfetc match.

Avoid submitting empty lines to troff and replace them mostly with .P
and use '.' at line start to preserve 'visual' presence of empty line
while editing man page manually when there is no extra space needed.

Fix some markup.

Add some missing SEE ALSO section.

Drop some white-space at end-of-lines.

Improve hyphenation logic so we do not split options.

Use '.IP numbers' only with first one the row (others in row
automatically derive this value)

Use automatic enumeration for .SH titles.

Guidelines in-use:
https://man7.org/linux/man-pages/man7/groff.7.html
https://www.gnu.org/software/groff/manual/html_node/Man-usage.html
https://www.gnu.org/software/groff/manual/html_node/Lists-in-ms.html
---
 man/blkdeactivate.8_main             |  81 ++--
 man/cmirrord.8_main                  |  30 +-
 man/dmeventd.8_main                  |  77 ++--
 man/dmfilemapd.8_main                |  79 ++--
 man/dmsetup.8_main                   | 190 ++++----
 man/dmstats.8_main                   | 418 ++++++++----------
 man/fsadm.8_main                     |  46 +-
 man/lvm.8_main                       |  54 ++-
 man/lvm.conf.5_main                  |  83 ++--
 man/lvm2-activation-generator.8_main |  53 ++-
 man/lvmcache.7_main                  | 472 ++++++++++----------
 man/lvmdbusd.8_main                  |  19 +-
 man/lvmdump.8_main                   |  79 ++--
 man/lvmlockctl.8_main                | 135 +++---
 man/lvmlockd.8_main                  | 614 +++++++++++++-------------
 man/lvmpolld.8_main                  |  56 ++-
 man/lvmreport.7_main                 | 332 +++++++-------
 man/lvmsadc.8_main                   |  18 +-
 man/lvmsar.8_main                    |  18 +-
 man/lvmsystemid.7_main               | 200 +++++----
 man/lvmthin.7_main                   | 809 ++++++++++++++++-------------------
 man/lvmvdo.7_main                    | 172 +++++---
 22 files changed, 1972 insertions(+), 2063 deletions(-)

diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index 06af52e52..a832b1af1 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -1,19 +1,34 @@
 .TH "BLKDEACTIVATE" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-.SH "NAME"
+.
+.SH NAME
+.
 blkdeactivate \(em utility to deactivate block devices
+.
 .SH SYNOPSIS
+.
+.ad l
+.nh
 .B blkdeactivate
-.RB [ -d \  \fIdm_options\fP ]
+.RB [ -d
+.IR dm_options ]
 .RB [ -e ]
 .RB [ -h ]
-.RB [ -l \  \fIlvm_options\fP ]
-.RB [ -m \  \fImpath_options\fP ]
-.RB [ -r \  \fImdraid_options\fP ]
-.RB [ -o \  \fIvdo_options\fP ]
+.RB [ -l
+.IR lvm_options ]
+.RB [ -m
+.IR mpath_options ]
+.RB [ -r
+.IR mdraid_options ]
+.RB [ -o
+.IR vdo_options ]
 .RB [ -u ]
 .RB [ -v ]
 .RI [ device ]
+.hy
+.ad b
+.
 .SH DESCRIPTION
+.
 The blkdeactivate utility deactivates block devices. For mounted
 block devices, it attempts to unmount it automatically before
 trying to deactivate. The utility currently supports
@@ -22,9 +37,11 @@ software RAID MD devices. LVM volumes are handled directly
 using the \fBlvm\fP(8) command, the rest of device-mapper
 based devices are handled using the \fBdmsetup\fP(8) command.
 MD devices are handled using the \fBmdadm\fP(8) command.
+.
 .SH OPTIONS
+.
 .TP
-.BR -d ", " --dmoptions \ \fIdm_options\fP
+.BR -d | --dmoptions " " \fIdm_options
 Comma separated list of device-mapper specific options.
 Accepted \fBdmsetup\fP(8) options are:
 .RS
@@ -33,17 +50,20 @@ Retry removal several times in case of failure.
 .IP \fIforce\fP
 Force device removal.
 .RE
+.
 .TP
-.BR -e ", " --errors
+.BR -e | --errors
 Show errors reported from tools called by \fBblkdeactivate\fP. Without this
 option, any error messages from these external tools are suppressed and the
 \fBblkdeactivate\fP itself provides only a summary message to indicate
 the device was skipped.
+.
 .TP
-.BR -h ", " --help
+.BR -h | --help
 Display the help text.
+.
 .TP
-.BR -l ", " --lvmoptions \ \fIlvm_options\fP
+.BR -l | --lvmoptions " " \fIlvm_options
 Comma-separated list of LVM specific options:
 .RS
 .IP \fIretry\fP
@@ -53,8 +73,9 @@ Deactivate the whole LVM Volume Group when processing a Logical Volume.
 Deactivating the Volume Group as a whole is quicker than deactivating
 each Logical Volume separately.
 .RE
+.
 .TP
-.BR -m ", " --mpathoptions \ \fImpath_options\fP
+.BR -m | --mpathoptions " " \fImpath_options
 Comma-separated list of device-mapper multipath specific options:
 .RS
 .IP \fIdisablequeueing\fP
@@ -63,68 +84,74 @@ This avoids a situation where blkdeactivate may end up waiting if
 all the paths are unavailable for any underlying device-mapper multipath
 device.
 .RE
+.
 .TP
-.BR -r ", " --mdraidoptions \ \fImdraid_options\fP
+.BR -r | --mdraidoptions " " \fImdraid_options
 Comma-separated list of MD RAID specific options:
 .RS
 .IP \fIwait\fP
 Wait MD device's resync, recovery or reshape action to complete
 before deactivation.
 .RE
-
+.
 .TP
-.BR -o ", " --vdooptions \ \fIvdo_options\fP
+.BR -o | --vdooptions " " \fIvdo_options
 Comma-separated list of VDO specific options:
 .RS
 .IP \fIconfigfile=file\fP
 Use specified VDO configuration file.
 .RE
-
+.
 .TP
-.BR -u ", " --umount
+.BR -u | --umount
 Unmount a mounted device before trying to deactivate it.
 Without this option used, a device that is mounted is not deactivated.
+.
 .TP
 .BR -v ", " --verbose
-Run in verbose mode. Use --vv for even more verbose mode.
+Run in verbose mode. Use \fB-vv\fP for even more verbose mode.
+.
 .SH EXAMPLES
 .
 Deactivate all supported block devices found in the system, skipping mounted
 devices.
-.BR
+.br
 #
 .B blkdeactivate
-.BR
+.br
 .P
 Deactivate all supported block devices found in the system, unmounting any
 mounted devices first, if possible.
-.BR
+.br
 #
 .B blkdeactivate -u
-.BR
+.br
 .P
-Deactivate the device /dev/vg/lvol0 together with all its holders, unmounting 
+Deactivate the device /dev/vg/lvol0 together with all its holders, unmounting
 any mounted devices first, if possible.
-.BR
+.br
 #
 .B blkdeactivate -u /dev/vg/lvol0
-.BR
+.br
 .P
 Deactivate all supported block devices found in the system. If the deactivation
 of a device-mapper device fails, retry it. Deactivate the whole
 Volume Group at once when processing an LVM Logical Volume.
-.BR
+.br
 #
 .B blkdeactivate -u -d retry -l wholevg
-.BR
+.br
 .P
 Deactivate all supported block devices found in the system. If the deactivation
 of a device-mapper device fails, retry it and force removal.
-.BR
+.br
 #
 .B blkdeactivate -d force,retry
 .
 .SH SEE ALSO
+.
+.nh
+.ad l
 .BR dmsetup (8),
 .BR lsblk (8),
 .BR lvm (8),
diff --git a/man/cmirrord.8_main b/man/cmirrord.8_main
index d49fa52a0..b841ae427 100644
--- a/man/cmirrord.8_main
+++ b/man/cmirrord.8_main
@@ -1,35 +1,45 @@
 .TH CMIRRORD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.
 .SH NAME
+.
 cmirrord \(em cluster mirror log daemon
-
+.
 .SH SYNOPSIS
-\fBcmirrord\fR [\fB-f\fR] [\fB-h\fR]
-
+.
+.B cmirrord
+.RB [ -f | --foreground ]
+.RB [ -h | --help ]
+.
 .SH DESCRIPTION
+.
 \fBcmirrord\fP is the daemon that tracks mirror log information in a cluster.
 It is specific to device-mapper based mirrors (and by extension, LVM
 cluster mirrors).  Cluster mirrors are not possible without this daemon
 running.
-
+.P
 This daemon relies on the cluster infrastructure provided by the corosync,
 which must be set up and running in order for cmirrord to function.
-
+.P
 Output is logged via \fBsyslog\fP(3). The \fBSIGUSR1 signal\fP(7) can be
 issued to \fBcmirrord\fP to gather current status information for debugging
 purposes.
-
+.P
 Once started, \fBcmirrord\fP will run until it is shutdown via \fBSIGINT\fP
 signal. If there are still active cluster mirrors, however, the signal will be
 ignored. Active cluster mirrors should be shutdown before stopping the cluster
 mirror log daemon.
-
+.
 .SH OPTIONS
-.IP "\fB-f\fR, \fB--foreground\fR" 4
+.
+.TP
+.BR -f | --foreground
 Do not fork and log to the terminal.
-.IP "\fB-h\fR, \fB--help\fR" 4
+.TP
+.BR -h | --help
 Print usage.
-
+.
 .SH SEE ALSO
+.
 .BR lvmlockd (8),
 .BR lvm (8),
 .BR syslog (3),
diff --git a/man/dmeventd.8_main b/man/dmeventd.8_main
index dc4abf627..123073b18 100644
--- a/man/dmeventd.8_main
+++ b/man/dmeventd.8_main
@@ -23,70 +23,63 @@ dmeventd is the event monitoring daemon for device-mapper devices.
 Library plugins can register and carry out actions triggered when
 particular events occur.
 .
-.
 .SH OPTIONS
 .
-.HP
-.BR -d
-.br
-Repeat from 1 to 3 times (
-.BR -d ,
+.TP
+.B -d
+Repeat from 1 to 3 times
+.RB ( -d ,
 .BR -dd ,
-.BR -ddd
-) to increase the detail of
+.BR -ddd )
+to increase the detail of
 debug messages sent to syslog.
 Each extra d adds more debugging information.
 .
-.HP
-.BR -f
-.br
+.TP
+.B -f
 Don't fork, run in the foreground.
 .
-.HP
-.BR -h
-.br
+.TP
+.B -h
 Show help information.
 .
-.HP
-.BR -l
-.br
+.TP
+.B -l
 Log through stdout and stderr instead of syslog.
 This option works only with option -f, otherwise it is ignored.
 .
-.HP
-.BR -?
-.br
+.TP
+.B -?
 Show help information on stderr.
 .
-.HP
-.BR -R
-.br
+.TP
+.B -R
 Replace a running dmeventd instance. The running dmeventd must be version
 2.02.77 or newer. The new dmeventd instance will obtain a list of devices and
 events to monitor from the currently running daemon.
 .
-.HP
-.BR -V
-.br
+.TP
+.B -V
 Show version of dmeventd.
 .
 .SH LVM PLUGINS
 .
-.HP
-.BR Mirror
+.TP
+.B Mirror
+Attempts to handle device failure automatically.
 .br
-Attempts to handle device failure automatically. See
+See
 .BR lvm.conf (5).
 .
-.HP
-.BR Raid
+.TP
+.B Raid
+Attempts to handle device failure automatically.
 .br
-Attempts to handle device failure automatically. See
+See
 .BR lvm.conf (5).
 .
-.HP
-.BR Snapshot
-.br
+.TP
+.B Snapshot
 Monitors how full a snapshot is becoming and emits a warning to
 syslog when it exceeds 80% full.
 The warning is repeated when 85%, 90% and 95% of the snapshot is filled.
@@ -95,9 +88,8 @@ See
 Snapshot which runs out of space gets invalid and when it is mounted,
 it gets umounted if possible.
 .
-.HP
-.BR Thin
-.br
+.TP
+.B Thin
 Monitors how full a thin pool data and metadata is becoming and emits
 a warning to syslog when it exceeds 80% full.
 The warning is repeated when more then 85%, 90% and 95%
@@ -123,12 +115,11 @@ Command is executed with environmental variable
 in this environment will not try to interact with dmeventd.
 To see the fullness of a thin pool command may check these
 two environmental variables
-\fBDMEVENTD_THIN_POOL_DATA\fP and \fBDMEVENTD_THIN_POOL_METADATA\fP.
+\fBDMEVENTD_THIN_POOL_DATA\fP and \fBDMEVENTD_THIN_POOL_\:METADATA\fP.
 Command can also read status with tools like \fBlvs\fP(8).
-
-.HP
-.BR Vdo
-.br
+.
+.TP
+.B Vdo
 Monitors how full a VDO pool data is becoming and emits
 a warning to syslog when it exceeds 80% full.
 The warning is repeated when more then 85%, 90% and 95%
diff --git a/man/dmfilemapd.8_main b/man/dmfilemapd.8_main
index c93349ad4..864933609 100644
--- a/man/dmfilemapd.8_main
+++ b/man/dmfilemapd.8_main
@@ -1,23 +1,23 @@
 .TH DMFILEMAPD 8 "Dec 17 2016" "Linux" "MAINTENANCE COMMANDS"
-
+.
 .de OPT_FD
-.  RB [ file_descriptor ]
+.  I file_descriptor
 ..
 .
 .de OPT_GROUP
-.  RB [ group_id ]
+.  I group_id
 ..
 .
 .de OPT_PATH
-.  RB [ abs_path ]
+.  I abs_path
 ..
 .
 .de OPT_MODE
-.  RB [ mode ]
+.  BR inode | path
 ..
 .
 .de OPT_DEBUG
-.  RB [ foreground [ verbose ]]
+.  RI [ foreground " [" verbose ]]
 ..
 .
 .SH NAME
@@ -29,7 +29,7 @@ dmfilemapd \(em device-mapper filemap monitoring daemon
 .de CMD_DMFILEMAPD
 .  ad l
 .  nh
-.  IR dmfilemapd
+.  BR dmfilemapd
 .  OPT_FD
 .  OPT_GROUP
 .  OPT_PATH
@@ -41,15 +41,14 @@ dmfilemapd \(em device-mapper filemap monitoring daemon
 .CMD_DMFILEMAPD
 .
 .PD
-.ad b
 .
 .SH DESCRIPTION
 .
-The dmfilemapd daemon monitors groups of \fIdmstats\fP regions that
+The dmfilemapd daemon monitors groups of \fBdmstats\fP regions that
 correspond to the extents of a file, adding and removing regions to
 reflect the changing state of the file on-disk.
-
-The daemon is normally launched automatically by the \fPdmstats
+.P
+The daemon is normally launched automatically by the \fBdmstats
 create\fP command, but can be run manually, either to create a new
 daemon where one did not previously exist, or to change the options
 previously used, by killing the existing daemon and starting a new
@@ -57,49 +56,48 @@ one.
 .
 .SH OPTIONS
 .
-.HP
-.BR file_descriptor
-.br
+.TP
+.OPT_FD
 Specify the file descriptor number for the file to be monitored.
 The file descriptor must reference a regular file, open for reading,
 in a local file system that supports the FIEMAP ioctl, and that
 returns data describing the physical location of extents.
-
+.sp
 The process that executes \fBdmfilemapd\fP is responsible for
 opening the file descriptor that is handed to the daemon.
 .
-.HP
-.BR group_id
-.br
+.TP
+.OPT_GROUP
 The \fBdmstats\fP group identifier of the group that \fBdmfilemapd\fP
 should update. The group must exist and it should correspond to
 a set of regions created by a previous filemap operation.
 .
-.HP
-.BR abs_path
-.br
+.TP
+.OPT_PATH
 The absolute path to the file being monitored, at the time that
-it was opened. The use of \fBpath\fP by the daemon differs,
+it was opened. The use of \fIabs_path\fP by the daemon differs,
 depending on the filemap following mode in use; see \fBMODES\fP
-and the \fBmode\fP option for more information.
-
-.br
-.HP
-.BR mode
-.br
-The filemap monitoring mode the daemon should use: either "inode"
-(\fBDM_FILEMAP_FOLLOW_INODE\fP), or "path"
+and the \fImode\fP option for more information.
+.
+.TP
+.OPT_MODE
+The filemap monitoring mode the daemon.
+Use either
+.B inode
+(\fBDM_FILEMAP_FOLLOW_INODE\fP), or
+.B path
 (\fBDM_FILEMAP_FOLLOW_PATH\fP), to enable follow-inode or
 follow-path mode respectively.
 .
-.HP
-.BR [foreground]
+.TP
+.RI [ foreground ]
 .br
 If set to 1, disable forking and allow the daemon to run in the
 foreground.
 .
-.HP
-.BR [verbose]
+.TP
+.RI [ verbose ]
+.br
 Control daemon logging. If set to zero, the daemon will close all
 stdio streams and run silently. If \fBverbose\fP is a number
 between 1 and 3, stdio will be retained and the daemon will log
@@ -112,7 +110,7 @@ The file map monitoring daemon can monitor files in two distinct
 ways: the mode affects the behaviour of the daemon when a file
 under monitoring is renamed or unlinked, and the conditions which
 cause the daemon to terminate.
-
+.P
 In both modes, the daemon will always shut down when the group
 being monitored is deleted.
 .P
@@ -123,7 +121,7 @@ daemon started. The file descriptor referencing the file is kept
 open at all times, and the daemon will exit when it detects that
 the file has been unlinked and it is the last holder of a reference
 to the file.
-
+.P
 This mode is useful if the file is expected to be renamed, or moved
 within the file system, while it is being monitored.
 .P
@@ -134,7 +132,7 @@ line. The file descriptor referencing the file is re-opened on each
 iteration of the daemon, and the daemon will exit if no file exists
 at this location (a tolerance is allowed so that a brief delay
 between removal and replacement is permitted).
-
+.P
 This mode is useful if the file is updated by unlinking the original
 and placing a new file at the same path.
 .
@@ -146,14 +144,14 @@ daemon can only react to new allocations once they have been written,
 there are inevitably some IO events that cannot be counted when a
 file is growing, particularly if the file is being extended by a
 single thread writing beyond EOF (for example, the \fBdd\fP program).
-
+.P
 There is a further loss of events in that there is currently no way
 to atomically resize a \fBdmstats\fP region and preserve its current
 counter values. This affects files when they grow by extending the
 final extent, rather than allocating a new extent: any events that
 had accumulated in the region between any prior operation and the
 resize are lost.
-
+.P
 File mapping is currently most effective in cases where the majority
 of IO does not trigger extent allocation. Future updates may address
 these limitations when kernel support is available.
@@ -206,8 +204,7 @@ Bryn M. Reeves <bmr@redhat.com>
 .SH SEE ALSO
 .
 .BR dmstats (8)
-
+.P
 LVM2 resource page: https://www.sourceware.org/lvm2/
 .br
 Device-mapper resource page: http://sources.redhat.com/dm/
-.br
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 528dc877a..aa60a0153 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -24,13 +24,13 @@ dmsetup \(em low level logical volume management
 .  nh
 .  BR create
 .  IR device_name
-.  RB [ -u | --uuid
-.  IR uuid ]
-.  RB [ --addnodeoncreate |\: --addnodeonresume ]
 .  RB [ -n | --notable |\: --table
 .  IR table |\: table_file ]
 .  RB [ --readahead
 .  RB [ + ] \fIsectors |\: auto | none ]
+.  RB [ -u | --uuid
+.  IR uuid ]
+.  RB [ --addnodeoncreate |\: --addnodeonresume ]
 .  hy
 .  ad b
 ..
@@ -86,12 +86,12 @@ dmsetup \(em low level logical volume management
 .  IR count ]
 .  RB [ --interval
 .  IR seconds ]
-.  RB [ --nameprefixes ]
 .  RB [ --noheadings ]
 .  RB [ -o
 .  IR fields ]
 .  RB [ -O | --sort
 .  IR sort_fields ]
+.  RB [ --nameprefixes ]
 .  RB [ --separator
 .  IR separator ]
 .  RI [ device_name ]
@@ -120,11 +120,11 @@ dmsetup \(em low level logical volume management
 .  BR ls
 .  RB [ --target
 .  IR target_type ]
+.  RB [ -o
+.  IR options ]
 .  RB [ --exec
 .  IR command ]
 .  RB [ --tree ]
-.  RB [ -o
-.  IR options ]
 .  hy
 .  ad b
 ..
@@ -391,10 +391,10 @@ dmsetup \(em low level logical volume management
 .CMD_WIPE_TABLE
 .PD
 .P
-.HP
 .PD 0
+.TP
 .B devmap_name \fImajor minor
-.HP
+.TP
 .B devmap_name \fImajor:minor
 .PD
 .ad b
@@ -404,10 +404,10 @@ dmsetup \(em low level logical volume management
 dmsetup manages logical devices that use the device-mapper driver.
 Devices are created by loading a table that specifies a target for
 each sector (512 bytes) in the logical device.
-
+.P
 The first argument to dmsetup is a command.
 The second argument is the logical device name or uuid.
-
+.P
 Invoking the dmsetup tool as \fBdevmap_name\fP
 (which is not normally distributed and is supported
 only for historical reasons) is equivalent to
@@ -417,66 +417,53 @@ only for historical reasons) is equivalent to
 .
 .SH OPTIONS
 .
-.HP
-.BR --addnodeoncreate
-.br
+.TP
+.B --addnodeoncreate
 Ensure \fI/dev/mapper\fP node exists after \fBdmsetup create\fP.
 .
-.HP
-.BR --addnodeonresume
-.br
+.TP
+.B --addnodeonresume
 Ensure \fI/dev/mapper\fP node exists after \fBdmsetup resume\fP (default with udev).
 .
-.HP
-.BR --checks
-.br
+.TP
+.B --checks
 Perform additional checks on the operations requested and report
 potential problems.  Useful when debugging scripts.
 In some cases these checks may slow down operations noticeably.
 .
-.HP
+.TP
 .BR -c | -C | --columns
-.br
 Display output in columns rather than as Field: Value lines.
 .
-.HP
-.BR --count
-.IR count
-.br
+.TP
+.B --count \fIcount
 Specify the number of times to repeat a report. Set this to zero
 continue until interrupted.  The default interval is one second.
 .
-.HP
+.TP
 .BR -f | --force
-.br
 Try harder to complete operation.
 .
-.HP
+.TP
 .BR -h | --help
-.br
 Outputs a summary of the commands available, optionally including
 the list of report fields (synonym with \fBhelp\fP command).
 .
-.HP
-.BR --inactive
-.br
+.TP
+.B --inactive
 When returning any table information from the kernel report on the
 inactive table instead of the live table.
 Requires kernel driver version 4.16.0 or above.
 .
-.HP
-.BR --interval
-.IR seconds
-.br
+.TP
+.B --interval \fIseconds
 Specify the interval in seconds between successive iterations for
 repeating reports. If \fB--interval\fP is specified but \fB--count\fP
 is not, reports will continue to repeat until interrupted.
 The default interval is one second.
 .
-.HP
-.BR --manglename
-.BR auto | hex | none
-.br
+.TP
+.BR --manglename " " auto | hex | none
 Mangle any character not on a whitelist using mangling_mode when
 processing device-mapper device names and UUIDs. The names and UUIDs
 are mangled on input and unmangled on output where the mangling mode
@@ -493,26 +480,20 @@ Mangling mode could be also set through
 \fBDM_DEFAULT_NAME_MANGLING_MODE\fP
 environment variable.
 .
-.HP
-.BR -j | --major
-.IR major
-.br
+.TP
+.BR -j | --major " " \fImajor
 Specify the major number.
 .
-.HP
-.BR -m | --minor
-.IR minor
-.br
+.TP
+.BR -m | --minor " " \fIminor
 Specify the minor number.
 .
-.HP
+.TP
 .BR -n | --notable
-.br
 When creating a device, don't load any table.
 .
-.HP
-.BR --nameprefixes
-.br
+.TP
+.B --nameprefixes
 Add a "DM_" prefix plus the field name to the output.  Useful with
 \fB--noheadings\fP to produce a list of
 field=value pairs that can be used to set environment variables
@@ -520,45 +501,37 @@ field=value pairs that can be used to set environment variables
 .BR udev (7)
 rules).
 .
-.HP
-.BR --noheadings
+.TP
+.B --noheadings
 Suppress the headings line when using columnar output.
 .
-.HP
-.BR --noflush
+.TP
+.B --noflush
 Do not flush outstanding I/O when suspending a device, or do not
 commit thin-pool metadata when obtaining thin-pool status.
 .
-.HP
-.BR --nolockfs
-.br
+.TP
+.B --nolockfs
 Do not attempt to synchronize filesystem eg, when suspending a device.
 .
-.HP
-.BR --noopencount
-.br
+.TP
+.B --noopencount
 Tell the kernel not to supply the open reference count for the device.
 .
-.HP
-.BR --noudevrules
-.br
+.TP
+.B --noudevrules
 Do not allow udev to manage nodes for devices in device-mapper directory.
 .
-.HP
-.BR --noudevsync
-.br
+.TP
+.B --noudevsync
 Do not synchronise with udev when creating, renaming or removing devices.
 .
-.HP
-.BR -o | --options
-.IR options
-.br
+.TP
+.BR -o | --options " " \fIoptions
 Specify which fields to display.
 .
-.HP
-.BR --readahead
-.RB [ + ] \fIsectors | auto | none
-.br
+.TP
+.BR --readahead \ [ + ] \fIsectors | auto | none
 Specify read ahead size in units of sectors.
 The default value is \fBauto\fP which allows the kernel to choose
 a suitable value automatically.  The \fB+\fP prefix lets you
@@ -566,15 +539,12 @@ specify a minimum value which will not be used if it is
 smaller than the value chosen by the kernel.
 The value \fBnone\fP is equivalent to specifying zero.
 .
-.HP
+.TP
 .BR -r | --readonly
-.br
 Set the table being loaded read-only.
 .
-.HP
-.BR -S | --select
-.IR selection
-.br
+.TP
+.BR -S | --select " " \fIselection
 Process only items that match \fIselection\fP criteria.  If the command is
 producing report output, adding the "selected" column (\fB-o
 selected\fP) displays all rows and shows 1 if the row matches the
@@ -584,49 +554,38 @@ comparison operators. As a quick help and to see full list of column names that
 can be used in selection and the set of supported selection operators, check
 the output of \fBdmsetup\ info\ -c\ -S\ help\fP command.
 .
-.HP
-.BR --table
-.IR table
-.br
+.TP
+.B --table \fItable
 Specify a one-line table directly on the command line.
 See below for more information on the table format.
 .
-.HP
-.BR --udevcookie
-.IR cookie
-.br
+.TP
+.B --udevcookie \fIcookie
 Use cookie for udev synchronisation.
 Note: Same cookie should be used for same type of operations i.e. creation of
 multiple different devices. It's not adviced to combine different
 operations on the single device.
 .
-.HP
-.BR -u | --uuid
-.br
+.TP
+.BR -u | --uuid " " \fIuuid
 Specify the \fIuuid\fP.
 .
-.HP
+.TP
 .BR -y | --yes
-.br
 Answer yes to all prompts automatically.
 .
-.HP
-.BR -v | --verbose
-.RB [ -v | --verbose ]
-.br
+.TP
+.BR -v | --verbose " [" -v | --verbose ]
 Produce additional output.
 .
-.HP
-.BR --verifyudev
-.br
+.TP
+.B --verifyudev
 If udev synchronisation is enabled, verify that udev operations get performed
 correctly and try to fix up the device nodes afterwards if not.
 .
-.HP
-.BR --version
-.br
+.TP
+.B --version
 Display the library and kernel driver version.
-.br
 .
 .SH COMMANDS
 .
@@ -656,7 +615,7 @@ Flags defaults to read-write (rw) or may be read-only (ro).
 Uuid, minor number and flags are optional so those fields may be empty.
 A semi-colon separates specifications of different devices.
 Use a backslash to escape the following character, for example a comma or semi-colon in a name or table. See also CONCISE FORMAT below.
-. 
+.
 .HP
 .CMD_DEPS
 .br
@@ -701,11 +660,11 @@ Fields are comma-separated and chosen from the following list:
 .BR events ,
 .BR uuid .
 Attributes are:
-.RI ( L )ive,
-.RI ( I )nactive,
-.RI ( s )uspended,
-.RI ( r )ead-only,
-.RI read-( w )rite.
+.RB ( L )ive,
+.RB ( I )nactive,
+.RB ( s )uspended,
+.RB ( r )ead-only,
+.RB read-( w )rite.
 Precede the list with '\fB+\fP' to append
 to the default selection of columns instead of replacing it.
 Precede any sort field with '\fB-\fP' for a reverse sort on that column.
@@ -838,7 +797,7 @@ Outputs status information for each of the device's targets.
 With \fB--target\fP, only information relating to the specified target type
 any is displayed.  With \fB--noflush\fP, the thin target (from version 1.3.0)
 doesn't commit any outstanding changes to disk before reporting its statistics.
-
+.
 .HP
 .CMD_SUSPEND
 .br
@@ -964,14 +923,13 @@ Creates a striped area.
 e.g. striped 2 32 /dev/hda1 0 /dev/hdb1 0
 will map the first chunk (16k) as follows:
 .RS
-.RS
+.IP
  LV chunk 1 -> hda1, chunk 1
  LV chunk 2 -> hdb1, chunk 1
  LV chunk 3 -> hda1, chunk 2
  LV chunk 4 -> hdb1, chunk 2
  etc.
 .RE
-.RE
 .TP
 .B error
 Errors any I/O that goes to this area.  Useful for testing or
diff --git a/man/dmstats.8_main b/man/dmstats.8_main
index db9f31904..f77ca05c8 100644
--- a/man/dmstats.8_main
+++ b/man/dmstats.8_main
@@ -1,12 +1,12 @@
 .TH DMSTATS 8 "Jun 23 2016" "Linux" "MAINTENANCE COMMANDS"
-
+.
 .de OPT_PROGRAMS
-.  RB \%[ --allprograms | --programid
+.  RB [ --allprograms | --programid
 .  IR id ]
 ..
 .
 .de OPT_REGIONS
-.  RB \%[ --allregions | --regionid
+.  RB [ --allregions | --regionid
 .  IR id ]
 ..
 .de OPT_OBJECTS
@@ -55,15 +55,17 @@ dmstats \(em device-mapper statistics management
 .B dmstats
 .de CMD_COMMAND
 .  ad l
+.  nh
 .  IR command
-.  IR device_name " |"
+.  IR device_name \ |
 .  BR --major
 .  IR major
 .  BR --minor
-.  IR minor " |"
+.  IR minor \ |
 .  BR -u | --uuid
 .  IR uuid
-.  RB \%[ -v | --verbose]
+.  RB [ -v | --verbose ]
+.  hy
 .  ad b
 ..
 .CMD_COMMAND
@@ -72,10 +74,12 @@ dmstats \(em device-mapper statistics management
 .B dmstats
 .de CMD_CLEAR
 .  ad l
+.  nh
 .  BR clear
 .  IR device_name
 .  OPT_PROGRAMS
 .  OPT_REGIONS
+.  hy
 .  ad b
 ..
 .CMD_CLEAR
@@ -84,13 +88,14 @@ dmstats \(em device-mapper statistics management
 .B dmstats
 .de CMD_CREATE
 .  ad l
+.  nh
 .  BR create
 .  IR device_name... | file_path... | \fB--alldevices
 .  RB [ --areas
 .  IR nr_areas | \fB--areasize
 .  IR area_size ]
 .  RB [ --bounds
-.  IR \%histogram_boundaries ]
+.  IR histogram_boundaries ]
 .  RB [ --filemap ]
 .  RB [ --follow
 .  IR follow_mode ]
@@ -102,10 +107,11 @@ dmstats \(em device-mapper statistics management
 .  IR start_sector
 .  BR --length
 .  IR length | \fB--segments ]
-.  RB \%[ --userdata
+.  RB [ --userdata
 .  IR user_data ]
 .  RB [ --programid
 .  IR id ]
+.  hy
 .  ad b
 ..
 .CMD_CREATE
@@ -114,10 +120,12 @@ dmstats \(em device-mapper statistics management
 .B dmstats
 .de CMD_DELETE
 .  ad l
+.  nh
 .  BR delete
 .  IR device_name | \fB--alldevices
 .  OPT_PROGRAMS
 .  OPT_REGIONS
+.  hy
 .  ad b
 ..
 .CMD_DELETE
@@ -126,12 +134,14 @@ dmstats \(em device-mapper statistics management
 .B dmstats
 .de CMD_GROUP
 .  ad l
+.  nh
 .  BR group
 .  RI [ device_name | \fB--alldevices ]
 .  RB [ --alias
 .  IR name ]
 .  RB [ --regions
 .  IR regions ]
+.  hy
 .  ad b
 ..
 .CMD_GROUP
@@ -149,6 +159,7 @@ dmstats \(em device-mapper statistics management
 .B dmstats
 .de CMD_LIST
 .  ad l
+.  nh
 .  BR list
 .  RI [ device_name ]
 .  RB [ --histogram ]
@@ -156,9 +167,10 @@ dmstats \(em device-mapper statistics management
 .  RB [ --units
 .  IR units ]
 .  OPT_OBJECTS
-.  RB \%[ --nosuffix ]
+.  RB [ --nosuffix ]
 .  RB [ --notimesuffix ]
-.  RB \%[ -v | --verbose]
+.  RB [ -v | --verbose ]
+.  hy
 .  ad b
 ..
 .CMD_LIST
@@ -167,11 +179,13 @@ dmstats \(em device-mapper statistics management
 .B dmstats
 .de CMD_PRINT
 .  ad l
+.  nh
 .  BR print
 .  RI [ device_name ]
 .  RB [ --clear ]
 .  OPT_PROGRAMS
 .  OPT_REGIONS
+.  hy
 .  ad b
 ..
 .CMD_PRINT
@@ -180,6 +194,7 @@ dmstats \(em device-mapper statistics management
 .B dmstats
 .de CMD_REPORT
 .  ad l
+.  nh
 .  BR report
 .  RI [ device_name ]
 .  RB [ --interval
@@ -199,7 +214,8 @@ dmstats \(em device-mapper statistics management
 .  RB [ --units
 .  IR units ]
 .  RB [ --nosuffix ]
-.  RB \%[ --notimesuffix ]
+.  RB [ --notimesuffix ]
+.  hy
 .  ad b
 ..
 .CMD_REPORT
@@ -207,10 +223,12 @@ dmstats \(em device-mapper statistics management
 .B dmstats
 .de CMD_UNGROUP
 .  ad l
+.  nh
 .  BR ungroup
 .  RI [ device_name | \fB--alldevices ]
 .  RB [ --groupid
 .  IR id ]
+.  hy
 .  ad b
 ..
 .CMD_UNGROUP
@@ -218,6 +236,7 @@ dmstats \(em device-mapper statistics management
 .B dmstats
 .de CMD_UPDATE_FILEMAP
 .  ad l
+.  nh
 .  BR update_filemap
 .  IR file_path
 .  RB [ --groupid
@@ -225,6 +244,7 @@ dmstats \(em device-mapper statistics management
 .  RB [ --follow
 .  IR follow_mode ]
 .  OPT_FOREGROUND
+.  hy
 .  ad b
 ..
 .CMD_UPDATE_FILEMAP
@@ -237,334 +257,272 @@ dmstats \(em device-mapper statistics management
 The dmstats program manages IO statistics regions for devices that use
 the device-mapper driver. Statistics regions may be created, deleted,
 listed and reported on using the tool.
-
+.P
 The first argument to dmstats is a \fIcommand\fP.
-
+.P
 The second argument is the \fIdevice name\fP,
 \fIuuid\fP or \fImajor\fP and \fIminor\fP numbers.
-
+.P
 Further options permit the selection of regions, output format
 control, and reporting behaviour.
-
+.P
 When no device argument is given dmstats will by default operate on all
 device-mapper devices present. The \fBcreate\fP and \fBdelete\fP
 commands require the use of \fB--alldevices\fP when used in this way.
 .
 .SH OPTIONS
 .
-.HP
-.BR --alias
-.IR name
-.br
+.TP
+.B --alias \fIname
 Specify an alias name for a group.
 .
-.HP
-.BR --alldevices
-.br
+.TP
+.B --alldevices
 If no device arguments are given allow operation on all devices when
 creating or deleting regions.
 .
-.HP
-.BR --allprograms
-.br
+.TP
+.B --allprograms
 Include regions from all program IDs for list and report operations.
-.br
-.HP
-.BR --allregions
-.br
+.
+.TP
+.B --allregions
 Include all present regions for commands that normally accept a single
 region identifier.
 .
-.HP
-.BR --area
-.br
+.TP
+.B --area
 When peforming a list or report, include objects of type area in the
 results.
 .
-.HP
-.BR --areas
-.IR nr_areas
-.br
+.TP
+.B --areas \fInr_areas
 Specify the number of statistics areas to create within a new region.
 .
-.HP
-.BR --areasize
-.IR area_size \c
-.RB [ \c
+.TP
+.B --areasize \fIarea_size\fR[\c
 .UNITS
-.br
 Specify the size of areas into which a new region should be divided. An
 optional suffix selects units of:
 .HELP_UNITS
 .
-.HP
-.BR --clear
-.br
+.TP
+.B --clear
 When printing statistics counters, also atomically reset them to zero.
 .
-.HP
-.BR --count
-.IR count
-.br
+.TP
+.B --count \fIcount
 Specify the iteration count for repeating reports. If the count
 argument is zero reports will continue to repeat until interrupted.
 .
-.HP
-.BR --group
-.br
+.TP
+.B --group
 When peforming a list or report, include objects of type group in the
 results.
 .
-.HP
-.BR --filemap
-.br
+.TP
+.B --filemap
 Instead of creating regions on a device as specified by command line
 options, open the file found at each \fBfile_path\fP argument, and
 create regions corresponding to the locations of the on-disk extents
 allocated to the file(s).
 .
-.HP
-.BR --nomonitor
-.br
+.TP
+.B --nomonitor
 Disable the \fBdmfilemapd\fP daemon when creating new file mapped
 groups. Normally the device-mapper filemap monitoring daemon,
 \fBdmfilemapd\fP, is started for each file mapped group to update the
 set of regions as the file changes on-disk: use of this option
 disables this behaviour.
-
+.P
 Regions in the group may still be updated with the
 \fBupdate_filemap\fP command, or by starting the daemon manually.
 .
-.HP
-.BR --follow
-.IR follow_mode
-.br
+.TP
+.B --follow \fIfollow_mode
 Specify the \fBdmfilemapd\fP file following mode. The file map
 monitoring daemon can monitor files in two distinct ways: the mode
 affects the behaviour of the daemon when a file under monitoring is
 renamed or unlinked, and the conditions which cause the daemon to
 terminate.
-
+.P
 The \fBfollow_mode\fP argument is either "inode", for follow-inode
 mode, or "path", for follow-path.
-
+.P
 If follow-inode mode is used, the daemon will hold the file open, and
 continue to update regions from the same file descriptor. This means
 that the mapping will follow rename, move (within the same file
 system), and unlink operations. This mode is useful if the file is
 expected to be moved, renamed, or unlinked while it is being
 monitored.
-
+.P
 In follow-inode mode, the daemon will exit once it detects that the
 file has been unlinked and it is the last holder of a reference to it.
-
+.P
 If follow-path is used, the daemon will re-open the provided path on
 each monitoring iteration. This means that the group will be updated
 to reflect a new file being moved to the same path as the original
 file. This mode is useful for files that are expected to be updated
 via unlink and rename.
-
+.P
 In follow-path mode, the daemon will exit if the file is removed and
 not replaced within a brief tolerance interval.
-
+.P
 In either mode, the daemon exits automatically if the monitored group
 is removed.
 .
-.HP
-.BR --foreground
-.br
+.TP
+.B --foreground
 Specify that the \fBdmfilemapd\fP daemon should run in the foreground.
 The daemon will not fork into the background, and will replace the
 \fBdmstats\fP command that started it.
 .
-.HP
-.BR --groupid
-.IR id
-.br
+.TP
+.B --groupid \fIid
 Specify the group to operate on.
 .
-.HP
-.BR --bounds
-.IR histogram_boundaries \c
+.TP
+.B --bounds \fIhistogram_boundaries\c
 .RB [ ns | us | ms | s ]
-.br
 Specify the boundaries of a latency histogram to be tracked for the
 region as a comma separated list of latency values. Latency values are
 given in nanoseconds. An optional unit suffix of
-.BR ns ,
-.BR us ,
-.BR ms ,
+.BR ns , us , ms ,
 or \fBs\fP may be given after each value to specify units of
 nanoseconds, microseconds, miliseconds or seconds respectively.
 .
-.HP
-.BR --histogram
-.br
+.TP
+.B --histogram
 When used with the \fBreport\fP and \fBlist\fP commands select default
 fields that emphasize latency histogram data.
 .
-.HP
-.BR --interval
-.IR seconds
-.br
+.TP
+.B --interval \fIseconds
 Specify the interval in seconds between successive iterations for
 repeating reports. If \fB--interval\fP is specified but
 \fB--count\fP is not,
 reports will continue to repeat until interrupted.
 .
-.HP
-.BR --length
-.IR length \c
-.RB [ \c
+.TP
+.B --length \fIlength\fR[\c
 .UNITS
-.br
 Specify the length of a new statistics region in sectors. An optional
 suffix selects units of:
 .HELP_UNITS
 .
-.HP
-.BR -j | --major
-.IR major
-.br
+.TP
+.BR -j | --major " " \fImajor
 Specify the major number.
 .
-.HP
-.BR -m | --minor
-.IR minor
-.br
+.TP
+.BR -m | --minor " " \fIminor
 Specify the minor number.
 .
-.HP
-.BR --nogroup
-.br
+.TP
+.B --nogroup
 When creating regions mapping the extents of a file in the file
 system, do not create a group or set an alias.
 .
-.HP
-.BR --nosuffix
-.br
+.TP
+.B --nosuffix
 Suppress the suffix on output sizes.  Use with \fB--units\fP
 (except h and H) if processing the output.
 .
-.HP
-.BR --notimesuffix
-.br
+.TP
+.B --notimesuffix
 Suppress the suffix on output time values. Histogram boundary values
 will be reported in units of nanoseconds.
 .
-.HP
+.TP
 .BR -o | --options
-.br
 Specify which report fields to display.
 .
-.HP
-.BR -O | --sort
-.IR sort_fields
-.br
+.TP
+.BR -O | --sort " " \fIsort_fields
 Sort output according to the list of fields given. Precede any
 sort field with '\fB-\fP' for a reverse sort on that column.
 .
-.HP
-.BR --precise
-.br
+.TP
+.B --precise
 Attempt to use nanosecond precision counters when creating new
 statistics regions.
 .
-.HP
-.BR --programid
-.IR id
-.br
+.TP
+.B --programid \fIid
 Specify a program ID string. When creating new statistics regions this
 string is stored with the region. Subsequent operations may supply a
 program ID in order to select only regions with a matching value. The
 default program ID for dmstats-managed regions is "dmstats".
 .
-.HP
-.BR --region
-.br
+.TP
+.B --region
 When peforming a list or report, include objects of type region in the
 results.
 .
-.HP
-.BR --regionid
-.IR id
-.br
+.TP
+.B --regionid \fIid
 Specify the region to operate on.
 .
-.HP
-.BR --regions
-.IR region_list
-.br
+.TP
+.B --regions \fIregion_list
 Specify a list of regions to group. The group list is a comma-separated
 list of region identifiers. Continuous sequences of identifiers may be
 expressed as a hyphen separated range, for example: '1-10'.
 .
-.HP
-.BR --relative
-.br
+.TP
+.B --relative
 If displaying the histogram report show relative (percentage) values
 instead of absolute counts.
 .
-.HP
-.BR -S | --select
-.IR selection
-.br
+.TP
+.BR -S | --select " " \fIselection
 Display only rows that match \fIselection\fP criteria. All rows with the
 additional "selected" column (\fB-o selected\fP) showing 1 if the row matches
 the \fIselection\fP and 0 otherwise. The selection criteria are defined by
 specifying column names and their valid values while making use of
 supported comparison operators.
 .
-.HP
-.BR --start
-.IR start \c
-.RB [ \c
+.TP
+.B --start \fIstart\fR[\c
 .UNITS
-.br
 Specify the start offset of a new statistics region in sectors. An
 optional suffix selects units of:
 .HELP_UNITS
 .
-.HP
-.BR --segments
-.br
+.TP
+.B --segments
 When used with \fBcreate\fP, create a new statistics region for each
 target contained in the given device(s). This causes a separate region
 to be allocated for each segment of the device.
-
+.P
 The newly created regions are automatically placed into a group unless
 the \fB--nogroup\fP option is given. When grouping is enabled a group
 alias may be specified using the \fB--alias\fP option.
 .
-.HP
-.BR --units
+.TP
+.B --units \c
 .RI [ units ] \c
 .RB [ h | H | \c
 .UNITS
-.br
 Set the display units for report output.
 All sizes are output in these units:
 .RB ( h )uman-readable,
 .HELP_UNITS
 Can also specify custom units e.g. \fB--units\ 3M\fP.
 .
-.HP
-.BR --userdata
-.IR user_data
-.br
+.TP
+.B --userdata \fIuser_data
 Specify user data (a word) to be stored with a new region. The value
 is added to any internal auxiliary data (for example, group
 information), and stored with the region in the aux_data field provided
 by the kernel. Whitespace is not permitted.
 .
-.HP
+.TP
 .BR -u | --uuid
-.br
 Specify the uuid.
 .
-.HP
-.BR -v | --verbose " [" -v | --verbose ]
-.br
+.TP
+.BR -v | --verbose \ [ -v | --verbose ]
 Produce additional output.
 .
 .SH COMMANDS
@@ -579,23 +537,23 @@ regions (with the exception of in-flight IO counters).
 .CMD_CREATE
 .br
 Creates one or more new statistics regions on the specified device(s).
-
+.P
 The region will span the entire device unless \fB--start\fP and
 \fB--length\fP or \fB--segments\fP are given. The \fB--start\fP an
 \fB--length\fP options allow a region of arbitrary length to be placed
 at an arbitrary offset into the device. The \fB--segments\fP option
 causes a new region to be created for each target in the corresponding
 device-mapper device's table.
-
+.P
 If the \fB--precise\fP option is used the command will attempt to
 create a region using nanosecond precision counters.
-
+.P
 If \fB--bounds\fP is given a latency histogram will be tracked for
 the new region. The boundaries of the histogram bins are given as a
 comma separated list of latency values. There is an implicit lower bound
 of zero on the first bin and an implicit upper bound of infinity (or the
 configured interval duration) on the final bin.
-
+.P
 Latencies are given in nanoseconds. An optional unit suffix of ns, us,
 ms, or s may be given after each value to specify units of nanoseconds,
 microseconds, miliseconds or seconds respectively, so for example, 10ms
@@ -603,19 +561,19 @@ is equivalent to 10000000. Latency values with a precision of less than
 one milisecond can only be used when precise timestamps are enabled: if
 \fB--precise\fP is not given and values less than one milisecond are
 used it will be enabled automatically.
-
+.P
 An optional \fBprogram_id\fP or \fBuser_data\fP string may be associated
 with the region. A \fBprogram_id\fP may then be used to select regions
 for subsequent list, print, and report operations. The \fBuser_data\fP
 stores an arbitrary string and is not used by dmstats or the
 device-mapper kernel statistics subsystem.
-
+.P
 By default dmstats creates regions with a \fBprogram_id\fP of
 "dmstats".
-
+.P
 On success the \fBregion_id\fP of the newly created region is printed
 to stdout.
-
+.P
 If the \fB--filemap\fP option is given with a regular file, or list
 of files, as the \fBfile_path\fP argument, instead of creating regions
 with parameters specified on the command line, \fBdmstats\fP will open
@@ -623,20 +581,20 @@ the files located at \fBfile_path\fP and create regions corresponding to
 the physical extents allocated to the file. This can be used to monitor
 statistics for individual files in the file system, for example, virtual
 machine images, swap areas, or large database files.
-
+.P
 To work with the \fB--filemap\fP option, files must be located on a
 local file system, backed by a device-mapper device, that supports
 physical extent data using the FIEMAP ioctl (Ext4 and XFS for e.g.).
-
+.P
 By default regions that map a file are placed into a group and the
 group alias is set to the basename of the file. This behaviour can be
 overridden with the \fB--alias\fP and \fB--nogroup\fP options.
-
+.P
 Creating a group that maps a file automatically starts a daemon,
 \fBdmfilemapd\fP to monitor the file and update the mapping as the
 extents allocated to the file change. This behaviour can be disabled
 using the \fB--nomonitor\fP option.
-
+.P
 Use the \fB--group\fP option to only display information for groups
 when listing and reporting.
 .
@@ -646,17 +604,17 @@ when listing and reporting.
 Delete the specified statistics region. All counters and resources used
 by the region are released and the region will not appear in the output
 of subsequent list, print, or report operations.
-
+.P
 All regions registered on a device may be removed using
 \fB--allregions\fP.
-
+.P
 To remove all regions on all devices both \fB--allregions\fP and
 \fB--alldevices\fP must be used.
-
+.P
 If a \fB--groupid\fP is given instead of a \fB--regionid\fP the
 command will attempt to delete the group and all regions that it
 contains.
-
+.P
 If a deleted region is the first member of a group of regions the group
 will also be removed.
 .
@@ -665,19 +623,19 @@ will also be removed.
 .br
 Combine one or more statistics regions on the specified device into a
 group.
-
+.P
 The list of regions to be grouped is specified with \fB--regions\fP
 and an optional alias may be assigned with \fB--alias\fP. The set of
 regions is given as a comma-separated list of region identifiers. A
 continuous range of identifers spanning from \fBR1\fP to \fBR2\fP may
 be expressed as '\fBR1\fP-\fBR2\fP'.
-
+.P
 Regions that have a histogram configured can be grouped: in this case
 the number of histogram bins and their bounds must match exactly.
-
+.P
 On success the group list and newly created \fBgroup_id\fP are
 printed to stdout.
-
+.P
 The group metadata is stored with the first (lowest numbered)
 \fBregion_id\fP in the group: deleting this region will also delete
 the group and other group members will be returned to their prior
@@ -695,18 +653,18 @@ the list of report fields.
 List the statistics regions, areas, or groups registered on the device.
 If the \fB--allprograms\fP switch is given all regions will be listed
 regardless of region program ID values.
-
+.P
 By default only regions and groups are included in list output. If
 \fB-v\fP or \fB--verbose\fP is given the report will also include a
 row of information for each configured group and for each area contained
 in each region displayed.
-
+.P
 Regions that contain a single area are by default omitted from the
 verbose list since their properties are identical to the area that they
 contain - to view all regions regardless of the number of areas present
 use \fB--region\fP). To also view the areas contained within regions
 use \fB--area\fP.
-
+.P
 If \fB--histogram\fP is given the report will include the bin count
 and latency boundary values for any configured histograms.
 .HP
@@ -722,16 +680,16 @@ Start a report for the specified object or for all present objects. If
 the count argument is specified, the report will repeat at a fixed
 interval set by the \fB--interval\fP option. The default interval is
 one second.
-
+.P
 If the \fB--allprograms\fP switch is given, all regions will be
 listed, regardless of region program ID values.
-
+.P
 If the \fB--histogram\fP is given the report will include the histogram
 values and latency boundaries.
-
+.P
 If the \fB--relative\fP is used the default histogram field displays
 bin values as a percentage of the total number of I/Os.
-
+.P
 Object types (areas, regions and groups) to include in the report are
 selected using the \fB--area\fP, \fB--region\fP, and \fB--group\fP
 options.
@@ -741,7 +699,7 @@ options.
 .br
 Remove an existing group and return all the group's regions to their
 original state.
-
+.P
 The group to be removed is specified using \fB--groupid\fP.
 .HP
 .CMD_UPDATE_FILEMAP
@@ -749,19 +707,19 @@ The group to be removed is specified using \fB--groupid\fP.
 Update a group of \fBdmstats\fP regions specified by \fBgroup_id\fP,
 that were previously created with \fB--filemap\fP, either directly,
 or by starting the monitoring daemon, \fBdmfilemapd\fP.
-
+.P
 This will add and remove regions to reflect changes in the allocated
 extents of the file on-disk, since the time that it was crated or last
 updated.
-
+.P
 Use of this command is not normally needed since the \fBdmfilemapd\fP
 daemon will automatically monitor filemap groups and perform these
 updates when required.
-
+.P
 If a filemapped group was created with \fB--nomonitor\fP, or the
 daemon has been killed, the \fBupdate_filemap\fP can be used to
 manually force an update or start a new daemon.
-
+.P
 Use \fB--nomonitor\fP to force a direct update and disable starting
 the monitoring daemon.
 .
@@ -773,55 +731,54 @@ span any range: from a single sector to the whole device. A region may
 be further sub-divided into a number of distinct areas (one or more),
 each with its own counter set. In this case a summary value for the
 entire region is also available for use in reports.
-
+.P
 In addition, one or more regions on one device can be combined into
 a statistics group. Groups allow several regions to be aggregated and
 reported as a single entity; counters for all regions and areas are
 summed and used to report totals for all group members. Groups also
 permit the assignment of an optional alias, allowing meaningful names
 to be associated with sets of regions.
-
+.P
 The group metadata is stored with the first (lowest numbered)
 \fBregion_id\fP in the group: deleting this region will also delete
 the group and other group members will be returned to their prior
 state.
-
+.P
 By default new regions span the entire device. The \fB--start\fP and
 \fB--length\fP options allows a region of any size to be placed at any
 location on the device.
-
+.P
 Using offsets it is possible to create regions that map individual
 objects within a block device (for example: partitions, files in a file
 system, or stripes or other structures in a RAID volume). Groups allow
 several non-contiguous regions to be assembled together for reporting
 and data aggregation.
-
+.P
 A region may be either divided into the specified number of equal-sized
 areas, or into areas of the given size by specifying one of
 \fB--areas\fP or \fB--areasize\fP when creating a region with the
 \fBcreate\fP command. Depending on the size of the areas and the device
 region the final area within the region may be smaller than requested.
-.P
-.B Region identifiers
-.P
+.
+.SS Region identifiers
+.
 Each region is assigned an identifier when it is created that is used to
 reference the region in subsequent operations. Region identifiers are
 unique within a given device (including across different \fBprogram_id\fP
 values).
-
+.P
 Depending on the sequence of create and delete operations, gaps may
 exist in the sequence of \fBregion_id\fP values for a particular device.
-
+.P
 The \fBregion_id\fP should be treated as an opaque identifier used to
 reference the region.
 .
-.P
-.B Group identifiers
-.P
+.SS Group identifiers
+.
 Groups are also assigned an integer identifier at creation time;
 like region identifiers, group identifiers are unique within the
 containing device.
-
+.P
 The \fBgroup_id\fP should be treated as an opaque identifier used to
 reference the group.
 .
@@ -832,82 +789,80 @@ correspond to the extents of a file in the file system. This allows
 IO statistics to be monitored on a per-file basis, for example to
 observe large database files, virtual machine images, or other files
 of interest.
-
+.P
 To be able to use file mapping, the file must be backed by a
 device-mapper device, and in a file system that supports the FIEMAP
 ioctl (and which returns data describing the physical location of
 extents). This currently includes \fBxfs(5)\fP and \fBext4(5)\fP.
-
+.P
 By default the regions making up a file are placed together in a
 group, and the group alias is set to the \fBbasename(3)\fP of the
 file. This allows statistics to be reported for the file as a whole,
 aggregating values for the regions making up the group. To see only
 the whole file (group) when using the \fBlist\fP and \fBreport\fP
 commands, use \fB--group\fP.
-
+.P
 Since it is possible for the file to change after the initial
 group of regions is created, the \fBupdate_filemap\fP command, and
 \fBdmfilemapd\fP daemon are provided to update file mapped groups
 either manually or automatically.
 .
-.P
-.B File follow modes
-.P
+.SS File follow modes
+.
 The file map monitoring daemon can monitor files in two distinct ways:
 follow-inode mode, and follow-path mode.
-
+.P
 The mode affects the behaviour of the daemon when a file under
 monitoring is renamed or unlinked, and the conditions which cause the
 daemon to terminate.
-
+.P
 If follow-inode mode is used, the daemon will hold the file open, and
 continue to update regions from the same file descriptor. This means
 that the mapping will follow rename, move (within the same file
 system), and unlink operations. This mode is useful if the file is
 expected to be moved, renamed, or unlinked while it is being
 monitored.
-
+.P
 In follow-inode mode, the daemon will exit once it detects that the
 file has been unlinked and it is the last holder of a reference to it.
-
+.P
 If follow-path is used, the daemon will re-open the provided path on
 each monitoring iteration. This means that the group will be updated
 to reflect a new file being moved to the same path as the original
 file. This mode is useful for files that are expected to be updated
 via unlink and rename.
-
+.P
 In follow-path mode, the daemon will exit if the file is removed and
 not replaced within a brief tolerance interval (one second).
-
+.P
 To stop the daemon, delete the group containing the mapped regions:
 the daemon will automatically shut down.
-
+.P
 The daemon can also be safely killed at any time and the group kept:
 if the file is still being allocated the mapping will become
 progressively out-of-date as extents are added and removed (in this
 case the daemon can be re-started or the group updated manually with
 the \fBupdate_filemap\fP command).
-
+.P
 See the \fBcreate\fP command and \fB--filemap\fP, \fB--follow\fP,
 and \fB--nomonitor\fP options for further information.
 .
-.P
-.B Limitations
-.P
+.SS Limitations
+.
 The daemon attempts to maintain good synchronisation between the file
 extents and the regions contained in the group, however, since it can
 only react to new allocations once they have been written, there are
 inevitably some IO events that cannot be counted when a file is
 growing, particularly if the file is being extended by a single thread
 writing beyond end-of-file (for example, the \fBdd\fP program).
-
+.P
 There is a further loss of events in that there is currently no way
 to atomically resize a \fBdmstats\fP region and preserve its current
 counter values. This affects files when they grow by extending the
 final extent, rather than allocating a new extent: any events that
 had accumulated in the region between any prior operation and the
 resize are lost.
-
+.P
 File mapping is currently most effective in cases where the majority
 of IO does not trigger extent allocation. Future updates may address
 these limitations when kernel support is available.
@@ -916,7 +871,7 @@ these limitations when kernel support is available.
 .
 The dmstats report provides several types of field that may be added to
 the default field set, or used to create custom reports.
-
+.P
 All performance counters and metrics are calculated per-area.
 .
 .SS Derived metrics
@@ -1273,12 +1228,11 @@ Bryn M. Reeves <bmr@redhat.com>
 .SH SEE ALSO
 .
 .BR dmsetup (8)
-
+.P
 LVM2 resource page: https://www.sourceware.org/lvm2/
 .br
 Device-mapper resource page: http://sources.redhat.com/dm/
-.br
-
+.P
 Device-mapper statistics kernel documentation
 .br
 .I Documentation/device-mapper/statistics.txt
diff --git a/man/fsadm.8_main b/man/fsadm.8_main
index 799cb2547..d83e99292 100644
--- a/man/fsadm.8_main
+++ b/man/fsadm.8_main
@@ -1,24 +1,27 @@
 .TH "FSADM" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.
 .SH "NAME"
+.
 fsadm \(em utility to resize or check filesystem on a device
+.
 .SH SYNOPSIS
 .
 .PD 0
 .ad l
-.HP 5
+.TP 6
 .B fsadm
 .RI [ options ]
 .BR check
 .IR device
 .
-.HP
+.TP
 .B fsadm
 .RI [ options ]
 .BR resize
 .IR device
 .RI [ new_size ]
-.PD
 .ad b
+.PD
 .
 .SH DESCRIPTION
 .
@@ -34,44 +37,36 @@ filesystem.
 .
 .SH OPTIONS
 .
-.HP
+.TP
 .BR -e | --ext-offline
-.br
 Unmount ext2/ext3/ext4 filesystem before doing resize.
 .
-.HP
+.TP
 .BR -f | --force
-.br
 Bypass some sanity checks.
 .
-.HP
+.TP
 .BR -h | --help
-.br
 Display the help text.
 .
-.HP
+.TP
 .BR -n | --dry-run
-.br
 Print commands without running them.
 .
-.HP
+.TP
 .BR -v | --verbose
-.br
 Be more verbose.
 .
-.HP
+.TP
 .BR -y | --yes
-.br
 Answer "yes" at any prompts.
 .
-.HP
+.TP
 .BR -c | --cryptresize
-.br
 Resize dm-crypt mapping together with filesystem detected on the device. The dm-crypt device must be recognizable by cryptsetup(8).
 .
-.HP
+.TP
 .BR \fInew_size [ B | K | M | G | T | P | E ]
-.br
 Absolute number of filesystem blocks to be in the filesystem,
 or an absolute size using a suffix (in powers of 1024).
 If new_size is not supplied, the whole device is used.
@@ -91,30 +86,37 @@ Resize the filesystem on logical volume \fI/dev/vg/test\fP to 1000 megabytes.
 If \fI/dev/vg/test\fP contains ext2/ext3/ext4
 filesystem it will be unmounted prior the resize.
 All [y/n] questions will be answered 'y'.
-.sp
+.P
+#
 .B fsadm -e -y resize /dev/vg/test 1000M
 .
 .SH ENVIRONMENT VARIABLES
 .
 .TP
-.B "TMPDIR   "
+.B TMPDIR
 The temporary directory name for mount points. Defaults to "\fI/tmp\fP".
 .TP
 .B DM_DEV_DIR
 The device directory name.
 Defaults to "\fI/dev\fP" and must be an absolute path.
-
+.
 .SH SEE ALSO
+.
 .nh
+.ad l
 .BR lvm (8),
 .BR lvresize (8),
 .BR lvm.conf (5),
+.P
 .BR fsck (8),
 .BR tune2fs (8),
 .BR resize2fs (8),
+.P
 .BR reiserfstune (8),
 .BR resize_reiserfs (8),
+.P
 .BR xfs_info (8),
 .BR xfs_growfs (8),
 .BR xfs_check (8),
+.P
 .BR cryptsetup (8)
diff --git a/man/lvm.8_main b/man/lvm.8_main
index b221761e3..44961f7cf 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -11,7 +11,6 @@ lvm \(em LVM2 tools
 .
 .SH DESCRIPTION
 .
-
 The Logical Volume Manager (LVM) provides tools to create virtual block
 devices from physical devices.  Virtual devices may be easier to manage
 than physical devices, and can have capabilities beyond what the physical
@@ -22,7 +21,6 @@ applications.  Each block of data in an LV is stored on one or more PV in
 the VG, according to algorithms implemented by Device Mapper (DM) in the
 kernel.
 .P
-
 The lvm command, and other commands listed below, are the command-line
 tools for LVM.  A separate manual page describes each command in detail.
 .P
@@ -40,7 +38,7 @@ On invocation, \fBlvm\fP requires that only the standard file descriptors
 stdin, stdout and stderr are available.  If others are found, they
 get closed and messages are issued warning about the leak.
 This warning can be suppressed by setting the environment variable
-.B LVM_SUPPRESS_FD_WARNINGS\fP.
+.BR LVM_SUPPRESS_FD_WARNINGS .
 .P
 Where commands take VG or LV names as arguments, the full path name is
 optional.  An LV called "lvol0" in a VG called "vg0" can be specified
@@ -67,7 +65,7 @@ The following commands are built into lvm without links
 normally being created in the filesystem for them.
 .sp
 .PD 0
-.TP 14
+.TP 16
 .B config
 The same as \fBlvmconfig\fP(8) below.
 .TP
@@ -112,7 +110,7 @@ Display version information.
 The following commands implement the core LVM functionality.
 .sp
 .PD 0
-.TP 14
+.TP 16
 .B pvchange
 Change attributes of a Physical Volume.
 .TP
@@ -296,19 +294,18 @@ original VG, LV and internal layer names.
 .
 .SH UNIQUE NAMES
 .
-
 VG names should be unique.  vgcreate will produce an error if the
 specified VG name matches an existing VG name.  However, there are cases
 where different VGs with the same name can appear to LVM, e.g. after
 moving disks or changing filters.
-
+.P
 When VGs with the same name exist, commands operating on all VGs will
 include all of the VGs with the same name.  If the ambiguous VG name is
 specified on the command line, the command will produce an error.  The
 error states that multiple VGs exist with the specified name.  To process
 one of the VGs specifically, the --select option should be used with the
-UUID of the intended VG: '--select vg_uuid=<uuid>'.
-
+UUID of the intended VG: --select vg_uuid=<uuid>
+.P
 An exception is if all but one of the VGs with the shared name is foreign
 (see
 .BR lvmsystemid (7).)
@@ -317,18 +314,17 @@ VG and is processed.
 .P
 LV names are unique within a VG.  The name of an historical LV cannot be
 reused until the historical LV has itself been removed or renamed.
-
 .
 .SH ALLOCATION
 .
 When an operation needs to allocate Physical Extents for one or more
 Logical Volumes, the tools proceed as follows:
-
+.P
 First of all, they generate the complete set of unallocated Physical Extents
 in the Volume Group.  If any ranges of Physical Extents are supplied at
 the end of the command line, only unallocated Physical Extents within
 those ranges on the specified Physical Volumes are considered.
-
+.P
 Then they try each allocation policy in turn, starting with the strictest
 policy (\fBcontiguous\fP) and ending with the allocation policy specified
 using \fB--alloc\fP or set as the default for the particular Logical
@@ -337,14 +333,14 @@ lowest-numbered Logical Extent of the empty Logical Volume space that
 needs to be filled, they allocate as much space as possible according to
 the restrictions imposed by the policy.  If more space is needed,
 they move on to the next policy.
-
+.P
 The restrictions are as follows:
-
+.P
 \fBContiguous\fP requires that the physical location of any Logical
 Extent that is not the first Logical Extent of a Logical Volume is
 adjacent to the physical location of the Logical Extent immediately
 preceding it.
-
+.P
 \fBCling\fP requires that the Physical Volume used for any Logical
 Extent to be added to an existing Logical Volume is already in use by at
 least one Logical Extent earlier in that Logical Volume.  If the
@@ -353,31 +349,31 @@ Physical Volumes are considered to match if any of the listed tags is
 present on both Physical Volumes.  This allows groups of Physical
 Volumes with similar properties (such as their physical location) to be
 tagged and treated as equivalent for allocation purposes.
-
+.P
 When a Logical Volume is striped or mirrored, the above restrictions are
 applied independently to each stripe or mirror image (leg) that needs
 space.
-
+.P
 \fBNormal\fP will not choose a Physical Extent that shares the same Physical
 Volume as a Logical Extent already allocated to a parallel Logical
 Volume (i.e. a different stripe or mirror image/leg) at the same offset
 within that parallel Logical Volume.
-
+.P
 When allocating a mirror log at the same time as Logical Volumes to hold
 the mirror data, Normal will first try to select different Physical
 Volumes for the log and the data.  If that's not possible and the
 .B allocation/mirror_logs_require_separate_pvs
 configuration parameter is set to 0, it will then allow the log
 to share Physical Volume(s) with part of the data.
-
+.P
 When allocating thin pool metadata, similar considerations to those of a
 mirror log in the last paragraph apply based on the value of the
 .B allocation/thin_pool_metadata_require_separate_pvs
 configuration parameter.
-
+.P
 If you rely upon any layout behaviour beyond that documented here, be
 aware that it might change in future versions of the code.
-
+.P
 For example, if you supply on the command line two empty Physical
 Volumes that have an identical number of free Physical Extents available for
 allocation, the current code considers using each of them in the order
@@ -387,7 +383,7 @@ for a particular Logical Volume, then you should build it up through a
 sequence of \fBlvcreate\fP(8) and \fBlvconvert\fP(8) steps such that the
 restrictions described above applied to each step leave the tools no
 discretion over the layout.
-
+.P
 To view the way the allocation process currently works in any specific
 case, read the debug logging output, for example by adding \fB-vvvv\fP to
 a command.
@@ -501,7 +497,7 @@ Prepends source file name and code line number with libdm debugging.
 .BR lvm (8),
 .BR lvm.conf (5),
 .BR lvmconfig (8),
-
+.P
 .BR pvchange (8),
 .BR pvck (8),
 .BR pvcreate (8),
@@ -511,7 +507,7 @@ Prepends source file name and code line number with libdm debugging.
 .BR pvresize (8),
 .BR pvs (8),
 .BR pvscan (8),
-
+.P
 .BR vgcfgbackup (8),
 .BR vgcfgrestore (8),
 .BR vgchange (8),
@@ -531,7 +527,7 @@ Prepends source file name and code line number with libdm debugging.
 .BR vgs (8),
 .BR vgscan (8),
 .BR vgsplit (8),
-
+.P
 .BR lvcreate (8),
 .BR lvchange (8),
 .BR lvconvert (8),
@@ -543,26 +539,26 @@ Prepends source file name and code line number with libdm debugging.
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
 .BR lvmthin (7),
 .BR lvmcache (7),
-
+.P
 .BR dmsetup (8),
 .BR dmstats (8),
 .BR readline (3)
diff --git a/man/lvm.conf.5_main b/man/lvm.conf.5_main
index 3a45f1ce0..63945ea2f 100644
--- a/man/lvm.conf.5_main
+++ b/man/lvm.conf.5_main
@@ -1,28 +1,35 @@
 .TH LVM.CONF 5 "LVM TOOLS #VERSION#" "Red Hat, Inc." \" -*- nroff -*-
+.
 .SH NAME
+.
 lvm.conf \(em Configuration file for LVM2
+.
 .SH SYNOPSIS
+.
 .B #DEFAULT_SYS_DIR#/lvm.conf
+.
 .SH DESCRIPTION
+.
 \fBlvm.conf\fP is loaded during the initialisation phase of
 \fBlvm\fP(8).  This file can in turn lead to other files
 being loaded - settings read in later override earlier
 settings.  File timestamps are checked between commands and if
 any have changed, all the files are reloaded.
-
+.P
 For a description of each lvm.conf setting, run:
-
+.P
 .B lvmconfig --typeconfig default --withcomments --withspaces
-
+.P
 The settings defined in lvm.conf can be overridden by any
 of these extended configuration methods:
+.
 .TP
 .B direct config override on command line
 The \fB--config ConfigurationString\fP command line option takes the
 ConfigurationString as direct string representation of the configuration
 to override the existing configuration. The ConfigurationString is of
 exactly the same format as used in any LVM configuration file.
-
+.
 .TP
 .B profile config
 .br
@@ -30,17 +37,17 @@ A profile is a set of selected customizable configuration settings
 that are aimed to achieve a certain characteristics in various
 environments or uses. It's used to override existing configuration.
 Normally, the name of the profile should reflect that environment or use.
-
+.P
 There are two groups of profiles recognised: \fBcommand profiles\fP and
 \fBmetadata profiles\fP.
-
+.P
 The \fBcommand profile\fP is used to override selected configuration
 settings at global LVM command level - it is applied at the very beginning
 of LVM command execution and it is used throughout the whole time of LVM
 command execution. The command profile is applied by using the
 \fB--commandprofile ProfileName\fP command line option that is recognised by
 all LVM2 commands.
-
+.P
 The \fBmetadata profile\fP is used to override selected configuration
 settings at Volume Group/Logical Volume level - it is applied independently
 for each Volume Group/Logical Volume that is being processed. As such,
@@ -56,12 +63,12 @@ option during creation when using \fBvgcreate\fP or \fBlvcreate\fP command.
 The \fBvgs\fP and \fBlvs\fP reporting commands provide \fB-o vg_profile\fP
 and \fB-o lv_profile\fP output options to show the metadata profile
 currently attached to a Volume Group or a Logical Volume.
-
+.P
 The set of options allowed for command profiles is mutually exclusive
 when compared to the set of options allowed for metadata profiles. The
 settings that belong to either of these two sets can't be mixed together
 and LVM tools will reject such profiles.
-
+.P
 LVM itself provides a few predefined configuration profiles.
 Users are allowed to add more profiles with different values if needed.
 For this purpose, there's the \fBcommand_profile_template.profile\fP
@@ -74,31 +81,36 @@ or \fBlvmconfig --file <ProfileName.profile> --type profilable-metadata <section
 can be used to generate a configuration with profilable settings in either
 of the type for given section and save it to new ProfileName.profile
 (if the section is not specified, all profilable settings are reported).
-
-The profiles are stored in #DEFAULT_PROFILE_DIR# directory by default.
+.P
+The profiles are stored in \fI#DEFAULT_PROFILE_DIR#\fP directory by default.
 This location can be changed by using the \fBconfig/profile_dir\fP setting.
 Each profile configuration is stored in \fBProfileName.profile\fP file
 in the profile directory. When referencing the profile, the \fB.profile\fP
 suffix is left out.
-
+.
 .TP
 .B tag config
 .br
 See \fBtags\fP configuration setting description below.
-
-.LP
+.P
 When several configuration methods are used@the same time
 and when LVM looks for the value of a particular setting, it traverses
 this \fBconfig cascade\fP from left to right:
-
-\fBdirect config override on command line\fP -> \fBcommand profile config\fP -> \fBmetadata profile config\fP -> \fBtag config\fP -> \fBlvmlocal.conf\fB -> \fBlvm.conf\fP
-
+.P
+\fBdirect config override on command line\fP ->
+\fBcommand profile config\fP ->
+\fBmetadata profile config\fP ->
+\fBtag config\fP ->
+\fBlvmlocal.conf\fP ->
+\fBlvm.conf\fP
+.P
 No part of this cascade is compulsory. If there's no setting value found at
 the end of the cascade, a default value is used for that setting.
 Use \fBlvmconfig\fP to check what settings are in use and what
 the default values are.
+.
 .SH SYNTAX
-.LP
+.
 This section describes the configuration file syntax.
 .LP
 Whitespace is not significant unless it is within quotes.
@@ -109,15 +121,12 @@ They are treated as whitespace.
 Here is an informal grammar:
 .TP
 .BR file " = " value *
-.br
 A configuration file consists of a set of values.
 .TP
 .BR value " = " section " | " assignment
-.br
 A value can either be a new section, or an assignment.
 .TP
 .BR section " = " identifier " '" { "' " value "* '" } '
-.br
 A section groups associated values together. If the same section is
 encountered multiple times, the contents of all instances are concatenated
 together in the order of appearance.
@@ -142,60 +151,58 @@ e.g.	\fBlevel = 7\fP
 .br
 .TP
 .BR array " =  '" [ "' ( " type " '" , "')* " type " '" ] "' | '" [ "' '" ] '
-.br
 Inhomogeneous arrays are supported.
 .br
 Elements must be separated by commas.
 .br
 An empty array is acceptable.
 .TP
-.BR type " = " integer " | " float " | " string
-.BR integer " = [0-9]*"
+.BR type " = " integer | float | string
+.BR integer " = [" 0 - 9 "]*"
 .br
-.BR float " = [0-9]*'" . '[0-9]*
+.BR float " = [" 0 - 9 "]*'" . "'[" 0 - 9 ]*
 .br
-.B string \fR= '\fB"\fR'.*'\fB"\fR'
+.BR string " = '" \(dq "' .* '" \(dq '
 .IP
 Strings with spaces must be enclosed in double quotes, single words that start
 with a letter can be left unquoted.
-
+.
 .SH SETTINGS
-
+.
 The
 .B lvmconfig
 command prints the LVM configuration settings in various ways.
 See the man page
 .BR lvmconfig (8).
-
+.P
 Command to print a list of all possible config settings, with their
 default values:
 .br
 .B lvmconfig --type default
-
+.P
 Command to print a list of all possible config settings, with their
 default values, and a full description of each as a comment:
 .br
 .B lvmconfig --type default --withcomments
-
+.P
 Command to print a list of all possible config settings, with their
 current values (configured, non-default values are shown):
 .br
 .B lvmconfig --type current
-
+.P
 Command to print all config settings that have been configured with a
 different value than the default (configured, non-default values are
 shown):
 .br
 .B lvmconfig --type diff
-
+.P
 Command to print a single config setting, with its default value,
 and a full description, where "Section" refers to the config section,
 e.g. global, and "Setting" refers to the name of the specific setting,
 e.g. umask:
 .br
 .B lvmconfig --type default --withcomments Section/Setting
-
-
+.
 .SH FILES
 .I #DEFAULT_SYS_DIR#/lvm.conf
 .br
@@ -210,8 +217,8 @@ e.g. umask:
 .I #DEFAULT_LOCK_DIR#
 .br
 .I #DEFAULT_PROFILE_DIR#
-
+.
 .SH SEE ALSO
-.BR lvm (8)
+.
+.BR lvm (8),
 .BR lvmconfig (8)
-
diff --git a/man/lvm2-activation-generator.8_main b/man/lvm2-activation-generator.8_main
index 478c23bd5..4c54da285 100644
--- a/man/lvm2-activation-generator.8_main
+++ b/man/lvm2-activation-generator.8_main
@@ -1,49 +1,58 @@
 .TH "LVM2-ACTIVATION-GENERATOR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.
 .SH "NAME"
+.
 lvm2-activation-generator - generator for systemd units to activate LVM volumes on boot
+.
 .SH SYNOPSIS
+.
 .B #SYSTEMD_GENERATOR_DIR#/lvm2-activation-generator
-.sp
+.
 .SH DESCRIPTION
-
+.
 The lvm2-activation-generator is called by \fBsystemd\fP(1) on boot to
 generate systemd units at runtime to activate LVM Logical Volumes (LVs)
 when global/event_activation=0 is set in \fBlvm.conf\fP(5).  These units use
 \fBvgchange -aay\fP to activate LVs.
-
+.P
 If event_activation=1, the lvm2-activation-generator exits immediately without
 generating any systemd units, and LVM fully relies on event-based
-activation to activate LVs.  In this case, event-generated \fBpvscan
---cache -aay\fP commands activate LVs.
-
+activation to activate LVs.  In this case, event-generated
+.B pvscan --cache -aay
+commands activate LVs.
+.P
 These systemd units are generated by lvm2-activation-generator:
-.sp
-\fIlvm2-activation-early.service\fP
+.P
+.I lvm2-activation-early.service
 is run before systemd's special \fBcryptsetup.target\fP to activate
 LVs that are not layered on top of encrypted devices.
-
-\fIlvm2-activation.service\fP
+.P
+.I lvm2-activation.service
 is run after systemd's special \fBcryptsetup.target\fP to activate
 LVs that are layered on top of encrypted devices.
-
-\fIlvm2-activation-net.service\fP
+.P
+.I lvm2-activation-net.service
 is run after systemd's special \fBremote-fs-pre.target\fP to activate
 LVs that are layered on attached remote devices.
-
+.P
 Note that all the underlying LVM devices (Physical Volumes) need to be
 present when the service is run. If the there are any devices that appear
 to the system later, LVs using these devices need to be activated directly
 by \fBlvchange\fP(8) or \fBvgchange\fP(8).
-
+.P
 The lvm2-activation-generator implements the \fBGenerators Specification\fP
 as referenced in \fBsystemd\fP(1).
-.sp
+.
 .SH SEE ALSO
-.BR lvm.conf (5)
-.BR vgchange (8)
-.BR lvchange (8)
-.BR pvscan (8)
+.nh
+.ad l
+.BR lvm.conf (5),
+.BR vgchange (8),
+.BR lvchange (8),
+.BR pvscan (8),
+.P
+.BR systemd (1),
+.BR systemd.target (5),
+.BR systemd.special (7),
+.P
 .BR udev (7)
-.BR systemd (1)
-.BR systemd.target (5)
-.BR systemd.special (7)
diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 182dc0a79..20463a548 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -1,14 +1,16 @@
 .TH "LVMCACHE" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.
 .SH NAME
+.
 lvmcache \(em LVM caching
-
+.
 .SH DESCRIPTION
-
+.
 \fBlvm\fP(8) includes two kinds of caching that can be used to improve the
 performance of a Logical Volume (LV). When caching, varying subsets of an
 LV's data are temporarily stored on a smaller, faster device (e.g. an SSD)
 to improve the performance of the LV.
-
+.P
 To do this with lvm, a new special LV is first created from the faster
 device. This LV will hold the cache. Then, the new fast LV is attached to
 the main LV by way of an lvconvert command. lvconvert inserts one of the
@@ -17,164 +19,162 @@ mapper target combines the main LV and fast LV into a hybrid device that looks
 like the main LV, but has better performance. While the main LV is being
 used, portions of its data will be temporarily and transparently stored on
 the special fast LV.
-
+.P
 The two kinds of caching are:
-
+.P
 .IP \[bu] 2
 A read and write hot-spot cache, using the dm-cache kernel module.
 This cache tracks access patterns and adjusts its content deliberately so
 that commonly used parts of the main LV are likely to be found on the fast
 storage. LVM refers to this using the LV type \fBcache\fP.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 A write cache, using the dm-writecache kernel module.  This cache can be
 used with SSD or PMEM devices to speed up all writes to the main LV. Data
 read from the main LV is not stored in the cache, only newly written data.
 LVM refers to this using the LV type \fBwritecache\fP.
-
+.
 .SH USAGE
-
-.B 1. Identify main LV that needs caching
-
+.
+.SS 1. Identify main LV that needs caching
+.
 The main LV may already exist, and is located on larger, slower devices.
 A main LV would be created with a command like:
-
-.nf
-  $ lvcreate -n main -L Size vg /dev/slow_hhd
-.fi
-
-.B 2. Identify fast LV to use as the cache
-
+.P
+# lvcreate -n main -L Size vg /dev/slow_hhd
+.
+.SS 2. Identify fast LV to use as the cache
+.
 A fast LV is created using one or more fast devices, like an SSD.  This
 special LV will be used to hold the cache:
-
-.nf
-  $ lvcreate -n fast -L Size vg /dev/fast_ssd
-
-  $ lvs -a
+.P
+# lvcreate -n fast -L Size vg /dev/fast_ssd
+.P
+# lvs -a
   LV   Attr       Type   Devices
   fast -wi------- linear /dev/fast_ssd
   main -wi------- linear /dev/slow_hhd
 .fi
-
-.B 3. Start caching the main LV
-
+.
+.SS 3. Start caching the main LV
+.
 To start caching the main LV, convert the main LV to the desired caching
 type, and specify the fast LV to use as the cache:
-
-.nf
+.P
 using dm-cache (with cachepool):
-
-  $ lvconvert --type cache --cachepool fast vg/main
-
+.P
+# lvconvert --type cache --cachepool fast vg/main
+.P
 using dm-cache (with cachevol):
-
-  $ lvconvert --type cache --cachevol fast vg/main
-
+.P
+# lvconvert --type cache --cachevol fast vg/main
+.P
 using dm-writecache (with cachevol):
-
-  $ lvconvert --type writecache --cachevol fast vg/main
-
+.P
+# lvconvert --type writecache --cachevol fast vg/main
+.P
 For more alteratives see:
+.br
 dm-cache command shortcut
+.br
 dm-cache with separate data and metadata LVs
-.fi
-
-.B 4. Display LVs
-
+.
+.SS 4. Display LVs
+.
 Once the fast LV has been attached to the main LV, lvm reports the main LV
 type as either \fBcache\fP or \fBwritecache\fP depending on the type used.
 While attached, the fast LV is hidden, and renamed with a _cvol or _cpool
 suffix.  It is displayed by lvs -a.  The _corig or _wcorig LV represents
 the original LV without the cache.
-
-.nf
+.sp
 using dm-cache (with cachepool):
-
-  $ lvs -ao+devices
+.P
+# lvs -ao+devices
+.nf
   LV                 Pool         Type       Devices
   main               [fast_cpool] cache      main_corig(0)
   [fast_cpool]                    cache-pool fast_pool_cdata(0)
   [fast_cpool_cdata]              linear     /dev/fast_ssd
   [fast_cpool_cmeta]              linear     /dev/fast_ssd
   [main_corig]                    linear     /dev/slow_hhd
-
+.fi
+.sp
 using dm-cache (with cachevol):
-
-  $ lvs -ao+devices
+.P
+# lvs -ao+devices
+.P
+.nf
   LV           Pool        Type   Devices
   main         [fast_cvol] cache  main_corig(0)
   [fast_cvol]              linear /dev/fast_ssd
   [main_corig]             linear /dev/slow_hhd
-
+.fi
+.sp
 using dm-writecache (with cachevol):
-
-  $ lvs -ao+devices
+.P
+# lvs -ao+devices
+.P
+.nf
   LV            Pool        Type       Devices
   main          [fast_cvol] writecache main_wcorig(0)
   [fast_cvol]               linear     /dev/fast_ssd
   [main_wcorig]             linear     /dev/slow_hhd
 .fi
-
-.B 5. Use the main LV
-
+.
+.SS 5. Use the main LV
+.
 Use the LV until the cache is no longer wanted, or needs to be changed.
-
-.B 6. Stop caching
-
+.
+.SS 6. Stop caching
+.
 To stop caching the main LV and also remove unneeded cache pool,
 use the --uncache:
-
+.P
+# lvconvert --uncache vg/main
+.P
+# lvs -a
 .nf
-  $ lvconvert --uncache vg/main
-
-  $ lvs -a
   LV   VG Attr       Type   Devices
   main vg -wi------- linear /dev/slow_hhd
-
+.fi
+.P
 To stop caching the main LV, separate the fast LV from the main LV.  This
 changes the type of the main LV back to what it was before the cache was
 attached.
-
+.P
+# lvconvert --splitcache vg/main
+.P
+# lvs -a
 .nf
-  $ lvconvert --splitcache vg/main
-
-  $ lvs -a
   LV   VG Attr       Type   Devices
   fast vg -wi------- linear /dev/fast_ssd
   main vg -wi------- linear /dev/slow_hhd
-
 .fi
-
-.SS Create a new LV with caching.
-
+.
+.SS 7. Create a new LV with caching
+.
 A new LV can be created with caching attached at the time of creation
 using the following command:
-
+.P
 .nf
-$ lvcreate --type cache|writecache -n Name -L Size
+# lvcreate --type cache|writecache -n Name -L Size
 	--cachedevice /dev/fast_ssd vg /dev/slow_hhd
 .fi
-
+.P
 The main LV is created with the specified Name and Size from the slow_hhd.
 A hidden fast LV is created on the fast_ssd and is then attached to the
 new main LV.  If the fast_ssd is unused, the entire disk will be used as
 the cache unless the --cachesize option is used to specify a size for the
 fast LV.  The --cachedevice option can be repeated to use multiple disks
 for the fast LV.
-
+.
 .SH OPTIONS
-
-\&
-
+.
 .SS option args
-
-\&
-
+.
 .B --cachepool
 .IR CachePoolLV | LV
-.br
-
+.P
 Pass this option a cachepool LV or a standard LV.  When using a cache
 pool, lvm places cache data and cache metadata on different LVs.  The two
 LVs together are called a cache pool.  This has a bit better performance
@@ -184,19 +184,17 @@ A cache pool is represented as a special type of LV
 that cannot be used directly.  If a standard LV is passed with this
 option, lvm will first convert it to a cache pool by combining it with
 another LV to use for metadata.  This option can be used with dm-cache.
-
+.P
 .B --cachevol
 .I LV
-.br
-
+.P
 Pass this option a fast LV that should be used to hold the cache.  With a
 cachevol, cache data and metadata are stored in different parts of the
 same fast LV.  This option can be used with dm-writecache or dm-cache.
-
+.P
 .B --cachedevice
 .I PV
-.br
-
+.P
 This option can be used in place of --cachevol, in which case a cachevol
 LV will be created using the specified device.  This option can be
 repeated to create a cachevol using multiple devices, or a tag name can be
@@ -204,112 +202,96 @@ specified in which case the cachevol will be created using any of the
 devices with the given tag.  If a named cache device is unused, the entire
 device will be used to create the cachevol.  To create a cachevol of a
 specific size from the cache devices, include the --cachesize option.
-
-\&
-
+.
 .SS dm-cache block size
-
-\&
-
+.
 A cache pool will have a logical block size of 4096 bytes if it is created
 on a device with a logical block size of 4096 bytes.
-
+.P
 If a main LV has logical block size 512 (with an existing xfs file system
 using that size), then it cannot use a cache pool with a 4096 logical
 block size.  If the cache pool is attached, the main LV will likely fail
 to mount.
-
+.P
 To avoid this problem, use a mkfs option to specify a 4096 block size for
 the file system, or attach the cache pool before running mkfs.
-
+.
 .SS dm-writecache block size
-
-\&
-
+.
 The dm-writecache block size can be 4096 bytes (the default), or 512
 bytes.  The default 4096 has better performance and should be used except
 when 512 is necessary for compatibility.  The dm-writecache block size is
 specified with --cachesettings block_size=4096|512 when caching is started.
-
+.P
 When a file system like xfs already exists on the main LV prior to
 caching, and the file system is using a block size of 512, then the
 writecache block size should be set to 512.  (The file system will likely
 fail to mount if writecache block size of 4096 is used in this case.)
-
+.P
 Check the xfs sector size while the fs is mounted:
-
+.P
+# xfs_info /dev/vg/main
 .nf
-$ xfs_info /dev/vg/main
 Look for sectsz=512 or sectsz=4096
 .fi
-
+.P
 The writecache block size should be chosen to match the xfs sectsz value.
-
+.P
 It is also possible to specify a sector size of 4096 to mkfs.xfs when
 creating the file system.  In this case the writecache block size of 4096
 can be used.
-
+.
 .SS dm-writecache settings
-
-\&
-
+.
 Tunable parameters can be passed to the dm-writecache kernel module using
 the --cachesettings option when caching is started, e.g.
-
+.P
 .nf
-$ lvconvert --type writecache --cachevol fast \\
+# lvconvert --type writecache --cachevol fast \\
 	--cachesettings 'high_watermark=N writeback_jobs=N' vg/main
 .fi
-
+.P
 Tunable options are:
-
-.IP \[bu] 2
+.
+.TP
 high_watermark = <percent>
-
 Start writeback when the writecache usage reaches this percent (0-100).
-
-.IP \[bu] 2
+.
+.TP
 low_watermark = <percent>
-
 Stop writeback when the writecache usage reaches this percent (0-100).
-
-.IP \[bu] 2
+.
+.TP
 writeback_jobs = <count>
-
 Limit the number of blocks that are in flight during writeback.  Setting
 this value reduces writeback throughput, but it may improve latency of
 read requests.
-
-.IP \[bu] 2
+.
+.TP
 autocommit_blocks = <count>
-
 When the application writes this amount of blocks without issuing the
 FLUSH request, the blocks are automatically commited.
-
-.IP \[bu] 2
+.
+.TP 
 autocommit_time = <milliseconds>
-
 The data is automatically commited if this time passes and no FLUSH
 request is received.
-
-.IP \[bu] 2
+.
+.TP
 fua = 0|1
-
 Use the FUA flag when writing data from persistent memory back to the
 underlying device.
 Applicable only to persistent memory.
-
-.IP \[bu] 2
+.
+.TP
 nofua = 0|1
-
 Don't use the FUA flag when writing back data and send the FLUSH request
 afterwards.  Some underlying devices perform better with fua, some with
 nofua.  Testing is necessary to determine which.
 Applicable only to persistent memory.
-
-.IP \[bu] 2
+.
+.TP
 cleaner = 0|1
-
 Setting cleaner=1 enables the writecache cleaner mode in which data is
 gradually flushed from the cache.  If this is done prior to detaching the
 writecache, then the splitcache command will have little or no flushing to
@@ -317,99 +299,88 @@ perform.  If not done beforehand, the splitcache command enables the
 cleaner mode and waits for flushing to complete before detaching the
 writecache.  Adding cleaner=0 to the splitcache command will skip the
 cleaner mode, and any required flushing is performed in device suspend.
-
+.
 .SS dm-cache with separate data and metadata LVs
-
-\&
-
+.
 Preferred way of using dm-cache is to place the cache metadata and cache data
 on separate LVs.  To do this, a "cache pool" is created, which is a special
 LV that references two sub LVs, one for data and one for metadata.
-
+.P
 To create a cache pool of given data size and let lvm2 calculate appropriate
 metadata size:
-
-.nf
-$ lvcreate --type cache-pool -L DataSize -n fast vg /dev/fast_ssd1
-.fi
-
+.P
+# lvcreate --type cache-pool -L DataSize -n fast vg /dev/fast_ssd1
+.P
 To create a cache pool from separate LV and let lvm2 calculate
 appropriate cache metadata size:
-
-.nf
-$ lvcreate -n fast -L DataSize vg /dev/fast_ssd1
-$ lvconvert --type cache-pool vg/fast /dev/fast_ssd1
-.fi
-
+.P
+# lvcreate -n fast -L DataSize vg /dev/fast_ssd1
+.br
+# lvconvert --type cache-pool vg/fast /dev/fast_ssd1
+.br
+.P
 To create a cache pool from two separate LVs:
-
-.nf
-$ lvcreate -n fast -L DataSize vg /dev/fast_ssd1
-$ lvcreate -n fastmeta -L MetadataSize vg /dev/fast_ssd2
-$ lvconvert --type cache-pool --poolmetadata fastmeta vg/fast
-.fi
-
+.P
+# lvcreate -n fast -L DataSize vg /dev/fast_ssd1
+.br
+# lvcreate -n fastmeta -L MetadataSize vg /dev/fast_ssd2
+.br
+# lvconvert --type cache-pool --poolmetadata fastmeta vg/fast
+.P
 Then use the cache pool LV to start caching the main LV:
-
-.nf
-$ lvconvert --type cache --cachepool fast vg/main
-.fi
-
+.P
+# lvconvert --type cache --cachepool fast vg/main
+.P
 A variation of the same procedure automatically creates a cache pool when
 caching is started.  To do this, use a standard LV as the --cachepool
 (this will hold cache data), and use another standard LV as the
 --poolmetadata (this will hold cache metadata).  LVM will create a
 cache pool LV from the two specified LVs, and use the cache pool to start
 caching the main LV.
-
+.P
 .nf
-$ lvcreate -n fast -L DataSize vg /dev/fast_ssd1
-$ lvcreate -n fastmeta -L MetadataSize vg /dev/fast_ssd2
-$ lvconvert --type cache --cachepool fast --poolmetadata fastmeta vg/main
+# lvcreate -n fast -L DataSize vg /dev/fast_ssd1
+# lvcreate -n fastmeta -L MetadataSize vg /dev/fast_ssd2
+# lvconvert --type cache --cachepool fast --poolmetadata fastmeta vg/main
 .fi
-
+.
 .SS dm-cache cache modes
-
-\&
-
+.
 The default dm-cache cache mode is "writethrough".  Writethrough ensures
 that any data written will be stored both in the cache and on the origin
 LV.  The loss of a device associated with the cache in this case would not
 mean the loss of any data.
-
+.P
 A second cache mode is "writeback".  Writeback delays writing data blocks
 from the cache back to the origin LV.  This mode will increase
 performance, but the loss of a cache device can result in lost data.
-
+.P
 With the --cachemode option, the cache mode can be set when caching is
 started, or changed on an LV that is already cached.  The current cache
 mode can be displayed with the cache_mode reporting option:
-
+.P
 .B lvs -o+cache_mode VG/LV
-
+.P
 .BR lvm.conf (5)
 .B allocation/cache_mode
 .br
 defines the default cache mode.
-
+.P
 .nf
-$ lvconvert --type cache --cachemode writethrough \\
+# lvconvert --type cache --cachemode writethrough \\
         --cachepool fast vg/main
-
-
-$ lvconvert --type cache --cachemode writethrough \\
+.P
+# lvconvert --type cache --cachemode writethrough \\
         --cachevol fast  vg/main
 .nf
-
+.
 .SS dm-cache chunk size
-
-\&
-
+.
 The size of data blocks managed by dm-cache can be specified with the
 --chunksize option when caching is started.  The default unit is KiB.  The
 value must be a multiple of 32KiB between 32KiB and 1GiB. Cache chunks
 bigger then 512KiB shall be only used when necessary.
-
+.P
 Using a chunk size that is too large can result in wasteful use of the
 cache, in which small reads and writes cause large sections of an LV to be
 stored in the cache. It can also require increasing migration threshold
@@ -420,100 +391,90 @@ cache origin LV. However, choosing a chunk size that is too small
 can result in more overhead trying to manage the numerous chunks that
 become mapped into the cache.  Overhead can include both excessive CPU
 time searching for chunks, and excessive memory tracking chunks.
-
+.P
 Command to display the chunk size:
-.br
+.P
 .B lvs -o+chunksize VG/LV
-
+.P
 .BR lvm.conf (5)
 .B cache_pool_chunk_size
-.br
+.P
 controls the default chunk size.
-
+.P
 The default value is shown by:
-.br
+.P
 .B lvmconfig --type default allocation/cache_pool_chunk_size
-
+.P
 Checking migration threshold (in sectors) of running cached LV:
 .br
 .B lvs -o+kernel_cache_settings VG/LV
-
-
+.
 .SS dm-cache migration threshold
-
-\&
-
+.
 Migrating data between the origin and cache LV uses bandwidth.
 The user can set a throttle to prevent more than a certain amount of
 migration occurring at any one time.  Currently dm-cache is not taking any
 account of normal io traffic going to the devices.
-
+.P
 User can set migration threshold via cache policy settings as
 "migration_threshold=<#sectors>" to set the maximum number
 of sectors being migrated, the default being 2048 sectors (1MiB).
-
+.P
 Command to set migration threshold to 2MiB (4096 sectors):
-.br
+.P
 .B lvcreate --cachepolicy 'migration_threshold=4096' VG/LV
-
-
+.P
 Command to display the migration threshold:
-.br
+.P
 .B lvs -o+kernel_cache_settings,cache_settings VG/LV
 .br
 .B lvs -o+chunksize VG/LV
-
-
+.
 .SS dm-cache cache policy
-
-\&
-
+.
 The dm-cache subsystem has additional per-LV parameters: the cache policy
 to use, and possibly tunable parameters for the cache policy.  Three
 policies are currently available: "smq" is the default policy, "mq" is an
 older implementation, and "cleaner" is used to force the cache to write
 back (flush) all cached writes to the origin LV.
-
+.P
 The older "mq" policy has a number of tunable parameters. The defaults are
 chosen to be suitable for the majority of systems, but in special
 circumstances, changing the settings can improve performance.
-
+.P
 With the --cachepolicy and --cachesettings options, the cache policy and
 settings can be set when caching is started, or changed on an existing
 cached LV (both options can be used together).  The current cache policy
 and settings can be displayed with the cache_policy and cache_settings
 reporting options:
-
+.P
 .B lvs -o+cache_policy,cache_settings VG/LV
-
-.nf
+.P
 Change the cache policy and settings of an existing LV.
-
-$ lvchange --cachepolicy mq --cachesettings \\
+.nf
+# lvchange --cachepolicy mq --cachesettings \\
 	\(aqmigration_threshold=2048 random_threshold=4\(aq vg/main
 .fi
-
+.P
 .BR lvm.conf (5)
 .B allocation/cache_policy
 .br
 defines the default cache policy.
-
+.P
 .BR lvm.conf (5)
 .B allocation/cache_settings
 .br
 defines the default cache settings.
-
+.
 .SS dm-cache using metadata profiles
-
-\&
-
+.
 Cache pools allows to set a variety of options. Lots of these settings
 can be specified in lvm.conf or profile settings. You can prepare
 a number of different profiles in the #DEFAULT_SYS_DIR#/profile directory
 and just specify the metadata profile file name when caching LV or creating cache-pool.
 Check the output of \fBlvmconfig --type default --withcomments\fP
 for a detailed description of all individual cache settings.
-
+.P
 .I Example
 .nf
 # cat <<EOF > #DEFAULT_SYS_DIR#/profile/cache_big_chunk.profile
@@ -531,80 +492,74 @@ allocation {
 	}
 }
 EOF
-
+.P
 # lvcreate --cache -L10G --metadataprofile cache_big_chunk vg/main  /dev/fast_ssd
 # lvcreate --cache -L10G --config 'allocation/cache_pool_chunk_size=512' vg/main /dev/fast_ssd
 .fi
-
+.
 .SS dm-cache spare metadata LV
-
-\&
-
+.
 See
 .BR lvmthin (7)
 for a description of the "pool metadata spare" LV.
 The same concept is used for cache pools.
-
+.
 .SS dm-cache metadata formats
-
-\&
-
+.
 There are two disk formats for dm-cache metadata.  The metadata format can
 be specified with --cachemetadataformat when caching is started, and
 cannot be changed.  Format \fB2\fP has better performance; it is more
 compact, and stores dirty bits in a separate btree, which improves the
 speed of shutting down the cache.  With \fBauto\fP, lvm selects the best
 option provided by the current dm-cache kernel module.
-
+.
 .SS RAID1 cache device
-
-\&
-
+.
 RAID1 can be used to create the fast LV holding the cache so that it can
 tolerate a device failure.  (When using dm-cache with separate data
 and metadata LVs, each of the sub-LVs can use RAID1.)
-
+.P
 .nf
-$ lvcreate -n main -L Size vg /dev/slow
-$ lvcreate --type raid1 -m 1 -n fast -L Size vg /dev/ssd1 /dev/ssd2
-$ lvconvert --type cache --cachevol fast vg/main
+# lvcreate -n main -L Size vg /dev/slow
+# lvcreate --type raid1 -m 1 -n fast -L Size vg /dev/ssd1 /dev/ssd2
+# lvconvert --type cache --cachevol fast vg/main
 .fi
-
+.
 .SS dm-cache command shortcut
-
-\&
-
+.
 A single command can be used to cache main LV with automatic
 creation of a cache-pool:
-
+.P
 .nf
-$ lvcreate --cache --size CacheDataSize VG/LV [FastPVs]
+# lvcreate --cache --size CacheDataSize VG/LV [FastPVs]
 .fi
-
+.P
 or the longer variant
-
+.P
 .nf
-$ lvcreate --type cache --size CacheDataSize \\
+# lvcreate --type cache --size CacheDataSize \\
 	--name NameCachePool VG/LV [FastPVs]
 .fi
-
+.P
 In this command, the specified LV already exists, and is the main LV to be
 cached.  The command creates a new cache pool with size and given name
 or the name is automatically selected from a sequence lvolX_cpool,
 using the optionally specified fast PV(s) (typically an ssd).  Then it
 attaches the new cache pool to the existing main LV to begin caching.
-
+.P
 (Note: ensure that the specified main LV is a standard LV.  If a cache
 pool LV is mistakenly specified, then the command does something
 different.)
-
+.P
 (Note: the type option is interpreted differently by this command than by
 normal lvcreate commands in which --type specifies the type of the newly
 created LV.  In this case, an LV with type cache-pool is being created,
 and the existing main LV is being converted to type cache.)
-
-
+.
 .SH SEE ALSO
+.
+.nh
+.ad l
 .BR lvm.conf (5),
 .BR lvchange (8),
 .BR lvcreate (8),
@@ -614,7 +569,12 @@ and the existing main LV is being converted to type cache.)
 .BR lvrename (8),
 .BR lvresize (8),
 .BR lvs (8),
+.br
 .BR vgchange (8),
 .BR vgmerge (8),
 .BR vgreduce (8),
-.BR vgsplit (8)
+.BR vgsplit (8),
+.P
+.BR cache_dump (8),
+.BR cache_check (8),
+.BR cache_repair (8)
diff --git a/man/lvmdbusd.8_main b/man/lvmdbusd.8_main
index 99a7001f1..3990a024f 100644
--- a/man/lvmdbusd.8_main
+++ b/man/lvmdbusd.8_main
@@ -8,31 +8,28 @@ lvmdbusd \(em LVM D-Bus daemon
 .
 .ad l
 .B lvmdbusd
-.RB [ --debug \]
-.RB [ --udev \]
+.RB [ --debug ]
+.RB [ --udev ]
 .ad b
 .
 .SH DESCRIPTION
 .
 lvmdbusd is a service which provides a D-Bus API to the logical volume manager (LVM).
-Run 
+Run
 .BR lvmdbusd (8)
 as root.
 .
 .SH OPTIONS
 .
-.HP
-.BR --debug 
-.br
-Enable debug statements 
+.TP 8
+.B --debug
+Enable debug statements
 .
-.HP
-.BR --udev
-.br
+.TP
+.B --udev
 Use udev events to trigger updates
 .
 .SH SEE ALSO
 .
-.nh
 .BR dbus-send (1),
 .BR lvm (8)
diff --git a/man/lvmdump.8_main b/man/lvmdump.8_main
index cbd5f15ef..1fa6d817d 100644
--- a/man/lvmdump.8_main
+++ b/man/lvmdump.8_main
@@ -1,7 +1,11 @@
 .TH LVMDUMP 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
+.
 .SH NAME
+.
 lvmdump \(em create lvm2 information dumps for diagnostic purposes
+.
 .SH SYNOPSIS
+.
 .B lvmdump
 .RB [ -a ]
 .RB [ -c ]
@@ -13,46 +17,54 @@ lvmdump \(em create lvm2 information dumps for diagnostic purposes
 .RB [ -p ]
 .RB [ -s ]
 .RB [ -u ]
+.
 .SH DESCRIPTION
+.
 lvmdump is a tool to dump various information concerning LVM2.
 By default, it creates a tarball suitable for submission along
 with a problem report.
-.PP
+.P
 The content of the tarball is as follows:
-.br
-- dmsetup info
-.br
-- table of currently running processes
-.br
-- recent entries from /var/log/messages (containing system messages)
-.br
-- complete lvm configuration and cache (content of #DEFAULT_SYS_DIR#)
-.br
-- list of device nodes present under /dev
-.br
-- list of files present /sys/block
-.br
-- list of files present /sys/devices/virtual/block
-.br
-- if enabled with -m, metadata dump will be also included
-.br
-- if enabled with -a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included
-.br
-- if enabled with -l, lvmetad state if running
-.br
-- if enabled with -p, lvmpolld state if running
-.br
-- if enabled with -s, system info and context
-.br
-- if enabled with -u, udev info and context
+.ad l
+.PD 0
+.IP \[bu] 2
+dmsetup info
+.IP \[bu]
+table of currently running processes
+.IP \[bu]
+recent entries from /var/log/messages (containing system messages)
+.IP \[bu]
+complete lvm configuration and cache (content of #DEFAULT_SYS_DIR#)
+.IP \[bu]
+list of device nodes present under /dev
+.IP \[bu]
+list of files present /sys/block
+.IP \[bu]
+list of files present /sys/devices/virtual/block
+.IP \[bu]
+if enabled with -m, metadata dump will be also included
+.IP \[bu]
+if enabled with -a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included
+.IP \[bu]
+if enabled with -l, lvmetad state if running
+.IP \[bu]
+if enabled with -p, lvmpolld state if running
+.IP \[bu]
+if enabled with -s, system info and context
+.IP \[bu]
+if enabled with -u, udev info and context
+.PD
+.ad b
+.
 .SH OPTIONS
+.
 .TP
 .B -a
 Advanced collection.
 \fBWARNING\fR: if lvm is already hung, then this script may hang as well
 if \fB-a\fR is used.
 .TP
-.B -d  \fIdirectory
+.B -d \fIdirectory
 Dump into a directory instead of tarball
 By default, lvmdump will produce a single compressed tarball containing
 all the information. Using this option, it can be instructed to only
@@ -92,16 +104,19 @@ Gather udev info and context: /etc/udev/udev.conf file, udev daemon version
 (content of /lib/udev/rules.d and /etc/udev/rules.d directory),
 list of files in /lib/udev directory and dump of current udev
 database content (the output of 'udevadm info --export-db' command).
+.
 .SH ENVIRONMENT VARIABLES
+.
 .TP
-\fBLVM_BINARY\fP
+.B LVM_BINARY
 The LVM2 binary to use.
 Defaults to "lvm".
-Sometimes you might need to set this to "#LVM_PATH#/lvm.static", for example.
+Sometimes you might need to set this to "#LVM_PATH#.static", for example.
 .TP
-\fBDMSETUP_BINARY\fP
+.B DMSETUP_BINARY
 The dmsetup binary to use.
 Defaults to "dmsetup".
-.PP
+.
 .SH SEE ALSO
+.
 .BR lvm (8)
diff --git a/man/lvmlockctl.8_main b/man/lvmlockctl.8_main
index 14ce926b5..8b7b00977 100644
--- a/man/lvmlockctl.8_main
+++ b/man/lvmlockctl.8_main
@@ -1,69 +1,79 @@
 .TH "LVMLOCKCTL" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-
+.
 .SH NAME
-lvmlockctl \(em Control for lvmlockd 
-
+.
+lvmlockctl \(em Control for lvmlockd
+.
+.SH SYNOPSIS
+.
+.BR lvmlockctl " [" \fIoptions ]
+.
 .SH DESCRIPTION
+.
 This command interacts with
 .BR lvmlockd (8).
-
+.
 .SH OPTIONS
-
-lvmlockctl [options]
-
-.B  --help | -h
-        Show this help information.
-
-.B  --quit | -q
-        Tell lvmlockd to quit.
-
-.B  --info | -i
-        Print lock state information from lvmlockd.
-
-.B  --dump | -d
-        Print log buffer from lvmlockd.
-
-.B  --wait | -w 0|1
-        Wait option for other commands.
-
-.B  --force | -f 0|1
-        Force option for other commands.
-
-.B  --kill | -k
-.I vgname
-        Kill access to the VG when sanlock cannot renew lease.
-
-.B  --drop | -r
-.I vgname
-        Clear locks for the VG when it is unused after kill (-k).
-
-.B  --gl-enable | -E
-.I vgname
-        Tell lvmlockd to enable the global lock in a sanlock VG.
-
-.B  --gl-disable | -D
-.I vgname
-        Tell lvmlockd to disable the global lock in a sanlock VG.
-
-.B  --stop-lockspaces | -S
-        Stop all lockspaces.
-
-
+.
+.TP
+.BR -h | --help
+Show this help information.
+.
+.TP
+.BR -q | --quit
+Tell lvmlockd to quit.
+.
+.TP
+.BR -i | --info
+Print lock state information from lvmlockd.
+.
+.TP
+.BR -d | --dump
+Print log buffer from lvmlockd.
+.
+.TP
+.BR -w | --wait\ 0 | 1
+Wait option for other commands.
+.
+.TP
+.BR -f | --force\ 0 | 1
+Force option for other commands.
+.
+.TP
+.BR -k | --kill " " \fIvgname
+Kill access to the VG when sanlock cannot renew lease.
+.
+.TP
+.BR -r | --drop " " \fIvgname
+Clear locks for the VG when it is unused after kill (-k).
+.
+.TP
+.BR -E | --gl-enable " " \fIvgname
+Tell lvmlockd to enable the global lock in a sanlock VG.
+.
+.TP
+.BR -D | --gl-disable " " \fIvgname
+Tell lvmlockd to disable the global lock in a sanlock VG.
+.
+.TP
+.BR -S | --stop-lockspaces
+Stop all lockspaces.
+.
 .SH USAGE
-
+.
 .SS info
-
+.
 This collects and displays lock state from lvmlockd.  The display is
 primitive, incomplete and will change in future version.  To print the raw
 lock state from lvmlockd, combine this option with --dump|-d.
-
+.
 .SS dump
-
+.
 This collects the circular log buffer of debug statements from lvmlockd
 and prints it.
-
+.
 .SS kill
-
+.
 This is run by sanlock when it loses access to the storage holding leases
 for a VG.  It runs the command specified in lvm.conf
 lvmlockctl_kill_command to deactivate LVs in the VG.  If the specified
@@ -73,34 +83,37 @@ is specified, or the command fails, then the user must intervene
 to forcefully deactivate LVs in the VG, and if successful, run
 lvmlockctl --drop.  For more, see
 .BR lvmlockd (8).
-
+.
 .SS drop
-
+.
 This should only be run after a VG has been successfully deactivated
 following an lvmlockctl --kill command.  It clears the stale lockspace
 from lvmlockd.  When lvmlockctl_kill_command is used, the --kill
 command may run drop automatically.  For more, see
 .BR lvmlockd (8).
-
+.
 .SS gl-enable
-
+.
 This enables the global lock in a sanlock VG.  This is necessary if the VG
 that previously held the global lock is removed.  For more, see
 .BR lvmlockd (8).
-
+.
 .SS gl-disable
-
+.
 This disables the global lock in a sanlock VG.  This is necessary if the
 global lock has mistakenly been enabled in more than one VG.  The global
 lock should be disabled in all but one sanlock VG.  For more, see
 .BR lvmlockd (8).
-
+.
 .SS stop-lockspaces
-
+.
 This tells lvmlockd to stop all lockspaces.  It can be useful to stop
 lockspaces for VGs that the vgchange --lock-stop comand can no longer
 see, or to stop the dlm global lockspace which is not directly stopped by
 the vgchange command.  The wait and force options can be used with this
 command.
-
-
+.
+.SH SEE ALSO
+.
+.BR lvm (8),
+.BR lvmlockd (8)
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index d1eee63fc..717292dc6 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -1,13 +1,19 @@
 .TH "LVMLOCKD" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-
+.
 .SH NAME
+.
 lvmlockd \(em LVM locking daemon
-
+.
+.SH SYNOPSIS
+.
+.BR lvmlockd " [" \fIoptions ]
+.
 .SH DESCRIPTION
+.
 LVM commands use lvmlockd to coordinate access to shared storage.
 .br
 When LVM is used on devices shared by multiple hosts, locks will:
-
+.br
 \[bu]
 coordinate reading and writing of LVM metadata
 .br
@@ -17,116 +23,119 @@ validate caching of LVM metadata
 \[bu]
 prevent conflicting activation of logical volumes
 .br
-
 lvmlockd uses an external lock manager to perform basic locking.
-.br
+.P
 Lock manager (lock type) options are:
-
+.br
 \[bu]
 sanlock: places locks on disk within LVM storage.
 .br
 \[bu]
 dlm: uses network communication and a cluster manager.
 .br
-
+.
 .SH OPTIONS
-
-lvmlockd [options]
-
-For default settings, see lvmlockd -h.
-
-.B  --help | -h
-        Show this help information.
-
-.B  --version | -V
-        Show version of lvmlockd.
-
-.B  --test | -T
-        Test mode, do not call lock manager.
-
-.B  --foreground | -f
-        Don't fork.
-
-.B  --daemon-debug | -D
-        Don't fork and print debugging to stdout.
-
-.B  --pid-file | -p
-.I path
-        Set path to the pid file.
-
-.B  --socket-path | -s
-.I path
-        Set path to the socket to listen on.
-
-.B  --adopt-file
-.I path
-        Set path to the adopt file.
-
-.B  --syslog-priority | -S err|warning|debug
-        Write log messages from this level up to syslog.
-
-.B  --gl-type | -g sanlock|dlm
-        Set global lock type to be sanlock or dlm.
-
-.B  --host-id | -i
-.I num
-        Set the local sanlock host id.
-
-.B  --host-id-file | -F
-.I path
-        A file containing the local sanlock host_id.
-
-.B  --sanlock-timeout | -o
-.I seconds
-        Override the default sanlock I/O timeout.
-
-.B --adopt | -A 0|1
-        Enable (1) or disable (0) lock adoption.
-
+.
+.TP
+.BR -h | --help
+Show this help information.
+.
+.TP
+.BR -V | --version
+Show version of lvmlockd.
+.
+.TP
+.BR -T | --test
+Test mode, do not call lock manager.
+.
+.TP
+.BR -f | --foreground
+Don't fork.
+.
+.TP
+.BR -D | --daemon-debug
+Don't fork and print debugging to stdout.
+.
+.TP
+.BR -p | --pid-file " " \fIpath
+Set path to the pid file.
+.
+.TP
+.BR -s | --socket-path " " \fIpath
+Set path to the socket to listen on.
+.
+.TP
+.B --adopt-file \fIpath
+Set path to the adopt file.
+.
+.TP
+.BR -S | --syslog-priority " " err | warning | debug
+Write log messages from this level up to syslog.
+.
+.TP
+.BR -g | --gl-type " " sanlock | dlm
+Set global lock type to be sanlock or dlm.
+.
+.TP
+.BR -i | --host-id " " \fInum
+Set the local sanlock host id.
+.
+.TP
+.BR -F | --host-id-file " " \fIpath
+A file containing the local sanlock host_id.
+.
+.TP
+.BR -o | --sanlock-timeout " " \fIseconds
+Override the default sanlock I/O timeout.
+.
+.TP
+.BR -A | --adopt " " 0 | 1
+Enable (1) or disable (0) lock adoption.
+.
 .SH USAGE
-
+.
 .SS Initial set up
-
+.
 Setting up LVM to use lvmlockd and a shared VG for the first time includes
 some one time set up steps:
-
+.
 .SS 1. choose a lock manager
-
+.
 .I dlm
 .br
 If dlm (or corosync) are already being used by other cluster
 software, then select dlm.  dlm uses corosync which requires additional
 configuration beyond the scope of this document.  See corosync and dlm
 documentation for instructions on configuration, set up and usage.
-
+.P
 .I sanlock
 .br
 Choose sanlock if dlm/corosync are not otherwise required.
 sanlock does not depend on any clustering software or configuration.
-
+.
 .SS 2. configure hosts to use lvmlockd
-
+.
 On all hosts running lvmlockd, configure lvm.conf:
 .nf
 use_lvmlockd = 1
 .fi
-
+.P
 .I sanlock
 .br
 Assign each host a unique host_id in the range 1-2000 by setting
 .br
 #DEFAULT_SYS_DIR#/lvmlocal.conf local/host_id
-
+.
 .SS 3. start lvmlockd
-
+.
 Start the lvmlockd daemon.
 .br
 Use systemctl, a cluster resource agent, or run directly, e.g.
 .br
 systemctl start lvmlockd
-
+.
 .SS 4. start lock manager
-
+.
 .I sanlock
 .br
 Start the sanlock and wdmd daemons.
@@ -134,7 +143,7 @@ Start the sanlock and wdmd daemons.
 Use systemctl or run directly, e.g.
 .br
 systemctl start wdmd sanlock
-
+.P
 .I dlm
 .br
 Start the dlm and corosync daemons.
@@ -142,42 +151,41 @@ Start the dlm and corosync daemons.
 Use systemctl, a cluster resource agent, or run directly, e.g.
 .br
 systemctl start corosync dlm
-
+.
 .SS 5. create VG on shared devices
-
+.
 vgcreate --shared <vgname> <devices>
-
+.P
 The shared option sets the VG lock type to sanlock or dlm depending on
 which lock manager is running.  LVM commands acquire locks from lvmlockd,
 and lvmlockd uses the chosen lock manager.
-
+.
 .SS 6. start VG on all hosts
-
+.
 vgchange --lock-start
-
+.P
 Shared VGs must be started before they are used.  Starting the VG performs
 lock manager initialization that is necessary to begin using locks (i.e.
 creating and joining a lockspace).  Starting the VG may take some time,
 and until the start completes the VG may not be modified or activated.
-
+.
 .SS 7. create and activate LVs
-
+.
 Standard lvcreate and lvchange commands are used to create and activate
 LVs in a shared VG.
-
+.P
 An LV activated exclusively on one host cannot be activated on another.
 When multiple hosts need to use the same LV concurrently, the LV can be
 activated with a shared lock (see lvchange options -aey vs -asy.)
 (Shared locks are disallowed for certain LV types that cannot be used from
 multiple hosts.)
-
-
+.
 .SS Normal start up and shut down
-
+.
 After initial set up, start up and shut down include the following steps.
 They can be performed directly or may be automated using systemd or a
 cluster resource manager/agents.
-
+.P
 \[bu]
 start lvmlockd
 .br
@@ -190,9 +198,9 @@ vgchange --lock-start
 \[bu]
 activate LVs in shared VGs
 .br
-
+.P
 The shut down sequence is the reverse:
-
+.P
 \[bu]
 deactivate LVs in shared VGs
 .br
@@ -204,35 +212,32 @@ stop lock manager
 .br
 \[bu]
 stop lvmlockd
-.br
-
-.P
-
+.
 .SH TOPICS
-
+.
 .SS Protecting VGs on shared devices
-
+.
 The following terms are used to describe the different ways of accessing
 VGs on shared devices.
-
+.P
 .I "shared VG"
-
+.P
 A shared VG exists on shared storage that is visible to multiple hosts.
 LVM acquires locks through lvmlockd to coordinate access to shared VGs.
 A shared VG has lock_type "dlm" or "sanlock", which specifies the lock
 manager lvmlockd will use.
-
+.P
 When the lock manager for the lock type is not available (e.g. not started
 or failed), lvmlockd is unable to acquire locks for LVM commands.  In this
 situation, LVM commands are only allowed to read and display the VG;
 changes and activation will fail.
-
+.P
 .I "local VG"
-
+.P
 A local VG is meant to be used by a single host.  It has no lock type or
 lock type "none".  A local VG typically exists on local (non-shared)
 devices and cannot be used concurrently from different hosts.
-
+.P
 If a local VG does exist on shared devices, it should be owned by a single
 host by having the system ID set, see
 .BR lvmsystemid (7).
@@ -241,97 +246,92 @@ will ignore it.  A VG with no lock type and no system ID should be
 excluded from all but one host using lvm.conf filters.  Without any of
 these protections, a local VG on shared devices can be easily damaged or
 destroyed.
-
+.P
 .I "clvm VG"
-
+.P
 A clvm VG (or clustered VG) is a VG on shared storage (like a shared VG)
 that requires clvmd for clustering and locking.  See below for converting
 a clvm/clustered VG to a shared VG.
-
-
-.SS shared VGs from hosts not using lvmlockd
-
+.
+.SS Shared VGs from hosts not using lvmlockd
+.
 Hosts that do not use shared VGs will not be running lvmlockd.  In this
 case, shared VGs that are still visible to the host will be ignored
-(like foreign VGs, see 
-.BR lvmsystemid (7).)
-
+(like foreign VGs, see
+.BR lvmsystemid (7)).
+.P
 The --shared option for reporting and display commands causes shared VGs
 to be displayed on a host not using lvmlockd, like the --foreign option
 does for foreign VGs.
-
-
-.SS creating the first sanlock VG
-
+.
+.SS Creating the first sanlock VG
+.
 When use_lvmlockd is first enabled in lvm.conf, and before the first
 sanlock VG is created, no global lock will exist.  In this initial state,
 LVM commands try and fail to acquire the global lock, producing a warning,
 and some commands are disallowed.  Once the first sanlock VG is created,
 the global lock will be available, and LVM will be fully operational.
-
+.P
 When a new sanlock VG is created, its lockspace is automatically started on
 the host that creates it.  Other hosts need to run 'vgchange --lock-start'
 to start the new VG before they can use it.
-
+.P
 Creating the first sanlock VG is not protected by locking, so it requires
 special attention.  This is because sanlock locks exist on storage within
 the VG, so they are not available until after the VG is created.  The
 first sanlock VG that is created will automatically contain the "global
 lock".  Be aware of the following special considerations:
-
+.P
 .IP \[bu] 2
 The first vgcreate command needs to be given the path to a device that has
 not yet been initialized with pvcreate.  The pvcreate initialization will
 be done by vgcreate.  This is because the pvcreate command requires the
 global lock, which will not be available until after the first sanlock VG
 is created.
-
-.IP \[bu] 2
+.IP \[bu]
 Because the first sanlock VG will contain the global lock, this VG needs
 to be accessible to all hosts that will use sanlock shared VGs.  All hosts
 will need to use the global lock from the first sanlock VG.
-
-.IP \[bu] 2
+.IP \[bu]
 The device and VG name used by the initial vgcreate will not be protected
 from concurrent use by another vgcreate on another host.
-
+.P
 See below for more information about managing the sanlock global lock.
-
-
-.SS using shared VGs
-
+.
+.SS Using shared VGs
+.
 In the 'vgs' command, shared VGs are indicated by "s" (for shared) in
 the sixth attr field, and by "shared" in the "--options shared" report
 field.  The specific lock type and lock args for a shared VG can be
 displayed with 'vgs -o+locktype,lockargs'.
-
+.P
 Shared VGs need to be "started" and "stopped", unlike other types of VGs.
 See the following section for a full description of starting and stopping.
-
+.P
 Removing a shared VG will fail if other hosts have the VG started.  Run
 vgchange --lock-stop <vgname> on all other hosts before vgremove.  (It may
 take several seconds before vgremove recognizes that all hosts have
 stopped a sanlock VG.)
-
-.SS starting and stopping VGs
-
+.
+.SS Starting and stopping VGs
+.
 Starting a shared VG (vgchange --lock-start) causes the lock manager to
 start (join) the lockspace for the VG on the host where it is run.  This
 makes locks for the VG available to LVM commands on the host.  Before a VG
 is started, only LVM commands that read/display the VG are allowed to
 continue without locks (and with a warning).
-
+.P
 Stopping a shared VG (vgchange --lock-stop) causes the lock manager to
 stop (leave) the lockspace for the VG on the host where it is run.  This
 makes locks for the VG inaccessible to the host.  A VG cannot be stopped
 while it has active LVs.
-
+.P
 When using the lock type sanlock, starting a VG can take a long time
 (potentially minutes if the host was previously shut down without cleanly
 stopping the VG.)
-
+.P
 A shared VG can be started after all the following are true:
-.br
+.P
 \[bu]
 lvmlockd is running
 .br
@@ -340,55 +340,52 @@ the lock manager is running
 .br
 \[bu]
 the VG's devices are visible on the system
-.br
-
+.P
 A shared VG can be stopped if all LVs are deactivated.
-
+.P
 All shared VGs can be started/stopped using:
 .br
 vgchange --lock-start
 .br
 vgchange --lock-stop
-
-
+.P
 Individual VGs can be started/stopped using:
 .br
 vgchange --lock-start <vgname> ...
 .br
 vgchange --lock-stop <vgname> ...
-
+.P
 To make vgchange not wait for start to complete:
 .br
 vgchange --lock-start --lock-opt nowait ...
-
+.P
 lvmlockd can be asked directly to stop all lockspaces:
 .br
 lvmlockctl -S|--stop-lockspaces
-
+.P
 To start only selected shared VGs, use the lvm.conf
 activation/lock_start_list.  When defined, only VG names in this list are
 started by vgchange.  If the list is not defined (the default), all
 visible shared VGs are started.  To start only "vg1", use the following
 lvm.conf configuration:
-
+.P
 .nf
 activation {
     lock_start_list = [ "vg1" ]
     ...
 }
 .fi
-
-
-.SS internal command locking
-
+.
+.SS Internal command locking
+.
 To optimize the use of LVM with lvmlockd, be aware of the three kinds of
 locks and when they are used:
-
+.P
 .I Global lock
-
+.P
 The global lock is associated with global information, which is
 information not isolated to a single VG.  This includes:
-
+.P
 \[bu]
 The global VG namespace.
 .br
@@ -397,40 +394,39 @@ The set of orphan PVs and unused devices.
 .br
 \[bu]
 The properties of orphan PVs, e.g. PV size.
-.br
-
+.P
 The global lock is acquired in shared mode by commands that read this
 information, or in exclusive mode by commands that change it.  For
 example, the command 'vgs' acquires the global lock in shared mode because
 it reports the list of all VG names, and the vgcreate command acquires the
 global lock in exclusive mode because it creates a new VG name, and it
 takes a PV from the list of unused PVs.
-
+.P
 When an LVM command is given a tag argument, or uses select, it must read
 all VGs to match the tag or selection, which causes the global lock to be
 acquired.
-
+.P
 .I VG lock
-
+.P
 A VG lock is associated with each shared VG.  The VG lock is acquired in
 shared mode to read the VG and in exclusive mode to change the VG or
 activate LVs.  This lock serializes access to a VG with all other LVM
 commands accessing the VG from all hosts.
-
+.P
 The command 'vgs <vgname>' does not acquire the global lock (it does not
 need the list of all VG names), but will acquire the VG lock on each VG
 name argument.
-
+.P
 .I LV lock
-
+.P
 An LV lock is acquired before the LV is activated, and is released after
 the LV is deactivated.  If the LV lock cannot be acquired, the LV is not
 activated.  (LV locks are persistent and remain in place when the
 activation command is done.  Global and VG locks are transient, and are
 held only while an LVM command is running.)
-
+.P
 .I lock retries
-
+.P
 If a request for a global or VG lock fails due to a lock conflict with
 another host, lvmlockd automatically retries for a short time before
 returning a failure to the LVM command.  If those retries are
@@ -438,25 +434,24 @@ insufficient, the LVM command will retry the entire lock request a number
 of times specified by global/lvmlockd_lock_retries before failing.  If a
 request for an LV lock fails due to a lock conflict, the command fails
 immediately.
-
-
-.SS managing the global lock in sanlock VGs
-
+.
+.SS Managing the global lock in sanlock VGs
+.
 The global lock exists in one of the sanlock VGs.  The first sanlock VG
 created will contain the global lock.  Subsequent sanlock VGs will each
 contain a disabled global lock that can be enabled later if necessary.
-
+.P
 The VG containing the global lock must be visible to all hosts using
 sanlock VGs.  For this reason, it can be useful to create a small sanlock
 VG, visible to all hosts, and dedicated to just holding the global lock.
 While not required, this strategy can help to avoid difficulty in the
 future if VGs are moved or removed.
-
+.P
 The vgcreate command typically acquires the global lock, but in the case
 of the first sanlock VG, there will be no global lock to acquire until the
 first vgcreate is complete.  So, creating the first sanlock VG is a
 special case that skips the global lock.
-
+.P
 vgcreate determines that it's creating the first sanlock VG when no other
 sanlock VGs are visible on the system.  It is possible that other sanlock
 VGs do exist, but are not visible when vgcreate checks for them.  In this
@@ -464,51 +459,49 @@ case, vgcreate will create a new sanlock VG with the global lock enabled.
 When the another VG containing a global lock appears, lvmlockd will then
 see more than one VG with a global lock enabled.  LVM commands will report
 that there are duplicate global locks.
-
+.P
 If the situation arises where more than one sanlock VG contains a global
 lock, the global lock should be manually disabled in all but one of them
 with the command:
-
+.P
 lvmlockctl --gl-disable <vgname>
-
+.P
 (The one VG with the global lock enabled must be visible to all hosts.)
-
+.P
 An opposite problem can occur if the VG holding the global lock is
 removed.  In this case, no global lock will exist following the vgremove,
 and subsequent LVM commands will fail to acquire it.  In this case, the
 global lock needs to be manually enabled in one of the remaining sanlock
 VGs with the command:
-
+.P
 lvmlockctl --gl-enable <vgname>
-
+.P
 (Using a small sanlock VG dedicated to holding the global lock can avoid
 the case where the global lock must be manually enabled after a vgremove.)
-
-
-.SS internal lvmlock LV
-
+.
+.SS Internal lvmlock LV
+.
 A sanlock VG contains a hidden LV called "lvmlock" that holds the sanlock
 locks.  vgreduce cannot yet remove the PV holding the lvmlock LV.  To
 remove this PV, change the VG lock type to "none", run vgreduce, then
 change the VG lock type back to "sanlock".  Similarly, pvmove cannot be
 used on a PV used by the lvmlock LV.
-
+.P
 To place the lvmlock LV on a specific device, create the VG with only that
 device, then use vgextend to add other devices.
-
-
+.
 .SS LV activation
-
+.
 In a shared VG, LV activation involves locking through lvmlockd, and the
 following values are possible with lvchange/vgchange -a:
-
+.P
 .IP \fBy\fP|\fBey\fP
 The command activates the LV in exclusive mode, allowing a single host
 to activate the LV.  Before activating the LV, the command uses lvmlockd
 to acquire an exclusive lock on the LV.  If the lock cannot be acquired,
 the LV is not activated and an error is reported.  This would happen if
 the LV is active on another host.
-
+.
 .IP \fBsy\fP
 The command activates the LV in shared mode, allowing multiple hosts to
 activate the LV concurrently.  Before activating the LV, the
@@ -521,14 +514,13 @@ The shared mode is intended for a multi-host/cluster application or
 file system.
 LV types that cannot be used concurrently
 from multiple hosts include thin, cache, raid, mirror, and snapshot.
-
+.
 .IP \fBn\fP
 The command deactivates the LV.  After deactivating the LV, the command
 uses lvmlockd to release the current lock on the LV.
-
-
-.SS manually repairing a shared VG
-
+.
+.SS Manually repairing a shared VG
+.
 Some failure conditions may not be repairable while the VG has a shared
 lock type.  In these cases, it may be possible to repair the VG by
 forcibly changing the lock type to "none".  This is done by adding
@@ -536,10 +528,9 @@ forcibly changing the lock type to "none".  This is done by adding
 vgchange --lock-type none VG.  The VG lockspace should first be stopped on
 all hosts, and be certain that no hosts are using the VG before this is
 done.
-
-
-.SS recover from lost PV holding sanlock locks
-
+.
+.SS Recover from lost PV holding sanlock locks
+.
 In a sanlock VG, the sanlock locks are held on the hidden "lvmlock" LV.
 If the PV holding this LV is lost, a new lvmlock LV needs to be created.
 To do this, ensure no hosts are using the VG, then forcibly change the
@@ -547,12 +538,11 @@ lock type to "none" (see above).  Then change the lock type back to
 "sanlock" with the normal command for changing the lock type:  vgchange
 --lock-type sanlock VG.  This recreates the internal lvmlock LV with the
 necessary locks.
-
-
-.SS locking system failures
-
+.
+.SS Locking system failures
+.
 .B lvmlockd failure
-
+.P
 If lvmlockd fails or is killed while holding locks, the locks are orphaned
 in the lock manager.  Orphaned locks must be cleared or adopted before the
 associated resources can be accessed normally.  If lock adoption is
@@ -561,53 +551,53 @@ instance of lvmlockd will then adopt locks orphaned by the previous
 instance.  Adoption must be enabled in both instances (--adopt|-A 1).
 Without adoption, the lock manager or host would require a reset to clear
 orphaned lock state.
-
+.P
 .B dlm/corosync failure
-
+.P
 If dlm or corosync fail, the clustering system will fence the host using a
 method configured within the dlm/corosync clustering environment.
-
+.P
 LVM commands on other hosts will be blocked from acquiring any locks until
 the dlm/corosync recovery process is complete.
-
+.P
 .B sanlock lease storage failure
-
+.P
 If the PV under a sanlock VG's lvmlock LV is disconnected, unresponsive or
 too slow, sanlock cannot renew the lease for the VG's locks.  After some
 time, the lease will expire, and locks that the host owns in the VG can be
 acquired by other hosts.  The VG must be forcibly deactivated on the host
 with the expiring lease before other hosts can acquire its locks.  This is
 necessary for data protection.
-
+.P
 When the sanlock daemon detects that VG storage is lost and the VG lease
 is expiring, it runs the command lvmlockctl --kill <vgname>.  This command
 emits a syslog message stating that storage is lost for the VG, and that
 LVs in the VG must be immediately deactivated.
-
+.P
 If no LVs are active in the VG, then the VG lockspace will be removed, and
 errors will be reported when trying to use the VG.  Use the lvmlockctl
 --drop command to clear the stale lockspace from lvmlockd.
-
+.P
 If the VG has active LVs, they must be quickly deactivated before the
 locks expire.  After all LVs are deactivated, run lvmlockctl --drop
 <vgname> to clear the expiring lockspace from lvmlockd.
-
+.P
 If all LVs in the VG are not deactivated within about 40 seconds, sanlock
 uses wdmd and the local watchdog to reset the host.  The machine reset is
 effectively a severe form of "deactivating" LVs before they can be
 activated on other hosts.  The reset is considered a better alternative
 than having LVs used by multiple hosts at once, which could easily damage
 or destroy their content.
-
+.P
 .B sanlock lease storage failure automation
-
+.P
 When the sanlock daemon detects that the lease storage is lost, it runs
 the command lvmlockctl --kill <vgname>.  This lvmlockctl command can be
 configured to run another command to forcibly deactivate LVs, taking the
 place of the manual process described above.  The other command is
 configured in the lvm.conf lvmlockctl_kill_command setting.  The VG name
 is appended to the end of the command specified.
-
+.P
 The lvmlockctl_kill_command should forcibly deactivate LVs in the VG,
 ensuring that existing writes to LVs in the VG are complete and that
 further writes to the LVs in the VG will be rejected.  If it is able to do
@@ -616,7 +606,7 @@ with an error.  If lvmlockctl --kill gets a successful result from
 lvmlockctl_kill_command, it tells lvmlockd to drop locks for the VG (the
 equivalent of running lvmlockctl --drop).  If this completes in time, a
 machine reset can be avoided.
-
+.P
 One possible option is to create a script my_vg_kill_script.sh:
 .nf
   #!/bin/bash
@@ -630,191 +620,181 @@ One possible option is to create a script my_vg_kill_script.sh:
   fi
   exit 1
 .fi
-
+.P
 Set in lvm.conf:
 .nf
   lvmlockctl_kill_command="/usr/sbin/my_vg_kill_script.sh"
 .fi
-
+.P
 (The script and dmsetup commands should be tested with the actual VG to
 ensure that all top level LVs are properly disabled.)
-
+.P
 If the lvmlockctl_kill_command is not configured, or fails, lvmlockctl
 --kill will emit syslog messages as described in the previous section,
 notifying the user to manually deactivate the VG before sanlock resets the
 machine.
-
+.P
 .B sanlock daemon failure
-
+.P
 If the sanlock daemon fails or exits while a lockspace is started, the
 local watchdog will reset the host.  This is necessary to protect any
 application resources that depend on sanlock leases.
-
-
-.SS changing dlm cluster name
-
+.
+.SS Changing dlm cluster name
+.
 When a dlm VG is created, the cluster name is saved in the VG metadata.
 To use the VG, a host must be in the named dlm cluster.  If the dlm
 cluster name changes, or the VG is moved to a new cluster, the dlm cluster
 name saved in the VG must also be changed.
-
+.P
 To see the dlm cluster name saved in the VG, use the command:
 .br
 vgs -o+locktype,lockargs <vgname>
-
+.P
 To change the dlm cluster name in the VG when the VG is still used by the
 original cluster:
-
+.P
 .IP \[bu] 2
 Start the VG on the host changing the lock type
 .br
 vgchange --lock-start <vgname>
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Stop the VG on all other hosts:
 .br
 vgchange --lock-stop <vgname>
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Change the VG lock type to none on the host where the VG is started:
 .br
 vgchange --lock-type none <vgname>
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Change the dlm cluster name on the hosts or move the VG to the new
 cluster.  The new dlm cluster must now be running on the host.  Verify the
 new name by:
 .br
 cat /sys/kernel/config/dlm/cluster/cluster_name
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Change the VG lock type back to dlm which sets the new cluster name:
 .br
 vgchange --lock-type dlm <vgname>
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Start the VG on hosts to use it:
 .br
 vgchange --lock-start <vgname>
-
 .P
-
 To change the dlm cluster name in the VG when the dlm cluster name has
 already been changed on the hosts, or the VG has already moved to a
 different cluster:
-
+.
 .IP \[bu] 2
 Ensure the VG is not being used by any hosts.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 The new dlm cluster must be running on the host making the change.
 The current dlm cluster name can be seen by:
 .br
 cat /sys/kernel/config/dlm/cluster/cluster_name
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Change the VG lock type to none:
 .br
 vgchange --lock-type none --lock-opt force <vgname>
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Change the VG lock type back to dlm which sets the new cluster name:
 .br
 vgchange --lock-type dlm <vgname>
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Start the VG on hosts to use it:
 .br
 vgchange --lock-start <vgname>
-
-
-.SS changing a local VG to a shared VG
-
+.
+.SS Changing a local VG to a shared VG
+.
 All LVs must be inactive to change the lock type.
-
+.P
 lvmlockd must be configured and running as described in USAGE.
-
+.
 .IP \[bu] 2
 Change a local VG to a shared VG with the command:
 .br
 vgchange --lock-type sanlock|dlm <vgname>
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Start the VG on hosts to use it:
 .br
 vgchange --lock-start <vgname>
-
-.P
-
-.SS changing a shared VG to a local VG
-
+.
+.SS Changing a shared VG to a local VG
+.
 All LVs must be inactive to change the lock type.
-
+.P
 .IP \[bu] 2
 Start the VG on the host making the change:
 .br
 vgchange --lock-start <vgname>
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Stop the VG on all other hosts:
 .br
 vgchange --lock-stop <vgname>
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Change the VG lock type to none on the host where the VG is started:
 .br
 vgchange --lock-type none <vgname>
-
 .P
-
 If the VG cannot be started with the previous lock type, then the lock
 type can be forcibly changed to none with:
-
+.br
 vgchange --lock-type none --lock-opt force <vgname>
-
+.P
 To change a VG from one lock type to another (i.e. between sanlock and
 dlm), first change it to a local VG, then to the new type.
-
-
-.SS changing a clvm/clustered VG to a shared VG
-
+.
+.SS Changing a clvm/clustered VG to a shared VG
+.
 All LVs must be inactive to change the lock type.
-
+.P
 First change the clvm/clustered VG to a local VG.  Within a running clvm
 cluster, change a clustered VG to a local VG with the command:
-
+.P
 vgchange -cn <vgname>
-
+.P
 If the clvm cluster is no longer running on any nodes, then extra options
 can be used to forcibly make the VG local.  Caution: this is only safe if
 all nodes have stopped using the VG:
-
+.P
 vgchange --lock-type none --lock-opt force <vgname>
-
+.P
 After the VG is local, follow the steps described in "changing a local VG
 to a shared VG".
-
-.SS extending an LV active on multiple hosts
-
+.
+.SS Extending an LV active on multiple hosts
+.
 With lvmlockd and dlm, a special clustering procedure is used to refresh a
 shared LV on remote cluster nodes after it has been extended on one node.
-
+.P
 When an LV holding gfs2 or ocfs2 is active on multiple hosts with a shared
 lock, lvextend is permitted to run with an existing shared LV lock in
 place of the normal exclusive LV lock.
-
+.P
 After lvextend has finished extending the LV, it sends a remote request to
 other nodes running the dlm to run 'lvchange --refresh' on the LV.  This
 uses dlm_controld and corosync features.
-
+.P
 Some special --lockopt values can be used to modify this process.
 "shupdate" permits the lvextend update with an existing shared lock if it
 isn't otherwise permitted.  "norefresh" prevents the remote refresh
 operation.
-
-
-.SS limitations of shared VGs
-
+.
+.SS Limitations of shared VGs
+.
 Things that do not yet work in shared VGs:
 .br
 \[bu]
@@ -831,72 +811,74 @@ pvmove of entire PVs, or under LVs activated with shared locks
 .br
 \[bu]
 vgsplit and vgmerge (convert to a local VG to do this)
-
-
+.
 .SS lvmlockd changes from clvmd
-
+.
 (See above for converting an existing clvm VG to a shared VG.)
-
+.P
 While lvmlockd and clvmd are entirely different systems, LVM command usage
 remains similar.  Differences are more notable when using lvmlockd's
 sanlock option.
-
+.P
 Visible usage differences between shared VGs (using lvmlockd) and
 clvm/clustered VGs (using clvmd):
-
+.
 .IP \[bu] 2
 lvm.conf is configured to use lvmlockd by setting use_lvmlockd=1.
 clvmd used locking_type=3.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 vgcreate --shared creates a shared VG.  vgcreate --clustered y
 created a clvm/clustered VG.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 lvmlockd adds the option of using sanlock for locking, avoiding the
 need for network clustering.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 lvmlockd defaults to the exclusive activation mode whenever the activation
 mode is unspecified, i.e. -ay means -aey, not -asy.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 lvmlockd commands always apply to the local host, and never have an effect
 on a remote host.  (The activation option 'l' is not used.)
-
-.IP \[bu] 2
+.
+.IP \[bu]
 lvmlockd saves the cluster name for a shared VG using dlm.  Only hosts in
 the matching cluster can use the VG.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 lvmlockd requires starting/stopping shared VGs with vgchange --lock-start
 and --lock-stop.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 vgremove of a sanlock VG may fail indicating that all hosts have not
 stopped the VG lockspace.  Stop the VG on all hosts using vgchange
 --lock-stop.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 vgreduce or pvmove of a PV in a sanlock VG will fail if it holds the
 internal "lvmlock" LV that holds the sanlock locks.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 lvmlockd uses lock retries instead of lock queueing, so high lock
 contention may require increasing global/lvmlockd_lock_retries to
 avoid transient lock failures.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 lvmlockd includes VG reporting options lock_type and lock_args, and LV
 reporting option lock_args to view the corresponding metadata fields.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 In the 'vgs' command's sixth VG attr field, "s" for "shared" is displayed
 for shared VGs.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 If lvmlockd fails or is killed while in use, locks it held remain but are
 orphaned in the lock manager.  lvmlockd can be restarted with an option to
 adopt the orphan locks from the previous instance of lvmlockd.
-
-.P
+.
+.SH SEE ALSO
+.
+.BR lvm (8),
+.BR lvmlockctl (8)
diff --git a/man/lvmpolld.8_main b/man/lvmpolld.8_main
index 4fe149094..885c4a2ea 100644
--- a/man/lvmpolld.8_main
+++ b/man/lvmpolld.8_main
@@ -1,10 +1,16 @@
 .TH LVMPOLLD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.
 .SH NAME
+.
 lvmpolld \(em LVM poll daemon
+.
 .SH SYNOPSIS
+.
 .B lvmpolld
+.nh
+.ad l
 .RB [ -l | --log
-.RI { all | wire | debug }]
+.BR all | wire | debug ]
 .RB [ -p | --pidfile
 .IR pidfile_path ]
 .RB [ -s | --socket
@@ -16,75 +22,91 @@ lvmpolld \(em LVM poll daemon
 .RB [ -f | --foreground ]
 .RB [ -h | --help ]
 .RB [ -V | --version ]
-
+.ad b
+.hy
+.P
 .B lvmpolld
 .RB [ --dump ]
+.
 .SH DESCRIPTION
+.
 lvmpolld is polling daemon for LVM. The daemon receives requests for polling
 of already initialised operations originating in LVM2 command line tool.
 The requests for polling originate in the \fBlvconvert\fP, \fBpvmove\fP,
 \fBlvchange\fP or \fBvgchange\fP LVM2 commands.
-
+.P
 The purpose of lvmpolld is to reduce the number of spawned background processes
 per otherwise unique polling operation. There should be only one. It also
 eliminates the possibility of unsolicited termination of background process by
 external factors.
-
+.P
 lvmpolld is used by LVM only if it is enabled in \fBlvm.conf\fP(5) by
 specifying the \fBglobal/use_lvmpolld\fP setting. If this is not defined in the
 LVM configuration explicitly then default setting is used instead (see the
 output of \fBlvmconfig --type default global/use_lvmpolld\fP command).
+.
 .SH OPTIONS
-
+.
 To run the daemon in a test environment both the pidfile_path and the
 socket_path should be changed from the defaults.
+.
 .TP
-.BR -f ", " --foreground
+.BR -f | --foreground
 Don't fork, but run in the foreground.
 .TP
-.BR -h ", " --help
+.BR -h | --help
 Show help information.
+.
 .TP
-.IR \fB-l\fP ", " \fB--log\fP " {" all | wire | debug }
+.BR -l | --log " " all | wire | debug
 Select the type of log messages to generate.
 Messages are logged by syslog.
-Additionally, when -f is given they are also sent to standard error.
-There are two classes of messages: wire and debug. Selecting 'all' supplies both
-and is equivalent to a comma-separated list -l wire,debug.
+Additionally, when \fB-f\fP is given they are also sent to standard error.
+There are two classes of messages: wire and debug. Selecting '\fBall\fP' supplies both
+and is equivalent to a comma-separated list \fB-l wire,debug\fP.
+.
 .TP
-.BR -p ", " --pidfile " " \fIpidfile_path
+.BR -p | --pidfile " " \fIpidfile_path
 Path to the pidfile. This overrides both the built-in default
 (#DEFAULT_PID_DIR#/lvmpolld.pid) and the environment variable
 \fBLVM_LVMPOLLD_PIDFILE\fP.  This file is used to prevent more
 than one instance of the daemon running simultaneously.
+.
 .TP
-.BR -s ", " --socket " " \fIsocket_path
+.BR -s | --socket " " \fIsocket_path
 Path to the socket file. This overrides both the built-in default
 (#DEFAULT_RUN_DIR#/lvmpolld.socket) and the environment variable
 \fBLVM_LVMPOLLD_SOCKET\fP.
+.
 .TP
-.BR -t ", " --timeout " " \fItimeout_value
+.BR -t | --timeout " " \fItimeout_value
 The daemon may shutdown after being idle for the given time (in seconds). When the
 option is omitted or the value given is zero the daemon never shutdowns on idle.
+.
 .TP
-.BR -B ", " --binary " " \fIlvm_binary_path
+.BR -B | --binary " " \fIlvm_binary_path
 Optional path to alternative LVM binary (default: #LVM_PATH#). Use for
 testing purposes only.
+.
 .TP
-.BR -V ", " --version
+.BR -V | --version
 Display the version of lvmpolld daemon.
 .TP
 .B --dump
 Contact the running lvmpolld daemon to obtain the complete state and print it
 out in a raw format.
+.
 .SH ENVIRONMENT VARIABLES
+.
 .TP
 .B LVM_LVMPOLLD_PIDFILE
 Path for the pid file.
+.
 .TP
 .B LVM_LVMPOLLD_SOCKET
 Path for the socket file.
-
+.
 .SH SEE ALSO
+.
 .BR lvm (8),
 .BR lvm.conf (5)
diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index d6943b9df..c13e7789c 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -874,7 +874,7 @@ segs_sort="vg_name,lv_name,seg_start"
 
 .nf
 # pvs
-  PV         VG Fmt  Attr PSize   PFree 
+  PV         VG Fmt  Attr PSize   PFree
   /dev/sda   vg lvm2 a--  100.00m 88.00m
   /dev/sdb   vg lvm2 a--  100.00m 92.00m
 
@@ -889,13 +889,13 @@ segs_sort="vg_name,lv_name,seg_start"
   /dev/sdb   vg lvm2 a--  100.00m 92.00m     2    23
 
 # vgs
-  VG #PV #LV #SN Attr   VSize   VFree  
+  VG #PV #LV #SN Attr   VSize   VFree
   vg   2   2   0 wz--n- 200.00m 180.00m
 
 # lvs
   LV    VG Attr       LSize Pool Origin Move Log Cpy%Sync Convert
-  lvol0 vg -wi-a----- 4.00m                                    
-  lvol1 vg rwi-a-r--- 4.00m                      100.00          
+  lvol0 vg -wi-a----- 4.00m
+  lvol1 vg rwi-a-r--- 4.00m                      100.00
 
 # lvs --segments
   LV    VG Attr       #Str Type   SSize
@@ -917,8 +917,8 @@ lvs_sort="-lv_time"
 
 # lvs
   LV    LSize Origin Pool Cpy%Sync
-  lvol1 4.00m             100.00  
-  lvol0 4.00m  
+  lvol1 4.00m             100.00
+  lvol0 4.00m
 .fi
 
 You can use \fB-o|--options\fP command line option to override current
@@ -931,18 +931,18 @@ configuration directly on command line.
   lvol0 4.00m
 
 # lvs -o+lv_layout
-  LV    LSize Origin Pool Cpy%Sync Layout    
+  LV    LSize Origin Pool Cpy%Sync Layout
   lvol1 4.00m             100.00   raid,raid1
-  lvol0 4.00m                      linear    
+  lvol0 4.00m                      linear
 
 # lvs -o-origin
   LV    LSize Pool Cpy%Sync
-  lvol1 4.00m      100.00  
-  lvol0 4.00m              
+  lvol1 4.00m      100.00
+  lvol0 4.00m
 
 # lvs -o lv_name,lv_size,origin -o+lv_layout -o-origin -O lv_name
-  LV    LSize Layout    
-  lvol0 4.00m linear    
+  LV    LSize Layout
+  lvol0 4.00m linear
   lvol1 4.00m raid,raid1
 .fi
 
@@ -1012,11 +1012,11 @@ compact_output=1
 
 # lvs
   LV    LSize Cpy%Sync
-  lvol1 4.00m 100.00  
-  lvol0 4.00m  
+  lvol1 4.00m 100.00
+  lvol0 4.00m
 
 # lvs vg/lvol0
-  LV    LSize 
+  LV    LSize
   lvol0 4.00m
 .fi
 
@@ -1031,17 +1031,17 @@ compact_output_cols="origin"
 
 # lvs
   LV    LSize Pool Cpy%Sync
-  lvol1 4.00m      100.00  
-  lvol0 4.00m    
+  lvol1 4.00m      100.00
+  lvol0 4.00m
 
 # lvs vg/lvol0
-  LV    LSize Pool 
-  lvol0 4.00m    
+  LV    LSize Pool
+  lvol0 4.00m
 
-# lvs -o#pool_lv        
+# lvs -o#pool_lv
   LV    LSize Origin Cpy%Sync
-  lvol1 4.00m        100.00  
-  lvol0 4.00m                
+  lvol1 4.00m        100.00
+  lvol0 4.00m
 .fi
 
 We will use \fBreport/compact_output=1\fP for subsequent examples.
@@ -1057,8 +1057,8 @@ configuration setting (or \fB--nosuffix\fP command line option) to change this.
 .nf
 # lvs --units b --nosuffix
   LV    LSize   Cpy%Sync
-  lvol1 4194304 100.00  
-  lvol0 4194304    
+  lvol1 4194304 100.00
+  lvol0 4194304
 .fi
 
 If you want to configure whether report headings are displayed or not, use
@@ -1067,8 +1067,8 @@ line option).
 
 .nf
 # lvs --noheadings
-  lvol1 4.00m 100.00  
-  lvol0 4.00m     
+  lvol1 4.00m 100.00
+  lvol0 4.00m
 .fi
 
 In some cases, it may be useful to display report content as key=value pairs
@@ -1124,12 +1124,12 @@ properly.
 # lvs --separator " | "
   LV | LSize | Cpy%Sync
   lvol1 | 4.00m | 100.00
-  lvol0 | 4.00m | 
+  lvol0 | 4.00m |
 
 # lvs --separator " | " --aligned
   LV    | LSize | Cpy%Sync
-  lvol1 | 4.00m | 100.00  
-  lvol0 | 4.00m |         
+  lvol1 | 4.00m | 100.00
+  lvol0 | 4.00m |
 .fi
 
 Let's display one one more field in addition ("lv_tags" in this example)
@@ -1137,8 +1137,8 @@ for the lvs report output.
 
 .nf
 # lvs -o+lv_tags
-  LV    LSize Cpy%Sync LV Tags  
-  lvol1 4.00m 100.00            
+  LV    LSize Cpy%Sync LV Tags
+  lvol1 4.00m 100.00
   lvol0 4.00m          tagA,tagB
 .fi
 
@@ -1152,8 +1152,8 @@ definition.
 list_item_separator=";"
 
 # lvs -o+tags
-  LV    LSize Cpy%Sync LV Tags  
-  lvol1 4.00m 100.00            
+  LV    LSize Cpy%Sync LV Tags
+  lvol1 4.00m 100.00
   lvol0 4.00m          tagA;tagB
 .fi
 
@@ -1169,9 +1169,9 @@ and time is displayed, including timezone.
 time_format="%Y-%m-%d %T %z"
 
 # lvs -o+time
-  LV    LSize Cpy%Sync CTime                     
-  lvol1 4.00m 100.00   2016-08-29 12:53:36 +0200 
-  lvol0 4.00m          2016-08-29 10:15:17 +0200 
+  LV    LSize Cpy%Sync CTime
+  lvol1 4.00m 100.00   2016-08-29 12:53:36 +0200
+  lvol0 4.00m          2016-08-29 10:15:17 +0200
 .fi
 
 We can change time format in similar way as we do when using \fBdate\fP(1)
@@ -1185,9 +1185,9 @@ below, we decided to use %s for number of seconds since Epoch (1970-01-01 UTC).
 time_format="%s"
 
 # lvs
-  LV    Attr       LSize Cpy%Sync LV Tags   CTime                     
-  lvol1 rwi-a-r--- 4.00m 100.00             1472468016                
-  lvol0 -wi-a----- 4.00m          tagA,tagB 1472458517     
+  LV    Attr       LSize Cpy%Sync LV Tags   CTime
+  lvol1 rwi-a-r--- 4.00m 100.00             1472468016
+  lvol0 -wi-a----- 4.00m          tagA,tagB 1472458517
 .fi
 
 The \fBlvs\fP does not display hidden LVs by default - to include these LVs
@@ -1197,12 +1197,12 @@ these hidden LVs are displayed within square brackets.
 .nf
 # lvs -a
   LV               LSize Cpy%Sync
-  lvol1            4.00m 100.00  
-  [lvol1_rimage_0] 4.00m         
-  [lvol1_rmeta_0]  4.00m         
-  [lvol1_rimage_1] 4.00m         
-  [lvol1_rmeta_1]  4.00m         
-  lvol0            4.00m      
+  lvol1            4.00m 100.00
+  [lvol1_rimage_0] 4.00m
+  [lvol1_rmeta_0]  4.00m
+  [lvol1_rimage_1] 4.00m
+  [lvol1_rmeta_1]  4.00m
+  lvol0            4.00m
 .fi
 
 You can configure LVM to display the square brackets for hidden LVs or not with
@@ -1214,12 +1214,12 @@ mark_hidden_devices=0
 
 # lvs -a
   LV             LSize Cpy%Sync
-  lvol1          4.00m 100.00  
-  lvol1_rimage_0 4.00m         
-  lvol1_rmeta_0  4.00m         
-  lvol1_rimage_1 4.00m         
-  lvol1_rmeta_1  4.00m         
-  lvol0          4.00m     
+  lvol1          4.00m 100.00
+  lvol1_rimage_0 4.00m
+  lvol1_rmeta_0  4.00m
+  lvol1_rimage_1 4.00m
+  lvol1_rmeta_1  4.00m
+  lvol0          4.00m
 .fi
 
 It's not recommended to use LV marks for hidden devices to decide whether the
@@ -1229,13 +1229,13 @@ used by LVM only and they should not be accessed directly by end users.
 
 .nf
 # lvs -a -o+lv_role
-  LV             LSize Cpy%Sync Role                 
-  lvol1          4.00m 100.00   public               
-  lvol1_rimage_0 4.00m          private,raid,image   
+  LV             LSize Cpy%Sync Role
+  lvol1          4.00m 100.00   public
+  lvol1_rimage_0 4.00m          private,raid,image
   lvol1_rmeta_0  4.00m          private,raid,metadata
-  lvol1_rimage_1 4.00m          private,raid,image   
+  lvol1_rimage_1 4.00m          private,raid,image
   lvol1_rmeta_1  4.00m          private,raid,metadata
-  lvol0          4.00m          public     
+  lvol0          4.00m          public
 .fi
 
 Some of the reporting fields that LVM reports are of binary nature. For such
@@ -1245,7 +1245,7 @@ undefined).
 
 .nf
 # lvs -o+lv_active_locally
-  LV    LSize Cpy%Sync ActLocal      
+  LV    LSize Cpy%Sync ActLocal
   lvol1 4.00m 100.00   active locally
   lvol0 4.00m          active locally
 .fi
@@ -1258,7 +1258,7 @@ We can change the way how these binary values are displayed with
 binary_values_as_numeric=1
 
 # lvs -o+lv_active_locally
-  LV    LSize Cpy%Sync ActLocal  
+  LV    LSize Cpy%Sync ActLocal
   lvol1 4.00m 100.00            1
   lvol0 4.00m                   1
 .fi
@@ -1342,11 +1342,11 @@ addition to lvol0 and lvol1 we used in our previous examples.
 
 .nf
 # lvs -o name,size,origin,snap_percent,tags,time
-  LV    LSize Origin Snap%  LV Tags        CTime                     
-  lvol4 4.00m lvol2  24.61                 2016-09-09 16:57:44 +0200 
-  lvol3 4.00m lvol2  5.08                  2016-09-09 16:56:48 +0200 
-  lvol2 8.00m               tagA,tagC,tagD 2016-09-09 16:55:12 +0200 
-  lvol1 4.00m                              2016-08-29 12:53:36 +0200 
+  LV    LSize Origin Snap%  LV Tags        CTime
+  lvol4 4.00m lvol2  24.61                 2016-09-09 16:57:44 +0200
+  lvol3 4.00m lvol2  5.08                  2016-09-09 16:56:48 +0200
+  lvol2 8.00m               tagA,tagC,tagD 2016-09-09 16:55:12 +0200
+  lvol1 4.00m                              2016-08-29 12:53:36 +0200
   lvol0 4.00m               tagA,tagB      2016-08-29 10:15:17 +0200
 .fi
 
@@ -1359,29 +1359,29 @@ together.
 
 .nf
 # lvs -o name,size,snap_percent -S 'size=8m'
-  LV    LSize 
+  LV    LSize
   lvol2 8.00m
 
 # lvs -o name,size,snap_percent -S 'size=8'
-  LV    LSize 
+  LV    LSize
   lvol2 8.00m
 
 # lvs -o name,size,snap_percent -S 'size < 5000k'
-  LV    LSize Snap% 
-  lvol4 4.00m 24.61 
-  lvol3 4.00m 5.08  
-  lvol1 4.00m       
-  lvol0 4.00m 
+  LV    LSize Snap%
+  lvol4 4.00m 24.61
+  lvol3 4.00m 5.08
+  lvol1 4.00m
+  lvol0 4.00m
 
 # lvs -o name,size,snap_percent -S 'size < 5000k && snap_percent > 20'
-  LV    LSize Snap% 
-  lvol4 4.00m 24.61 
+  LV    LSize Snap%
+  lvol4 4.00m 24.61
 
 # lvs -o name,size,snap_percent \\
     -S '(size < 5000k && snap_percent > 20%) || name=lvol2'
-  LV    LSize Snap% 
-  lvol4 4.00m 24.61 
-  lvol2 8.00m       
+  LV    LSize Snap%
+  lvol4 4.00m 24.61
+  lvol2 8.00m
 .fi
 
 You can also use selection together with processing-oriented commands.
@@ -1409,14 +1409,14 @@ that matches. If the subset has only one item, we can leave out { }.
 
 .nf
 # lvs -o name,tags -S 'tags={tagA}'
-  LV    LV Tags       
+  LV    LV Tags
   lvol2 tagA,tagC,tagD
-  lvol0 tagA,tagB   
-  
+  lvol0 tagA,tagB
+
 # lvs -o name,tags -S 'tags=tagA'
-  LV    LV Tags       
+  LV    LV Tags
   lvol2 tagA,tagC,tagD
-  lvol0 tagA,tagB   
+  lvol0 tagA,tagB
 .fi
 
 Depending on whether we use "&&" (or ",") or "||" ( or "#") as delimiter
@@ -1425,23 +1425,23 @@ we either match subset ("&&" or ",") or even intersection ("||" or "#").
 
 .nf
 # lvs -o name,tags -S 'tags={tagA,tagC,tagD}'
-  LV    LV Tags       
+  LV    LV Tags
   lvol2 tagA,tagC,tagD
 
 # lvs -o name,tags -S 'tags={tagA || tagC || tagD}'
-  LV    LV Tags       
+  LV    LV Tags
   lvol2 tagA,tagC,tagD
-  lvol0 tagA,tagB     
+  lvol0 tagA,tagB
 .fi
 
 To match the complete set, use [ ] with "&&" (or ",") as delimiter for items.
 Also note that the order in which we define items in the set is not relevant.
 
 .nf
-# lvs -o name,tags -S 'tags=[tagA]'                
+# lvs -o name,tags -S 'tags=[tagA]'
 
 # lvs -o name,tags -S 'tags=[tagB,tagA]'
-  LV    LV Tags  
+  LV    LV Tags
   lvol0 tagA,tagB
 .fi
 
@@ -1449,9 +1449,9 @@ If you use [ ] with "||" (or "#"), this is exactly the same as using { }.
 
 .nf
 # lvs -o name,tags -S 'tags=[tagA || tagC || tagD]'
-  LV    LV Tags       
+  LV    LV Tags
   lvol2 tagA,tagC,tagD
-  lvol0 tagA,tagB  
+  lvol0 tagA,tagB
 .fi
 
 To match a set with no items, use "" to denote this (note that we have
@@ -1460,15 +1460,15 @@ the example below because it's blank and so it gets compacted).
 
 .nf
 # lvs -o name,tags -S 'tags=""'
-  LV    
+  LV
   lvol4
   lvol3
   lvol1
 
 # lvs -o name,tags -S 'tags!=""'
-  LV    LV Tags       
+  LV    LV Tags
   lvol2 tagA,tagC,tagD
-  lvol0 tagA,tagB  
+  lvol0 tagA,tagB
 .fi
 
 When doing selection based on time fields, we can use either standard,
@@ -1477,40 +1477,40 @@ are using standard forms.
 
 .nf
 # lvs -o name,time
-  LV    CTime                     
-  lvol4 2016-09-09 16:57:44 +0200 
-  lvol3 2016-09-09 16:56:48 +0200 
-  lvol2 2016-09-09 16:55:12 +0200 
-  lvol1 2016-08-29 12:53:36 +0200 
-  lvol0 2016-08-29 10:15:17 +0200 
+  LV    CTime
+  lvol4 2016-09-09 16:57:44 +0200
+  lvol3 2016-09-09 16:56:48 +0200
+  lvol2 2016-09-09 16:55:12 +0200
+  lvol1 2016-08-29 12:53:36 +0200
+  lvol0 2016-08-29 10:15:17 +0200
 
 # lvs -o name,time -S 'time since "2016-09-01"'
-  LV    CTime                     
-  lvol4 2016-09-09 16:57:44 +0200 
-  lvol3 2016-09-09 16:56:48 +0200 
-  lvol2 2016-09-09 16:55:12 +0200 
+  LV    CTime
+  lvol4 2016-09-09 16:57:44 +0200
+  lvol3 2016-09-09 16:56:48 +0200
+  lvol2 2016-09-09 16:55:12 +0200
 
 # lvs -o name,time -S 'time since "2016-09-09 16:56"'
-  LV    CTime                     
-  lvol4 2016-09-09 16:57:44 +0200 
-  lvol3 2016-09-09 16:56:48 +0200 
+  LV    CTime
+  lvol4 2016-09-09 16:57:44 +0200
+  lvol3 2016-09-09 16:56:48 +0200
 
 # lvs -o name,time -S 'time since "2016-09-09 16:57:30"'
-  LV    CTime                     
-  lvol4 2016-09-09 16:57:44 +0200 
+  LV    CTime
+  lvol4 2016-09-09 16:57:44 +0200
 
-# lvs -o name,time \\ 
+# lvs -o name,time \\
     -S 'time since "2016-08-29" && time until "2016-09-09 16:55:12"'
-  LV    CTime                     
-  lvol2 2016-09-09 16:55:12 +0200 
-  lvol1 2016-08-29 12:53:36 +0200 
-  lvol0 2016-08-29 10:15:17 +0200 
+  LV    CTime
+  lvol2 2016-09-09 16:55:12 +0200
+  lvol1 2016-08-29 12:53:36 +0200
+  lvol0 2016-08-29 10:15:17 +0200
 
 # lvs -o name,time \\
     -S 'time since "2016-08-29" && time before "2016-09-09 16:55:12"'
-  LV    CTime                     
-  lvol1 2016-08-29 12:53:36 +0200 
-  lvol0 2016-08-29 10:15:17 +0200 
+  LV    CTime
+  lvol1 2016-08-29 12:53:36 +0200
+  lvol0 2016-08-29 10:15:17 +0200
 .fi
 
 Time operators have synonyms: ">=" for since, "<=" for until,
@@ -1519,75 +1519,75 @@ Time operators have synonyms: ">=" for since, "<=" for until,
 .nf
 # lvs -o name,time \\
     -S 'time >= "2016-08-29" && time <= "2016-09-09 16:55:30"'
-  LV    CTime                     
-  lvol2 2016-09-09 16:55:12 +0200 
-  lvol1 2016-08-29 12:53:36 +0200 
-  lvol0 2016-08-29 10:15:17 +0200 
+  LV    CTime
+  lvol2 2016-09-09 16:55:12 +0200
+  lvol1 2016-08-29 12:53:36 +0200
+  lvol0 2016-08-29 10:15:17 +0200
 
 # lvs -o name,time \\
     -S 'time since "2016-08-29" && time < "2016-09-09 16:55:12"'
-  LV    CTime                     
-  lvol1 2016-08-29 12:53:36 +0200 
-  lvol0 2016-08-29 10:15:17 +0200 
+  LV    CTime
+  lvol1 2016-08-29 12:53:36 +0200
+  lvol0 2016-08-29 10:15:17 +0200
 .fi
 
 Example below demonstrates using absolute time expression.
 
 .nf
 # lvs -o name,time --config report/time_format="%s"
-  LV    CTime                     
-  lvol4 1473433064                
-  lvol3 1473433008                
-  lvol2 1473432912                
-  lvol1 1472468016                
-  lvol0 1472458517  
+  LV    CTime
+  lvol4 1473433064
+  lvol3 1473433008
+  lvol2 1473432912
+  lvol1 1472468016
+  lvol0 1472458517
 
 # lvs -o name,time -S 'time since @1473433008'
-  LV    CTime                     
-  lvol4 2016-09-09 16:57:44 +0200 
-  lvol3 2016-09-09 16:56:48 +0200 
+  LV    CTime
+  lvol4 2016-09-09 16:57:44 +0200
+  lvol3 2016-09-09 16:56:48 +0200
 .fi
 
 Examples below demonstrates using freeform time expressions.
 
 .nf
 # lvs -o name,time -S 'time since "2 weeks ago"'
-  LV    CTime                     
-  lvol4 2016-09-09 16:57:44 +0200 
-  lvol3 2016-09-09 16:56:48 +0200 
-  lvol2 2016-09-09 16:55:12 +0200 
-  lvol1 2016-08-29 12:53:36 +0200 
-  lvol0 2016-08-29 10:15:17 +0200 
+  LV    CTime
+  lvol4 2016-09-09 16:57:44 +0200
+  lvol3 2016-09-09 16:56:48 +0200
+  lvol2 2016-09-09 16:55:12 +0200
+  lvol1 2016-08-29 12:53:36 +0200
+  lvol0 2016-08-29 10:15:17 +0200
 
 # lvs -o name,time -S 'time since "1 week ago"'
-  LV    CTime                     
-  lvol4 2016-09-09 16:57:44 +0200 
-  lvol3 2016-09-09 16:56:48 +0200 
-  lvol2 2016-09-09 16:55:12 +0200 
+  LV    CTime
+  lvol4 2016-09-09 16:57:44 +0200
+  lvol3 2016-09-09 16:56:48 +0200
+  lvol2 2016-09-09 16:55:12 +0200
 
 # lvs -o name,time -S 'time since "2 weeks ago"'
-  LV    CTime                     
-  lvol1 2016-08-29 12:53:36 +0200 
-  lvol0 2016-08-29 10:15:17 +0200 
+  LV    CTime
+  lvol1 2016-08-29 12:53:36 +0200
+  lvol0 2016-08-29 10:15:17 +0200
 
 # lvs -o name,time -S 'time before "1 week ago"'
-  LV    CTime                     
-  lvol1 2016-08-29 12:53:36 +0200 
-  lvol0 2016-08-29 10:15:17 +0200 
+  LV    CTime
+  lvol1 2016-08-29 12:53:36 +0200
+  lvol0 2016-08-29 10:15:17 +0200
 
 # lvs -o name,time -S 'time since "68 hours ago"'
-  LV    CTime                     
-  lvol4 2016-09-09 16:57:44 +0200 
-  lvol3 2016-09-09 16:56:48 +0200 
-  lvol2 2016-09-09 16:55:12 +0200 
+  LV    CTime
+  lvol4 2016-09-09 16:57:44 +0200
+  lvol3 2016-09-09 16:56:48 +0200
+  lvol2 2016-09-09 16:55:12 +0200
 
 # lvs -o name,time -S 'time since "1 year 3 months ago"'
-  LV    CTime                     
-  lvol4 2016-09-09 16:57:44 +0200 
-  lvol3 2016-09-09 16:56:48 +0200 
-  lvol2 2016-09-09 16:55:12 +0200 
-  lvol1 2016-08-29 12:53:36 +0200 
-  lvol0 2016-08-29 10:15:17 +0200 
+  LV    CTime
+  lvol4 2016-09-09 16:57:44 +0200
+  lvol3 2016-09-09 16:56:48 +0200
+  lvol2 2016-09-09 16:55:12 +0200
+  lvol1 2016-08-29 12:53:36 +0200
+  lvol0 2016-08-29 10:15:17 +0200
 .fi
 
 .SS Command log reporting
@@ -1615,9 +1615,9 @@ command_log_selection="!(log_type=status && message=success)"
   Logical Volume
   ==============
   LV    LSize Cpy%Sync
-  lvol1 4.00m 100.00  
-  lvol0 4.00m         
-  
+  lvol1 4.00m 100.00
+  lvol0 4.00m
+
   Command Log
   ===========
   Seq LogType Context ObjType ObjName ObjGrp  Msg     Errno RetCode
@@ -1638,9 +1638,9 @@ command_log_selection="all"
   Logical Volume
   ==============
   LV    LSize Cpy%Sync
-  lvol1 4.00m 100.00  
-  lvol0 4.00m         
-  
+  lvol1 4.00m 100.00
+  lvol0 4.00m
+
   Command Log
   ===========
   Seq LogType Context    ObjType ObjName ObjGrp  Msg     Errno RetCode
@@ -1670,7 +1670,7 @@ To configure the log report directly on command line, we need to use
   LV    LSize
   lvol1 4.00m
   lvol0 4.00m
-  
+
   Command Log
   ===========
   ObjType ObjName Msg     RetCode
@@ -1763,9 +1763,9 @@ lvm> lvs
   Logical Volume
   ==============
   LV    LSize Cpy%Sync
-  lvol1 4.00m 100.00  
-  lvol0 4.00m         
-  
+  lvol1 4.00m 100.00
+  lvol0 4.00m
+
   Command Log
   ===========
   Seq LogType Context    ObjType ObjName ObjGrp  Msg     Errno RetCode
@@ -1774,7 +1774,7 @@ lvm> lvs
     3 status  processing vg      vg              success     0       1
     4 status  shell      cmd     lvs             success     0       1
 
-lvm> lastlog    
+lvm> lastlog
   Command Log
   ===========
   Seq LogType Context    ObjType ObjName ObjGrp  Msg     Errno RetCode
diff --git a/man/lvmsadc.8_main b/man/lvmsadc.8_main
index c2781b8cb..039ff7bca 100644
--- a/man/lvmsadc.8_main
+++ b/man/lvmsadc.8_main
@@ -1,12 +1,20 @@
 .TH "LVMSADC" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-.SH "NAME"
+.
+.SH NAME
+.
 lvmsadc \(em LVM system activity data collector
-.SH "SYNOPSIS"
+.
+.SH SYNOPSIS
+.
 .B lvmsadc
-.SH "DESCRIPTION"
+.
+.SH DESCRIPTION
+.
 lvmsadc is not supported under LVM2. The device-mapper statistics
 facility provides similar performance metrics using the \fBdmstats(8)\fP
 command.
-.SH "SEE ALSO"
-.BR dmstats (8)
+.
+.SH SEE ALSO
+.
+.BR dmstats (8),
 .BR lvm (8)
diff --git a/man/lvmsar.8_main b/man/lvmsar.8_main
index 0bbcbf37d..4c3f14bf7 100644
--- a/man/lvmsar.8_main
+++ b/man/lvmsar.8_main
@@ -1,12 +1,20 @@
 .TH "LVMSAR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-.SH "NAME"
+.
+.SH NAME
+.
 lvmsar \(em LVM system activity reporter
-.SH "SYNOPSIS"
+.
+.SH SYNOPSIS
+.
 .B lvmsar
-.SH "DESCRIPTION"
+.
+.SH DESCRIPTION
+.
 lvmsar is not supported under LVM2. The device-mapper statistics
 facility provides similar performance metrics using the \fBdmstats(8)\fP
 command.
-.SH "SEE ALSO"
-.BR dmstats (8)
+.
+.SH SEE ALSO
+.
+.BR dmstats (8),
 .BR lvm (8)
diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index 7d6e96ed6..eac4f7bc1 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -1,38 +1,39 @@
 .TH "LVMSYSTEMID" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-
+.
 .SH NAME
+.
 lvmsystemid \(em LVM system ID
-
+.
 .SH DESCRIPTION
-
+.
 The \fBlvm\fP(8) system ID restricts Volume Group (VG) access to one host.
 This is useful when a VG is placed on shared storage devices, or when
 local devices are visible to both host and guest operating systems.  In
 cases like these, a VG can be visible to multiple hosts at once, and some
 mechanism is needed to protect it from being used by more than one host at
 a time.
-
+.P
 A VG's system ID identifies one host as the VG owner.  The host with a
 matching system ID can use the VG and its LVs, while LVM on other hosts
 will ignore it.  This protects the VG from being accidentally used from
 other hosts.
-
+.P
 The system ID is a string that uniquely identifies a host.  It can be
 configured as a custom value, or it can be assigned automatically by LVM
 using some unique identifier already available on the host, e.g.
 machine-id or uname.
-
+.P
 When a new VG is created, the system ID of the local host is recorded in
 the VG metadata.  The creating host then owns the new VG, and LVM on other
 hosts will ignore it.  When an existing, exported VG is imported
 (vgimport), the system ID of the local host is saved in the VG metadata,
 and the importing host owns the VG.
-
+.P
 A VG without a system ID can be used by LVM on any host where the VG's
 devices are visible.  When system IDs are not used, device filters should
 be configured on all hosts to exclude the VG's devices from all but one
 host.
-
+.P
 A
 .B foreign VG
 is a VG seen by a host with an unmatching system ID, i.e. the system ID
@@ -40,195 +41,194 @@ in the VG metadata does not match the system ID configured on the host.
 If the host has no system ID, and the VG does, the VG is foreign and LVM
 will ignore it.  If the VG has no system ID, access is unrestricted, and
 LVM can access it from any host, whether the host has a system ID or not.
-
+.P
 Changes to a host's system ID and a VG's system ID can be made in limited
 circumstances (see vgexport and vgimport).  Improper changes can result in
 a host losing access to its VG, or a VG being accidentally damaged by
 access from an unintended host.  Even limited changes to the VG system ID
 may not be perfectly reflected across hosts.  A more coherent view of
 shared storage requires an inter-host locking system to coordinate access.
-
+.P
 Valid system ID characters are the same as valid VG name characters.  If a
 system ID contains invalid characters, those characters are omitted and
 remaining characters are used.  If a system ID is longer than the maximum
 name length, the characters up to the maximum length are used.  The
 maximum length of a system ID is 128 characters.
-
+.P
 Print the system ID of a VG to check if it is set:
-
+.P
 .B vgs -o systemid
 .I VG
-
+.P
 Print the system ID of the local host to check if it is configured:
-
+.P
 .B lvm systemid
-
+.
 .SS Limitations and warnings
-
+.
 To benefit fully from system ID, all hosts should have a system ID
 configured, and all VGs should have a system ID set.  Without any method
 to restrict access, e.g. system ID or device filters, a VG that is visible
 to multiple hosts can be accidentally damaged or destroyed.
-
+.
 .IP \[bu] 2
 A VG without a system ID can be used without restriction from any host
 where it is visible, even from hosts that have a system ID.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Many VGs will not have a system ID set because LVM has not enabled it by
 default, and even when enabled, many VGs were created before the feature
 was added to LVM or enabled.  A system ID can be assigned to these VGs by
 using vgchange --systemid (see below).
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Two hosts should not be assigned the same system ID.  Doing so defeats
 the purpose of distinguishing different hosts with this value.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Orphan PVs (or unused devices) on shared storage are unprotected by the
 system ID feature.  Commands that use these PVs, such as vgcreate or
 vgextend, are not prevented from performing conflicting operations and
 corrupting the PVs.  See the
 .B orphans
 section for more information.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 The system ID does not protect devices in a VG from programs other than LVM.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 A host using an old LVM version (without the system ID feature) will not
 recognize a system ID set in VGs.  The old LVM can read a VG with a
 system ID, but is prevented from writing to the VG (or its LVs).
 The system ID feature changes the write mode of a VG, making it appear
 read-only to previous versions of LVM.
-
+.sp
 This also means that if a host downgrades to the old LVM version, it would
 lose access to any VGs it had created with a system ID.  To avoid this,
 the system ID should be removed from local VGs before downgrading LVM to a
 version without the system ID feature.
-
-
+.
 .SS Types of VG access
-
+.
 A local VG is meant to be used by a single host.
-
+.P
 A shared or clustered VG is meant to be used by multiple hosts.
-
+.P
 These can be further distinguished as:
-
+.
+.TP
 .B Unrestricted:
 A local VG that has no system ID.  This VG type is unprotected and
 accessible to any host.
-
+.
+.TP
 .B Owned:
 A local VG that has a system ID set, as viewed from the host with a
 matching system ID (the owner).  This VG type is accessible to the host.
-
+.
+.TP
 .B Foreign:
 A local VG that has a system ID set, as viewed from any host with an
 unmatching system ID (or no system ID).  It is owned by another host.
 This VG type is not accessible to the host.
-
+.
+.TP
 .B Exported:
 A local VG that has been exported with vgexport and has no system ID.
 This VG type can only be accessed by vgimport which will change it to
 owned.
-
+.
+.TP
 .B Shared:
 A shared or "lockd" VG has the lock_type set and has no system ID.
 A shared VG is meant to be used on shared storage from multiple hosts,
 and is only accessible to hosts using lvmlockd. Applicable only if LVM
 is compiled with lvmlockd support.
-
+.
+.TP
 .B Clustered:
 A clustered or "clvm" VG has the clustered flag set and has no system ID.
 A clustered VG is meant to be used on shared storage from multiple hosts,
 and is only accessible to hosts using clvmd. Applicable only if LVM
 is compiled with clvm support.
-
-
-.SS Host system ID configuration 
-
+.
+.SS Host system ID configuration
+.
 A host's own system ID can be defined in a number of ways.  lvm.conf
 global/system_id_source defines the method LVM will use to find the local
 system ID:
-
+.
 .TP
 .B none
 .br
-
 LVM will not use a system ID.  LVM is allowed to access VGs without a
 system ID, and will create new VGs without a system ID.  An undefined
 system_id_source is equivalent to none.
-
+.sp
 .I lvm.conf
 .nf
 global {
     system_id_source = "none"
 }
 .fi
-
+.
 .TP
 .B machineid
 .br
-
 The content of /etc/machine-id is used as the system ID if available.
 See
 .BR machine-id (5)
 and
 .BR systemd-machine-id-setup (1)
 to check if machine-id is available on the host.
-
+.sp
 .I lvm.conf
 .nf
 global {
     system_id_source = "machineid"
 }
 .fi
-
+.
 .TP
 .B uname
 .br
-
 The string utsname.nodename from
 .BR uname (2)
 is used as the system ID.  A uname beginning with "localhost"
 is ignored and equivalent to none.
-
+.sp
 .I lvm.conf
 .nf
 global {
     system_id_source = "uname"
 }
 .fi
-
+.
 .TP
 .B lvmlocal
 .br
-
 The system ID is defined in lvmlocal.conf local/system_id.
-
+.sp
 .I lvm.conf
 .nf
 global {
     system_id_source = "lvmlocal"
 }
 .fi
-
+.sp
 .I lvmlocal.conf
 .nf
 local {
     system_id = "example_name"
 }
 .fi
-
+.
 .TP
 .B file
 .br
-
 The system ID is defined in a file specified by lvm.conf
 global/system_id_file.
-
+.sp
 .I lvm.conf
 .nf
 global {
@@ -236,132 +236,125 @@ global {
     system_id_file = "/path/to/file"
 }
 .fi
-
 .LP
-
 Changing system_id_source will likely cause the system ID of the host to
 change, which will prevent the host from using VGs that it previously used
 (see extra_system_ids below to handle this.)
-
+.P
 If a system_id_source other than none fails to produce a system ID value,
 it is the equivalent of having none.  The host will be allowed to access
 VGs with no system ID, but will not be allowed to access VGs with a system
 ID set.
-
-
+.
 .SS Overriding system ID
-
+.
 In some cases, it may be necessary for a host to access VGs with different
 system IDs, e.g. if a host's system ID changes, and it wants to use VGs
 that it created with its old system ID.  To allow a host to access VGs
 with other system IDs, those other system IDs can be listed in
 lvmlocal.conf local/extra_system_ids.
-
+.P
 .I lvmlocal.conf
 .nf
 local {
     extra_system_ids = [ "my_other_name" ]
 }
 .fi
-
+.P
 A safer option may be configuring the extra values as needed on the
 command line as:
 .br
 \fB--config 'local/extra_system_ids=["\fP\fIid\fP\fB"]'\fP
-
-
+.
 .SS vgcreate
-
+.
 In vgcreate, the host running the command assigns its own system ID to the
 new VG.  To override this and set another system ID:
-
+.P
 .B vgcreate --systemid
 .I SystemID VG PVs
-
+.P
 Overriding the host's system ID makes it possible for a host to create a
 VG that it may not be able to use.  Another host with a system ID matching
 the one specified may not recognize the new VG without manually rescanning
 devices.
-
+.P
 If the --systemid argument is an empty string (""), the VG is created with
 no system ID, making it accessible to other hosts (see warnings above.)
-
-
+.
 .SS report/display
-
+.
 The system ID of a VG is displayed with the "systemid" reporting option.
-
+.P
 Report/display commands ignore foreign VGs by default.  To report foreign
 VGs, the --foreign option can be used.  This causes the VGs to be read
 from disk.
-
+.P
 .B vgs --foreign -o +systemid
-
+.P
 When a host with no system ID sees foreign VGs, it warns about them as
 they are skipped.  The host should be assigned a system ID, after which
 standard reporting commands will silently ignore foreign VGs.
-
-
+.
 .SS vgexport/vgimport
-
+.
 vgexport clears the VG system ID when exporting the VG.
-
+.P
 vgimport sets the VG system ID to the system ID of the host doing the
 import.
-
-
+.
 .SS vgchange
-
+.
 A host can change the system ID of its own VGs, but the command requires
 confirmation because the host may lose access to the VG being changed:
-
+.P
 .B vgchange --systemid
 .I SystemID VG
-
+.P
 The system ID can be removed from a VG by specifying an empty string ("")
 as the new system ID.  This makes the VG accessible to other hosts (see
 warnings above.)
-
+.P
 A host cannot directly change the system ID of a foreign VG.
-
+.P
 To move a VG from one host to another, vgexport and vgimport should be
 used.
-
+.P
 To forcibly gain ownership of a foreign VG, a host can temporarily add the
 foreign system ID to its extra_system_ids list, and change the system ID
 of the foreign VG to its own.  See Overriding system ID above.
-
-
+.
 .SS shared VGs
-
+.
 A shared VG has no system ID set, allowing multiple hosts to use it
 via lvmlockd.  Changing a VG to shared will clear the existing
 system ID.  Applicable only if LVM is compiled with lvmlockd support.
-
-
+.
 .SS clustered VGs
-
+.
 A clustered/clvm VG has no system ID set, allowing multiple hosts to use
 it via clvmd.  Changing a VG to clustered will clear the existing system
 ID.  Changing a VG to not clustered will set the system ID to the host
 running the vgchange command.
-
-
+.
 .SS creation_host
-
+.
 In vgcreate, the VG metadata field creation_host is set by default to the
 host's uname.  The creation_host cannot be changed, and is not used to
 control access.  When system_id_source is "uname", the system_id and
 creation_host fields will be the same.
-
+.
 .SS orphans
-
+.
 Orphan PVs are unused devices; they are not currently used in any VG.
 Because of this, they are not protected by a system ID, and any host can
 use them.  Coordination of changes to orphan PVs is beyond the scope of
 system ID.  The same is true of any block device that is not a PV.
-
+.
 .SH SEE ALSO
+.
+.nh
+.ad l
 .BR vgcreate (8),
 .BR vgchange (8),
 .BR vgimport (8),
@@ -371,4 +364,3 @@ system ID.  The same is true of any block device that is not a PV.
 .BR lvm.conf (5),
 .BR machine-id (5),
 .BR uname (2)
-
diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index 9568eca41..0a9d4698f 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -1,33 +1,34 @@
 .TH "LVMTHIN" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-
+.
 .SH NAME
+.
 lvmthin \(em LVM thin provisioning
-
+.
 .SH DESCRIPTION
-
+.
 Blocks in a standard \fBlvm\fP(8) Logical Volume (LV) are allocated when
 the LV is created, but blocks in a thin provisioned LV are allocated as
 they are written.  Because of this, a thin provisioned LV is given a
 virtual size, and can then be much larger than physically available
 storage.  The amount of physical storage provided for thin provisioned LVs
 can be increased later as the need arises.
-
+.P
 Blocks in a standard LV are allocated (during creation) from the Volume
 Group (VG), but blocks in a thin LV are allocated (during use) from a
 special "thin pool LV".  The thin pool LV contains blocks of physical
 storage, and blocks in thin LVs just reference blocks in the thin pool LV.
-
+.P
 A thin pool LV must be created before thin LVs can be created within it.
 A thin pool LV is created by combining two standard LVs: a large data LV
 that will hold blocks for thin LVs, and a metadata LV that will hold
 metadata.  The metadata tracks which data blocks belong to each thin LV.
-
+.P
 Snapshots of thin LVs are efficient because the data blocks common to a
 thin LV and any of its snapshots are shared.  Snapshots may be taken of
 thin LVs or of other thin snapshots.  Blocks common to recursive snapshots
 are also shared in the thin pool.  There is no limit to or degradation
 from sequences of snapshots.
-
+.P
 As thin LVs or snapshot LVs are written to, they consume data blocks in
 the thin pool.  As free data blocks in the pool decrease, more free blocks
 may need to be supplied.  This is done by extending the thin pool data LV
@@ -36,14 +37,13 @@ snapshots from the thin pool can also free blocks in the thin pool.
 However, removing LVs is not always an effective way of freeing space in a
 thin pool because the amount is limited to the number of blocks not shared
 with other LVs in the pool.
-
+.P
 Incremental block allocation from thin pools can cause thin LVs to become
 fragmented.  Standard LVs generally avoid this problem by allocating all
 the blocks at once during creation.
-
-
-.SH Thin Terms
-
+.
+.SH THIN TERMS
+.
 .TP
 ThinDataLV
 .br
@@ -52,7 +52,7 @@ thin data LV
 large LV created in a VG
 .br
 used by thin pool to store ThinLV blocks
-
+.
 .TP
 ThinMetaLV
 .br
@@ -61,7 +61,7 @@ thin metadata LV
 small LV created in a VG
 .br
 used by thin pool to track data block usage
-
+.
 .TP
 ThinPoolLV
 .br
@@ -70,7 +70,7 @@ thin pool LV
 combination of ThinDataLV and ThinMetaLV
 .br
 contains ThinLVs and SnapLVs
-
+.
 .TP
 ThinLV
 .br
@@ -79,7 +79,7 @@ thin LV
 created from ThinPoolLV
 .br
 appears blank after creation
-
+.
 .TP
 SnapLV
 .br
@@ -88,65 +88,64 @@ snapshot LV
 created from ThinPoolLV
 .br
 appears as a snapshot of another LV after creation
-
-
-
-.SH Thin Usage
-
+.
+.SH THIN USAGE
+.
 The primary method for using lvm thin provisioning:
-
-.SS 1. create ThinDataLV
-
+.nr step 1 1
+.
+.SS \n[step]. Create ThinDataLV
+.
 Create an LV that will hold thin pool data.
-
+.P
 .B lvcreate -n ThinDataLV -L LargeSize VG
-
+.P
 .I Example
 .br
 # lvcreate -n pool0 -L 10G vg
-
-.SS 2. create ThinMetaLV
-
+.
+.SS \n+[step]. Create ThinMetaLV
+.
 Create an LV that will hold thin pool metadata.
-
+.P
 .B lvcreate -n ThinMetaLV -L SmallSize VG
-
+.P
 .I Example
 .br
 # lvcreate -n pool0meta -L 1G vg
-
+.P
 # lvs
   LV        VG Attr       LSize
   pool0     vg -wi-a----- 10.00g
   pool0meta vg -wi-a----- 1.00g
-
-.SS 3. create ThinPoolLV
-
+.
+.SS \n+[step]. Create ThinPoolLV
+.
 .nf
 Combine the data and metadata LVs into a thin pool LV.
 ThinDataLV is renamed to hidden ThinPoolLV_tdata.
 ThinMetaLV is renamed to hidden ThinPoolLV_tmeta.
 The new ThinPoolLV takes the previous name of ThinDataLV.
 .fi
-
+.P
 .B lvconvert --type thin-pool --poolmetadata VG/ThinMetaLV VG/ThinDataLV
-
+.P
 .I Example
 .br
 # lvconvert --type thin-pool --poolmetadata vg/pool0meta vg/pool0
-
+.P
 # lvs vg/pool0
   LV    VG Attr       LSize  Pool Origin Data% Meta%
   pool0 vg twi-a-tz-- 10.00g      0.00   0.00
-
+.P
 # lvs -a
   LV            VG Attr       LSize
   pool0         vg twi-a-tz-- 10.00g
   [pool0_tdata] vg Twi-ao---- 10.00g
   [pool0_tmeta] vg ewi-ao---- 1.00g
-
-.SS 4. create ThinLV
-
+.
+.SS \n+[step]. Create ThinLV
+.
 .nf
 Create a new thin LV from the thin pool LV.
 The thin LV is created with a virtual size.
@@ -156,26 +155,26 @@ The '--type thin' option is inferred from the virtual size option.
 The --thinpool argument specifies which thin pool will
 contain the ThinLV.
 .fi
-
+.P
 .B lvcreate -n ThinLV -V VirtualSize --thinpool ThinPoolLV VG
-
+.P
 .I Example
 .br
 Create a thin LV in a thin pool:
 .br
 # lvcreate -n thin1 -V 1T --thinpool pool0 vg
-
+.P
 Create another thin LV in the same thin pool:
 .br
 # lvcreate -n thin2 -V 1T --thinpool pool0 vg
-
+.P
 # lvs vg/thin1 vg/thin2
   LV    VG Attr       LSize Pool  Origin Data%
   thin1 vg Vwi-a-tz-- 1.00t pool0        0.00
   thin2 vg Vwi-a-tz-- 1.00t pool0        0.00
-
-.SS 5. create SnapLV
-
+.
+.SS \n+[step]. Create SnapLV
+.
 Create snapshots of an existing ThinLV or SnapLV.
 .br
 Do not specify
@@ -183,49 +182,49 @@ Do not specify
 when creating a thin snapshot.
 .br
 A size argument will cause an old COW snapshot to be created.
-
+.P
 .B lvcreate -n SnapLV --snapshot VG/ThinLV
 .br
 .B lvcreate -n SnapLV --snapshot VG/PrevSnapLV
-
+.P
 .I Example
 .br
 Create first snapshot of an existing ThinLV:
 .br
 # lvcreate -n thin1s1 -s vg/thin1
-
+.P
 Create second snapshot of the same ThinLV:
 .br
 # lvcreate -n thin1s2 -s vg/thin1
-
+.P
 Create a snapshot of the first snapshot:
 .br
 # lvcreate -n thin1s1s1 -s vg/thin1s1
-
+.P
 # lvs vg/thin1s1 vg/thin1s2 vg/thin1s1s1
   LV        VG Attr       LSize Pool  Origin
   thin1s1   vg Vwi---tz-k 1.00t pool0 thin1
   thin1s2   vg Vwi---tz-k 1.00t pool0 thin1
   thin1s1s1 vg Vwi---tz-k 1.00t pool0 thin1s1
-
-.SS 6. activate SnapLV
-
+.
+.SS \n+[step]. Activate SnapLV
+.
 Thin snapshots are created with the persistent "activation skip"
 flag, indicated by the "k" attribute.  Use -K with lvchange
 or vgchange to activate thin snapshots with the "k" attribute.
-
+.P
 .B lvchange -ay -K VG/SnapLV
-
+.P
 .I Example
 .br
 # lvchange -ay -K vg/thin1s1
-
+.P
 # lvs vg/thin1s1
   LV      VG Attr       LSize Pool  Origin
   thin1s1 vg Vwi-a-tz-k 1.00t pool0 thin1
-
-.SH Thin Topics
-
+.
+.SH THIN TOPICS
+.
 .B Automatic pool metadata LV
 .br
 .B Specify devices for data and metadata LVs
@@ -273,172 +272,154 @@ or vgchange to activate thin snapshots with the "k" attribute.
 .B Merge thin snapshots
 .br
 .B XFS on snapshots
-
-\&
-
+.
 .SS Automatic pool metadata LV
-
-\&
-
+.
 A thin data LV can be converted to a thin pool LV without specifying a
 thin pool metadata LV.  LVM automatically creates a metadata LV from the
 same VG.
-
+.P
 .B lvcreate -n ThinDataLV -L LargeSize VG
 .br
 .B lvconvert --type thin-pool VG/ThinDataLV
-
+.P
 .I Example
 .br
 .nf
 # lvcreate -n pool0 -L 10G vg
 # lvconvert --type thin-pool vg/pool0
-
+.P
 # lvs -a
   pool0           vg          twi-a-tz--  10.00g
   [pool0_tdata]   vg          Twi-ao----  10.00g
   [pool0_tmeta]   vg          ewi-ao----  16.00m
 .fi
-
-
+.
 .SS Specify devices for data and metadata LVs
-
-\&
-
+.
 The data and metadata LVs in a thin pool are best created on
 separate physical devices.  To do that, specify the device name(s)
 at the end of the lvcreate line.  It can be especially helpful
 to use fast devices for the metadata LV.
-
+.P
 .B lvcreate -n ThinDataLV -L LargeSize VG LargePV
 .br
 .B lvcreate -n ThinMetaLV -L SmallSize VG SmallPV
 .br
 .B lvconvert --type thin-pool --poolmetadata VG/ThinMetaLV VG/ThinDataLV
-
+.P
 .I Example
-.br
 .nf
 # lvcreate -n pool0 -L 10G vg /dev/sdA
 # lvcreate -n pool0meta -L 1G vg /dev/sdB
 # lvconvert --type thin-pool --poolmetadata vg/pool0meta vg/pool0
 .fi
-
+.P
 .BR lvm.conf (5)
 .B thin_pool_metadata_require_separate_pvs
 .br
 controls the default PV usage for thin pool creation.
-
-\&
-
+.
 .SS Tolerate device failures using raid
-
-\&
-
+.
 To tolerate device failures, use raid for the pool data LV and
 pool metadata LV.  This is especially recommended for pool metadata LVs.
-
+.P
 .B lvcreate --type raid1 -m 1 -n ThinMetaLV -L SmallSize VG PVA PVB
 .br
 .B lvcreate --type raid1 -m 1 -n ThinDataLV -L LargeSize VG PVC PVD
 .br
 .B lvconvert --type thin-pool --poolmetadata VG/ThinMetaLV VG/ThinDataLV
-
+.P
 .I Example
-.br
 .nf
 # lvcreate --type raid1 -m 1 -n pool0 -L 10G vg /dev/sdA /dev/sdB
 # lvcreate --type raid1 -m 1 -n pool0meta -L 1G vg /dev/sdC /dev/sdD
 # lvconvert --type thin-pool --poolmetadata vg/pool0meta vg/pool0
 .fi
-
-
+.
 .SS Spare metadata LV
-
-\&
-
+.
 The first time a thin pool LV is created, lvm will create a spare
 metadata LV in the VG.  This behavior can be controlled with the
 option --poolmetadataspare y|n.  (Future thin pool creations will
 also attempt to create the pmspare LV if none exists.)
-
+.P
 To create the pmspare ("pool metadata spare") LV, lvm first creates
 an LV with a default name, e.g. lvol0, and then converts this LV to
 a hidden LV with the _pmspare suffix, e.g. lvol0_pmspare.
-
+.P
 One pmspare LV is kept in a VG to be used for any thin pool.
-
+.P
 The pmspare LV cannot be created explicitly, but may be removed
 explicitly.
-
+.P
 .I Example
-.br
 .nf
 # lvcreate -n pool0 -L 10G vg
 # lvcreate -n pool0meta -L 1G vg
 # lvconvert --type thin-pool --poolmetadata vg/pool0meta vg/pool0
-
+.P
 # lvs -a
   [lvol0_pmspare] vg          ewi-------
   pool0           vg          twi---tz--
   [pool0_tdata]   vg          Twi-------
   [pool0_tmeta]   vg          ewi-------
 .fi
-
+.P
 The "Metadata check and repair" section describes the use of
 the pmspare LV.
-
-
+.
 .SS Metadata check and repair
-
-\&
-
+.
 If thin pool metadata is damaged, it may be repairable.
 Checking and repairing thin pool metadata is analogous to
 running fsck/repair on a file system.
-
+.P
 When a thin pool LV is activated, lvm runs the thin_check command
 to check the correctness of the metadata on the pool metadata LV.
-
+.P
 .BR lvm.conf (5)
 .B thin_check_executable
 .br
 can be set to an empty string ("") to disable the thin_check step.
 This is not recommended.
-
+.P
 .BR lvm.conf (5)
 .B thin_check_options
 .br
 controls the command options used for the thin_check command.
-
+.P
 If the thin_check command finds a problem with the metadata,
 the thin pool LV is not activated, and the thin pool metadata needs
 to be repaired.
-
+.P
 Simple repair commands are not always successful.  Advanced repair may
 require editing thin pool metadata and lvm metadata.  Newer versions of
 the kernel and lvm tools may be more successful at repair.  Report the
 details of damaged thin metadata to get the best advice on recovery.
-
+.P
 Command to repair a thin pool:
 .br
 .B lvconvert --repair VG/ThinPoolLV
-
+.P
 Repair performs the following steps:
-
-1. Creates a new, repaired copy of the metadata.
+.P
+.nr step 1 1
+.IP \n[step] 3
+Creates a new, repaired copy of the metadata.
 .br
 lvconvert runs the thin_repair command to read damaged metadata
 from the existing pool metadata LV, and writes a new repaired
 copy to the VG's pmspare LV.
-
-2. Replaces the thin pool metadata LV.
+.IP \n+[step] 3
+Replaces the thin pool metadata LV.
 .br
 If step 1 is successful, the thin pool metadata LV is replaced
 with the pmspare LV containing the corrected metadata.
 The previous thin pool metadata LV, containing the damaged metadata,
 becomes visible with the new name ThinPoolLV_metaN (where N is 0,1,...).
-
+.P
 If the repair works, the thin pool LV and its thin LVs can be activated.
 User should manually check if repaired thin pool kernel metadata
 has all data for all lvm2 known LVs by individual activation of
@@ -449,101 +430,93 @@ Once the thin pool is considered fully functional user may remove ThinPoolLV_met
 space reuse.
 For a better performance it may be useful to pvmove the new repaired metadata LV
 (written to previous pmspare volume) to a faster PV, e.g. SSD.
-
+.P
 If the repair operation fails, the thin pool LV and its thin LVs
 are not accessible and it may be necessary to restore their content
 from a backup.  In such case the content of unmodified original damaged
 ThinPoolLV_metaN volume can be used by your support for more
 advanced recovery methods.
-
+.P
 If metadata is manually restored with thin_repair directly,
 the pool metadata LV can be manually swapped with another LV
 containing new metadata:
-
+.P
 .B lvconvert --thinpool VG/ThinPoolLV --poolmetadata VG/NewThinMetaLV
-
+.P
 Note: Thin pool metadata is compact so even small corruptions
 in them may result in significant portions of mappings to be lost.
 It is recommended to use fast resilient storage for them.
-
+.
 .SS Activation of thin snapshots
-
-\&
-
+.
 When a thin snapshot LV is created, it is by default given the
 "activation skip" flag.  This flag is indicated by the "k" attribute
 displayed by lvs:
-
+.P
 .nf
 # lvs vg/thin1s1
   LV         VG  Attr       LSize Pool  Origin
   thin1s1    vg  Vwi---tz-k 1.00t pool0 thin1
 .fi
-
+.P
 This flag causes the snapshot LV to be skipped, i.e. not activated,
 by normal activation commands.  The skipping behavior does not
 apply to deactivation commands.
-
+.P
 A snapshot LV with the "k" attribute can be activated using
 the -K (or --ignoreactivationskip) option in addition to the
 standard -ay (or --activate y) option.
-
+.P
 Command to activate a thin snapshot LV:
 .br
 .B lvchange -ay -K VG/SnapLV
-
+.P
 The persistent "activation skip" flag can be turned off during
 lvcreate, or later with lvchange using the -kn
 (or --setactivationskip n) option.
 It can be turned on again with -ky (or --setactivationskip y).
-
+.P
 When the "activation skip" flag is removed, normal activation
 commands will activate the LV, and the -K activation option is
 not needed.
-
+.P
 Command to create snapshot LV without the activation skip flag:
 .br
 .B lvcreate -kn -n SnapLV -s VG/ThinLV
-
+.P
 Command to remove the activation skip flag from a snapshot LV:
 .br
 .B lvchange -kn VG/SnapLV
-
+.P
 .BR lvm.conf (5)
 .B auto_set_activation_skip
 .br
 controls the default activation skip setting used by lvcreate.
-
-
+.
 .SS Removing thin pool LVs, thin LVs and snapshots
-
-\&
-
+.
 Removing a thin LV and its related snapshots returns the blocks it
 used to the thin pool LV.  These blocks will be reused for other
 thin LVs and snapshots.
-
+.P
 Removing a thin pool LV removes both the data LV and metadata LV
 and returns the space to the VG.
-
+.P
 lvremove of thin pool LVs, thin LVs and snapshots cannot be
 reversed with vgcfgrestore.
-
+.P
 vgcfgbackup does not back up thin pool metadata.
-
-
+.
 .SS Manually manage free data space of thin pool LV
-
-\&
-
+.
 The available free space in a thin pool LV can be displayed
 with the lvs command.  Free space can be added by extending
 the thin pool LV.
-
+.P
 Command to extend thin pool data space:
 .br
 .B lvextend -L Size VG/ThinPoolLV
-
+.P
 .I Example
 .br
 .nf
@@ -551,32 +524,29 @@ Command to extend thin pool data space:
 # lvs
   LV    VG           Attr       LSize   Pool  Origin Data%
   pool0 vg           twi-a-tz--  10.00g               26.96
-
+.P
 2. Double the amount of physical space in the thin pool LV.
 # lvextend -L+10G vg/pool0
-
+.P
 3. The percentage of used data blocks is half the previous value.
 # lvs
   LV    VG           Attr       LSize   Pool  Origin Data%
   pool0 vg           twi-a-tz--  20.00g               13.48
 .fi
-
+.P
 Other methods of increasing free data space in a thin pool LV
 include removing a thin LV and its related snapshots, or running
 fstrim on the file system using a thin LV.
-
-
+.
 .SS Manually manage free metadata space of a thin pool LV
-
-\&
-
+.
 The available metadata space in a thin pool LV can be displayed
 with the lvs -o+metadata_percent command.
-
+.P
 Command to extend thin pool metadata space:
 .br
 .B lvextend --poolmetadatasize Size VG/ThinPoolLV
-
+.P
 .I Example
 .br
 1. A thin pool LV is using 12.40% of its metadata blocks.
@@ -585,7 +555,7 @@ Command to extend thin pool metadata space:
   LV    LSize   Data%  Meta%
   pool0  20.00g  13.48  12.40
 .fi
-
+.P
 2. Display a thin pool LV with its component thin data LV and thin metadata LV.
 .nf
 # lvs -a -oname,attr,size vg
@@ -594,12 +564,12 @@ Command to extend thin pool metadata space:
   [pool0_tdata]   Twi-ao----  20.00g
   [pool0_tmeta]   ewi-ao----  12.00m
 .fi
-
+.P
 3. Double the amount of physical space in the thin metadata LV.
 .nf
 # lvextend --poolmetadatasize +12M vg/pool0
 .fi
-
+.P
 4. The percentage of used metadata blocks is half the previous value.
 .nf
 # lvs -a -oname,size,data_percent,metadata_percent vg
@@ -608,18 +578,15 @@ Command to extend thin pool metadata space:
   [pool0_tdata]    20.00g
   [pool0_tmeta]    24.00m
 .fi
-
-
+.
 .SS Using fstrim to increase free space in a thin pool LV
-
-\&
-
+.
 Removing files in a file system on top of a thin LV does not
 generally add free space back to the thin pool.  Manually running
 the fstrim command can return space back to the thin pool that had
 been used by removed files.  fstrim uses discards and will not work
 if the thin pool LV has discards mode set to ignore.
-
+.P
 .I Example
 .br
 A thin pool has 10G of physical data space, and a thin LV has a virtual
@@ -628,166 +595,157 @@ free space in the thin pool by 10% and increases the virtual usage
 of the file system by 1%.  Removing the 1G file restores the virtual
 1% to the file system, but does not restore the physical 10% to the
 thin pool.  The fstrim command restores the physical space to the thin pool.
-
+.P
 .nf
 # lvs -a -oname,attr,size,pool_lv,origin,data_percent,metadata_percent vg
-LV              Attr       LSize   Pool  Origin Data%  Meta%
-pool0           twi-a-tz--  10.00g               47.01  21.03
-thin1           Vwi-aotz-- 100.00g pool0          2.70
-
+  LV            Attr       LSize   Pool  Origin Data%  Meta%
+  pool0         twi-a-tz--  10.00g              47.01  21.03
+  thin1         Vwi-aotz-- 100.00g pool0         2.70
+.P
 # df -h /mnt/X
 Filesystem            Size  Used Avail Use% Mounted on
 /dev/mapper/vg-thin1   99G  1.1G   93G   2% /mnt/X
-
+.P
 # dd if=/dev/zero of=/mnt/X/1Gfile bs=4096 count=262144; sync
-
+.P
 # lvs
-pool0           vg   twi-a-tz--  10.00g               57.01  25.26
-thin1           vg   Vwi-aotz-- 100.00g pool0          3.70
-
+  pool0         vg   twi-a-tz--  10.00g         57.01  25.26
+  thin1         vg   Vwi-aotz-- 100.00g pool0    3.70
+.P
 # df -h /mnt/X
 /dev/mapper/vg-thin1   99G  2.1G   92G   3% /mnt/X
-
+.P
 # rm /mnt/X/1Gfile
-
+.P
 # lvs
-pool0           vg   twi-a-tz--  10.00g               57.01  25.26
-thin1           vg   Vwi-aotz-- 100.00g pool0          3.70
-
+  pool0         vg   twi-a-tz--  10.00g         57.01  25.26
+  thin1         vg   Vwi-aotz-- 100.00g pool0    3.70
+.P
 # df -h /mnt/X
 /dev/mapper/vg-thin1   99G  1.1G   93G   2% /mnt/X
-
+.P
 # fstrim -v /mnt/X
-
+.P
 # lvs
-pool0           vg   twi-a-tz--  10.00g               47.01  21.03
-thin1           vg   Vwi-aotz-- 100.00g pool0          2.70
+  pool0         vg   twi-a-tz--  10.00g         47.01  21.03
+  thin1         vg   Vwi-aotz-- 100.00g pool0    2.70
 .fi
-
+.P
 The "Discard" section covers an option for automatically freeing data
 space in a thin pool.
-
-
+.
 .SS Automatically extend thin pool LV
-
-\&
-
+.
 The lvm daemon dmeventd (lvm2-monitor) monitors the data usage of thin
 pool LVs and extends them when the usage reaches a certain level.  The
 necessary free space must exist in the VG to extend thin pool LVs.
 Monitoring and extension of thin pool LVs are controlled independently.
-
-.I monitoring
-
+.P
+\(em Monitoring \(em
+.P
 When a thin pool LV is activated, dmeventd will begin monitoring it by
 default.
-
+.sp
 Command to start or stop dmeventd monitoring a thin pool LV:
 .br
-.B lvchange --monitor {y|n} VG/ThinPoolLV
-
+.B lvchange --monitor y|n VG/ThinPoolLV
+.sp
 The current dmeventd monitoring status of a thin pool LV can be displayed
 with the command lvs -o+seg_monitor.
-
-.I autoextend
-
+.P
+\(em Autoextending \(em
+.P
 dmeventd should be configured to extend thin pool LVs before all data
 space is used.  Warnings are emitted through syslog when the use of a thin
 pool reaches 80%, 85%, 90% and 95%.  (See the section "Data space
 exhaustion" for the effects of not extending a thin pool LV.)  The point
 at which dmeventd extends thin pool LVs, and the amount are controlled
 with two configuration settings:
-
+.P
 .BR lvm.conf (5)
 .B thin_pool_autoextend_threshold
 .br
 is a percentage full value that defines when the thin pool LV should be
 extended.  Setting this to 100 disables automatic extension.  The minimum
 value is 50.
-
+.P
 .BR lvm.conf (5)
 .B thin_pool_autoextend_percent
 .br
 defines how much extra data space should be added to the thin pool LV from
 the VG, in percent of its current size.
-
-.I disabling
-
+.P
+\(em Disabling \(em
+.P
 There are multiple ways that extension of thin pools could be prevented:
-
 .IP \[bu] 2
 If the dmeventd daemon is not running, no monitoring or automatic
 extension will occur.
-
+.
 .IP \[bu]
 Even when dmeventd is running, all monitoring can be disabled with the
 lvm.conf monitoring setting.
-
+.
 .IP \[bu]
 To activate or create a thin pool LV without interacting with dmeventd,
 the --ignoremonitoring option can be used.  With this option, the command
 will not ask dmeventd to monitor the thin pool LV.
-
+.
 .IP \[bu]
 Setting thin_pool_autoextend_threshold to 100 disables automatic
 extension of thin pool LVs, even if they are being monitored by dmeventd.
-
 .P
-
 .I Example
 .br
 If thin_pool_autoextend_threshold is 70 and thin_pool_autoextend_percent is 20,
 whenever a pool exceeds 70% usage, it will be extended by another 20%.
 For a 1G pool, using 700M will trigger a resize to 1.2G. When the usage exceeds
 840M, the pool will be extended to 1.44G, and so on.
-
-
+.
 .SS Data space exhaustion
-
-\&
-
+.
 When properly managed, thin pool data space should be extended before it
 is all used (see the section "Automatically extend thin pool LV").  If
 thin pool data space is already exhausted, it can still be extended (see
 the section "Manually manage free data space of thin pool LV".)
-
+.P
 The behavior of a full thin pool is configurable with the --errorwhenfull
 y|n option to lvcreate or lvchange.  The errorwhenfull setting applies
 only to writes; reading thin LVs can continue even when data space is
 exhausted.
-
+.P
 Command to change the handling of a full thin pool:
 .br
-.B lvchange --errorwhenfull {y|n} VG/ThinPoolLV
-
+.B lvchange --errorwhenfull y|n VG/ThinPoolLV
+.P
 .BR lvm.conf (5)
 .B error_when_full
 .br
 controls the default error when full behavior.
-
+.P
 The current setting of a thin pool LV can be displayed with the command:
 lvs -o+lv_when_full.
-
+.P
 The errorwhenfull setting does not effect the monitoring and autoextend
 settings, and the monitoring/autoextend settings do not effect the
 errorwhenfull setting.  It is only when monitoring/autoextend are not
 effective that the thin pool becomes full and the errorwhenfull setting is
 applied.
-
-.I errorwhenfull n
-
+.P
+\(em errorwhenfull n \(em
+.P
 This is the default.  Writes to thin LVs are accepted and queued, with the
 expectation that pool data space will be extended soon.  Once data space
 is extended, the queued writes will be processed, and the thin pool will
 return to normal operation.
-
+.P
 While waiting to be extended, the thin pool will queue writes for up to 60
 seconds (the default).  If data space has not been extended after this
 time, the queued writes will return an error to the caller, e.g. the file
 system.  This can result in file system corruption for non-journaled file
 systems that may require repair.  When a thin pool returns errors for writes
 to a thin LV, any file system is subject to losing unsynced user data.
-
+.P
 The 60 second timeout can be changed or disabled with the dm-thin-pool
 kernel module option
 .B no_space_timeout.
@@ -795,330 +753,315 @@ This option sets the number of seconds that thin pools will queue writes.
 If set to 0, writes will not time out.  Disabling timeouts can result in
 the system running out of resources, memory exhaustion, hung tasks, and
 deadlocks.  (The timeout applies to all thin pools on the system.)
-
-.I errorwhenfull y
-
+.P
+\(em errorwhenfull y \(em
+.P
 Writes to thin LVs immediately return an error, and no writes are queued.
 In the case of a file system, this can result in corruption that may
 require fs repair (the specific consequences depend on the thin LV user.)
-
-.I data percent
-
+.P
+\(em data percent \(em
+.P
 When data space is exhausted, the lvs command displays 100 under Data% for
 the thin pool LV:
-
+.P
 .nf
 # lvs vg/pool0
   LV     VG           Attr       LSize   Pool  Origin Data%
   pool0  vg           twi-a-tz-- 512.00m              100.00
 .fi
-
-.I causes
-
+.P
+\(em causes \(em
+.P
 A thin pool may run out of data space for any of the following reasons:
-
+.
 .IP \[bu] 2
 Automatic extension of the thin pool is disabled, and the thin pool is not
 manually extended.  (Disabling automatic extension is not recommended.)
-
+.
 .IP \[bu]
 The dmeventd daemon is not running and the thin pool is not manually
 extended.  (Disabling dmeventd is not recommended.)
-
+.
 .IP \[bu]
 Automatic extension of the thin pool is too slow given the rate of writes
 to thin LVs in the pool.  (This can be addressed by tuning the
 thin_pool_autoextend_threshold and thin_pool_autoextend_percent.
 See "Automatic extend settings".)
-
+.
 .IP \[bu]
 The VG does not have enough free blocks to extend the thin pool.
-
-.P
-
+.
 .SS Metadata space exhaustion
-
-\&
-
+.
 If thin pool metadata space is exhausted (or a thin pool metadata
 operation fails), errors will be returned for IO operations on thin LVs.
-
+.P
 When metadata space is exhausted, the lvs command displays 100 under Meta%
 for the thin pool LV:
-
+.P
 .nf
 # lvs -o lv_name,size,data_percent,metadata_percent vg/pool0
   LV    LSize Data%  Meta%
   pool0              100.00
 .fi
-
+.P
 The same reasons for thin pool data space exhaustion apply to thin pool
 metadata space.
-
+.P
 Metadata space exhaustion can lead to inconsistent thin pool metadata and
 inconsistent file systems, so the response requires offline checking and
 repair.
-
-1. Deactivate the thin pool LV, or reboot the system if this is not possible.
-
-2. Repair thin pool with lvconvert --repair.
-.br
-   See "Metadata check and repair".
-
-3. Extend pool metadata space with lvextend --poolmetadatasize.
-.br
-   See "Manually manage free metadata space of a thin pool LV".
-
-4. Check and repair file system.
-
-
+.TP 4
+1.
+Deactivate the thin pool LV, or reboot the system if this is not possible.
+.TP
+2.
+Repair thin pool with lvconvert --repair.
+.br
+See "Metadata check and repair".
+.TP
+3.
+Extend pool metadata space with lvextend --poolmetadatasize.
+.br
+See "Manually manage free metadata space of a thin pool LV".
+.TP
+4.
+Check and repair file system.
+.
 .SS Automatic extend settings
-
-\&
-
+.
 Thin pool LVs can be extended according to preset values.  The presets
 determine if the LV should be extended based on how full it is, and if so
 by how much.  When dmeventd monitors thin pool LVs, it uses lvextend with
 these presets.  (See "Automatically extend thin pool LV".)
-
+.P
 Command to extend a thin pool data LV using presets:
 .br
 .B lvextend --use-policies VG/ThinPoolLV
-
+.P
 The command uses these settings:
-
+.P
 .BR lvm.conf (5)
 .B thin_pool_autoextend_threshold
 .br
 autoextend the LV when its usage exceeds this percent.
-
+.P
 .BR lvm.conf (5)
 .B thin_pool_autoextend_percent
 .br
 autoextend the LV by this much additional space.
-
+.P
 To see the default values of these settings, run:
-
+.P
 .B lvmconfig --type default --withcomment
 .RS
 .B activation/thin_pool_autoextend_threshold
 .RE
-
+.P
 .B lvmconfig --type default --withcomment
 .RS
 .B activation/thin_pool_autoextend_percent
 .RE
-
+.P
 To change these values globally, edit
 .BR lvm.conf (5).
-
+.P
 To change these values on a per-VG or per-LV basis, attach a "profile" to
 the VG or LV.  A profile is a collection of config settings, saved in a
 local text file (using the lvm.conf format).  lvm looks for profiles in
 the profile_dir directory, e.g. #DEFAULT_SYS_DIR#/profile/.  Once attached to a VG
 or LV, lvm will process the VG or LV using the settings from the attached
 profile.  A profile is named and referenced by its file name.
-
+.P
 To use a profile to customize the lvextend settings for an LV:
-
+.
 .IP \[bu] 2
 Create a file containing settings, saved in profile_dir.
+.br
 For the profile_dir location, run:
 .br
 .B lvmconfig config/profile_dir
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Attach the profile to an LV, using the command:
 .br
 .B lvchange --metadataprofile ProfileName VG/ThinPoolLV
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Extend the LV using the profile settings:
 .br
 .B lvextend --use-policies VG/ThinPoolLV
-
 .P
-
 .I Example
 .br
 .nf
 # lvmconfig config/profile_dir
 profile_dir="#DEFAULT_SYS_DIR#/profile"
-
+.P
 # cat #DEFAULT_SYS_DIR#/profile/pool0extend.profile
 activation {
         thin_pool_autoextend_threshold=50
         thin_pool_autoextend_percent=10
 }
-
+.P
 # lvchange --metadataprofile pool0extend vg/pool0
-
+.P
 # lvextend --use-policies vg/pool0
 .fi
-
-.I Notes
+.P
+Notes
+.
 .IP \[bu] 2
 A profile is attached to a VG or LV by name, where the name references a
 local file in profile_dir.  If the VG is moved to another machine, the
 file with the profile also needs to be moved.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Only certain settings can be used in a VG or LV profile, see:
 .br
 .B lvmconfig --type profilable-metadata.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 An LV without a profile of its own will inherit the VG profile.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Remove a profile from an LV using the command:
 .br
 .B lvchange --detachprofile VG/ThinPoolLV.
-
-.IP \[bu] 2
+.
+.IP \[bu]
 Commands can also have profiles applied to them.  The settings that can be
 applied to a command are different than the settings that can be applied
 to a VG or LV.  See lvmconfig --type profilable-command.  To apply a
 profile to a command, write a profile, save it in the profile directory,
 and run the command using the option: --commandprofile ProfileName.
-
-
+.
 .SS Zeroing
-
-\&
-
+.
 When a thin pool provisions a new data block for a thin LV, the
 new block is first overwritten with zeros.  The zeroing mode is
 indicated by the "z" attribute displayed by lvs.  The option -Z
 (or --zero) can be added to commands to specify the zeroing mode.
-
+.P
 Command to set the zeroing mode when creating a thin pool LV:
-.br
-.B lvconvert --type thin-pool -Z{y|n}
-.br
+.P
+.B lvconvert --type thin-pool -Z y|n
 .RS
 .B --poolmetadata VG/ThinMetaLV VG/ThinDataLV
 .RE
-
+.P
 Command to change the zeroing mode of an existing thin pool LV:
-.br
-.B lvchange -Z{y|n} VG/ThinPoolLV
-
+.P
+.B lvchange -Z y|n VG/ThinPoolLV
+.P
 If zeroing mode is changed from "n" to "y", previously provisioned
 blocks are not zeroed.
-
+.P
 Provisioning of large zeroed chunks impacts performance.
-
+.P
 .BR lvm.conf (5)
 .B thin_pool_zero
 .br
 controls the default zeroing mode used when creating a thin pool.
-
-
+.
 .SS Discard
-
-\&
-
+.
 The discard behavior of a thin pool LV determines how discard requests are
 handled.  Enabling discard under a file system may adversely affect the
 file system performance (see the section on fstrim for an alternative.)
 Possible discard behaviors:
-
-ignore: Ignore any discards that are received.
-
-nopassdown: Process any discards in the thin pool itself and allow
+.P
+.B ignore:
+Ignore any discards that are received.
+.P
+.B nopassdown:
+Process any discards in the thin pool itself and allow
 the no longer needed extents to be overwritten by new data.
-
-passdown: Process discards in the thin pool (as with nopassdown), and
+.P
+.B passdown:
+Process discards in the thin pool (as with nopassdown), and
 pass the discards down the the underlying device.  This is the default
 mode.
-
+.P
 Command to display the current discard mode of a thin pool LV:
 .br
 .B lvs -o+discards VG/ThinPoolLV
-
+.P
 Command to set the discard mode when creating a thin pool LV:
 .br
-.B lvconvert --discards {ignore|nopassdown|passdown}
-.br
+.B lvconvert --discards ignore|nopassdown|passdown
 .RS
 .B --type thin-pool --poolmetadata VG/ThinMetaLV VG/ThinDataLV
 .RE
-
+.P
 Command to change the discard mode of an existing thin pool LV:
 .br
-.B lvchange --discards {ignore|nopassdown|passdown} VG/ThinPoolLV
-
+.B lvchange --discards ignore|nopassdown|passdown VG/ThinPoolLV
+.P
 .I Example
-.br
 .nf
 # lvs -o name,discards vg/pool0
-pool0 passdown
-
+  pool0 passdown
+.P
 # lvchange --discards ignore vg/pool0
 .fi
-
+.P
 .BR lvm.conf (5)
 .B thin_pool_discards
 .br
 controls the default discards mode used when creating a thin pool.
-
-
+.
 .SS Chunk size
-
-\&
-
+.
 The size of data blocks managed by a thin pool can be specified with the
 --chunksize option when the thin pool LV is created.  The default unit
 is KiB. The value must be a multiple of 64KiB between 64KiB and 1GiB.
-
+.P
 When a thin pool is used primarily for the thin provisioning feature, a
 larger value is optimal.  To optimize for many snapshots, a smaller value
 reduces copying time and consumes less space.
-
+.P
 Command to display the thin pool LV chunk size:
-.br
+.P
 .B lvs -o+chunksize VG/ThinPoolLV
-
+.P
 .I Example
-.br
 .nf
 # lvs -o name,chunksize
   pool0 64.00k
 .fi
-
+.P
 .BR lvm.conf (5)
 .B thin_pool_chunk_size
 .br
 controls the default chunk size used when creating a thin pool.
-
+.P
 The default value is shown by:
 .br
 .B lvmconfig --type default allocation/thin_pool_chunk_size
-
-
+.P
+.
 .SS Size of pool metadata LV
-
-\&
-
+.
 The amount of thin metadata depends on how many blocks are shared between
 thin LVs (i.e. through snapshots).  A thin pool with many snapshots may
 need a larger metadata LV.  Thin pool metadata LV sizes can be from 2MiB
 to approximately 16GiB.
-
+.P
 When using lvcreate to create what will become a thin metadata LV, the
 size is specified with the -L|--size option.
-
+.P
 When an LVM command automatically creates a thin metadata LV, the size is
 specified with the --poolmetadatasize option.  When this option is not
 given, LVM automatically chooses a size based on the data size and chunk
 size.
-
+.P
 It can be hard to predict the amount of metadata space that will be
 needed, so it is recommended to start with a size of 1GiB which should be
 enough for all practical purposes.  A thin pool metadata LV can later be
 manually or automatically extended if needed.
-
+.P
 Configurable setting
 .BR lvm.conf (5)
 .BR allocation / thin_pool_crop_metadata
@@ -1126,38 +1069,31 @@ gives control over cropping to 15.81GiB to stay backward compatible with older
 versions of lvm2. With enabled cropping there can be observed some problems when
 using volumes above this size with thin tools (i.e. thin_repair).
 Cropping should be enabled only when compatibility is required.
-
-
+.
 .SS Create a thin snapshot of an external, read only LV
-
-\&
-
+.
 Thin snapshots are typically taken of other thin LVs or other
 thin snapshot LVs within the same thin pool.  It is also possible
 to take thin snapshots of external, read only LVs.  Writes to the
 snapshot are stored in the thin pool, and the external LV is used
 to read unwritten parts of the thin snapshot.
-
+.P
 .B lvcreate -n SnapLV -s VG/ExternalOriginLV --thinpool VG/ThinPoolLV
-
+.P
 .I Example
-.br
 .nf
 # lvchange -an vg/lve
 # lvchange --permission r vg/lve
 # lvcreate -n snaplve -s vg/lve --thinpool vg/pool0
-
+.P
 # lvs vg/lve vg/snaplve
   LV      VG  Attr       LSize  Pool  Origin Data%
   lve     vg  ori------- 10.00g
   snaplve vg  Vwi-a-tz-- 10.00g pool0 lve      0.00
 .fi
-
-
+.
 .SS Convert a standard LV to a thin LV with an external origin
-
-\&
-
+.
 A new thin LV can be created and given the name of an existing
 standard LV.  At the same time, the existing LV is converted to a
 read only external LV with a new name.  Unwritten portions of the
@@ -1165,66 +1101,57 @@ thin LV are read from the external LV.
 The new name given to the existing LV can be specified with
 --originname, otherwise the existing LV will be given a default
 name, e.g. lvol#.
-
+.P
 Convert ExampleLV into a read only external LV with the new name
 NewExternalOriginLV, and create a new thin LV that is given the previous
 name of ExampleLV.
-
+.P
 .B lvconvert --type thin --thinpool VG/ThinPoolLV
-.br
 .RS
 .B --originname NewExternalOriginLV VG/ExampleLV
 .RE
-
+.P
 .I Example
-.br
 .nf
 # lvcreate -n lv_example -L 10G vg
-
+.P
 # lvs
   lv_example      vg          -wi-a-----  10.00g
-
+.P
 # lvconvert --type thin --thinpool vg/pool0
           --originname lv_external --thin vg/lv_example
-
+.P
 # lvs
   LV              VG          Attr       LSize   Pool  Origin
   lv_example      vg          Vwi-a-tz--  10.00g pool0 lv_external
   lv_external     vg          ori-------  10.00g
 .fi
-
-
+.
 .SS Single step thin pool LV creation
-
-\&
-
+.
 A thin pool LV can be created with a single lvcreate command,
 rather than using lvconvert on existing LVs.
 This one command creates a thin data LV, a thin metadata LV,
 and combines the two into a thin pool LV.
-
+.P
 .B lvcreate --type thin-pool -L LargeSize -n ThinPoolLV VG
-
+.P
 .I Example
-.br
 .nf
 # lvcreate --type thin-pool -L8M -n pool0 vg
-
+.P
 # lvs vg/pool0
   LV    VG  Attr       LSize Pool Origin Data%
   pool0 vg  twi-a-tz-- 8.00m               0.00
-
+.P
 # lvs -a
   pool0           vg          twi-a-tz--   8.00m
   [pool0_tdata]   vg          Twi-ao----   8.00m
   [pool0_tmeta]   vg          ewi-ao----   8.00m
 .fi
-
-
+.
 .SS Single step thin pool LV and thin LV creation
-
-\&
-
+.
 A thin pool LV and a thin LV can be created with a single
 lvcreate command.  This one command creates a thin data LV,
 a thin metadata LV, combines the two into a thin pool LV,
@@ -1233,92 +1160,86 @@ and creates a thin LV in the new pool.
 -L LargeSize specifies the physical size of the thin pool LV.
 .br
 -V VirtualSize specifies the virtual size of the thin LV.
-
+.P
 .B lvcreate --type thin -V VirtualSize -L LargeSize
 .RS
 .B -n ThinLV --thinpool VG/ThinPoolLV
 .RE
-
+.P
 Equivalent to:
 .br
 .B lvcreate --type thin-pool -L LargeSize VG/ThinPoolLV
 .br
 .B lvcreate -n ThinLV -V VirtualSize --thinpool VG/ThinPoolLV
-
+.P
 .I Example
-.br
 .nf
 # lvcreate -L8M -V2G -n thin1 --thinpool vg/pool0
-
+.P
 # lvs -a
   pool0           vg          twi-a-tz--   8.00m
   [pool0_tdata]   vg          Twi-ao----   8.00m
   [pool0_tmeta]   vg          ewi-ao----   8.00m
   thin1           vg          Vwi-a-tz--   2.00g pool0
 .fi
-
-
+.
 .SS Merge thin snapshots
-
-\&
-
+.
 A thin snapshot can be merged into its origin thin LV using the lvconvert
 --merge command.  The result of a snapshot merge is that the origin thin
 LV takes the content of the snapshot LV, and the snapshot LV is removed.
 Any content that was unique to the origin thin LV is lost after the merge.
-
+.P
 Because a merge changes the content of an LV, it cannot be done while the
 LVs are open, e.g. mounted.  If a merge is initiated while the LVs are open,
 the effect of the merge is delayed until the origin thin LV is next
 activated.
-
+.P
 .B lvconvert --merge VG/SnapLV
-
+.P
 .I Example
-.br
 .nf
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
   pool0   vg twi-a-tz--  10.00g
   thin1   vg Vwi-a-tz-- 100.00g pool0
   thin1s1 vg Vwi-a-tz-k 100.00g pool0 thin1
-
+.P
 # lvconvert --merge vg/thin1s1
-
+.P
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
   pool0   vg twi-a-tz--  10.00g
   thin1   vg Vwi-a-tz-- 100.00g pool0
 .fi
-
+.P
 .I Example
-.br
 .nf
 Delayed merging of open LVs.
-
+.P
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
   pool0   vg twi-a-tz--  10.00g
   thin1   vg Vwi-aotz-- 100.00g pool0
   thin1s1 vg Vwi-aotz-k 100.00g pool0 thin1
-
+.P
 # df
 /dev/mapper/vg-thin1            100G   33M  100G   1% /mnt/X
 /dev/mapper/vg-thin1s1          100G   33M  100G   1% /mnt/Xs
-
+.P
 # ls /mnt/X
 file1 file2 file3
 # ls /mnt/Xs
 file3 file4 file5
-
+.P
 # lvconvert --merge vg/thin1s1
 Logical volume vg/thin1s1 contains a filesystem in use.
 Delaying merge since snapshot is open.
 Merging of thin snapshot thin1s1 will occur on next activation.
-
+.P
 # umount /mnt/X
 # umount /mnt/Xs
-
+.P
 # lvs -a vg
   LV              VG   Attr       LSize   Pool  Origin
   pool0           vg   twi-a-tz--  10.00g
@@ -1326,47 +1247,47 @@ Merging of thin snapshot thin1s1 will occur on next activation.
   [pool0_tmeta]   vg   ewi-ao----   1.00g
   thin1           vg   Owi-a-tz-- 100.00g pool0
   [thin1s1]       vg   Swi-a-tz-k 100.00g pool0 thin1
-
+.P
 # lvchange -an vg/thin1
 # lvchange -ay vg/thin1
-
+.P
 # mount /dev/vg/thin1 /mnt/X
-
+.P
 # ls /mnt/X
 file3 file4 file5
 .fi
-
-
+.
 .SS XFS on snapshots
-
-\&
-
+.
 Mounting an XFS file system on a new snapshot LV requires attention to the
 file system's log state and uuid.  On the snapshot LV, the xfs log will
 contain a dummy transaction, and the xfs uuid will match the uuid from the
 file system on the origin LV.
-
+.P
 If the snapshot LV is writable, mounting will recover the log to clear the
 dummy transaction, but will require skipping the uuid check:
-
-mount /dev/VG/SnapLV /mnt -o nouuid
-
+.P
+# mount /dev/VG/SnapLV /mnt -o nouuid
+.P
 After the first mount with the above approach, the UUID can subsequently be
 changed using:
-
-xfs_admin -U generate /dev/VG/SnapLV
-.br
-mount /dev/VG/SnapLV /mnt
-
+.P
+# xfs_admin -U generate /dev/VG/SnapLV
+.P
+# mount /dev/VG/SnapLV /mnt
+.P
 Once the UUID has been changed, the mount command will no longer require
 the nouuid option.
-
+.P
 If the snapshot LV is readonly, the log recovery and uuid check need to be
 skipped while mounting readonly:
-
-mount /dev/VG/SnapLV /mnt -o ro,nouuid,norecovery
-
+.P
+# mount /dev/VG/SnapLV /mnt -o ro,nouuid,norecovery
+.
 .SH SEE ALSO
+.
+.nh
+.ad l
 .BR lvm (8),
 .BR lvm.conf (5),
 .BR lvmconfig (8),
@@ -1376,7 +1297,7 @@ mount /dev/VG/SnapLV /mnt -o ro,nouuid,norecovery
 .BR lvextend (8),
 .BR lvremove (8),
 .BR lvs (8),
+.P
 .BR thin_dump (8),
-.BR thin_repair (8)
+.BR thin_repair (8),
 .BR thin_restore (8)
-
diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 55b9fa2a6..7bc27b189 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -1,19 +1,22 @@
 .TH "LVMVDO" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-
+.
 .SH NAME
+.
 lvmvdo \(em Support for Virtual Data Optimizer in LVM
+.
 .SH DESCRIPTION
+.
 VDO is software that provides inline
 block-level deduplication, compression, and thin provisioning capabilities
 for primary storage.
-
+.P
 Deduplication is a technique for reducing the consumption of storage
 resources by eliminating multiple copies of duplicate blocks. Compression
 takes the individual unique blocks and shrinks them. These reduced blocks are then efficiently packed together into
 physical blocks. Thin provisioning manages the mapping from logical blocks
 presented by VDO to where the data has actually been physically stored,
 and also eliminates any blocks of all zeroes.
-
+.P
 With deduplication, instead of writing the same data more than once, VDO detects and records each
 duplicate block as a reference to the original
 block. VDO maintains a mapping from Logical Block Addresses (LBA) (used by the
@@ -21,31 +24,33 @@ storage layer above VDO) to physical block addresses (used by the storage
 layer under VDO). After deduplication, multiple logical block addresses
 may be mapped to the same physical block address; these are called shared
 blocks and are reference-counted by the software.
-
+.P
 With compression, VDO compresses multiple blocks (or shared blocks)
 with the fast LZ4 algorithm, and bins them together where possible so that
 multiple compressed blocks fit within a 4 KB block on the underlying
 storage. Mapping from LBA is to a physical block address and index within
 it for the desired compressed data. All compressed blocks are individually
 reference counted for correctness.
-
+.P
 Block sharing and block compression are invisible to applications using
 the storage, which read and write blocks as they would if VDO were not
 present. When a shared block is overwritten, a new physical block is
 allocated for storing the new block data to ensure that other logical
 block addresses that are mapped to the shared physical block are not
 modified.
-
+.P
 To use VDO with \fBlvm\fP(8), you must install the standard VDO user-space tools
 \fBvdoformat\fP(8) and the currently non-standard kernel VDO module
 "\fIkvdo\fP".
-
+.P
 The "\fIkvdo\fP" module implements fine-grained storage virtualization,
 thin provisioning, block sharing, and compression.
 The "\fIuds\fP" module provides memory-efficient duplicate
 identification. The user-space tools include \fBvdostats\fP(8)
 for extracting statistics from VDO volumes.
+.
 .SH VDO TERMS
+.
 .TP
 VDODataLV
 .br
@@ -54,6 +59,7 @@ VDO data LV
 A large hidden LV with the _vdata suffix. It is created in a VG
 .br
 used by the VDO kernel target to store all data and metadata blocks.
+.
 .TP
 VDOPoolLV
 .br
@@ -62,6 +68,7 @@ VDO pool LV
 A pool for virtual VDOLV(s), which are the size of used VDODataLV.
 .br
 Only a single VDOLV is currently supported.
+.
 .TP
 VDOLV
 .br
@@ -70,9 +77,14 @@ VDO LV
 Created from VDOPoolLV.
 .br
 Appears blank after creation.
+.
 .SH VDO USAGE
+.
 The primary methods for using VDO with lvm2:
-.SS 1. Create a VDOPoolLV and a VDOLV
+.nr step 1 1
+.
+.SS \n[step]. Create a VDOPoolLV and a VDOLV
+.
 Create a VDOPoolLV that will hold VDO data, and a
 virtual size VDOLV that the user can use. If you do not specify the virtual size,
 then the VDOLV is created with the maximum size that
@@ -81,23 +93,25 @@ deduplication or compression can happen
 (i.e. it can hold the incompressible content of /dev/urandom).
 If you do not specify the name of VDOPoolLV, it is taken from
 the sequence of vpool0, vpool1 ...
-
+.P
 Note: The performance of TRIM/Discard operations is slow for large
 volumes of VDO type. Please try to avoid sending discard requests unless
 necessary because it might take considerable amount of time to finish the discard
 operation.
-
+.P
 .nf
 .B lvcreate --type vdo -n VDOLV -L DataSize -V LargeVirtualSize VG/VDOPoolLV
 .B lvcreate --vdo -L DataSize VG
 .fi
-
+.P
 .I Example
 .nf
 # lvcreate --type vdo -n vdo0 -L 10G -V 100G vg/vdopool0
 # mkfs.ext4 -E nodiscard /dev/vg/vdo0
 .fi
-.SS 2. Convert an existing LV into VDOPoolLV
+.
+.SS \n+[step]. Convert an existing LV into VDOPoolLV
+.
 Convert an already created or existing LV into a VDOPoolLV, which is a volume
 that can hold data and metadata.
 You will be prompted to confirm such conversion because it \fBIRREVERSIBLY
@@ -106,24 +120,26 @@ formatted by \fBvdoformat\fP(8) as a VDO pool data volume. You can
 specify the virtual size of the VDOLV associated with this VDOPoolLV.
 If you do not specify the virtual size, it will be set to the maximum size
 that can keep 100% incompressible data there.
-
+.P
 .nf
 .B lvconvert --type vdo-pool -n VDOLV -V VirtualSize VG/VDOPoolLV
 .B lvconvert --vdopool VG/VDOPoolLV
 .fi
-
+.P
 .I Example
 .nf
 # lvconvert --type vdo-pool -n vdo0 -V10G vg/ExistingLV
 .fi
-.SS 3. Change the default settings used for creating a VDOPoolLV
+.
+.SS \n+[step]. Change the default settings used for creating a VDOPoolLV
+.
 VDO allows to set a large variety of options. Lots of these settings
 can be specified in lvm.conf or profile settings. You can prepare
 a number of different profiles in the #DEFAULT_SYS_DIR#/profile directory
 and just specify the profile file name.
 Check the output of \fBlvmconfig --type default --withcomments\fP
 for a detailed description of all individual VDO settings.
-
+.P
 .I Example
 .nf
 # cat <<EOF > #DEFAULT_SYS_DIR#/profile/vdo_create.profile
@@ -149,43 +165,45 @@ allocation {
 	vdo_max_discard=1
 }
 EOF
-
+.P
 # lvcreate --vdo -L10G --metadataprofile vdo_create vg/vdopool0
 # lvcreate --vdo -L10G --config 'allocation/vdo_cpu_threads=4' vg/vdopool1
 .fi
-.SS 4. Change the compression and deduplication of a VDOPoolLV
+.
+.SS \n+[step]. Change the compression and deduplication of a VDOPoolLV
+.
 Disable or enable the compression and deduplication for VDOPoolLV
 (the volume that maintains all VDO LV(s) associated with it).
-
-.nf
+.P
 .B lvchange --compression [y|n] --deduplication [y|n] VG/VDOPoolLV
-.fi
-
+.P
 .I Example
 .nf
 # lvchange --compression n  vg/vdopool0
 # lvchange --deduplication y vg/vdopool1
 .fi
-.SS 5. Checking the usage of VDOPoolLV
+.
+.SS \n+[step]. Checking the usage of VDOPoolLV
+.
 To quickly check how much data on a VDOPoolLV is already consumed,
 use \fBlvs\fP(8). The Data% field reports how much data is occupied
 in the content of the virtual data for the VDOLV and how much space is already
 consumed with all the data and metadata blocks in the VDOPoolLV.
 For a detailed description, use the \fBvdostats\fP(8) command.
-
+.P
 Note: \fBvdostats\fP(8) currently understands only /dev/mapper device names.
-
+.P
 .I Example
 .nf
 # lvcreate --type vdo -L10G -V20G -n vdo0 vg/vdopool0
 # mkfs.ext4 -E nodiscard /dev/vg/vdo0
 # lvs -a vg
-
+.P
   LV               VG Attr       LSize  Pool     Origin Data%
   vdo0             vg vwi-a-v--- 20.00g vdopool0        0.01
   vdopool0         vg dwi-ao---- 10.00g                 30.16
   [vdopool0_vdata] vg Dwi-ao---- 10.00g
-
+.P
 # vdostats --all /dev/mapper/vg-vdopool0-vpool
 /dev/mapper/vg-vdopool0 :
   version                             : 30
@@ -193,76 +211,88 @@ Note: \fBvdostats\fP(8) currently understands only /dev/mapper device names.
   data blocks used                    : 79
   ...
 .fi
-.SS 6. Extending the VDOPoolLV size
+.
+.SS \n+[step]. Extending the VDOPoolLV size
+.
 You can add more space to hold VDO data and metadata by
 extending the VDODataLV using the commands
 \fBlvresize\fP(8) and \fBlvextend\fP(8).
 The extension needs to add at least one new VDO slab. You can configure
 the slab size with the \fBallocation/vdo_slab_size_mb\fP setting.
-
+.P
 You can also enable automatic size extension of a monitored VDOPoolLV
 with the \fBactivation/vdo_pool_autoextend_percent\fP and
 \fBactivation/vdo_pool_autoextend_threshold\fP settings.
-
+.P
 Note: You cannot reduce the size of a VDOPoolLV.
-
-.nf
+.P
 .B lvextend -L+AddingSize VG/VDOPoolLV
-.fi
-
+.P
 .I Example
 .nf
 # lvextend -L+50G vg/vdopool0
 # lvresize -L300G vg/vdopool1
 .fi
-.SS 7. Extending or reducing the VDOLV size
+.
+.SS \n+[step]. Extending or reducing the VDOLV size
+.
 You can extend or reduce a virtual VDO LV as a standard LV with the
 \fBlvresize\fP(8), \fBlvextend\fP(8), and \fBlvreduce\fP(8) commands.
-
+.P
 Note: The reduction needs to process TRIM for reduced disk area
 to unmap used data blocks from the VDOPoolLV, which might take
 a long time.
-
-.nf
+.P
 .B lvextend -L+AddingSize VG/VDOLV
+.br
 .B lvreduce -L-ReducingSize VG/VDOLV
-.fi
-
+.P
 .I Example
 .nf
 # lvextend -L+50G vg/vdo0
 # lvreduce -L-50G vg/vdo1
 # lvresize -L200G vg/vdo2
 .fi
-.SS 8. Component activation of a VDODataLV
+.
+.SS \n+[step]. Component activation of a VDODataLV
+.
 You can activate a VDODataLV separately as a component LV for examination
 purposes. The activation of the VDODataLV activates the data LV in read-only mode,
 and the data LV cannot be modified.
 If the VDODataLV is active as a component, any upper LV using this volume CANNOT
 be activated. You have to deactivate the VDODataLV first to continue to use the VDOPoolLV.
-
+.P
 .I Example
 .nf
 # lvchange -ay vg/vpool0_vdata
 # lvchange -an vg/vpool0_vdata
 .fi
+.
 .SH VDO TOPICS
-.SS 1. Stacking VDO
+.
+.nr step 1 1
+.
+.SS \n[step]. Stacking VDO
+.
 You can convert or stack a VDOPooLV with these currently supported
 volume types: linear, stripe, raid, and cache with cachepool.
-.SS 2. VDOPoolLV on top of raid
+.
+.SS \n+[step]. VDOPoolLV on top of raid
+.
 Using a raid type LV for a VDODataLV.
-
+.P
 .I Example
 .nf
 # lvcreate --type raid1 -L 5G -n vdopool vg
 # lvconvert --type vdo-pool -V 10G vg/vdopool
 .fi
-.SS 3. Caching a VDODataLV or a VDOPoolLV
+.
+.SS \n+[step]. Caching a VDODataLV or a VDOPoolLV
+.
 VDODataLV (accepts also VDOPoolLV) caching provides a mechanism
 to accelerate reads and writes of already compressed and deduplicated
 data blocks together with VDO metadata.
-
+.P
 .I Example
 .nf
 # lvcreate --type vdo -L 5G -V 10G -n vdo1 vg/vdopool
@@ -270,10 +300,12 @@ data blocks together with VDO metadata.
 # lvconvert --cache --cachepool vg/cachepool vg/vdopool
 # lvconvert --uncache vg/vdopool
 .fi
-.SS 4. Caching a VDOLV
+.
+.SS \n+[step]. Caching a VDOLV
+.
 VDO LV cache allow you to 'cache' a device for better performance before
 it hits the processing of the VDO Pool LV layer.
-
+.P
 .I Example
 .nf
 # lvcreate --type vdo -L 5G -V 10G -n vdo1 vg/vdopool
@@ -281,12 +313,14 @@ it hits the processing of the VDO Pool LV layer.
 # lvconvert --cache --cachepool vg/cachepool vg/vdo1
 # lvconvert --uncache vg/vdo1
 .fi
-.SS 5. Usage of Discard/TRIM with a VDOLV
+.
+.SS \n+[step]. Usage of Discard/TRIM with a VDOLV
+.
 You can discard data on a VDO LV and reduce used blocks on a VDOPoolLV.
 However, the current performance of discard operations is still not optimal
 and takes a considerable amount of time and CPU.
 Unless you really need it, you should avoid using discard.
-
+.P
 When a block device is going to be rewritten,
 its blocks will be automatically reused for new data.
 Discard is useful in situations when user knows that the given portion of a VDO LV
@@ -295,55 +329,59 @@ provisioning in other regions of the VDO LV.
 For the same reason, you should avoid using mkfs with discard for
 a freshly created VDO LV to save a lot of time that this operation would
 take otherwise as device is already expected to be empty.
-.SS 6. Memory usage
+.
+.SS \n+[step]. Memory usage
+.
 The VDO target requires 370 MiB of RAM plus an additional 268 MiB
 per each 1 TiB of physical storage managed by the volume.
-
+.P
 UDS requires a minimum of 250 MiB of RAM,
 which is also the default amount that deduplication uses.
-
+.P
 The memory required for the UDS index is determined by the index type
 and the required size of the deduplication window and
 is controlled by the \fBallocation/vdo_use_sparse_index\fP setting.
-
+.P
 With enabled UDS sparse indexing, it relies on the temporal locality of data
 and attempts to retain only the most relevant index entries in memory and
 can maintain a deduplication window that is ten times larger
 than with dense while using the same amount of memory.
-
+.P
 Although the sparse index provides the greatest coverage,
 the dense index provides more deduplication advice.
 For most workloads, given the same amount of memory,
 the difference in deduplication rates between dense
 and sparse indexes is negligible.
-
+.P
 A dense index with 1 GiB of RAM maintains a 1 TiB deduplication window,
 while a sparse index with 1 GiB of RAM maintains a 10 TiB deduplication window.
 In general, 1 GiB is sufficient for 4 TiB of physical space with
 a dense index and 40 TiB with a sparse index.
-.SS 7. Storage space requirements
+.
+.SS \n+[step]. Storage space requirements
+.
 You can configure a VDOPoolLV to use up to 256 TiB of physical storage.
 Only a certain part of the physical storage is usable to store data.
 This section provides the calculations to determine the usable size
 of a VDO-managed volume.
-
+.P
 The VDO target requires storage for two types of VDO metadata and for the UDS index:
-.TP
-\(bu
+.IP \(bu 2
 The first type of VDO metadata uses approximately 1 MiB for each 4 GiB
 of physical storage plus an additional 1 MiB per slab.
-.TP
-\(bu
+.IP \(bu
 The second type of VDO metadata consumes approximately 1.25 MiB
 for each 1 GiB of logical storage, rounded up to the nearest slab.
-.TP
-\(bu
+.IP \(bu
 The amount of storage required for the UDS index depends on the type of index
 and the amount of RAM allocated to the index. For each 1 GiB of RAM,
 a dense UDS index uses 17 GiB of storage and a sparse UDS index will use
 170 GiB of storage.
-
+.
 .SH SEE ALSO
+.
+.nh
+.ad l
 .BR lvm (8),
 .BR lvm.conf (5),
 .BR lvmconfig (8),
@@ -355,7 +393,9 @@ a dense UDS index uses 17 GiB of storage and a sparse UDS index will use
 .BR lvresize (8),
 .BR lvremove (8),
 .BR lvs (8),
+.P
 .BR vdo (8),
 .BR vdoformat (8),
 .BR vdostats (8),
+.P
 .BR mkfs (8)


