From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu,  8 Dec 2022 13:40:59 +0000 (GMT)
Subject: rhel-8.8.0 - make: generate
Message-ID: <20221208134059.13E853834E3A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=71354c39350b482ca8cf0fd9dcaf025b1d55b7d1
Commit:        71354c39350b482ca8cf0fd9dcaf025b1d55b7d1
Parent:        b56e8fc94d4d2b6d384148e3f74c54f4e1d816e6
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Dec 8 14:32:23 2022 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Dec 8 14:32:23 2022 +0100

make: generate

---
 man/lvchange.8_pregen        | 20 ++++++++++++++++++--
 man/lvconvert.8_pregen       | 22 ++++++++++++++++++++--
 man/lvcreate.8_pregen        | 24 ++++++++++++++++++++++--
 man/lvdisplay.8_pregen       |  5 +++--
 man/lvextend.8_pregen        |  5 +++--
 man/lvm-fullreport.8_pregen  |  5 +++--
 man/lvm-lvpoll.8_pregen      |  5 +++--
 man/lvmconfig.8_pregen       |  5 +++--
 man/lvmdevices.8_pregen      |  8 +++++---
 man/lvmdiskscan.8_pregen     |  5 +++--
 man/lvreduce.8_pregen        |  5 +++--
 man/lvremove.8_pregen        |  5 +++--
 man/lvrename.8_pregen        |  5 +++--
 man/lvresize.8_pregen        |  5 +++--
 man/lvs.8_pregen             |  5 +++--
 man/lvscan.8_pregen          |  5 +++--
 man/pvchange.8_pregen        |  5 +++--
 man/pvck.8_pregen            |  5 +++--
 man/pvcreate.8_pregen        |  5 +++--
 man/pvdisplay.8_pregen       |  5 +++--
 man/pvmove.8_pregen          |  5 +++--
 man/pvremove.8_pregen        |  5 +++--
 man/pvresize.8_pregen        |  5 +++--
 man/pvs.8_pregen             |  5 +++--
 man/pvscan.8_pregen          |  5 +++--
 man/vgcfgbackup.8_pregen     |  5 +++--
 man/vgcfgrestore.8_pregen    |  5 +++--
 man/vgchange.8_pregen        |  5 +++--
 man/vgck.8_pregen            |  5 +++--
 man/vgconvert.8_pregen       |  5 +++--
 man/vgcreate.8_pregen        |  5 +++--
 man/vgdisplay.8_pregen       |  5 +++--
 man/vgexport.8_pregen        |  5 +++--
 man/vgextend.8_pregen        |  5 +++--
 man/vgimport.8_pregen        |  5 +++--
 man/vgimportclone.8_pregen   |  5 +++--
 man/vgimportdevices.8_pregen |  5 +++--
 man/vgmerge.8_pregen         |  5 +++--
 man/vgmknodes.8_pregen       |  5 +++--
 man/vgreduce.8_pregen        |  5 +++--
 man/vgremove.8_pregen        |  5 +++--
 man/vgrename.8_pregen        |  5 +++--
 man/vgs.8_pregen             |  5 +++--
 man/vgscan.8_pregen          |  5 +++--
 man/vgsplit.8_pregen         |  5 +++--
 45 files changed, 188 insertions(+), 91 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index b559c89c9..27bee0f14 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -126,6 +126,8 @@ lvchange \(em Change the attributes of logical volume(s)
     \fB--sysinit\fP
 .br
  \fB-t\fP|\fB--test\fP
+.br
+    \fB--vdosettings\fP \fIString\fP
 .br
  \fB-v\fP|\fB--verbose\fP
 .br
@@ -202,6 +204,8 @@ required, after which the others are optional.
      \fB--\fP[\fBraid\fP]\fBminrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
      \fB--\fP[\fBraid\fP]\fBmaxrecoveryrate\fP \fISize\fP[k|UNIT]
+.br
+     \fB--vdosettings\fP \fIString\fP
 .br
      \fB--\fP[\fBraid\fP]\fBwritebehind\fP \fINumber\fP
 .br
@@ -609,8 +613,9 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
@@ -927,6 +932,17 @@ error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .
 .HP
+\fB--vdosettings\fP \fIString\fP
+.br
+Specifies tunable VDO options for VDO LVs.
+Use the form 'option=value' or 'option1=value option2=value', or
+repeat --vdosettings for each option being set.
+These settings override the default VDO behaviors.
+To remove vdosettings and revert to the default
+VDO behaviors, use --vdosettings 'default'.
+See \fBlvmvdo\fP(7) for more information.
+.
+.HP
 \fB-v\fP|\fB--verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 679519303..fa52da55c 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -155,6 +155,8 @@ lvconvert \(em Change logical volume layout
     \fB--usepolicies\fP
 .br
     \fB--vdopool\fP \fILV\fP
+.br
+    \fB--vdosettings\fP \fIString\fP
 .br
  \fB-v\fP|\fB--verbose\fP
 .br
@@ -742,6 +744,8 @@ Convert LV to type vdopool.
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--vdosettings\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -1131,8 +1135,9 @@ See \fBlvmvdo\fP(7) for more information about VDO usage.
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
@@ -1535,6 +1540,17 @@ The name of a VDO pool LV.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
 .
 .HP
+\fB--vdosettings\fP \fIString\fP
+.br
+Specifies tunable VDO options for VDO LVs.
+Use the form 'option=value' or 'option1=value option2=value', or
+repeat --vdosettings for each option being set.
+These settings override the default VDO behaviors.
+To remove vdosettings and revert to the default
+VDO behaviors, use --vdosettings 'default'.
+See \fBlvmvdo\fP(7) for more information.
+.
+.HP
 \fB-v\fP|\fB--verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
@@ -1808,6 +1824,8 @@ Convert LV to type vdopool.
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--vdosettings\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 2cccbbe56..0ffe92a94 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -157,6 +157,8 @@ lvcreate \(em Create a logical volume
     \fB--vdo\fP
 .br
     \fB--vdopool\fP \fILV\fP
+.br
+    \fB--vdosettings\fP \fIString\fP
 .br
  \fB-v\fP|\fB--verbose\fP
 .br
@@ -537,6 +539,8 @@ Create a LV that returns VDO when used.
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--vdosettings\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -1003,8 +1007,9 @@ See \fBlvmvdo\fP(7) for more information about VDO usage.
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
@@ -1438,6 +1443,17 @@ The name of a VDO pool LV.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
 .
 .HP
+\fB--vdosettings\fP \fIString\fP
+.br
+Specifies tunable VDO options for VDO LVs.
+Use the form 'option=value' or 'option1=value option2=value', or
+repeat --vdosettings for each option being set.
+These settings override the default VDO behaviors.
+To remove vdosettings and revert to the default
+VDO behaviors, use --vdosettings 'default'.
+See \fBlvmvdo\fP(7) for more information.
+.
+.HP
 \fB-v\fP|\fB--verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
@@ -1966,6 +1982,8 @@ Create a VDO LV with VDO pool.
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--vdosettings\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -1996,6 +2014,8 @@ Create a VDO LV with VDO pool.
 .br
 [    \fB--deduplication\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--vdosettings\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 04aab4c09..387a7d30d 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -186,8 +186,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index be6992e94..8a3e1ea4e 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -328,8 +328,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 02b38ef40..edae0efe3 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -169,8 +169,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 7f45f6eb3..fa8027f8e 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -115,8 +115,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 51946e1ec..e6762f989 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -156,8 +156,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvmdevices.8_pregen b/man/lvmdevices.8_pregen
index d64c3a31a..a2397e50f 100644
--- a/man/lvmdevices.8_pregen
+++ b/man/lvmdevices.8_pregen
@@ -322,7 +322,8 @@ Find a device with the PVID and add the device to the devices file.
 .HP
 \fB--check\fP
 .br
-Check the content of the devices file.
+Checks the content of the devices file.
+Reports incorrect device names or PVIDs for entries.
 .
 .HP
 \fB--commandprofile\fP \fIString\fP
@@ -364,8 +365,9 @@ then it will override the default type that lvm would use.
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index 7fd3d941d..ac0931c88 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -102,8 +102,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index ea960eb53..cd2e38e5b 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -130,8 +130,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index 2bd7997a3..8a4afbdff 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -136,8 +136,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index d41a4c241..27ce2caeb 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -120,8 +120,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index f3ea2536c..10e7dda7c 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -286,8 +286,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 2b2c5f193..94a74f9dd 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -172,8 +172,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index f459ab35b..8d79f22dd 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -119,8 +119,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 4add9ca69..010845274 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -179,8 +179,9 @@ multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 88200f21e..7d6652342 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -351,8 +351,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index a74a5ec2a..6ffd596fe 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -229,8 +229,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 2f26a8727..59628bedd 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -183,8 +183,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index 0f70497a2..f633b97d2 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -206,8 +206,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 3d4a86c09..51c589fd7 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -103,8 +103,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 87d87c8ce..9ce57e325 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -98,8 +98,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 32c28e4d1..955b3f887 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -169,8 +169,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 1c96d5aab..1e1cc11ab 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -369,8 +369,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index 5e658093a..cf984b04b 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -123,8 +123,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index 695e05582..6165cd36e 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -208,8 +208,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 05c67aead..7c7030c0d 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -556,8 +556,9 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index a8fa33f4b..cfb828ff9 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -114,8 +114,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 4d54c2b27..b99de39b8 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -124,8 +124,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 9bb8d3868..d5316aa1c 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -206,8 +206,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 0a12b3c39..b6cd294d5 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -180,8 +180,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index a87058946..6af64b82a 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -139,8 +139,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index 2b2650527..e55e0a110 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -147,8 +147,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index 5cd8fab84..9f8614205 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -128,8 +128,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index bf0af5841..80da5454b 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -113,8 +113,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgimportdevices.8_pregen b/man/vgimportdevices.8_pregen
index 5897e29ad..44e5fc663 100644
--- a/man/vgimportdevices.8_pregen
+++ b/man/vgimportdevices.8_pregen
@@ -132,8 +132,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index a36e0c7bd..dfe8e2f0f 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -107,8 +107,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 0a03e1582..d7cd722a4 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -108,8 +108,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index f3178a618..63b0a20f3 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -199,8 +199,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index 779c0f13e..661ada673 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -109,8 +109,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index d3e776ca4..2b849d180 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -133,8 +133,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index ee5083a93..2ca98b0b0 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -166,8 +166,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 824e7f673..a8da70d99 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -101,8 +101,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 065c8b52a..99938a4e3 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -175,8 +175,9 @@ messages sent to the log file and/or syslog (if configured).
 .HP
 \fB--devices\fP \fIPV\fP
 .br
-Devices that the command can use. This option can be repeated
-or accepts a comma separated list of devices. This overrides
+Restricts the devices that are visible and accessible to the command.
+Devices not listed will appear to be missing. This option can be
+repeated, or accepts a comma separated list of devices. This overrides
 the devices file.
 .
 .HP

