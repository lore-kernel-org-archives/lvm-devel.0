From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  1 Oct 2015 13:04:01 +0000 (UTC)
Subject: master - man: update lvm pages
Message-ID: <20151001130401.E78D560331@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=796e3fb7e4dc9d996316b0fcc4ed09a2cc800ade
Commit:        796e3fb7e4dc9d996316b0fcc4ed09a2cc800ade
Parent:        867a36b4197e2abe6efd3b16e229590eedc566a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 11:28:54 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 1 15:03:34 2015 +0200

man: update lvm pages

---
 man/clvmd.8.in    |  141 +++++++----
 man/lvchange.8.in |  344 ++++++++++++++++----------
 man/lvcreate.8.in |  418 ++++++++++++++++++------------
 man/lvm.8.in      |  734 +++++++++++++++++++++++++++++++++--------------------
 4 files changed, 1017 insertions(+), 620 deletions(-)

diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index 90de980..9b9310d 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -1,125 +1,159 @@
 .TH CLVMD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.
 .SH NAME
+.
 clvmd \(em cluster LVM daemon
+.
 .SH SYNOPSIS
+.
+.ad l
 .B clvmd
 .RB [ \-C ]
 .RB [ \-d
 .RI [ value ]]
 .RB [ \-E
-.IR "lock uuid" ]
+.IR lock_uuid ]
 .RB [ \-f ]
 .RB [ \-h ]
 .RB [ \-I
-.IR "cluster manager" ]
+.IR cluster_manager ]
 .RB [ \-R ]
 .RB [ \-S ]
 .RB [ \-t
 .IR timeout ]
 .RB [ \-T
-.IR "start timeout" ]
+.IR start_timeout ]
 .RB [ \-V ]
+.ad b
+.
 .SH DESCRIPTION
+.
 clvmd is the daemon that distributes LVM metadata updates around a cluster.
 It must be running on all nodes in the cluster and will give an error
 if a node in the cluster does not have this daemon running.
+.
 .SH OPTIONS
-.TP
-.BR \-d \ [ \fIvalue ]
+.
+.HP
+.BR \-C
+.br
+Only valid if \fB\-d\fP is also specified.
+Tells all clvmds in a cluster to enable/disable debug logging.
+Without this switch, only the local clvmd will change its debug level to that
+given with \fB\-d\fP.
+.br
+This does not work correctly if specified on the command-line that starts clvmd.
+If you want to start clvmd \fBand\fP
+enable cluster-wide logging then the command needs to be issued twice, eg:
+.br
+.BR clvmd
+.br
+.BR clvmd\ \-d2
+.
+.HP
+.BR \-d
+.RI [ value ]
+.br
 Set debug logging level.
 If \fB\-d\fP is specified without a \fIvalue\fP
 then 1 is assumed. \fIValue\fP can be:
 .PD 0
 .IP
-.B 0
+.BR 0
 \(em Disabled
 .IP
-.B 1
+.BR 1
 \(em Sends debug logs to stderr (implies \fB\-f\fP)
 .IP
-.B 2
+.BR 2
 \(em Sends debug logs to \fBsyslog\fP(3)
 .PD
-.TP
-.B \-C
-Only valid if
-.B \-d
-is also specified. Tells all clvmds in a cluster to enable/disable debug logging.
-Without this switch, only the local clvmd will change its debug level to that
-given with
-.B \-d
 .
+.HP
+.BR \-E
+.IR lock_uuid
 .br
-This does not work correctly if specified on the command-line that starts clvmd.
-If you want to start clvmd
-.B and
-enable cluster-wide logging then the command needs to be issued twice, eg:
-.br
-.B clvmd
-.br
-.B clvmd \-d2
+Pass lock uuid to be reacquired exclusively when clvmd is restarted.
+.
+.HP
+.BR \-f
 .br
-.TP
-.BR \-E "\fI lock uuid"
-Pass \fIlock uuid\fP to be reacquired exclusively when clvmd is restarted.
-.TP
-.B \-f
 Don't fork, run in the foreground.
-.TP
-.B \-h
+.
+.HP
+.BR \-h
+.br
 Show help information.
-.TP
-.BR \-I "\fI cluster manager"
-Selects the \fIcluster manager\fP to use for locking and internal
+.
+.HP
+.BR \-I
+.IR cluster_manager
+.br
+Selects the cluster manager to use for locking and internal
 communications. As it is quite possible to have multiple managers available on
 the same system you might have to manually specify this option to override the
 search.
 
-By default, omit \fB-I\fP is equivalent to \fB\-Iauto\fP. \fBClvmd\fP
-will use the first cluster manager that succeeds, and it checks them in a
-predefined order cman,corosync,openais.
+By default, omit \fB-I\fP is equivalent to \fB\-Iauto\fP.
+Clvmd will use the first cluster manager that succeeds,
+and it checks them in a predefined order
+.BR cman ,
+.BR corosync ,
+.BR openais .
 The available managers will be listed by order as part of the
 \fBclvmd \-h\fP output.
-.TP
-.B \-R
+.
+.HP
+.BR \-R
+.br
 Tells all the running instance of \fBclvmd\fP in the cluster to reload their device cache and
 re-read the lvm configuration file \fBlvm.conf\fP(5). This command should be run whenever the
 devices on a cluster system are changed.
-.TP
-.B \-S
+.
+.HP
+.BR \-S
+.br
 Tells the running \fBclvmd\fP to exit and reexecute itself, for example at the
 end of a package upgrade. The new instance is instructed to reacquire
 any locks in the same state as they were previously held. (Alternative
 methods of restarting the daemon have the side effect of changing
 exclusive LV locks into shared locks.)
-.TP
-.BR \-t "\fI timeout"
+.
+.HP
+.BR \-t
+.IR timeout
+.br
 Specifies the \fItimeout\fP for commands to run around the cluster. This should not
 be so small that commands with many disk updates to do will fail, so you
 may need to increase this on systems with very large disk farms.
 The default is 60 seconds.
-.TP
-.BR \-T "\fI start timeout"
-Specifies the \fIstart timeout\fP for \fBclvmd\fP daemon startup. If the
+.
+.HP
+.BR \-T
+.IR start_timeout
+.br
+Specifies the start timeout for \fBclvmd\fP daemon startup. If the
 daemon does not report that it has started up within this time then the parent
 command will exit with status of 5. This does NOT mean that \fBclvmd\fP has
 not started! What it means is that the startup has been delayed for some
 reason; the most likely cause of this is an inquorate cluster though it
 could be due to locking latencies on a cluster with large numbers of logical
 volumes. If you get the return code of 5 it is usually not necessary to
-restart \fBclvmd\fP ??? it will start as soon as that blockage has cleared.
+restart \fBclvmd\fP it will start as soon as that blockage has cleared.
 This flag is to allow startup scripts to exit in a timely fashion even if the
 cluster is stalled for some reason.
 
-The default is 0 (no timeout) and the value is in seconds. Don't set this too
+The default is \fB0\fP (no timeout) and the value is in seconds. Don't set this too
 small or you will experience spurious errors. 10 or 20 seconds might be
 sensible.
 
 This timeout will be ignored if you start \fBclvmd\fP with the \fB\-d\fP.
-.TP
-.B \-V
+.
+.HP
+.BR \-V
+.br
 Display the version of the cluster LVM daemon.
-
+.
 .SH ENVIRONMENT VARIABLES
 .TP
 .B LVM_CLVMD_BINARY
@@ -129,7 +163,10 @@ Defaults to \fI#CLVMD_PATH#\fP.
 .B LVM_BINARY
 The LVM2 binary to use.
 Defaults to \fI#LVM_PATH#\fP.
-
+.SH FILES
+.I #CLVMD_PATH#
+.br
+.I #LVM_PATH#
 .SH SEE ALSO
 .BR syslog (3),
 .BR lvm.conf (5),
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index e8babba..62bdca1 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -1,21 +1,30 @@
 .TH LVCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+
+.de UNITS
+..
+
+.
 .SH NAME
+.
 lvchange \(em change attributes of a logical volume
+.
 .SH SYNOPSIS
+.
+.ad l
 .B lvchange
-.RB [ \-\-addtag
-.IR Tag ]
-.RB [ \-A | \-\-autobackup
-.RB { y | n }]
 .RB [ \-a | \-\-activate
 .RB [ a ][ e | s | l ]{ y | n }]
 .RB [ \-\-activationmode
 .RB { complete | degraded | partial }]
+.RB [ \-\-addtag
+.IR Tag ]
+.RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-k | \-\-setactivationskip
 .RB { y | n }]
-.RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
+.RB [ \-A | \-\-autobackup
+.RB { y | n }]
 .RB [ \-\-cachepolicy
 .IR policy ]
 .RB [ \-\-cachesettings
@@ -33,13 +42,24 @@ lvchange \(em change attributes of a logical volume
 .RB { ignore | nopassdown | passdown }]
 .RB [ \-\-errorwhenfull
 .RB { y | n }]
-.RB [ \-\-resync ]
 .RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoremonitoring ]
-.RB [ \-\-ignoreskippedcluster ]
+.RB \%[ \-\-ignorelockingfailure ]
+.RB \%[ \-\-ignoremonitoring ]
+.RB \%[ \-\-ignoreskippedcluster ]
+.RB \%[ \-\-metadataprofile
+.IR ProfileName ]
 .RB [ \-\-monitor
 .RB { y | n }]
+.RB [ \-\-noudevsync ]
+.RB [ \-P | \-\-partial ]
+.RB [ \-p | \-\-permission
+.RB { r | rw }]
+.RB [ \-M | \-\-persistent
+.RB { y | n }
+.RB [ \-\-major
+.IR major ]
+.RB [ \-\-minor
+.IR minor ]]
 .RB [ \-\-poll
 .RB { y | n }]
 .RB [ \-\- [ raid ] maxrecoveryrate
@@ -52,41 +72,38 @@ lvchange \(em change attributes of a logical volume
 .IR IOCount ]
 .RB [ \-\- [ raid ] writemostly
 .BR \fIPhysicalVolume [ : { y | n | t }]]
-.RB [ \-\-sysinit ]
-.RB [ \-\-noudevsync ]
-.RB [ \-\-metadataprofile
-.IR ProfileName ]
-.RB [ \-M | \-\-persistent
-.RB { y | n }
-.RB [ \-\-minor
-.IR minor ]
-.RB [ \-\-major
-.IR major ]]
-.RB [ \-P | \-\-partial ]
-.RB [ \-p | \-\-permission
-.RB { r | rw }]
 .RB [ \-r | \-\-readahead
 .RB { \fIReadAheadSectors | auto | none }]
 .RB [ \-\-refresh ]
+.RB [ \-\-resync ]
 .RB [ \-S | \-\-select
 .IR Selection ]
+.RB [ \-\-sysinit ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-Z | \-\-zero
 .RB { y | n }]
 .RI [ LogicalVolumePath ...]
+.ad b
+.
 .SH DESCRIPTION
+.
 lvchange allows you to change the attributes of a logical volume
 including making them known to the kernel ready for use.
+.
 .SH OPTIONS
+.
 See \fBlvm\fP(8) for common options.
-.TP
-.BR \-a ", " \-\-activate " [" a ][ e | s | l ]{ y | n }
+.
+.HP
+.BR \-a | \-\-activate
+.RB [ a ][ e | s | l ]{ y | n }
+.br
 Controls the availability of the logical volumes for use.
 Communicates with the kernel device-mapper driver via
 libdevmapper to activate (\fB\-ay\fP) or deactivate (\fB\-an\fP) the
 logical volumes.
-.IP
+.br
 Activation of a logical volume creates a symbolic link
 \fI/dev/VolumeGroupName/LogicalVolumeName\fP pointing to the device node.
 This link is removed on deactivation.
@@ -95,19 +112,16 @@ this symbolic link and present this as the name of the device.
 The location and name of the underlying device node may depend on
 the distribution and configuration (e.g. udev) and might change
 from release to release.
-.IP
+.br
 If autoactivation option is used (\fB\-aay\fP),
 the logical volume is activated only if it matches an item in
-the
-.B activation/auto_activation_volume_list
+the \fBactivation/auto_activation_volume_list\fP
 set in \fBlvm.conf\fP(5).
 If this list is not set, then all volumes are considered for
 activation. The \fB\-aay\fP option should be also used during system
 boot so it's possible to select which volumes to activate using
-the 
-.B activation/auto_activation_volume_list
-setting.
-.IP
+the \fBactivation/auto_activation_volume_list\fP setting.
+.br
 In a clustered VG, clvmd is used for activation, and the
 following options are possible:
 
@@ -137,9 +151,11 @@ LVs with snapshots are always activated exclusively because they can only
 be used on one node at once.
 
 For local VGs \fB\-ay\fP, \fB\-aey\fP, and \fB\-asy\fP are all equivalent.
-
-.TP
-.BR \-\-activationmode " {" complete | degraded | partial }
+.
+.HP
+.BR \-\-activationmode
+.RB { complete | degraded | partial }
+.br
 The activation mode determines whether logical volumes are allowed to
 activate when there are physical volumes missing (e.g. due to a device
 failure).  \fBcomplete\fP is the most restrictive; allowing only those
@@ -150,106 +166,168 @@ considered a RAID logical volume.  The "\fIraid1\fP" segment type should
 be used instead.)  Finally, \fBpartial\fP allows any logical volume to
 be activated even if portions are missing due to a missing or failed
 PV.  This last option should only be used when performing recovery or
-repair operations.  \fBdegraded\fP is the default mode.  To change it, modify
-.B activation_mode
-in
-.BR lvm.conf (5).
-.TP
-.BR \-k ", " \-\-setactivationskip " {" y | n }
+repair operations.  \fBdegraded\fP is the default mode.  To change it,
+modify \fBactivation_mode\fP in \fBlvm.conf\fP(5).
+.
+.HP
+.BR \-K | \-\-ignoreactivationskip
+.br
+Ignore the flag to skip Logical Volumes during activation.
+.
+.HP
+.BR \-k | \-\-setactivationskip
+.RB { y | n }
+.br
 Controls  whether Logical Volumes are persistently flagged to be
 skipped during activation. By default, thin snapshot volumes are
 flagged for activation skip.  To activate such volumes,
