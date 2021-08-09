From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon,  9 Aug 2021 14:27:14 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20210809142714.C61E1385C411@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b328cfee5288c14e771404821baa646b5f378a3c
Commit:        b328cfee5288c14e771404821baa646b5f378a3c
Parent:        d0ab5bf7f98da83cd5d7ec393554dff309482cf4
Author:        root <root@bot-frawhide-x86-64.lab.eng.brq.redhat.com>
AuthorDate:    Thu Aug 5 21:38:43 2021 +0200
Committer:     root <root@bot-frawhide-x86-64.lab.eng.brq.redhat.com>
CommitterDate: Thu Aug 5 21:38:43 2021 +0200

make: generate

---
 conf/example.conf.in | 28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 50cf6f42b..2dc6dd9e6 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -67,25 +67,13 @@ devices {
 	# setting applies only to the udev-managed device directory; other
 	# directories will be scanned fully. LVM needs to be compiled with
 	# udev support for this setting to apply.
-	obtain_device_list_from_udev = 1
+	obtain_device_list_from_udev = 0
 
 	# Configuration option devices/external_device_info_source.
-	# Select an external device information source.
-	# Some information may already be available in the system and LVM can
-	# use this information to determine the exact type or use of devices it
-	# processes. Using an existing external device information source can
-	# speed up device processing as LVM does not need to run its own native
-	# routines to acquire this information. For example, this information
-	# is used to drive LVM filtering like MD component detection, multipath
-	# component detection, partition detection and others.
-	#
-	# Accepted values:
-	#   none
-	#     No external device information source is used.
-	#   udev
-	#     Reuse existing udev database records. Applicable only if LVM is
-	#     compiled with udev support.
-	#
+	# Enable device information from udev.
+	# If set to "udev", lvm will supplement its own native device information
+	# with information from libudev. This can potentially improve the detection
+	# of MD component devices and multipath component devices.
 	external_device_info_source = "none"
 
 	# Configuration option devices/hints.
@@ -232,6 +220,12 @@ devices {
 	# Ignore devices that are components of DM multipath devices.
 	multipath_component_detection = 1
 
+	# Configuration option devices/multipath_wwids_file.
+	# The path to the multipath wwids file used for multipath component detection.
+	# Set this to an empty string to disable the use of the multipath wwids file.
+	# This configuration option has an automatic default value.
+	# multipath_wwids_file = "/etc/multipath/wwids"
+
 	# Configuration option devices/md_component_detection.
 	# Enable detection and exclusion of MD component devices.
 	# An MD component device is a block device that MD uses as part


