From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 21:37:13 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20211014213713.1A0C03858419@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae92888a7baf3f1882168a6084eca23c9b85b998
Commit:        ae92888a7baf3f1882168a6084eca23c9b85b998
Parent:        0bd5388b16e2a14285ecd91ebf9f5537b5b303cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 14 22:41:48 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 14 23:34:11 2021 +0200

make: generate

---
 conf/example.conf.in | 10 ++--------
 man/pvscan.8_pregen  |  2 ++
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 1f7c449bf..a78ed7333 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -126,7 +126,7 @@ devices {
 	# be used, regardless of this setting, when the --devicesfile
 	# option is set to a specific file name.
 	# This configuration option has an automatic default value.
-	# use_devicesfile = 1
+	# use_devicesfile = 0
 
 	# Configuration option devices/devicesfile.
 	# The name of the system devices file, listing devices that LVM should use.
@@ -236,12 +236,6 @@ devices {
 	# This configuration option has an automatic default value.
 	# multipath_wwids_file = "/etc/multipath/wwids"
 
-	# Configuration option devices/multipath_wwids_file.
-	# The path to the multipath wwids file used for multipath component detection.
-	# Set this to an empty string to disable the use of the multipath wwids file.
-	# This configuration option has an automatic default value.
-	# multipath_wwids_file = "/etc/multipath/wwids"
-
 	# Configuration option devices/md_component_detection.
 	# Enable detection and exclusion of MD component devices.
 	# An MD component device is a block device that MD uses as part
@@ -842,7 +836,7 @@ log {
 	# Configuration option log/syslog.
 	# Send log messages through syslog.
 	# This configuration option has an automatic default value.
-	# syslog = 1
+	# syslog = 0
 
 	# Configuration option log/file.
 	# Write error and debug log messages to a file specified here.
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index a15138d8b..9eb6b5bf9 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -51,6 +51,8 @@ pvscan \(em List all physical volumes
  \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
     \fB--minor\fP \fINumber\fP
+.br
+    \fB--nohints\fP
 .br
     \fB--nolocking\fP
 .br


