From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 09:13:42 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20210412091342.8D0B23896820@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9eca1312569f89884ca4c0a767d6c603ab7613db
Commit:        9eca1312569f89884ca4c0a767d6c603ab7613db
Parent:        396d93937db940736675db13609640ac6856b912
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 12 11:11:51 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 11:12:40 2021 +0200

make: generate

Oops, previous generate was not correct.
---
 man/lvchange.8_pregen        | 132 ++++++++++++++++++------------------
 man/lvconvert.8_pregen       | 154 +++++++++++++++++++++---------------------
 man/lvcreate.8_pregen        | 156 +++++++++++++++++++++----------------------
 man/lvdisplay.8_pregen       |  88 ++++++++++++------------
 man/lvextend.8_pregen        |  72 ++++++++++----------
 man/lvm-fullreport.8_pregen  |  80 +++++++++++-----------
 man/lvm-lvpoll.8_pregen      |  48 ++++++-------
 man/lvmconfig.8_pregen       |  76 ++++++++++-----------
 man/lvmdevices.8_pregen      |  48 ++++++-------
 man/lvmdiskscan.8_pregen     |  40 +++++------
 man/lvreduce.8_pregen        |  54 +++++++--------
 man/lvremove.8_pregen        |  56 ++++++++--------
 man/lvrename.8_pregen        |  46 ++++++-------
 man/lvresize.8_pregen        |  68 +++++++++----------
 man/lvs.8_pregen             |  88 ++++++++++++------------
 man/lvscan.8_pregen          |  46 ++++++-------
 man/pvchange.8_pregen        |  60 ++++++++---------
 man/pvck.8_pregen            |  52 +++++++--------
 man/pvcreate.8_pregen        |  68 +++++++++----------
 man/pvdisplay.8_pregen       |  84 +++++++++++------------
 man/pvmove.8_pregen          |  56 ++++++++--------
 man/pvremove.8_pregen        |  42 ++++++------
 man/pvresize.8_pregen        |  42 ++++++------
 man/pvs.8_pregen             |  84 +++++++++++------------
 man/pvscan.8_pregen          |  60 ++++++++---------
 man/vgcfgbackup.8_pregen     |  48 ++++++-------
 man/vgcfgrestore.8_pregen    |  46 ++++++-------
 man/vgchange.8_pregen        | 108 +++++++++++++++---------------
 man/vgck.8_pregen            |  44 ++++++------
 man/vgconvert.8_pregen       |  52 +++++++--------
 man/vgcreate.8_pregen        |  84 +++++++++++------------
 man/vgdisplay.8_pregen       |  82 +++++++++++------------
 man/vgexport.8_pregen        |  48 ++++++-------
 man/vgextend.8_pregen        |  64 +++++++++---------
 man/vgimport.8_pregen        |  50 +++++++-------
 man/vgimportclone.8_pregen   |  44 ++++++------
 man/vgimportdevices.8_pregen |  50 +++++++-------
 man/vgmerge.8_pregen         |  42 ++++++------
 man/vgmknodes.8_pregen       |  48 ++++++-------
 man/vgreduce.8_pregen        |  52 +++++++--------
 man/vgremove.8_pregen        |  50 +++++++-------
 man/vgrename.8_pregen        |  44 ++++++------
 man/vgs.8_pregen             |  82 +++++++++++------------
 man/vgscan.8_pregen          |  44 ++++++------
 man/vgsplit.8_pregen         |  54 +++++++--------
 45 files changed, 1468 insertions(+), 1468 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 3d376996f..93c7311b5 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -594,7 +594,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
