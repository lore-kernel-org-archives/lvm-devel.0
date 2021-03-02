From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:43 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20210302215843.E77003851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9cb913ab4bf8e8e98f2f84210e4bee55d7f177a8
Commit:        9cb913ab4bf8e8e98f2f84210e4bee55d7f177a8
Parent:        8e1771f8571c54cc053b077305b886278086dd03
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 24 12:40:15 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:57:35 2021 +0100

make: generate

---
 conf/example.conf.in        | 32 ++++++++++++++++++++++++++++++++
 man/lvchange.8_pregen       | 36 ++++++++++++++++++++++++++++++++++++
 man/lvconvert.8_pregen      | 36 ++++++++++++++++++++++++++++++++++++
 man/lvcreate.8_pregen       | 36 ++++++++++++++++++++++++++++++++++++
 man/lvdisplay.8_pregen      | 28 ++++++++++++++++++++++++++++
 man/lvextend.8_pregen       | 36 ++++++++++++++++++++++++++++++++++++
 man/lvm-fullreport.8_pregen | 28 ++++++++++++++++++++++++++++
 man/lvm-lvpoll.8_pregen     | 28 ++++++++++++++++++++++++++++
 man/lvmconfig.8_pregen      | 28 ++++++++++++++++++++++++++++
 man/lvmdiskscan.8_pregen    | 28 ++++++++++++++++++++++++++++
 man/lvreduce.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/lvremove.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/lvrename.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/lvresize.8_pregen       | 36 ++++++++++++++++++++++++++++++++++++
 man/lvs.8_pregen            | 28 ++++++++++++++++++++++++++++
 man/lvscan.8_pregen         | 28 ++++++++++++++++++++++++++++
 man/pvchange.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/pvck.8_pregen           | 36 ++++++++++++++++++++++++++++++++++++
 man/pvcreate.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/pvdisplay.8_pregen      | 28 ++++++++++++++++++++++++++++
 man/pvmove.8_pregen         | 28 ++++++++++++++++++++++++++++
 man/pvremove.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/pvresize.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/pvs.8_pregen            | 28 ++++++++++++++++++++++++++++
 man/pvscan.8_pregen         | 28 ++++++++++++++++++++++++++++
 man/vgcfgbackup.8_pregen    | 28 ++++++++++++++++++++++++++++
 man/vgcfgrestore.8_pregen   | 36 ++++++++++++++++++++++++++++++++++++
 man/vgchange.8_pregen       | 36 ++++++++++++++++++++++++++++++++++++
 man/vgck.8_pregen           | 28 ++++++++++++++++++++++++++++
 man/vgconvert.8_pregen      | 28 ++++++++++++++++++++++++++++
 man/vgcreate.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/vgdisplay.8_pregen      | 28 ++++++++++++++++++++++++++++
 man/vgexport.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/vgextend.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/vgimport.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/vgimportclone.8_pregen  | 38 ++++++++++++++++++++++++++++++++++++++
 man/vgmerge.8_pregen        | 28 ++++++++++++++++++++++++++++
 man/vgmknodes.8_pregen      | 28 ++++++++++++++++++++++++++++
 man/vgreduce.8_pregen       | 36 ++++++++++++++++++++++++++++++++++++
 man/vgremove.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/vgrename.8_pregen       | 28 ++++++++++++++++++++++++++++
 man/vgs.8_pregen            | 28 ++++++++++++++++++++++++++++
 man/vgscan.8_pregen         | 28 ++++++++++++++++++++++++++++
 man/vgsplit.8_pregen        | 28 ++++++++++++++++++++++++++++
 44 files changed, 1318 insertions(+)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index fc0a16bf1..8ac376303 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -124,6 +124,38 @@ devices {
 	#
 	# This configuration option does not have a default value defined.
 
+	# Configuration option devices/use_devicesfile.
+	# Enable or disable the use of a devices file.
+	# When enabled, lvm will only use devices that
+	# are lised in the devices file. A devices file will
+	# be used, regardless of this setting, when the --devicesfile
+	# option is set to a specific file name.
+	# This configuration option has an automatic default value.
+	# use_devicesfile = 0
+
+	# Configuration option devices/devicesfile.
+	# The name of the system devices file, listing devices that LVM should use.
+	# This should not be used to select a non-system devices file.
+	# The --devicesfile option is intended for alternative devices files.
+	# This configuration option has an automatic default value.
+	# devicesfile = "system.devices"
+
+	# Configuration option devices/search_for_devnames.
+	# Look outside of the devices file for missing devname entries.
+	# A devname entry is used for a device that does not have a stable
+	# device id, e.g. wwid, so the unstable device name is used as
+	# the device id. After reboot, or if the device is reattached,
+	# the device name may change, in which case lvm will not find
+	# the expected PV on the device listed in the devices file.
+	# This setting controls whether lvm will search other devices,
+	# outside the devices file, to look for the missing PV on a
+	# renamed device. If "none", lvm will not look at other devices,
+	# and the PV may appear to be missing. If "auto", lvm will look
+	# at other devices, but only those that are likely to have the PV.
+	# If "all", lvm will look at all devices on the system.
+	# This configuration option has an automatic default value.
+	# search_for_devnames = "auto"
+
 	# Configuration option devices/filter.
 	# Limit the block devices that are used by LVM commands.
 	# This is a list of regular expressions used to accept or reject block
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index e133387af..572f84aa8 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -72,6 +72,14 @@ lvchange - Change the attributes of logical volume(s)
     \fB--detachprofile\fP
 .ad b
 .br
+.ad l
+    \fB--devices\fP \fIPV\fP
+.ad b
+.br
+.ad l
+    \fB--devicesfile\fP \fIString\fP
+.ad b
+.br
 .ad l
     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .ad b
@@ -586,6 +594,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -782,6 +798,24 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
 Specifies how the device-mapper thin pool layer in the kernel should
@@ -1192,6 +1226,7 @@ Change LV permission to read-only:
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -1214,6 +1249,7 @@ Change LV permission to read-only:
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 01fbc7154..c645d6a56 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -78,6 +78,14 @@ lvconvert - Change logical volume layout
     \fB--deduplication\fP \fBy\fP|\fBn\fP
 .ad b
 .br
+.ad l
+    \fB--devices\fP \fIPV\fP
+.ad b
+.br
+.ad l
+    \fB--devicesfile\fP \fIString\fP
+.ad b
+.br
 .ad l
     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .ad b
@@ -1146,6 +1154,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -1326,6 +1342,24 @@ See \fBlvmvdo\fP(7) for more information about VDO usage.
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
 Specifies how the device-mapper thin pool layer in the kernel should
@@ -2265,6 +2299,7 @@ Detach and remove the cache pool from a cache LV.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -2287,6 +2322,7 @@ Detach and remove the cache pool from a cache LV.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 716db5053..8f548811e 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -90,6 +90,14 @@ lvcreate - Create a logical volume
     \fB--deduplication\fP \fBy\fP|\fBn\fP
 .ad b
 .br
+.ad l
+    \fB--devices\fP \fIPV\fP
+.ad b
+.br
+.ad l
+    \fB--devicesfile\fP \fIString\fP
+.ad b
+.br
 .ad l
     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .ad b
@@ -1199,6 +1207,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -1412,6 +1428,24 @@ See \fBlvmvdo\fP(7) for more information about VDO usage.
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
 Specifies how the device-mapper thin pool layer in the kernel should
@@ -3162,6 +3196,7 @@ Create a VDO LV vdo0 with VDOPoolLV size of 10GiB and name vpool1.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -3184,6 +3219,7 @@ Create a VDO LV vdo0 with VDOPoolLV size of 10GiB and name vpool1.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 9751b7656..e19447c58 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -154,6 +154,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -245,6 +253,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -509,6 +535,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -531,6 +558,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 3dd4d0f3f..4ccfa809b 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -30,6 +30,14 @@ lvextend - Add space to a logical volume
  \fB-d\fP|\fB--debug\fP
 .ad b
 .br
+.ad l
+    \fB--devices\fP \fIPV\fP
+.ad b
+.br
+.ad l
+    \fB--devicesfile\fP \fIString\fP
+.ad b
+.br
 .ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
@@ -316,6 +324,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -393,6 +409,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -678,6 +712,7 @@ Extend an LV by 16MiB using specific physical extents.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -700,6 +735,7 @@ Extend an LV by 16MiB using specific physical extents.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index b6212a6f0..7fb7d046d 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -146,6 +146,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -220,6 +228,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -474,6 +500,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -496,6 +523,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index bbfa1216d..87af9b925 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -72,6 +72,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -134,6 +142,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -289,6 +315,7 @@ Continue thin snapshot merge.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -311,6 +338,7 @@ Continue thin snapshot merge.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index b2ab265ca..afb890cc3 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -141,6 +141,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -202,6 +210,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -481,6 +507,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -503,6 +530,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index 62dc2afdd..d47514027 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -67,6 +67,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -116,6 +124,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -233,6 +259,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -255,6 +282,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 9e3dbfe87..4fcc08f99 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -98,6 +98,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -154,6 +162,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -340,6 +366,7 @@ Reduce the size of an LV by 3 logical extents:
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -362,6 +389,7 @@ Reduce the size of an LV by 3 logical extents:
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index 4635ec77c..b53b871cc 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -102,6 +102,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -158,6 +166,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -334,6 +360,7 @@ Remove all LVs the specified VG.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -356,6 +383,7 @@ Remove all LVs the specified VG.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 1cfc887a8..0a468aed3 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -77,6 +77,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -133,6 +141,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -271,6 +297,7 @@ An alternate syntax to rename "lvold" to "lvnew":
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -293,6 +320,7 @@ An alternate syntax to rename "lvold" to "lvnew":
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 83b060d86..528066154 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -30,6 +30,14 @@ lvresize - Resize a logical volume
  \fB-d\fP|\fB--debug\fP
 .ad b
 .br
+.ad l
+    \fB--devices\fP \fIPV\fP
+.ad b
+.br
+.ad l
+    \fB--devicesfile\fP \fIString\fP
+.ad b
+.br
 .ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
@@ -264,6 +272,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -341,6 +357,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -604,6 +638,7 @@ Extend an LV by 16MB using specific physical extents:
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -626,6 +661,7 @@ Extend an LV by 16MB using specific physical extents:
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 57b3736f9..8351aeea2 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -150,6 +150,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -227,6 +235,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -587,6 +613,7 @@ s(k)ip activation: this volume is flagged to be skipped during activation.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -609,6 +636,7 @@ s(k)ip activation: this volume is flagged to be skipped during activation.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 0b782fedf..03c7806e2 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -77,6 +77,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -140,6 +148,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -269,6 +295,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -291,6 +318,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 234a114a9..ccf7a613d 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -134,6 +134,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -216,6 +224,24 @@ multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -384,6 +410,7 @@ disk errors, or because it will be removed after freeing it).
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -406,6 +433,7 @@ disk errors, or because it will be removed after freeing it).
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index eac6634ce..76671a515 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -20,6 +20,14 @@ pvck - Check metadata on physical volumes
  \fB-d\fP|\fB--debug\fP
 .ad b
 .br
+.ad l
+    \fB--devices\fP \fIPV\fP
+.ad b
+.br
+.ad l
+    \fB--devicesfile\fP \fIString\fP
+.ad b
+.br
 .ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
@@ -342,6 +350,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -391,6 +407,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -568,6 +602,7 @@ parameter with a value of 204800 (100 * 1024 * 1024 / 512 = 204800).
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -590,6 +625,7 @@ parameter with a value of 204800 (100 * 1024 * 1024 / 512 = 204800).
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index 781762521..b43dbdd16 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -190,6 +190,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -271,6 +279,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -503,6 +529,7 @@ boundary) manually account for this when initializing for use by LVM.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -525,6 +552,7 @@ boundary) manually account for this when initializing for use by LVM.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 7c4500131..b560f9de2 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -150,6 +150,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -240,6 +248,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -496,6 +522,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -518,6 +545,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index a34271ff8..0fc745009 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -125,6 +125,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -226,6 +234,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -459,6 +485,7 @@ extents can also be picked out and moved.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -481,6 +508,7 @@ extents can also be picked out and moved.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 784fcbe12..802e1d4a1 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -67,6 +67,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -116,6 +124,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -244,6 +270,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -266,6 +293,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index fc79a3a5f..01cbc099f 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -62,6 +62,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -111,6 +119,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -251,6 +277,7 @@ appropriate for the intended new partition size).
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -273,6 +300,7 @@ appropriate for the intended new partition size).
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index d85ae6cda..cb43845d2 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -146,6 +146,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -222,6 +230,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -504,6 +530,7 @@ e(x)ported
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -526,6 +553,7 @@ e(x)ported
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 27e1a773e..b604f9328 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -174,6 +174,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -236,6 +244,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -409,6 +435,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -431,6 +458,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index 6401ee4fb..8f662a7ad 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -93,6 +93,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -142,6 +150,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -290,6 +316,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -312,6 +339,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index a174d7642..43d863541 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -22,6 +22,14 @@ vgcfgrestore - Restore volume group configuration
  \fB-d\fP|\fB--debug\fP
 .ad b
 .br
