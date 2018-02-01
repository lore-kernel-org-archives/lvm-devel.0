From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 1 Feb 2018 15:58:51 -0500
Subject: master - configure: ensure path /usr/sbin is checked for some tools
Message-ID: <201802012058.w11Kwp4x018385@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e727da6cf111b07b302c08ed479336e4994635b0
Commit:        e727da6cf111b07b302c08ed479336e4994635b0
Parent:        4d4d5bf3234e90fbef233a376d6306e08ac6bf8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 29 16:20:53 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 1 21:57:05 2018 +0100

configure: ensure path /usr/sbin is checked for some tools

Some tools are typically installed into /usr/sbin (or /sbin) dir.
And some systems do not add this path to user's $PATH var.

Ensure sbin paths are looked through...
---
 WHATS_NEW    |    1 +
 configure    |   37 +++++++++++++++++++------------------
 configure.in |   19 ++++++++++---------
 3 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 75a147b..911a6e3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Configure ensures /usr/bin dir is checked for dmpd tools.
   Restore pvmove support for wide-clustered active volumes (2.02.177).
   Avoid non-exclusive activation of exclusive segment types.
   Fix trimming sibling PVs when doing a pvmove of raid subLVs.
diff --git a/configure b/configure
index d04b9d3..0a5d225 100755
--- a/configure
+++ b/configure
@@ -4369,6 +4369,7 @@ ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
 CFLAGS=$save_CFLAGS
 CXXFLAGS=$save_CXXFLAGS
+PATH_SBIN="$PATH:/usr/sbin:/sbin"
 
 
 ac_ext=c
@@ -8672,7 +8673,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -8715,7 +8716,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -8796,7 +8797,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -8839,7 +8840,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -8903,7 +8904,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -8946,7 +8947,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -9010,7 +9011,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -9053,7 +9054,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -9221,7 +9222,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -9264,7 +9265,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -9357,7 +9358,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -9400,7 +9401,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -9464,7 +9465,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -9507,7 +9508,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -9571,7 +9572,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -9614,7 +9615,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -15310,7 +15311,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
@@ -15353,7 +15354,7 @@ else
   ;;
   *)
   as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
+for as_dir in $PATH_SBIN
 do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
diff --git a/configure.in b/configure.in
index d879408..b8e1623 100644
--- a/configure.in
+++ b/configure.in
@@ -77,6 +77,7 @@ AC_PROG_CC
 AC_PROG_CXX
 CFLAGS=$save_CFLAGS
 CXXFLAGS=$save_CXXFLAGS
+PATH_SBIN="$PATH:/usr/sbin:/sbin"
 
 dnl probably no longer needed in 2008, but...
 AC_PROG_GCC_TRADITIONAL
@@ -468,7 +469,7 @@ case "$THIN" in
   internal|shared)
 	# Empty means a config way to ignore thin checking
 	if test "$THIN_CHECK_CMD" = "autodetect"; then
-		AC_PATH_TOOL(THIN_CHECK_CMD, thin_check)
+		AC_PATH_TOOL(THIN_CHECK_CMD, thin_check, [], [$PATH_SBIN])
 		if test -z "$THIN_CHECK_CMD"; then
 			AC_MSG_WARN([thin_check not found in path $PATH])
 			THIN_CHECK_CMD=/usr/sbin/thin_check
@@ -492,7 +493,7 @@ case "$THIN" in
 	fi
 	# Empty means a config way to ignore thin dumping
 	if test "$THIN_DUMP_CMD" = "autodetect"; then
