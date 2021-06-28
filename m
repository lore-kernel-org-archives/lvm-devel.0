From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jun 2021 18:42:30 +0000 (GMT)
Subject: master - make: generate
Message-ID: <20210628184230.01A3B398902D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=580e64e93ba469b64cf11e400c4cb2f759eaf579
Commit:        580e64e93ba469b64cf11e400c4cb2f759eaf579
Parent:        2c6a2b6e86b57aeb96e93618193426ee129b00a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 28 18:10:41 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 28 20:41:07 2021 +0200

make: generate

---
 man/lvconvert.8_pregen  |  2 +-
 man/lvmdevices.8_pregen | 86 +++++++++++++++++++++++++++++++++++++------------
 man/vgchange.8_pregen   |  7 ----
 man/vgck.8_pregen       |  7 ----
 4 files changed, 66 insertions(+), 36 deletions(-)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index d733ab64f..4fafe5d29 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -670,7 +670,7 @@ Convert LV to type thin-pool.
 .RE
 .P
 .RS 4
-LV1 types: linear striped cache raid error zero
+LV1 types: linear striped cache raid error zero writecache
 .RE
 .P
 \(em
diff --git a/man/lvmdevices.8_pregen b/man/lvmdevices.8_pregen
index 267ce965f..e581a8d01 100644
--- a/man/lvmdevices.8_pregen
+++ b/man/lvmdevices.8_pregen
@@ -27,6 +27,8 @@ lvmdevices \(em Manage the devices file
     \fB--deldev\fP \fIPV\fP
 .br
     \fB--delpvid\fP \fIString\fP
+.br
+    \fB--deviceidtype\fP \fIString\fP
 .br
     \fB--devices\fP \fIPV\fP
 .br
@@ -70,18 +72,18 @@ remove it from the devices file with lvmdevices --deldev.  The
 vgimportdevices(8) command adds all PVs from a VG to the devices file,
 and updates the VG metadata to include device IDs of the PVs.
 .P
-Commands adding new devices to the devices file necessarily look outside
-the existing devices file to find the devices to add.  pvcreate, vgcreate,
-and vgextend also look outside the devices file to create new PVs and add
-them to the devices file.
+Commands that add new devices to the devices file necessarily look outside
+the existing devices file to find the devices being added.  pvcreate,
+vgcreate, and vgextend also look outside the devices file to create new
+PVs and add those PVs to the devices file.
 .P
 LVM records devices in the devices file using hardware-specific IDs, such
 as the WWID, and attempts to use subsystem-specific IDs for virtual device
-types (which also aim to be as unique and stable as possible.)
-These device IDs are also written in the VG metadata.  When no hardware or
+types (which also aim to be as unique and stable as possible.) These
+device IDs are also written in the VG metadata.  When no hardware or
 virtual ID is available, lvm falls back using the unstable device name as
-the device ID.  When devnames are used, lvm performs extra scanning to
-find devices if their devname changes, e.g. after reboot.
+the device ID.  When devnames are used as IDs, lvm performs extra scanning
+to find devices if their devname changes, e.g. after reboot.
 .P
 When proper device IDs are used, an lvm command will not look at devices
 outside the devices file, but when devnames are used as a fallback, lvm
@@ -95,12 +97,13 @@ overriding the devices file.  The listed devices act as a sort of devices
 file in terms of limiting which devices lvm will see and use.  Devices
 that are not listed will appear to be missing to the lvm command.
 .P
-Multiple devices files can be kept in \fI#DEFAULT_SYS_DIR#/devices\fP, which allows lvm
-to be used with different sets of devices, e.g. system devices do not need
-to be exposed to a specific application, and the application can use lvm on
-its own devices that are not exposed to the system.  The option
---devicesfile <filename> is used to select the devices file to use with the
-command.  Without the option set, the default system devices file is used.
+Multiple devices files can be kept \fI#DEFAULT_SYS_DIR#/devices\fP, which
+allows lvm to be used with different sets of devices.  For example, system
+devices do not need to be exposed to a specific application, and the
+application can use lvm on its own devices that are not exposed to the
+system.  The option --devicesfile <filename> is used to select the devices
+file to use with the command.  Without the option set, the default system
+devices file is used.
 .P
 Setting --devicesfile "" causes lvm to not use a devices file.
 .P
@@ -120,6 +123,45 @@ if it does not yet exist.
 .P
 It is recommended to use lvm commands to make changes to the devices file to
 ensure proper updates.
+.P
+The device ID and device ID type are included in the VG metadata and can
+be reported with pvs -o deviceid,deviceidtype.  (Note that the lvmdevices
+command does not update VG metadata, but subsequent lvm commands modifying
+the metadata will include the device ID.)
+.P
+Possible device ID types are:
+.br
+.IP \[bu] 2
+.B sys_wwid
+uses the wwid reported by sysfs.  This is the first choice for non-virtual
+devices.
+.IP \[bu] 2
+.B sys_serial
+uses the serial number reported by sysfs.  This is the second choice for
+non-virtual devices.
+.IP \[bu] 2
+.B mpath_uuid
+is used for dm multipath devices, reported by sysfs.
+.IP \[bu] 2
+.B crypt_uuid
+is used for dm crypt devices, reported by sysfs.
+.IP \[bu] 2
+.B md_uuid
+is used for md devices, reported by sysfs.
+.B lvmlv_uuid
+is used if a PV is placed on top of an lvm LV, reported by sysfs.
+.IP \[bu] 2
+.B loop_file
+is used for loop devices, the backing file name repored by sysfs.
+.IP \[bu] 2
+.B devname
+the device name is used if no other type applies.
+.P
+
+The default choice for device ID type can be overriden using lvmdevices
+--addev --deviceidtype <type>.  If the specified type is available for the
+device it will be used, otherwise the device will be added using the type
+that would otherwise be chosen.
 .
 .SH USAGE
 .
@@ -169,6 +211,8 @@ Add a device to the devices file.
 .br
 .RS 4
 .ad l
+[    \fB--deviceidtype\fP \fIString\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -214,13 +258,6 @@ Remove the devices file entry for the given PVID.
 .P
 \(em
 .P
-Common options for command:
-.
-.RS 4
-.ad l
-.ad b
-.RE
-.P
 Common options for lvm:
 .
 .RS 4
@@ -308,6 +345,13 @@ Remove a device from the devices file.
 Remove a device with the PVID from the devices file.
 .
 .HP
+\fB--deviceidtype\fP \fIString\fP
+.br
+The type of device ID to use for the device.
+If the specified type is available for the device,
+then it will override the default type that lvm would use.
+.
+.HP
 \fB--devices\fP \fIPV\fP
 .br
 Devices that the command can use. This option can be repeated
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 857dabf04..31fc458da 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -393,13 +393,6 @@ Change the lock type for a shared VG.
 .P
 \(em
 .P
-Common options for command:
-.
-.RS 4
-.ad l
-.ad b
-.RE
-.P
 Common options for lvm:
 .
 .RS 4
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index f177dfbdd..ae312424a 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -46,13 +46,6 @@ Rewrite VG metadata to correct problems.
 .ad b
 .RE
 .P
-Common options for command:
-.
-.RS 4
-.ad l
-.ad b
-.RE
-.P
 Common options for lvm:
 .
 .RS 4


