From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 15 Mar 2017 21:52:04 -0400
Subject: master - man: Reinstate previous lvmsar and lvmsadc pages.
Message-ID: <201703160152.v2G1q4HH030118@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0430b975ba96e6309e6c0dcd675b3ada32ffc70
Commit:        b0430b975ba96e6309e6c0dcd675b3ada32ffc70
Parent:        1cdaa8144ddc2d171700d2c80f18cb745828f7ed
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 01:49:40 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 01:49:40 2017 +0000

man: Reinstate previous lvmsar and lvmsadc pages.

Avoid listing all the common options for obsolete commands.
---
 man/lvm.8_main       |    6 +-
 man/lvmsadc.8_des    |    3 -
 man/lvmsadc.8_main   |   12 +++
 man/lvmsadc.8_pregen |  247 -----------------------------------------------
 man/lvmsar.8_des     |    3 -
 man/lvmsar.8_main    |   12 +++
 man/lvmsar.8_pregen  |  262 --------------------------------------------------
 7 files changed, 25 insertions(+), 520 deletions(-)

diff --git a/man/lvm.8_main b/man/lvm.8_main
index 1166375..32b87c4 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -82,9 +82,6 @@ if command log reporting is enabled.
 .B lvpoll
 Complete lvmpolld operations (Internal command).
 .TP
-.B pvdata
-Not implemented in LVM2.
-.TP
 .B segtypes
 Display recognised Logical Volume segment types.
 .TP
@@ -234,8 +231,7 @@ Report information about Logical Volumes.
 Scan (all disks) for Logical Volumes.
 .PD
 .P
-The following commands are not implemented in LVM2 but might be
-in the future:
+The following LVM1 commands are not implemented in LVM2:
 .BR lvmchange ", " lvmsadc ", " lvmsar ", " pvdata .
 .
 .SH VALID NAMES
