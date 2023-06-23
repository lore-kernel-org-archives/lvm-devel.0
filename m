From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2023 16:09:48 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20230623160948.37E313858C36@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9756824f6447fb8c6096760e802d4f616929f710
Commit:        9756824f6447fb8c6096760e802d4f616929f710
Parent:        46fe47b8e0ad8069bb3736d2aa3e78befdccb38d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 11:39:46 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:08:10 2023 +0200

make: generate

---
 conf/example.conf.in  | 28 +++++++++++++++++++++++++++-
 man/lvcreate.8_pregen |  6 ++++++
 2 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 0b9b06a17..35837c013 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1201,7 +1201,7 @@ global {
 
 	# Configuration option global/thin_check_executable.
 	# The full path to the thin_check command.
-	# LVM uses this command to check that a thin metadata device is in a
+	# LVM uses this command to check that a thin pool metadata device is in a
 	# usable state. When a thin pool is activated and after it is
 	# deactivated, this command is run. Activation will only proceed if
 	# the command has an exit status of 0. Set to "" to skip this check.
@@ -1225,6 +1225,14 @@ global {
 	# This configuration option has an automatic default value.
 	# thin_repair_executable = "@THIN_REPAIR_CMD@"
 
+	# Configuration option global/thin_restore_executable.
+	# The full path to the thin_restore command.
+	# LVM uses this command to restore generated data for a thin pool metadata device.
+	# Also see thin_restore_options.
+	# (See package device-mapper-persistent-data or thin-provisioning-tools)
+	# This configuration option has an automatic default value.
+	# thin_restore_executable = "@THIN_RESTORE_CMD@"
+
 	# Configuration option global/thin_check_options.
 	# List of options passed to the thin_check command.
 	# With thin_check version 2.1 or newer you can add the option
@@ -1239,6 +1247,11 @@ global {
 	# This configuration option has an automatic default value.
 	# thin_repair_options = [ "" ]
 
+	# Configuration option global/thin_restore_options.
+	# List of options passed to the thin_restore command.
+	# This configuration option has an automatic default value.
+	# thin_restore_options = [ "" ]
+
 	# Configuration option global/thin_disabled_features.
 	# Features to not use in the thin driver.
 	# This can be helpful for testing, or to avoid using a feature that is
@@ -1287,6 +1300,14 @@ global {
 	# This configuration option has an automatic default value.
 	# cache_repair_executable = "@CACHE_REPAIR_CMD@"
 
+	# Configuration option global/cache_restore_executable.
+	# The full path to the cache_restore command.
+	# LVM uses this command to restore generated data for a cache metadata device.
+	# Also see cache_restore_options.
+	# (See package device-mapper-persistent-data or thin-provisioning-tools)
+	# This configuration option has an automatic default value.
+	# cache_restore_executable = "@CACHE_RESTORE_CMD@"
+
 	# Configuration option global/cache_check_options.
 	# List of options passed to the cache_check command.
 	# With cache_check version 5.0 or newer you should include the option
@@ -1299,6 +1320,11 @@ global {
 	# This configuration option has an automatic default value.
 	# cache_repair_options = [ "" ]
 
+	# Configuration option global/cache_restore_options.
+	# List of options passed to the cache_restore command.
+	# This configuration option has an automatic default value.
+	# cache_restore_options = [ "" ]
+
 	# Configuration option global/vdo_format_executable.
 	# The full path to the vdoformat command.
 	# LVM uses this command to initial data volume for VDO type logical volume
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 528a9db9c..27a93d890 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -491,6 +491,8 @@ Create a thin LV that is a snapshot of an existing thin LV.
 [ \fB--type thin\fP ] (implied)
 .br
 .br
+[ \fB-T\fP|\fB--thin\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -1917,6 +1919,8 @@ Create a thin LV that is a snapshot of an existing thin LV.
 .ad l
 [ \fB-T\fP|\fB--thin\fP ]
 .br
+[ \fB-s\fP|\fB--snapshot\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -1937,6 +1941,8 @@ Create a thin LV that is a snapshot of an existing thin LV.
 [ \fB--type thin\fP ] (implied)
 .br
 .br
+[ \fB-s\fP|\fB--snapshot\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE

