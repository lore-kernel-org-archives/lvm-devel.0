From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 17:38:36 -0400
Subject: master - build: make generate
Message-ID: <201806222138.w5MLcawG018622@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=086f1ef4a0f59ee247067e850b9b9ef0cdf5b1c3
Commit:        086f1ef4a0f59ee247067e850b9b9ef0cdf5b1c3
Parent:        254e5c5d119447bcb8b160a4b4e5b0c36e9af5ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 19 15:07:50 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 15:36:34 2018 +0200

build: make generate

---
 conf/example.conf.in        |   33 +++++----------------------------
 man/lvchange.8_pregen       |   15 ---------------
 man/lvdisplay.8_pregen      |   11 -----------
 man/lvm-fullreport.8_pregen |   11 -----------
 man/lvs.8_pregen            |   11 -----------
 man/pvchange.8_pregen       |   11 -----------
 man/pvdisplay.8_pregen      |   11 -----------
 man/pvs.8_pregen            |   11 -----------
 man/vgchange.8_pregen       |   31 -------------------------------
 man/vgconvert.8_pregen      |    9 +++++----
 man/vgdisplay.8_pregen      |   11 -----------
 man/vgs.8_pregen            |   11 -----------
 12 files changed, 10 insertions(+), 166 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 97daab2..83f9f42 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -151,21 +151,15 @@ devices {
 	# global_filter = [ "a|.*/|" ]
 
 	# Configuration option devices/cache_dir.
-	# Directory in which to store the device cache file.
-	# The results of filtering are cached on disk to avoid rescanning dud
-	# devices (which can take a very long time). By default this cache is
-	# stored in a file named .cache. It is safe to delete this file; the
-	# tools regenerate it. If obtain_device_list_from_udev is enabled, the
-	# list of devices is obtained from udev and any existing .cache file
-	# is removed.
+	# This setting is no longer used.
 	cache_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@"
 
 	# Configuration option devices/cache_file_prefix.
-	# A prefix used before the .cache file name. See devices/cache_dir.
+	# This setting is no longer used.
 	cache_file_prefix = ""
 
 	# Configuration option devices/write_cache_state.
-	# Enable/disable writing the cache file. See devices/cache_dir.
+	# This setting is no longer used.
 	write_cache_state = 1
 
 	# Configuration option devices/types.
@@ -269,11 +263,7 @@ devices {
 	ignore_lvm_mirrors = 1
 
 	# Configuration option devices/disable_after_error_count.
-	# Number of I/O errors after which a device is skipped.
-	# During each LVM operation, errors received from each device are
-	# counted. If the counter of a device exceeds the limit set here,
-	# no further I/O is sent to that device for the remainder of the
-	# operation. Setting this to 0 disables the counters altogether.
+	# This setting is no longer used.
 	disable_after_error_count = 0
 
 	# Configuration option devices/require_restorefile_with_uuid.
@@ -1557,20 +1547,7 @@ activation {
 	# stripesize = 64
 
 	# Configuration option metadata/dirs.
-	# Directories holding live copies of text format metadata.
-	# These directories must not be on logical volumes!
-	# It's possible to use LVM with a couple of directories here,
-	# preferably on different (non-LV) filesystems, and with no other
-	# on-disk metadata (pvmetadatacopies = 0). Or this can be in addition
-	# to on-disk metadata areas. The feature was originally added to
-	# simplify testing and is not supported under low memory situations -
-	# the machine could lock up. Never edit any files in these directories
-	# by hand unless you are absolutely sure you know what you are doing!
-	# Use the supplied toolset to make changes (e.g. vgcfgrestore).
-	# 
-	# Example
-	# dirs = [ "/etc/lvm/metadata", "/mnt/disk2/lvm/metadata2" ]
-	# 
+	# This setting is no longer used.
 	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
 # }
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 8f9783a..03e0b1c 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -97,10 +97,6 @@ lvchange - Change the attributes of logical volume(s)
 .ad b
 .br
 .ad l
-    \fB--ignoreskippedcluster\fP
-.ad b
-.br
-.ad l
     \fB--lockopt\fP \fIString\fP
 .ad b
 .br
@@ -520,10 +516,6 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--noudevsync\fP ]
 .ad b
 .br
@@ -818,13 +810,6 @@ Do not use this if dmeventd is already monitoring a device.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and clustered VGs are skipped.
-.ad b
-.HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 6211a47..9a8962b 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -72,10 +72,6 @@ and more, using a more compact and configurable output format.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--logonly\fP ]
 .ad b
 .br
@@ -284,13 +280,6 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and clustered VGs are skipped.
-.ad b
-.HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 4a8d7b3..111b8ef 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -56,10 +56,6 @@ if information changes between commands.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--logonly\fP ]
 .ad b
 .br