-		AC_PATH_TOOL(THIN_DUMP_CMD, thin_dump)
+		AC_PATH_TOOL(THIN_DUMP_CMD, thin_dump, [], [$PATH_SBIN])
 		test -z "$THIN_DUMP_CMD" && {
 			AC_MSG_WARN(thin_dump not found in path $PATH)
 			THIN_DUMP_CMD=/usr/sbin/thin_dump
@@ -501,7 +502,7 @@ case "$THIN" in
 	fi
 	# Empty means a config way to ignore thin repairing
 	if test "$THIN_REPAIR_CMD" = "autodetect"; then
-		AC_PATH_TOOL(THIN_REPAIR_CMD, thin_repair)
+		AC_PATH_TOOL(THIN_REPAIR_CMD, thin_repair, [], [$PATH_SBIN])
 		test -z "$THIN_REPAIR_CMD" && {
 			AC_MSG_WARN(thin_repair not found in path $PATH)
 			THIN_REPAIR_CMD=/usr/sbin/thin_repair
@@ -510,7 +511,7 @@ case "$THIN" in
 	fi
 	# Empty means a config way to ignore thin restoring
 	if test "$THIN_RESTORE_CMD" = "autodetect"; then
-		AC_PATH_TOOL(THIN_RESTORE_CMD, thin_restore)
+		AC_PATH_TOOL(THIN_RESTORE_CMD, thin_restore, [], [$PATH_SBIN])
 		test -z "$THIN_RESTORE_CMD" && {
 			AC_MSG_WARN(thin_restore not found in path $PATH)
 			THIN_RESTORE_CMD=/usr/sbin/thin_restore
@@ -582,7 +583,7 @@ case "$CACHE" in
   internal|shared)
 	# Empty means a config way to ignore cache checking
 	if test "$CACHE_CHECK_CMD" = "autodetect"; then
-		AC_PATH_TOOL(CACHE_CHECK_CMD, cache_check)
+		AC_PATH_TOOL(CACHE_CHECK_CMD, cache_check, [], [$PATH_SBIN])
 		if test -z "$CACHE_CHECK_CMD"; then
 			AC_MSG_WARN([cache_check not found in path $PATH])
 			CACHE_CHECK_CMD=/usr/sbin/cache_check
@@ -617,7 +618,7 @@ case "$CACHE" in
 	fi
 	# Empty means a config way to ignore cache dumping
 	if test "$CACHE_DUMP_CMD" = "autodetect"; then
-		AC_PATH_TOOL(CACHE_DUMP_CMD, cache_dump)
+		AC_PATH_TOOL(CACHE_DUMP_CMD, cache_dump, [], [$PATH_SBIN])
 		test -z "$CACHE_DUMP_CMD" && {
 			AC_MSG_WARN(cache_dump not found in path $PATH)
 			CACHE_DUMP_CMD=/usr/sbin/cache_dump
@@ -626,7 +627,7 @@ case "$CACHE" in
 	fi
 	# Empty means a config way to ignore cache repairing
 	if test "$CACHE_REPAIR_CMD" = "autodetect"; then
-		AC_PATH_TOOL(CACHE_REPAIR_CMD, cache_repair)
+		AC_PATH_TOOL(CACHE_REPAIR_CMD, cache_repair, [], [$PATH_SBIN])
 		test -z "$CACHE_REPAIR_CMD" && {
 			AC_MSG_WARN(cache_repair not found in path $PATH)
 			CACHE_REPAIR_CMD=/usr/sbin/cache_repair
@@ -635,7 +636,7 @@ case "$CACHE" in
 	fi
 	# Empty means a config way to ignore cache restoring
 	if test "$CACHE_RESTORE_CMD" = "autodetect"; then
-		AC_PATH_TOOL(CACHE_RESTORE_CMD, cache_restore)
+		AC_PATH_TOOL(CACHE_RESTORE_CMD, cache_restore, [], [$PATH_SBIN])
 		test -z "$CACHE_RESTORE_CMD" && {
 			AC_MSG_WARN(cache_restore not found in path $PATH)
 			CACHE_RESTORE_CMD=/usr/sbin/cache_restore
@@ -1870,7 +1871,7 @@ if test "$BUILD_DMFILEMAPD" = yes; then
 fi
 
 ################################################################################
-AC_PATH_TOOL(MODPROBE_CMD, modprobe)
+AC_PATH_TOOL(MODPROBE_CMD, modprobe, [], [$PATH_SBIN])
 
 if test -n "$MODPROBE_CMD"; then
 	AC_DEFINE_UNQUOTED([MODPROBE_CMD], ["$MODPROBE_CMD"], [The path to 'modprobe', if available.])


