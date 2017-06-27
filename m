From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 27 Jun 2017 10:47:57 -0400
Subject: master - man: regenerate
Message-ID: <201706271447.v5RElv2C008162@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b90014addca59b3a40a686fd73b27f7a40511660
Commit:        b90014addca59b3a40a686fd73b27f7a40511660
Parent:        7f1ec681d65001ed3c74a7c7239efa98a8507d88
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jun 27 15:47:00 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 27 15:47:00 2017 +0100

man: regenerate

---
 conf/example.conf.in        |    7 ++++---
 man/lvchange.8_pregen       |   14 ++++++++------
 man/lvconvert.8_pregen      |    2 ++
 man/lvcreate.8_pregen       |   12 +++++++-----
 man/lvdisplay.8_pregen      |   16 +++++++++-------
 man/lvextend.8_pregen       |    4 +++-
 man/lvm-fullreport.8_pregen |   11 ++++++-----
 man/lvm-lvpoll.8_pregen     |    4 +++-
 man/lvmconfig.8_pregen      |   40 ++++++++++++++++++++++++++++++++++++++--
 man/lvmdiskscan.8_pregen    |    2 ++
 man/lvreduce.8_pregen       |    4 +++-
 man/lvremove.8_pregen       |    4 +++-
 man/lvrename.8_pregen       |    4 +++-
 man/lvresize.8_pregen       |    4 +++-
 man/lvs.8_pregen            |   10 ++++++----
 man/lvscan.8_pregen         |    2 ++
 man/pvchange.8_pregen       |   12 +++++++++---
 man/pvck.8_pregen           |    2 ++
 man/pvcreate.8_pregen       |    6 ++++--
 man/pvdisplay.8_pregen      |   16 +++++++++-------
 man/pvmove.8_pregen         |    4 +++-
 man/pvremove.8_pregen       |    2 ++
 man/pvresize.8_pregen       |    2 ++
 man/pvs.8_pregen            |   10 ++++++----
 man/pvscan.8_pregen         |    6 +++++-
 man/vgcfgbackup.8_pregen    |    4 +++-
 man/vgcfgrestore.8_pregen   |    2 ++
 man/vgchange.8_pregen       |   26 ++++++++++++++------------
 man/vgck.8_pregen           |    2 ++
 man/vgconvert.8_pregen      |    2 ++
 man/vgcreate.8_pregen       |   16 +++++++++-------
 man/vgdisplay.8_pregen      |   16 +++++++++-------
 man/vgexport.8_pregen       |    4 +++-
 man/vgextend.8_pregen       |    4 +++-
 man/vgimport.8_pregen       |    3 +++
 man/vgimportclone.8_pregen  |    2 ++
 man/vgmerge.8_pregen        |    4 +++-
 man/vgmknodes.8_pregen      |    2 ++
 man/vgreduce.8_pregen       |    4 +++-
 man/vgremove.8_pregen       |    2 ++
 man/vgrename.8_pregen       |    4 +++-
 man/vgs.8_pregen            |   10 ++++++----
 man/vgscan.8_pregen         |    2 ++
 man/vgsplit.8_pregen        |    4 +++-
 44 files changed, 220 insertions(+), 93 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index ed34b91..b5b0e6a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -379,8 +379,9 @@ allocation {
 
 	# Configuration option allocation/raid_stripe_all_devices.
 	# Stripe across all PVs when RAID stripes are not specified.
-	# If enabled, all PVs in the VG or on the command line are used for raid0/4/5/6/10
-	# when the command does not specify the number of stripes to use.
+	# If enabled, all PVs in the VG or on the command line are used for
+	# raid0/4/5/6/10 when the command does not specify the number of
+	# stripes to use.
 	# This was the default behaviour until release 2.02.162.
 	# This configuration option has an automatic default value.
 	# raid_stripe_all_devices = 0
@@ -939,7 +940,7 @@ global {
 	use_lvmetad = @DEFAULT_USE_LVMETAD@
 
 	# Configuration option global/lvmetad_update_wait_time.
-	# The number of seconds a command will wait for lvmetad update to finish.
+	# Number of seconds a command will wait for lvmetad update to finish.
 	# After waiting for this period, a command will not use lvmetad, and
 	# will revert to disk scanning.
 	# This configuration option has an automatic default value.
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index e89ad39..68c21d8 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -598,8 +598,8 @@ If the list is not set, all LVs are considered to match, and if
 if the list is set but empty, no LVs match.
 Autoactivation should be used during system boot to make it possible
 to select which LVs should be automatically activated by the system.
-See lvmlockd(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
-See clvmd(8) for more information about activation options \fBey\fP, \fBsy\fP, \fBly\fP and \fBln\fP for clustered VGs.
+See \fBlvmlockd\fP(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
+See \fBclvmd\fP(8) for more information about activation options \fBey\fP, \fBsy\fP, \fBly\fP and \fBln\fP for clustered VGs.
 .ad b
 .HP
 .ad l
@@ -621,7 +621,7 @@ See \fBlvmraid\fP(7) for more information.
 \fB--addtag\fP \fITag\fP
 .br
 Adds a tag to a PV, VG or LV. This option can be repeated to add
-multiple tags at once. See lvm(8) for information about tags.
+multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .ad b
 .HP
 .ad l
@@ -649,7 +649,7 @@ See \fBlvm\fP(8) for more information about allocation.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -724,7 +724,7 @@ messages sent to the log file and/or syslog (if configured).
 \fB--deltag\fP \fITag\fP
 .br
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
-multiple tags at once. See lvm(8) for information about tags.
+multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .ad b
 .HP
 .ad l
@@ -857,7 +857,7 @@ See \fBlvmraid\fP(7) for more information.
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
-See dmeventd(8) for more information.
+See \fBdmeventd\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -1173,6 +1173,8 @@ Change LV permission to read-only:
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 3a96dc8..6855550 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1864,6 +1864,8 @@ Detach and remove the cache pool from a cache LV.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 3954026..6b05147 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -931,15 +931,15 @@ The --zero option normally requires the LV to be active.
 If autoactivation \fBay\fP is used, the LV is only activated
 if it matches an item in lvm.conf activation/auto_activation_volume_list.
 \fBay\fP implies --zero n and --wipesignatures n.
-See lvmlockd(8) for more information about activation options for shared VGs.
-See clvmd(8) for more information about activation options for clustered VGs.
+See \fBlvmlockd\fP(8) for more information about activation options for shared VGs.
+See \fBclvmd\fP(8) for more information about activation options for clustered VGs.
 .ad b
 .HP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
 Adds a tag to a PV, VG or LV. This option can be repeated to add
-multiple tags at once. See lvm(8) for information about tags.
+multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .ad b
 .HP
 .ad l
@@ -967,7 +967,7 @@ See \fBlvm\fP(8) for more information about allocation.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -1227,7 +1227,7 @@ See \fBlvmraid\fP(7) for more information.
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
-See dmeventd(8) for more information.
+See \fBdmeventd\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -2717,6 +2717,8 @@ then combining the new origin LV with an existing cache pool.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index a0ca9aa..6df90a0 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -201,14 +201,14 @@ the "unknown" value which denotes that the value could not be determined).
 \fB-c\fP|\fB--colon\fP
 .br
 Generate colon separated output for easier parsing in scripts or programs.
-Also see vgs(8) which provides considerably more control over the output.
+Also see \fBvgs\fP(8) which provides considerably more control over the output.
 .ad b
 .HP
 .ad l
 \fB-C\fP|\fB--columns\fP
 .br
-Display output in columns, the equivalent of vgs(8).
-Options listed are the same as options given in vgs(8).
+Display output in columns, the equivalent of \fBvgs\fP(8).
+Options listed are the same as options given in \fBvgs\fP(8).
 .ad b
 .HP
 .ad l
@@ -230,7 +230,7 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See lvmreport(7).
+See \fBlvmreport\fP(7).
 .ad b
 .HP
 .ad l
@@ -251,7 +251,7 @@ For testing and debugging.
 \fB--foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
-See lvmsystemid(7) for more information about foreign VGs.
+See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
@@ -335,7 +335,7 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
-See lvmreport(7) for more information about reporting.
+See \fBlvmreport\fP(7) for more information about reporting.
 .ad b
 .HP
 .ad l
@@ -406,7 +406,7 @@ String to use to separate each column. Useful if grepping the output.
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
-See lvmlockd(8) for more information about shared VGs.
+See \fBlvmlockd\fP(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
@@ -546,6 +546,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index ae631be..9f4f097 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -350,7 +350,7 @@ See \fBlvm\fP(8) for more information about allocation.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -692,6 +692,8 @@ Extend an LV by 16MiB using specific physical extents.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 8104dba..ff0cba7 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -15,7 +15,6 @@ and LV segments. The information is all gathered together for each VG
 (under a per-VG lock) so it is consistent. Information gathered from
 separate calls to \fBvgs\fP, \fBpvs\fP, and \fBlvs\fP can be inconsistent
 if information changes between commands.
-
 .SH USAGE
 \fBlvm fullreport\fP
 .br
@@ -214,7 +213,7 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See lvmreport(7).
+See \fBlvmreport\fP(7).
 .ad b
 .HP
 .ad l
@@ -235,7 +234,7 @@ For testing and debugging.
 \fB--foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
-See lvmsystemid(7) for more information about foreign VGs.
+See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
@@ -317,7 +316,7 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
-See lvmreport(7) for more information about reporting.
+See \fBlvmreport\fP(7) for more information about reporting.
 .ad b
 .HP
 .ad l
@@ -389,7 +388,7 @@ String to use to separate each column. Useful if grepping the output.
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
-See lvmlockd(8) for more information about shared VGs.
+See \fBlvmlockd\fP(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
@@ -532,6 +531,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 1292a6c..2154b79 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -99,7 +99,7 @@ Stop processing a poll operation in lvmpolld.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -312,6 +312,8 @@ Continue thin snapshot merge.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index e7f93cd..3c3e25f 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -213,7 +213,10 @@ Exclude advanced configuration settings from the output.
 .ad l
 \fB--ignorelocal\fP
 .br
-Ignore local section.
+Ignore the local section. The local section should be defined in
+the lvmlocal.conf file, and should contain config settings
+specific to the local host which should not be copied to
+other hosts.
 .ad b
 .HP
 .ad l
@@ -315,7 +318,38 @@ back metadata it believes has changed but hasn't.
 .ad l
 \fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
 .br
-See lvmreport(7).
+\fBcurrent\fP prints the config settings that would be applied
+to an lvm command (assuming the command does not override them
+on the command line.) This includes:
+settings that have been modified in lvm config files,
+settings that get their default values from config files,
+and default settings that have been uncommented in config files.
+\fBdefault\fP prints all settings with their default values.
+Changes made in lvm config files are not reflected in the output.
+Some settings get their default values internally,
+and these settings are printed as comments.
+Other settings get their default values from config files,
+and these settings are not printed as comments.
+\fBdiff\fP prints only config settings that have been modified
+from their default values in config files (the difference between
+current and default.)
+\fBfull\fP prints every setting uncommented and set to the
+current value, i.e. how it would be used by an lvm command.
+This includes settings modified in config files, settings that usually
+get defaults internally, and settings that get defaults from config files.
+\fBlist\fP prints all config names without values.
+\fBmissing\fP prints settings that are missing from the
+lvm config files. A missing setting that usually gets its default
+from config files is printed uncommented and set to the internal default.
+Settings that get their default internally and are not set in config files
+are printed commented with the internal default.
+\fBnew\fP prints config settings that have been added since
+the lvm version specified by --sinceversion. They are printed
+with their default values.
+\fBprofilable\fP prints settings with their default values that can be set from a profile.
+\fBprofilable-command\fP prints settings with their default values that can be set from a command profile.
+\fBprofilable-metadata\fP prints settings with their default values that can be set from a metadata profile.
+Also see \fBlvm.conf\fP(5).
 .ad b
 .HP
 .ad l
@@ -450,6 +484,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index b346fde..fe379bb 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -259,6 +259,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 65f3da4..865aef4 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -119,7 +119,7 @@ Common options for lvm:
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -363,6 +363,8 @@ Reduce the size of an LV by 3 logical extents:
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index cc28563..2c9aad1 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -123,7 +123,7 @@ Common options for lvm:
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -357,6 +357,8 @@ Remove all LVs the specified VG.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index dfb9247..af39eed 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -98,7 +98,7 @@ Common options for lvm:
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -294,6 +294,8 @@ An alternate syntax to rename "lvold" to "lvnew":
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index df9d93c..2432495 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -298,7 +298,7 @@ See \fBlvm\fP(8) for more information about allocation.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -618,6 +618,8 @@ Extend an LV by 16MB using specific physical extents:
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index b16bc86..f773750 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -220,7 +220,7 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See lvmreport(7).
+See \fBlvmreport\fP(7).
 .ad b
 .HP
 .ad l
@@ -241,7 +241,7 @@ For testing and debugging.
 \fB--foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
-See lvmsystemid(7) for more information about foreign VGs.
+See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
@@ -331,7 +331,7 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
-See lvmreport(7) for more information about reporting.
+See \fBlvmreport\fP(7) for more information about reporting.
 .ad b
 .HP
 .ad l
@@ -409,7 +409,7 @@ String to use to separate each column. Useful if grepping the output.
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
-See lvmlockd(8) for more information about shared VGs.
+See \fBlvmlockd\fP(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
@@ -637,6 +637,8 @@ s(k)ip activation: this volume is flagged to be skipped during activation.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 523de90..7713e53 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -322,6 +322,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 85ffcc8..33c49e9 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -9,6 +9,9 @@ pvchange - Change attributes of physical volume(s)
 .br
 .SH DESCRIPTION
 pvchange changes PV attributes in the VG.
+
+For options listed in parentheses, any one is required, after which the
+others are optional.
 .SH USAGE
 Change properties of all PVs.
 .br
@@ -160,12 +163,13 @@ Common options for lvm:
 \fB--addtag\fP \fITag\fP
 .br
 Adds a tag to a PV, VG or LV. This option can be repeated to add
-multiple tags at once. See lvm(8) for information about tags.
+multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .ad b
 .HP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
+Change all visible PVs.
 .ad b
 .HP
 .ad l
@@ -178,7 +182,7 @@ Enable or disable allocation of physical extents on this PV.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -208,7 +212,7 @@ messages sent to the log file and/or syslog (if configured).
 \fB--deltag\fP \fITag\fP
 .br
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
-multiple tags at once. See lvm(8) for information about tags.
+multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .ad b
 .HP
 .ad l
@@ -418,6 +422,8 @@ disk errors, or because it will be removed after freeing it).
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index fe5a030..51b761d 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -256,6 +256,8 @@ parameter with a value of 204800 (100 * 1024 * 1024 / 512 = 204800).
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index d3cb688..6345b28 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -343,11 +343,11 @@ back metadata it believes has changed but hasn't.
 Specify a UUID for the device.
 Without this option, a random UUID is generated.
 This option is needed before restoring a backup of LVM metadata
-onto a replacement device; see vgcfgrestore(8). As such, use of
+onto a replacement device; see \fBvgcfgrestore\fP(8). As such, use of
 --restorefile is compulsory unless the --norestorefile is used.
 All PVs must have unique UUIDs, and LVM will prevent certain operations
 if multiple devices are seen with the same UUID.
-See vgimportclone(8) for more information.
+See \fBvgimportclone\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -469,6 +469,8 @@ boundary) manually account for this when initializing for use by LVM.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 9434508..1e7ed4b 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -196,14 +196,14 @@ the "unknown" value which denotes that the value could not be determined).
 \fB-c\fP|\fB--colon\fP
 .br
 Generate colon separated output for easier parsing in scripts or programs.
-Also see vgs(8) which provides considerably more control over the output.
+Also see \fBvgs\fP(8) which provides considerably more control over the output.
 .ad b
 .HP
 .ad l
 \fB-C\fP|\fB--columns\fP
 .br
-Display output in columns, the equivalent of vgs(8).
-Options listed are the same as options given in vgs(8).
+Display output in columns, the equivalent of \fBvgs\fP(8).
+Options listed are the same as options given in \fBvgs\fP(8).
 .ad b
 .HP
 .ad l
@@ -225,7 +225,7 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See lvmreport(7).
+See \fBlvmreport\fP(7).
 .ad b
 .HP
 .ad l
@@ -246,7 +246,7 @@ For testing and debugging.
 \fB--foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
-See lvmsystemid(7) for more information about foreign VGs.
+See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
@@ -320,7 +320,7 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
-See lvmreport(7) for more information about reporting.
+See \fBlvmreport\fP(7) for more information about reporting.
 .ad b
 .HP
 .ad l
@@ -386,7 +386,7 @@ String to use to separate each column. Useful if grepping the output.
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
-See lvmlockd(8) for more information about shared VGs.
+See \fBlvmlockd\fP(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
@@ -533,6 +533,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index 08f35b9..cfc4549 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -183,7 +183,7 @@ moved to the destination PV, or none are if the operation is aborted.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -482,6 +482,8 @@ extents can also be picked out and moved.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index a913ab3..325654a 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -267,6 +267,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 8a03088..09c81e4 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -274,6 +274,8 @@ appropriate for the intended new partition size).
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 9b5162a..970c1f9 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -215,7 +215,7 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See lvmreport(7).
+See \fBlvmreport\fP(7).
 .ad b
 .HP
 .ad l
@@ -236,7 +236,7 @@ For testing and debugging.
 \fB--foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
-See lvmsystemid(7) for more information about foreign VGs.
+See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
@@ -318,7 +318,7 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
-See lvmreport(7) for more information about reporting.
+See \fBlvmreport\fP(7) for more information about reporting.
 .ad b
 .HP
 .ad l
@@ -398,7 +398,7 @@ String to use to separate each column. Useful if grepping the output.
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
-See lvmlockd(8) for more information about shared VGs.
+See \fBlvmlockd\fP(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
@@ -561,6 +561,8 @@ e(x)ported
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 0148c09..4927fcb 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -141,7 +141,7 @@ Populate the lvmetad cache by scanning PVs.
 .ad b
 .br
 .ad l
-[ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP ]
+[ \fB-a\fP|\fB--activate\fP \fBay\fP ]
 .ad b
 .br
 .ad l
@@ -227,6 +227,8 @@ Common options for lvm:
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
+Auto-activate LVs in a VG when the PVs scanned have completed the VG.
+(Only \fBay\fP is applicable.)
 .ad b
 .HP
 .ad l
@@ -462,6 +464,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index 6a7099d..6a56481 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -152,7 +152,7 @@ treated as a template, and %s is replaced by the VG name.
 \fB--foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
-See lvmsystemid(7) for more information about foreign VGs.
+See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
@@ -316,6 +316,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index d15859e..f4fe2e4 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -399,6 +399,8 @@ missing PV. Repeat for all other missing PVs in the VG.  Then use
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 6d95335..b08c2f9 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -536,8 +536,8 @@ If the list is not set, all LVs are considered to match, and if
 if the list is set but empty, no LVs match.
 Autoactivation should be used during system boot to make it possible
 to select which LVs should be automatically activated by the system.
-See lvmlockd(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
-See clvmd(8) for more information about activation options \fBey\fP, \fBsy\fP, \fBly\fP and \fBln\fP for clustered VGs.
+See \fBlvmlockd\fP(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
+See \fBclvmd\fP(8) for more information about activation options \fBey\fP, \fBsy\fP, \fBly\fP and \fBln\fP for clustered VGs.
 .ad b
 .HP
 .ad l
@@ -559,7 +559,7 @@ See \fBlvmraid\fP(7) for more information.
 \fB--addtag\fP \fITag\fP
 .br
 Adds a tag to a PV, VG or LV. This option can be repeated to add
-multiple tags at once. See lvm(8) for information about tags.
+multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .ad b
 .HP
 .ad l
@@ -587,14 +587,14 @@ See \fBlvm\fP(8) for more information about allocation.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
 \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
 .br
 Change the clustered property of a VG using clvmd.
-See clvmd(8) for more information about clustered VGs.
+See \fBclvmd\fP(8) for more information about clustered VGs.
 .ad b
 .HP
 .ad l
@@ -624,7 +624,7 @@ messages sent to the log file and/or syslog (if configured).
 \fB--deltag\fP \fITag\fP
 .br
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
-multiple tags at once. See lvm(8) for information about tags.
+multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .ad b
 .HP
 .ad l
@@ -686,7 +686,7 @@ without clustered locking and clustered VGs are skipped.
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
-See lvmlockd(8) for more information.
+See \fBlvmlockd\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -694,7 +694,7 @@ See lvmlockd(8) for more information.
 .br
 Start the lockspace of a shared VG in lvmlockd.
 lvmlockd locks becomes available for the VG, allowing LVM to use the VG.
-See lvmlockd(8) for more information.
+See \fBlvmlockd\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -702,14 +702,14 @@ See lvmlockd(8) for more information.
 .br
 Stop the lockspace of a shared VG in lvmlockd.
 lvmlockd locks become unavailable for the VG, preventing LVM from using the VG.
-See lvmlockd(8) for more information.
+See \fBlvmlockd\fP(8) for more information.
 .ad b
 .HP
 .ad l
 \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .br
 Change the VG lock type to or from a shared lock type used with lvmlockd.
-See lvmlockd(8) for more information.
+See \fBlvmlockd\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -746,7 +746,7 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
-See dmeventd(8) for more information.
+See \fBdmeventd\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -879,7 +879,7 @@ vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
 Changes the system ID of the VG.  Using this option requires caution
 because the VG may become foreign to the host running the command,
 leaving the host unable to access it.
-See lvmsystemid(7) for more information.
+See \fBlvmsystemid\fP(7) for more information.
 .ad b
 .HP
 .ad l
@@ -1032,6 +1032,8 @@ Change the maximum number of LVs for an inactive VG.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 235c3cc..9e3c2ef 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -254,6 +254,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 60b474b..c63bd50 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -332,6 +332,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 6311e42..82d341c 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -165,7 +165,7 @@ Common options for lvm:
 \fB--addtag\fP \fITag\fP
 .br
 Adds a tag to a PV, VG or LV. This option can be repeated to add
-multiple tags at once. See lvm(8) for information about tags.
+multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .ad b
 .HP
 .ad l
@@ -193,7 +193,7 @@ See \fBlvm\fP(8) for more information about allocation.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -203,7 +203,7 @@ Create a clustered VG using clvmd if LVM is compiled with cluster support.
 This allows multiple hosts to share a VG on shared devices.
 clvmd and a lock manager must be configured and running.
 (A clustered VG using clvmd is different from a shared VG using lvmlockd.)
-See clvmd(8) for more information about clustered VGs.
+See \fBclvmd\fP(8) for more information about clustered VGs.
 .ad b
 .HP
 .ad l
@@ -278,14 +278,14 @@ in the source). Use with care.
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
-See lvmlockd(8) for more information.
+See \fBlvmlockd\fP(8) for more information.
 .ad b
 .HP
 .ad l
 \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .br
 Specify the VG lock type directly in place of using --shared.
-See lvmlockd(8) for more information.
+See \fBlvmlockd\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -389,7 +389,7 @@ lvmlockd will select lock type sanlock or dlm depending on which lock
 manager is running. This allows multiple hosts to share a VG on shared
 devices. lvmlockd and a lock manager must be configured and running.
 (A shared VG using lvmlockd is different from a clustered VG using clvmd.)
-See lvmlockd(8) for more information about shared VGs.
+See \fBlvmlockd\fP(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
@@ -401,7 +401,7 @@ without this option, in which case the new VG is given the system ID of
 the host creating it. Using this option requires caution because the
 system ID of the new VG may not match the system ID of the host running
 the command, leaving the VG inaccessible to the host.
-See lvmsystemid(7) for more information.
+See \fBlvmsystemid\fP(7) for more information.
 .ad b
 .HP
 .ad l
@@ -548,6 +548,8 @@ Create a VG with two PVs, using the default physical extent size.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 9b99936..2fffacb 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -191,14 +191,14 @@ the "unknown" value which denotes that the value could not be determined).
 \fB-c\fP|\fB--colon\fP
 .br
 Generate colon separated output for easier parsing in scripts or programs.
-Also see vgs(8) which provides considerably more control over the output.
+Also see \fBvgs\fP(8) which provides considerably more control over the output.
 .ad b
 .HP
 .ad l
 \fB-C\fP|\fB--columns\fP
 .br
-Display output in columns, the equivalent of vgs(8).
-Options listed are the same as options given in vgs(8).
+Display output in columns, the equivalent of \fBvgs\fP(8).
+Options listed are the same as options given in \fBvgs\fP(8).
 .ad b
 .HP
 .ad l
@@ -220,7 +220,7 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See lvmreport(7).
+See \fBlvmreport\fP(7).
 .ad b
 .HP
 .ad l
@@ -241,7 +241,7 @@ For testing and debugging.
 \fB--foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
-See lvmsystemid(7) for more information about foreign VGs.
+See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
@@ -309,7 +309,7 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
-See lvmreport(7) for more information about reporting.
+See \fBlvmreport\fP(7) for more information about reporting.
 .ad b
 .HP
 .ad l
@@ -375,7 +375,7 @@ String to use to separate each column. Useful if grepping the output.
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
-See lvmlockd(8) for more information about shared VGs.
+See \fBlvmlockd\fP(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
@@ -516,6 +516,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index 6d2c6ca..ed292f8 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -10,7 +10,7 @@ vgexport - Unregister volume group(s) from the system
 .SH DESCRIPTION
 vgexport makes inactive VGs unknown to the system. In this state, all the
 PVs in the VG can be moved to a different system, from which
-\fBvgimport\fP can then be run.
+\fBvgimport\fP(8) can then be run.
 
 Most LVM tools ignore exported VGs.
 
@@ -301,6 +301,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index 5445f6c..bc6d959 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -132,7 +132,7 @@ Common options for lvm:
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -405,6 +405,8 @@ Add two PVs to a VG.
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index ffd237c..7e0c3d6 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -106,6 +106,7 @@ Common options for lvm:
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
+Import all visible VGs.
 .ad b
 .HP
 .ad l
@@ -309,6 +310,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index ea326f7..96c95f9 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -273,6 +273,8 @@ Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_sna
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index c2a071b..c3a9bc8 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -84,7 +84,7 @@ Common options for lvm:
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -258,6 +258,8 @@ Merge an inactive VG named "vg00" into the active or inactive VG named
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index d23ecaf..b50b3dc 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -287,6 +287,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index d5cdac3..44a6ae0 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -198,7 +198,7 @@ Removes all empty PVs if none are named on the command line.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -409,6 +409,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index 22e778c..5399848 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -304,6 +304,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 5a5b8fa..3570e87 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -111,7 +111,7 @@ Common options for lvm:
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -300,6 +300,8 @@ Rename the VG with the specified UUID to "myvg".
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index 7909af9..6bef89d 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -210,7 +210,7 @@ See \fBlvm.conf\fP(5) for more information about config.
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See lvmreport(7).
+See \fBlvmreport\fP(7).
 .ad b
 .HP
 .ad l
@@ -231,7 +231,7 @@ For testing and debugging.
 \fB--foreign\fP
 .br
 Report/display foreign VGs that would otherwise be skipped.
-See lvmsystemid(7) for more information about foreign VGs.
+See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .ad b
 .HP
 .ad l
@@ -313,7 +313,7 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBseg_all\fP all LV segment fields, and
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
-See lvmreport(7) for more information about reporting.
+See \fBlvmreport\fP(7) for more information about reporting.
 .ad b
 .HP
 .ad l
@@ -385,7 +385,7 @@ String to use to separate each column. Useful if grepping the output.
 .br
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
-See lvmlockd(8) for more information about shared VGs.
+See \fBlvmlockd\fP(8) for more information about shared VGs.
 .ad b
 .HP
 .ad l
@@ -549,6 +549,8 @@ Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index ccc2f29..bd2f4d9 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -284,6 +284,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 400cdcd..d02e68a 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -152,7 +152,7 @@ See \fBlvm\fP(8) for more information about allocation.
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
 Specifies if metadata should be backed up automatically after a change.
-Enabling this is strongly advised! See vgcfgbackup(8) for more information.
+Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
 .ad b
 .HP
 .ad l
@@ -378,6 +378,8 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvs (8)
 .BR lvscan (8)
 
+.BR lvm-fullreport (8)
+.BR lvm-lvpoll (8)
 .BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)