@@ -255,13 +251,6 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and clustered VGs are skipped.
-.ad b
-.HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index b5128f9..fecca99 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -60,10 +60,6 @@ lvs produces formatted output about LVs.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--logonly\fP ]
 .ad b
 .br
@@ -270,13 +266,6 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and clustered VGs are skipped.
-.ad b
-.HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 5da8eca..8c9288d 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -98,10 +98,6 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
 .RE
@@ -244,13 +240,6 @@ Display help text.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and clustered VGs are skipped.
-.ad b
-.HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 5f39e7b..9dbcac3 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -72,10 +72,6 @@ and more, using a more compact and configurable output format.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--logonly\fP ]
 .ad b
 .br
@@ -271,13 +267,6 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and clustered VGs are skipped.
-.ad b
-.HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 59f1e3d..53c259c 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -56,10 +56,6 @@ pvs produces formatted output about PVs.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--logonly\fP ]
 .ad b
 .br
@@ -257,13 +253,6 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and clustered VGs are skipped.
-.ad b
-.HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index a9ac546..94dbd88 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -75,10 +75,6 @@ vgchange - Change volume group attributes
 .ad b
 .br
 .ad l
-    \fB--ignoreskippedcluster\fP
-.ad b
-.br
-.ad l
     \fB--lockopt\fP \fIString\fP
 .ad b
 .br
@@ -279,10 +275,6 @@ required, after which the others are optional.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--noudevsync\fP ]
 .ad b
 .br
@@ -333,10 +325,6 @@ Start or stop monitoring LVs from dmeventd.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--noudevsync\fP ]
 .ad b
 .br
@@ -379,10 +367,6 @@ Start or stop processing LV conversions.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--noudevsync\fP ]
 .ad b
 .br
@@ -449,10 +433,6 @@ Activate or deactivate LVs.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--noudevsync\fP ]
 .ad b
 .br
@@ -503,10 +483,6 @@ Reactivate LVs using the latest metadata.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--noudevsync\fP ]
 .ad b
 .br
@@ -800,13 +776,6 @@ Do not use this if dmeventd is already monitoring a device.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and clustered VGs are skipped.
-.ad b
-.HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 16e1fc8..b2a6027 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -8,9 +8,9 @@ vgconvert - Change volume group metadata format
     [ \fIoption_args\fP ]
 .br
 .SH DESCRIPTION
-vgconvert converts VG metadata from one format to another.  This command
-is no longer used because this version of lvm no longer supports the LVM1
-format.
+vgconvert is no longer a part of LVM.  It was removed along with
+support for the LVM1 format.  Use an older version of LVM to
+convert VGs from the LVM1 format to LVM2.
 .SH USAGE
 \fBvgconvert\fP \fIVG\fP ...
 .br
@@ -46,7 +46,6 @@ format.
 [ COMMON_OPTIONS ]
 .RE
 .br
-
 Common options for lvm:
 .
 .RS 4
@@ -106,6 +105,7 @@ Common options for lvm:
 [    \fB--version\fP ]
 .ad b
 .RE
+
 .SH OPTIONS
 .HP
 .ad l
@@ -301,6 +301,7 @@ capital letters mean multiple of 1000.)
 .SH ENVIRONMENT VARIABLES
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
+
 .SH SEE ALSO
 
 .BR lvm (8)
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 89e3603..7c8fb12 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -67,10 +67,6 @@ and more, using a more compact and configurable output format.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--logonly\fP ]
 .ad b
 .br
@@ -266,13 +262,6 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and clustered VGs are skipped.
-.ad b
-.HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index 681711b..c8a9611 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -52,10 +52,6 @@ vgs produces formatted output about VGs.
 .ad b
 .br
 .ad l
-[    \fB--ignoreskippedcluster\fP ]
-.ad b
-.br
-.ad l
 [    \fB--logonly\fP ]
 .ad b
 .br
@@ -252,13 +248,6 @@ operations after locking failures.
 .ad b
 .HP
 .ad l
-\fB--ignoreskippedcluster\fP
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and clustered VGs are skipped.
-.ad b
-.HP
-.ad l
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.