@@ -623,7 +623,7 @@ If auto_activation_volume_list is defined and empty, no LVs are autoactivated.
 Items included by auto_activation_volume_list will not be autoactivated if
 the autoactivation property has been disabled.
 See \fBlvmlockd\fP(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
-.TP
+.HP
 .ad l
 \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
 .br
@@ -638,14 +638,14 @@ and is the most restrictive mode.
 should only be used for recovery or repair.
 For default, see lvm.conf/activation_mode.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
 .ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.TP
+.HP
 .ad l
 \fB--alloc\fP 
 .nh
@@ -669,14 +669,14 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
@@ -692,14 +692,14 @@ cache pool LV. With \fBpassthrough\fP, all reads are served
 from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--cachepolicy\fP \fIString\fP
 .br
 .ad b
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--cachesettings\fP \fIString\fP
 .br
@@ -711,21 +711,21 @@ The special string value \fBdefault\fP switches
 settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--compression\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Controls whether compression is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -734,7 +734,7 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
 .br
@@ -744,35 +744,35 @@ Default is no contiguous allocation based on a next free principle.
 It is only possible to change a non-contiguous allocation policy
 to contiguous if all of the allocated physical extents in the LV
 are already contiguous.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--deduplication\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Controls whether deduplication is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.TP
+.HP
 .ad l
 \fB--deltag\fP \fITag\fP
 .br
 .ad b
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.TP
+.HP
 .ad l
 \fB--detachprofile\fP
 .br
 .ad b
 Detaches a metadata profile from a VG or LV.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -780,7 +780,7 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -790,7 +790,7 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
@@ -803,14 +803,14 @@ allow reuse of unneeded extents in the thin pool.
 \fBpassdown\fP causes the thin pool to process discards itself
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
@@ -823,60 +823,60 @@ period of time to allow the thin pool to be extended.
 Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
 .br
 .ad b
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--ignoremonitoring\fP
 .br
 .ad b
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
 .ad b
 Sets the major number of an LV block device.
-.TP
+.HP
 .ad l
 \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
@@ -885,20 +885,20 @@ Sets the maximum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
 .ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--minor\fP \fINumber\fP
 .br
 .ad b
 Sets the minor number of an LV block device.
-.TP
+.HP
 .ad l
 \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
@@ -907,7 +907,7 @@ Sets the minimum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
 .br
@@ -916,13 +916,13 @@ Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See \fBdmeventd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -931,7 +931,7 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB-P\fP|\fB--partial\fP
 .br
@@ -940,19 +940,19 @@ Commands will do their best to activate LVs with missing PV extents.
 Missing extents may be replaced with error or zero segments
 according to the lvm.conf missing_stripe_filler setting.
 Metadata may not be changed with this option.
-.TP
+.HP
 .ad l
 \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
 .br
 .ad b
 Set access permission to read only \fBr\fP or read and write \fBrw\fP.
-.TP
+.HP
 .ad l
 \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 When yes, makes the specified minor number persistent.
-.TP
+.HP
 .ad l
 \fB--poll\fP \fBy\fP|\fBn\fP
 .br
@@ -964,21 +964,21 @@ When no, background transformation of an LV will not occur, and the
 transformation will not complete. It may not be appropriate to immediately
 poll an LV after activation, in which case --poll n can be used to defer
 polling until a later --poll y command.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
@@ -987,7 +987,7 @@ Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -998,7 +998,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--rebuild\fP \fIPV\fP
 .br
@@ -1009,7 +1009,7 @@ Use this option in place of --resync or --syncaction repair when the
 PVs with corrupted data are known, and their data should be reconstructed
 rather than reconstructing default (rotating) data.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--refresh\fP
 .br
@@ -1018,7 +1018,7 @@ If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -1029,7 +1029,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--resync\fP
 .br
@@ -1041,7 +1041,7 @@ During synchronization, data is read from the primary mirror device
 and copied to the others. This can take considerable time, during
 which the LV is without a complete redundant copy of the data.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -1054,7 +1054,7 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .br
@@ -1065,7 +1065,7 @@ An LV with this flag set is not activated unless the
 This flag is set by default on new thin snapshot LVs.
 The flag is not applied to deactivation.
 The current value of the flag is indicated in the lvs lv_attr bits.
-.TP
+.HP
 .ad l
 \fB--setautoactivation\fP \fBy\fP|\fBn\fP
 .br
@@ -1079,7 +1079,7 @@ If autoactivation is disabled on a VG, no LVs will be autoactivated
 in that VG, and the LV autoactivation property has no effect.
 If autoactivation is enabled on a VG, autoactivation can be disabled
 for individual LVs.
-.TP
+.HP
 .ad l
 \fB--[raid]syncaction\fP \fBcheck\fP|\fBrepair\fP
 .br
@@ -1091,7 +1091,7 @@ blocks in the array and check for discrepancies
 \fBcheck\fP will count but not correct discrepancies.
 \fBrepair\fP will correct discrepancies.
 See lvs for reporting discrepancies found or repaired.
-.TP
+.HP
 .ad l
 \fB--sysinit\fP
 .br
@@ -1103,7 +1103,7 @@ acts as a shortcut which selects an appropriate set of options. Currently,
 this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
 --poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -1113,20 +1113,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB--[raid]writebehind\fP \fINumber\fP
 .br
@@ -1137,7 +1137,7 @@ Once this value is exceeded, writes become synchronous (i.e. all writes
 to the constituent devices must complete before the array signals the
 write has completed). Setting the value to zero clears the preference
 and allows the system to choose the value arbitrarily.
-.TP
+.HP
 .ad l
 \fB--[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
 .br
@@ -1150,7 +1150,7 @@ It is also possible to remove the write-mostly flag by adding the
 suffix \fB:n\fP at the end of the PV name, or to toggle the value with
 the suffix \fB:t\fP. Repeat this option to change the attribute on
 multiple PVs.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -1158,7 +1158,7 @@ multiple PVs.
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.TP
+.HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
@@ -1166,33 +1166,33 @@ answer yes. Use with extreme caution.
 Set zeroing mode for thin pool. Note: already provisioned blocks from pool
 in non-zero mode are not cleared in unwritten parts when setting --zero y.
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index cfe3a56ff..03e6d62dd 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1196,7 +1196,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--alloc\fP 
 .nh
@@ -1220,7 +1220,7 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.TP
+.HP
 .ad l
 \fB-b\fP|\fB--background\fP
 .br
@@ -1228,7 +1228,7 @@ See \fBlvm\fP(8) for more information about allocation.
 If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
 background.
-.TP
+.HP
 .ad l
 \fB-H\fP|\fB--cache\fP
 .br
@@ -1236,19 +1236,19 @@ background.
 Specifies the command is handling a cache LV or cache pool.
 See --type cache and --type cache-pool.
 See \fBlvmcache\fP(7) for more information about LVM caching.
-.TP
+.HP
 .ad l
 \fB--cachedevice\fP \fIPV\fP
 .br
 .ad b
 The name of a device to use for a cache.
-.TP
+.HP
 .ad l
 \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
 .ad b
 Specifies the cache metadata format used by cache target.
-.TP
+.HP
 .ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
@@ -1264,20 +1264,20 @@ cache pool LV. With \fBpassthrough\fP, all reads are served
 from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--cachepolicy\fP \fIString\fP
 .br
 .ad b
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--cachepool\fP \fILV\fP
 .br
 .ad b
 The name of a cache pool.
-.TP
+.HP
 .ad l
 \fB--cachesettings\fP \fIString\fP
 .br
@@ -1289,19 +1289,19 @@ The special string value \fBdefault\fP switches
 settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--cachesize\fP \fISize\fP[m|UNIT]
 .br
 .ad b
 The size of cache to use.
-.TP
+.HP
 .ad l
 \fB--cachevol\fP \fILV\fP
 .br
 .ad b
 The name of a cache volume.
-.TP
+.HP
 .ad l
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .br
@@ -1316,21 +1316,21 @@ and the default value starts with 64 and scales up to fit the
 pool metadata size within 128MiB, if the pool metadata size is not specified.
 The value must be a multiple of 64KiB.
 See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--compression\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Controls whether compression is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -1339,21 +1339,21 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--deduplication\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Controls whether deduplication is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -1361,7 +1361,7 @@ See \fBlvmvdo\fP(7) for more information about VDO usage.
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -1371,7 +1371,7 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
@@ -1384,14 +1384,14 @@ allow reuse of unneeded extents in the thin pool.
 \fBpassdown\fP causes the thin pool to process discards itself
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
@@ -1404,53 +1404,53 @@ period of time to allow the thin pool to be extended.
 Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
 .ad b
 Report progress at regular intervals.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--merge\fP
 .br
 .ad b
 An alias for --mergethin, --mergemirrors, or --mergesnapshot,
 depending on the type of LV.
-.TP
+.HP
 .ad l
 \fB--mergemirrors\fP
 .br
 .ad b
 Merge LV images that were split from a raid1 LV.
 See --splitmirrors with --trackchanges.
-.TP
+.HP
 .ad l
 \fB--mergesnapshot\fP
 .br
@@ -1467,7 +1467,7 @@ reads or writes to the origin appear as being directed to the snapshot
 being merged. When the merge finishes, the merged snapshot is removed.
 Multiple snapshots may be specified on the command line or a @tag may be
 used to specify multiple snapshots be merged to their respective origin.
-.TP
+.HP
 .ad l
 \fB--mergethin\fP
 .br
@@ -1476,14 +1476,14 @@ Merge thin LV into its origin LV.
 The origin thin LV takes the content of the thin snapshot,
 and the thin snapshot LV is removed.
 See \fBlvmthin\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
 .ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
 .br
@@ -1497,7 +1497,7 @@ In this case, the mirror must be synchronized (by copying LV data from
 the first device to others) each time the LV is activated, e.g. after reboot.
 \fBmirrored\fP is a persistent log that is itself mirrored, but
 should be avoided. Instead, use the raid1 type for log redundancy.
-.TP
+.HP
 .ad l
 \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP
 .br
@@ -1518,7 +1518,7 @@ the number is added to the current number of images,
 or the minus prefix \fB-\fP can be used, in which case
 the number is subtracted from the current number of images.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
@@ -1526,13 +1526,13 @@ See \fBlvmraid\fP(7) for more information.
 Specifies the name of a new LV.
 When unspecified, a default name of "lvol#" is
 generated, where # is a number generated by LVM.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -1541,7 +1541,7 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB--originname\fP \fILV\fP
 .br
@@ -1549,19 +1549,19 @@ ignore the devices LVM creates.
 Specifies the name to use for the external origin LV when converting an LV
 to a thin LV. The LV being converted becomes a read-only external origin
 with this name.
-.TP
+.HP
 .ad l
 \fB--poolmetadata\fP \fILV\fP
 .br
 .ad b
 The name of a an LV to use for storing pool metadata.
-.TP
+.HP
 .ad l
 \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
 .br
 .ad b
 Specifies the size of the new pool metadata LV.
-.TP
+.HP
 .ad l
 \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
 .br
@@ -1569,27 +1569,27 @@ Specifies the size of the new pool metadata LV.
 Enable or disable the automatic creation and management of a
 spare pool metadata LV in the VG. A spare metadata LV is reserved
 space that can be used when repairing a pool.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--raidintegrity\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Enable or disable data integrity checksums for raid images.
-.TP
+.HP
 .ad l
 \fB--raidintegrityblocksize\fP \fINumber\fP
 .br
@@ -1600,7 +1600,7 @@ logical block size, or the file system block size.
 It may be less than the file system block size, but not
 less than the device logical block size.
 Possible values: 512, 1024, 2048, 4096.
-.TP
+.HP
 .ad l
 \fB--raidintegritymode\fP \fIString\fP
 .br
@@ -1612,7 +1612,7 @@ The journal mode doubles writes to storage, but can improve performance for
 scattered writes packed into a single journal write.
 bitmap mode can in theory achieve full write throughput of the device,
 but would not benefit from the potential scattered write optimization.
-.TP
+.HP
 .ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
@@ -1621,7 +1621,7 @@ Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
-.TP
+.HP
 .ad l
 \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
 .br
@@ -1629,7 +1629,7 @@ a suitable value automatically.
 Size of each raid or mirror synchronization region.
 lvm.conf activation/raid_region_size can be used to
 configure a default.
-.TP
+.HP
 .ad l
 \fB--repair\fP
 .br
@@ -1637,7 +1637,7 @@ configure a default.
 Replace failed PVs in a raid or mirror LV, or run a repair
 utility on a thin pool. See \fBlvmraid\fP(7) and \fBlvmthin\fP(7)
 for more information.
-.TP
+.HP
 .ad l
 \fB--replace\fP \fIPV\fP
 .br
@@ -1646,21 +1646,21 @@ Replace a specific PV in a raid LV with another PV.
 The new PV to use can be optionally specified after the LV.
 Multiple PVs can be replaced by repeating this option.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-s\fP|\fB--snapshot\fP
 .br
 .ad b
 Combine a former COW snapshot LV with a former origin LV to reverse
 a previous --splitsnapshot command.
-.TP
+.HP
 .ad l
 \fB--splitcache\fP
 .br
 .ad b
 Separates a cache pool from a cache LV, and keeps the unused cache pool LV.
 Before the separation, the cache is flushed. Also see --uncache.
-.TP
+.HP
 .ad l
 \fB--splitmirrors\fP \fINumber\fP
 .br
@@ -1670,7 +1670,7 @@ and uses them to create a new LV. If --trackchanges is also specified,
 changes to the raid1 LV are tracked while the split LV remains detached.
 If --name is specified, then the images are permanently split from the
 original LV and changes are not tracked.
-.TP
+.HP
 .ad l
 \fB--splitsnapshot\fP
 .br
@@ -1678,13 +1678,13 @@ original LV and changes are not tracked.
 Separates a COW snapshot from its origin LV. The LV that is split off
 contains the chunks that differ from the origin LV along with metadata
 describing them. This LV can be wiped and then destroyed with lvremove.
-.TP
+.HP
 .ad l
 \fB--startpoll\fP
 .br
 .ad b
 Start polling an LV to continue processing a conversion.
-.TP
+.HP
 .ad l
 \fB--stripes\fP \fINumber\fP
 .br
@@ -1694,14 +1694,14 @@ PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
 the stripe size (see --stripesize). This does not apply to
 existing allocated space, only newly allocated space can be striped.
-.TP
+.HP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
 .ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
-.TP
+.HP
 .ad l
 \fB--swapmetadata\fP
 .br
@@ -1712,7 +1712,7 @@ Use for repair only. When the metadata LV is swapped out of the pool, it can
 be activated directly and used with thin provisioning tools:
 \fBcache_dump\fP(8), \fBcache_repair\fP(8), \fBcache_restore\fP(8),
 \fBthin_dump\fP(8), \fBthin_repair\fP(8), \fBthin_restore\fP(8).
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -1722,7 +1722,7 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-T\fP|\fB--thin\fP
 .br
@@ -1730,13 +1730,13 @@ back metadata it believes has changed but hasn't.
 Specifies the command is handling a thin LV or thin pool.
 See --type thin, --type thin-pool, and --virtualsize.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
-.TP
+.HP
 .ad l
 \fB--thinpool\fP \fILV\fP
 .br
 .ad b
 The name of a thin pool LV.
-.TP
+.HP
 .ad l
 \fB--trackchanges\fP
 .br
@@ -1749,7 +1749,7 @@ Only the regions with changed data are resynchronized during merge.
 While a raid1 LV is tracking changes, operations on it are limited to
 merging the split image (see --mergemirrors) or permanently splitting
 the image (see --splitmirrors with --name.
-.TP
+.HP
 .ad l
 \fB--type\fP 
 .nh
@@ -1768,41 +1768,41 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
-.TP
+.HP
 .ad l
 \fB--uncache\fP
 .br
 .ad b
 Separates a cache pool from a cache LV, and deletes the unused cache pool LV.
 Before the separation, the cache is flushed. Also see --splitcache.
-.TP
+.HP
 .ad l
 \fB--usepolicies\fP
 .br
 .ad b
 Perform an operation according to the policy configured in lvm.conf
 or a profile.
-.TP
+.HP
 .ad l
 \fB--vdopool\fP \fILV\fP
 .br
 .ad b
 The name of a VDO pool LV.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
 .br
@@ -1819,7 +1819,7 @@ When using a snapshot to create a sparse LV, a hidden virtual device
 is created using the zero target, and the LV has the suffix _vorigin.
 Snapshots are less efficient than thin provisioning when creating
 large sparse LVs (GiB).
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -1827,7 +1827,7 @@ large sparse LVs (GiB).
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.TP
+.HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
@@ -1837,18 +1837,18 @@ snapshot. If the LV is read-only, the snapshot will not be zeroed.
 For thin pools, this controls zeroing of provisioned blocks.
 Provisioning of large zeroed chunks negatively impacts performance.
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -1858,16 +1858,16 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index e804f9ce0..140344fa8 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -1257,7 +1257,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
@@ -1274,14 +1274,14 @@ If autoactivation \fBay\fP is used, the LV is only activated
 if it matches an item in lvm.conf activation/auto_activation_volume_list.
 \fBay\fP implies --zero n and --wipesignatures n.
 See \fBlvmlockd\fP(8) for more information about activation options for shared VGs.
-.TP
+.HP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
 .ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.TP
+.HP
 .ad l
 \fB--alloc\fP 
 .nh
@@ -1305,14 +1305,14 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB-H\fP|\fB--cache\fP
 .br
@@ -1320,19 +1320,19 @@ Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information
 Specifies the command is handling a cache LV or cache pool.
 See --type cache and --type cache-pool.
 See \fBlvmcache\fP(7) for more information about LVM caching.
-.TP
+.HP
 .ad l
 \fB--cachedevice\fP \fIPV\fP
 .br
 .ad b
 The name of a device to use for a cache.
-.TP
+.HP
 .ad l
 \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
 .ad b
 Specifies the cache metadata format used by cache target.
-.TP
+.HP
 .ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
@@ -1348,20 +1348,20 @@ cache pool LV. With \fBpassthrough\fP, all reads are served
 from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--cachepolicy\fP \fIString\fP
 .br
 .ad b
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--cachepool\fP \fILV\fP
 .br
 .ad b
 The name of a cache pool.
-.TP
+.HP
 .ad l
 \fB--cachesettings\fP \fIString\fP
 .br
@@ -1373,19 +1373,19 @@ The special string value \fBdefault\fP switches
 settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--cachesize\fP \fISize\fP[m|UNIT]
 .br
 .ad b
 The size of cache to use.
-.TP
+.HP
 .ad l
 \fB--cachevol\fP \fILV\fP
 .br
 .ad b
 The name of a cache volume.
-.TP
+.HP
 .ad l
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .br
@@ -1400,21 +1400,21 @@ and the default value starts with 64 and scales up to fit the
 pool metadata size within 128MiB, if the pool metadata size is not specified.
 The value must be a multiple of 64KiB.
 See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--compression\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Controls whether compression is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -1423,7 +1423,7 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
 .br
@@ -1433,21 +1433,21 @@ Default is no contiguous allocation based on a next free principle.
 It is only possible to change a non-contiguous allocation policy
 to contiguous if all of the allocated physical extents in the LV
 are already contiguous.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--deduplication\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Controls whether deduplication is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -1455,7 +1455,7 @@ See \fBlvmvdo\fP(7) for more information about VDO usage.
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -1465,7 +1465,7 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
@@ -1478,14 +1478,14 @@ allow reuse of unneeded extents in the thin pool.
 \fBpassdown\fP causes the thin pool to process discards itself
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
@@ -1498,7 +1498,7 @@ period of time to allow the thin pool to be extended.
 Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT]
 .br
@@ -1518,46 +1518,46 @@ the whole origin).
 When expressed as a percentage, the size defines an upper limit for the
 number of logical extents in the new LV. The precise number of logical
 extents in the new LV is not determined until the command has completed.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
 .br
 .ad b
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
-.TP
+.HP
 .ad l
 \fB--ignoremonitoring\fP
 .br
 .ad b
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
 .ad b
 Sets the major number of an LV block device.
-.TP
+.HP
 .ad l
 \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
@@ -1566,20 +1566,20 @@ Sets the maximum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
 .ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--minor\fP \fINumber\fP
 .br
 .ad b
 Sets the minor number of an LV block device.
-.TP
+.HP
 .ad l
 \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
@@ -1588,7 +1588,7 @@ Sets the minimum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
 .br
@@ -1602,7 +1602,7 @@ In this case, the mirror must be synchronized (by copying LV data from
 the first device to others) each time the LV is activated, e.g. after reboot.
 \fBmirrored\fP is a persistent log that is itself mirrored, but
 should be avoided. Instead, use the raid1 type for log redundancy.
-.TP
+.HP
 .ad l
 \fB-m\fP|\fB--mirrors\fP \fINumber\fP
 .br
@@ -1620,7 +1620,7 @@ Use lvm.conf global/mirror_segtype_default and
 global/raid10_segtype_default to configure the default types.
 See the --nosync option for avoiding initial image synchronization.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
 .br
@@ -1629,7 +1629,7 @@ Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See \fBdmeventd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
@@ -1637,13 +1637,13 @@ See \fBdmeventd\fP(8) for more information.
 Specifies the name of a new LV.
 When unspecified, a default name of "lvol#" is
 generated, where # is a number generated by LVM.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--nosync\fP
 .br
@@ -1660,7 +1660,7 @@ This option is not valid for raid6, because raid6 relies on proper parity
 to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -1669,25 +1669,25 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
 .br
 .ad b
 Set access permission to read only \fBr\fP or read and write \fBrw\fP.
-.TP
+.HP
 .ad l
 \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 When yes, makes the specified minor number persistent.
-.TP
+.HP
 .ad l
 \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
 .br
 .ad b
 Specifies the size of the new pool metadata LV.
-.TP
+.HP
 .ad l
 \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
 .br
@@ -1695,27 +1695,27 @@ Specifies the size of the new pool metadata LV.
 Enable or disable the automatic creation and management of a
 spare pool metadata LV in the VG. A spare metadata LV is reserved
 space that can be used when repairing a pool.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--raidintegrity\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Enable or disable data integrity checksums for raid images.
-.TP
+.HP
 .ad l
 \fB--raidintegrityblocksize\fP \fINumber\fP
 .br
@@ -1726,7 +1726,7 @@ logical block size, or the file system block size.
 It may be less than the file system block size, but not
 less than the device logical block size.
 Possible values: 512, 1024, 2048, 4096.
-.TP
+.HP
 .ad l
 \fB--raidintegritymode\fP \fIString\fP
 .br
@@ -1738,7 +1738,7 @@ The journal mode doubles writes to storage, but can improve performance for
 scattered writes packed into a single journal write.
 bitmap mode can in theory achieve full write throughput of the device,
 but would not benefit from the potential scattered write optimization.
-.TP
+.HP
 .ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
@@ -1747,7 +1747,7 @@ Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
-.TP
+.HP
 .ad l
 \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
 .br
@@ -1755,7 +1755,7 @@ a suitable value automatically.
 Size of each raid or mirror synchronization region.
 lvm.conf activation/raid_region_size can be used to
 configure a default.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -1766,7 +1766,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .br
@@ -1777,7 +1777,7 @@ An LV with this flag set is not activated unless the
 This flag is set by default on new thin snapshot LVs.
 The flag is not applied to deactivation.
 The current value of the flag is indicated in the lvs lv_attr bits.
-.TP
+.HP
 .ad l
 \fB--setautoactivation\fP \fBy\fP|\fBn\fP
 .br
@@ -1791,7 +1791,7 @@ If autoactivation is disabled on a VG, no LVs will be autoactivated
 in that VG, and the LV autoactivation property has no effect.
 If autoactivation is enabled on a VG, autoactivation can be disabled
 for individual LVs.
-.TP
+.HP
 .ad l
 \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
 .br
@@ -1800,7 +1800,7 @@ Specifies the size of the new LV.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
-.TP
+.HP
 .ad l
 \fB-s\fP|\fB--snapshot\fP
 .br
@@ -1830,7 +1830,7 @@ A small amount of the COW snapshot LV size is used to track COW block
 locations, so the full size is not available for COW data blocks.
 Use lvs to check how much space is used, and see --monitor to
 to automatically extend the size to avoid running out of space.
-.TP
+.HP
 .ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
 .br
@@ -1847,14 +1847,14 @@ when unspecified, the default depends on the RAID type
 (raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)
 To stripe a new raid LV across all PVs by default,
 see lvm.conf allocation/raid_stripe_all_devices.
-.TP
+.HP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
 .ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -1864,7 +1864,7 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-T\fP|\fB--thin\fP
 .br
@@ -1872,13 +1872,13 @@ back metadata it believes has changed but hasn't.
 Specifies the command is handling a thin LV or thin pool.
 See --type thin, --type thin-pool, and --virtualsize.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
-.TP
+.HP
 .ad l
 \fB--thinpool\fP \fILV\fP
 .br
 .ad b
 The name of a thin pool LV.
-.TP
+.HP
 .ad l
 \fB--type\fP 
 .nh
@@ -1897,7 +1897,7 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
-.TP
+.HP
 .ad l
 \fB--vdo\fP
 .br
@@ -1905,27 +1905,27 @@ Use inferred types with care because it can lead to unexpected results.
 Specifies the command is handling VDO LV.
 See --type vdo.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.TP
+.HP
 .ad l
 \fB--vdopool\fP \fILV\fP
 .br
 .ad b
 The name of a VDO pool LV.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
 .br
@@ -1942,7 +1942,7 @@ When using a snapshot to create a sparse LV, a hidden virtual device
 is created using the zero target, and the LV has the suffix _vorigin.
 Snapshots are less efficient than thin provisioning when creating
 large sparse LVs (GiB).
-.TP
+.HP
 .ad l
 \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP
 .br
@@ -1960,7 +1960,7 @@ signatures that are recognized).
 Otherwise, native LVM code is used to detect signatures
 (only MD RAID, swap and LUKS signatures are detected in this case.)
 The LV is not wiped if the read only flag is set.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -1968,7 +1968,7 @@ The LV is not wiped if the read only flag is set.
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.TP
+.HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
@@ -1980,21 +1980,21 @@ For thin pools, this controls zeroing of provisioned blocks.
 LV is not zeroed if the read only flag is set.
 Warning: trying to mount an unzeroed LV can cause the system to hang.
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
 For lvcreate, the required VG positional arg may be
 omitted when the VG name is included in another option,
 e.g. --name VG/LV.
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -2004,11 +2004,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index d1370d616..be1c8b73e 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -186,13 +186,13 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--aligned\fP
 .br
 .ad b
 Use with --separator to align the output columns
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
@@ -200,7 +200,7 @@ Use with --separator to align the output columns
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
-.TP
+.HP
 .ad l
 \fB--binary\fP
 .br
