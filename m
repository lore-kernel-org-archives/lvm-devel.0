From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 21 Sep 2015 22:11:52 +0000 (UTC)
Subject: master - man: update man pages
Message-ID: <20150921221152.A777660703@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cfe869692f42ee2f4ac0f36c5337e7638ff01c29
Commit:        cfe869692f42ee2f4ac0f36c5337e7638ff01c29
Parent:        a61f3c531650e4473291ff162dd4c9faf5888a39
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 21 22:45:47 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 00:08:44 2015 +0200

man: update man pages

Start to use 'italic' when the argument is not a fixed string.
Keep 'bold' when user cannot use any other string instead.
---
 man/clvmd.8.in    |   51 ++++++++-------
 man/dmstats.8.in  |    2 +-
 man/lvchange.8.in |  181 ++++++++++++++++++++++++++++-------------------------
 3 files changed, 125 insertions(+), 109 deletions(-)

diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index 2c7330b..90de980 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -4,19 +4,20 @@ clvmd \(em cluster LVM daemon
 .SH SYNOPSIS
 .B clvmd
 .RB [ \-C ]
-.RB [ \-d [< \fIvalue\fP >]]
+.RB [ \-d
+.RI [ value ]]
 .RB [ \-E
-.RI < "lock uuid" >]
+.IR "lock uuid" ]
 .RB [ \-f ]
 .RB [ \-h ]
 .RB [ \-I
-.IR "cluster_manager" ]
+.IR "cluster manager" ]
 .RB [ \-R ]
 .RB [ \-S ]
 .RB [ \-t
-.RI < timeout >]
+.IR timeout ]
 .RB [ \-T
-.RI < "start timeout" >]
+.IR "start timeout" ]
 .RB [ \-V ]
 .SH DESCRIPTION
 clvmd is the daemon that distributes LVM metadata updates around a cluster.
@@ -24,17 +25,21 @@ It must be running on all nodes in the cluster and will give an error
 if a node in the cluster does not have this daemon running.
 .SH OPTIONS
 .TP
-.BR \-d [< \fIvalue >]
-Set debug logging level.If \fB\-d\fP is specified without a \fIvalue\fP 
+.BR \-d \ [ \fIvalue ]
+Set debug logging level.
+If \fB\-d\fP is specified without a \fIvalue\fP
 then 1 is assumed. \fIValue\fP can be:
-.RS
-.IP \fI0\fP
-Disabled
-.IP \fI1\fP
-Sends debug logs to stderr (implies \fB\-f\fP)
-.IP \fI2\fP
-Sends debug logs to \fBsyslog\fP(3)
-.RE
+.PD 0
+.IP
+.B 0
+\(em Disabled
+.IP
+.B 1
+\(em Sends debug logs to stderr (implies \fB\-f\fP)
+.IP
+.B 2
+\(em Sends debug logs to \fBsyslog\fP(3)
+.PD
 .TP
 .B \-C
 Only valid if
@@ -55,8 +60,8 @@ enable cluster-wide logging then the command needs to be issued twice, eg:
 .B clvmd \-d2
 .br
 .TP
-.BR \-E < "\fIlock uuid" >
-Pass lock uuid to be reacquired exclusively when clvmd is restarted.
+.BR \-E "\fI lock uuid"
+Pass \fIlock uuid\fP to be reacquired exclusively when clvmd is restarted.
 .TP
 .B \-f
 Don't fork, run in the foreground.
@@ -64,13 +69,13 @@ Don't fork, run in the foreground.
 .B \-h
 Show help information.
 .TP
-.BR \-I " \fIcluster_manager\fP"
+.BR \-I "\fI cluster manager"
 Selects the \fIcluster manager\fP to use for locking and internal
 communications. As it is quite possible to have multiple managers available on
 the same system you might have to manually specify this option to override the
 search.
 
-By default, omit \fB-I\fP is equivalent to \fB\-I\fP\fIauto\fP. \fBClvmd\fP
+By default, omit \fB-I\fP is equivalent to \fB\-Iauto\fP. \fBClvmd\fP
 will use the first cluster manager that succeeds, and it checks them in a
 predefined order cman,corosync,openais.
 The available managers will be listed by order as part of the
@@ -88,13 +93,13 @@ any locks in the same state as they were previously held. (Alternative
 methods of restarting the daemon have the side effect of changing
 exclusive LV locks into shared locks.)
 .TP
-.BR \-t < \fItimeout >
+.BR \-t "\fI timeout"
 Specifies the \fItimeout\fP for commands to run around the cluster. This should not
 be so small that commands with many disk updates to do will fail, so you
 may need to increase this on systems with very large disk farms.
 The default is 60 seconds.
 .TP
-.BR \-T < "\fIstart timeout" >
+.BR \-T "\fI start timeout"
 Specifies the \fIstart timeout\fP for \fBclvmd\fP daemon startup. If the
 daemon does not report that it has started up within this time then the parent
 command will exit with status of 5. This does NOT mean that \fBclvmd\fP has
@@ -119,11 +124,11 @@ Display the version of the cluster LVM daemon.
 .TP
 .B LVM_CLVMD_BINARY
 The CLVMD binary to use when \fBclvmd\fP restart is requested.
-Defaults to #CLVMD_PATH#.
+Defaults to \fI#CLVMD_PATH#\fP.
 .TP
 .B LVM_BINARY
 The LVM2 binary to use.
-Defaults to #LVM_PATH#.
+Defaults to \fI#LVM_PATH#\fP.
 
 .SH SEE ALSO
 .BR syslog (3),
diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 21e7685..985f3fd 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -9,7 +9,7 @@ dmstats \(em device-mapper statistics management
 .HP
 .PD 0
 .B dmstats
-.RB < command >
+.I command
 .RI [ device_name | \fB\-\-uuid
 .IR uuid | \fB\-\-major
 .I major
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 9199b49..e8babba 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -6,74 +6,74 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-\-addtag
 .IR Tag ]
 .RB [ \-A | \-\-autobackup
-.RI { y | n }]
+.RB { y | n }]
 .RB [ \-a | \-\-activate
-.RI [ a | e | s | l ]{ y | n }]
+.RB [ a ][ e | s | l ]{ y | n }]
 .RB [ \-\-activationmode
-.RI { complete | degraded | partial }]
+.RB { complete | degraded | partial }]
 .RB [ \-k | \-\-setactivationskip
-.RI { y | n }]
+.RB { y | n }]
 .RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
 .RB [ \-\-cachepolicy
 .IR policy ]
 .RB [ \-\-cachesettings
-.IR key=value ]
+.IR key \fB= value ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-C | \-\-contiguous
-.RI { y | n }]
+.RB { y | n }]
 .RB [ \-d | \-\-debug ]
 .RB [ \-\-degraded ]
 .RB [ \-\-deltag
 .IR Tag ]
 .RB [ \-\-detachprofile ]
 .RB [ \-\-discards
-.RI { ignore | nopassdown | passdown }]
+.RB { ignore | nopassdown | passdown }]
 .RB [ \-\-errorwhenfull
-.RI { y | n }]
+.RB { y | n }]
 .RB [ \-\-resync ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-ignoremonitoring ]
 .RB [ \-\-ignoreskippedcluster ]
 .RB [ \-\-monitor
-.RI { y | n }]
+.RB { y | n }]
 .RB [ \-\-poll
-.RI { y | n }]
-.RB [ \-\-[raid]maxrecoveryrate
+.RB { y | n }]
+.RB [ \-\- [ raid ] maxrecoveryrate
 .IR Rate ]