-an extra
-.BR \-K / \-\-ignoreactivationskip
-option must be used.
+an extra \fB\-\-ignoreactivationskip\fP option must be used.
 The flag is not applied during deactivation. To see whether
 the flag is attached, use \fBlvs\fP(8) command where the state
 of the flag is reported within \fBlv_attr\fP bits.
-.TP
-.BR \-K ", " \-\-ignoreactivationskip
-Ignore the flag to skip Logical Volumes during activation.
-.TP
-.BR  \-\-cachepolicy " " \fIpolicy ", " \-\-cachesettings " " \fIkey = \fIvalue
+.
+.HP
+.BR  \-\-cachepolicy
+.IR policy ,
+.BR \-\-cachesettings
+.IR key \fB= value
+.br
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
 the cache policy and its associated tunable settings. In most use-cases,
 default values should be adequate.
-.TP
-.BR \-C ", " \-\-contiguous " {" y | n }
+.
+.HP
+.BR \-C | \-\-contiguous
+.RB { y | n }
+.br
 Tries to set or reset the contiguous allocation policy for
 logical volumes. It's only possible to change a non-contiguous
 logical volume's allocation policy to contiguous, if all of the
 allocated physical extents are already contiguous.
-.TP
+.
+.HP
 .BR \-\-detachprofile
+.br
 Detach any metadata configuration profiles attached to given
 Logical Volumes. See \fBlvm.conf\fP(5) for more information
 about metadata profiles.
-.TP
-.BR \-\-discards " {" ignore | nopassdown | passdown }
+.
+.HP
+.BR \-\-discards
+.RB { ignore | nopassdown | passdown }
+.br
 Set this to \fBignore\fP to ignore any discards received by a
 thin pool Logical Volume.  Set to \fBnopassdown\fP to process such
 discards within the thin pool itself and allow the no-longer-needed
 extents to be overwritten by new data.  Set to \fBpassdown\fP (the
 default) to process them both within the thin pool itself and to
 pass them down the underlying device.
-.TP
-.BR \-\-errorwhenfull " {" y | n }
+.
+.HP
+.BR \-\-errorwhenfull
+.RB { y | n }
+.br
 Sets thin pool behavior when data space is exhaused. See
 .BR lvcreate (8)
 for information.
-.TP
-.B \-\-resync
-Forces the complete resynchronization of a mirror.  In normal
-circumstances you should not need this option because synchronization
-happens automatically.  Data is read from the primary mirror device
-and copied to the others, so this can take a considerable amount of
-time - and during this time you are without a complete redundant copy
-of your data.
-.TP
-.B \-\-metadataprofile " " \fIProfileName
+.
+.HP
+.BR \-\-ignoremonitoring
+.br
+Make no attempt to interact with dmeventd unless \fB\-\-monitor\fP
+is specified.
+Do not use this if dmeventd is already monitoring a device.
+.
+.HP
+.BR \-\-major
+.IR major
+.br
+Sets the major number. This option is supported only on older systems
+(kernel version 2.4) and is ignored on modern Linux systems where major
+numbers are dynamically assigned.
+.
+.HP
+.BR \-\-minor
+.IR minor
+.br
+Set the minor number.
+.
+.HP
+.BR \-\-metadataprofile
+.IR ProfileName
+.br
 Uses and attaches \fIProfileName\fP configuration profile to the logical
 volume metadata. Whenever the logical volume is processed next time,
 the profile is automatically applied. If the volume group has another
 profile attached, the logical volume profile is preferred.
 See \fBlvm.conf\fP(5) for more information about metadata profiles.
-.TP
-.B \-\-minor \fIminor
-Set the minor number.
-.TP
-.B \-\-major \fImajor
-Sets the major number. This option is supported only on older systems
-(kernel version 2.4) and is ignored on modern Linux systems where major
-numbers are dynamically assigned.
-.TP
-.BR \-\-monitor " {" y | n }
+.
+.HP
+.BR \-\-monitor
+.RB { y | n }
+.br
 Start or stop monitoring a mirrored or snapshot logical volume with
 dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
 the failure is handled according to
-\fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
+\%\fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
 set in \fBlvm.conf\fP(5).
-.TP
-.BR \-\-poll " {" y | n }
+.
+.HP
+.BR \-\-noudevsync
+.br
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.
+.HP
+.BR \-p | \-\-permission
+.RB { r | rw }
+.br
+Change access permission to read-only or read/write.
+.
+.HP
+.BR \-M | \-\-persistent
+.RB { y | n }
+.br
+Set to \fBy\fP to make the minor number specified persistent.
+Change of persistent numbers is not supported for pool volumes.
+.
+.HP
+.BR \-\-poll
+.RB { y | n }
+.br
 Without polling a logical volume's backgrounded transformation process
 will never complete.  If there is an incomplete pvmove or lvconvert (for
 example, on rebooting after a crash), use \fB\-\-poll y\fP to restart the
 process from its last checkpoint.  However, it may not be appropriate to
 immediately poll a logical volume when it is activated, use
 \fB\-\-poll n\fP to defer and then \fB\-\-poll y\fP to restart the process.
-.TP
-.BR \-\- [ raid ] maxrecoveryrate " " \fIRate [ bBsSkKmMgG ]
+.
+.HP
+.BR \-\- [ raid ] maxrecoveryrate
+.BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
+.br
 Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
 If no suffix is given, then KiB/sec/device is assumed.  Setting the
 recovery rate to \fB0\fP means it will be unbounded.
-.TP
-.BR \-\- [ raid ] minrecoveryrate " " \fIRate [ bBsSkKmMgG ]
+.
+.HP
+.BR \-\- [ raid ] minrecoveryrate
+.BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
+.br
 Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
 If no suffix is given, then KiB/sec/device is assumed.  Setting the
 recovery rate to \fB0\fP means it will be unbounded.
-.TP
-.BR \-\- [ raid ] syncaction " {" check | repair }
+.
+.HP
+.BR \-\- [ raid ] syncaction
+.RB { check | repair }
+.br
 This argument is used to initiate various RAID synchronization operations.
 The \fBcheck\fP and \fBrepair\fP options provide a way to check the
 integrity of a RAID logical volume (often referred to as "scrubbing").
@@ -260,16 +338,22 @@ If \fBcheck\fP is used, the discrepancies will be counted but not repaired.
 If \fBrepair\fP is used, the discrepancies will be corrected as they are
 encountered.  The \fBlvs\fP(8) command can be used to show the number of
 discrepancies found or repaired.
-.TP
-.BR \-\- [ raid ] writebehind " " \fIIOCount
+.
+.HP
+.BR \-\- [ raid ] writebehind
+.IR IOCount
+.br
 Specify the maximum number of outstanding writes that are allowed to
 devices in a RAID1 logical volume that are marked as write-mostly.
 Once this value is exceeded, writes become synchronous (i.e. all writes
 to the constituent devices must complete before the array signals the
 write has completed).  Setting the value to zero clears the preference
 and allows the system to choose the value arbitrarily.