@@ -208,28 +208,28 @@ which are not independently accessible, e.g. not mountable.
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.TP
+.HP
 .ad l
 \fB-c\fP|\fB--colon\fP
 .br
 .ad b
 Generate colon separated output for easier parsing in scripts or programs.
 Also see \fBvgs\fP(8) which provides considerably more control over the output.
-.TP
+.HP
 .ad l
 \fB-C\fP|\fB--columns\fP
 .br
 .ad b
 Display output in columns, the equivalent of \fBvgs\fP(8).
 Options listed are the same as options given in \fBvgs\fP(8).
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -238,20 +238,20 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 .ad b
 See \fBlvmreport\fP(7).
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -259,7 +259,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -269,27 +269,27 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--foreign\fP
 .br
 .ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-H\fP|\fB--history\fP
 .br
@@ -297,33 +297,33 @@ Display help text.
 Include historical LVs in the output.
 (This has no effect unless LVs were removed while
 lvm.conf metadata/record_lvs_history was enabled.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--logonly\fP
 .br
 .ad b
 Suppress command report and display only log report.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-m\fP|\fB--maps\fP
 .br
@@ -331,27 +331,27 @@ Display long help text.
 Display the mapping of logical extents to PVs and physical extents.
 To map physical extents to logical extents use:
 pvs --segments -o+lv_name,seg_start_pe,segtype
-.TP
+.HP
 .ad l
 \fB--noheadings\fP
 .br
 .ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--nosuffix\fP
 .br
 .ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.TP
+.HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
@@ -373,21 +373,21 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -398,7 +398,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -409,12 +409,12 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--segments\fP
 .br
 .ad b
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -427,13 +427,13 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 .ad b
 String to use to separate each column. Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--shared\fP
 .br
@@ -441,14 +441,14 @@ String to use to separate each column. Useful if grepping the output.
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.TP
+.HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
 .ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -458,13 +458,13 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--unbuffered\fP
 .br
 .ad b
 Produce output immediately without sorting or aligning the columns properly.
-.TP
+.HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
@@ -475,20 +475,20 @@ human-(r)eadable with '<' rounding indicator,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -497,25 +497,25 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index a4a90994d..83216b972 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -370,7 +370,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--alloc\fP 
 .nh
@@ -394,21 +394,21 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -417,14 +417,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -432,7 +432,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -442,14 +442,14 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--extents\fP [\fB+\fP]\fINumber\fP[PERCENT]
 .br
@@ -472,39 +472,39 @@ extents in the new LV is not determined until the command has completed.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-m\fP|\fB--mirrors\fP \fINumber\fP
 .br
 .ad b
 Not used.
-.TP
+.HP
 .ad l
 \fB-n\fP|\fB--nofsck\fP
 .br
@@ -512,13 +512,13 @@ Not used.
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--nosync\fP
 .br
@@ -535,7 +535,7 @@ This option is not valid for raid6, because raid6 relies on proper parity
 to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -544,7 +544,7 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
@@ -552,21 +552,21 @@ ignore the devices LVM creates.
 Specifies the new size of the pool metadata LV.
 The plus prefix \fB+\fP can be used, in which case
 the value is added to the current size.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -577,13 +577,13 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
 .ad b
 Resize underlying filesystem together with the LV using fsadm(8).
-.TP
+.HP
 .ad l
 \fB-L\fP|\fB--size\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
@@ -595,7 +595,7 @@ greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.TP
+.HP
 .ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
 .br
@@ -612,14 +612,14 @@ when unspecified, the default depends on the RAID type
 (raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)
 To stripe a new raid LV across all PVs by default,
 see lvm.conf allocation/raid_stripe_all_devices.
-.TP
+.HP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
 .ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -629,7 +629,7 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--type\fP 
 .nh
@@ -648,27 +648,27 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
-.TP
+.HP
 .ad l
 \fB--usepolicies\fP
 .br
 .ad b
 Perform an operation according to the policy configured in lvm.conf
 or a profile.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -677,14 +677,14 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -694,11 +694,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 7a63dc4ad..33e2dfaad 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -178,18 +178,18 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--aligned\fP
 .br
 .ad b
 Use with --separator to align the output columns
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
-.TP
+.HP
 .ad l
 \fB--binary\fP
 .br
@@ -197,14 +197,14 @@ Use with --separator to align the output columns
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -213,20 +213,20 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 .ad b
 See \fBlvmreport\fP(7).
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -234,7 +234,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -244,53 +244,53 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--foreign\fP
 .br
 .ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--logonly\fP
 .br
 .ad b
 Suppress command report and display only log report.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nameprefixes\fP
 .br
@@ -298,27 +298,27 @@ Display long help text.
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
-.TP
+.HP
 .ad l
 \fB--noheadings\fP
 .br
 .ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--nosuffix\fP
 .br
 .ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.TP
+.HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
@@ -340,21 +340,21 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -365,7 +365,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -376,13 +376,13 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--rows\fP
 .br
 .ad b
 Output columns as rows.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -395,13 +395,13 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 .ad b
 String to use to separate each column. Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--shared\fP
 .br
@@ -409,14 +409,14 @@ String to use to separate each column. Useful if grepping the output.
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.TP
+.HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
 .ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -426,13 +426,13 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--unbuffered\fP
 .br
 .ad b
 Produce output immediately without sorting or aligning the columns properly.
-.TP
+.HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
@@ -443,27 +443,27 @@ human-(r)eadable with '<' rounding indicator,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.TP
+.HP
 .ad l
 \fB--unquoted\fP
 .br
 .ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -472,15 +472,15 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 328e980c0..3aff67d19 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -104,27 +104,27 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--abort\fP
 .br
 .ad b
 Stop processing a poll operation in lvmpolld.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -133,14 +133,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -148,7 +148,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -158,72 +158,72 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--handlemissingpvs\fP
 .br
 .ad b
 Allows a polling operation to continue when PVs are missing,
 e.g. for repairs due to faulty devices.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
 .ad b
 Report progress at regular intervals.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP
 .br
 .ad b
 The command to perform from lvmpolld.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -233,20 +233,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -255,16 +255,16 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 8ddee04a7..469a6b9e8 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -177,7 +177,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--atversion\fP \fIString\fP
 .br
@@ -189,14 +189,14 @@ at this LVM version will be considered only. This can be used
 to display a configuration that a certain LVM version understands and
 which does not contain any newer settings for which LVM would
 issue a warning message when checking the configuration.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -205,14 +205,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -220,7 +220,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -230,32 +230,32 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
 .ad b
 Write output to the named file.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignoreadvanced\fP
 .br
 .ad b
 Exclude advanced configuration settings from the output.
-.TP
+.HP
 .ad l
 \fB--ignorelocal\fP
 .br
@@ -264,7 +264,7 @@ Ignore the local section. The local section should be defined in
 the lvmlocal.conf file, and should contain config settings
 specific to the local host which should not be copied to
 other hosts.
-.TP
+.HP
 .ad l
 \fB--ignoreunsupported\fP
 .br
@@ -274,27 +274,27 @@ either used for debugging and development purposes only or their support is not
 yet complete and they are not meant to be used in production. The \fBcurrent\fP
 and \fBdiff\fP types include unsupported settings in their output by default,
 all the other types ignore unsupported settings.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--list\fP
 .br
 .ad b
 List config settings with summarizing comment. This is the same as using
 options --typeconfig list --withsummary.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--mergedconfig\fP
 .br
@@ -306,34 +306,34 @@ merge all the contents of the "config cascade" before displaying it.
 Without merging, only the configuration at the front of the
 cascade is displayed.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
 .ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--showdeprecated\fP
 .br
@@ -344,7 +344,7 @@ with --atversion, deprecated settings are automatically included
 if the specified version is lower than the version in which the settings were
 deprecated. The current and diff types include deprecated settings
 in their output by default, all the other types ignore deprecated settings.
-.TP
+.HP
 .ad l
 \fB--showunsupported\fP
 .br
@@ -354,7 +354,7 @@ are either used for debugging or development purposes only, or their support
 is not yet complete and they are not meant to be used in production. The
 current and diff types include unsupported settings in their
 output by default, all the other types ignore unsupported settings.
-.TP
+.HP
 .ad l
 \fB--sinceversion\fP \fIString\fP
 .br
@@ -363,7 +363,7 @@ Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 This option is currently applicable only with --typeconfig new
 to display all configuration settings introduced since given version.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -373,7 +373,7 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--typeconfig\fP 
 .nh
@@ -413,13 +413,13 @@ with their default values.
 \fBprofilable-command\fP prints settings with their default values that can be set from a command profile.
 \fBprofilable-metadata\fP prints settings with their default values that can be set from a metadata profile.
 Also see \fBlvm.conf\fP(5).
-.TP
+.HP
 .ad l
 \fB--unconfigured\fP
 .br
 .ad b
 Internal option used for generating config file during build.
-.TP
+.HP
 .ad l
 \fB--validate\fP
 .br
@@ -429,51 +429,51 @@ return code. The validation is done only for the configuration
@the front of the "config cascade". To validate the whole
 merged configuration tree, also use --mergedconfig.
 The validation is done even if lvm.conf config/checks is disabled.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB--withcomments\fP
 .br
 .ad b
 Display a full comment for each configuration node. For deprecated
 settings, also display comments about deprecation.
-.TP
+.HP
 .ad l
 \fB--withgeneralpreamble\fP
 .br
 .ad b
 Include general config file preamble.
-.TP
+.HP
 .ad l
 \fB--withlocalpreamble\fP
 .br
 .ad b
 Include local config file preamble.
-.TP
+.HP
 .ad l
 \fB--withspaces\fP
 .br
 .ad b
 Where appropriate, add more spaces in output for better readability.
-.TP
+.HP
 .ad l
 \fB--withsummary\fP
 .br
 .ad b
 Display a one line comment for each configuration node.
-.TP
+.HP
 .ad l
 \fB--withversions\fP
 .br
@@ -481,7 +481,7 @@ Display a one line comment for each configuration node.
 Also display a comment containing the version of introduction for
 each configuration node. If the setting is deprecated, also display
 the version since which it is deprecated.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -490,11 +490,11 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvmdevices.8_pregen b/man/lvmdevices.8_pregen
index f576bdea4..6bdb5ff26 100644
--- a/man/lvmdevices.8_pregen
+++ b/man/lvmdevices.8_pregen
@@ -309,32 +309,32 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--adddev\fP \fIPV\fP
 .br
 .ad b
 Add a device to the devices file.
-.TP
+.HP
 .ad l
 \fB--addpvid\fP \fIString\fP
 .br
 .ad b
 Find a device with the PVID and add the device to the devices file.
-.TP
+.HP
 .ad l
 \fB--check\fP
 .br
 .ad b
 Check the content of the devices file.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -343,26 +343,26 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--deldev\fP \fIPV\fP
 .br
 .ad b
 Remove a device from the devices file.
-.TP
+.HP
 .ad l
 \fB--delpvid\fP \fIString\fP
 .br
 .ad b
 Remove a device with the PVID from the devices file.
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -370,7 +370,7 @@ Remove a device with the PVID from the devices file.
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -380,53 +380,53 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -436,26 +436,26 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--update\fP
 .br
 .ad b
 Update the content of the devices file.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -464,11 +464,11 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index 0fb64dbe3..f6cc0e2e2 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -99,14 +99,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -115,14 +115,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -130,7 +130,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -140,59 +140,59 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--lvmpartition\fP
 .br
 .ad b
 Only report PVs.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -203,7 +203,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -213,20 +213,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -235,11 +235,11 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 50c9ae453..49c9465d9 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -130,21 +130,21 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -153,14 +153,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -168,7 +168,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -178,14 +178,14 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--extents\fP [\fB-\fP]\fINumber\fP[PERCENT]
 .br
@@ -208,33 +208,33 @@ extents in the new LV is not determined until the command has completed.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-n\fP|\fB--nofsck\fP
 .br
@@ -242,13 +242,13 @@ Display long help text.
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -257,21 +257,21 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -282,13 +282,13 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
 .ad b
 Resize underlying filesystem together with the LV using fsadm(8).
-.TP
+.HP
 .ad l
 \fB-L\fP|\fB--size\fP [\fB-\fP]\fISize\fP[m|UNIT]
 .br
@@ -300,7 +300,7 @@ greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -310,20 +310,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -332,16 +332,16 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index ca62d5d65..53ba71e0b 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -134,21 +134,21 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -157,14 +157,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -172,7 +172,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -182,40 +182,40 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nohistory\fP
 .br
@@ -223,13 +223,13 @@ Display long help text.
 Do not record history of LVs being removed.
 This has no effect unless the configuration setting
 metadata/record_lvs_history is enabled.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -238,21 +238,21 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -263,7 +263,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -276,7 +276,7 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -286,20 +286,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -308,31 +308,31 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 7a3d78996..024da1821 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -109,21 +109,21 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -132,14 +132,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -147,7 +147,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -157,39 +157,39 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -198,21 +198,21 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -223,7 +223,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -233,20 +233,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -255,20 +255,20 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index dfe30ca56..f3535ce7f 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -318,7 +318,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--alloc\fP 
 .nh
@@ -342,21 +342,21 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -365,14 +365,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -380,7 +380,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -390,14 +390,14 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT]
 .br
