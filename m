From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 27 Apr 2015 19:16:07 +0000 (UTC)
Subject: master - example.conf.in: regenerate
Message-ID: <20150427191607.AAAD660F47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c1bda9b53d1935a6eadea579061c323366c8e61
Commit:        0c1bda9b53d1935a6eadea579061c323366c8e61
Parent:        cfb0174fed25cb6a27a5ff3554b5c442d2defcc9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 27 14:15:24 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 27 14:15:24 2015 -0500

example.conf.in: regenerate

>From recent config_settings.h changes.
---
 conf/example.conf.in |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index eedefb5..5354779 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -144,7 +144,7 @@ devices {
 #	global_filter=[]
 
 	# Configuration option devices/cache.
-	# This has been replaced by the devices/cache_dir setting.
+	# The path can be set using the devices/cache_dir setting.
 	cache="/etc/lvm/cache/.cache"
 
 	# Configuration option devices/cache_dir.
@@ -540,7 +540,7 @@ backup {
 	# Configuration option backup/archive_dir.
 	# Location of the metdata archive files.
 	# Remember to back up this directory regularly!
-	archive_dir="/etc/lvm/archive"
+	archive_dir="@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@"
 
 	# Configuration option backup/retain_min.
 	# Minimum number of archives to keep.
@@ -863,7 +863,7 @@ global {
 	# ignorable errors and fix them later.
 	# With thin_check version 3.2 or newer you should add
 	# --clear-needs-check-flag.
-	thin_check_options="-q --clear-needs-check-flag"
+	thin_check_options=["-q", "--clear-needs-check-flag"]
 
 	# Configuration option global/thin_repair_options.
 	# String of options passed to the thin_repair command.
@@ -879,7 +879,8 @@ global {
 	# error_if_no_space.
 	# Example:
 	# thin_disabled_features = [ "discards", "block_size" ]
-	thin_disabled_features=[]
+	# This configuration option does not have a default value defined.
+#	thin_disabled_features=[]
 
 	# Configuration option global/cache_check_executable.
 	# The full path to the cache_check command.