-.TP
-.BR \-\- [ raid ] writemostly " " \fIPhysicalVolume [ : { y | n | t }]
+.
+.HP
+.BR \-\- [ raid ] writemostly
+.BR \fIPhysicalVolume [ : { y | n | t }]
+.br
 Mark a device in a RAID1 logical volume as write-mostly.  All reads
 to these drives will be avoided unless absolutely necessary.  This keeps
 the number of I/Os to the drive to a minimum.  The default behavior is to
@@ -279,8 +363,39 @@ appending a "\fB:n\fP" to the physical volume or to toggle the value by specifyi
 "\fB:t\fP".  The \fB\-\-writemostly\fP argument can be specified more than one time
 in a single command; making it possible to toggle the write-mostly attributes
 for all the physical volumes in a logical volume at once.
-.TP
-.B \-\-sysinit
+.
+.HP
+.BR \-r | \-\-readahead
+.RB { \fIReadAheadSectors | auto | none }
+.br
+Set read ahead sector count of this logical volume.
+For volume groups with metadata in lvm1 format, this must
+be a value between 2 and 120 sectors.
+The default value is "\fBauto\fP" which allows the kernel to choose
+a suitable value automatically.
+"\fBnone\fP" is equivalent to specifying zero.
+.
+.HP
+.BR \-\-refresh
+.br
+If the logical volume is active, reload its metadata.
+This is not necessary in normal operation, but may be useful
+if something has gone wrong or if you're doing clustering
+manually without a clustered lock manager.
+.
+.HP
+.BR \-\-resync
+.br
+Forces the complete resynchronization of a mirror.  In normal
+circumstances you should not need this option because synchronization
+happens automatically.  Data is read from the primary mirror device
+and copied to the others, so this can take a considerable amount of
+time - and during this time you are without a complete redundant copy
+of your data.
+.
+.HP
+.BR \-\-sysinit
+.br
 Indicates that \fBlvchange\fP(8) is being invoked from early system
 initialisation scripts (e.g. rc.sysinit or an initrd),
 before writeable filesystems are available. As such,
@@ -295,51 +410,24 @@ If \fB\-\-sysinit\fP is used in conjunction with
 \fBlvmetad\fP(8) enabled and running,
 autoactivation is preferred over manual activation via direct lvchange call.
 Logical volumes are autoactivated according to
-.B auto_activation_volume_list
-set in \fBlvm.conf\fP(5).
-.TP
-.B \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.TP
-.B \-\-ignoremonitoring
-Make no attempt to interact with dmeventd unless \fB\-\-monitor\fP
-is specified.
-Do not use this if dmeventd is already monitoring a device.
-.TP
-.BR \-M ", " \-\-persistent " {" y | n }
-Set to \fBy\fP to make the minor number specified persistent.
-Change of persistent numbers is not supported for pool volumes.
-.TP
-.BR \-p ", " \-\-permission " {" r | rw }
-Change access permission to read-only or read/write.
-.TP
-.BR \-r ", " \-\-readahead " {" \fIReadAheadSectors | auto | none }
-Set read ahead sector count of this logical volume.
-For volume groups with metadata in lvm1 format, this must
-be a value between 2 and 120 sectors.
-The default value is "\fBauto\fP" which allows the kernel to choose
-a suitable value automatically.
-"\fBnone\fP" is equivalent to specifying zero.
-.TP
-.B \-\-refresh
-If the logical volume is active, reload its metadata.
-This is not necessary in normal operation, but may be useful
-if something has gone wrong or if you're doing clustering
-manually without a clustered lock manager.
-.TP
-.BR \-Z ", " \-\-zero " {" y | n }
+\fB auto_activation_volume_list\fP set in \fBlvm.conf\fP(5).
+.
+.HP
+.BR \-Z | \-\-zero
+.RB { y | n }
+.br
 Set zeroing mode for thin pool. Note: already provisioned blocks from pool
 in non-zero mode are not cleared in unwritten parts when setting zero to
 \fBy\fP.
+.
 .SH ENVIRONMENT VARIABLES
+.
 .TP
 .B LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES
 Suppress locking failure messages.
+.
 .SH Examples
+.
 Changes the permission on volume lvol1 in volume group vg00 to be read-only:
 .sp
 .B lvchange \-pr vg00/lvol1
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index ee10392..8a364c4 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -2,40 +2,41 @@
 .SH NAME
 lvcreate \- create a logical volume in an existing volume group
 .SH SYNOPSIS
+.ad l
 .B lvcreate
 .RB [ \-a | \-\-activate
-.RI [ a | e | l ]{ y | n }]
+.RB [ a ][ e | l | s ]{ y | n }]
 .RB [ \-\-addtag
 .IR Tag ]
 .RB [ \-\-alloc
-.IR AllocationPolicy ]
+.IR Allocation\%Policy ]
 .RB [ \-A | \-\-autobackup
-.RI { y | n }]
+.RB { y | n }]
 .RB [ \-H | \-\-cache ]
 .RB [ \-\-cachemode
-.RI { passthrough | writeback | writethrough }]
+.RB { passthrough | writeback | writethrough }]
 .RB [ \-\-cachepolicy
 .IR policy ]
 .RB [ \-\-cachepool
-.IR CachePoolLogicalVolume { Name | Path }
+.IR CachePoolLogicalVolume ]
 .RB [ \-\-cachesettings
-.IR key=value ]
+.IR key \fB= value ]
 .RB [ \-c | \-\-chunksize
-.IR ChunkSize [ bBsSkKmMgG ]]
+.IR ChunkSize ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-C | \-\-contiguous
-.RI { y | n }]
+.RB { y | n }]
 .RB [ \-d | \-\-debug ]
 .RB [ \-\-discards
-.RI { ignore | nopassdown | passdown }]
+.RB \%{ ignore | nopassdown | passdown }]
 .RB [ \-\-errorwhenfull
-.RI { y | n }]
+.RB { y | n }]
 .RB [{ \-l | \-\-extents
-.IR LogicalExtentsNumber [ % { FREE | PVS | VG }]
-|
+.BR \fILogicalExtents\%Number [ % { FREE | PVS | VG }]
+.RB |
 .BR \-L | \-\-size
-.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
+.BR \fILogicalVolumeSize }
 .RB [ \-i | \-\-stripes
 .IR Stripes
 .RB [ \-I | \-\-stripesize
@@ -48,86 +49,79 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-j | \-\-major
 .IR major ]]
 .RB [ \-\-metadataprofile
-.IR ProfileName ]
+.IR Profile\%Name ]
 .RB [ \-m | \-\-mirrors
 .IR Mirrors
-.RB [{ \-\-corelog
-|
-.B \-\-mirrorlog
-.RI { disk | core | mirrored }}]
+.RB [ \-\-corelog | \-\-mirrorlog
+.RB { disk | core | mirrored }]
 .RB [ \-\-nosync ]
 .RB [ \-R | \-\-regionsize
-.IR MirrorLogRegionSize [ bBsSkKmMgG ]]]
+.BR \fIMirrorLogRegionSize ]]
 .RB [ \-\-monitor
-.RI { y | n }]
+.RB { y | n }]
 .RB [ \-n | \-\-name
-.IR LogicalVolume { Name | Path }]
+.IR Logical\%Volume ]
 .RB [ \-\-noudevsync ]
 .RB [ \-p | \-\-permission
-.RI { r | rw }]
+.RB { r | rw }]
 .RB [ \-M | \-\-persistent
-.RI { y | n }]
+.RB { y | n }]
 .\" .RB [ \-\-pooldatasize
-.\" .IR DataVolumeSize [ bBsSkKmMgGtTpPeE ]]
-.RB [ \-\-poolmetadatasize
-.IR MetadataVolumeSize [ bBsSkKmMgG ]]
+.\" .I DataVolumeSize
+.RB \%[ \-\-poolmetadatasize
+.IR MetadataVolumeSize ]
 .RB [ \-\-poolmetadataspare
-.RI { y | n }]
+.RB { y | n }]
 .RB [ \-\- [ raid ] maxrecoveryrate
 .IR Rate ]
 .RB [ \-\- [ raid ] minrecoveryrate
 .IR Rate ]
 .RB [ \-r | \-\-readahead
-.RI { ReadAheadSectors | auto | none }]
+.RB { \fIReadAheadSectors | auto | none }]
 .RB [ \-k | \-\-setactivationskip
-.RI { y | n }]
-.RB [ \-s | \-\-snapshot
+.RB { y | n }]
+.RB [ \-s | \-\-snapshot ]
 .RB [ \-V | \-\-virtualsize
-.IR VirtualSize [ bBsSkKmMgGtTpPeE ]]
+.IR VirtualSize ]
 .RB [ \-t | \-\-test ]
 .RB [ \-T | \-\-thin ]
 .RB [ \-\-thinpool
-.IR ThinPoolLogicalVolume { Name | Path }]
+.IR ThinPoolLogicalVolume ]
 .RB [ \-\-type
 .IR SegmentType ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-W | \-\-wipesignatures
-.RI { y | n }]
+.RB { y | n }]
 .RB [ \-Z | \-\-zero
-.RI { y | n }]
-.RI [ VolumeGroup { Name | Path }
-.RI [/\{ ExternalOrigin
-|
-.I Origin
-|
+.RB { y | n }]
+.RI [ VolumeGroup [ \fB/ { ExternalOrigin |\: Origin |
 .IR Pool } LogicalVolumeName ]
-.RI [ PhysicalVolumePath [ :PE [ \-PE ]]...]
-
+.RI [ PhysicalVolumePath [ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.LP
 .B lvcreate
 .RB [ \-l | \-\-extents
-.IR LogicalExtentsNumber [ % { FREE | ORIGIN | PVS | VG }]
+.BR \fILogicalExtentsNumber [ % { FREE | ORIGIN | PVS | VG }]
 |
 .BR \-L | \-\-size
 .\" | \-\-pooldatasize
-.IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
+.IR LogicalVolumeSize ]
 .RB [ \-c | \-\-chunksize
-.IR ChunkSize [ bBsSkKmMgG ]]
+.IR ChunkSize ]
 .RB [ \-\-commandprofile
-.IR Profilename ]
+.IR Profile\%Name ]
 .RB [ \-\-noudevsync ]
 .RB [ \-\-ignoremonitoring ]
-.RB [ \-\-metadataProfile
-.IR ProfileName ]
-.RB [ \-\-monitor
-.RI { y | n }]
+.RB [ \-\-metadataprofile
+.IR Profile\%Name ]
+.RB \%[ \-\-monitor
+.RB { y | n }]
 .RB [ \-n | \-\-name
-.IR SnapshotLogicalVolume { Name | Path }]
+.IR SnapshotLogicalVolume ]
 .BR \-s | \-\-snapshot | \-H | \-\-cache
-.RI {[ VolumeGroup { Name | Path }/] OriginalLogicalVolumeName
+.RI \%{[ VolumeGroup \fB/ ] OriginalLogicalVolume
 .BR \-V | \-\-virtualsize
-.IR VirtualSize [ bBsSkKmMgGtTpPeE ]}
-.br
-
+.IR VirtualSize }
+.ad b
 .SH DESCRIPTION
 lvcreate creates a new logical volume in a volume group (see
 .BR vgcreate "(8), " vgchange (8))
@@ -144,12 +138,17 @@ extents will be restricted to these volumes.
 .br
 The second form supports the creation of snapshot logical volumes which
 keep the contents of the original logical volume for backup purposes.
+.
 .SH OPTIONS
+.
 See
 .BR lvm (8)
 for common options.
-.TP
-.IR \fB\-a ", " \fB\-\-activate " {" y | ay | n | ey | en | ly | ln }
+.
+.HP
+.BR \-a | \-\-activate
+.RB [ a ][ l | e | s ]{ y | n }
+.br
 Controls the availability of the Logical Volumes for immediate use after
 the command finishes running.
 By default, new Logical Volumes are activated (\fB\-a\fIy\fR).
@@ -171,8 +170,10 @@ be overridden. If the clustered locking is enabled,
 \fB\-a\fIey\fR will activate exclusively on one node and
 .IR \fB\-a { a | l } y
 will activate only on the local node.
-.TP
-.IR \fB\-H ", " \fB\-\-cache
+.
+.HP
+.BR \-H | \-\-cache
+.br
 Creates cache or cache pool logical volume or both.
 Specifying the optional argument \fB\-\-size\fP will cause the creation of
 the cache logical volume.
@@ -187,33 +188,49 @@ the \fB\-\-size\fP is used to specify size of cache pool volume.
 See \fBlvmcache\fP(7) for more info about caching support.
 Note that the cache segment type requires a dm-cache kernel module version
 1.3.0 or greater.
-.TP
-.IR \fB\-\-cachemode " {" passthrough | writeback | writethrough }
+.
+.HP
+.BR \-\-cachemode
+.RB { passthrough | writeback | writethrough }
+.br
 Specifying a cache mode determines when the writes to a cache LV