-.RB [ \-\-[raid]minrecoveryrate
+.RB [ \-\- [ raid ] minrecoveryrate
 .IR Rate ]
-.RB [ \-\-[raid]syncaction
-.RI { check | repair }]
-.RB [ \-\-[raid]writebehind
+.RB [ \-\- [ raid ] syncaction
+.RB { check | repair }]
+.RB [ \-\- [ raid ] writebehind
 .IR IOCount ]
-.RB [ \-\-[raid]writemostly
-.IR PhysicalVolume [ : { y | n | t }]]
+.RB [ \-\- [ raid ] writemostly
+.BR \fIPhysicalVolume [ : { y | n | t }]]
 .RB [ \-\-sysinit ]
 .RB [ \-\-noudevsync ]
 .RB [ \-\-metadataprofile
 .IR ProfileName ]
 .RB [ \-M | \-\-persistent
-.RI { y | n }
+.RB { y | n }
 .RB [ \-\-minor
 .IR minor ]
 .RB [ \-\-major
 .IR major ]]
 .RB [ \-P | \-\-partial ]
 .RB [ \-p | \-\-permission
-.RI { r | rw }]
+.RB { r | rw }]
 .RB [ \-r | \-\-readahead
-.RI { ReadAheadSectors | auto | none }]
+.RB { \fIReadAheadSectors | auto | none }]
 .RB [ \-\-refresh ]
 .RB [ \-S | \-\-select
 .IR Selection ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-Z | \-\-zero
-.RI { y | n }]
+.RB { y | n }]
 .RI [ LogicalVolumePath ...]
 .SH DESCRIPTION
 lvchange allows you to change the attributes of a logical volume
@@ -81,14 +81,14 @@ including making them known to the kernel ready for use.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
-.BR \-a ", " \-\-activate " [" \fIa | \fIe | \fIs | \fIl ]{ \fIy | \fIn }
+.BR \-a ", " \-\-activate " [" a ][ e | s | l ]{ y | n }
 Controls the availability of the logical volumes for use.
 Communicates with the kernel device-mapper driver via
-libdevmapper to activate (\-ay) or deactivate (\-an) the
+libdevmapper to activate (\fB\-ay\fP) or deactivate (\fB\-an\fP) the
 logical volumes.
 .IP
 Activation of a logical volume creates a symbolic link
-/dev/VolumeGroupName/LogicalVolumeName pointing to the device node.
+\fI/dev/VolumeGroupName/LogicalVolumeName\fP pointing to the device node.
 This link is removed on deactivation.
 All software and scripts should access the device through
 this symbolic link and present this as the name of the device.
@@ -96,79 +96,85 @@ The location and name of the underlying device node may depend on
 the distribution and configuration (e.g. udev) and might change
 from release to release.
 .IP
-If autoactivation option is used (\-aay),
+If autoactivation option is used (\fB\-aay\fP),
 the logical volume is activated only if it matches an item in
-the activation/auto_activation_volume_list set in lvm.conf.
+the
+.B activation/auto_activation_volume_list
+set in \fBlvm.conf\fP(5).
 If this list is not set, then all volumes are considered for
-activation. The \-aay option should be also used during system
+activation. The \fB\-aay\fP option should be also used during system
 boot so it's possible to select which volumes to activate using
-the activation/auto_activation_volume_list setting.
+the 
+.B activation/auto_activation_volume_list
+setting.
 .IP
 In a clustered VG, clvmd is used for activation, and the
 following options are possible:
 
-With \-aey, clvmd activates the LV in exclusive mode
+With \fB\-aey\fP, clvmd activates the LV in exclusive mode
 (with an exclusive lock), allowing a single node to activate the LV.
 
-With \-asy, clvmd activates the LV in shared mode
+With \fB\-asy\fP, clvmd activates the LV in shared mode
 (with a shared lock), allowing multiple nodes to activate the LV concurrently.
 If the LV type prohibits shared access, such as an LV with a snapshot,
-the 's' option is ignored and an exclusive lock is used.
+the '\fBs\fP' option is ignored and an exclusive lock is used.
 
-With \-ay (no mode specified), clvmd activates the LV in shared mode
+With \fB\-ay\fP (no mode specified), clvmd activates the LV in shared mode
 if the LV type allows concurrent access, such as a linear LV.
 Otherwise, clvmd activates the LV in exclusive mode.
 
-With \-aey, \-asy, and \-ay, clvmd attempts to activate the LV
+With \fB\-aey\fP, \fB\-asy\fP, and \fB\-ay\fP, clvmd attempts to activate the LV
 on all nodes.  If exclusive mode is used, then only one of the
 nodes will be successful.
 
-With \-an, clvmd attempts to deactivate the LV on all nodes.
+With \fB\-an\fP, clvmd attempts to deactivate the LV on all nodes.
 
-With \-aly, clvmd activates the LV only on the local node, and \-aln
+With \fB\-aly\fP, clvmd activates the LV only on the local node, and \fB\-aln\fP
 deactivates only on the local node.  If the LV type allows concurrent
 access, then shared mode is used, otherwise exclusive.
 
 LVs with snapshots are always activated exclusively because they can only
 be used on one node at once.
 