@@ -420,33 +420,33 @@ extents in the new LV is not determined until the command has completed.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-n\fP|\fB--nofsck\fP
 .br
@@ -454,13 +454,13 @@ Display long help text.
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--nosync\fP
 .br
@@ -477,7 +477,7 @@ This option is not valid for raid6, because raid6 relies on proper parity
 to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -486,7 +486,7 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
@@ -494,21 +494,21 @@ ignore the devices LVM creates.
 Specifies the new size of the pool metadata LV.
 The plus prefix \fB+\fP can be used, in which case
 the value is added to the current size.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -519,13 +519,13 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
 .ad b
 Resize underlying filesystem together with the LV using fsadm(8).
-.TP
+.HP
 .ad l
 \fB-L\fP|\fB--size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]
 .br
@@ -537,7 +537,7 @@ greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.TP
+.HP
 .ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
 .br
@@ -554,14 +554,14 @@ when unspecified, the default depends on the RAID type
 (raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)
 To stripe a new raid LV across all PVs by default,
 see lvm.conf allocation/raid_stripe_all_devices.
-.TP
+.HP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
 .ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -571,7 +571,7 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--type\fP 
 .nh
@@ -590,20 +590,20 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -612,14 +612,14 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -629,11 +629,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index c45aacc61..76ea404c7 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -182,13 +182,13 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--aligned\fP
 .br
 .ad b
 Use with --separator to align the output columns
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
@@ -196,7 +196,7 @@ Use with --separator to align the output columns
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
-.TP
+.HP
 .ad l
 \fB--binary\fP
 .br