-are considered complete.  When \fIwriteback\fP is specified, a write is
+are considered complete.  When \fBwriteback\fP is specified, a write is
 considered complete as soon as it is stored in the cache pool LV.
-If \fIwritethough\fP is specified, a write is considered complete only
+If \fBwritethough\fP is specified, a write is considered complete only
 when it has been stored in the cache pool LV and on the origin LV.
-While \fIwritethrough\fP may be slower for writes, it is more
+While \fBwritethrough\fP may be slower for writes, it is more
 resilient if something should happen to a device associated with the
 cache pool LV.
-.TP
-.B \-\-cachepolicy \fIpolicy
+.
+.HP
+.BR \-\-cachepolicy
+.IR policy
+.br
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
-the cache policy. \fImq\fP is the basic policy name. \fIsmq\fP is more advanced
+the cache policy. \fBmq\fP is the basic policy name. \fBsmq\fP is more advanced
 version available in newer kernels.
-.TP
-.IR \fB\-\-cachepool " " CachePoolLogicalVolume { Name | Path }
+.
+.HP
+.BR \-\-cachepool
+.IR CachePoolLogicalVolume { Name | Path }
+.br
 Specifies the name of cache pool volume name. The other way to specify pool name
 is to append name to Volume group name argument.
-.TP
-.BR \-\-cachesettings " " \fIkey=value
+.
+.HP
+.BR \-\-cachesettings
+.IB key = value
+.br
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
 the cache tunable settings. In most use-cases, default values should be adequate.
-Special string value \fIdefault\fP switches setting back to its default kernel value
+Special string value \fBdefault\fP switches setting back to its default kernel value
 and removes it from the list of settings stored in lvm2 metadata.
-.TP
-.BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
+.
+.HP
+.BR \-c | \-\-chunksize
+.IR ChunkSize \c
+.RB [ b | B | s | S | k | K | m | M | g | G ]
+.br
 Gives the size of chunk for snapshot, cache pool and thin pool logical volumes.
 Default unit is in kilobytes.
 .br
@@ -230,79 +247,108 @@ fit the pool metadata size within 128MiB,
 if the pool metadata size is not specified.
 See
 .BR lvm.conf (5)
-setting
-.IR allocation / thin_pool_chunk_size_policy
+setting \fBallocation/thin_pool_chunk_size_policy\fP
 to select different calculation policy.
 Thin pool target version <1.4 requires this value to be a power of 2.
 For target version <1.5 discard is not supported for non power of 2 values.
-.TP
-.BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
+.
+.HP
+.BR \-C | \-\-contiguous
+.RB { y | n }
+.br
 Sets or resets the contiguous allocation policy for
 logical volumes. Default is no contiguous allocation based
 on a next free principle.
-.TP
+.
+.HP
 .BR \-\-corelog
-This is shortcut for option \fB\-\-mirrorlog\fP \fIcore\fP.
-.TP
-.BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
+.br
+This is shortcut for option \fB\-\-mirrorlog core\fP.
+.
+.HP
+.BR \-\-discards
+.RB { ignore | nopassdown | passdown }
+.br
 Sets discards behavior for thin pool.
-Default is \fIpassdown\fP.
-.TP
-.BR \-\-errorwhenfull " {" \fIy |\fIn }
+Default is \fBpassdown\fP.
+.
+.HP
+.BR \-\-errorwhenfull
+.RB { y | n }
+.br
 Configures thin pool behaviour when data space is exhausted.
-Default is \fIn\fPo.
+Default is \fBn\fPo.
 Device will queue I/O operations until target timeout
 (see dm-thin-pool kernel module option \fIno_space_timeout\fP)
 expires. Thus configured system has a time to i.e. extend
 the size of thin pool data device.
-When set to \fIy\fPes, the I/O operation is immeditelly errored.
-.TP
-.BR \-K ", " \-\-ignoreactivationskip
+When set to \fBy\fPes, the I/O operation is immeditelly errored.
+.
+.HP
+.BR \-K | \-\-ignoreactivationskip
+.br
 Ignore the flag to skip Logical Volumes during activation.
 Use \fB\-\-setactivationskip\fP option to set or reset
 activation skipping flag persistently for logical volume.
-.TP
-.B \-\-ignoremonitoring
+.
+.HP
+.BR \-\-ignoremonitoring
+.br
 Make no attempt to interact with dmeventd unless \fB\-\-monitor\fP
 is specified.
-.TP
-.IR \fB\-l ", " \fB\-\-extents " " LogicalExtentsNumber [ % { VG | PVS | FREE | ORIGIN }]
+.
+.HP
+.BR -l | \-\-extents
+.IR LogicalExtentsNumber \c
+.RB [ % { VG | PVS | FREE | ORIGIN }]
+.br
 Gives the number of logical extents to allocate for the new
 logical volume.  The total number of physical extents allocated will be
 greater than this, for example, if the volume is mirrored.
 The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix \fI%VG\fR, as a percentage of the
-remaining free space in the Volume Group with the suffix \fI%FREE\fR, as a
+in the Volume Group with the suffix \fB%VG\fP, as a percentage of the
+remaining free space in the Volume Group with the suffix \fB%FREE\fP, as a
 percentage of the remaining free space for the specified
-PhysicalVolume(s) with the suffix \fI%PVS\fR, or (for a snapshot) as a
+PhysicalVolume(s) with the suffix \fB%PVS\fP, or (for a snapshot) as a
 percentage of the total space in the Origin Logical Volume with the
-suffix \fI%ORIGIN\fR (i.e. \fI100%ORIGIN\fR provides space for the whole origin).
+suffix \fB%ORIGIN\fP (i.e. \fB100%ORIGIN\fP provides space for the whole origin).
 When expressed as a percentage, the number is treated
 as an approximate upper limit for the total number of physical extents
 to be allocated (including extents used by any mirrors, for example).
-.TP
-.BR \-j ", " \-\-major " " \fImajor
+.
+.HP
+.BR \-j | \-\-major
+.IR major
+.br
 Sets the major number.
 Major numbers are not supported with pool volumes.
 This option is supported only on older systems
 (kernel version 2.4) and is ignored on modern Linux systems where major
 numbers are dynamically assigned.
-.TP
-.BR \-\-metadataprofile " " \fIProfileName
+.
+.HP
+.BR \-\-metadataprofile
+.IR ProfileName
+.br
 Uses and attaches the ProfileName configuration profile to the logical
 volume metadata. Whenever the logical volume is processed next time,
 the profile is automatically applied. If the volume group has another
 profile attached, the logical volume profile is preferred.
 See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
-.TP
-.B \-\-minor \fIminor
+.
+.HP
+.BR \-\-minor
+.IR minor
+.br
 Sets the minor number.
 Minor numbers are not supported with pool volumes.
-.TP
-.BR \-m ", " \-\-mirrors " " \fIMirrors
-Creates a mirrored logical volume with \fIMirrors\fP copies.
-For example, specifying
-.BI \-m\  1
+.
+.HP
+.BR \-m | \-\-mirrors
+.IR mirrors
+.br
+Creates a mirrored logical volume with \fImirrors\fP copies.
+For example, specifying \fB\-m 1\fP
 would result in a mirror with two-sides; that is,
 a linear volume plus one copy.
 
@@ -318,131 +364,173 @@ The default is "\fIraid1\fP".  See the
 \fB\-\-type\fP option for more information if you would like to use the
 legacy "\fImirror\fP" segment type.  See
 .BR lvm.conf (5)
-settings
-.IR global / mirror_segtype_default
-and
-.IR global / raid10_segtype_default
+settings \fB global/mirror_segtype_default\fP
+and \fBglobal/raid10_segtype_default\fP
 to configure default mirror segment type.
 The options
 \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP apply
 to the legacy "\fImirror\fP" segment type only.
-.TP
-.BR \-\-mirrorlog " {" \fIdisk | \fIcore | \fImirrored }
+.
+.HP
+.BR \-\-mirrorlog
+.RB { disk | core | mirrored }
+.br
 Specifies the type of log to be used for logical volumes utilizing
 the legacy "\fImirror\fP" segment type.
 .br
-The default is \fIdisk\fP, which is persistent and requires
+The default is \fBdisk\fP, which is persistent and requires
 a small amount of storage space, usually on a separate device from the
 data being mirrored.
 .br
-Using \fIcore\fP means the mirror is regenerated by copying the data
+Using \fBcore\fP means the mirror is regenerated by copying the data
 from the first device each time the logical volume is activated,
 like after every reboot.
 .br