+.ad l
+    \fB--devices\fP \fIPV\fP
+.ad b
+.br
+.ad l
+    \fB--devicesfile\fP \fIString\fP
+.ad b
+.br
 .ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
@@ -189,6 +197,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -238,6 +254,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -383,6 +417,7 @@ missing PV. Repeat for all other missing PVs in the VG.  Then use
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -405,6 +440,7 @@ missing PV. Repeat for all other missing PVs in the VG.  Then use
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 9016e76dd..cb3c3500a 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -50,6 +50,14 @@ vgchange - Change volume group attributes
     \fB--detachprofile\fP
 .ad b
 .br
+.ad l
+    \fB--devices\fP \fIPV\fP
+.ad b
+.br
+.ad l
+    \fB--devicesfile\fP \fIString\fP
+.ad b
+.br
 .ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
@@ -605,6 +613,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -742,6 +758,24 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -1103,6 +1137,7 @@ Change the maximum number of LVs for an inactive VG.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -1125,6 +1160,7 @@ Change the maximum number of LVs for an inactive VG.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 9226dc4a6..13f7a1eb9 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -80,6 +80,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -129,6 +137,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -264,6 +290,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -286,6 +313,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 09b6f1d31..ab7c083e9 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -82,6 +82,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -148,6 +156,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -307,6 +333,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -329,6 +356,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index adef80999..91fa6a67e 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -146,6 +146,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -253,6 +261,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -514,6 +540,7 @@ Create a VG with two PVs, using the default physical extent size.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -536,6 +563,7 @@ Create a VG with two PVs, using the default physical extent size.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index f7db557b7..559d64c25 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -145,6 +145,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -235,6 +243,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -479,6 +505,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -501,6 +528,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index a9a9dc6fb..e88d91922 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -96,6 +96,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -150,6 +158,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -289,6 +315,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -311,6 +338,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index 40a34d9e0..1aef95d6e 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -111,6 +111,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -183,6 +191,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -380,6 +406,7 @@ Add two PVs to a VG.
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -402,6 +429,7 @@ Add two PVs to a VG.
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index b82a1847e..2592fb4d9 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -86,6 +86,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -141,6 +149,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -287,6 +313,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -309,6 +336,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index 8cb048ffa..8e0144655 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -26,6 +26,10 @@ changes the associated VG and PV UUIDs.
 [ \fB-i\fP|\fB--import\fP ]
 .ad b
 .br
