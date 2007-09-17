From: Jim Meyering <jim@meyering.net>
Date: Mon, 17 Sep 2007 11:56:06 -0000
Subject: [PATCH] Allow relative dir name in: --with-dmdir=../device-mapper
Message-ID: <mailman.0.1646510520.4176946.lvm-devel@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

* configure.in: Convert a relative dmdir directory name to the required
absolute form, e.g. in ./configure --with-dmdir=../device-mapper
Suggestion from Jun'ichi Nomura.
* configure: Regenerate.

Signed-off-by: Jim Meyering <jim@meyering.net>
---
 configure    |   10 ++++++++--
 configure.in |    6 ++++++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index b61aed9..468a9f5 100755
--- a/configure
+++ b/configure
@@ -9627,6 +9627,12 @@ else
 fi
 
 
+# Convert a relative dir name to absolute.
+case $DMDIR in
+  /*) ;;
+  *) DMDIR="`pwd`/$DMDIR" ;;
+esac
+
 ################################################################################
 if test x$READLINE = xyes; then
 
@@ -11591,7 +11597,7 @@ fi
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile test/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile test/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12195,6 +12201,7 @@ do
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
     "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
+    "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
@@ -12206,7 +12213,6 @@ do
     "test/format1/Makefile") CONFIG_FILES="$CONFIG_FILES test/format1/Makefile" ;;
     "test/regex/Makefile") CONFIG_FILES="$CONFIG_FILES test/regex/Makefile" ;;
     "test/filters/Makefile") CONFIG_FILES="$CONFIG_FILES test/filters/Makefile" ;;
-    "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
 
   *) { { $as_echo "$as_me:$LINENO: error: invalid argument: $ac_config_target" >&5
 $as_echo "$as_me: error: invalid argument: $ac_config_target" >&2;}
diff --git a/configure.in b/configure.in
index b3c1769..4042b8c 100644
--- a/configure.in
+++ b/configure.in
@@ -538,6 +538,12 @@ AC_ARG_WITH(dmdir,
   	    [ DMDIR="$withval" CPPFLAGS="$CPPFLAGS -I$DMDIR/include"],
 	    [ DMDIR= ])
 
+# Convert a relative dir name to absolute.
+case $DMDIR in
+  /*) ;;
+  *) DMDIR="`pwd`/$DMDIR" ;;
+esac
+
 ################################################################################
 dnl -- Ensure additional headers required
 if test x$READLINE = xyes; then
-- 
1.5.3.1.19.gb5ef6-dirty