-Using \fImirrored\fP will create a persistent log that is itself mirrored.
-.TP
-.BR \-\-monitor " {" \fIy | \fIn }
+Using \fBmirrored\fP will create a persistent log that is itself mirrored.
+.
+.HP
+.BR \-\-monitor
+.RB { y | n }
+.br
 Starts or avoids monitoring a mirrored, snapshot or thin pool logical volume with
 dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
 the failure is handled according to
-.IR activation / mirror_image_fault_policy
-and
-.IR activation / mirror_log_fault_policy
+\fBactivation/mirror_image_fault_policy\fP
+and \fBactivation/mirror_log_fault_policy\fP
 set in \fBlvm.conf\fP(5).
-.TP
-.IR \fB\-n ", " \fB\-\-name " " LogicalVolume { Name | Path }
+.
+.HP
+.BR \-n | \-\-name
+.IR LogicalVolume { Name | Path }
+.br
 Sets the name for the new logical volume.
 .br
 Without this option a default name of "lvol#" will be generated where
 # is the LVM internal number of the logical volume.
-.TP
-.B \-\-nosync
+.
+.HP
+.BR \-\-nosync
+.br
 Causes the creation of the mirror to skip the initial resynchronization.
-.TP
-.B \-\-noudevsync
+.
+.HP
+.BR \-\-noudevsync
+.br
 Disables udev synchronisation. The
 process will not wait for notification from udev.
 It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
-.TP
-.BR \-p ", " \-\-permission " {" \fIr | \fIrw }
-Sets access permissions to read only (\fIr\fP) or read and write (\fIrw\fP).
+.
+.HP
+.BR \-p | \-\-permission
+.RB { r | rw }
+.br
+Sets access permissions to read only (\fBr\fP) or read and write (\fBrw\fP).
 .br
 Default is read and write.
-.TP
-.BR \-M ", " \-\-persistent " {" \fIy | \fIn }
-Set to \fIy\fP to make the minor number specified persistent.
+.
+.HP
+.BR \-M | \-\-persistent
+.RB { y | n }
+.br
+Set to \fBy\fP to make the minor number specified persistent.
 Pool volumes cannot have persistent major and minor numbers.
-Defaults to \fIy\fPes only when major or minor number is specified.
-Otherwise it is \fIn\fPo.
-.TP
+Defaults to \fBy\fPes only when major or minor number is specified.
+Otherwise it is \fBn\fPo.
+.\" .HP
 .\" .IR \fB\-\-pooldatasize " " PoolDataVolumeSize [ bBsSkKmMgGtTpPeE ]
 .\" Sets the size of pool's data logical volume.
 .\" For thin pools you may also specify the size
 .\" with the option \fB\-\-size\fP.
-.\" .TP
-.IR \fB\-\-poolmetadatasize " " MetadataVolumeSize [ bBsSkKmMgG ]
+.\"
+.
+.HP
+.BR \-\-poolmetadatasize
+.BR \fIMetadataVolumeSize [ b | B | s | S | k | K | m | M | g | G ]
+.br
 Sets the size of pool's metadata logical volume.
 Supported values are in range between 2MiB and 16GiB for thin pool,
 and upto 16GiB for cache pool. The minimum value is computed from pool's
 data size.
 Default value for thin pool is (Pool_LV_size / Pool_LV_chunk_size * 64b).
 Default unit is megabytes.
-.TP
-.IR \fB\-\-poolmetadataspare " {"  y | n }
+.
+.HP
+.BR \-\-poolmetadataspare
+.RB { y | n }
+.br
 Controls creation and maintanence of pool metadata spare logical volume
 that will be used for automated pool recovery.
 Only one such volume is maintained within a volume group
 with the size of the biggest pool metadata volume.
-Default is \fIy\fPes.
-.TP
-.BR \-\- [ raid ] maxrecoveryrate " " \fIRate [ \fIbBsSkKmMgG ]
+Default is \fBy\fPes.
+.
+.HP
+.BR \-\- [ raid ] maxrecoveryrate
+.BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
+.br
 Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
 If no suffix is given, then KiB/sec/device is assumed.  Setting the
 recovery rate to 0 means it will be unbounded.
-.TP
-.BR \-\- [ raid ] minrecoveryrate " " \fIRate [ \fIbBsSkKmMgG ]
+.
+.HP
+.BR \-\- [ raid ] minrecoveryrate
+.BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
+.br
 Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
 If no suffix is given, then KiB/sec/device is assumed.  Setting the
 recovery rate to 0 means it will be unbounded.
-.TP
-.IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
+.
+.HP
+.BR \-r | \-\-readahead
+.RB { \fIReadAheadSectors | auto | none }
+.br
 Sets read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
 be a value between 2 and 120.
-The default value is \fIauto\fP which allows the kernel to choose
+The default value is \fBauto\fP which allows the kernel to choose
 a suitable value automatically.
-\fINone\fP is equivalent to specifying zero.
-.TP
-.BR \-R ", " \-\-regionsize " " \fIMirrorLogRegionSize [ \fIbBsSkKmMgG ]
+\fBnone\fP is equivalent to specifying zero.
+.
+.HP
+.BR \-R | \-\-regionsize
+.BR \fIMirrorLogRegionSize [ b | B | s | S | k | K | m | M | g | G ]
+.br
 A mirror is divided into regions of this size (in MiB), and the mirror log
 uses this granularity to track which regions are in sync.
-.TP
-.IR \fB\-k ", " \fB\-\-setactivationskip "  {" y | n }
+.
+.HP
+.BR \-k | \-\-setactivationskip
+.RB { y | n }
+.br
 Controls whether Logical Volumes are persistently flagged to be skipped during
 activation. By default, thin snapshot volumes are flagged for activation skip.
 See
 .BR lvm.conf (5)
-.IR activation / auto_set_activation_skip
+\fBactivation/auto_set_activation_skip\fP
 how to change its default behaviour.
-To activate such volumes, an extra
-.BR \-K | \-\-ignoreactivationskip
+To activate such volumes, an extra \fB\-\-ignoreactivationskip\fP
 option must be used. The flag is not applied during deactivation. Use
-.B lvchange \-\-setactivationskip {y|n}
+\fBlvchange \-\-setactivationskip\fP
 command to change the skip flag for existing volumes.
 To see whether the flag is attached, use \fBlvs\fP command
 where the state of the flag is reported within \fBlv_attr\fP bits.
-.TP
-.IR \fB\-L ", " \fB\-\-size " " LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
+.
+.HP
+.BR \-L | \-\-size
+.BR \fILogicalVolumeSize [ b | B | s | S | k | K | m | M | \c
+.BR g | G | t | T | p | P | e | E ]
+.\" man2html cannot handle all those changes in 1 line
+.br
 Gives the size to allocate for the new logical volume.
-A size suffix of \fIB\fR for bytes, \fIS\fR for sectors as 512 bytes,
-\fIK\fR for kilobytes, \fIM\fR for megabytes,
-\fIG\fR for gigabytes, \fIT\fR for terabytes, \fIP\fR for petabytes
-or \fIE\fR for exabytes is optional.
+A size suffix of \fBB\fP for bytes, \fBS\fP for sectors as 512 bytes,
+\fBK\fP for kilobytes, \fBM\fP for megabytes,
+\fBG\fP for gigabytes, \fBT\fP for terabytes, \fBP\fP for petabytes
+or \fBE\fP for exabytes is optional.
 .br
 Default unit is megabytes.
 .TP
@@ -589,7 +677,7 @@ If blkid wiping is used
 setting in
 .BR lvm.conf (5))
 and LVM2 is compiled with blkid wiping support, then \fBblkid\fP(8) library is used
-to detect the signatures (use \fBblkid -k\fP command to list the signatures that are recognized).
+to detect the signatures (use \fBblkid \-k\fP command to list the signatures that are recognized).
 Otherwise, native LVM2 code is used to detect signatures (MD RAID, swap and LUKS
 signatures are detected only in this case).
 .br
@@ -705,7 +793,7 @@ volume (i.e. the origin LV), creating a cache LV.
 
 .\" Create a 1G cached LV "lvol1" with  10M cache pool "vg00/pool".
 .\" .sp
-.\" .B lvcreate \-\-cache \-L 1G \-n lv --pooldatasize 10M vg00/pool
+.\" .B lvcreate \-\-cache \-L 1G \-n lv \-\-pooldatasize 10M vg00/pool
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/man/lvm.8.in b/man/lvm.8.in
index daab791..8ff31ae 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -1,29 +1,35 @@
 .TH LVM 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.
 .SH NAME