+.ad l
+[    \fB--importdevices\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -66,6 +70,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -125,6 +137,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -145,6 +175,12 @@ will not be changed (nor will their associated PVs).
 .ad b
 .HP
 .ad l
+\fB--importdevices\fP
+.br
+Add devices to the devices file.
+.ad b
+.HP
+.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
@@ -250,6 +286,7 @@ Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_sna
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -272,6 +309,7 @@ Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_sna
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index 03aa096eb..b555a8365 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -63,6 +63,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -119,6 +127,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -235,6 +261,7 @@ Merge an inactive VG named "vg00" into the active or inactive VG named
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -257,6 +284,7 @@ Merge an inactive VG named "vg00" into the active or inactive VG named
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 4243b0923..66c16a9f6 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -74,6 +74,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -123,6 +131,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -264,6 +290,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -286,6 +313,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index 1f1d8d94e..6aded0070 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -28,6 +28,14 @@ vgreduce - Remove physical volume(s) from a volume group
  \fB-d\fP|\fB--debug\fP
 .ad b
 .br
+.ad l
+    \fB--devices\fP \fIPV\fP
+.ad b
+.br
+.ad l
+    \fB--devicesfile\fP \fIString\fP
+.ad b
+.br
 .ad l
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .ad b
@@ -179,6 +187,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -241,6 +257,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -394,6 +428,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -416,6 +451,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index c715742ad..f78f9b476 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -77,6 +77,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -126,6 +134,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -281,6 +307,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -303,6 +330,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index b9ac143e5..3444a64ac 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -90,6 +90,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -146,6 +154,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -277,6 +303,7 @@ Rename the VG with the specified UUID to "myvg".
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -299,6 +326,7 @@ Rename the VG with the specified UUID to "myvg".
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index f50e43fbd..29ed39e2a 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -142,6 +142,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -217,6 +225,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -492,6 +518,7 @@ Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -514,6 +541,7 @@ Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 5d329f921..1772a450d 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -69,6 +69,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -118,6 +126,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -251,6 +277,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -273,6 +300,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 9731aa4fa..fe680982d 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -107,6 +107,14 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--devices\fP \fIPV\fP ]
+.ad b
+.br
+.ad l
+[    \fB--devicesfile\fP \fIString\fP ]
+.ad b
+.br
+.ad l
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .ad b
 .br
@@ -184,6 +192,24 @@ messages sent to the log file and/or syslog (if configured).
 .ad b
 .HP
 .ad l
+\fB--devices\fP \fIPV\fP
+.br
+Devices that the command can use. This option can be repeated
+or accepts a comma separated list of devices. This overrides
+the devices file.
+.ad b
+.HP
+.ad l
+\fB--devicesfile\fP \fIString\fP
+.br
+A file listing devices that LVM should use.
+The file must exist in /etc/lvm/devices/ and is managed
+with the lvmdevices(8) command.
+This overrides the lvm.conf devices/devicesfile and
+devices/use_devicesfile settings.
+.ad b
+.HP
+.ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
 If set to no, the command will not attempt to use device-mapper.
@@ -345,6 +371,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -367,6 +394,7 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)


