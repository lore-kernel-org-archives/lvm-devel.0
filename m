From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 15 Mar 2017 20:52:08 -0400
Subject: master - man: Remove blank lines from pregenerated files
Message-ID: <201703160052.v2G0q89S022878@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9729fc4f8c62ade44f2adb3dadf7904a19b3709f
Commit:        9729fc4f8c62ade44f2adb3dadf7904a19b3709f
Parent:        6d6ab310e5a848737a50e1a2c8e3659912e337c7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 00:50:27 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 00:50:27 2017 +0000

man: Remove blank lines from pregenerated files

---
 man/lvchange.8_pregen       |  129 ++----------------
 man/lvconvert.8_pregen      |  245 ++++----------------------------
 man/lvcreate.8_pregen       |  327 ++++++++++---------------------------------
 man/lvdisplay.8_pregen      |   64 +--------
 man/lvextend.8_pregen       |   77 +----------
 man/lvm-config.8_pregen     |   51 -------
 man/lvm-dumpconfig.8_pregen |   51 -------
 man/lvm-fullreport.8_pregen |   62 +--------
 man/lvm-lvpoll.8_pregen     |   41 ------
 man/lvmconfig.8_pregen      |   51 -------
 man/lvmdiskscan.8_pregen    |   35 -----
 man/lvmsadc.8_pregen        |   33 -----
 man/lvmsar.8_pregen         |   34 -----
 man/lvreduce.8_pregen       |   43 ------
 man/lvremove.8_pregen       |   47 ------
 man/lvrename.8_pregen       |   42 ------
 man/lvresize.8_pregen       |   70 +---------
 man/lvs.8_pregen            |   67 +---------
 man/lvscan.8_pregen         |   44 ------
 man/pvchange.8_pregen       |   49 -------
 man/pvck.8_pregen           |   35 -----
 man/pvcreate.8_pregen       |   50 -------
 man/pvdisplay.8_pregen      |   61 +--------
 man/pvmove.8_pregen         |   49 -------
 man/pvremove.8_pregen       |   36 -----
 man/pvresize.8_pregen       |   40 ------
 man/pvs.8_pregen            |   66 +---------
 man/pvscan.8_pregen         |   60 --------
 man/vgcfgbackup.8_pregen    |   40 ------
 man/vgcfgrestore.8_pregen   |   62 +--------
 man/vgchange.8_pregen       |  113 +--------------
 man/vgck.8_pregen           |   36 -----
 man/vgconvert.8_pregen      |   42 ------
 man/vgcreate.8_pregen       |   58 --------
 man/vgdisplay.8_pregen      |   61 +--------
 man/vgexport.8_pregen       |   42 ------
 man/vgextend.8_pregen       |   48 -------
 man/vgimport.8_pregen       |   43 ------
 man/vgimportclone.8_pregen  |   37 -----
 man/vgmerge.8_pregen        |   37 -----
 man/vgmknodes.8_pregen      |   39 -----
 man/vgreduce.8_pregen       |   60 +--------
 man/vgremove.8_pregen       |   40 ------
 man/vgrename.8_pregen       |   41 ------
 man/vgs.8_pregen            |   64 +--------
 man/vgscan.8_pregen         |   39 -----
 man/vgsplit.8_pregen        |   46 ------
 47 files changed, 150 insertions(+), 2757 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index cba3830..f0e2c92 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -1,20 +1,13 @@
 .TH LVCHANGE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvchange \- Change the attributes of logical volume(s)
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvchange\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
 .P
-
-.P
 .ad l
  \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .ad b
@@ -226,18 +219,10 @@ lvchange \- Change the attributes of logical volume(s)
 .ad l
  \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .ad b
-
-.P
-
 .SH DESCRIPTION
 lvchange changes LV attributes in the VG, changes LV activation in the
 kernel, and includes other utilities for LV maintenance.
-
-.P
 .SH USAGE
-.br
-.P
-.
 Change a general LV attribute. 
 .br
 For options listed in parentheses, any one is 
@@ -341,10 +326,7 @@ required, after which the others are optional.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Resyncronize a mirror or raid LV.
 .br
@@ -359,10 +341,7 @@ Resyncronize a mirror or raid LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Resynchronize or check a raid LV.
 .br
@@ -373,10 +352,7 @@ Resynchronize or check a raid LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Reconstruct data on specific PVs of a raid LV.
 .br
@@ -387,10 +363,7 @@ Reconstruct data on specific PVs of a raid LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Activate or deactivate an LV.
 .br
@@ -421,10 +394,7 @@ Activate or deactivate an LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Reactivate an LV using the latest metadata.
 .br
@@ -443,10 +413,7 @@ Reactivate an LV using the latest metadata.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Start or stop monitoring an LV from dmeventd.
 .br
@@ -461,10 +428,7 @@ Start or stop monitoring an LV from dmeventd.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Start or stop processing an LV conversion.
 .br
@@ -479,10 +443,7 @@ Start or stop processing an LV conversion.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Make the minor device number persistent for an LV.
 .br
@@ -497,10 +458,7 @@ Make the minor device number persistent for an LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Common options for command:
 .
@@ -532,9 +490,7 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -586,12 +542,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
@@ -617,7 +569,6 @@ to select which LVs should be automatically activated by the system.
 See lvmlockd(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
 See clvmd(8) for more information about activation options \fBey\fP, \fBsy\fP, \fBly\fP and \fBln\fP for clustered VGs.
 .ad b
-
 .HP
 .ad l
 \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
@@ -633,7 +584,6 @@ should only be used for recovery or repair.
 For default, see lvm.conf/activation_mode.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--addtag\fP \fITag\fP
@@ -641,7 +591,6 @@ See \fBlvmraid\fP(7) for more information.
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
-
 .HP
 .ad l
 \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
@@ -663,7 +612,6 @@ Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -671,7 +619,6 @@ See \fBlvm\fP(8) for more information about allocation.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
@@ -688,7 +635,6 @@ from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--cachepolicy\fP \fIString\fP
@@ -696,7 +642,6 @@ block invalidates. See \fBlvmcache\fP(7) for more information.
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--cachesettings\fP \fIString\fP
@@ -709,7 +654,6 @@ settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -717,7 +661,6 @@ See \fBlvmcache\fP(7) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -727,7 +670,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
@@ -738,7 +680,6 @@ It is only possible to change a non-contiguous allocation policy
 to contiguous if all of the allocated physical extents in the LV
 are already contiguous.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -746,7 +687,6 @@ are already contiguous.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--deltag\fP \fITag\fP
@@ -754,7 +694,6 @@ messages sent to the log file and/or syslog (if configured).
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
-
 .HP
 .ad l
 \fB--detachprofile\fP
@@ -762,7 +701,6 @@ multiple tags at once. See lvm(8) for information about tags.
 Detaches a metadata profile from a VG or LV.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
@@ -776,7 +714,6 @@ allow reuse of unneeded extents in the thin pool.
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -784,7 +721,6 @@ See \fBlvmthin\fP(7) for more information.
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
@@ -798,7 +734,6 @@ Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -806,14 +741,12 @@ See \fBlvmthin\fP(7) for more information.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
@@ -821,7 +754,6 @@ Display help text.
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -829,7 +761,6 @@ to allow LVs with the flag set to be activated.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--ignoremonitoring\fP
@@ -837,7 +768,6 @@ operations after locking failures.
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreskippedcluster\fP
@@ -845,21 +775,18 @@ Do not use this if dmeventd is already monitoring a device.
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
 Sets the major number of an LV block device.
 .ad b
-
 .HP
 .ad l
 \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
@@ -869,7 +796,6 @@ is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
@@ -877,14 +803,12 @@ See \fBlvmraid\fP(7) for more information.
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--minor\fP \fINumber\fP
 .br
 Sets the minor number of an LV block device.
 .ad b
-
 .HP
 .ad l
 \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
@@ -894,7 +818,6 @@ is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
@@ -904,7 +827,6 @@ dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See dmeventd(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -914,7 +836,6 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -924,21 +845,18 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
 .br
 Set access permission to read only \fBr\fP or read and write \fBrw\fP.
 .ad b
-
 .HP
 .ad l
 \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
 .br
 When yes, makes the specified minor number persistent.
 .ad b
-
 .HP
 .ad l
 \fB--poll\fP \fBy\fP|\fBn\fP
@@ -951,7 +869,6 @@ transformation will not complete. It may not be appropriate to immediately
 poll an LV after activation, in which case --poll n can be used to defer
 polling until a later --poll y command.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -959,7 +876,6 @@ polling until a later --poll y command.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -967,7 +883,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
@@ -977,7 +892,6 @@ Sets read ahead sector count of an LV.
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
 .ad b
-
 .HP
 .ad l
 \fB--rebuild\fP \fIPV\fP
@@ -989,7 +903,6 @@ PVs with corrupted data are known, and their data should be reconstructed
 rather than reconstructing default (rotating) data.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--refresh\fP
@@ -999,7 +912,6 @@ This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -1011,7 +923,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--resync\fP
@@ -1024,7 +935,6 @@ and copied to the others. This can take considerable time, during
 which the LV is without a complete redundant copy of the data.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -1038,7 +948,6 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
@@ -1050,7 +959,6 @@ This flag is set by default on new thin snapshot LVs.
 The flag is not applied to deactivation.
 The current value of the flag is indicated in the lvs lv_attr bits.
 .ad b
-
 .HP
 .ad l
 \fB--[raid]syncaction\fP \fBcheck\fP|\fBrepair\fP
@@ -1063,7 +971,6 @@ blocks in the array and check for discrepancies
 \fBrepair\fP will correct discrepancies.
 See lvs for reporting discrepancies found or repaired.
 .ad b
-
 .HP
 .ad l
 \fB--sysinit\fP
@@ -1077,7 +984,6 @@ this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
 When used in conjunction with lvmetad enabled and running,
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -1088,7 +994,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -1096,14 +1001,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB--[raid]writebehind\fP \fINumber\fP
@@ -1115,7 +1018,6 @@ to the constituent devices must complete before the array signals the
 write has completed). Setting the value to zero clears the preference
 and allows the system to choose the value arbitrarily.
 .ad b
-
 .HP
 .ad l
 \fB--[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
@@ -1129,7 +1031,6 @@ suffix \fB:n\fP at the end of the PV name, or to toggle the value with
 the suffix \fB:t\fP. Repeat this option to change the attribute on
 multiple PVs.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -1138,7 +1039,6 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
-
 .HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
@@ -1147,13 +1047,10 @@ Set zeroing mode for thin pool. Note: already provisioned blocks from pool
 in non-zero mode are not cleared in unwritten parts when setting --zero y.
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fILV\fP
 .br
@@ -1161,25 +1058,21 @@ Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -1194,15 +1087,12 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
-
 Change LV permission to read-only:
 .sp
 .B lvchange \-pr vg00/lvol1
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -1269,4 +1159,3 @@ Change LV permission to read-only:
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index bc8d53f..da29009 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1,13 +1,8 @@
 .TH LVCONVERT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvconvert \- Change logical volume layout
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvconvert\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -15,8 +10,6 @@ lvconvert \- Change logical volume layout
     [ \fIposition_args\fP ]
 .br
 .P
-
-.P
 .ad l
     \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .ad b
@@ -240,9 +233,6 @@ lvconvert \- Change logical volume layout
 .ad l
  \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .ad b
-
-.P
-
 .SH DESCRIPTION
 lvconvert changes the LV type and includes utilities for LV data
 maintenance. The LV type controls data layout and redundancy.
@@ -308,13 +298,7 @@ and vice-versa by e.g. linear <-> raid1 <-> raid5_n (then adding stripes) <-> st
 
 Sub LVs can be displayed with the command
 .B lvs -a
-
-
-.P
 .SH USAGE
-.br
-.P
-.
 Convert LV to linear.
 .br
 .P
@@ -327,10 +311,7 @@ Convert LV to linear.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Convert LV to striped.
 .br
@@ -360,10 +341,7 @@ Convert LV to striped.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Convert LV to raid or change raid layout 
 .br
@@ -399,10 +377,7 @@ Convert LV to raid or change raid layout
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Convert LV to raid1 or mirror, or change number of mirror images.
 .br
@@ -428,10 +403,7 @@ Convert LV to raid1 or mirror, or change number of mirror images.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Convert raid LV to change number of stripe images.
 .br
@@ -457,10 +429,7 @@ Convert raid LV to change number of stripe images.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Convert raid LV to change the stripe size.
 .br
@@ -479,10 +448,7 @@ Convert raid LV to change the stripe size.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Split images from a raid1 or mirror LV and use them to create a new LV.
 .br
@@ -496,10 +462,7 @@ Split images from a raid1 or mirror LV and use them to create a new LV.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Split images from a raid1 LV and track changes to origin.
 .br
@@ -513,10 +476,7 @@ Split images from a raid1 LV and track changes to origin.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Merge LV images that were split from a raid1 LV.
 .br
@@ -527,10 +487,7 @@ Merge LV images that were split from a raid1 LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Convert LV to a thin LV, using the original LV as an external origin.
 .br
@@ -577,10 +534,7 @@ Convert LV to a thin LV, using the original LV as an external origin.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Convert LV to type cache.
 .br
@@ -639,10 +593,7 @@ Convert LV to type cache.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Convert LV to type thin-pool.
 .br
@@ -696,10 +647,7 @@ Convert LV to type thin-pool.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Convert LV to type cache-pool.
 .br
@@ -757,10 +705,7 @@ Convert LV to type cache-pool.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Separate and keep the cache pool from a cache LV.
 .br
@@ -771,10 +716,7 @@ Separate and keep the cache pool from a cache LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Merge thin LV into its origin LV.
 .br
@@ -785,10 +727,7 @@ Merge thin LV into its origin LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Merge COW snapshot LV into its origin.
 .br
@@ -803,10 +742,7 @@ Merge COW snapshot LV into its origin.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Replace failed PVs in a raid or mirror LV. 
 .br
@@ -830,10 +766,7 @@ Repair a thin pool.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Replace specific PV(s) in a raid LV with another PV.
 .br
@@ -847,10 +780,7 @@ Replace specific PV(s) in a raid LV with another PV.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Poll LV to continue conversion.
 .br
@@ -861,10 +791,7 @@ Poll LV to continue conversion.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Common options for command:
 .
@@ -884,9 +811,7 @@ Common options for command:
 .ad l
 [    \fB--noudevsync\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -938,12 +863,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
@@ -965,7 +886,6 @@ Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
 .ad b
-
 .HP
 .ad l
 \fB-b\fP|\fB--background\fP
@@ -974,7 +894,6 @@ If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
 background.
 .ad b
-
 .HP
 .ad l
 \fB-H\fP|\fB--cache\fP
@@ -983,14 +902,12 @@ Specifies the command is handling a cache LV or cache pool.
 See --type cache and --type cache-pool.
 See \fBlvmcache\fP(7) for more information about LVM caching.
 .ad b
-
 .HP
 .ad l
 \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
 Specifies the cache metadata format used by cache target.
 .ad b
-
 .HP
 .ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
@@ -1007,7 +924,6 @@ from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--cachepolicy\fP \fIString\fP
@@ -1015,14 +931,12 @@ block invalidates. See \fBlvmcache\fP(7) for more information.
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--cachepool\fP \fILV\fP
 .br
 The name of a cache pool LV.
 .ad b
-
 .HP
 .ad l
 \fB--cachesettings\fP \fIString\fP
@@ -1035,7 +949,6 @@ settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
@@ -1051,7 +964,6 @@ pool metadata size within 128MiB, if the pool metadata size is not specified.
 The value must be a multiple of 64KiB.
 See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -1059,7 +971,6 @@ See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -1069,7 +980,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -1077,7 +987,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
@@ -1091,7 +1000,6 @@ allow reuse of unneeded extents in the thin pool.
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -1099,7 +1007,6 @@ See \fBlvmthin\fP(7) for more information.
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -1107,28 +1014,24 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
 Report progress at regular intervals.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--merge\fP
@@ -1136,7 +1039,6 @@ Display long help text.
 An alias for --mergethin, --mergemirrors, or --mergesnapshot,
 depending on the type of LV.
 .ad b
-
 .HP
 .ad l
 \fB--mergemirrors\fP
@@ -1144,7 +1046,6 @@ depending on the type of LV.
 Merge LV images that were split from a raid1 LV.
 See --splitmirrors with --trackchanges.
 .ad b
-
 .HP
 .ad l
 \fB--mergesnapshot\fP
@@ -1162,7 +1063,6 @@ being merged. When the merge finishes, the merged snapshot is removed.
 Multiple snapshots may be specified on the command line or a @tag may be
 used to specify multiple snapshots be merged to their respective origin.
 .ad b
-
 .HP
 .ad l
 \fB--mergethin\fP
@@ -1172,7 +1072,6 @@ The origin thin LV takes the content of the thin snapshot,
 and the thin snapshot LV is removed.
 See \fBlvmthin\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
@@ -1180,7 +1079,6 @@ See \fBlvmthin\fP(7) for more information.
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
@@ -1194,7 +1092,6 @@ In this case, the mirror must be synchronized (by copying LV data from
 the first device to others) each time the LV is activated, e.g. after reboot.
 \fBmirrored\fP is a persistent log that is itself mirrored.
 .ad b
-
 .HP
 .ad l
 \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP
@@ -1216,7 +1113,6 @@ or the minus prefix \fB-\fP can be used, in which case
 the number is subtracted from the current number of images.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
@@ -1225,7 +1121,6 @@ Specifies the name of a new LV.
 When unspecified, a default name of "lvol#" is
 generated, where # is a number generated by LVM.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -1235,7 +1130,6 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB--originname\fP \fILV\fP
@@ -1244,21 +1138,18 @@ Specifies the name to use for the external origin LV when converting an LV
 to a thin LV. The LV being converted becomes a read-only external origin
 with this name.
 .ad b
-
 .HP
 .ad l
 \fB--poolmetadata\fP \fILV\fP
 .br
 The name of a an LV to use for storing pool metadata.
 .ad b
-
 .HP
 .ad l
 \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
 .br
 Specifies the size of the new pool metadata LV.
 .ad b
-
 .HP
 .ad l
 \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
@@ -1267,7 +1158,6 @@ Enable or disable the automatic creation and management of a
 spare pool metadata LV in the VG. A spare metadata LV is reserved
 space that can be used when repairing a pool.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -1275,7 +1165,6 @@ space that can be used when repairing a pool.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -1283,7 +1172,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
@@ -1293,7 +1181,6 @@ Sets read ahead sector count of an LV.
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
 .ad b
-
 .HP
 .ad l
 \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
@@ -1302,7 +1189,6 @@ Size of each raid or mirror synchronization region.
 lvm.conf activation/raid_region_size can be used to
 configure a default.
 .ad b
-
 .HP
 .ad l
 \fB--repair\fP
@@ -1311,7 +1197,6 @@ Replace failed PVs in a raid or mirror LV, or run a repair
 utility on a thin pool. See \fBlvmraid\fP(7) and \fBlvmthin\fP(7)
 for more information.
 .ad b
-
 .HP
 .ad l
 \fB--replace\fP \fIPV\fP
@@ -1321,7 +1206,6 @@ The new PV to use can be optionally specified after the LV.
 Multiple PVs can be replaced by repeating this option.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-s\fP|\fB--snapshot\fP
@@ -1329,7 +1213,6 @@ See \fBlvmraid\fP(7) for more information.
 Combine a former COW snapshot LV with a former origin LV to reverse
 a previous --splitsnapshot command.
 .ad b
-
 .HP
 .ad l
 \fB--splitcache\fP
@@ -1337,7 +1220,6 @@ a previous --splitsnapshot command.
 Separates a cache pool from a cache LV, and keeps the unused cache pool LV.
 Before the separation, the cache is flushed. Also see --uncache.
 .ad b
-
 .HP
 .ad l
 \fB--splitmirrors\fP \fINumber\fP
@@ -1346,7 +1228,6 @@ Splits the specified number of images from a raid1 or mirror LV
 and uses them to create a new LV. If --trackchanges is also specified,
 changes to the raid1 LV are tracked while the split LV remains detached.
 .ad b
-
 .HP
 .ad l
 \fB--splitsnapshot\fP
@@ -1355,14 +1236,12 @@ Separates a COW snapshot from its origin LV. The LV that is split off
 contains the chunks that differ from the origin LV along with metadata
 describing them. This LV can be wiped and then destroyed with lvremove.
 .ad b
-
 .HP
 .ad l
 \fB--startpoll\fP
 .br
 Start polling an LV to continue processing a conversion.
 .ad b
-
 .HP
 .ad l
 \fB--stripes\fP \fINumber\fP
@@ -1373,7 +1252,6 @@ appears sequential in the LV is spread across multiple devices in units of
 the stripe size (see --stripesize). This does not apply to
 existing allocated space, only newly allocated space can be striped.
 .ad b
-
 .HP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
@@ -1381,7 +1259,6 @@ existing allocated space, only newly allocated space can be striped.
 The amount of data that is written to one device before
 moving to the next in a striped LV.
 .ad b
-
 .HP
 .ad l
 \fB--swapmetadata\fP
@@ -1393,7 +1270,6 @@ be activated directly and used with thin provisioning tools:
 \fBcache_dump\fP(8), \fBcache_repair\fP(8), \fBcache_restore\fP(8),
 \fBthin_dump\fP(8), \fBthin_repair\fP(8), \fBthin_restore\fP(8).
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -1404,7 +1280,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-T\fP|\fB--thin\fP
@@ -1413,14 +1288,12 @@ Specifies the command is handling a thin LV or thin pool.
 See --type thin, --type thin-pool, and --virtualsize.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
 .ad b
-
 .HP
 .ad l
 \fB--thinpool\fP \fILV\fP
 .br
 The name of a thin pool LV.
 .ad b
-
 .HP
 .ad l
 \fB--trackchanges\fP
@@ -1432,7 +1305,6 @@ merged efficiently back into the raid1 LV later. Only the regions with
 changed data are resynchronized during merge. (This option only applies
 when using the raid1 LV type.)
 .ad b
-
 .HP
 .ad l
 \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
@@ -1448,7 +1320,6 @@ is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
-
 .HP
 .ad l
 \fB--uncache\fP
@@ -1456,7 +1327,6 @@ Use inferred types with care because it can lead to unexpected results.
 Separates a cache pool from a cache LV, and deletes the unused cache pool LV.
 Before the separation, the cache is flushed. Also see --splitcache.
 .ad b
-
 .HP
 .ad l
 \fB--usepolicies\fP
@@ -1464,7 +1334,6 @@ Before the separation, the cache is flushed. Also see --splitcache.
 Perform an operation according to the policy configured in lvm.conf
 or a profile.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -1472,14 +1341,12 @@ or a profile.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -1488,7 +1355,6 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
-
 .HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
@@ -1499,13 +1365,10 @@ For thin pools, this controls zeroing of provisioned blocks.
 Provisioning of large zeroed chunks negatively impacts performance.
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fILV\fP
 .br
@@ -1513,7 +1376,6 @@ Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-
 .HP
 \fIPV\fP
 .br
@@ -1524,18 +1386,15 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -1550,7 +1409,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH ADVANCED USAGE
@@ -1586,10 +1444,7 @@ Convert LV to type mirror (also see type raid1),
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Change the region size of an LV.
 .br
@@ -1600,10 +1455,7 @@ Change the region size of an LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Change the type of mirror log used by a mirror LV.
 .br
@@ -1617,10 +1469,7 @@ Change the type of mirror log used by a mirror LV.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Convert LV to a thin LV, using the original LV as an external origin 
 .br
@@ -1669,10 +1518,7 @@ Convert LV to a thin LV, using the original LV as an external origin
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Convert LV to type cache (infers --type cache).
 .br
@@ -1731,10 +1577,7 @@ Convert LV to type cache (infers --type cache).
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Separate and delete the cache pool from a cache LV.
 .br
@@ -1745,10 +1588,7 @@ Separate and delete the cache pool from a cache LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Swap metadata LV in a thin pool or cache pool (for repair only).
 .br
@@ -1763,10 +1603,7 @@ Swap metadata LV in a thin pool or cache pool (for repair only).
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Merge LV that was split from a mirror (variant, use --mergemirrors). 
 .br
@@ -1785,10 +1622,7 @@ Merge COW snapshot LV into its origin (variant, use --mergesnapshot).
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Separate a COW snapshot from its origin LV.
 .br
@@ -1799,10 +1633,7 @@ Separate a COW snapshot from its origin LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Combine a former COW snapshot (second arg) with a former 
 .br
@@ -1827,10 +1658,7 @@ origin LV (first arg) to reverse a splitsnapshot command.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Combine a former COW snapshot (second arg) with a former 
 .br
@@ -1855,10 +1683,7 @@ origin LV (first arg) to reverse a splitsnapshot command.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Poll LV to continue conversion (also see --startpoll).
 .br
@@ -1869,13 +1694,9 @@ Poll LV to continue conversion (also see --startpoll).
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 .SH NOTES
-
 This previous command syntax would perform two different operations:
 .br
 \fBlvconvert --thinpool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
@@ -1894,9 +1715,7 @@ If LV1 was not a cache pool, the command would convert LV1 to
 a cache pool, optionally using a specified LV for metadata.
 But, if LV1 was already a cache pool, the command would swap
 the current metadata LV with LV2 (for repair purposes.)
-
 .SH EXAMPLES
-
 Convert a linear LV to a two-way mirror LV.
 .br
 .B lvconvert \-\-type mirror \-\-mirrors 1 vg/lvol1
@@ -1989,7 +1808,6 @@ Detach and keep the cache pool from a cache LV.
 Detach and remove the cache pool from a cache LV.
 .br
 .B lvconvert \-\-uncache vg/lvol1
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -2056,4 +1874,3 @@ Detach and remove the cache pool from a cache LV.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 49d9072..9b64c53 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -1,13 +1,8 @@
 .TH LVCREATE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvcreate \- Create a logical volume
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvcreate\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -15,8 +10,6 @@ lvcreate \- Create a logical volume
     [ \fIposition_args\fP ]
 .br
 .P
-
-.P
 .ad l
  \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .ad b
@@ -248,9 +241,6 @@ lvcreate \- Create a logical volume
 .ad l
  \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .ad b
-
-.P
-
 .SH DESCRIPTION
 lvcreate creates a new LV in a VG. For standard LVs, this requires
 allocating logical extents from the VG's free physical extents. If there
@@ -279,9 +269,7 @@ Thin LVs are thinly provisioned from a thin pool, and are created with a
 virtual size rather than a physical size. A cache LV is the combination of
 a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
-
 .SS Usage notes
-
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
@@ -290,13 +278,7 @@ In the usage section below, \fB--name\fP is omitted from the required
 options, even though it is typically used.  When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
 numeric suffix.  Also see the description in the options section.
-
-
-.P
 .SH USAGE
-.br
-.P
-.
 Create a linear LV.
 .br
 .P
@@ -317,10 +299,7 @@ Create a linear LV.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a striped LV (infers --type striped).
 .br
@@ -336,20 +315,13 @@ Create a striped LV (infers --type striped).
 [ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
-.ad l
-[    \fB--type\fP \fBstriped\fP ]
-.ad b
-.br
 [ COMMON_OPTIONS ]
 .RE
 .br
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a raid1 or mirror LV (infers --type raid1|mirror).
 .br
@@ -362,26 +334,10 @@ Create a raid1 or mirror LV (infers --type raid1|mirror).
 .ad b
 .br
 .ad l
-[ \fB-i\fP|\fB--stripes\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-m\fP|\fB--mirrors\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
-.ad b
-.br
-.ad l
 [ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBraid1\fP ]
-.ad b
-.br
-.ad l
 [    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
 .ad b
 .br
@@ -399,10 +355,7 @@ Create a raid1 or mirror LV (infers --type raid1|mirror).
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a raid LV (a specific raid level must be used, e.g. raid1).
 .br
@@ -444,10 +397,44 @@ Create a raid LV (a specific raid level must be used, e.g. raid1).
 .RS 4
 [ \fIPV\fP ... ]
 .RE
+-
 
---
-
+Create a raid10 LV.
+.br
+.P
+\fBlvcreate\fP \fB-m\fP|\fB--mirrors\fP \fINumber\fP \fB-i\fP|\fB--stripes\fP \fINumber\fP
+.RS 5
+ \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT] \fIVG\fP
+.RE
+.br
+.RS 4
+.ad l
+[ \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT] ]
+.ad b
+.br
+.ad l
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+.ad b
 .br
+.ad l
+[    \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
 
 Create a COW snapshot LV of an origin LV.
 .br
@@ -481,10 +468,7 @@ Create a COW snapshot LV of an origin LV.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a thin pool.
 .br
@@ -534,10 +518,7 @@ Create a thin pool.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a cache pool.
 .br
@@ -587,10 +568,7 @@ Create a cache pool.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a thin LV in a thin pool (infers --type thin).
 .br
@@ -617,10 +595,7 @@ Create a thin LV in a thin pool (infers --type thin).
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create a thin LV that is a snapshot of an existing thin LV 
 .br
@@ -645,10 +620,7 @@ Create a thin LV that is a snapshot of an existing thin LV
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create a thin LV that is a snapshot of an external origin LV.
 .br
@@ -683,10 +655,7 @@ Create a thin LV that is a snapshot of an external origin LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create a thin LV, first creating a thin pool for it, 
 .br
@@ -741,10 +710,7 @@ where the new thin pool is named by the --thinpool arg.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a cache LV, first creating a new origin LV, 
 .br
@@ -809,10 +775,7 @@ by the --cachepool arg.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Common options for command:
 .
@@ -900,9 +863,7 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -954,12 +915,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
@@ -978,7 +935,6 @@ if it matches an item in lvm.conf activation/auto_activation_volume_list.
 See lvmlockd(8) for more information about activation options for shared VGs.
 See clvmd(8) for more information about activation options for clustered VGs.
 .ad b
-
 .HP
 .ad l
 \fB--addtag\fP \fITag\fP
@@ -986,7 +942,6 @@ See clvmd(8) for more information about activation options for clustered VGs.
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
-
 .HP
 .ad l
 \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
@@ -1008,7 +963,6 @@ Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -1016,7 +970,6 @@ See \fBlvm\fP(8) for more information about allocation.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-H\fP|\fB--cache\fP
@@ -1025,14 +978,12 @@ Specifies the command is handling a cache LV or cache pool.
 See --type cache and --type cache-pool.
 See \fBlvmcache\fP(7) for more information about LVM caching.
 .ad b
-
 .HP
 .ad l
 \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
 Specifies the cache metadata format used by cache target.
 .ad b
-
 .HP
 .ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
@@ -1049,7 +1000,6 @@ from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--cachepolicy\fP \fIString\fP
@@ -1057,14 +1007,12 @@ block invalidates. See \fBlvmcache\fP(7) for more information.
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--cachepool\fP \fILV\fP
 .br
 The name of a cache pool LV.
 .ad b
-
 .HP
 .ad l
 \fB--cachesettings\fP \fIString\fP
@@ -1077,7 +1025,6 @@ settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
@@ -1093,7 +1040,6 @@ pool metadata size within 128MiB, if the pool metadata size is not specified.
 The value must be a multiple of 64KiB.
 See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -1101,7 +1047,6 @@ See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -1111,7 +1056,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
@@ -1122,7 +1066,6 @@ It is only possible to change a non-contiguous allocation policy
 to contiguous if all of the allocated physical extents in the LV
 are already contiguous.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -1130,7 +1073,6 @@ are already contiguous.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
@@ -1144,7 +1086,6 @@ allow reuse of unneeded extents in the thin pool.
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -1152,7 +1093,6 @@ See \fBlvmthin\fP(7) for more information.
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
@@ -1166,7 +1106,6 @@ Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT]
@@ -1187,14 +1126,12 @@ When expressed as a percentage, the size defines an upper limit for the
 number of logical extents in the new LV. The precise number of logical
 extents in the new LV is not determined until the command has completed.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
@@ -1202,7 +1139,6 @@ Display help text.
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
 .ad b
-
 .HP
 .ad l
 \fB--ignoremonitoring\fP
@@ -1210,21 +1146,18 @@ to allow LVs with the flag set to be activated.
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
 Sets the major number of an LV block device.
 .ad b
-
 .HP
 .ad l
 \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
@@ -1234,7 +1167,6 @@ is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
@@ -1242,14 +1174,12 @@ See \fBlvmraid\fP(7) for more information.
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--minor\fP \fINumber\fP
 .br
 Sets the minor number of an LV block device.
 .ad b
-
 .HP
 .ad l
 \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
@@ -1259,7 +1189,6 @@ is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
@@ -1273,7 +1202,6 @@ In this case, the mirror must be synchronized (by copying LV data from
 the first device to others) each time the LV is activated, e.g. after reboot.
 \fBmirrored\fP is a persistent log that is itself mirrored.
 .ad b
-
 .HP
 .ad l
 \fB-m\fP|\fB--mirrors\fP \fINumber\fP
@@ -1292,7 +1220,6 @@ global/raid10_segtype_default to configure the default types.
 See the --nosync option for avoiding initial image synchronization.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
@@ -1302,7 +1229,6 @@ dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See dmeventd(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
@@ -1311,7 +1237,6 @@ Specifies the name of a new LV.
 When unspecified, a default name of "lvol#" is
 generated, where # is a number generated by LVM.
 .ad b
-
 .HP
 .ad l
 \fB--nosync\fP
@@ -1329,7 +1254,6 @@ to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -1339,28 +1263,24 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
 .br
 Set access permission to read only \fBr\fP or read and write \fBrw\fP.
 .ad b
-
 .HP
 .ad l
 \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
 .br
 When yes, makes the specified minor number persistent.
 .ad b
-
 .HP
 .ad l
 \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
 .br
 Specifies the size of the new pool metadata LV.
 .ad b
-
 .HP
 .ad l
 \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
@@ -1369,7 +1289,6 @@ Enable or disable the automatic creation and management of a
 spare pool metadata LV in the VG. A spare metadata LV is reserved
 space that can be used when repairing a pool.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -1377,7 +1296,6 @@ space that can be used when repairing a pool.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -1385,7 +1303,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
@@ -1395,7 +1312,6 @@ Sets read ahead sector count of an LV.
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
 .ad b
-
 .HP
 .ad l
 \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
@@ -1404,7 +1320,6 @@ Size of each raid or mirror synchronization region.
 lvm.conf activation/raid_region_size can be used to
 configure a default.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -1416,7 +1331,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
@@ -1428,7 +1342,6 @@ This flag is set by default on new thin snapshot LVs.
 The flag is not applied to deactivation.
 The current value of the flag is indicated in the lvs lv_attr bits.
 .ad b
-
 .HP
 .ad l
 \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
@@ -1438,7 +1351,6 @@ The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
 .ad b
-
 .HP
 .ad l
 \fB-s\fP|\fB--snapshot\fP
@@ -1469,7 +1381,6 @@ locations, so the full size is not available for COW data blocks.
 Use lvs to check how much space is used, and see --monitor to
 to automatically extend the size to avoid running out of space.
 .ad b
-
 .HP
 .ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
@@ -1487,7 +1398,6 @@ when unspecified, the default depends on the RAID type
 To stripe a new raid LV across all PVs by default,
 see lvm.conf allocation/raid_stripe_all_devices.
 .ad b
-
 .HP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
@@ -1495,7 +1405,6 @@ see lvm.conf allocation/raid_stripe_all_devices.
 The amount of data that is written to one device before
 moving to the next in a striped LV.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -1506,7 +1415,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-T\fP|\fB--thin\fP
@@ -1515,14 +1423,12 @@ Specifies the command is handling a thin LV or thin pool.
 See --type thin, --type thin-pool, and --virtualsize.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
 .ad b
-
 .HP
 .ad l
 \fB--thinpool\fP \fILV\fP
 .br
 The name of a thin pool LV.
 .ad b
-
 .HP
 .ad l
 \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
@@ -1538,7 +1444,6 @@ is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -1546,14 +1451,12 @@ Use inferred types with care because it can lead to unexpected results.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
@@ -1571,7 +1474,6 @@ is created using the zero target, and the LV has the suffix _vorigin.
 Snapshots are less efficient than thin provisioning when creating
 large sparse LVs (GiB).
 .ad b
-
 .HP
 .ad l
 \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP
@@ -1590,7 +1492,6 @@ Otherwise, native LVM code is used to detect signatures
 (only MD RAID, swap and LUKS signatures are detected in this case.)
 The LV is not wiped if the read only flag is set.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -1599,7 +1500,6 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
-
 .HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
@@ -1611,8 +1511,6 @@ LV is not zeroed if the read only flag is set.
 Warning: trying to mount an unzeroed LV can cause the system to hang.
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
@@ -1620,7 +1518,6 @@ Volume Group name.  See \fBlvm\fP(8) for valid names.
 For lvcreate, the required VG positional arg may be
 omitted when the VG name is included in another option,
 e.g. --name VG/LV.
-
 .HP
 \fILV\fP
 .br
@@ -1628,7 +1525,6 @@ Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-
 .HP
 \fIPV\fP
 .br
@@ -1639,12 +1535,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -1659,7 +1553,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH ADVANCED USAGE
@@ -1678,10 +1571,7 @@ Create an LV that returns errors when used.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create an LV that returns zeros when read.
 .br
@@ -1696,10 +1586,7 @@ Create an LV that returns zeros when read.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create a linear LV.
 .br
@@ -1717,10 +1604,7 @@ Create a linear LV.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a striped LV (also see lvcreate --stripes).
 .br
@@ -1746,10 +1630,7 @@ Create a striped LV (also see lvcreate --stripes).
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a mirror LV (also see --type raid1).
 .br
@@ -1774,6 +1655,10 @@ Create a mirror LV (also see --type raid1).
 .ad b
 .br
 .ad l
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
 [    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
 .ad b
 .br
@@ -1783,10 +1668,7 @@ Create a mirror LV (also see --type raid1).
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a COW snapshot LV of an origin LV 
 .br
@@ -1822,10 +1704,7 @@ Create a COW snapshot LV of an origin LV
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a sparse COW snapshot LV of a virtual origin LV 
 .br
@@ -1856,10 +1735,7 @@ Create a sparse COW snapshot LV of a virtual origin LV
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a sparse COW snapshot LV of a virtual origin LV.
 .br
@@ -1888,10 +1764,7 @@ Create a sparse COW snapshot LV of a virtual origin LV.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a thin pool (infers --type thin-pool).
 .br
@@ -1941,10 +1814,7 @@ Create a thin pool (infers --type thin-pool).
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a thin pool named by the --thinpool arg 
 .br
@@ -2000,10 +1870,7 @@ Create a thin pool named by the --thinpool arg
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a cache pool named by the --cachepool arg 
 .br
@@ -2058,10 +1925,7 @@ Create a cache pool named by the --cachepool arg
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a thin LV in a thin pool.
 .br
@@ -2099,10 +1963,7 @@ Create a thin LV in a thin pool.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create a thin LV in a thin pool named in the first arg 
 .br
@@ -2127,10 +1988,7 @@ Create a thin LV in a thin pool named in the first arg
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create a thin LV in the thin pool named in the first arg 
 .br
@@ -2161,10 +2019,7 @@ naming pool.)
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create a thin LV that is a snapshot of an existing thin LV.
 .br
@@ -2187,10 +2042,7 @@ Create a thin LV that is a snapshot of an existing thin LV.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create a thin LV that is a snapshot of an existing thin LV 
 .br
@@ -2215,10 +2067,7 @@ Create a thin LV that is a snapshot of an existing thin LV
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create a thin LV that is a snapshot of an external origin LV 
 .br
@@ -2243,10 +2092,7 @@ Create a thin LV that is a snapshot of an external origin LV
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Create a thin LV, first creating a thin pool for it, 
 .br
@@ -2303,10 +2149,7 @@ where the new thin pool is named by the --thinpool arg
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a thin LV, first creating a thin pool for it, 
 .br
@@ -2365,10 +2208,7 @@ arg is a VG name.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a thin LV, first creating a thin pool for it, 
 .br
@@ -2427,10 +2267,7 @@ arg is a VG name (variant, infers --type thin).
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a thin LV, first creating a thin pool for it 
 .br
@@ -2498,10 +2335,7 @@ config setting sparse_segtype_default.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a cache LV, first creating a new origin LV, 
 .br
@@ -2559,10 +2393,7 @@ by the --cachepool arg (variant, infers --type cache).
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Create a cache LV, first creating a new origin LV, 
 .br
@@ -2624,10 +2455,7 @@ in the first arg (variant, also use --cachepool).
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 When LV is a cache pool, create a cache LV, 
 .br
@@ -2693,10 +2521,7 @@ to type cache after creating a new cache pool LV to use
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 .SH EXAMPLES
 
@@ -2795,7 +2620,6 @@ then combining the new origin LV with an existing cache pool.
 .RS
 .B \-L 100G \-n mylv vg00 /dev/slow1
 .RE
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -2862,4 +2686,3 @@ then combining the new origin LV with an existing cache pool.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 10d45ae..5670db4 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -1,33 +1,21 @@
 .TH LVDISPLAY 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvdisplay \- Display information about a logical volume
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvdisplay\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvdisplay shows the attributes of LVs, like size, read/write status,
 snapshot information, etc.
 
 \fBlvs\fP(8) is a preferred alternative that shows the same information
 and more, using a more compact and configurable output format.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvdisplay\fP
 .br
 .RS 4
@@ -138,7 +126,6 @@ and more, using a more compact and configurable output format.
 [ \fIVG\fP|\fILV\fP|\fITag\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -189,19 +176,14 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--aligned\fP
 .br
 Use with --separator to align the output columns
 .ad b
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
@@ -210,7 +192,6 @@ Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
 .ad b
-
 .HP
 .ad l
 \fB--binary\fP
@@ -219,7 +200,6 @@ Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
 .ad b
-
 .HP
 .ad l
 \fB-c\fP|\fB--colon\fP
@@ -227,7 +207,6 @@ the "unknown" value which denotes that the value could not be determined).
 Generate colon separated output for easier parsing in scripts or programs.
 Also see vgs(8) which provides considerably more control over the output.
 .ad b
-
 .HP
 .ad l
 \fB-C\fP|\fB--columns\fP
@@ -235,7 +214,6 @@ Also see vgs(8) which provides considerably more control over the output.
 Display output in columns, the equivalent of vgs(8).
 Options listed are the same as options given in vgs(8).
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -243,7 +221,6 @@ Options listed are the same as options given in vgs(8).
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -253,14 +230,12 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -268,7 +243,6 @@ See lvmreport(7).
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -276,7 +250,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB--foreign\fP
@@ -284,14 +257,12 @@ For testing and debugging.
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-H\fP|\fB--history\fP
@@ -300,7 +271,6 @@ Include historical LVs in the output.
 (This has no effect unless LVs were removed while
 lvm.conf metadata/record_lvs_history was enabled.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -308,7 +278,6 @@ lvm.conf metadata/record_lvs_history was enabled.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreskippedcluster\fP
@@ -316,21 +285,18 @@ operations after locking failures.
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
-
 .HP
 .ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-m\fP|\fB--maps\fP
@@ -339,7 +305,6 @@ Display the mapping of logical extents to PVs and physical extents.
 To map physical extents to logical extents use:
 pvs --segments -o+lv_name,seg_start_pe,segtype
 .ad b
-
 .HP
 .ad l
 \fB--noheadings\fP
@@ -347,7 +312,6 @@ pvs --segments -o+lv_name,seg_start_pe,segtype
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--nosuffix\fP
@@ -355,7 +319,6 @@ Useful if grepping the output.
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
 .ad b
-
 .HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
@@ -366,7 +329,8 @@ The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
 Use \fB-o help\fP to view the list of all available fields.
-The -o option can be repeated, providing several lists.
+Use separate lists of fields to add, remove or compact by repeating the -o option:
+-o+field1,field2 -o-field3,field4 -o#field5.
 These lists are evaluated from left to right.
 Use field name \fBlv_all\fP to view all LV fields,
 \fBvg_all\fP all VG fields,
@@ -377,7 +341,6 @@ Use field name \fBlv_all\fP to view all LV fields,
 See the lvm.conf report section for more config options.
 See lvmreport(7) for more information about reporting.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -387,7 +350,6 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -395,7 +357,6 @@ changed with this option.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -403,7 +364,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--readonly\fP
@@ -418,7 +378,6 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not LVs are
 actually in use.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -430,13 +389,11 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--segments\fP
 .br
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -450,14 +407,12 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--shared\fP
@@ -466,7 +421,6 @@ Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See lvmlockd(8) for more information about shared VGs.
 .ad b
-
 .HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
@@ -474,7 +428,6 @@ See lvmlockd(8) for more information about shared VGs.
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -485,14 +438,12 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
-
 .HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
@@ -504,7 +455,6 @@ human-(r)eadable with '<' rounding indicator,
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -512,14 +462,12 @@ Custom units can be specified, e.g. --units 3M.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -529,30 +477,24 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -567,7 +509,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -636,4 +577,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 92e5796..d23b719 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -1,13 +1,8 @@
 .TH LVEXTEND 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvextend \- Add space to a logical volume
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvextend\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -15,8 +10,6 @@ lvextend \- Add space to a logical volume
     [ \fIposition_args\fP ]
 .br
 .P
-
-.P
 .ad l
     \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .ad b
@@ -128,9 +121,6 @@ lvextend \- Add space to a logical volume
 .ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
-
-.P
-
 .SH DESCRIPTION
 lvextend extends the size of an LV. This requires allocating logical
 extents from the VG's free physical extents. If the extension adds a new
@@ -144,12 +134,7 @@ mirrored LV.
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
-
-.P
 .SH USAGE
-.br
-.P
-.
 Extend an LV by a specified size.
 .br
 .P
@@ -182,10 +167,7 @@ Extend an LV by a specified size.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Extend an LV by specified PV extents.
 .br
@@ -208,10 +190,7 @@ Extend an LV by specified PV extents.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Extend a pool metadata SubLV by a specified size.
 .br
@@ -233,10 +212,7 @@ Extend a pool metadata SubLV by a specified size.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Extend an LV according to a predefined policy.
 .br
@@ -254,10 +230,7 @@ Extend an LV according to a predefined policy.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Common options for command:
 .
@@ -297,9 +270,7 @@ Common options for command:
 .ad l
 [    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -351,12 +322,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
@@ -378,7 +345,6 @@ Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -386,7 +352,6 @@ See \fBlvm\fP(8) for more information about allocation.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -394,7 +359,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -404,7 +368,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -412,7 +375,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -420,7 +382,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--extents\fP [\fB+\fP]\fINumber\fP[PERCENT]
@@ -444,7 +405,6 @@ When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -452,28 +412,24 @@ from the current size.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-m\fP|\fB--mirrors\fP \fINumber\fP
 .br
 Not used.
 .ad b
-
 .HP
 .ad l
 \fB-n\fP|\fB--nofsck\fP
@@ -482,7 +438,6 @@ Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
 .ad b
-
 .HP
 .ad l
 \fB--nosync\fP
@@ -500,7 +455,6 @@ to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -510,7 +464,6 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
@@ -519,7 +472,6 @@ Specifies the new size of the pool metadata LV.
 The plus prefix \fB+\fP can be used, in which case
 the value is added to the current size.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -527,7 +479,6 @@ the value is added to the current size.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -535,7 +486,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -547,14 +497,12 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
 Resize underlying filesystem together with the LV using fsadm(8).
 .ad b
-
 .HP
 .ad l
 \fB-L\fP|\fB--size\fP [\fB+\fP]\fISize\fP[m|UNIT]
@@ -567,7 +515,6 @@ When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
 .ad b
-
 .HP
 .ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
@@ -585,7 +532,6 @@ when unspecified, the default depends on the RAID type
 To stripe a new raid LV across all PVs by default,
 see lvm.conf allocation/raid_stripe_all_devices.
 .ad b
-
 .HP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
@@ -593,7 +539,6 @@ see lvm.conf allocation/raid_stripe_all_devices.
 The amount of data that is written to one device before
 moving to the next in a striped LV.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -604,7 +549,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
@@ -620,7 +564,6 @@ is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
-
 .HP
 .ad l
 \fB--usepolicies\fP
@@ -628,7 +571,6 @@ Use inferred types with care because it can lead to unexpected results.
 Perform an operation according to the policy configured in lvm.conf
 or a profile.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -636,14 +578,12 @@ or a profile.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -653,8 +593,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fILV\fP
 .br
@@ -662,7 +600,6 @@ Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-
 .HP
 \fIPV\fP
 .br
@@ -673,12 +610,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -693,11 +628,9 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
-
 Extend the size of an LV by 54MiB, using a specific PV.
 .br
 .B lvextend \-L +54 vg01/lvol10 /dev/sdk3
@@ -711,7 +644,6 @@ space on PV /dev/sdk3. This is equivalent to specifying
 Extend an LV by 16MiB using specific physical extents.
 .br
 .B lvextend \-L+16m vg01/lvol01 /dev/sda:8\-9 /dev/sdb:8\-9
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -778,4 +710,3 @@ Extend an LV by 16MiB using specific physical extents.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvm-config.8_pregen b/man/lvm-config.8_pregen
index 7223fd2..3eb34a5 100644
--- a/man/lvm-config.8_pregen
+++ b/man/lvm-config.8_pregen
@@ -1,33 +1,21 @@
 .TH LVM CONFIG 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvm config \- Display and manipulate configuration information
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvm config\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 This command is the same as \fBlvmconfig\fP(8).
 
 lvm config produces formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
 line settings from \-\-config.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvm config\fP
 .br
 .RS 4
@@ -110,7 +98,6 @@ line settings from \-\-config.
 [ \fIString\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -161,12 +148,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--atversion\fP \fIString\fP
@@ -179,7 +162,6 @@ to display a configuration that a certain LVM version understands and
 which does not contain any newer settings for which LVM would
 issue a warning message when checking the configuration.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -187,7 +169,6 @@ issue a warning message when checking the configuration.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -197,7 +178,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -205,7 +185,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -213,35 +192,30 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
 Write output to the named file.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreadvanced\fP
 .br
 Exclude advanced configuration settings from the output.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelocal\fP
 .br
 Ignore local section.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreunsupported\fP
@@ -252,7 +226,6 @@ yet complete and they are not meant to be used in production. The \fBcurrent\fP
 and \fBdiff\fP types include unsupported settings in their output by default,
 all the other types ignore unsupported settings.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--list\fP
@@ -260,14 +233,12 @@ all the other types ignore unsupported settings.
 List config settings with summarizing comment. This is the same as using
 options --typeconfig list --withsummary.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--mergedconfig\fP
@@ -280,7 +251,6 @@ Without merging, only the configuration at the front of the
 cascade is displayed.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
@@ -288,7 +258,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -296,7 +265,6 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -304,7 +272,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--showdeprecated\fP
@@ -316,7 +283,6 @@ if the specified version is lower than the version in which the settings were
 deprecated. The current and diff types include deprecated settings
 in their output by default, all the other types ignore deprecated settings.
 .ad b
-
 .HP
 .ad l
 \fB--showunsupported\fP
@@ -327,7 +293,6 @@ is not yet complete and they are not meant to be used in production. The
 current and diff types include unsupported settings in their
 output by default, all the other types ignore unsupported settings.
 .ad b
-
 .HP
 .ad l
 \fB--sinceversion\fP \fIString\fP
@@ -337,7 +302,6 @@ the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 This option is currently applicable only with --typeconfig new
 to display all configuration settings introduced since given version.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -348,21 +312,18 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
 .br
 See lvmreport(7).
 .ad b
-
 .HP
 .ad l
 \fB--unconfigured\fP
 .br
 Internal option used for generating config file during build.
 .ad b
-
 .HP
 .ad l
 \fB--validate\fP
@@ -373,7 +334,6 @@ at the front of the "config cascade". To validate the whole
 merged configuration tree, also use --mergedconfig.
 The validation is done even if lvm.conf config/checks is disabled.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -381,14 +341,12 @@ The validation is done even if lvm.conf config/checks is disabled.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB--withcomments\fP
@@ -396,21 +354,18 @@ Display version information.
 Display a full comment for each configuration node. For deprecated
 settings, also display comments about deprecation.
 .ad b
-
 .HP
 .ad l
 \fB--withspaces\fP
 .br
 Where appropriate, add more spaces in output for better readability.
 .ad b
-
 .HP
 .ad l
 \fB--withsummary\fP
 .br
 Display a one line comment for each configuration node.
 .ad b
-
 .HP
 .ad l
 \fB--withversions\fP
@@ -419,7 +374,6 @@ Also display a comment containing the version of introduction for
 each configuration node. If the setting is deprecated, also display
 the version since which it is deprecated.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -429,13 +383,10 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -450,7 +401,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -519,4 +469,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvm-dumpconfig.8_pregen b/man/lvm-dumpconfig.8_pregen
index acc54ca..1b47fd5 100644
--- a/man/lvm-dumpconfig.8_pregen
+++ b/man/lvm-dumpconfig.8_pregen
@@ -1,33 +1,21 @@
 .TH LVM DUMPCONFIG 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvm dumpconfig \- Display and manipulate configuration information
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvm dumpconfig\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 This command is the same as \fBlvmconfig\fP(8).
 
 lvm dumpconfig produces formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
 line settings from \-\-config.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvm dumpconfig\fP
 .br
 .RS 4
@@ -110,7 +98,6 @@ line settings from \-\-config.
 [ \fIString\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -161,12 +148,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--atversion\fP \fIString\fP
@@ -179,7 +162,6 @@ to display a configuration that a certain LVM version understands and
 which does not contain any newer settings for which LVM would
 issue a warning message when checking the configuration.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -187,7 +169,6 @@ issue a warning message when checking the configuration.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -197,7 +178,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -205,7 +185,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -213,35 +192,30 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
 Write output to the named file.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreadvanced\fP
 .br
 Exclude advanced configuration settings from the output.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelocal\fP
 .br
 Ignore local section.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreunsupported\fP
@@ -252,7 +226,6 @@ yet complete and they are not meant to be used in production. The \fBcurrent\fP
 and \fBdiff\fP types include unsupported settings in their output by default,
 all the other types ignore unsupported settings.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--list\fP
@@ -260,14 +233,12 @@ all the other types ignore unsupported settings.
 List config settings with summarizing comment. This is the same as using
 options --typeconfig list --withsummary.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--mergedconfig\fP
@@ -280,7 +251,6 @@ Without merging, only the configuration at the front of the
 cascade is displayed.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
@@ -288,7 +258,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -296,7 +265,6 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -304,7 +272,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--showdeprecated\fP
@@ -316,7 +283,6 @@ if the specified version is lower than the version in which the settings were
 deprecated. The current and diff types include deprecated settings
 in their output by default, all the other types ignore deprecated settings.
 .ad b
-
 .HP
 .ad l
 \fB--showunsupported\fP
@@ -327,7 +293,6 @@ is not yet complete and they are not meant to be used in production. The
 current and diff types include unsupported settings in their
 output by default, all the other types ignore unsupported settings.
 .ad b
-
 .HP
 .ad l
 \fB--sinceversion\fP \fIString\fP
@@ -337,7 +302,6 @@ the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 This option is currently applicable only with --typeconfig new
 to display all configuration settings introduced since given version.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -348,21 +312,18 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
 .br
 See lvmreport(7).
 .ad b
-
 .HP
 .ad l
 \fB--unconfigured\fP
 .br
 Internal option used for generating config file during build.
 .ad b
-
 .HP
 .ad l
 \fB--validate\fP
@@ -373,7 +334,6 @@ at the front of the "config cascade". To validate the whole
 merged configuration tree, also use --mergedconfig.
 The validation is done even if lvm.conf config/checks is disabled.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -381,14 +341,12 @@ The validation is done even if lvm.conf config/checks is disabled.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB--withcomments\fP
@@ -396,21 +354,18 @@ Display version information.
 Display a full comment for each configuration node. For deprecated
 settings, also display comments about deprecation.
 .ad b
-
 .HP
 .ad l
 \fB--withspaces\fP
 .br
 Where appropriate, add more spaces in output for better readability.
 .ad b
-
 .HP
 .ad l
 \fB--withsummary\fP
 .br
 Display a one line comment for each configuration node.
 .ad b
-
 .HP
 .ad l
 \fB--withversions\fP
@@ -419,7 +374,6 @@ Also display a comment containing the version of introduction for
 each configuration node. If the setting is deprecated, also display
 the version since which it is deprecated.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -429,13 +383,10 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -450,7 +401,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -519,4 +469,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 74f8dd3..c62b449 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -1,21 +1,14 @@
 .TH LVM FULLREPORT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvm fullreport \- Display full report
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvm fullreport\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvm fullreport produces formatted output about PVs, PV segments, VGs, LVs
 and LV segments. The information is all gathered together for each VG
@@ -23,12 +16,7 @@ and LV segments. The information is all gathered together for each VG
 separate calls to \fBvgs\fP, \fBpvs\fP, and \fBlvs\fP can be inconsistent
 if information changes between commands.
 
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvm fullreport\fP
 .br
 .RS 4
@@ -139,7 +127,6 @@ if information changes between commands.
 [ \fIVG\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -190,25 +177,19 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--aligned\fP
 .br
 Use with --separator to align the output columns
 .ad b
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
-
 .HP
 .ad l
 \fB--binary\fP
@@ -217,7 +198,6 @@ Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -225,7 +205,6 @@ the "unknown" value which denotes that the value could not be determined).
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -235,14 +214,12 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -250,7 +227,6 @@ See lvmreport(7).
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -258,7 +234,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB--foreign\fP
@@ -266,14 +241,12 @@ For testing and debugging.
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -281,7 +254,6 @@ Display help text.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreskippedcluster\fP
@@ -289,21 +261,18 @@ operations after locking failures.
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
-
 .HP
 .ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--nameprefixes\fP
@@ -312,7 +281,6 @@ Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
 .ad b
-
 .HP
 .ad l
 \fB--noheadings\fP
@@ -320,14 +288,12 @@ be used to set environment variables (for example, in udev rules).
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--nolocking\fP
 .br
 Disable locking.
 .ad b
-
 .HP
 .ad l
 \fB--nosuffix\fP
@@ -335,7 +301,6 @@ Disable locking.
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
 .ad b
-
 .HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
@@ -346,7 +311,8 @@ The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
 Use \fB-o help\fP to view the list of all available fields.
-The -o option can be repeated, providing several lists.
+Use separate lists of fields to add, remove or compact by repeating the -o option:
+-o+field1,field2 -o-field3,field4 -o#field5.
 These lists are evaluated from left to right.
 Use field name \fBlv_all\fP to view all LV fields,
 \fBvg_all\fP all VG fields,
@@ -357,7 +323,6 @@ Use field name \fBlv_all\fP to view all LV fields,
 See the lvm.conf report section for more config options.
 See lvmreport(7) for more information about reporting.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -367,7 +332,6 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -375,7 +339,6 @@ changed with this option.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -383,7 +346,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--readonly\fP
@@ -398,7 +360,6 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not LVs are
 actually in use.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -410,14 +371,12 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--rows\fP
 .br
 Output columns as rows.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -431,14 +390,12 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--shared\fP
@@ -447,7 +404,6 @@ Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See lvmlockd(8) for more information about shared VGs.
 .ad b
-
 .HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
@@ -455,7 +411,6 @@ See lvmlockd(8) for more information about shared VGs.
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -466,21 +421,18 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--trustcache\fP
 .br
 Avoids certain device scanning during command processing. Do not use.
 .ad b
-
 .HP
 .ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
-
 .HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
@@ -492,7 +444,6 @@ human-(r)eadable with '<' rounding indicator,
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
 .ad b
-
 .HP
 .ad l
 \fB--unquoted\fP
@@ -500,7 +451,6 @@ Custom units can be specified, e.g. --units 3M.
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -508,14 +458,12 @@ pairs are not quoted.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -525,18 +473,14 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -551,7 +495,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -620,4 +563,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 935123c..5f2b225 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -1,30 +1,18 @@
 .TH LVM LVPOLL 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvm lvpoll \- Continue already initiated poll operation on a logical volume
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvm lvpoll\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvm lvpoll is an internal command used by \fBlvmpolld\fP(8) to monitor and
 complete \fBlvconvert\fP(8) and \fBpvmove\fP(8) operations. lvpoll itself
 does not initiate these operations and should not normally need to be run
 directly.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvm lvpoll\fP \fB--polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP \fILV\fP ...
 .br
 .RS 4
@@ -48,7 +36,6 @@ directly.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -99,19 +86,14 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--abort\fP
 .br
 Stop processing a poll operation in lvmpolld.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -119,7 +101,6 @@ Stop processing a poll operation in lvmpolld.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -127,7 +108,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -137,7 +117,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -145,7 +124,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -153,7 +131,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB--handlemissingpvs\fP
@@ -161,35 +138,30 @@ For testing and debugging.
 Allows a polling operation to continue when PVs are missing,
 e.g. for repairs due to faulty devices.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
 Report progress at regular intervals.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP
 .br
 The command to perform from lvmpolld.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -197,7 +169,6 @@ The command to perform from lvmpolld.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -205,7 +176,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -216,7 +186,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -224,14 +193,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -241,19 +208,15 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -268,7 +231,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH NOTES
@@ -277,7 +239,6 @@ To find the name of the pvmove LV that was created by an original
 \fBpvmove /dev/name\fP command, use the command:
 .br
 \fBlvs -a -S move_pv=/dev/name\fP.
-
 .SH EXAMPLES
 
 Continue polling a pvmove operation.
@@ -303,7 +264,6 @@ Continue snapshot merge.
 Continue thin snapshot merge.
 .br
 .B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -370,4 +330,3 @@ Continue thin snapshot merge.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index e3bfdfc..cfa03fe 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -1,31 +1,19 @@
 .TH LVMCONFIG 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvmconfig \- Display and manipulate configuration information
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvmconfig\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvmconfig produces formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
 line settings from \-\-config.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvmconfig\fP
 .br
 .RS 4
@@ -108,7 +96,6 @@ line settings from \-\-config.
 [ \fIString\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -159,12 +146,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--atversion\fP \fIString\fP
@@ -177,7 +160,6 @@ to display a configuration that a certain LVM version understands and
 which does not contain any newer settings for which LVM would
 issue a warning message when checking the configuration.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -185,7 +167,6 @@ issue a warning message when checking the configuration.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -195,7 +176,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -203,7 +183,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -211,35 +190,30 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
 Write output to the named file.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreadvanced\fP
 .br
 Exclude advanced configuration settings from the output.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelocal\fP
 .br
 Ignore local section.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreunsupported\fP
@@ -250,7 +224,6 @@ yet complete and they are not meant to be used in production. The \fBcurrent\fP
 and \fBdiff\fP types include unsupported settings in their output by default,
 all the other types ignore unsupported settings.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--list\fP
@@ -258,14 +231,12 @@ all the other types ignore unsupported settings.
 List config settings with summarizing comment. This is the same as using
 options --typeconfig list --withsummary.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--mergedconfig\fP
@@ -278,7 +249,6 @@ Without merging, only the configuration at the front of the
 cascade is displayed.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
@@ -286,7 +256,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -294,7 +263,6 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -302,7 +270,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--showdeprecated\fP
@@ -314,7 +281,6 @@ if the specified version is lower than the version in which the settings were
 deprecated. The current and diff types include deprecated settings
 in their output by default, all the other types ignore deprecated settings.
 .ad b
-
 .HP
 .ad l
 \fB--showunsupported\fP
@@ -325,7 +291,6 @@ is not yet complete and they are not meant to be used in production. The
 current and diff types include unsupported settings in their
 output by default, all the other types ignore unsupported settings.
 .ad b
-
 .HP
 .ad l
 \fB--sinceversion\fP \fIString\fP
@@ -335,7 +300,6 @@ the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 This option is currently applicable only with --typeconfig new
 to display all configuration settings introduced since given version.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -346,21 +310,18 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
 .br
 See lvmreport(7).
 .ad b
-
 .HP
 .ad l
 \fB--unconfigured\fP
 .br
 Internal option used for generating config file during build.
 .ad b
-
 .HP
 .ad l
 \fB--validate\fP
@@ -371,7 +332,6 @@@the front of the "config cascade". To validate the whole
 merged configuration tree, also use --mergedconfig.
 The validation is done even if lvm.conf config/checks is disabled.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -379,14 +339,12 @@ The validation is done even if lvm.conf config/checks is disabled.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB--withcomments\fP
@@ -394,21 +352,18 @@ Display version information.
 Display a full comment for each configuration node. For deprecated
 settings, also display comments about deprecation.
 .ad b
-
 .HP
 .ad l
 \fB--withspaces\fP
 .br
 Where appropriate, add more spaces in output for better readability.
 .ad b
-
 .HP
 .ad l
 \fB--withsummary\fP
 .br
 Display a one line comment for each configuration node.
 .ad b
-
 .HP
 .ad l
 \fB--withversions\fP
@@ -417,7 +372,6 @@ Also display a comment containing the version of introduction for
 each configuration node. If the setting is deprecated, also display
 the version since which it is deprecated.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -427,13 +381,10 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -448,7 +399,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -517,4 +467,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index fc87d65..67e923b 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -1,19 +1,12 @@
 .TH LVMDISKSCAN 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvmdiskscan \- List devices that may be used as physical volumes
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvmdiskscan\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvmdiskscan scans all SCSI, (E)IDE disks, multiple devices and a bunch of
 other block devices in the system looking for LVM PVs. The size reported
@@ -22,12 +15,7 @@ the scan to avoid a CD ROM, for example.
 
 This command is deprecated, use \fBpvs\fP instead.
 
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvmdiskscan\fP
 .br
 .RS 4
@@ -43,7 +31,6 @@ This command is deprecated, use \fBpvs\fP instead.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -94,12 +81,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -107,7 +90,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -117,7 +99,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -125,7 +106,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -133,28 +113,24 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--lvmpartition\fP
 .br
 Only report PVs.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -162,7 +138,6 @@ Only report PVs.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -170,7 +145,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--readonly\fP
@@ -185,7 +159,6 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not LVs are
 actually in use.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -196,7 +169,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -204,14 +176,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -221,13 +191,10 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -242,7 +209,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -311,4 +277,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvmsadc.8_pregen b/man/lvmsadc.8_pregen
index 6ee5e3e..ed4a0d7 100644
--- a/man/lvmsadc.8_pregen
+++ b/man/lvmsadc.8_pregen
@@ -1,29 +1,17 @@
 .TH LVMSADC 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvmsadc \- Collect activity data
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvmsadc\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvmsadc is not currently supported in LVM. The device-mapper statistics
 facility provides similar performance metrics using the \fBdmstats(8)\fP
 command.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvmsadc\fP
 .br
 .RS 4
@@ -31,7 +19,6 @@ command.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -82,12 +69,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -95,7 +78,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -105,7 +87,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -113,7 +94,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -121,21 +101,18 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -143,7 +120,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -151,7 +127,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -162,7 +137,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -170,14 +144,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -187,13 +159,10 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -208,7 +177,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -277,4 +245,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvmsar.8_pregen b/man/lvmsar.8_pregen
index f0f57c8..547a0a0 100644
--- a/man/lvmsar.8_pregen
+++ b/man/lvmsar.8_pregen
@@ -1,29 +1,17 @@
 .TH LVMSAR 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvmsar \- Create activity report
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvmsar\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvmsar is not currently supported in LVM. The device-mapper statistics
 facility provides similar performance metrics using the \fBdmstats(8)\fP
 command.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvmsar\fP
 .br
 .RS 4
@@ -38,7 +26,6 @@ command.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
 Common options for lvm:
 .
 .RS 4
@@ -89,12 +76,9 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
 
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -102,7 +86,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -112,7 +95,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -120,7 +102,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -128,25 +109,21 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--full\fP.ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -154,7 +131,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -162,11 +138,9 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-s\fP|\fB--stdin\fP.ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -177,7 +151,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -185,14 +158,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -202,13 +173,10 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -223,7 +191,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 
@@ -293,4 +260,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 67c382b..931b754 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -1,19 +1,12 @@
 .TH LVREDUCE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvreduce \- Reduce the size of a logical volume
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvreduce\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvreduce reduces the size of an LV. The freed logical extents are returned
 to the VG to be used by other LVs. A copy\-on\-write snapshot LV can also
@@ -33,13 +26,7 @@ multiple of the number of stripes.
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
-
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvreduce\fP \fB-L\fP|\fB--size\fP [\fB-\fP]\fISize\fP[m|UNIT] \fILV\fP
 .br
 .RS 4
@@ -75,7 +62,6 @@ the options section.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -126,12 +112,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -139,7 +121,6 @@ Common options for lvm:
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -147,7 +128,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -157,7 +137,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -165,7 +144,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -173,7 +151,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--extents\fP [\fB-\fP]\fINumber\fP[PERCENT]
@@ -197,7 +174,6 @@ When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -205,21 +181,18 @@ from the current size.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-n\fP|\fB--nofsck\fP
@@ -228,7 +201,6 @@ Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -238,7 +210,6 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -246,7 +217,6 @@ ignore the devices LVM creates.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -254,7 +224,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -266,14 +235,12 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
 Resize underlying filesystem together with the LV using fsadm(8).
 .ad b
-
 .HP
 .ad l
 \fB-L\fP|\fB--size\fP [\fB-\fP]\fISize\fP[m|UNIT]
@@ -286,7 +253,6 @@ When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -297,7 +263,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -305,14 +270,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -322,19 +285,15 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -349,7 +308,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -423,4 +381,3 @@ Reduce the size of an LV by 3 logical extents:
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index e823f1c..a502397 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -1,19 +1,12 @@
 .TH LVREMOVE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvremove \- Remove logical volume(s) from the system
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvremove\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvremove removes one or more LVs. For standard LVs, this returns the
 logical extents that were used by the LV to the VG for use by other LVs.
@@ -41,13 +34,7 @@ some intermediate LVs have been removed. The names of such historical LVs
 acquire a hyphen as a prefix (e.g. '-lvol1') and cannot be reactivated.
 Use lvremove a second time, with the hyphen, to remove the record of the
 former LV completely.
-
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvremove\fP \fIVG\fP|\fILV\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
@@ -79,7 +66,6 @@ former LV completely.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -130,12 +116,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -143,7 +125,6 @@ Common options for lvm:
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -151,7 +132,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -161,7 +141,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -169,7 +148,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -177,7 +155,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -185,21 +162,18 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--nohistory\fP
@@ -208,7 +182,6 @@ Do not record history of LVs being removed.
 This has no effect unless the configuration setting
 metadata/record_lvs_history is enabled.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -218,7 +191,6 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -226,7 +198,6 @@ ignore the devices LVM creates.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -234,7 +205,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -246,7 +216,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -260,7 +229,6 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -271,7 +239,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -279,14 +246,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -296,37 +261,30 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -341,11 +299,9 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
-
 Remove an active LV without asking for confirmation.
 .br
 .B lvremove \-f vg00/lvol1
@@ -353,8 +309,6 @@ Remove an active LV without asking for confirmation.
 Remove all LVs the specified VG.
 .br
 .B lvremove vg00
-
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -421,4 +375,3 @@ Remove all LVs the specified VG.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 20bdfbf..3eafe3d 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -1,28 +1,16 @@
 .TH LVRENAME 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvrename \- Rename a logical volume
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvrename\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvrename renames an existing LV or a historical LV (see \fBlvremove\fP for
 historical LV information.)
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvrename\fP \fIVG\fP \fILV\fP \fILV\fP\fI_new\fP
 .br
 .RS 4
@@ -30,7 +18,6 @@ historical LV information.)
 .RE
 .br
 
-
 \fBlvrename\fP \fILV\fP \fILV\fP\fI_new\fP
 .br
 .RS 4
@@ -38,7 +25,6 @@ historical LV information.)
 .RE
 .br
 
-
 Common options for command:
 .
 .RS 4
@@ -53,9 +39,7 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -107,12 +91,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -120,7 +100,6 @@ Common options for lvm:
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -128,7 +107,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -138,7 +116,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -146,7 +123,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -154,21 +130,18 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -178,7 +151,6 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -186,7 +158,6 @@ ignore the devices LVM creates.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -194,7 +165,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -206,7 +176,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -217,7 +186,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -225,14 +193,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -242,24 +208,19 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -274,7 +235,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -286,7 +246,6 @@ Rename "lvold" to "lvnew":
 An alternate syntax to rename "lvold" to "lvnew":
 .br
 .B lvrename vg02 lvold lvnew
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -353,4 +312,3 @@ An alternate syntax to rename "lvold" to "lvnew":
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 598cde0..ca8c2bf 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -1,13 +1,8 @@
 .TH LVRESIZE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvresize \- Resize a logical volume
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvresize\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -15,8 +10,6 @@ lvresize \- Resize a logical volume
     [ \fIposition_args\fP ]
 .br
 .P
-
-.P
 .ad l
     \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
 .ad b
@@ -120,9 +113,6 @@ lvresize \- Resize a logical volume
 .ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
-
-.P
-
 .SH DESCRIPTION
 lvresize resizes an LV in the same way as lvextend and lvreduce. See
 \fBlvextend\fP(8) and \fBlvreduce\fP(8) for more information.
@@ -130,13 +120,7 @@ lvresize resizes an LV in the same way as lvextend and lvreduce. See
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
-
-
-.P
 .SH USAGE
-.br
-.P
-.
 Resize an LV by a specified size.
 .br
 .P
@@ -161,10 +145,7 @@ Resize an LV by a specified size.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Resize an LV by specified PV extents.
 .br
@@ -179,10 +160,7 @@ Resize an LV by specified PV extents.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Resize a pool metadata SubLV by a specified size.
 .br
@@ -196,10 +174,7 @@ Resize a pool metadata SubLV by a specified size.
 .RS 4
 [ \fIPV\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Common options for command:
 .
@@ -243,9 +218,7 @@ Common options for command:
 .ad l
 [    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -297,12 +270,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
@@ -324,7 +293,6 @@ Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -332,7 +300,6 @@ See \fBlvm\fP(8) for more information about allocation.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -340,7 +307,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -350,7 +316,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -358,7 +323,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -366,7 +330,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT]
@@ -390,7 +353,6 @@ When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -398,21 +360,18 @@ from the current size.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-n\fP|\fB--nofsck\fP
@@ -421,7 +380,6 @@ Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
 .ad b
-
 .HP
 .ad l
 \fB--nosync\fP
@@ -439,7 +397,6 @@ to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -449,7 +406,6 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
@@ -458,7 +414,6 @@ Specifies the new size of the pool metadata LV.
 The plus prefix \fB+\fP can be used, in which case
 the value is added to the current size.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -466,7 +421,6 @@ the value is added to the current size.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -474,7 +428,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -486,14 +439,12 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
 Resize underlying filesystem together with the LV using fsadm(8).
 .ad b
-
 .HP
 .ad l
 \fB-L\fP|\fB--size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]
@@ -506,7 +457,6 @@ When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
 .ad b
-
 .HP
 .ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
@@ -524,7 +474,6 @@ when unspecified, the default depends on the RAID type
 To stripe a new raid LV across all PVs by default,
 see lvm.conf allocation/raid_stripe_all_devices.
 .ad b
-
 .HP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
@@ -532,7 +481,6 @@ see lvm.conf allocation/raid_stripe_all_devices.
 The amount of data that is written to one device before
 moving to the next in a striped LV.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -543,7 +491,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBmirror\fP|\fBraid\fP|\fBthin\fP|\fBcache\fP|\fBthin-pool\fP|\fBcache-pool\fP
@@ -559,7 +506,6 @@ is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).
 Use inferred types with care because it can lead to unexpected results.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -567,14 +513,12 @@ Use inferred types with care because it can lead to unexpected results.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -584,8 +528,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fILV\fP
 .br
@@ -593,7 +535,6 @@ Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-
 .HP
 \fIPV\fP
 .br
@@ -604,12 +545,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -624,7 +563,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -632,7 +570,6 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 Extend an LV by 16MB using specific physical extents:
 .br
 .B lvresize \-L+16M vg1/lv1 /dev/sda:0\-1 /dev/sdb:0\-1
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -699,4 +636,3 @@ Extend an LV by 16MB using specific physical extents:
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 2abe377..bd7bd3e 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -1,29 +1,17 @@
 .TH LVS 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvs \- Display information about logical volumes
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvs\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvs produces formatted output about LVs.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvs\fP
 .br
 .RS 4
@@ -142,7 +130,6 @@ lvs produces formatted output about LVs.
 [ \fIVG\fP|\fILV\fP|\fITag\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -193,19 +180,14 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--aligned\fP
 .br
 Use with --separator to align the output columns
 .ad b
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
@@ -214,7 +196,6 @@ Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
 .ad b
-
 .HP
 .ad l
 \fB--binary\fP
@@ -223,7 +204,6 @@ Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -231,7 +211,6 @@ the "unknown" value which denotes that the value could not be determined).
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -241,14 +220,12 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -256,7 +233,6 @@ See lvmreport(7).
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -264,7 +240,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB--foreign\fP
@@ -272,14 +247,12 @@ For testing and debugging.
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-H\fP|\fB--history\fP
@@ -288,7 +261,6 @@ Include historical LVs in the output.
 (This has no effect unless LVs were removed while
 lvm.conf metadata/record_lvs_history was enabled.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -296,7 +268,6 @@ lvm.conf metadata/record_lvs_history was enabled.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreskippedcluster\fP
@@ -304,21 +275,18 @@ operations after locking failures.
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
-
 .HP
 .ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--nameprefixes\fP
@@ -327,7 +295,6 @@ Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
 .ad b
-
 .HP
 .ad l
 \fB--noheadings\fP
@@ -335,14 +302,12 @@ be used to set environment variables (for example, in udev rules).
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--nolocking\fP
 .br
 Disable locking.
 .ad b
-
 .HP
 .ad l
 \fB--nosuffix\fP
@@ -350,7 +315,6 @@ Disable locking.
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
 .ad b
-
 .HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
@@ -361,7 +325,8 @@ The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
 Use \fB-o help\fP to view the list of all available fields.
-The -o option can be repeated, providing several lists.
+Use separate lists of fields to add, remove or compact by repeating the -o option:
+-o+field1,field2 -o-field3,field4 -o#field5.
 These lists are evaluated from left to right.
 Use field name \fBlv_all\fP to view all LV fields,
 \fBvg_all\fP all VG fields,
@@ -372,7 +337,6 @@ Use field name \fBlv_all\fP to view all LV fields,
 See the lvm.conf report section for more config options.
 See lvmreport(7) for more information about reporting.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -382,7 +346,6 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -390,7 +353,6 @@ changed with this option.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -398,7 +360,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--readonly\fP
@@ -413,7 +374,6 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not LVs are
 actually in use.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -425,21 +385,18 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--rows\fP
 .br
 Output columns as rows.
 .ad b
-
 .HP
 .ad l
 \fB--segments\fP
 .br
 Use default columns that emphasize segment information.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -453,14 +410,12 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--shared\fP
@@ -469,7 +424,6 @@ Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See lvmlockd(8) for more information about shared VGs.
 .ad b
-
 .HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
@@ -477,7 +431,6 @@ See lvmlockd(8) for more information about shared VGs.
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -488,21 +441,18 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--trustcache\fP
 .br
 Avoids certain device scanning during command processing. Do not use.
 .ad b
-
 .HP
 .ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
-
 .HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
@@ -514,7 +464,6 @@ human-(r)eadable with '<' rounding indicator,
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
 .ad b
-
 .HP
 .ad l
 \fB--unquoted\fP
@@ -522,7 +471,6 @@ Custom units can be specified, e.g. --units 3M.
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -530,14 +478,12 @@ pairs are not quoted.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -547,30 +493,24 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -585,7 +525,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH NOTES
@@ -663,7 +602,6 @@ Related to Thin Logical Volumes: (F)ailed.
 is permitted at all.
 .IP 10 3
 s(k)ip activation: this volume is flagged to be skipped during activation.
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -730,4 +668,3 @@ s(k)ip activation: this volume is flagged to be skipped during activation.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 421b6c5..f386352 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -1,33 +1,21 @@
 .TH LVSCAN 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 lvscan \- List all logical volumes in all volume groups
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBlvscan\fP \fIoption_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 lvscan scans all VGs or all supported LVM block devices in the system for
 LVs. The output consists of one line for each LV indicating whether or not
 it is active, a snapshot or origin, the size of the device and its
 allocation policy. Use \fBlvs\fP(8) or \fBlvdisplay\fP(8) to obtain more
 comprehensive information about LVs.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBlvscan\fP
 .br
 .RS 4
@@ -39,7 +27,6 @@ comprehensive information about LVs.
 .RE
 .br
 
-
 \fBlvscan\fP \fB--cache\fP
 .br
 .RS 4
@@ -50,7 +37,6 @@ comprehensive information about LVs.
 [ \fILV\fP ... ]
 .RE
 
-
 Common options for command:
 .
 .RS 4
@@ -73,9 +59,7 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -127,12 +111,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
@@ -141,21 +121,18 @@ Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
 .ad b
-
 .HP
 .ad l
 \fB-b\fP|\fB--blockdevice\fP
 .br
 No longer used.
 .ad b
-
 .HP
 .ad l
 \fB--cache\fP
 .br
 Scan the devices used by an LV and send the metadata to lvmetad.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -163,7 +140,6 @@ Scan the devices used by an LV and send the metadata to lvmetad.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -173,7 +149,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -181,7 +156,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -189,14 +163,12 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -204,14 +176,12 @@ Display help text.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -221,7 +191,6 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -229,7 +198,6 @@ changed with this option.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -237,7 +205,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--readonly\fP
@@ -252,7 +219,6 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not LVs are
 actually in use.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -264,7 +230,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -275,7 +240,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -283,14 +247,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -300,19 +262,15 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -327,7 +285,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -396,4 +353,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 1b72672..ccfce11 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -1,27 +1,15 @@
 .TH PVCHANGE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 pvchange \- Change attributes of physical volume(s)
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBpvchange\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 pvchange changes PV attributes in the VG.
-
-.P
 .SH USAGE
-.br
-.P
-.
 Change properties of all PVs.
 .br
 .P
@@ -55,7 +43,6 @@ Change properties of all PVs.
 .RE
 .br
 
-
 Change properties of specified PVs.
 .br
 .P
@@ -92,7 +79,6 @@ Change properties of specified PVs.
 .RE
 .br
 
-
 Common options for command:
 .
 .RS 4
@@ -115,9 +101,7 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -169,12 +153,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--addtag\fP \fITag\fP
@@ -182,20 +162,17 @@ Common options for lvm:
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
-
 .HP
 .ad l
 \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP
 .br
 Enable or disable allocation of physical extents on this PV.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -203,7 +180,6 @@ Enable or disable allocation of physical extents on this PV.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -211,7 +187,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -221,7 +196,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -229,7 +203,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--deltag\fP \fITag\fP
@@ -237,7 +210,6 @@ messages sent to the log file and/or syslog (if configured).
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -245,7 +217,6 @@ multiple tags at once. See lvm(8) for information about tags.
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -253,14 +224,12 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreskippedcluster\fP
@@ -268,14 +237,12 @@ Display help text.
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
@@ -285,7 +252,6 @@ If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -293,7 +259,6 @@ If no, lvm will store metadata on the PV.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -301,7 +266,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -313,7 +277,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -327,7 +290,6 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -338,14 +300,12 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-u\fP|\fB--uuid\fP
 .br
 Generate new random UUID for specified PVs.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -353,14 +313,12 @@ Generate new random UUID for specified PVs.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -370,8 +328,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIPV\fP
 .br
@@ -382,19 +338,16 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -409,7 +362,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -484,4 +436,3 @@ disk errors, or because it will be removed after freeing it).
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index a420953..194e41a 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -1,27 +1,15 @@
 .TH PVCK 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 pvck \- Check the consistency of physical volume(s)
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBpvck\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 pvck checks the LVM metadata for consistency on PVs.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBpvck\fP \fIPV\fP ...
 .br
 .RS 4
@@ -33,7 +21,6 @@ pvck checks the LVM metadata for consistency on PVs.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -84,12 +71,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -97,7 +80,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -107,7 +89,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -115,7 +96,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -123,14 +103,12 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--labelsector\fP \fINumber\fP
@@ -140,14 +118,12 @@ sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -155,7 +131,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -163,7 +138,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -174,7 +148,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -182,14 +155,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -199,8 +170,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIPV\fP
 .br
@@ -211,12 +180,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -231,7 +198,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -308,4 +274,3 @@ parameter with a value of 204800 (100 * 1024 * 1024 / 512 = 204800).
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index 0cf7549..deb9cd1 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -1,19 +1,12 @@
 .TH PVCREATE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 pvcreate \- Initialize physical volume(s) for use by LVM
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBpvcreate\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 pvcreate initializes a PV so that it is recognized as belonging to LVM,
 and allows the PV to be used in a VG. A PV can be a disk partition, whole
@@ -36,12 +29,7 @@ to add the PV to existing VG.
 The force option will create a PV without confirmation.  Repeating the
 force option (\fB-ff\fP) will forcibly create a PV, overriding checks that
 normally prevent it, e.g. if the PV is already in a VG.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBpvcreate\fP \fIPV\fP ...
 .br
 .RS 4
@@ -109,7 +97,6 @@ normally prevent it, e.g. if the PV is already in a VG.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -160,12 +147,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
@@ -180,7 +163,6 @@ end up increased due to the alignment, but it's never less than the
 size that is requested. To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -188,7 +170,6 @@ an existing PV use pvs -o +pv_ba_start,pv_ba_size.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -198,7 +179,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
@@ -209,14 +189,12 @@ To see the location of the first Physical Extent of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.
 See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.
 .ad b
-
 .HP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
 Shift the start of the data area by this additional offset.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -224,7 +202,6 @@ Shift the start of the data area by this additional offset.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -232,7 +209,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -240,14 +216,12 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--labelsector\fP \fINumber\fP
@@ -257,14 +231,12 @@ sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
@@ -274,7 +246,6 @@ If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
 .ad b
-
 .HP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
@@ -282,7 +253,6 @@ If no, lvm will store metadata on the PV.
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
 .ad b
-
 .HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
@@ -292,7 +262,6 @@ Specifies the type of on-disk metadata to use.
 \fBlvm1\fP (or just \fB1\fP) is a historical format that
 can be used for accessing old data.
 .ad b
-
 .HP
 .ad l
 \fB--norestorefile\fP
@@ -300,7 +269,6 @@ can be used for accessing old data.
 In conjunction with --uuid, this allows a uuid to be specified
 without also requiring that a backup of the metadata be provided.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -308,7 +276,6 @@ without also requiring that a backup of the metadata be provided.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
@@ -322,7 +289,6 @@ When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -330,7 +296,6 @@ on the ability to use vgsplit later.)
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -342,7 +307,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--restorefile\fP \fIString\fP
@@ -355,7 +319,6 @@ the same place and not be overwritten by new metadata. This provides
 a mechanism to upgrade the metadata format or to add/remove metadata
 areas. Use with care.
 .ad b
-
 .HP
 .ad l
 \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
@@ -363,7 +326,6 @@ areas. Use with care.
 Overrides the automatically detected size of the PV.
 Use with care, or prior to reducing the physical size of the device.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -374,7 +336,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-u\fP|\fB--uuid\fP \fIString\fP
@@ -388,7 +349,6 @@ All PVs must have unique UUIDs, and LVM will prevent certain operations
 if multiple devices are seen with the same UUID.
 See vgimportclone(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -396,14 +356,12 @@ See vgimportclone(8) for more information.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -412,7 +370,6 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
-
 .HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
@@ -422,8 +379,6 @@ The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIPV\fP
 .br
@@ -434,12 +389,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -454,7 +407,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -469,7 +421,6 @@ sectors start at LBA -1, and consequently sector 63 is aligned on a 4KiB
 boundary) manually account for this when initializing for use by LVM.
 .br
 .B pvcreate \-\-dataalignmentoffset 7s /dev/sdb
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -536,4 +487,3 @@ boundary) manually account for this when initializing for use by LVM.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 9e793b9..4e2b85e 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -1,33 +1,21 @@
 .TH PVDISPLAY 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 pvdisplay \- Display various attributes of physical volume(s)
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBpvdisplay\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 pvdisplay shows the attributes of PVs, like size, physical extent size,
 space used for the VG descriptor area, etc.
 
 \fBpvs\fP(8) is a preferred alternative that shows the same information
 and more, using a more compact and configurable output format.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBpvdisplay\fP
 .br
 .RS 4
@@ -130,7 +118,6 @@ and more, using a more compact and configurable output format.
 [ \fIPV\fP|\fITag\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -181,19 +168,14 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--aligned\fP
 .br
 Use with --separator to align the output columns
 .ad b
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
@@ -201,7 +183,6 @@ Use with --separator to align the output columns
 Show information about devices that have not been initialized
 by LVM, i.e. they are not PVs.
 .ad b
-
 .HP
 .ad l
 \fB--binary\fP
@@ -210,7 +191,6 @@ Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
 .ad b
-
 .HP
 .ad l
 \fB-c\fP|\fB--colon\fP
@@ -218,7 +198,6 @@ the "unknown" value which denotes that the value could not be determined).
 Generate colon separated output for easier parsing in scripts or programs.
 Also see vgs(8) which provides considerably more control over the output.
 .ad b
-
 .HP
 .ad l
 \fB-C\fP|\fB--columns\fP
@@ -226,7 +205,6 @@ Also see vgs(8) which provides considerably more control over the output.
 Display output in columns, the equivalent of vgs(8).
 Options listed are the same as options given in vgs(8).
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -234,7 +212,6 @@ Options listed are the same as options given in vgs(8).
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -244,14 +221,12 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -259,7 +234,6 @@ See lvmreport(7).
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -267,7 +241,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB--foreign\fP
@@ -275,14 +248,12 @@ For testing and debugging.
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -290,7 +261,6 @@ Display help text.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreskippedcluster\fP
@@ -298,28 +268,24 @@ operations after locking failures.
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
-
 .HP
 .ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-m\fP|\fB--maps\fP
 .br
 Display the mapping of physical extents to LVs and logical extents.
 .ad b
-
 .HP
 .ad l
 \fB--noheadings\fP
@@ -327,7 +293,6 @@ Display the mapping of physical extents to LVs and logical extents.
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--nosuffix\fP
@@ -335,7 +300,6 @@ Useful if grepping the output.
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
 .ad b
-
 .HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
@@ -346,7 +310,8 @@ The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
 Use \fB-o help\fP to view the list of all available fields.
-The -o option can be repeated, providing several lists.
+Use separate lists of fields to add, remove or compact by repeating the -o option:
+-o+field1,field2 -o-field3,field4 -o#field5.
 These lists are evaluated from left to right.
 Use field name \fBlv_all\fP to view all LV fields,
 \fBvg_all\fP all VG fields,
@@ -357,7 +322,6 @@ Use field name \fBlv_all\fP to view all LV fields,
 See the lvm.conf report section for more config options.
 See lvmreport(7) for more information about reporting.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -365,7 +329,6 @@ See lvmreport(7) for more information about reporting.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -373,7 +336,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--readonly\fP
@@ -388,7 +350,6 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not LVs are
 actually in use.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -400,7 +361,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -414,14 +374,12 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--shared\fP
@@ -430,14 +388,12 @@ Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See lvmlockd(8) for more information about shared VGs.
 .ad b
-
 .HP
 .ad l
 \fB-s\fP|\fB--short\fP
 .br
 Only display the size of the given PVs.
 .ad b
-
 .HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
@@ -445,7 +401,6 @@ Only display the size of the given PVs.
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -456,14 +411,12 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
-
 .HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
@@ -475,7 +428,6 @@ human-(r)eadable with '<' rounding indicator,
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -483,14 +435,12 @@ Custom units can be specified, e.g. --units 3M.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -500,8 +450,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIPV\fP
 .br
@@ -512,18 +460,15 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -538,7 +483,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -607,4 +551,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index b4ce27e..814773d 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -1,21 +1,14 @@
 .TH PVMOVE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 pvmove \- Move extents from one physical volume to another
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBpvmove\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 pvmove moves the allocated physical extents (PEs) on a source PV to one or
 more destination PVs.  You can optionally specify a source LV in which
@@ -32,13 +25,7 @@ after an abort depends on whether the atomic option was used.
 More than one pvmove can run concurrently if they are moving data from
 different source PVs, but additional pvmoves will ignore any LVs already
 in the process of being changed, so some data might not get moved.
-
-
-.P
 .SH USAGE
-.br
-.P
-.
 Move PV extents.
 .br
 .P
@@ -76,7 +63,6 @@ Move PV extents.
 [ \fIPV\fP ... ]
 .RE
 
-
 Continue or abort existing pvmove operations.
 .br
 .P
@@ -87,7 +73,6 @@ Continue or abort existing pvmove operations.
 .RE
 .br
 
-
 Common options for command:
 .
 .RS 4
@@ -102,9 +87,7 @@ Common options for command:
 .ad l
 [    \fB--abort\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -156,12 +139,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--abort\fP
@@ -171,7 +150,6 @@ with the --atomic option, then all LVs will remain on the source PV.
 Otherwise, segments that have been moved will remain on the
 destination PV, while unmoved segments will remain on the source PV.
 .ad b
-
 .HP
 .ad l
 \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
@@ -193,7 +171,6 @@ Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
 .ad b
-
 .HP
 .ad l
 \fB--atomic\fP
@@ -201,7 +178,6 @@ See \fBlvm\fP(8) for more information about allocation.
 Makes a pvmove operation atomic, ensuring that all affected LVs are
 moved to the destination PV, or none are if the operation is aborted.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -209,7 +185,6 @@ moved to the destination PV, or none are if the operation is aborted.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-b\fP|\fB--background\fP
@@ -218,7 +193,6 @@ If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
 background.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -226,7 +200,6 @@ background.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -236,7 +209,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -244,7 +216,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -252,35 +223,30 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
 Report progress at regular intervals.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
 Move only the extents belonging to the named LV.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -290,7 +256,6 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -298,7 +263,6 @@ ignore the devices LVM creates.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -306,7 +270,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -318,7 +281,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -329,7 +291,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -337,14 +298,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -354,8 +313,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIPV\fP
 .br
@@ -366,12 +323,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -386,11 +341,9 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH NOTES
-
 pvmove works as follows:
 
 1. A temporary 'pvmove' LV is created to store details of all the data
@@ -481,7 +434,6 @@ The part of a specific LV present within in a range of physical
 extents can also be picked out and moved.
 .br
 .B pvmove \-n lvol1 /dev/sdb1:1000\-1999 /dev/sdc1
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -548,4 +500,3 @@ extents can also be picked out and moved.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 18873c1..0a9dd4c 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -1,19 +1,12 @@
 .TH PVREMOVE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 pvremove \- Remove LVM label(s) from physical volume(s)
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBpvremove\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 pvremove wipes the label on a device so that LVM will no longer recognise
 it as a PV.
@@ -22,12 +15,7 @@ A PV cannot be removed from a VG while it is used by an active LV.
 
 Repeat the force option (\fB-ff\fP) to forcibly remove a PV belonging to
 an existing VG. Normally, \fBvgreduce\fP(8) should be used instead.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBpvremove\fP \fIPV\fP ...
 .br
 .RS 4
@@ -43,7 +31,6 @@ an existing VG. Normally, \fBvgreduce\fP(8) should be used instead.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -94,12 +81,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -107,7 +90,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -117,7 +99,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -125,7 +106,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -133,7 +113,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -141,21 +120,18 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -163,7 +139,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -171,7 +146,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -183,7 +157,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -194,7 +167,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -202,14 +174,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -219,8 +189,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIPV\fP
 .br
@@ -231,12 +199,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -251,7 +217,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -320,4 +285,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index a57abf3..c5acfe3 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -1,28 +1,16 @@
 .TH PVRESIZE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 pvresize \- Resize physical volume(s)
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBpvresize\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 pvresize resizes a PV. The PV may already be in a VG and may have active
 LVs allocated on it.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBpvresize\fP \fIPV\fP ...
 .br
 .RS 4
@@ -38,7 +26,6 @@ LVs allocated on it.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -89,12 +76,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -102,7 +85,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -112,7 +94,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -120,7 +101,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -128,21 +108,18 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -150,7 +127,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -158,7 +134,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -170,7 +145,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
@@ -178,7 +152,6 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 Overrides the automatically detected size of the PV.
 Use with care, or prior to reducing the physical size of the device.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -189,7 +162,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -197,14 +169,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -214,8 +184,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIPV\fP
 .br
@@ -226,12 +194,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -246,16 +212,12 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH NOTES
-
 pvresize will refuse to shrink a PV if it has allocated extents beyond the
 new end.
-
 .SH EXAMPLES
-
 Expand a PV after enlarging the partition.
 .br
 .B pvresize /dev/sda1
@@ -264,7 +226,6 @@ Shrink a PV prior to shrinking the partition (ensure that the PV size is
 appropriate for the intended new partition size).
 .br
 .B pvresize \-\-setphysicalvolumesize 40G /dev/sda1
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -331,4 +292,3 @@ appropriate for the intended new partition size).
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 5df8c4a..3e8b909 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -1,29 +1,17 @@
 .TH PVS 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 pvs \- Display information about physical volumes
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBpvs\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 pvs produces formatted output about PVs.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBpvs\fP
 .br
 .RS 4
@@ -138,7 +126,6 @@ pvs produces formatted output about PVs.
 [ \fIPV\fP|\fITag\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -189,19 +176,14 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--aligned\fP
 .br
 Use with --separator to align the output columns
 .ad b
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
@@ -209,7 +191,6 @@ Use with --separator to align the output columns
 Show information about devices that have not been initialized
 by LVM, i.e. they are not PVs.
 .ad b
-
 .HP
 .ad l
 \fB--binary\fP
@@ -218,7 +199,6 @@ Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -226,7 +206,6 @@ the "unknown" value which denotes that the value could not be determined).
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -236,14 +215,12 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -251,7 +228,6 @@ See lvmreport(7).
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -259,7 +235,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB--foreign\fP
@@ -267,14 +242,12 @@ For testing and debugging.
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -282,7 +255,6 @@ Display help text.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreskippedcluster\fP
@@ -290,21 +262,18 @@ operations after locking failures.
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
-
 .HP
 .ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--nameprefixes\fP
@@ -313,7 +282,6 @@ Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
 .ad b
-
 .HP
 .ad l
 \fB--noheadings\fP
@@ -321,14 +289,12 @@ be used to set environment variables (for example, in udev rules).
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--nolocking\fP
 .br
 Disable locking.
 .ad b
-
 .HP
 .ad l
 \fB--nosuffix\fP
@@ -336,7 +302,6 @@ Disable locking.
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
 .ad b
-
 .HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
@@ -347,7 +312,8 @@ The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
 Use \fB-o help\fP to view the list of all available fields.
-The -o option can be repeated, providing several lists.
+Use separate lists of fields to add, remove or compact by repeating the -o option:
+-o+field1,field2 -o-field3,field4 -o#field5.
 These lists are evaluated from left to right.
 Use field name \fBlv_all\fP to view all LV fields,
 \fBvg_all\fP all VG fields,
@@ -358,7 +324,6 @@ Use field name \fBlv_all\fP to view all LV fields,
 See the lvm.conf report section for more config options.
 See lvmreport(7) for more information about reporting.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -368,7 +333,6 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -376,7 +340,6 @@ changed with this option.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -384,7 +347,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--readonly\fP
@@ -399,7 +361,6 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not LVs are
 actually in use.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -411,14 +372,12 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--rows\fP
 .br
 Output columns as rows.
 .ad b
-
 .HP
 .ad l
 \fB--segments\fP
@@ -427,7 +386,6 @@ Produces one line of output for each contiguous allocation of space on each
 PV, showing the start (pvseg_start) and length (pvseg_size) in units of
 physical extents.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -441,14 +399,12 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--shared\fP
@@ -457,7 +413,6 @@ Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See lvmlockd(8) for more information about shared VGs.
 .ad b
-
 .HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
@@ -465,7 +420,6 @@ See lvmlockd(8) for more information about shared VGs.
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -476,21 +430,18 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--trustcache\fP
 .br
 Avoids certain device scanning during command processing. Do not use.
 .ad b
-
 .HP
 .ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
-
 .HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
@@ -502,7 +453,6 @@ human-(r)eadable with '<' rounding indicator,
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
 .ad b
-
 .HP
 .ad l
 \fB--unquoted\fP
@@ -510,7 +460,6 @@ Custom units can be specified, e.g. --units 3M.
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -518,14 +467,12 @@ pairs are not quoted.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -535,8 +482,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIPV\fP
 .br
@@ -547,18 +492,15 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -573,7 +515,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH NOTES
@@ -585,8 +526,6 @@ The pv_attr bits are:
 e(x)ported
 .IP 3 3
 (m)issing
-
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -653,4 +592,3 @@ e(x)ported
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index dc64b21..ae2a6a4 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -1,21 +1,14 @@
 .TH PVSCAN 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 pvscan \- List all physical volumes
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBpvscan\fP \fIoption_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 pvscan scans all supported LVM block devices in the system for PVs.
 
@@ -50,15 +43,12 @@ historical reasons.  To avoid disrupting the system with extraneous disk
 scanning, an ordinary pvscan (without \-\-cache) will simply read metadata
 from lvmetad like other LVM commands.  It does not do anything beyond
 displaying the current state of the cache.
-
 .IP \[bu] 2
 When given specific device name arguments, pvscan \-\-cache will only
 read the named devices.
-
 .IP \[bu] 2
 LVM udev rules and systemd services are used to initiate automatic device
 scanning.
-
 .IP \[bu] 2
 To prevent devices from being scanned by pvscan --cache, add them
 to
@@ -69,22 +59,17 @@ apply to system level scanning.
 For more information, see:
 .br
 .B lvmconfig --withcomments devices/global_filter
-
 .IP \[bu] 2
 If lvmetad is started or restarted after devices are visible, or
 if the global_filter has changed, then all devices must be rescanned
 for metadata with the command pvscan \-\-cache.
-
 .IP \[bu] 2
 lvmetad does not cache older metadata formats, e.g. lvm1, and will
 be temporarily disabled if they are seen.
-
 .IP \[bu] 2
 To notify lvmetad about a device that is no longer present, the major and
 minor numbers must be given, not the path.
-
 .P
-
 \fBAutomatic activation\fP
 
 When event-driven system services detect a new LVM device, the first step
@@ -108,26 +93,17 @@ fully integrated with the event-driven system services.)
 
 When a VG or LV is not auto-activated, traditional activation using
 vgchange or lvchange -a|--activate is needed.
-
 .IP \[bu] 2
 pvscan auto-activation can be only done in combination with \-\-cache.
-
 .IP \[bu] 2
 Auto-activation is designated by the "a" argument in '-a|--activate ay'.
 This is meant to distinguish system generated commands from explicit user
 commands, although it can be used in any activation command.  Whenever it
 is used, the auto_activation_volume_list is applied.
-
 .IP \[bu] 2
 Auto-activation is not yet supported for LVs that are part of partial or
 clustered volume groups.
-
-
-.P
 .SH USAGE
-.br
-.P
-.
 Display PV information.
 .br
 .P
@@ -154,7 +130,6 @@ Display PV information.
 .RE
 .br
 
-
 Populate the lvmetad cache by scanning PVs.
 .br
 .P
@@ -184,7 +159,6 @@ Populate the lvmetad cache by scanning PVs.
 [ \fIString\fP|\fIPV\fP ... ]
 .RE
 
-
 Common options for command:
 .
 .RS 4
@@ -195,9 +169,7 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -249,18 +221,13 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
 .ad b
-
 .HP
 .ad l
 \fB-b\fP|\fB--background\fP
@@ -269,14 +236,12 @@ If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
 background.
 .ad b
-
 .HP
 .ad l
 \fB--cache\fP
 .br
 Scan one or more devices and send the metadata to lvmetad.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -284,7 +249,6 @@ Scan one or more devices and send the metadata to lvmetad.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -294,7 +258,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -302,7 +265,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -310,21 +272,18 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-e\fP|\fB--exported\fP
 .br
 Only show PVs belonging to exported VGs.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -332,35 +291,30 @@ Display help text.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
 The major number of a device.
 .ad b
-
 .HP
 .ad l
 \fB--minor\fP \fINumber\fP
 .br
 The minor number of a device.
 .ad b
-
 .HP
 .ad l
 \fB-n\fP|\fB--novolumegroup\fP
 .br
 Only show PVs not belonging to any VG.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -368,7 +322,6 @@ Only show PVs not belonging to any VG.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -376,7 +329,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -388,14 +340,12 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-s\fP|\fB--short\fP
 .br
 Short listing format.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -406,14 +356,12 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-u\fP|\fB--uuid\fP
 .br
 Show UUIDs in addition to device names.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -421,14 +369,12 @@ Show UUIDs in addition to device names.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -438,8 +384,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIPV\fP
 .br
@@ -450,12 +394,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -470,7 +412,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -539,4 +480,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index 8808540..a0a4b07 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -1,21 +1,14 @@
 .TH VGCFGBACKUP 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgcfgbackup \- Backup volume group configuration(s)
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgcfgbackup\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgcfgbackup creates back up files containing metadata of VGs.
 If no VGs are named, back up files are created for all VGs.
@@ -33,12 +26,7 @@ NB. This DOES NOT back up the data content of LVs.
 
 It may also be useful to regularly back up the files in
 \fI/etc/lvm\fP.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgcfgbackup\fP
 .br
 .RS 4
@@ -73,7 +61,6 @@ It may also be useful to regularly back up the files in
 [ \fIVG\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -124,12 +111,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -137,7 +120,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -147,7 +129,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -155,7 +136,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -163,7 +143,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
@@ -172,7 +151,6 @@ Write the backup to the named file.
 When backing up more than one VG, the file name is
 treated as a template, and %s is replaced by the VG name.
 .ad b
-
 .HP
 .ad l
 \fB--foreign\fP
@@ -180,14 +158,12 @@ treated as a template, and %s is replaced by the VG name.
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -195,14 +171,12 @@ Display help text.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -212,7 +186,6 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -220,7 +193,6 @@ changed with this option.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -228,7 +200,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--readonly\fP
@@ -243,7 +214,6 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not LVs are
 actually in use.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -255,7 +225,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -266,7 +235,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -274,14 +242,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -291,18 +257,14 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -317,7 +279,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -386,4 +347,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index 36da543..74b6e05 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -1,13 +1,8 @@
 .TH VGCFGRESTORE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgcfgrestore \- Restore volume group configuration
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgcfgrestore\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -15,8 +10,6 @@ vgcfgrestore \- Restore volume group configuration
     [ \fIposition_args\fP ]
 .br
 .P
-
-.P
 .ad l
     \fB--commandprofile\fP \fIString\fP
 .ad b
@@ -80,9 +73,6 @@ vgcfgrestore \- Restore volume group configuration
 .ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
-
-.P
-
 .SH DESCRIPTION
 vgcfgrestore restores the metadata of a VG from a text back up file
 produced by \fBvgcfgbackup\fP. This writes VG metadata onto the devices
@@ -95,12 +85,7 @@ the available back up and archive files of a VG.
 WARNING: When a VG contains thin pools, changes to thin metadata cannot be
 reverted, and data loss may occur if thin metadata has changed. The force
 option is required to restore in this case.
-
-.P
 .SH USAGE
-.br
-.P
-.
 Restore VG metadata from last backup.
 .br
 .P
@@ -110,10 +95,7 @@ Restore VG metadata from last backup.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Restore VG metadata from specified file.
 .br
@@ -124,10 +106,7 @@ Restore VG metadata from specified file.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 List all VG metadata backups.
 .br
@@ -138,10 +117,7 @@ List all VG metadata backups.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 List one VG metadata backup file.
 .br
@@ -155,10 +131,7 @@ List one VG metadata backup file.
 .RS 4
 [ \fIVG\fP ]
 .RE
-
---
-
-.br
+-
 
 Common options for command:
 .
@@ -170,9 +143,7 @@ Common options for command:
 .ad l
 [    \fB--force\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -224,12 +195,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -237,7 +204,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -247,7 +213,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -255,7 +220,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -263,7 +227,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
@@ -271,7 +234,6 @@ For testing and debugging.
 Read metadata backup from the named file.
 Usually this file was created by vgcfgbackup.
 .ad b
-
 .HP
 .ad l
 \fB--force\fP ...
@@ -282,14 +244,12 @@ cannot be reverted.
 You may lose data if you restore metadata that does not match the
 thin pool kernel metadata precisely.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--list\fP
@@ -297,14 +257,12 @@ Display help text.
 List metadata backup and archive files pertaining to the VG.
 May be used with --file. Does not restore the VG.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
@@ -314,7 +272,6 @@ Specifies the type of on-disk metadata to use.
 \fBlvm1\fP (or just \fB1\fP) is a historical format that
 can be used for accessing old data.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -322,7 +279,6 @@ can be used for accessing old data.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -330,7 +286,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -341,7 +296,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -349,14 +303,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -366,18 +318,14 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -392,7 +340,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH NOTES
@@ -470,4 +417,3 @@ missing PV. Repeat for all other missing PVs in the VG.  Then use
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 1494f4e..9e4b818 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -1,13 +1,8 @@
 .TH VGCHANGE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgchange \- Change volume group attributes
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgchange\fP \fIoption_args\fP
 .br
     [ \fIoption_args\fP ]
@@ -15,8 +10,6 @@ vgchange \- Change volume group attributes
     [ \fIposition_args\fP ]
 .br
 .P
-
-.P
 .ad l
  \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .ad b
@@ -200,18 +193,10 @@ vgchange \- Change volume group attributes
 .ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
-
-.P
-
 .SH DESCRIPTION
 vgchange changes VG attributes, changes LV activation in the kernel, and
 includes other utilities for VG maintenance.
-
-.P
 .SH USAGE
-.br
-.P
-.
 Change a general VG attribute. 
 .br
 For options listed in parentheses, any one is 
@@ -291,10 +276,7 @@ required, after which the others are optional.
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Start or stop monitoring LVs from dmeventd.
 .br
@@ -320,10 +302,7 @@ Start or stop monitoring LVs from dmeventd.
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Start or stop processing LV conversions.
 .br
@@ -341,10 +320,7 @@ Start or stop processing LV conversions.
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Activate or deactivate LVs.
 .br
@@ -386,10 +362,7 @@ Activate or deactivate LVs.
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Reactivate LVs using the latest metadata.
 .br
@@ -419,10 +392,7 @@ Reactivate LVs using the latest metadata.
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Start the lockspace of a shared VG in lvmlockd.
 .br
@@ -440,10 +410,7 @@ Start the lockspace of a shared VG in lvmlockd.
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Stop the lockspace of a shared VG in lvmlockd.
 .br
@@ -461,10 +428,7 @@ Stop the lockspace of a shared VG in lvmlockd.
 .RS 4
 [ \fIVG\fP|\fITag\fP|\fISelect\fP ... ]
 .RE
-
---
-
-.br
+-
 
 Common options for command:
 .
@@ -496,9 +460,7 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -550,12 +512,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
@@ -581,7 +539,6 @@ to select which LVs should be automatically activated by the system.
 See lvmlockd(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
 See clvmd(8) for more information about activation options \fBey\fP, \fBsy\fP, \fBly\fP and \fBln\fP for clustered VGs.
 .ad b
-
 .HP
 .ad l
 \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
@@ -597,7 +554,6 @@ should only be used for recovery or repair.
 For default, see lvm.conf/activation_mode.
 See \fBlvmraid\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--addtag\fP \fITag\fP
@@ -605,7 +561,6 @@ See \fBlvmraid\fP(7) for more information.
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
-
 .HP
 .ad l
 \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
@@ -627,7 +582,6 @@ Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -635,7 +589,6 @@ See \fBlvm\fP(8) for more information about allocation.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
@@ -643,7 +596,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 Change the clustered property of a VG using clvmd.
 See clvmd(8) for more information about clustered VGs.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -651,7 +603,6 @@ See clvmd(8) for more information about clustered VGs.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -661,7 +612,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -669,7 +619,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--deltag\fP \fITag\fP
@@ -677,7 +626,6 @@ messages sent to the log file and/or syslog (if configured).
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
-
 .HP
 .ad l
 \fB--detachprofile\fP
@@ -685,7 +633,6 @@ multiple tags at once. See lvm(8) for information about tags.
 Detaches a metadata profile from a VG or LV.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -693,7 +640,6 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -701,14 +647,12 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
@@ -716,7 +660,6 @@ Display help text.
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -724,7 +667,6 @@ to allow LVs with the flag set to be activated.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--ignoremonitoring\fP
@@ -732,7 +674,6 @@ operations after locking failures.
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreskippedcluster\fP
@@ -740,7 +681,6 @@ Do not use this if dmeventd is already monitoring a device.
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
-
 .HP
 .ad l
 \fB--lockopt\fP \fIString\fP
@@ -748,7 +688,6 @@ without clustered locking and clustered VGs are skipped.
 Used to pass options for special cases to lvmlockd.
 See lvmlockd(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--lockstart\fP
@@ -757,7 +696,6 @@ Start the lockspace of a shared VG in lvmlockd.
 lvmlockd locks becomes available for the VG, allowing LVM to use the VG.
 See lvmlockd(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--lockstop\fP
@@ -766,7 +704,6 @@ Stop the lockspace of a shared VG in lvmlockd.
 lvmlockd locks become unavailable for the VG, preventing LVM from using the VG.
 See lvmlockd(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
@@ -774,21 +711,18 @@ See lvmlockd(8) for more information.
 Change the VG lock type to or from a shared lock type used with lvmlockd.
 See lvmlockd(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--logicalvolume\fP \fINumber\fP
 .br
 Sets the maximum number of LVs allowed in a VG.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
@@ -798,7 +732,6 @@ The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
 .ad b
-
 .HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
@@ -806,7 +739,6 @@ and --vgmetadatacopies for improving performance.
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
@@ -816,7 +748,6 @@ dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See dmeventd(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -826,7 +757,6 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -836,7 +766,6 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
@@ -851,7 +780,6 @@ Before increasing the physical extent size, you might need to use lvresize,
 pvresize and/or pvmove so that everything fits. For example, every
 contiguous range of extents used in a LV must start and end on an extent boundary.
 .ad b
-
 .HP
 .ad l
 \fB--poll\fP \fBy\fP|\fBn\fP
@@ -864,7 +792,6 @@ transformation will not complete. It may not be appropriate to immediately
 poll an LV after activation, in which case --poll n can be used to defer
 polling until a later --poll y command.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -872,7 +799,6 @@ polling until a later --poll y command.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
@@ -886,7 +812,6 @@ When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -894,7 +819,6 @@ on the ability to use vgsplit later.)
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--refresh\fP
@@ -904,7 +828,6 @@ This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -916,7 +839,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP
@@ -924,7 +846,6 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 Enables or disables the addition or removal of PVs to/from a VG
 (by vgextend/vgreduce).
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -938,7 +859,6 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB--sysinit\fP
@@ -952,7 +872,6 @@ this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
 When used in conjunction with lvmetad enabled and running,
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
 .ad b
-
 .HP
 .ad l
 \fB--systemid\fP \fIString\fP
@@ -962,7 +881,6 @@ because the VG may become foreign to the host running the command,
 leaving the host unable to access it.
 See lvmsystemid(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -973,14 +891,12 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-u\fP|\fB--uuid\fP
 .br
 Generate new random UUID for specified VGs.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -988,14 +904,12 @@ Generate new random UUID for specified VGs.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
@@ -1014,7 +928,6 @@ metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -1024,31 +937,25 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -1063,17 +970,13 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH NOTES
-
 If vgchange recognizes COW snapshot LVs that were dropped because they ran
 out of space, it displays a message informing the administrator that the
 snapshots should be removed.
-
 .SH EXAMPLES
-
 Activate all LVs in all VGs on all existing devices.
 .br
 .B vgchange \-a y
@@ -1081,7 +984,6 @@ Activate all LVs in all VGs on all existing devices.
 Change the maximum number of LVs for an inactive VG.
 .br
 .B vgchange \-l 128 vg00
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -1148,4 +1050,3 @@ Change the maximum number of LVs for an inactive VG.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index fa01362..01adbfc 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -1,29 +1,17 @@
 .TH VGCK 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgck \- Check the consistency of volume group(s)
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgck\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgck checks LVM metadata for consistency.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgck\fP
 .br
 .RS 4
@@ -38,7 +26,6 @@ vgck checks LVM metadata for consistency.
 [ \fIVG\fP|\fITag\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -89,12 +76,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -102,7 +85,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -112,7 +94,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -120,7 +101,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -128,21 +108,18 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -150,7 +127,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -158,7 +134,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -170,7 +145,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -181,7 +155,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -189,14 +162,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -206,24 +177,19 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -238,7 +204,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -307,4 +272,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 4f89b9e..795b436 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -1,19 +1,12 @@
 .TH VGCONVERT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgconvert \- Change volume group metadata format
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgconvert\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgconvert converts VG metadata from one format to another.  The new
 metadata format must be able to fit into the space provided by the old
@@ -21,13 +14,7 @@ format.
 
 Because the LVM1 format should no longer be used, this command is no
 longer needed in general.
-
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgconvert\fP \fIVG\fP ...
 .br
 .RS 4
@@ -63,7 +50,6 @@ longer needed in general.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -114,12 +100,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
@@ -134,7 +116,6 @@ end up increased due to the alignment, but it's never less than the
 size that is requested. To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -142,7 +123,6 @@ an existing PV use pvs -o +pv_ba_start,pv_ba_size.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -152,7 +132,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -160,7 +139,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -168,7 +146,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -176,14 +153,12 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--labelsector\fP \fINumber\fP
@@ -193,14 +168,12 @@ sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
@@ -208,7 +181,6 @@ Display long help text.
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
 .ad b
-
 .HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
@@ -218,7 +190,6 @@ Specifies the type of on-disk metadata to use.
 \fBlvm1\fP (or just \fB1\fP) is a historical format that
 can be used for accessing old data.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -226,7 +197,6 @@ can be used for accessing old data.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
@@ -240,7 +210,6 @@ When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -248,7 +217,6 @@ on the ability to use vgsplit later.)
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -260,7 +228,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -271,7 +238,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -279,14 +245,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -296,18 +260,14 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -322,7 +282,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -391,4 +350,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 5c73312..8279e33 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -1,30 +1,18 @@
 .TH VGCREATE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgcreate \- Create a volume group
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgcreate\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgcreate creates a new VG on block devices. If the devices were not
 previously intialized as PVs with \fBpvcreate\fP(8), vgcreate will
 inititialize them, making them PVs. The pvcreate options for initializing
 devices are also available with vgcreate.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgcreate\fP \fIVG\fP\fI_new\fP \fIPV\fP ...
 .br
 .RS 4
@@ -120,7 +108,6 @@ devices are also available with vgcreate.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -171,12 +158,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--addtag\fP \fITag\fP
@@ -184,7 +167,6 @@ Common options for lvm:
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See lvm(8) for information about tags.
 .ad b
-
 .HP
 .ad l
 \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
@@ -206,7 +188,6 @@ Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -214,7 +195,6 @@ See \fBlvm\fP(8) for more information about allocation.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
@@ -225,7 +205,6 @@ clvmd and a lock manager must be configured and running.
 (A clustered VG using clvmd is different from a shared VG using lvmlockd.)
 See clvmd(8) for more information about clustered VGs.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -233,7 +212,6 @@ See clvmd(8) for more information about clustered VGs.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -243,7 +221,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
@@ -254,14 +231,12 @@ To see the location of the first Physical Extent of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.
 See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.
 .ad b
-
 .HP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
 Shift the start of the data area by this additional offset.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -269,7 +244,6 @@ Shift the start of the data area by this additional offset.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -277,7 +251,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -285,14 +258,12 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--labelsector\fP \fINumber\fP
@@ -302,7 +273,6 @@ sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
 .ad b
-
 .HP
 .ad l
 \fB--lockopt\fP \fIString\fP
@@ -310,7 +280,6 @@ in the source). Use with care.
 Used to pass options for special cases to lvmlockd.
 See lvmlockd(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
@@ -318,21 +287,18 @@ See lvmlockd(8) for more information.
 Specify the VG lock type directly in place of using --shared.
 See lvmlockd(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP
 .br
 Sets the maximum number of LVs allowed in a VG.
 .ad b
-
 .HP
 .ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
@@ -342,7 +308,6 @@ The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
 .ad b
-
 .HP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
@@ -350,7 +315,6 @@ and --vgmetadatacopies for improving performance.
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
@@ -358,7 +322,6 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
 .ad b
-
 .HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
@@ -368,7 +331,6 @@ Specifies the type of on-disk metadata to use.
 \fBlvm1\fP (or just \fB1\fP) is a historical format that
 can be used for accessing old data.
 .ad b
-
 .HP
 .ad l
 \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
@@ -380,7 +342,6 @@ currently used in the VG), or at least 128KiB.
 Once this value has been set, it is difficult to change
 without recreating the VG, unless no extents need moving.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -388,7 +349,6 @@ without recreating the VG, unless no extents need moving.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
@@ -402,7 +362,6 @@ When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -410,7 +369,6 @@ on the ability to use vgsplit later.)
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -422,7 +380,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--shared\fP
@@ -434,7 +391,6 @@ devices. lvmlockd and a lock manager must be configured and running.
 (A shared VG using lvmlockd is different from a clustered VG using clvmd.)
 See lvmlockd(8) for more information about shared VGs.
 .ad b
-
 .HP
 .ad l
 \fB--systemid\fP \fIString\fP
@@ -447,7 +403,6 @@ system ID of the new VG may not match the system ID of the host running
 the command, leaving the VG inaccessible to the host.
 See lvmsystemid(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -458,7 +413,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -466,14 +420,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
@@ -492,7 +444,6 @@ metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -501,7 +452,6 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
-
 .HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
@@ -511,13 +461,10 @@ The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fIPV\fP
 .br
@@ -528,12 +475,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -548,7 +493,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -556,7 +500,6 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 Create a VG with two PVs, using the default physical extent size.
 .br
 .B vgcreate myvg /dev/sdk1 /dev/sdl1
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -623,4 +566,3 @@ Create a VG with two PVs, using the default physical extent size.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 352a521..cddac7a 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -1,32 +1,20 @@
 .TH VGDISPLAY 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgdisplay \- Display volume group information
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgdisplay\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgdisplay shows the attributes of VGs, and the associated PVs and LVs.
 
 \fBvgs\fP(8) is a preferred alternative that shows the same information
 and more, using a more compact and configurable output format.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgdisplay\fP
 .br
 .RS 4
@@ -129,7 +117,6 @@ and more, using a more compact and configurable output format.
 [ \fIVG\fP|\fITag\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -180,12 +167,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-A\fP|\fB--activevolumegroups\fP
@@ -193,14 +176,12 @@ Common options for lvm:
 Only select active VGs. The VG is considered active
 if@least one of its LVs is active.
 .ad b
-
 .HP
 .ad l
 \fB--aligned\fP
 .br
 Use with --separator to align the output columns
 .ad b
-
 .HP
 .ad l
 \fB--binary\fP
@@ -209,7 +190,6 @@ Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
 .ad b
-
 .HP
 .ad l
 \fB-c\fP|\fB--colon\fP
@@ -217,7 +197,6 @@ the "unknown" value which denotes that the value could not be determined).
 Generate colon separated output for easier parsing in scripts or programs.
 Also see vgs(8) which provides considerably more control over the output.
 .ad b
-
 .HP
 .ad l
 \fB-C\fP|\fB--columns\fP
@@ -225,7 +204,6 @@ Also see vgs(8) which provides considerably more control over the output.
 Display output in columns, the equivalent of vgs(8).
 Options listed are the same as options given in vgs(8).
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -233,7 +211,6 @@ Options listed are the same as options given in vgs(8).
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -243,14 +220,12 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -258,7 +233,6 @@ See lvmreport(7).
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -266,7 +240,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB--foreign\fP
@@ -274,14 +247,12 @@ For testing and debugging.
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -289,7 +260,6 @@ Display help text.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreskippedcluster\fP
@@ -297,21 +267,18 @@ operations after locking failures.
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
-
 .HP
 .ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--noheadings\fP
@@ -319,7 +286,6 @@ Display long help text.
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--nosuffix\fP
@@ -327,7 +293,6 @@ Useful if grepping the output.
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
 .ad b
-
 .HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
@@ -338,7 +303,8 @@ The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
 Use \fB-o help\fP to view the list of all available fields.
-The -o option can be repeated, providing several lists.
+Use separate lists of fields to add, remove or compact by repeating the -o option:
+-o+field1,field2 -o-field3,field4 -o#field5.
 These lists are evaluated from left to right.
 Use field name \fBlv_all\fP to view all LV fields,
 \fBvg_all\fP all VG fields,
@@ -349,7 +315,6 @@ Use field name \fBlv_all\fP to view all LV fields,
 See the lvm.conf report section for more config options.
 See lvmreport(7) for more information about reporting.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -359,7 +324,6 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -367,7 +331,6 @@ changed with this option.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -375,7 +338,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--readonly\fP
@@ -390,7 +352,6 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not LVs are
 actually in use.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -402,7 +363,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -416,14 +376,12 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--shared\fP
@@ -432,14 +390,12 @@ Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See lvmlockd(8) for more information about shared VGs.
 .ad b
-
 .HP
 .ad l
 \fB-s\fP|\fB--short\fP
 .br
 Give a short listing showing the existence of VGs.
 .ad b
-
 .HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
@@ -447,7 +403,6 @@ Give a short listing showing the existence of VGs.
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -458,14 +413,12 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
-
 .HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
@@ -477,7 +430,6 @@ human-(r)eadable with '<' rounding indicator,
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -485,14 +437,12 @@ Custom units can be specified, e.g. --units 3M.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -502,24 +452,19 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -534,7 +479,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -603,4 +547,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index 0551c26..6138c0f 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -1,19 +1,12 @@
 .TH VGEXPORT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgexport \- Unregister volume group(s) from the system
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgexport\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgexport makes inactive VGs unknown to the system. In this state, all the
 PVs in the VG can be moved to a different system, from which
@@ -23,12 +16,7 @@ Most LVM tools ignore exported VGs.
 
 vgexport clears the VG system ID, and vgimport sets the VG system ID to
 match the host running vgimport (if the host has a system ID).
-
-.P
 .SH USAGE
-.br
-.P
-.
 Export specified VGs.
 .br
 .P
@@ -43,7 +31,6 @@ Export specified VGs.
 .RE
 .br
 
-
 Export all VGs.
 .br
 .P
@@ -54,16 +41,13 @@ Export all VGs.
 .RE
 .br
 
-
 Common options for command:
 .
 .RS 4
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -115,18 +99,13 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -134,7 +113,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -144,7 +122,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -152,7 +129,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -160,21 +136,18 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -182,7 +155,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -190,7 +162,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -202,7 +173,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -216,7 +186,6 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -227,7 +196,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -235,14 +203,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -252,31 +218,25 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -291,7 +251,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -360,4 +319,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index 42ef268..6d8d6f8 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -1,19 +1,12 @@
 .TH VGEXTEND 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgextend \- Add physical volumes to a volume group
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgextend\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgextend adds one or more PVs to a VG. This increases the space available
 for LVs in the VG.
@@ -26,12 +19,7 @@ If the specified PVs have not yet been initialized with pvcreate, vgextend
 will initialize them. In this case pvcreate options can be used, e.g.
 \-\-labelsector, \-\-metadatasize, \-\-metadataignore,
 \-\-pvmetadatacopies, \-\-dataalignment, \-\-dataalignmentoffset.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgextend\fP \fIVG\fP \fIPV\fP ...
 .br
 .RS 4
@@ -87,7 +75,6 @@ will initialize them. In this case pvcreate options can be used, e.g.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -138,12 +125,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -151,7 +134,6 @@ Common options for lvm:
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -159,7 +141,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -169,7 +150,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
@@ -180,14 +160,12 @@ To see the location of the first Physical Extent of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.
 See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.
 .ad b
-
 .HP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
 Shift the start of the data area by this additional offset.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -195,7 +173,6 @@ Shift the start of the data area by this additional offset.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -203,7 +180,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -211,14 +187,12 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--labelsector\fP \fINumber\fP
@@ -228,14 +202,12 @@ sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
@@ -245,7 +217,6 @@ If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
 .ad b
-
 .HP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
@@ -253,7 +224,6 @@ If no, lvm will store metadata on the PV.
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
 .ad b
-
 .HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
@@ -263,7 +233,6 @@ Specifies the type of on-disk metadata to use.
 \fBlvm1\fP (or just \fB1\fP) is a historical format that
 can be used for accessing old data.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -271,7 +240,6 @@ can be used for accessing old data.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
@@ -285,7 +253,6 @@ When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -293,7 +260,6 @@ on the ability to use vgsplit later.)
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -305,7 +271,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--restoremissing\fP
@@ -313,7 +278,6 @@ output in JSON format. See \fBlvmreport\fP(7) for more information.
 Add a PV back into a VG after the PV was missing and then returned,
 e.g. due to a transient failure. The PV is not reinitialized.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -324,7 +288,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -332,14 +295,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -348,7 +309,6 @@ Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
-
 .HP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
@@ -358,13 +318,10 @@ The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fIPV\fP
 .br
@@ -375,12 +332,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -395,7 +350,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -403,7 +357,6 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 Add two PVs to a VG.
 .br
 .B vgextend vg00 /dev/sda4 /dev/sdn1
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -470,4 +423,3 @@ Add two PVs to a VG.
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index e71436f..c31d9f4 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -1,31 +1,19 @@
 .TH VGIMPORT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgimport \- Register exported volume group with system
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgimport\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgimport makes exported VGs known to the system again, perhaps after
 moving the PVs from a different system.
 
 vgexport clears the VG system ID, and vgimport sets the VG system ID to
 match the host running vgimport (if the host has a system ID).
-
-.P
 .SH USAGE
-.br
-.P
-.
 Import specified VGs.
 .br
 .P
@@ -40,7 +28,6 @@ Import specified VGs.
 .RE
 .br
 
-
 Import all VGs.
 .br
 .P
@@ -51,7 +38,6 @@ Import all VGs.
 .RE
 .br
 
-
 Common options for command:
 .
 .RS 4
@@ -62,9 +48,7 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -116,18 +100,13 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -135,7 +114,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -145,7 +123,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -153,7 +130,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -161,7 +137,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -169,21 +144,18 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -191,7 +163,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -199,7 +170,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -211,7 +181,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -225,7 +194,6 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -236,7 +204,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -244,14 +211,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -261,31 +226,25 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -300,7 +259,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -369,4 +327,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index 280e2a8..f68a384 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -1,19 +1,12 @@
 .TH VGIMPORTCLONE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgimportclone \- Import a VG from cloned PVs
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgimportclone\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgimportclone imports a VG from duplicated PVs, e.g. created by a hardware
 snapshot of existing PVs.
@@ -21,12 +14,7 @@ snapshot of existing PVs.
 A duplicated VG cannot used until it is made to coexist with the original
 VG. vgimportclone renames the VG associated with the specified PVs and
 changes the associated VG and PV UUIDs.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgimportclone\fP \fIPV\fP ...
 .br
 .RS 4
@@ -42,7 +30,6 @@ changes the associated VG and PV UUIDs.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -93,12 +80,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-n\fP|\fB--basevgname\fP \fIString\fP
@@ -109,7 +92,6 @@ to 'test_vg1'). This option will override the base VG name that is
 used for all VG renames. If a VG already exists with the specified name
 a numeric suffix will be added (like the previous example) to make it unique.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -117,7 +99,6 @@ a numeric suffix will be added (like the previous example) to make it unique.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -127,7 +108,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -135,7 +115,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -143,14 +122,12 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-i\fP|\fB--import\fP
@@ -158,14 +135,12 @@ Display help text.
 Import exported VGs. Otherwise VGs that have been exported
 will not be changed (nor will their associated PVs).
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -173,7 +148,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -181,7 +155,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -192,7 +165,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -200,14 +172,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -217,8 +187,6 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIPV\fP
 .br
@@ -229,12 +197,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -249,7 +215,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -260,7 +225,6 @@ Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_sna
 (and change associated UUIDs).
 .br
 .B vgimportclone \-\-basevgname vg00_snap /dev/sdc /dev/sdd
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -327,4 +291,3 @@ Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_sna
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index ffa9929..52c7f56 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -1,29 +1,17 @@
 .TH VGMERGE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgmerge \- Merge volume groups
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgmerge\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgmerge merges two existing VGs. The inactive source VG is merged into the
 destination VG if physical extent sizes are equal and PV and LV summaries
 of both VGs fit into the destination VG's limits.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgmerge\fP \fIVG\fP \fIVG\fP
 .br
 .RS 4
@@ -39,7 +27,6 @@ of both VGs fit into the destination VG's limits.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -90,12 +77,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -103,7 +86,6 @@ Common options for lvm:
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -111,7 +93,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -121,7 +102,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -129,7 +109,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -137,28 +116,24 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--list\fP
 .br
 Display merged destination VG like vgdisplay -v.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -166,7 +141,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -174,7 +148,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -185,7 +158,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -193,14 +165,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -210,18 +180,14 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -236,7 +202,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -245,7 +210,6 @@ Merge an inactive VG named "vg00" into the active or inactive VG named
 "databases", giving verbose runtime information.
 .br
 .B vgmerge \-v databases vg00
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -312,4 +276,3 @@ Merge an inactive VG named "vg00" into the active or inactive VG named
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 6f785b2..501d6e1 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -1,33 +1,21 @@
 .TH VGMKNODES 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgmknodes \- Create the special files for volume group devices in /dev
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgmknodes\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgmknodes checks the LVM device nodes in /dev that are needed for active
 LVs and creates any that are missing and removes unused ones.
 
 This command should not usually be needed if all the system components are
 interoperating correctly.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgmknodes\fP
 .br
 .RS 4
@@ -50,7 +38,6 @@ interoperating correctly.
 [ \fIVG\fP|\fILV\fP|\fITag\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -101,12 +88,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -114,7 +97,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -124,7 +106,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -132,7 +113,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -140,14 +120,12 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -155,14 +133,12 @@ Display help text.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -170,7 +146,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -178,7 +153,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--refresh\fP
@@ -188,7 +162,6 @@ This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -200,7 +173,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -211,7 +183,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -219,14 +190,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -236,30 +205,24 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -274,7 +237,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -343,4 +305,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index 548188b..e4f1575 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -1,20 +1,13 @@
 .TH VGREDUCE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgreduce \- Remove physical volume(s) from a volume group
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgreduce\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
 .P
-
-.P
 .ad l
  \fB-a\fP|\fB--all\fP
 .ad b
@@ -86,17 +79,9 @@ vgreduce \- Remove physical volume(s) from a volume group
 .ad l
  \fB-y\fP|\fB--yes\fP
 .ad b
-
-.P
-
 .SH DESCRIPTION
 vgreduce removes one or more unused PVs from a VG.
-
-.P
 .SH USAGE
-.br
-.P
-.
 Remove a PV from a VG.
 .br
 .P
@@ -106,10 +91,7 @@ Remove a PV from a VG.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Remove all unused PVs from a VG.
 .br
@@ -120,10 +102,7 @@ Remove all unused PVs from a VG.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Remove all missing PVs from a VG.
 .br
@@ -138,10 +117,7 @@ Remove all missing PVs from a VG.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
---
-
-.br
+-
 
 Common options for command:
 .
@@ -157,9 +133,7 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -211,19 +185,14 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 Removes all empty PVs if none are named on the command line.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -231,7 +200,6 @@ Removes all empty PVs if none are named on the command line.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -239,7 +207,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -249,7 +216,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -257,7 +223,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -265,7 +230,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -273,28 +237,24 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--mirrorsonly\fP
 .br
 Only remove missing PVs from mirror LVs.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -302,7 +262,6 @@ Only remove missing PVs from mirror LVs.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -310,7 +269,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--removemissing\fP
@@ -326,7 +284,6 @@ those parts on disks that are still present.
 If LVs spanned several disks, including ones that are lost, salvaging
 some data first may be possible by activating LVs in partial mode.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -338,7 +295,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -349,7 +305,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -357,14 +312,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -374,13 +327,10 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fIPV\fP
 .br
@@ -391,12 +341,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -411,7 +359,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -480,4 +427,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index ab1aa90..e9b2db9 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -1,19 +1,12 @@
 .TH VGREMOVE 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgremove \- Remove volume group(s)
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgremove\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgremove removes one or more VGs. If LVs exist in the VG, a prompt is used
 to confirm LV removal.
@@ -24,12 +17,7 @@ metadata consistent again.
 
 Repeat the force option (\fB-ff\fP) to forcibly remove LVs in the VG
 without confirmation.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgremove\fP \fIVG\fP|\fITag\fP|\fISelect\fP ...
 .br
 .RS 4
@@ -53,7 +41,6 @@ without confirmation.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -104,12 +91,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -117,7 +100,6 @@ Common options for lvm:
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -127,7 +109,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -135,7 +116,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -143,7 +123,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -151,21 +130,18 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--noudevsync\fP
@@ -175,7 +151,6 @@ from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -183,7 +158,6 @@ ignore the devices LVM creates.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -191,7 +165,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -203,7 +176,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -217,7 +189,6 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -228,7 +199,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -236,14 +206,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -253,31 +221,25 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -292,7 +254,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -361,4 +322,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index a9055d0..1e35c4f 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -1,19 +1,12 @@
 .TH VGRENAME 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgrename \- Rename a volume group
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgrename\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgrename renames a VG.
 
@@ -24,12 +17,7 @@ changed. If a newly connected disk has a VG with the same name as the VG
 containing the root filesystem, the machine may not boot correctly. When
 two VGs have the same name, the VG UUID can be used in place of the source
 VG name.
-
-.P
 .SH USAGE
-.br
-.P
-.
 Rename a VG.
 .br
 .P
@@ -40,7 +28,6 @@ Rename a VG.
 .RE
 .br
 
-
 Rename a VG by specifying the VG UUID.
 .br
 .P
@@ -51,7 +38,6 @@ Rename a VG by specifying the VG UUID.
 .RE
 .br
 
-
 Common options for command:
 .
 .RS 4
@@ -66,9 +52,7 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -120,12 +104,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -133,7 +113,6 @@ Common options for lvm:
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -141,7 +120,6 @@ Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -151,7 +129,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -159,7 +136,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -167,7 +143,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-f\fP|\fB--force\fP ...
@@ -175,21 +150,18 @@ For testing and debugging.
 Override various checks, confirmations and protections.
 Use with extreme caution.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -197,7 +169,6 @@ Display long help text.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -205,7 +176,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -217,7 +187,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -228,7 +197,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -236,14 +204,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -253,18 +219,14 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -279,7 +241,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH EXAMPLES
@@ -291,7 +252,6 @@ Rename VG "vg02" to "myvg":
 Rename the VG with the specified UUID to "myvg".
 .br
 .B vgrename Zvlifi\-Ep3t\-e0Ng\-U42h\-o0ye\-KHu1\-nl7Ns4 myvg
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -358,4 +318,3 @@ Rename the VG with the specified UUID to "myvg".
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index c00460b..aa6e2f9 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -1,29 +1,17 @@
 .TH VGS 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgs \- Display information about volume groups
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgs\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgs produces formatted output about VGs.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgs\fP
 .br
 .RS 4
@@ -134,7 +122,6 @@ vgs produces formatted output about VGs.
 [ \fIVG\fP|\fITag\fP ... ]
 .RE
 
-
 Common options for lvm:
 .
 .RS 4
@@ -185,26 +172,20 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--aligned\fP
 .br
 Use with --separator to align the output columns
 .ad b
-
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 List all VGs. Equivalent to not specifying any VGs.
 .ad b
-
 .HP
 .ad l
 \fB--binary\fP
@@ -213,7 +194,6 @@ Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -221,7 +201,6 @@ the "unknown" value which denotes that the value could not be determined).
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -231,14 +210,12 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
 See lvmreport(7).
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -246,7 +223,6 @@ See lvmreport(7).
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -254,7 +230,6 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB--foreign\fP
@@ -262,14 +237,12 @@ For testing and debugging.
 Report/display foreign VGs that would otherwise be skipped.
 See lvmsystemid(7) for more information about foreign VGs.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -277,7 +250,6 @@ Display help text.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--ignoreskippedcluster\fP
@@ -285,21 +257,18 @@ operations after locking failures.
 Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and clustered VGs are skipped.
 .ad b
-
 .HP
 .ad l
 \fB--logonly\fP
 .br
 Suppress command report and display only log report.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--nameprefixes\fP
@@ -308,7 +277,6 @@ Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
 .ad b
-
 .HP
 .ad l
 \fB--noheadings\fP
@@ -316,14 +284,12 @@ be used to set environment variables (for example, in udev rules).
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--nolocking\fP
 .br
 Disable locking.
 .ad b
-
 .HP
 .ad l
 \fB--nosuffix\fP
@@ -331,7 +297,6 @@ Disable locking.
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
 .ad b
-
 .HP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
@@ -342,7 +307,8 @@ The prefix \fB+\fP will append the specified fields to the default fields,
 \fB-\fP will remove the specified fields from the default fields, and
 \fB#\fP will compact specified fields (removing them when empty for all rows.)
 Use \fB-o help\fP to view the list of all available fields.
-The -o option can be repeated, providing several lists.
+Use separate lists of fields to add, remove or compact by repeating the -o option:
+-o+field1,field2 -o-field3,field4 -o#field5.
 These lists are evaluated from left to right.
 Use field name \fBlv_all\fP to view all LV fields,
 \fBvg_all\fP all VG fields,
@@ -353,7 +319,6 @@ Use field name \fBlv_all\fP to view all LV fields,
 See the lvm.conf report section for more config options.
 See lvmreport(7) for more information about reporting.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -363,7 +328,6 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -371,7 +335,6 @@ changed with this option.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -379,7 +342,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--readonly\fP
@@ -394,7 +356,6 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not LVs are
 actually in use.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -406,14 +367,12 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB--rows\fP
 .br
 Output columns as rows.
 .ad b
-
 .HP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
@@ -427,14 +386,12 @@ showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
 .ad b
-
 .HP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
 String to use to separate each column. Useful if grepping the output.
 .ad b
-
 .HP
 .ad l
 \fB--shared\fP
@@ -443,7 +400,6 @@ Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See lvmlockd(8) for more information about shared VGs.
 .ad b
-
 .HP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
@@ -451,7 +407,6 @@ See lvmlockd(8) for more information about shared VGs.
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -462,21 +417,18 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB--trustcache\fP
 .br
 Avoids certain device scanning during command processing. Do not use.
 .ad b
-
 .HP
 .ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
 .ad b
-
 .HP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
@@ -488,7 +440,6 @@ human-(r)eadable with '<' rounding indicator,
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
 .ad b
-
 .HP
 .ad l
 \fB--unquoted\fP
@@ -496,7 +447,6 @@ Custom units can be specified, e.g. --units 3M.
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -504,14 +454,12 @@ pairs are not quoted.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -521,24 +469,19 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -553,7 +496,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH NOTES
@@ -572,7 +514,6 @@ are missing from the system
 Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
 .IP 6 3
 (c)lustered, (s)hared
-
 .SH SEE ALSO
 
 .BR lvm (8)
@@ -639,4 +580,3 @@ Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, @nywhere
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 57691ef..1e1547a 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -1,27 +1,15 @@
 .TH VGSCAN 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgscan \- Search for all volume groups
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgscan\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgscan scans all supported LVM block devices in the system for VGs.
-
-.P
 .SH USAGE
-.br
-.P
-.
 \fBvgscan\fP
 .br
 .RS 4
@@ -53,7 +41,6 @@ vgscan scans all supported LVM block devices in the system for VGs.
 .RE
 .br
 
-
 Common options for lvm:
 .
 .RS 4
@@ -104,19 +91,14 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--cache\fP
 .br
 Scan all devices and send the metadata to lvmetad.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -124,7 +106,6 @@ Scan all devices and send the metadata to lvmetad.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -134,7 +115,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -142,7 +122,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -150,14 +129,12 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--ignorelockingfailure\fP
@@ -165,14 +142,12 @@ Display help text.
 Allows a command to continue with read-only metadata
 operations after locking failures.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB--mknodes\fP
@@ -180,7 +155,6 @@ Display long help text.
 Also checks the LVM special files in /dev that are needed for active
 LVs and creates any missing ones and removes unused ones.
 .ad b
-
 .HP
 .ad l
 \fB--notifydbus\fP
@@ -189,7 +163,6 @@ Send a notification to D-Bus. The command will exit with an error
 if LVM is not built with support for D-Bus notification, or if the
 notify_dbus config setting is disabled.
 .ad b
-
 .HP
 .ad l
 \fB-P\fP|\fB--partial\fP
@@ -199,7 +172,6 @@ that are only partially available (one or more PVs belonging
 to the VG are missing from the system). Metadata may not be
 changed with this option.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -207,7 +179,6 @@ changed with this option.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -215,7 +186,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
@@ -227,7 +197,6 @@ If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -238,7 +207,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -246,14 +214,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -263,13 +229,10 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -284,7 +247,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -353,4 +315,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index a45db0b..a013c12 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -1,19 +1,12 @@
 .TH VGSPLIT 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
 .SH NAME
-.
 vgsplit \- Move physical volumes into a new or existing volume group
-.P
 .
 .SH SYNOPSIS
-.br
-.P
-.
 \fBvgsplit\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
-.P
-
 .SH DESCRIPTION
 vgsplit moves one or more PVs from a source VG to a destination VG. The
 PVs can be specified explicitly or implicitly by naming an LV, in which
@@ -28,12 +21,7 @@ the source or destination VG.
 
 vgsplit can only move complete PVs. (See \fBpvmove\fP(8) for moving part
 of a PV.)
-
-.P
 .SH USAGE
-.br
-.P
-.
 Split a VG by specified PVs.
 .br
 .P
@@ -44,7 +32,6 @@ Split a VG by specified PVs.
 .RE
 .br
 
-
 Split a VG by PVs in a specified LV.
 .br
 .P
@@ -55,7 +42,6 @@ Split a VG by PVs in a specified LV.
 .RE
 .br
 
-
 Common options for command:
 .
 .RS 4
@@ -86,9 +72,7 @@ Common options for command:
 .ad l
 [    \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
 .ad b
-
 .RE
-.br
 
 Common options for lvm:
 .
@@ -140,12 +124,8 @@ Common options for lvm:
 .ad l
 [    \fB--version\fP ]
 .ad b
-
 .RE
-
 .SH OPTIONS
-.br
-
 .HP
 .ad l
 \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
@@ -167,7 +147,6 @@ Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
 .ad b
-
 .HP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
@@ -175,14 +154,12 @@ See \fBlvm\fP(8) for more information about allocation.
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See vgcfgbackup(8) for more information.
 .ad b
-
 .HP
 .ad l
 \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
 .br
 Specifies the clustered property of the new VG.
 .ad b
-
 .HP
 .ad l
 \fB--commandprofile\fP \fIString\fP
@@ -190,7 +167,6 @@ Specifies the clustered property of the new VG.
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
-
 .HP
 .ad l
 \fB--config\fP \fIString\fP
@@ -200,7 +176,6 @@ The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
 .ad b
-
 .HP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
@@ -208,7 +183,6 @@ See \fBlvm.conf\fP(5) for more information about config.
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 .ad b
-
 .HP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
@@ -216,28 +190,24 @@ messages sent to the log file and/or syslog (if configured).
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
 .ad b
-
 .HP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.
 .ad b
-
 .HP
 .ad l
 \fB--longhelp\fP
 .br
 Display long help text.
 .ad b
-
 .HP
 .ad l
 \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP
 .br
 Sets the maximum number of LVs allowed in a VG.
 .ad b
-
 .HP
 .ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
@@ -247,7 +217,6 @@ The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
 .ad b
-
 .HP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
@@ -257,14 +226,12 @@ Specifies the type of on-disk metadata to use.
 \fBlvm1\fP (or just \fB1\fP) is a historical format that
 can be used for accessing old data.
 .ad b
-
 .HP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
 Move only PVs used by the named LV.
 .ad b
-
 .HP
 .ad l
 \fB--profile\fP \fIString\fP
@@ -272,7 +239,6 @@ Move only PVs used by the named LV.
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
 .ad b
-
 .HP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
@@ -280,7 +246,6 @@ on the command.
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer no.
 .ad b
-
 .HP
 .ad l
 \fB-t\fP|\fB--test\fP
@@ -291,7 +256,6 @@ returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .ad b
-
 .HP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
@@ -299,14 +263,12 @@ back metadata it believes has changed but hasn't.
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
 .ad b
-
 .HP
 .ad l
 \fB--version\fP
 .br
 Display version information.
 .ad b
-
 .HP
 .ad l
 \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
@@ -325,7 +287,6 @@ metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
 .ad b
-
 .HP
 .ad l
 \fB-y\fP|\fB--yes\fP
@@ -335,13 +296,10 @@ answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
 .ad b
 .SH VARIABLES
-.br
-
 .HP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-
 .HP
 \fIPV\fP
 .br
@@ -352,12 +310,10 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-
 .HP
 \fIString\fP
 .br
 See the option description for information about the string content.
-
 .HP
 \fISize\fP[UNIT]
 .br
@@ -372,7 +328,6 @@ p|P is petabytes, e|E is exabytes.
 (This should not be confused with the output control --units, where
 capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
-.br
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
@@ -441,4 +396,3 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvmraid (7)
 .BR lvmthin (7)
 .BR lvmcache (7)
-