+.
 lvm \(em LVM2 tools
+.
 .SH SYNOPSIS
+.
 .B lvm
-[command | file]
+.RI [ command | file ]
+.
 .SH DESCRIPTION
+.
 lvm provides the command-line tools for LVM2.  A separate
 manual page describes each command in detail.
-.LP
+.P
 If \fBlvm\fP is invoked with no arguments it presents a readline prompt
 (assuming it was compiled with readline support).
 LVM commands may be entered interactively at this prompt with
 readline facilities including history and command name and option
 completion.  Refer to \fBreadline\fP(3) for details.
-.LP
+.P
 If \fBlvm\fP is invoked with argv[0] set to the name of a specific
 LVM command (for example by using a hard or soft link) it acts as
 that command.
-.LP
+.P
 On invocation, \fBlvm\fP requires that only the standard file descriptors
 stdin, stdout and stderr are available.  If others are found, they
 get closed and messages are issued warning about the leak.
 This warning can be suppressed by setting the environment variable
 .B LVM_SUPPRESS_FD_WARNINGS\fP.
-.LP
+.P
 Where commands take VG or LV names as arguments, the full path name is
 optional.  An LV called "lvol0" in a VG called "vg0" can be specified
 as "vg0/lvol0".  Where a list of VGs is required but is left empty,
@@ -31,223 +37,319 @@ a list of all VGs will be substituted.  Where a list of LVs is required
 but a VG is given, a list of all the LVs in that VG will be substituted.
 So \fBlvdisplay vg0\fP will display all the LVs in "vg0".
 Tags can also be used - see \fB\-\-addtag\fP below.
-.LP
+.P
 One advantage of using the built-in shell is that configuration
 information gets cached internally between commands.
-.LP
+.P
 A file containing a simple script with one command per line
 can also be given on the command line.  The script can also be
 executed directly if the first line is #! followed by the absolute
 path of \fBlvm\fP.
+.
 .SH BUILT-IN COMMANDS
-The following commands are built into lvm without links normally
-being created in the filesystem for them.
+.
+The following commands are built into lvm without links
+normally being created in the filesystem for them.
+.sp
 .PD 0
-.HP
-\fBconfig\fP \(em The same as \fBlvmconfig\fP(8) below.
-.HP
-\fBdevtypes\fP \(em Display the recognised built-in block device types.
-.HP
-\fBdumpconfig\fP \(em The same as \fBlvmconfig\fP(8) below.
-.HP
-\fBformats\fP \(em Display recognised metadata formats.
-.HP
-\fBhelp\fP \(em Display the help text.
-.HP
-\fBlvpoll\fP \(em Internal command used by lvmpolld to complete some Logical Volume operations.
-.HP
-\fBpvdata\fP \(em Not implemented in LVM2.
-.HP
-\fBsegtypes\fP \(em Display recognised Logical Volume segment types.
-.HP
-\fBsystemid\fP \(em Display the system ID, if any, currently set on this host.
-.HP
-\fBtags\fP \(em Display any tags defined on this host.
-.HP
-\fBversion\fP \(em Display version information.
+.TP 14
+.B config
+The same as \fBlvmconfig\fP(8) below.
+.TP
+.B devtypes
+Display the recognised built-in block device types.
+.TP
+.B dumpconfig
+The same as \fBlvmconfig\fP(8) below.
+.TP
+.B formats
+Display recognised metadata formats.
+.TP
+.B help
+Display the help text.
+.TP
+.B lvpoll
+Complete lvmpolld operations (Internal command).
+.TP
+.B pvdata
+Not implemented in LVM2.
+.TP
+.B segtypes
+Display recognised Logical Volume segment types.
+.TP
+.B systemid
+Display any system ID currently set on this host.
+.TP
+.B tags
+Display any tags defined on this host.
+.TP
+.B version
+Display version information.
 .PD
+.
 .SH COMMANDS
+.
 The following commands implement the core LVM functionality.
+.sp
 .PD 0
-.HP
-\fBpvchange\fP \(em Change attributes of a Physical Volume.
-.HP
-\fBpvck\fP \(em Check Physical Volume metadata.
-.HP
-\fBpvcreate\fP \(em Initialize a disk or partition for use by LVM.
-.HP
-\fBpvdisplay\fP \(em Display attributes of a Physical Volume.
-.HP
-\fBpvmove\fP \(em Move Physical Extents.
-.HP
-\fBpvremove\fP \(em Remove a Physical Volume.
-.HP
-\fBpvresize\fP \(em Resize a disk or partition in use by LVM2.
-.HP
-\fBpvs\fP \(em Report information about Physical Volumes.
-.HP
-\fBpvscan\fP \(em Scan all disks for Physical Volumes.
-.HP
-\fBvgcfgbackup\fP \(em Backup Volume Group descriptor area.
-.HP
-\fBvgcfgrestore\fP \(em Restore Volume Group descriptor area.
-.HP
-\fBvgchange\fP \(em Change attributes of a Volume Group.
-.HP
-\fBvgck\fP \(em Check Volume Group metadata.
-.HP
-\fBvgconvert\fP \(em Convert Volume Group metadata format.
-.HP
-\fBvgcreate\fP \(em Create a Volume Group.
-.HP
-\fBvgdisplay\fP \(em Display attributes of Volume Groups.
-.HP
-\fBvgexport\fP \(em Make volume Groups unknown to the system.
-.HP
-\fBvgextend\fP \(em Add Physical Volumes to a Volume Group.
-.HP
-\fBvgimport\fP \(em Make exported Volume Groups known to the system.
-.HP
-\fBvgimportclone\fP \(em Import and rename duplicated Volume Group (e.g. a hardware snapshot).
-.HP
-\fBvgmerge\fP \(em Merge two Volume Groups.
-.HP
-\fBvgmknodes\fP \(em Recreate Volume Group directory and Logical Volume special files
-.HP
-\fBvgreduce\fP \(em Reduce a Volume Group by removing one or more
-Physical Volumes.
-.HP
-\fBvgremove\fP \(em Remove a Volume Group.
-.HP
-\fBvgrename\fP \(em Rename a Volume Group.
-.HP
-\fBvgs\fP \(em Report information about Volume Groups.
-.HP
-\fBvgscan\fP \(em Scan all disks for Volume Groups and rebuild caches.
-.HP
-\fBvgsplit\fP \(em Split a Volume Group into two, moving any logical
+.TP 14
+.B pvchange
+Change attributes of a Physical Volume.
+.TP
+.B pvck
+Check Physical Volume metadata.
+.TP
+.B pvcreate
+Initialize a disk or partition for use by LVM.
+.TP
+.B pvdisplay
+Display attributes of a Physical Volume.
+.TP
+.B pvmove
+Move Physical Extents.
+.TP
+.B pvremove
+Remove a Physical Volume.
+.TP
+.B pvresize
+Resize a disk or partition in use by LVM2.
+.TP
+.B pvs
+Report information about Physical Volumes.
+.TP
+.B pvscan
+Scan all disks for Physical Volumes.
+.TP
+.B vgcfgbackup
+Backup Volume Group descriptor area.
+.TP
+.B vgcfgrestore
+Restore Volume Group descriptor area.
+.TP
+.B vgchange
+Change attributes of a Volume Group.
+.TP
+.B vgck
+Check Volume Group metadata.
+.TP
+.B vgconvert
+Convert Volume Group metadata format.
+.TP
+.B vgcreate
+Create a Volume Group.
+.TP
+.B vgdisplay
+Display attributes of Volume Groups.
+.TP
+.B vgexport
+Make volume Groups unknown to the system.
+.TP
+.B vgextend
+Add Physical Volumes to a Volume Group.
+.TP
+.B vgimport
+Make exported Volume Groups known to the system.
+.TP
+.B vgimportclone
+Import and rename duplicated Volume Group (e.g. a hardware snapshot).
+.TP
+.B vgmerge
+Merge two Volume Groups.
+.TP
+.B vgmknodes
+Recreate Volume Group directory and Logical Volume special files
+.TP
+.B vgreduce
+Reduce a Volume Group by removing one or more Physical Volumes.
+.TP
+.B vgremove
+Remove a Volume Group.
+.TP
+.B vgrename
+Rename a Volume Group.
+.TP
+.B vgs
+Report information about Volume Groups.
+.TP
+.B vgscan
+Scan all disks for Volume Groups and rebuild caches.
+.TP
+.B vgsplit
+Split a Volume Group into two, moving any logical
 volumes from one Volume Group to another by moving entire Physical
 Volumes.
-.HP
-\fBlvchange\fP \(em Change attributes of a Logical Volume.
-.HP
-\fBlvconvert\fP \(em Convert a Logical Volume from linear to mirror or snapshot.
-.HP
-\fBlvcreate\fP \(em Create a Logical Volume in an existing Volume Group.
-.HP
-\fBlvdisplay\fP \(em Display attributes of a Logical Volume.
-.HP
-\fBlvextend\fP \(em Extend the size of a Logical Volume.
-.HP
-\fBlvmchange\fP \(em Change attributes of the Logical Volume Manager.
-.HP
-\fBlvmconfig\fP \(em Display the configuration information after
+.TP
+.B lvchange
+Change attributes of a Logical Volume.
+.TP
+.B lvconvert
+Convert a Logical Volume from linear to mirror or snapshot.
+.TP
+.B lvcreate
+Create a Logical Volume in an existing Volume Group.
+.TP
+.B lvdisplay
+Display attributes of a Logical Volume.
+.TP
+.B lvextend
+Extend the size of a Logical Volume.
+.TP
+.B lvmchange
+Change attributes of the Logical Volume Manager.
+.TP
+.B lvmconfig
+Display the configuration information after
 loading \fBlvm.conf\fP(5) and any other configuration files.
-.HP
-\fBlvmdiskscan\fP \(em Scan for all devices visible to LVM2.
-.HP
-\fBlvmdump\fP \(em Create lvm2 information dumps for diagnostic purposes.
-.HP
-\fBlvreduce\fP \(em Reduce the size of a Logical Volume.
-.HP
-\fBlvremove\fP \(em Remove a Logical Volume.
-.HP
-\fBlvrename\fP \(em Rename a Logical Volume.
-.HP
-\fBlvresize\fP \(em Resize a Logical Volume.
-.HP
-\fBlvs\fP \(em Report information about Logical Volumes.
-.HP
-\fBlvscan\fP \(em Scan (all disks) for Logical Volumes.
+.TP
+.B lvmdiskscan
+Scan for all devices visible to LVM2.
+.TP
+.B lvmdump
+Create lvm2 information dumps for diagnostic purposes.
+.TP
+.B lvreduce
+Reduce the size of a Logical Volume.
+.TP
+.B lvremove
+Remove a Logical Volume.
+.TP
+.B lvrename
+Rename a Logical Volume.
+.TP
+.B lvresize
+Resize a Logical Volume.
+.TP
+.B lvs
+Report information about Logical Volumes.
+.TP
+.B lvscan
+Scan (all disks) for Logical Volumes.
 .PD
-.HP
-The following commands are not implemented in LVM2 but might be in the future: lvmsadc, lvmsar, pvdata.
+.P
+The following commands are not implemented in LVM2 but might be
+in the future:
+.BR lvmsadc ", " lvmsar ", " pvdata .
+.
 .SH OPTIONS
+.
 The following options are available for many of the commands.
 They are implemented generically and documented here rather
 than repeated on individual manual pages.
-
+.P
 Additional hyphens within option names are ignored.  For example,
-\-\-readonly and \-\-read\-only are both accepted.
-
-.TP
-.BR \-h ", " \-? ", " \-\-help
+\fB\-\-readonly\fP and \fB\-\-read\-only\fP are both accepted.
+.
+.HP
+.BR \-h | \-? | \-\-help
+.br
 Display the help text.
-.TP
-.B \-\-version
+.
+.HP
+.BR \-\-version
+.br
 Display version information.
-.TP
-.BR \-v ", " \-\-verbose
+.
+.HP
+.BR \-v | \-\-verbose
+.br
 Set verbose level. Repeat from 1 to 3 times to increase the detail
 of messages sent to stdout and stderr.  Overrides config file setting.
-.TP
-.BR \-d ", " \-\-debug
+.
+.HP
+.BR \-d | \-\-debug
+.br
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 Overrides config file setting.
-.TP
-.BR \-q ", "  \-\-quiet
+.
+.HP
+.BR \-q | \-\-quiet
+.br
 Suppress output and log messages.
 Overrides \fB\-d\fP and \fB\-v\fP.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.
+.HP
 .BR \-\-yes
+.br
 Don't prompt for confirmation interactively but instead always assume the
 answer is 'yes'.  Take great care if you use this!
-.TP
-.BR \-t ", " \-\-test
+.
+.HP
+.BR \-t | \-\-test
+.br
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function.  This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
-.BR \-\-driverloaded " {" \fIy | \fIn }
+.
+.HP
+.BR \-\-driverloaded
+.RB { y | n }
+.br
 Whether or not the device-mapper kernel driver is loaded.
-If you set this to \fIn\fP, no attempt will be made to contact the driver.
-.TP
-.BR \-A ", " \-\-autobackup " {" \fIy | \fIn }
+If you set this to \fBn\fP, no attempt will be made to contact the driver.
+.
+.HP
+.BR \-A | \-\-autobackup
+.RB { y | n }
+.br
 Whether or not to metadata should be backed up automatically after a change.
 You are strongly advised not to disable this!
 See \fBvgcfgbackup\fP(8).
-.TP
-.BR \-P ", " \-\-partial
+.
+.HP
+.BR \-P | \-\-partial
+.br
 When set, the tools will do their best to provide access to Volume Groups
 that are only partially available (one or more Physical Volumes belonging
 to the Volume Group are missing from the system).  Where part of a logical
-volume is missing, \fB/dev/ioerror\fP will be substituted, and you could use
+volume is missing, \fI\%/dev/ioerror\fP will be substituted, and you could use
 \fBdmsetup\fP(8) to set this up to return I/O errors when accessed,
 or create it as a large block device of nulls.  Metadata may not be
 changed with this option. To insert a replacement Physical Volume
 of the same or large size use \fBpvcreate \-u\fP to set the uuid to
 match the original followed by \fBvgcfgrestore\fP(8).
-.TP
-.BR \-S ", " \-\-select " " \fISelection
-For reporting commands, display only rows that match selection criteria.
+.
+.HP
+.BR \-S | \-\-select
+.IR Selection
+.br
+For reporting commands, display only rows that match \fISelection\fP criteria.
 All rows are displayed with the additional "selected" column (\fB-o selected\fP)
-showing 1 if the row matches the Selection and 0 otherwise. For non-reporting
+showing 1 if the row matches the \fISelection\fP and 0 otherwise. For non-reporting
 commands which process LVM entities, the selection can be used to match items
 to process. See \fBSELECTION CRITERIA\fP section of this man page for more
 information about the way the selection criteria are constructed.
-.TP
-.BR \-M ", " \-\-metadatatype " " \fIType
-Specifies which type of on-disk metadata to use, such as \fIlvm1\fP
-or \fIlvm2\fP, which can be abbreviated to \fI1\fP or \fI2\fP respectively.
-The default (\fIlvm2\fP) can be changed by setting \fBformat\fP
-in the \fBglobal\fP section of the config file.
-.TP
-.B \-\-ignorelockingfailure
+.
+.HP
+.BR \-M | \-\-metadatatype
+.IR Type
+.br
+Specifies which \fItype\fP of on-disk metadata to use, such as \fBlvm1\fP
+or \fBlvm2\fP, which can be abbreviated to \fB1\fP or \fB2\fP respectively.
+The default (\fBlvm2\fP) can be changed by setting \fBformat\fP
+in the \fBglobal\fP section of the config file \fBlvm.conf\fP(5).
+.
+.HP
+.BR \-\-ignorelockingfailure
+.br
 This lets you proceed with read-only metadata operations such as
 \fBlvchange \-ay\fP and \fBvgchange \-ay\fP even if the locking module fails.
 One use for this is in a system init script if the lock directory
 is mounted read-only when the script runs.
-.TP
-.B \-\-ignoreskippedcluster
+.
+.HP
+.BR \-\-ignoreskippedcluster
+.br
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and some clustered Volume Groups have to be
 skipped over.
-.TP
-.B \-\-readonly
+.
+.HP
+.BR \-\-readonly
+.br
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks.  This can be used to peek
 inside metadata used by a virtual machine image while the virtual
@@ -255,21 +357,28 @@ machine is running.
 It can also be used to peek inside the metadata of clustered Volume
 Groups when clustered locking is not configured or running.  No attempt
 will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not Logical Volumes are 
+this option is unable to report whether or not Logical Volumes are
 actually in use.
-.TP
-.B \-\-foreign
+.
+.HP
+.BR \-\-foreign
+.br
 Cause the command to access foreign VGs, that would otherwise be skipped.
 It can be used to report or display a VG that is owned by another host.
 This option can cause a command to perform poorly because lvmetad caching
 is not used and metadata is read from disks.
-.TP
-.B \-\-shared
+.
+.HP
+.BR \-\-shared
+.br
 Cause the command to access shared VGs, that would otherwise be skipped
 when lvmlockd is not being used.  It can be used to report or display a
 lockd VG without locking.
-.TP
-.B \-\-addtag \fITag
+.
+.HP
+.BR \-\-addtag
+.IR Tag
+.br
 Add the tag \fITag\fP to a PV, VG or LV.
 Supply this argument multiple times to add more than one tag at once.
 A tag is a word that can be used to group LVM2 objects of the same type
@@ -288,79 +397,113 @@ Only the new LVM2 metadata format supports tagging: objects using the
 LVM1 metadata format cannot be tagged because the on-disk format does not
 support it.
 Characters allowed in tags are:
-.B A-Z a-z 0-9 _ + . -
+.BR A - Z
+.BR a - z
+.BR 0 - 9
+.BR "_ + . -"
 and as of version 2.02.78 the following characters are also accepted:
-.B / = ! : # &
-.TP
-.B \-\-deltag \fITag
+.BR "/ = ! : # &"
+..
+.HP
+.BR \-\-deltag
+.IR Tag
+.br
 Delete the tag \fITag\fP from a PV, VG or LV, if it's present.
 Supply this argument multiple times to remove more than one tag at once.
-.TP
-.IR \fB\-\-alloc \ { anywhere | contiguous | cling | inherit | normal }
+.
+.HP
+.BR \-\-alloc
+.RB { anywhere | contiguous | cling | inherit | normal }
+.br
 Selects the allocation policy when a command needs to allocate
 Physical Extents from the Volume Group.
 Each Volume Group and Logical Volume has an allocation policy defined.
-The default for a Volume Group is \fInormal\fP which applies
+The default for a Volume Group is \fBnormal\fP which applies
 common-sense rules such as not placing parallel stripes on the same
-Physical Volume.  The default for a Logical Volume is \fIinherit\fP
+Physical Volume.  The default for a Logical Volume is \fBinherit\fP
 which applies the same policy as for the Volume Group.  These policies can
 be changed using \fBlvchange\fP(8) and \fBvgchange\fP(8) or overridden
 on the command line of any command that performs allocation.
-The \fIcontiguous\fP policy requires that new Physical Extents be placed adjacent
+The \fBcontiguous\fP policy requires that new Physical Extents be placed adjacent
 to existing Physical Extents.
-The \fIcling\fP policy places new Physical Extents on the same Physical
+The \fBcling\fP policy places new Physical Extents on the same Physical
 Volume as existing Physical Extents in the same stripe of the Logical Volume.
 If there are sufficient free Physical Extents to satisfy
-an allocation request but \fInormal\fP doesn't use them,
-\fIanywhere\fP will - even if that reduces performance by
+an allocation request but \fBnormal\fP doesn't use them,
+\fBanywhere\fP will - even if that reduces performance by
 placing two stripes on the same Physical Volume.
-.TP
-.IR \fB\-\-commandprofile " " \fIProfileName
+.
+.HP
+.BR \-\-commandprofile
+.IR ProfileName
+.br
 Selects the command configuration profile to use when processing an LVM command.
 See also \fBlvm.conf\fP(5) for more information about \fBcommand profile config\fP and
 the way it fits with other LVM configuration methods. Using \fB\-\-commandprofile\fP
 option overrides any command profile specified via \fBLVM_COMMAND_PROFILE\fP
 environment variable.
-.TP
-.IR \fB\-\-metadataprofile " " \fIProfileName
+.
+.HP
+.BR \-\-metadataprofile
+.IR ProfileName
+.br
 Selects the metadata configuration profile to use when processing an LVM command.
 When using metadata profile during Volume Group or Logical Volume creation,
 the metadata profile name is saved in metadata. When such Volume Group or Logical
 Volume is processed next time, the metadata profile is automatically applied
-and the use of \-\-metadataprofile option is not necessary. See also
+and the use of \fB\-\-metadataprofile\fP option is not necessary. See also
 \fBlvm.conf\fP(5) for more information about \fBmetadata profile config\fP and the
 way it fits with other LVM configuration methods.
-.TP
-.IR \fB\-\-profile " " \fIProfileName
+.
+.HP
+.BR \-\-profile
+.IR ProfileName
+.br
 A short form of \fB\-\-metadataprofile\fP for \fBvgcreate\fP, \fBlvcreate\fP,
 \fBvgchange\fP and \fBlvchange\fP command and a short form of \fB\-\-commandprofile\fP
 for any other command (with the exception of \fBlvmconfig\fP command where the
-\-\-profile has special meaning, see \fBlvmconfig\fP(8) for more information).
-.TP
-.IR \fB\-\-config " " \fIConfigurationString
+\fB\-\-profile\fP has special meaning, see \fBlvmconfig\fP(8) for more information).
+.
+.HP
+.BR \-\-config
+.IR ConfigurationString
+.br
 Uses the ConfigurationString as direct string representation of the configuration
 to override the existing configuration. The ConfigurationString is of exactly
 the same format as used in any LVM configuration file. See \fBlvm.conf\fP(5)
 for more information about \fBdirect config override on command line\fP and the
 way it fits with other LVM configuration methods.
+.
 .SH VALID NAMES
+.
 The valid characters for VG and LV names are:
-.B a-z A-Z 0-9 + _ . -
-.LP
+.BR a - z
+.BR A - Z
+.BR 0 - 9
+.BR "+ _ . -"
+.P
 VG and LV names cannot begin with a hyphen.
-There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
-A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
-An LV cannot be called '.', '..', 'snapshot' or 'pvmove'. The LV name may also not contain any of the following 
-strings: '_cdata', '_cmeta', '_corig', '_mlog', '_mimage', '_pmspare', '_rimage', '_rlog', '_tdata' or '_tmeta'.
-A directory bearing the name of each Volume Group is created under /dev when any of its Logical Volumes are activated.
-Each active Logical Volume is accessible from this directory as a symbolic link leading to a device node.
-Links or nodes in /dev/mapper are intended only for internal use and the precise format and escaping might change between releases and distributions.
+There are also various reserved names that are used internally by lvm that can
+not be used as LV or VG names. A VG cannot be called anything that exists in
+\fI/dev/\fP at the time of creation, nor can it be called '.' or '..'.
+An LV cannot be called '.', '..', 'snapshot' or 'pvmove'.
+The LV name may also not contain any of the following strings:
+'_cdata', '_cmeta', '_corig', '_mlog', '_mimage', '_pmspare', '_rimage',
+'_rlog', '_tdata' or '_tmeta'.
+A directory bearing the name of each Volume Group is created under
+\fI/dev\fP when any of its Logical Volumes are activated.
+Each active Logical Volume is accessible from this directory as a symbolic
+link leading to a device node.
+Links or nodes in \fI/dev/mapper\fP are intended only for internal use and
+the precise format and escaping might change between releases and distributions.
 Other software and scripts should use the
-/dev/VolumeGroupName/LogicalVolumeName format to reduce the chance of needing
+\fI/dev/VolumeGroupName/LogicalVolumeName\fP format to reduce the chance of needing
 amendment when the software is updated.  Should you need to process the node
 names in /dev/mapper, you may use \fBdmsetup splitname\fP to separate out the
 original VG, LV and internal layer names.
+.
 .SH ALLOCATION
+.
 When an operation needs to allocate Physical Extents for one or more
 Logical Volumes, the tools proceed as follows:
 
@@ -370,7 +513,7 @@ the end of the command line, only unallocated Physical Extents within
 those ranges on the specified Physical Volumes are considered.
 
 Then they try each allocation policy in turn, starting with the strictest
-policy (\fIcontiguous\fP) and ending with the allocation policy specified
+policy (\fBcontiguous\fP) and ending with the allocation policy specified
 using \fB\-\-alloc\fP or set as the default for the particular Logical
 Volume or Volume Group concerned.  For each policy, working from the
 lowest-numbered Logical Extent of the empty Logical Volume space that
@@ -380,15 +523,15 @@ they move on to the next policy.
 
 The restrictions are as follows:
 
-\fIContiguous\fP requires that the physical location of any Logical
+\fBContiguous\fP requires that the physical location of any Logical
 Extent that is not the first Logical Extent of a Logical Volume is
 adjacent to the physical location of the Logical Extent immediately
 preceding it.
 
-\fICling\fP requires that the Physical Volume used for any Logical
+\fBCling\fP requires that the Physical Volume used for any Logical
 Extent to be added to an existing Logical Volume is already in use by at
 least one Logical Extent earlier in that Logical Volume.  If the
-configuration parameter allocation/cling_tag_list is defined, then two
+configuration parameter \fBallocation/cling_tag_list\fP is defined, then two
 Physical Volumes are considered to match if any of the listed tags is
 present on both Physical Volumes.  This allows groups of Physical
 Volumes with similar properties (such as their physical location) to be
@@ -398,25 +541,25 @@ When a Logical Volume is striped or mirrored, the above restrictions are
 applied independently to each stripe or mirror image (leg) that needs
 space.
 
-\fINormal\fP will not choose a Physical Extent that shares the same Physical
+\fBNormal\fP will not choose a Physical Extent that shares the same Physical
 Volume as a Logical Extent already allocated to a parallel Logical
-Volume (i.e. a different stripe or mirror image/leg) at the same offset 
+Volume (i.e. a different stripe or mirror image/leg) at the same offset
 within that parallel Logical Volume.
 
 When allocating a mirror log@the same time as Logical Volumes to hold
 the mirror data, Normal will first try to select different Physical
 Volumes for the log and the data.  If that's not possible and the
-allocation/mirror_logs_require_separate_pvs configuration parameter is
-set to 0, it will then allow the log to share Physical Volume(s) with
-part of the data.  
+.B allocation/mirror_logs_require_separate_pvs
+configuration parameter is set to 0, it will then allow the log
+to share Physical Volume(s) with part of the data.
 
 When allocating thin pool metadata, similar considerations to those of a
 mirror log in the last paragraph apply based on the value of the
-allocation/thin_pool_metadata_require_separate_pvs configuration
-parameter.
+.B allocation/thin_pool_metadata_require_separate_pvs
+configuration parameter.
 
 If you rely upon any layout behaviour beyond that documented here, be
-aware that it might change in future versions of the code.  
+aware that it might change in future versions of the code.
 
 For example, if you supply on the command line two empty Physical
 Volumes that have an identical number of free Physical Extents available for
@@ -431,87 +574,123 @@ discretion over the layout.
 To view the way the allocation process currently works in any specific
 case, read the debug logging output, for example by adding \fB\-vvvv\fP to
 a command.
-
+.
 .SH LOGICAL VOLUME TYPES
+.
 Some logical volume types are simple to create and can be done with a
 single \fBlvcreate\fP(8) command.  The linear and striped logical
 volume types are an example of this.  Other logical volume types may
 require more than one command to create.  The cache (\fBlvmcache\fP(7))
 and thin provisioning (\fBlvmthin\fP(7)) types are examples of this.
-
+.
 .SH SELECTION CRITERIA
-.LP
+.
 The selection criteria are a set of \fBstatements\fP combined by \fBlogical
 and grouping operators\fP. The \fBstatement\fP consists of \fBcolumn\fP
 name for which a set of valid \fBvalues\fP is defined using
 \fBcomparison operators\fP. For complete list of column names (fields)
 that can be used in selection, see the output of \fB<lvm reporting command> -S help\fP.
-.LP
-\fBComparison operators\fP (cmp_op):
-.IP
-\fB=~\fP \(em Matching regular expression.
-.IP
-\fB!~\fP \(em Not matching regular expression.
-.IP
-\fB=\fP  \(em Equal to.
-.IP
-\fB!=\fP \(em Not equal to.
-.IP
-\fB>=\fP \(em Greater than or equal to.
-.IP
-\fB>\fP  \(em Greater than
-.IP
-\fB<=\fP \(em Less than or equal to.
-.IP
-\fB<\fP  \(em Less than.
-.LP
-\fBBinary logical operators\fP (cmp_log):
-.IP
-\fB&&\fP \(em All fields must match
-.IP
-\fB,\fP  \(em All fields must match
-.IP
-\fB||\fP \(em At least one field must match
-.IP
-\fB#\fP  \(em At least one field must match
-.LP
-\fBUnary logical operators\fP:
-.IP
-\fB!\fP  \(em Logical negation
-.LP
-\fBGrouping operators\fP:
-.IP
-\fB(\fP  \(em Left parenthesis
-.IP
-\fB)\fP  \(em Right parenthesis
-.IP
-\fB[\fP  \(em List start
-.IP
-\fB]\fP  \(em List end
-.IP
-\fB{\fP  \(em List subset start
-.IP
-\fB}\fP  \(em List subset end
-.LP
-\fBInformal grammar specification\fP:
-.IP
-.BR STATEMENT " = " column " cmp_op " VALUE " | " STATEMENT " log_op " STATEMENT " | " (STATEMENT) " | " !(STATEMENT)
-.IP
+.P
+.SS Comparison operators \fR(cmp_op)
+.sp
+.PD 0
+.TP
+.B =~
+Matching regular expression.
+.TP
+.B !~
+Not matching regular expression.
+.TP
+.B =
+Equal to.
+.TP
+.B !=
+Not equal to.
+.TP
+.B >=
+Greater than or equal to.
+.TP
+.B >
+Greater than
+.TP
+.B <=
+Less than or equal to.
+.TP
+.B <
+Less than.
+.PD
+.P
+.SS Binary logical operators \fR(cmp_log)
+.sp
+.PD 0
+.TP
+.B &&
+All fields must match
+.TP
+.B ,
+All fields must match
+.TP
+.B ||
+At least one field must match
+.TP
+.B #
+At least one field must match
+.PD
+.P
+.SS Unary logical operators
+.TP
+.B !
+Logical negation
+.P
+.SS Grouping operators
+.sp
+.PD 0
+.TP
+.B (
+Left parenthesis
+.TP
+.B )
+Right parenthesis
+.TP
+.B [
+List start
+.TP
+.B ]
+List end
+.TP
+.B {
+List subset start
+.TP
+.B }
+List subset end
+.PD
+.SS Informal grammar specification
+.HP
+.BR STATEMENT " = " column " cmp_op " VALUE " | " \%STATEMENT " log_op " STATEMENT " | " \%(STATEMENT) " | " \%!(STATEMENT)
+.br
+.HP
 .BR VALUE " = " [VALUE " log_op " VALUE]
 .br
-For list-based types: string list. Matches strictly. The log_op must always be of one type within the whole list value.
-.IP
+For list-based types: string list. Matches strictly.
+The log_op must always be of one type within the whole list value.
+.HP
 .BR VALUE " = " {VALUE " log_op " VALUE}
 .br
-For list-based types: string list. Matches a subset. The log_op must always be of one type within the whole list value.
-.IP
+For list-based types: string list. Matches a subset.
+The log_op must always be of one type within the whole list value.
+.HP
 .BR VALUE " = " value
 .br
-For scalar types: number (integer), size (floating point number with size unit suffix), percent (floating point number with or without % suffix), string.
-
+For scalar types: number (integer), size (floating point number
+with size unit suffix), percent (floating point number with or
+without % suffix), string.
+.
 .SH DIAGNOSTICS
+.
 All tools return a status code of zero on success or non-zero on failure.
+.
 .SH ENVIRONMENT VARIABLES
+.
 .TP
 .B HOME
 Directory containing \fI.lvm_history\fP if the internal readline
@@ -523,7 +702,7 @@ is overriden by direct use of \fB\-\-commandprofile\fP command line option.
 .TP
 .B LVM_SYSTEM_DIR
 Directory containing \fBlvm.conf\fP(5) and other LVM system files.
-Defaults to "#DEFAULT_SYS_DIR#".
+Defaults to "\fI#DEFAULT_SYS_DIR#\fP".
 .TP
 .B LVM_SUPPRESS_FD_WARNINGS
 Suppress warnings about unexpected file descriptors passed into LVM.
@@ -554,9 +733,10 @@ separate file.
 The status anticipated when the process exits.  Use ">N" to match any
 status greater than N.  If the actual exit status matches and a log
 file got produced, it is deleted.
-
-LVM_LOG_FILE_EPOCH and LVM_EXPECTED_EXIT_STATUS together allow
-automated test scripts to discard uninteresting log data.
+.B LVM_LOG_FILE_EPOCH
+and
+.B LVM_EXPECTED_EXIT_STATUS
+together allow automated test scripts to discard uninteresting log data.
 .TP
 .B LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES
 Used to suppress warning messages when the configured locking is known
@@ -568,11 +748,15 @@ Abort processing if the code detects a non-fatal internal error.
 .B DM_DISABLE_UDEV
 Avoid interaction with udev.  LVM will manage the relevant nodes in /dev
 directly.
+.
 .SH FILES
+.
 .I #DEFAULT_SYS_DIR#/lvm.conf
 .br
 .I $HOME/.lvm_history
+.
 .SH SEE ALSO
+.
 .BR lvm.conf (5),
 .BR lvmcache (7),
 .BR lvmthin (7),