-For local VGs, \-ay, \-aey, and \-asy are all equivalent.
+For local VGs \fB\-ay\fP, \fB\-aey\fP, and \fB\-asy\fP are all equivalent.
 
 .TP
-.BR \-\-activationmode " {" \fIcomplete | \fIdegraded | \fIpartial }
+.BR \-\-activationmode " {" complete | degraded | partial }
 The activation mode determines whether logical volumes are allowed to
 activate when there are physical volumes missing (e.g. due to a device
-failure).  \fIcomplete\fP is the most restrictive; allowing only those
+failure).  \fBcomplete\fP is the most restrictive; allowing only those
 logical volumes to be activated that are not affected by the missing
-PVs.  \fIdegraded\fP allows RAID logical volumes to be activated even if
+PVs.  \fBdegraded\fP allows RAID logical volumes to be activated even if
 they have PVs missing.  (Note that the "\fImirror\fP" segment type is not
 considered a RAID logical volume.  The "\fIraid1\fP" segment type should
-be used instead.)  Finally, \fIpartial\fP allows any logical volume to
+be used instead.)  Finally, \fBpartial\fP allows any logical volume to
 be activated even if portions are missing due to a missing or failed
 PV.  This last option should only be used when performing recovery or
-repair operations.  \fIdegraded\fP is the default mode.  To change it, modify
+repair operations.  \fBdegraded\fP is the default mode.  To change it, modify
 .B activation_mode
 in
 .BR lvm.conf (5).
 .TP
-.BR \-k ", " \-\-setactivationskip " {" \fIy | \fIn }
+.BR \-k ", " \-\-setactivationskip " {" y | n }
 Controls  whether Logical Volumes are persistently flagged to be
 skipped during activation. By default, thin snapshot volumes are
 flagged for activation skip.  To activate such volumes,
-an extra \fB\-K/\-\-ignoreactivationskip\fP option must be used.
+an extra
+.BR \-K / \-\-ignoreactivationskip
+option must be used.
 The flag is not applied during deactivation. To see whether
-the flag is attached, use \fBlvs\fP command where the state
+the flag is attached, use \fBlvs\fP(8) command where the state
 of the flag is reported within \fBlv_attr\fP bits.
 .TP
 .BR \-K ", " \-\-ignoreactivationskip
 Ignore the flag to skip Logical Volumes during activation.
 .TP
-.BR  \-\-cachepolicy " " policy ", " \-\-cachesettings " " key=value
+.BR  \-\-cachepolicy " " \fIpolicy ", " \-\-cachesettings " " \fIkey = \fIvalue
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
 the cache policy and its associated tunable settings. In most use-cases,
 default values should be adequate.
 .TP
-.BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
+.BR \-C ", " \-\-contiguous " {" y | n }
 Tries to set or reset the contiguous allocation policy for
 logical volumes. It's only possible to change a non-contiguous
 logical volume's allocation policy to contiguous, if all of the
@@ -177,17 +183,17 @@ allocated physical extents are already contiguous.
 .BR \-\-detachprofile
 Detach any metadata configuration profiles attached to given
 Logical Volumes. See \fBlvm.conf\fP(5) for more information
-about \fBmetadata profiles\fP.
+about metadata profiles.
 .TP
-.BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
-Set this to \fIignore\fP to ignore any discards received by a
-thin pool Logical Volume.  Set to \fInopassdown\fP to process such
+.BR \-\-discards " {" ignore | nopassdown | passdown }
+Set this to \fBignore\fP to ignore any discards received by a
+thin pool Logical Volume.  Set to \fBnopassdown\fP to process such
 discards within the thin pool itself and allow the no-longer-needed
-extents to be overwritten by new data.  Set to \fIpassdown\fP (the
+extents to be overwritten by new data.  Set to \fBpassdown\fP (the
 default) to process them both within the thin pool itself and to
 pass them down the underlying device.
 .TP
-.BR \-\-errorwhenfull " {" \fIy | \fIn }
+.BR \-\-errorwhenfull " {" y | n }
 Sets thin pool behavior when data space is exhaused. See
 .BR lvcreate (8)
 for information.
