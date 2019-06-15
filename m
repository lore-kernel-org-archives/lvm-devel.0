From: Marian Csontos <mcsontos@sourceware.org>
Date: Sat, 15 Jun 2019 03:34:34 -0400
Subject: master - build: make generate
Message-ID: <201906150734.x5F7YYmc032571@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4ff865b44f47fc36e90505fd891dcf4d297c408
Commit:        b4ff865b44f47fc36e90505fd891dcf4d297c408
Parent:        9f5e46965bd3e967de8c3b6741f2b7f178192a53
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Sat Jun 15 08:30:04 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Sat Jun 15 08:30:04 2019 +0200

build: make generate

---
 conf/example.conf.in        |   27 ++++++++++++++++++++++++++-
 man/lvm-fullreport.8_pregen |   10 ----------
 man/lvs.8_pregen            |   10 ----------
 man/pvchange.8_pregen       |    6 +-----
 man/pvs.8_pregen            |   10 ----------
 man/vgck.8_pregen           |   26 +++++++++++++++++++++++++-
 man/vgs.8_pregen            |   10 ----------
 7 files changed, 52 insertions(+), 47 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index a5eba01..154f621 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -201,9 +201,34 @@ devices {
 	multipath_component_detection = 1
 
 	# Configuration option devices/md_component_detection.
-	# Ignore devices that are components of software RAID (md) devices.
+	# Enable detection and exclusion of MD component devices.
+	# An MD component device is a block device that MD uses as part
+	# of a software RAID virtual device. When an LVM PV is created
+	# on an MD device, LVM must only use the top level MD device as
+	# the PV, and should ignore the underlying component devices.
+	# In cases where the MD superblock is located at the end of the
+	# component devices, it is more difficult for LVM to consistently
+	# identify an MD component, see the md_component_checks setting.
 	md_component_detection = 1
 
+	# Configuration option devices/md_component_checks.
+	# The checks LVM should use to detect MD component devices.
+	# MD component devices are block devices used by MD software RAID.
+	# 
+	# Accepted values:
+	#   auto
+	#     LVM will skip scanning the end of devices when it has other
+	#     indications that the device is not an MD component.
+	#   start
+	#     LVM will only scan the start of devices for MD superblocks.
+	#     This does not incur extra I/O by LVM.
+	#   full
+	#     LVM will scan the start and end of devices for MD superblocks.
+	#     This requires an extra read at the end of devices.
+	# 
+	# This configuration option has an automatic default value.
+	# md_component_checks = "auto"
+
 	# Configuration option devices/fw_raid_component_detection.
 	# Ignore devices that are components of firmware RAID devices.
 	# LVM must use an external_device_info_source other than none for this
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 1170dc7..07e618a 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -92,10 +92,6 @@ if information changes between commands.
 .ad b
 .br
 .ad l
-[    \fB--trustcache\fP ]
-.ad b
-.br
-.ad l
 [    \fB--unbuffered\fP ]
 .ad b
 .br
@@ -406,12 +402,6 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--trustcache\fP
-.br
-Avoids certain device scanning during command processing. Do not use.
-.ad b
-.HP
-.ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index c92ba14..8c3091d 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -96,10 +96,6 @@ lvs produces formatted output about LVs.
 .ad b
 .br
 .ad l
-[    \fB--trustcache\fP ]
-.ad b
-.br
-.ad l
 [    \fB--unbuffered\fP ]
 .ad b
 .br
@@ -427,12 +423,6 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--trustcache\fP
-.br
-Avoids certain device scanning during command processing. Do not use.
-.ad b
-.HP
-.ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index c21ce70..33c63dc 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -16,7 +16,7 @@ others are optional.
 Change properties of all PVs.
 .br
 .P
-\fBpvchange\fP
+\fBpvchange\fP \fB-a\fP|\fB--all\fP
 .RS 4
 ( \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP,
 .ad b
@@ -26,10 +26,6 @@ Change properties of all PVs.
 .ad b
 .br
 .ad l
-  \fB-a\fP|\fB--all\fP,
-.ad b
-.br
-.ad l
      \fB--addtag\fP \fITag\fP,
 .ad b
 .br
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 1902f29..596f593 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -92,10 +92,6 @@ pvs produces formatted output about PVs.
 .ad b
 .br
 .ad l
-[    \fB--trustcache\fP ]
-.ad b
-.br
-.ad l
 [    \fB--unbuffered\fP ]
 .ad b
 .br
@@ -416,12 +412,6 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--trustcache\fP
-.br
-Avoids certain device scanning during command processing. Do not use.
-.ad b
-.HP
-.ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 4f2a866..a66de5d 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -3,7 +3,7 @@
 vgck - Check the consistency of volume group(s)
 .
 .SH SYNOPSIS
-\fBvgck\fP
+\fBvgck\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
@@ -12,6 +12,9 @@ vgck - Check the consistency of volume group(s)
 .SH DESCRIPTION
 vgck checks LVM metadata for consistency.
 .SH USAGE
+Read and display information about a VG.
+.br
+.P
 \fBvgck\fP
 .br
 .RS 4
@@ -26,6 +29,21 @@ vgck checks LVM metadata for consistency.
 [ \fIVG\fP|\fITag\fP ... ]
 .RE
 
+Rewrite VG metadata to correct problems.
+.br
+.P
+\fBvgck\fP \fB--updatemetadata\fP \fIVG\fP
+.br
+.RS 4
+[ COMMON_OPTIONS ]
+.RE
+.br
+
+Common options for command:
+.
+.RS 4
+.RE
+
 Common options for lvm:
 .
 .RS 4
@@ -178,6 +196,12 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
+\fB--updatemetadata\fP
+.br
+Update VG metadata to correct problems.
+.ad b
+.HP
+.ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index 7ba7b8c..8726909 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -88,10 +88,6 @@ vgs produces formatted output about VGs.
 .ad b
 .br
 .ad l
-[    \fB--trustcache\fP ]
-.ad b
-.br
-.ad l
 [    \fB--unbuffered\fP ]
 .ad b
 .br
@@ -403,12 +399,6 @@ back metadata it believes has changed but hasn't.
 .ad b
 .HP
 .ad l
-\fB--trustcache\fP
-.br
-Avoids certain device scanning during command processing. Do not use.
-.ad b
-.HP
-.ad l
 \fB--unbuffered\fP
 .br
 Produce output immediately without sorting or aligning the columns properly.