diff --git a/man/lvmsadc.8_des b/man/lvmsadc.8_des
deleted file mode 100644
index e4cfd8d..0000000
--- a/man/lvmsadc.8_des
+++ /dev/null
@@ -1,3 +0,0 @@
-lvmsadc is not currently supported in LVM. The device-mapper statistics
-facility provides similar performance metrics using the \fBdmstats(8)\fP
-command.
diff --git a/man/lvmsadc.8_end b/man/lvmsadc.8_end
deleted file mode 100644
index e69de29..0000000
diff --git a/man/lvmsadc.8_main b/man/lvmsadc.8_main
new file mode 100644
index 0000000..c2781b8
--- /dev/null
+++ b/man/lvmsadc.8_main
@@ -0,0 +1,12 @@
+.TH "LVMSADC" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.SH "NAME"
+lvmsadc \(em LVM system activity data collector
+.SH "SYNOPSIS"
+.B lvmsadc
+.SH "DESCRIPTION"
+lvmsadc is not supported under LVM2. The device-mapper statistics
+facility provides similar performance metrics using the \fBdmstats(8)\fP
+command.
+.SH "SEE ALSO"
+.BR dmstats (8)
+.BR lvm (8)
diff --git a/man/lvmsadc.8_pregen b/man/lvmsadc.8_pregen
deleted file mode 100644
index ed4a0d7..0000000
--- a/man/lvmsadc.8_pregen
+++ /dev/null
@@ -1,247 +0,0 @@
-.TH LVMSADC 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
-.SH NAME
-lvmsadc \- Collect activity data
-.
-.SH SYNOPSIS
-\fBlvmsadc\fP
-.br
-    [ \fIoption_args\fP ]
-.br
-.SH DESCRIPTION
-lvmsadc is not currently supported in LVM. The device-mapper statistics
-facility provides similar performance metrics using the \fBdmstats(8)\fP
-command.
-.SH USAGE
-\fBlvmsadc\fP
-.br
-.RS 4
-[ COMMON_OPTIONS ]
-.RE
-.br
-
-Common options for lvm:
-.
-.RS 4
-.ad l
-[ \fB-d\fP|\fB--debug\fP ]
-.ad b
-.br
-.ad l
-[ \fB-h\fP|\fB--help\fP ]
-.ad b
-.br
-.ad l
-[ \fB-q\fP|\fB--quiet\fP ]
-.ad b
-.br
-.ad l
-[ \fB-t\fP|\fB--test\fP ]
-.ad b
-.br
-.ad l
-[ \fB-v\fP|\fB--verbose\fP ]
-.ad b
-.br
-.ad l
-[ \fB-y\fP|\fB--yes\fP ]
-.ad b
-.br
-.ad l
-[    \fB--commandprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--config\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--longhelp\fP ]
-.ad b
-.br
-.ad l
-[    \fB--profile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--version\fP ]
-.ad b
-.RE
-.SH OPTIONS
-.HP
-.ad l
-\fB--commandprofile\fP \fIString\fP
-.br
-The command profile to use for command configuration.
-See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
-.ad l
-\fB--config\fP \fIString\fP
-.br
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
-or may use section/field syntax.
-See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
-.ad l
-\fB-d\fP|\fB--debug\fP ...
-.br
-Set debug level. Repeat from 1 to 6 times to increase the detail of
-messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
-.ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
-.br
-If set to no, the command will not attempt to use device-mapper.
-For testing and debugging.
-.ad b
-.HP
-.ad l
-\fB-h\fP|\fB--help\fP
-.br
-Display help text.
-.ad b
-.HP
-.ad l
-\fB--longhelp\fP
-.br
-Display long help text.
-.ad b
-.HP
-.ad l
-\fB--profile\fP \fIString\fP
-.br
-An alias for --commandprofile or --metadataprofile, depending
-on the command.
-.ad b
-.HP
-.ad l
-\fB-q\fP|\fB--quiet\fP ...
-.br
-Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
-.ad b
-.HP
-.ad l
-\fB-t\fP|\fB--test\fP
-.br
-Run in test mode. Commands will not update metadata.
-This is implemented by disabling all metadata writing but nevertheless
-returning success to the calling function. This may lead to unusual
-error messages in multi-stage operations if a tool relies on reading
-back metadata it believes has changed but hasn't.
-.ad b
-.HP
-.ad l
-\fB-v\fP|\fB--verbose\fP ...
-.br
-Set verbose level. Repeat from 1 to 4 times to increase the detail
-of messages sent to stdout and stderr.
-.ad b
-.HP
-.ad l
-\fB--version\fP
-.br
-Display version information.
-.ad b
-.HP
-.ad l
-\fB-y\fP|\fB--yes\fP
-.br
-Do not prompt for confirmation interactively but always assume the
-answer yes. Use with extreme caution.
-(For automatic no, see -qq.)
-.ad b
-.SH VARIABLES
-.HP
-\fIString\fP
-.br
-See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
-Size is an input number that accepts an optional unit.
-Input units are always treated as base two values, regardless of
-capitalization, e.g. 'k' and 'K' both refer to 1024.
-The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
-capital letters mean multiple of 1000.)
-.SH ENVIRONMENT VARIABLES
-See \fBlvm\fP(8) for information about environment variables used by lvm.
-For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
-
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
-
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
-
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
-
-.BR dmeventd (8)
-.BR lvmetad (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR clvmd (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
-
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
-.BR lvmcache (7)
diff --git a/man/lvmsar.8_des b/man/lvmsar.8_des
deleted file mode 100644
index 3177506..0000000
--- a/man/lvmsar.8_des
+++ /dev/null
@@ -1,3 +0,0 @@
-lvmsar is not currently supported in LVM. The device-mapper statistics
-facility provides similar performance metrics using the \fBdmstats(8)\fP
-command.
diff --git a/man/lvmsar.8_end b/man/lvmsar.8_end
deleted file mode 100644
index e69de29..0000000
diff --git a/man/lvmsar.8_main b/man/lvmsar.8_main
new file mode 100644
index 0000000..0bbcbf3
--- /dev/null
+++ b/man/lvmsar.8_main
@@ -0,0 +1,12 @@
+.TH "LVMSAR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.SH "NAME"
+lvmsar \(em LVM system activity reporter
+.SH "SYNOPSIS"
+.B lvmsar
+.SH "DESCRIPTION"
+lvmsar is not supported under LVM2. The device-mapper statistics
+facility provides similar performance metrics using the \fBdmstats(8)\fP
+command.
+.SH "SEE ALSO"
+.BR dmstats (8)
+.BR lvm (8)
diff --git a/man/lvmsar.8_pregen b/man/lvmsar.8_pregen
deleted file mode 100644
index 547a0a0..0000000
--- a/man/lvmsar.8_pregen
+++ /dev/null
@@ -1,262 +0,0 @@
-.TH LVMSAR 8 "LVM TOOLS 2.02.169(2)-git (2016-11-30)" "Red Hat, Inc."
-.SH NAME
-lvmsar \- Create activity report
-.
-.SH SYNOPSIS
-\fBlvmsar\fP
-.br
-    [ \fIoption_args\fP ]
-.br
-.SH DESCRIPTION
-lvmsar is not currently supported in LVM. The device-mapper statistics
-facility provides similar performance metrics using the \fBdmstats(8)\fP
-command.
-.SH USAGE
-\fBlvmsar\fP
-.br
-.RS 4
-.ad l
-[ \fB-f\fP|\fB--full\fP ]
-.ad b
-.br
-.ad l
-[ \fB-s\fP|\fB--stdin\fP ]
-.ad b
-.br
-[ COMMON_OPTIONS ]
-.RE
-.br
-Common options for lvm:
-.
-.RS 4
-.ad l
-[ \fB-d\fP|\fB--debug\fP ]
-.ad b
-.br
-.ad l
-[ \fB-h\fP|\fB--help\fP ]
-.ad b
-.br
-.ad l
-[ \fB-q\fP|\fB--quiet\fP ]
-.ad b
-.br
-.ad l
-[ \fB-t\fP|\fB--test\fP ]
-.ad b
-.br
-.ad l
-[ \fB-v\fP|\fB--verbose\fP ]
-.ad b
-.br
-.ad l
-[ \fB-y\fP|\fB--yes\fP ]
-.ad b
-.br
-.ad l
-[    \fB--commandprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--config\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--longhelp\fP ]
-.ad b
-.br
-.ad l
-[    \fB--profile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--version\fP ]
-.ad b
-.RE
-
-.SH OPTIONS
-.HP
-.ad l
-\fB--commandprofile\fP \fIString\fP
-.br
-The command profile to use for command configuration.
-See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
-.ad l
-\fB--config\fP \fIString\fP
-.br
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
-or may use section/field syntax.
-See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
-.ad l
-\fB-d\fP|\fB--debug\fP ...
-.br
-Set debug level. Repeat from 1 to 6 times to increase the detail of
-messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
-.ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
-.br
-If set to no, the command will not attempt to use device-mapper.
-For testing and debugging.
-.ad b
-.HP
-.ad l
-\fB-f\fP|\fB--full\fP.ad b
-.HP
-.ad l
-\fB-h\fP|\fB--help\fP
-.br
-Display help text.
-.ad b
-.HP
-.ad l
-\fB--longhelp\fP
-.br
-Display long help text.
-.ad b
-.HP
-.ad l
-\fB--profile\fP \fIString\fP
-.br
-An alias for --commandprofile or --metadataprofile, depending
-on the command.
-.ad b
-.HP
-.ad l
-\fB-q\fP|\fB--quiet\fP ...
-.br
-Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
-.ad b
-.HP
-.ad l
-\fB-s\fP|\fB--stdin\fP.ad b
-.HP
-.ad l
-\fB-t\fP|\fB--test\fP
-.br
-Run in test mode. Commands will not update metadata.
-This is implemented by disabling all metadata writing but nevertheless
-returning success to the calling function. This may lead to unusual
-error messages in multi-stage operations if a tool relies on reading
-back metadata it believes has changed but hasn't.
-.ad b
-.HP
-.ad l
-\fB-v\fP|\fB--verbose\fP ...
-.br
-Set verbose level. Repeat from 1 to 4 times to increase the detail
-of messages sent to stdout and stderr.
-.ad b
-.HP
-.ad l
-\fB--version\fP
-.br
-Display version information.
-.ad b
-.HP
-.ad l
-\fB-y\fP|\fB--yes\fP
-.br
-Do not prompt for confirmation interactively but always assume the
-answer yes. Use with extreme caution.
-(For automatic no, see -qq.)
-.ad b
-.SH VARIABLES
-.HP
-\fIString\fP
-.br
-See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
-Size is an input number that accepts an optional unit.
-Input units are always treated as base two values, regardless of
-capitalization, e.g. 'k' and 'K' both refer to 1024.
-The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
-capital letters mean multiple of 1000.)
-.SH ENVIRONMENT VARIABLES
-See \fBlvm\fP(8) for information about environment variables used by lvm.
-For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-
-.SH SEE ALSO
-
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
-
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
-
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
-
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
-
-.BR dmeventd (8)
-.BR lvmetad (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR clvmd (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
-
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
-.BR lvmcache (7)