@@ -201,11 +207,11 @@ time - and during this time you are without a complete redundant copy
 of your data.
 .TP
 .B \-\-metadataprofile " " \fIProfileName
-Uses and attaches ProfileName configuration profile to the logical
+Uses and attaches \fIProfileName\fP configuration profile to the logical
 volume metadata. Whenever the logical volume is processed next time,
 the profile is automatically applied. If the volume group has another
 profile attached, the logical volume profile is preferred.
-See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
+See \fBlvm.conf\fP(5) for more information about metadata profiles.
 .TP
 .B \-\-minor \fIminor
 Set the minor number.
@@ -215,15 +221,15 @@ Sets the major number. This option is supported only on older systems
 (kernel version 2.4) and is ignored on modern Linux systems where major
 numbers are dynamically assigned.
 .TP
-.BR \-\-monitor " {" \fIy | \fIn }
+.BR \-\-monitor " {" y | n }
 Start or stop monitoring a mirrored or snapshot logical volume with
 dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
 the failure is handled according to
 \fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
-set in \fBlvm.conf\fP.
+set in \fBlvm.conf\fP(5).
 .TP
-.BR \-\-poll " {" \fIy | \fIn }
+.BR \-\-poll " {" y | n }
 Without polling a logical volume's backgrounded transformation process
 will never complete.  If there is an incomplete pvmove or lvconvert (for
 example, on rebooting after a crash), use \fB\-\-poll y\fP to restart the
@@ -231,46 +237,46 @@ process from its last checkpoint.  However, it may not be appropriate to
 immediately poll a logical volume when it is activated, use
 \fB\-\-poll n\fP to defer and then \fB\-\-poll y\fP to restart the process.
 .TP
-.IR \fB\-\-[raid]maxrecoveryrate " " \fIRate [ bBsSkKmMgG ]
+.BR \-\- [ raid ] maxrecoveryrate " " \fIRate [ bBsSkKmMgG ]
 Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
 If no suffix is given, then KiB/sec/device is assumed.  Setting the
-recovery rate to 0 means it will be unbounded.
+recovery rate to \fB0\fP means it will be unbounded.
 .TP
-.IR \fB\-\-[raid]minrecoveryrate " " \fIRate [ bBsSkKmMgG ]
+.BR \-\- [ raid ] minrecoveryrate " " \fIRate [ bBsSkKmMgG ]
 Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
 is specified as an amount per second for each device in the array.
 If no suffix is given, then KiB/sec/device is assumed.  Setting the
-recovery rate to 0 means it will be unbounded.
+recovery rate to \fB0\fP means it will be unbounded.
 .TP
-.BR \-\-[raid]syncaction " {" \fIcheck | \fIrepair }
+.BR \-\- [ raid ] syncaction " {" check | repair }
 This argument is used to initiate various RAID synchronization operations.
-The \fIcheck\fP and \fIrepair\fP options provide a way to check the
+The \fBcheck\fP and \fBrepair\fP options provide a way to check the
 integrity of a RAID logical volume (often referred to as "scrubbing").
 These options cause the RAID logical volume to
 read all of the data and parity blocks in the array and check for any
 discrepancies (e.g. mismatches between mirrors or incorrect parity values).
-If \fIcheck\fP is used, the discrepancies will be counted but not repaired.
-If \fIrepair\fP is used, the discrepancies will be corrected as they are
-encountered.  The 'lvs' command can be used to show the number of
+If \fBcheck\fP is used, the discrepancies will be counted but not repaired.
+If \fBrepair\fP is used, the discrepancies will be corrected as they are
+encountered.  The \fBlvs\fP(8) command can be used to show the number of
 discrepancies found or repaired.
 .TP
-.BR \-\-[raid]writebehind " " \fIIOCount
+.BR \-\- [ raid ] writebehind " " \fIIOCount
 Specify the maximum number of outstanding writes that are allowed to
-devices in a RAID1 logical volume that are marked as \fIwrite-mostly\fP.
+devices in a RAID1 logical volume that are marked as write-mostly.
 Once this value is exceeded, writes become synchronous (i.e. all writes
 to the constituent devices must complete before the array signals the
 write has completed).  Setting the value to zero clears the preference
 and allows the system to choose the value arbitrarily.
 .TP
