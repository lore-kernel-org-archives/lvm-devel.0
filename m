From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 18 May 2022 16:15:44 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20220518161544.5A3BC3858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9aa3ea1c9859aa6a1d8b9ac918fa47ae24927735
Commit:        9aa3ea1c9859aa6a1d8b9ac918fa47ae24927735
Parent:        7ec0726ce331a4dc1ab5dc5e1b9ae503e5d758da
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed May 18 18:15:30 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed May 18 18:15:30 2022 +0200

make: generate

---
 man/lvchange.8_pregen        | 5 +++--
 man/lvconvert.8_pregen       | 5 +++--
 man/lvcreate.8_pregen        | 5 +++--
 man/lvdisplay.8_pregen       | 5 +++--
 man/lvextend.8_pregen        | 5 +++--
 man/lvm-fullreport.8_pregen  | 5 +++--
 man/lvm-lvpoll.8_pregen      | 5 +++--
 man/lvmconfig.8_pregen       | 5 +++--
 man/lvmdevices.8_pregen      | 5 +++--
 man/lvmdiskscan.8_pregen     | 5 +++--
 man/lvreduce.8_pregen        | 5 +++--
 man/lvremove.8_pregen        | 5 +++--
 man/lvrename.8_pregen        | 5 +++--
 man/lvresize.8_pregen        | 5 +++--
 man/lvs.8_pregen             | 5 +++--
 man/lvscan.8_pregen          | 5 +++--
 man/pvchange.8_pregen        | 5 +++--
 man/pvck.8_pregen            | 5 +++--
 man/pvcreate.8_pregen        | 5 +++--
 man/pvdisplay.8_pregen       | 5 +++--
 man/pvmove.8_pregen          | 5 +++--
 man/pvremove.8_pregen        | 5 +++--
 man/pvresize.8_pregen        | 5 +++--
 man/pvs.8_pregen             | 5 +++--
 man/pvscan.8_pregen          | 5 +++--
 man/vgcfgbackup.8_pregen     | 5 +++--
 man/vgcfgrestore.8_pregen    | 5 +++--
 man/vgchange.8_pregen        | 5 +++--
 man/vgck.8_pregen            | 5 +++--
 man/vgconvert.8_pregen       | 5 +++--
 man/vgcreate.8_pregen        | 5 +++--
 man/vgdisplay.8_pregen       | 5 +++--
 man/vgexport.8_pregen        | 5 +++--
 man/vgextend.8_pregen        | 5 +++--
 man/vgimport.8_pregen        | 5 +++--
 man/vgimportclone.8_pregen   | 5 +++--
 man/vgimportdevices.8_pregen | 5 +++--
 man/vgmerge.8_pregen         | 5 +++--
 man/vgmknodes.8_pregen       | 5 +++--
 man/vgreduce.8_pregen        | 5 +++--
 man/vgremove.8_pregen        | 5 +++--
 man/vgrename.8_pregen        | 5 +++--
 man/vgs.8_pregen             | 5 +++--
 man/vgscan.8_pregen          | 5 +++--
 man/vgsplit.8_pregen         | 5 +++--
 45 files changed, 135 insertions(+), 90 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index babeb1b29..e46a3b9b2 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -614,8 +614,9 @@ See \fBlvm.conf\fP(5) for more information about profiles.
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
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 156ae00ce..22de7467f 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1136,8 +1136,9 @@ See \fBlvmvdo\fP(7) for more information about VDO usage.
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
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index a454d175f..efca91c19 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -1008,8 +1008,9 @@ See \fBlvmvdo\fP(7) for more information about VDO usage.
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
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 03235ef1a..b89d188de 100644
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
index 8bc2c2523..445afc25e 100644
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
index 115f50d4a..4bcfba4f8 100644
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
index 43696c1b7..bfdfafab8 100644
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
index bab5d6056..a29255cf4 100644
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
index 90d3af455..86fe7e015 100644
--- a/man/lvmdevices.8_pregen
+++ b/man/lvmdevices.8_pregen
@@ -370,8 +370,9 @@ then it will override the default type that lvm would use.
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
index 0d5fdc741..4db9c2021 100644
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
index 6c55ae158..e8953bc8f 100644
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
index 5b471f0e5..f47181213 100644
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
index 9624611d1..278e8e989 100644
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
index bacad4f46..625fed0a1 100644
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
index 8540816d3..d055851f5 100644
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
index 20a51ae99..012479618 100644
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
index 1ace1b6b4..57d1570c4 100644
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
index 3f60ff818..156e3b789 100644
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
index 043f067f7..67b5c27d0 100644
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
index 4c681c955..23d41b29b 100644
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
index ea300bb9d..28b0ea4e8 100644
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
index ce01d3398..a086724b8 100644
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
index 85078e18d..708b7d72a 100644
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
index e9f981a9e..485e651a7 100644
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
index 00743a7d4..cb837b8ca 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -383,8 +383,9 @@ messages sent to the log file and/or syslog (if configured).
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
index 0f051b75e..e732a7d43 100644
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
index 67e8ae8e8..d9d4a2a76 100644
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
index 1dafeafd0..07626ee1b 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -568,8 +568,9 @@ See \fBlvm.conf\fP(5) for more information about profiles.
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
index 76ef1a284..23bd7ea6d 100644
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
index 8fe27ca2e..cdeee39fa 100644
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
index 7b8b81885..d07741ffc 100644
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
index 3fd7e55c2..db2e48b01 100644
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
index 3709434bb..25f767bc8 100644
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
index 3ea40988a..af5679118 100644
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
index 0eb9d627d..fee109849 100644
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
index 151fa9282..87a830807 100644
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
index 3f09499e0..c030c01a5 100644
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
index 298e30868..b4be7bb24 100644
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
index f57440ef3..511d579bd 100644
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
index 759160a6c..278aa0fac 100644
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
index fa601b8cf..9e6051ade 100644
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
index 615559bb0..932a51103 100644
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
index 7c4a06d6d..0c89c5b5e 100644
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
index c0a3de185..600c2c978 100644
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
index fb217beed..b128fb8e2 100644
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