@@ -204,14 +204,14 @@ which are not independently accessible, e.g. not mountable.
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -220,20 +220,20 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 .ad b
 See \fBlvmreport\fP(7).
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -241,7 +241,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -251,27 +251,27 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--foreign\fP
 .br
 .ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-H\fP|\fB--history\fP
 .br
@@ -279,33 +279,33 @@ Display help text.
 Include historical LVs in the output.
 (This has no effect unless LVs were removed while
 lvm.conf metadata/record_lvs_history was enabled.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--logonly\fP
 .br
 .ad b
 Suppress command report and display only log report.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nameprefixes\fP
 .br
@@ -313,27 +313,27 @@ Display long help text.
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
-.TP
+.HP
 .ad l
 \fB--noheadings\fP
 .br
 .ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--nosuffix\fP
 .br
 .ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.TP
+.HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
@@ -355,21 +355,21 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -380,7 +380,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -391,19 +391,19 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--rows\fP
 .br
 .ad b
 Output columns as rows.
-.TP
+.HP
 .ad l
 \fB--segments\fP
 .br
 .ad b
 Use default columns that emphasize segment information.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -416,13 +416,13 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 .ad b
 String to use to separate each column. Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--shared\fP
 .br
@@ -430,14 +430,14 @@ String to use to separate each column. Useful if grepping the output.
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.TP
+.HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
 .ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -447,13 +447,13 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--unbuffered\fP
 .br
 .ad b
 Produce output immediately without sorting or aligning the columns properly.
-.TP
+.HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
@@ -464,27 +464,27 @@ human-(r)eadable with '<' rounding indicator,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.TP
+.HP
 .ad l
 \fB--unquoted\fP
 .br
 .ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -493,25 +493,25 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index ab3ed3670..264d9607e 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -109,7 +109,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
@@ -117,20 +117,20 @@ Common options for lvm:
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
-.TP
+.HP
 .ad l
 \fB-b\fP|\fB--blockdevice\fP
 .br
 .ad b
 No longer used.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -139,14 +139,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -154,7 +154,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -164,60 +164,60 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -228,7 +228,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -239,7 +239,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -249,20 +249,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -271,11 +271,11 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 84b4e13e0..33778ee6c 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -150,40 +150,40 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
 .ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
 Change all visible PVs.
-.TP
+.HP
 .ad l
 \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Enable or disable allocation of physical extents on this PV.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -192,21 +192,21 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--deltag\fP \fITag\fP
 .br
 .ad b
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -214,7 +214,7 @@ multiple tags at once. See \fBlvm\fP(8) for information about tags.
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -224,40 +224,40 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
 .br
@@ -266,27 +266,27 @@ Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -297,7 +297,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -310,7 +310,7 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -320,26 +320,26 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-u\fP|\fB--uuid\fP
 .br
 .ad b
 Generate new random UUID for specified PVs.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -348,7 +348,7 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -358,17 +358,17 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 8b1493b10..22e6f6eff 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -389,14 +389,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -405,14 +405,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -420,7 +420,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -430,14 +430,14 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--dump\fP 
 .nh
@@ -452,19 +452,19 @@ Option values include: \fBheaders\fP to print and check LVM headers,
 \fBmetadata_search\fP to list or save all versions of metadata,
 searching standard locations in case of damaged headers,
 \fBmetadata_area\fP to save an entire text metadata area to a file.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
 .ad b
 Metadata file to read or write.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--labelsector\fP \fINumber\fP
 .br
@@ -473,33 +473,33 @@ By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
@@ -511,26 +511,26 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--repair\fP
 .br
 .ad b
 Repair headers and metadata on a PV.
-.TP
+.HP
 .ad l
 \fB--repairtype\fP \fBpv_header\fP|\fBmetadata\fP|\fBlabel_header\fP
 .br
 .ad b
 Repair headers and metadata on a PV. See command description.
-.TP
+.HP
 .ad l
 \fB--settings\fP \fIString\fP
 .br
@@ -538,7 +538,7 @@ Repair headers and metadata on a PV. See command description.
 Specifies command specific settings in "Key = Value" form.
 Combine multiple settings in quotes, or repeat the settings
 option for each.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -548,20 +548,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -570,7 +570,7 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -580,11 +580,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index 52ad1d5ee..f56022b2e 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -222,7 +222,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
 .br
@@ -238,14 +238,14 @@ and --dataalignmentoffset. The bootloader area may be larger than requested
 due to the alignment, but it's never less than the requested size.
 To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -254,7 +254,7 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
@@ -264,20 +264,20 @@ To see the location of the first Physical Extent (PE) of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
 see --dataalignmentoffset.
 Also specify an appropriate PE size when creating a VG.
-.TP
+.HP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
 .ad b
 Shift the start of the PV data area by this additional offset.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -285,7 +285,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -295,27 +295,27 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--labelsector\fP \fINumber\fP
 .br
@@ -324,20 +324,20 @@ By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
 .br
@@ -346,14 +346,14 @@ Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
-.TP
+.HP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
 .ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
-.TP
+.HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
@@ -361,27 +361,27 @@ The size may be rounded.
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--norestorefile\fP
 .br
 .ad b
 In conjunction with --uuid, this allows a uuid to be specified
 without also requiring that a backup of the metadata be provided.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
@@ -393,14 +393,14 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -411,7 +411,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--restorefile\fP \fIString\fP
 .br
@@ -423,14 +423,14 @@ with the contents of the file, i.e. the physical extents will be in
 the same place and not be overwritten by new metadata. This provides
 a mechanism to upgrade the metadata format or to add/remove metadata
 areas. Use with care.
-.TP
+.HP
 .ad l
 \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
 .br
 .ad b
 Overrides the automatically detected size of the PV.
 Use with care, or prior to reducing the physical size of the device.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -440,7 +440,7 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-u\fP|\fB--uuid\fP \fIString\fP
 .br
@@ -453,20 +453,20 @@ onto a replacement device; see \fBvgcfgrestore\fP(8). As such, use of
 All PVs must have unique UUIDs, and LVM will prevent certain operations
 if multiple devices are seen with the same UUID.
 See \fBvgimportclone\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -474,7 +474,7 @@ Display version information.
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.TP
+.HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
@@ -483,7 +483,7 @@ Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
 .SH VARIABLES
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -493,11 +493,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 1aebef484..9a7e4ed56 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -182,20 +182,20 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--aligned\fP
 .br
 .ad b
 Use with --separator to align the output columns
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
 Show information about devices that have not been initialized
 by LVM, i.e. they are not PVs.
-.TP
+.HP
 .ad l
 \fB--binary\fP
 .br
@@ -203,28 +203,28 @@ by LVM, i.e. they are not PVs.
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.TP
+.HP
 .ad l
 \fB-c\fP|\fB--colon\fP
 .br
 .ad b
 Generate colon separated output for easier parsing in scripts or programs.
 Also see \fBvgs\fP(8) which provides considerably more control over the output.
-.TP
+.HP
 .ad l
 \fB-C\fP|\fB--columns\fP
 .br
 .ad b
 Display output in columns, the equivalent of \fBvgs\fP(8).
 Options listed are the same as options given in \fBvgs\fP(8).
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -233,20 +233,20 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 .ad b
 See \fBlvmreport\fP(7).
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -254,7 +254,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -264,79 +264,79 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--foreign\fP
 .br
 .ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--logonly\fP
 .br
 .ad b
 Suppress command report and display only log report.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-m\fP|\fB--maps\fP
 .br
 .ad b
 Display the mapping of physical extents to LVs and logical extents.
-.TP
+.HP
 .ad l
 \fB--noheadings\fP
 .br
 .ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--nosuffix\fP
 .br
 .ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.TP
+.HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
@@ -358,21 +358,21 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -383,7 +383,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -394,7 +394,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -407,13 +407,13 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 .ad b
 String to use to separate each column. Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--shared\fP
 .br
@@ -421,20 +421,20 @@ String to use to separate each column. Useful if grepping the output.
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.TP
+.HP
 .ad l
 \fB-s\fP|\fB--short\fP
 .br
 .ad b
 Only display the size of the given PVs.
-.TP
+.HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
 .ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -444,13 +444,13 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--unbuffered\fP
 .br
 .ad b
 Produce output immediately without sorting or aligning the columns properly.
-.TP
+.HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
@@ -461,20 +461,20 @@ human-(r)eadable with '<' rounding indicator,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -483,7 +483,7 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -493,16 +493,16 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index a9fab6eac..791e2834f 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -161,7 +161,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--abort\fP
 .br
@@ -170,7 +170,7 @@ Abort any pvmove operations in progress. If a pvmove was started
 with the --atomic option, then all LVs will remain on the source PV.
 Otherwise, segments that have been moved will remain on the
 destination PV, while unmoved segments will remain on the source PV.
-.TP
+.HP
 .ad l
 \fB--alloc\fP 
 .nh
@@ -194,21 +194,21 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.TP
+.HP
 .ad l
 \fB--atomic\fP
 .br
 .ad b
 Makes a pvmove operation atomic, ensuring that all affected LVs are
 moved to the destination PV, or none are if the operation is aborted.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB-b\fP|\fB--background\fP
 .br
@@ -216,14 +216,14 @@ Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information
 If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
 background.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -232,14 +232,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -247,7 +247,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -257,51 +257,51 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
 .ad b
 Report progress at regular intervals.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
 .ad b
 Move only the extents belonging to the named LV.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -310,21 +310,21 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -335,7 +335,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -345,20 +345,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -367,7 +367,7 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -377,11 +377,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 36577aff2..3015b70d1 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -99,14 +99,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -115,14 +115,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -130,7 +130,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -140,60 +140,60 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -204,7 +204,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -214,20 +214,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -236,7 +236,7 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -246,11 +246,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index bb3ab4cb2..fcc85885b 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -94,14 +94,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -110,14 +110,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -125,7 +125,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -135,53 +135,53 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -192,14 +192,14 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
 .br
 .ad b
 Overrides the automatically detected size of the PV.
 Use with care, or prior to reducing the physical size of the device.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -209,20 +209,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -231,7 +231,7 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -241,11 +241,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 12160af0d..f00e0328a 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -178,20 +178,20 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--aligned\fP
 .br
 .ad b
 Use with --separator to align the output columns
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
 Show information about devices that have not been initialized
 by LVM, i.e. they are not PVs.
-.TP
+.HP
 .ad l
 \fB--binary\fP
 .br
@@ -199,14 +199,14 @@ by LVM, i.e. they are not PVs.
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -215,20 +215,20 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 .ad b
 See \fBlvmreport\fP(7).
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -236,7 +236,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -246,53 +246,53 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--foreign\fP
 .br
 .ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--logonly\fP
 .br
 .ad b
 Suppress command report and display only log report.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nameprefixes\fP
 .br
@@ -300,27 +300,27 @@ Display long help text.
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
-.TP
+.HP
 .ad l
 \fB--noheadings\fP
 .br
 .ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--nosuffix\fP
 .br
 .ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.TP
+.HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
@@ -342,21 +342,21 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -367,7 +367,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -378,13 +378,13 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--rows\fP
 .br
 .ad b
 Output columns as rows.
-.TP
+.HP
 .ad l
 \fB--segments\fP
 .br
@@ -392,7 +392,7 @@ Output columns as rows.
 Produces one line of output for each contiguous allocation of space on each
 PV, showing the start (pvseg_start) and length (pvseg_size) in units of
 physical extents.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -405,13 +405,13 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 .ad b
 String to use to separate each column. Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--shared\fP
 .br
@@ -419,14 +419,14 @@ String to use to separate each column. Useful if grepping the output.
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.TP
+.HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
 .ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -436,13 +436,13 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--unbuffered\fP
 .br
 .ad b
 Produce output immediately without sorting or aligning the columns properly.
-.TP
+.HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
@@ -453,27 +453,27 @@ human-(r)eadable with '<' rounding indicator,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.TP
+.HP
 .ad l
 \fB--unquoted\fP
 .br
 .ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -482,7 +482,7 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -492,16 +492,16 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 644c6a2fc..1b0d3d925 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -206,27 +206,27 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
 .ad b
 Auto-activate LVs in a VG when the PVs scanned have completed the VG.
 (Only \fBay\fP is applicable.)
-.TP
+.HP
 .ad l
 \fB--cache\fP
 .br
 .ad b
 Scan one or more devices and record that they are online.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -235,14 +235,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -250,7 +250,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -260,64 +260,64 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-e\fP|\fB--exported\fP
 .br
 .ad b
 Only show PVs belonging to exported VGs.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
 .ad b
 The major number of a device.
-.TP
+.HP
 .ad l
 \fB--minor\fP \fINumber\fP
 .br
 .ad b
 The minor number of a device.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -326,27 +326,27 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB-n\fP|\fB--novolumegroup\fP
 .br
 .ad b
 Only show PVs not belonging to any VG.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -357,13 +357,13 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-s\fP|\fB--short\fP
 .br
 .ad b
 Short listing format.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -373,26 +373,26 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-u\fP|\fB--uuid\fP
 .br
 .ad b
 Show UUIDs in addition to device names.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -401,7 +401,7 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -411,11 +411,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index 5d359146a..1ef11ffb0 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -125,14 +125,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -141,14 +141,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -156,7 +156,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -166,14 +166,14 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
@@ -181,60 +181,60 @@ For testing and debugging.
 Write the backup to the named file.
 When backing up more than one VG, the file name is
 treated as a template, and %s is replaced by the VG name.
-.TP
+.HP
 .ad l
 \fB--foreign\fP
 .br
 .ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -245,7 +245,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -256,7 +256,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -266,20 +266,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -288,15 +288,15 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index eb1564f70..151aa2505 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -229,14 +229,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -245,14 +245,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -260,7 +260,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -270,21 +270,21 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
 .ad b
 Read metadata backup from the named file.
 Usually this file was created by vgcfgbackup.
-.TP
+.HP
 .ad l
 \fB--force\fP ...
 .br
@@ -294,33 +294,33 @@ Use with extreme caution. Most changes to thin metadata
 cannot be reverted.
 You may lose data if you restore metadata that does not match the
 thin pool kernel metadata precisely.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--list\fP
 .br
 .ad b
 List metadata backup and archive files pertaining to the VG.
 May be used with --file. Does not restore the VG.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
@@ -328,27 +328,27 @@ Display long help text.
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -358,20 +358,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -380,15 +380,15 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index c5af0de36..025113627 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -633,7 +633,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
@@ -662,7 +662,7 @@ If auto_activation_volume_list is defined and empty, no LVs are autoactivated.
 Items included by auto_activation_volume_list will not be autoactivated if
 the autoactivation property has been disabled.
 See \fBlvmlockd\fP(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
-.TP
+.HP
 .ad l
 \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
 .br
@@ -677,14 +677,14 @@ and is the most restrictive mode.
 should only be used for recovery or repair.
 For default, see lvm.conf/activation_mode.
 See \fBlvmraid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
 .ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.TP
+.HP
 .ad l
 \fB--alloc\fP 
 .nh
@@ -708,21 +708,21 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -731,28 +731,28 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--deltag\fP \fITag\fP
 .br
 .ad b
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.TP
+.HP
 .ad l
 \fB--detachprofile\fP
 .br
 .ad b
 Detaches a metadata profile from a VG or LV.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -760,7 +760,7 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -770,55 +770,55 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
 .br
 .ad b
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--ignoremonitoring\fP
 .br
 .ad b
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--lockstart\fP
 .br
@@ -826,7 +826,7 @@ See \fBlvmlockd\fP(8) for more information.
 Start the lockspace of a shared VG in lvmlockd.
 lvmlockd locks becomes available for the VG, allowing LVM to use the VG.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--lockstop\fP
 .br
@@ -834,26 +834,26 @@ See \fBlvmlockd\fP(8) for more information.
 Stop the lockspace of a shared VG in lvmlockd.
 lvmlockd locks become unavailable for the VG, preventing LVM from using the VG.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .br
 .ad b
 Change the VG lock type to or from a shared lock type used with lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--logicalvolume\fP \fINumber\fP
 .br
 .ad b
 Sets the maximum number of LVs allowed in a VG.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
@@ -862,14 +862,14 @@ Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
-.TP
+.HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
 .ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
 .br
@@ -878,13 +878,13 @@ Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See \fBdmeventd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -893,7 +893,7 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB-P\fP|\fB--partial\fP
 .br
@@ -902,7 +902,7 @@ Commands will do their best to activate LVs with missing PV extents.
 Missing extents may be replaced with error or zero segments
 according to the lvm.conf missing_stripe_filler setting.
 Metadata may not be changed with this option.
-.TP
+.HP
 .ad l
 \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
 .br
@@ -916,7 +916,7 @@ without recreating the VG, unless no extents need moving.
 Before increasing the physical extent size, you might need to use lvresize,
 pvresize and/or pvmove so that everything fits. For example, every
 contiguous range of extents used in a LV must start and end on an extent boundary.
-.TP
+.HP
 .ad l
 \fB--poll\fP \fBy\fP|\fBn\fP
 .br
@@ -928,14 +928,14 @@ When no, background transformation of an LV will not occur, and the
 transformation will not complete. It may not be appropriate to immediately
 poll an LV after activation, in which case --poll n can be used to defer
 polling until a later --poll y command.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
@@ -947,14 +947,14 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -965,7 +965,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--refresh\fP
 .br
@@ -974,7 +974,7 @@ If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -985,14 +985,14 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Enables or disables the addition or removal of PVs to/from a VG
 (by vgextend/vgreduce).
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -1005,7 +1005,7 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB--setautoactivation\fP \fBy\fP|\fBn\fP
 .br
@@ -1019,7 +1019,7 @@ If autoactivation is disabled on a VG, no LVs will be autoactivated
 in that VG, and the LV autoactivation property has no effect.
 If autoactivation is enabled on a VG, autoactivation can be disabled
 for individual LVs.
-.TP
+.HP
 .ad l
 \fB--sysinit\fP
 .br
@@ -1031,7 +1031,7 @@ acts as a shortcut which selects an appropriate set of options. Currently,
 this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
 --poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
-.TP
+.HP
 .ad l
 \fB--systemid\fP \fIString\fP
 .br
@@ -1040,7 +1040,7 @@ Changes the system ID of the VG.  Using this option requires caution
 because the VG may become foreign to the host running the command,
 leaving the host unable to access it.
 See \fBlvmsystemid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -1050,26 +1050,26 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-u\fP|\fB--uuid\fP
 .br
 .ad b
 Generate new random UUID for specified VGs.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
@@ -1087,7 +1087,7 @@ The number can also be replaced with special string values:
 metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -1096,26 +1096,26 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 7682431ff..aef35f3b2 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -112,14 +112,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -128,14 +128,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -143,7 +143,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -153,53 +153,53 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -210,7 +210,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -220,7 +220,7 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--updatemetadata\fP
 .br
@@ -235,20 +235,20 @@ this option will clear the outdated metadata from the previously
 missing PV. If metadata text is damaged on one PV, using this
 option will replace the damaged metadata text. For more severe
 damage, e.g. with headers, see \fBpvck\fP(8).
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -257,20 +257,20 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 2f2ba8b75..093512ab0 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -115,7 +115,7 @@ Common options for lvm:
 .RE
 
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
 .br
@@ -131,14 +131,14 @@ and --dataalignmentoffset. The bootloader area may be larger than requested
 due to the alignment, but it's never less than the requested size.
 To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -147,14 +147,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -162,7 +162,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -172,27 +172,27 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--labelsector\fP \fINumber\fP
 .br
@@ -201,27 +201,27 @@ By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
 .ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
-.TP
+.HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
@@ -229,20 +229,20 @@ The size may be rounded.
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
@@ -254,14 +254,14 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -272,7 +272,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -282,20 +282,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -304,15 +304,15 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 61823d579..3a3c35a08 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -186,14 +186,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
 .ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.TP
+.HP
 .ad l
 \fB--alloc\fP 
 .nh
@@ -217,28 +217,28 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 This option was specific to clvm and is now replaced by
 the --shared option with \fBlvmlockd\fP(8).
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -247,7 +247,7 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
@@ -257,20 +257,20 @@ To see the location of the first Physical Extent (PE) of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
 see --dataalignmentoffset.
 Also specify an appropriate PE size when creating a VG.
-.TP
+.HP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
 .ad b
 Shift the start of the PV data area by this additional offset.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -278,7 +278,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -288,27 +288,27 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--labelsector\fP \fINumber\fP
 .br
@@ -317,33 +317,33 @@ By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .br
 .ad b
 Specify the VG lock type directly in place of using --shared.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP
 .br
 .ad b
 Sets the maximum number of LVs allowed in a VG.
-.TP
+.HP
 .ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
@@ -352,21 +352,21 @@ Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
-.TP
+.HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
 .ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
 .ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
-.TP
+.HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
@@ -374,13 +374,13 @@ The size may be rounded.
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
 .br
@@ -391,14 +391,14 @@ The value must be either a power of 2 of at least 1 sector
 currently used in the VG), or at least 128KiB.
 Once this value has been set, it is difficult to change
 without recreating the VG, unless no extents need moving.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
@@ -410,14 +410,14 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -428,7 +428,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--setautoactivation\fP \fBy\fP|\fBn\fP
 .br
@@ -442,7 +442,7 @@ If autoactivation is disabled on a VG, no LVs will be autoactivated
 in that VG, and the LV autoactivation property has no effect.
 If autoactivation is enabled on a VG, autoactivation can be disabled
 for individual LVs.
-.TP
+.HP
 .ad l
 \fB--shared\fP
 .br
@@ -452,7 +452,7 @@ lvmlockd will select lock type sanlock or dlm depending on which lock
 manager is running. This allows multiple hosts to share a VG on shared
 devices. lvmlockd and a lock manager must be configured and running.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.TP
+.HP
 .ad l
 \fB--systemid\fP \fIString\fP
 .br
@@ -464,7 +464,7 @@ the host creating it. Using this option requires caution because the
 system ID of the new VG may not match the system ID of the host running
 the command, leaving the VG inaccessible to the host.
 See \fBlvmsystemid\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -474,20 +474,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
@@ -505,7 +505,7 @@ The number can also be replaced with special string values:
 metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -513,7 +513,7 @@ all PVs, and then to become unmanaged.
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.TP
+.HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
@@ -522,11 +522,11 @@ Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -536,11 +536,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 1684a68ba..a6f8106f2 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -177,20 +177,20 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--activevolumegroups\fP
 .br
 .ad b
 Only select active VGs. The VG is considered active
 if at least one of its LVs is active.
-.TP
+.HP
 .ad l
 \fB--aligned\fP
 .br
 .ad b
 Use with --separator to align the output columns
-.TP
+.HP
 .ad l
 \fB--binary\fP
 .br
@@ -198,28 +198,28 @@ Use with --separator to align the output columns
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.TP
+.HP
 .ad l
 \fB-c\fP|\fB--colon\fP
 .br
 .ad b
 Generate colon separated output for easier parsing in scripts or programs.
 Also see \fBvgs\fP(8) which provides considerably more control over the output.
-.TP
+.HP
 .ad l
 \fB-C\fP|\fB--columns\fP
 .br
 .ad b
 Display output in columns, the equivalent of \fBvgs\fP(8).
 Options listed are the same as options given in \fBvgs\fP(8).
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -228,20 +228,20 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 .ad b
 See \fBlvmreport\fP(7).
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -249,7 +249,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -259,73 +259,73 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--foreign\fP
 .br
 .ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--logonly\fP
 .br
 .ad b
 Suppress command report and display only log report.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--noheadings\fP
 .br
 .ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--nosuffix\fP
 .br
 .ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.TP
+.HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
@@ -347,21 +347,21 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -372,7 +372,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -383,7 +383,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -396,13 +396,13 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 .ad b
 String to use to separate each column. Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--shared\fP
 .br
@@ -410,20 +410,20 @@ String to use to separate each column. Useful if grepping the output.
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.TP
+.HP
 .ad l
 \fB-s\fP|\fB--short\fP
 .br
 .ad b
 Give a short listing showing the existence of VGs.
-.TP
+.HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
 .ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -433,13 +433,13 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--unbuffered\fP
 .br
 .ad b
 Produce output immediately without sorting or aligning the columns properly.
-.TP
+.HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
@@ -450,20 +450,20 @@ human-(r)eadable with '<' rounding indicator,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -472,20 +472,20 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index eb10961ce..89a25af07 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -128,19 +128,19 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -149,14 +149,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -164,7 +164,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -174,53 +174,53 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -231,7 +231,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -244,7 +244,7 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -254,20 +254,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -276,26 +276,26 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index e82cdb4e8..c4c0b130a 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -143,21 +143,21 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -166,7 +166,7 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
@@ -176,20 +176,20 @@ To see the location of the first Physical Extent (PE) of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
 see --dataalignmentoffset.
 Also specify an appropriate PE size when creating a VG.
-.TP
+.HP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
 .ad b
 Shift the start of the PV data area by this additional offset.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -197,7 +197,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -207,27 +207,27 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--labelsector\fP \fINumber\fP
 .br
@@ -236,20 +236,20 @@ By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
 .br
@@ -258,14 +258,14 @@ Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
-.TP
+.HP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
 .ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
-.TP
+.HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
@@ -273,20 +273,20 @@ The size may be rounded.
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
@@ -298,14 +298,14 @@ When 1, one copy of the VG metadata is stored@the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -316,14 +316,14 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--restoremissing\fP
 .br
 .ad b
 Add a PV back into a VG after the PV was missing and then returned,
 e.g. due to a transient failure. The PV is not reinitialized.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -333,20 +333,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -354,7 +354,7 @@ Display version information.
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.TP
+.HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
@@ -363,11 +363,11 @@ Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -377,11 +377,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index b119a4e15..993a52e21 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -118,20 +118,20 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
 Import all visible VGs.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -140,14 +140,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -155,7 +155,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -165,60 +165,60 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -229,7 +229,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -242,7 +242,7 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -252,20 +252,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -274,26 +274,26 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index 42dfa3487..2fe7ed60f 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -102,7 +102,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-n\fP|\fB--basevgname\fP \fIString\fP
 .br
@@ -112,14 +112,14 @@ numeric suffix to avoid duplicate naming (e.g. 'test_vg' would be renamed
 to 'test_vg1'). This option will override the base VG name that is
 used for all VG renames. If a VG already exists with the specified name
 a numeric suffix will be added (like the previous example) to make it unique.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -128,14 +128,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -143,7 +143,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -153,66 +153,66 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-i\fP|\fB--import\fP
 .br
 .ad b
 Import exported VGs. Otherwise VGs that have been exported
 will not be changed (nor will their associated PVs).
-.TP
+.HP
 .ad l
 \fB--importdevices\fP
 .br
 .ad b
 Add devices to the devices file.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -222,20 +222,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -244,7 +244,7 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -254,11 +254,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgimportdevices.8_pregen b/man/vgimportdevices.8_pregen
index 1472de265..18beabdfa 100644
--- a/man/vgimportdevices.8_pregen
+++ b/man/vgimportdevices.8_pregen
@@ -124,19 +124,19 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -145,14 +145,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -160,7 +160,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -170,60 +170,60 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--foreign\fP
 .br
 .ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -234,7 +234,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -247,7 +247,7 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -257,20 +257,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -279,26 +279,26 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index f0ef43ddc..cca10b528 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -95,21 +95,21 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -118,14 +118,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -133,7 +133,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -143,59 +143,59 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--list\fP
 .br
 .ad b
 Display merged destination VG like vgdisplay -v.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -205,20 +205,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -227,15 +227,15 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 476b76ed5..34213ef8e 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -106,14 +106,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -122,14 +122,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -137,7 +137,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -147,60 +147,60 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--refresh\fP
 .br
@@ -209,7 +209,7 @@ If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -220,7 +220,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -230,20 +230,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -252,25 +252,25 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index 72937ce67..f0d22121b 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -219,27 +219,27 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
 Removes all empty PVs if none are named on the command line.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -248,14 +248,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -263,7 +263,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -273,66 +273,66 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--mirrorsonly\fP
 .br
 .ad b
 Only remove missing PVs from mirror LVs.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--removemissing\fP
 .br
@@ -347,7 +347,7 @@ were partly on the missing disks are removed completely, including
 those parts on disks that are still present.
 If LVs spanned several disks, including ones that are lost, salvaging
 some data first may be possible by activating LVs in partial mode.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -358,7 +358,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -368,20 +368,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -390,11 +390,11 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -404,11 +404,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index b80dc09ba..73d6dbd4a 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -109,14 +109,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -125,14 +125,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -140,7 +140,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -150,46 +150,46 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--noudevsync\fP
 .br
@@ -198,21 +198,21 @@ Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -223,7 +223,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -236,7 +236,7 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -246,20 +246,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -268,26 +268,26 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index e22bca88c..ba5adca31 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -122,21 +122,21 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -145,14 +145,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -160,7 +160,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -170,60 +170,60 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
 .ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -234,7 +234,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -244,20 +244,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -266,15 +266,15 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index ae18b1c10..2cf23764e 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -174,19 +174,19 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--aligned\fP
 .br
 .ad b
 Use with --separator to align the output columns
-.TP
+.HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
 List all VGs. Equivalent to not specifying any VGs.
-.TP
+.HP
 .ad l
 \fB--binary\fP
 .br
@@ -194,14 +194,14 @@ List all VGs. Equivalent to not specifying any VGs.
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -210,20 +210,20 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 .ad b
 See \fBlvmreport\fP(7).
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -231,7 +231,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -241,53 +241,53 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB--foreign\fP
 .br
 .ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--logonly\fP
 .br
 .ad b
 Suppress command report and display only log report.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--nameprefixes\fP
 .br
@@ -295,27 +295,27 @@ Display long help text.
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
-.TP
+.HP
 .ad l
 \fB--noheadings\fP
 .br
 .ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--nosuffix\fP
 .br
 .ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.TP
+.HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
@@ -337,21 +337,21 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--readonly\fP
 .br
@@ -362,7 +362,7 @@ inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -373,13 +373,13 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB--rows\fP
 .br
 .ad b
 Output columns as rows.
-.TP
+.HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
@@ -392,13 +392,13 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.TP
+.HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 .ad b
 String to use to separate each column. Useful if grepping the output.
-.TP
+.HP
 .ad l
 \fB--shared\fP
 .br
@@ -406,14 +406,14 @@ String to use to separate each column. Useful if grepping the output.
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.TP
+.HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
 .ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -423,13 +423,13 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB--unbuffered\fP
 .br
 .ad b
 Produce output immediately without sorting or aligning the columns properly.
-.TP
+.HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
@@ -440,27 +440,27 @@ human-(r)eadable with '<' rounding indicator,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.TP
+.HP
 .ad l
 \fB--unquoted\fP
 .br
 .ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -469,20 +469,20 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 4cbf08d91..40145b078 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -101,14 +101,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -117,14 +117,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -132,7 +132,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -142,53 +142,53 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
 .ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB--mknodes\fP
 .br
 .ad b
 Also checks the LVM special files in /dev that are needed for active
 LVs and creates any missing ones and removes unused ones.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--notifydbus\fP
 .br
@@ -196,21 +196,21 @@ Disable locking.
 Send a notification to D-Bus. The command will exit with an error
 if LVM is not built with support for D-Bus notification, or if the
 notify_dbus config setting is disabled.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
@@ -221,7 +221,7 @@ the report/output_format setting in lvm.conf.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -231,20 +231,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -253,11 +253,11 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 9a1a6083e..c4721b9ba 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -143,7 +143,7 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.TP
+.HP
 .ad l
 \fB--alloc\fP 
 .nh
@@ -167,21 +167,21 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.TP
+.HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 .ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.TP
+.HP
 .ad l
 \fB--config\fP \fIString\fP
 .br
@@ -190,14 +190,14 @@ Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.TP
+.HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
 .ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.TP
+.HP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
@@ -205,7 +205,7 @@ messages sent to the log file and/or syslog (if configured).
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.TP
+.HP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
@@ -215,39 +215,39 @@ The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.TP
+.HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 .ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.TP
+.HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 .ad b
 Display help text.
-.TP
+.HP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
 .ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.TP
+.HP
 .ad l
 \fB--longhelp\fP
 .br
 .ad b
 Display long help text.
-.TP
+.HP
 .ad l
 \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP
 .br
 .ad b
 Sets the maximum number of LVs allowed in a VG.
-.TP
+.HP
 .ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
@@ -256,7 +256,7 @@ Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
-.TP
+.HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
@@ -264,33 +264,33 @@ and --vgmetadatacopies for improving performance.
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.TP
+.HP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
 .ad b
 Move only PVs used by the named LV.
-.TP
+.HP
 .ad l
 \fB--nolocking\fP
 .br
 .ad b
 Disable locking.
-.TP
+.HP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
 .ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.TP
+.HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
 .ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.TP
+.HP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
@@ -300,20 +300,20 @@ This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.TP
+.HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 .ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.TP
+.HP
 .ad l
 \fB--version\fP
 .br
 .ad b
 Display version information.
-.TP
+.HP
 .ad l
 \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
@@ -331,7 +331,7 @@ The number can also be replaced with special string values:
 metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
-.TP
+.HP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
@@ -340,11 +340,11 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .SH VARIABLES
-.TP
+.HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.TP
+.HP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -354,11 +354,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.TP
+.HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.TP
+.HP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.