-.IR \fB\-\-[raid]writemostly " " PhysicalVolume [ : { y | n | t }]
-Mark a device in a RAID1 logical volume as \fIwrite-mostly\fP.  All reads
+.BR \-\- [ raid ] writemostly " " \fIPhysicalVolume [ : { y | n | t }]
+Mark a device in a RAID1 logical volume as write-mostly.  All reads
 to these drives will be avoided unless absolutely necessary.  This keeps
 the number of I/Os to the drive to a minimum.  The default behavior is to
 set the write-mostly attribute for the specified physical volume in the
 logical volume.  It is possible to also remove the write-mostly flag by
-appending a "\fI:n\fP" to the physical volume or to toggle the value by specifying
-"\fI:t\fP".  The \fB\-\-writemostly\fP argument can be specified more than one time
+appending a "\fB:n\fP" to the physical volume or to toggle the value by specifying
+"\fB:t\fP".  The \fB\-\-writemostly\fP argument can be specified more than one time
 in a single command; making it possible to toggle the write-mostly attributes
 for all the physical volumes in a logical volume at once.
 .TP
@@ -285,10 +291,12 @@ this is equivalent to using  \fB\-\-ignorelockingfailure\fP,
 \fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
 environment variable.
 
-If \fB\-\-sysinit\fP is used in conjunction with lvmetad(8) enabled and running,
+If \fB\-\-sysinit\fP is used in conjunction with
+\fBlvmetad\fP(8) enabled and running,
 autoactivation is preferred over manual activation via direct lvchange call.
-Logical volumes are autoactivated according to auto_activation_volume_list
-set in lvm.conf(5).
+Logical volumes are autoactivated according to
+.B auto_activation_volume_list
+set in \fBlvm.conf\fP(5).
 .TP
 .B \-\-noudevsync
 Disable udev synchronisation. The
@@ -302,20 +310,20 @@ Make no attempt to interact with dmeventd unless \fB\-\-monitor\fP
 is specified.
 Do not use this if dmeventd is already monitoring a device.
 .TP
-.BR \-M ", " \-\-persistent " {" \fIy | \fIn }
-Set to y to make the minor number specified persistent.
+.BR \-M ", " \-\-persistent " {" y | n }
+Set to \fBy\fP to make the minor number specified persistent.
 Change of persistent numbers is not supported for pool volumes.
 .TP
-.BR \-p ", " \-\-permission " {" \fIr | \fIrw }
+.BR \-p ", " \-\-permission " {" r | rw }
 Change access permission to read-only or read/write.
 .TP
-.BR \-r ", " \-\-readahead " {" \fIReadAheadSectors | \fIauto | \fInone }
+.BR \-r ", " \-\-readahead " {" \fIReadAheadSectors | auto | none }
 Set read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
 be a value between 2 and 120 sectors.
-The default value is "auto" which allows the kernel to choose
+The default value is "\fBauto\fP" which allows the kernel to choose
 a suitable value automatically.
-"None" is equivalent to specifying zero.
+"\fBnone\fP" is equivalent to specifying zero.
 .TP
 .B \-\-refresh
 If the logical volume is active, reload its metadata.
@@ -323,10 +331,10 @@ This is not necessary in normal operation, but may be useful
 if something has gone wrong or if you're doing clustering
 manually without a clustered lock manager.
 .TP
-.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
+.BR \-Z ", " \-\-zero " {" y | n }
 Set zeroing mode for thin pool. Note: already provisioned blocks from pool
 in non-zero mode are not cleared in unwritten parts when setting zero to
-\fIy\fP.
+\fBy\fP.
 .SH ENVIRONMENT VARIABLES
 .TP
 .B LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES
@@ -337,7 +345,10 @@ Changes the permission on volume lvol1 in volume group vg00 to be read-only:
 .B lvchange \-pr vg00/lvol1
 .SH SEE ALSO
 .BR lvm (8),
+.BR lvmetad (8),
+.BR lvs (8),
+.BR lvcreate (8),
+.BR vgchange (8),
 .BR lvmcache (7),
 .BR lvmthin (7),
-.BR lvcreate (8),
-.BR vgchange (8)
+.BR lvm.conf (5)


