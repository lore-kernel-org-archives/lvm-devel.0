From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:11:00 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20230216231100.316873858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a861f0425e0688b2feb97b15277bceb3132d5004
Commit:        a861f0425e0688b2feb97b15277bceb3132d5004
Parent:        13b216fbdf038dc83d31c43026aa53d281ab3942
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 23:26:24 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:08:50 2023 +0100

configure: update

---
 configure | 326 +++++++++++++++++++++++++-------------------------------------
 1 file changed, 129 insertions(+), 197 deletions(-)

diff --git a/configure b/configure
index 3e09aa265..c2eee6ba7 100755
--- a/configure
+++ b/configure
@@ -686,23 +686,9 @@ SYSCONFDIR
 SELINUX_PC
 SELINUX_LIBS
 SBINDIR
-SALCK_LIBS
-SALCK_CFLAGS
-SACKPT_LIBS
-SACKPT_CFLAGS
-REPLICATORS
 RT_LIBS
-QUORUM_LIBS
-QUORUM_CFLAGS
 PYTHON3DIR
 PYTHON2DIR
-PYTHON3_LIBDIRS
-PYTHON2_LIBDIRS
-PYTHON3_INCDIRS
-PYTHON2_INCDIRS
-PYTHON3_BINDINGS
-PYTHON2_BINDINGS
-PYTHON_BINDINGS
 PYTHON3
 PYTHON2
 PTHREAD_LIBS
@@ -728,11 +714,6 @@ LDDEPS
 JOBS
 INTL
 INTEGRITY
-HAVE_VALGRIND
-HAVE_REALTIME
-HAVE_LIBDL
-HAVE_BLKID_SUBLKS_FSINFO
-HAVE_BLKID
 BLKDEACTIVATE
 LVRESIZE_FS_HELPER_PATH
 FSADM_PATH
@@ -741,8 +722,6 @@ ELDFLAGS
 DM_LIB_PATCHLEVEL
 DMEVENTD_PATH
 DL_LIBS
-DLM_LIBS
-DLM_CFLAGS
 DEVMAPPER
 DEFAULT_USE_LVMLOCKD
 DEFAULT_USE_LVMPOLLD
@@ -764,8 +743,6 @@ DEFAULT_ARCHIVE_SUBDIR
 DEBUG
 COPTIMISE_FLAG
 CONFDIR
-CONFDB_LIBS
-CONFDB_CFLAGS
 CMDLIB
 CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
@@ -806,16 +783,16 @@ UDEV_CFLAGS
 BLKID_LIBS
 BLKID_CFLAGS
 SYSTEMD_RUN_CMD
-SYSTEMD_LIBS
-SYSTEMD_CFLAGS
-LOCKD_IDM_LIBS
-LOCKD_IDM_CFLAGS
-LOCKD_DLM_CONTROL_LIBS
-LOCKD_DLM_CONTROL_CFLAGS
-LOCKD_DLM_LIBS
-LOCKD_DLM_CFLAGS
-LOCKD_SANLOCK_LIBS
-LOCKD_SANLOCK_CFLAGS
+LIBSYSTEMD_LIBS
+LIBSYSTEMD_CFLAGS
+LIBSEAGATEILM_LIBS
+LIBSEAGATEILM_CFLAGS
+LIBDLMCONTROL_LIBS
+LIBDLMCONTROL_CFLAGS
+LIBDLM_LIBS
+LIBDLM_CFLAGS
+LIBSANLOCKCLIENT_LIBS
+LIBSANLOCKCLIENT_CFLAGS
 VALGRIND_LIBS
 VALGRIND_CFLAGS
 GENPNG
@@ -1052,16 +1029,16 @@ CPG_CFLAGS
 CPG_LIBS
 VALGRIND_CFLAGS
 VALGRIND_LIBS
-LOCKD_SANLOCK_CFLAGS
-LOCKD_SANLOCK_LIBS
-LOCKD_DLM_CFLAGS
-LOCKD_DLM_LIBS
-LOCKD_DLM_CONTROL_CFLAGS
-LOCKD_DLM_CONTROL_LIBS
-LOCKD_IDM_CFLAGS
-LOCKD_IDM_LIBS
-SYSTEMD_CFLAGS
-SYSTEMD_LIBS
+LIBSANLOCKCLIENT_CFLAGS
+LIBSANLOCKCLIENT_LIBS
+LIBDLM_CFLAGS
+LIBDLM_LIBS
+LIBDLMCONTROL_CFLAGS
+LIBDLMCONTROL_LIBS
+LIBSEAGATEILM_CFLAGS
+LIBSEAGATEILM_LIBS
+LIBSYSTEMD_CFLAGS
+LIBSYSTEMD_LIBS
 BLKID_CFLAGS
 BLKID_LIBS
 UDEV_CFLAGS
@@ -1867,26 +1844,25 @@ Some influential environment variables:
               C compiler flags for VALGRIND, overriding pkg-config
   VALGRIND_LIBS
               linker flags for VALGRIND, overriding pkg-config
-  LOCKD_SANLOCK_CFLAGS
-              C compiler flags for LOCKD_SANLOCK, overriding pkg-config
-  LOCKD_SANLOCK_LIBS
-              linker flags for LOCKD_SANLOCK, overriding pkg-config
-  LOCKD_DLM_CFLAGS
-              C compiler flags for LOCKD_DLM, overriding pkg-config
-  LOCKD_DLM_LIBS
-              linker flags for LOCKD_DLM, overriding pkg-config
-  LOCKD_DLM_CONTROL_CFLAGS
-              C compiler flags for LOCKD_DLM_CONTROL, overriding pkg-config
-  LOCKD_DLM_CONTROL_LIBS
-              linker flags for LOCKD_DLM_CONTROL, overriding pkg-config
-  LOCKD_IDM_CFLAGS
-              C compiler flags for LOCKD_IDM, overriding pkg-config
-  LOCKD_IDM_LIBS
-              linker flags for LOCKD_IDM, overriding pkg-config
-  SYSTEMD_CFLAGS
-              C compiler flags for SYSTEMD, overriding pkg-config
-  SYSTEMD_LIBS
-              linker flags for SYSTEMD, overriding pkg-config
+  LIBSANLOCKCLIENT_CFLAGS
+              C compiler flags for LIBSANLOCKCLIENT, overriding pkg-config
+  LIBSANLOCKCLIENT_LIBS
+              linker flags for LIBSANLOCKCLIENT, overriding pkg-config
+  LIBDLM_CFLAGS
+              C compiler flags for LIBDLM, overriding pkg-config
+  LIBDLM_LIBS linker flags for LIBDLM, overriding pkg-config
+  LIBDLMCONTROL_CFLAGS
+              C compiler flags for LIBDLMCONTROL, overriding pkg-config
+  LIBDLMCONTROL_LIBS
+              linker flags for LIBDLMCONTROL, overriding pkg-config
+  LIBSEAGATEILM_CFLAGS
+              C compiler flags for LIBSEAGATEILM, overriding pkg-config
+  LIBSEAGATEILM_LIBS
+              linker flags for LIBSEAGATEILM, overriding pkg-config
+  LIBSYSTEMD_CFLAGS
+              C compiler flags for LIBSYSTEMD, overriding pkg-config
+  LIBSYSTEMD_LIBS
+              linker flags for LIBSYSTEMD, overriding pkg-config
   BLKID_CFLAGS
               C compiler flags for BLKID, overriding pkg-config
   BLKID_LIBS  linker flags for BLKID, overriding pkg-config
@@ -12064,11 +12040,11 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_SANLOCK" >&5
-printf %s "checking for LOCKD_SANLOCK... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LIBSANLOCKCLIENT" >&5
+printf %s "checking for LIBSANLOCKCLIENT... " >&6; }
 
-if test -n "$LOCKD_SANLOCK_CFLAGS"; then
-    pkg_cv_LOCKD_SANLOCK_CFLAGS="$LOCKD_SANLOCK_CFLAGS"
+if test -n "$LIBSANLOCKCLIENT_CFLAGS"; then
+    pkg_cv_LIBSANLOCKCLIENT_CFLAGS="$LIBSANLOCKCLIENT_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client >= 3.3.0\""; } >&5
@@ -12076,7 +12052,7 @@ if test -n "$LOCKD_SANLOCK_CFLAGS"; then
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LOCKD_SANLOCK_CFLAGS=`$PKG_CONFIG --cflags "libsanlock_client >= 3.3.0" 2>/dev/null`
+  pkg_cv_LIBSANLOCKCLIENT_CFLAGS=`$PKG_CONFIG --cflags "libsanlock_client >= 3.3.0" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12084,8 +12060,8 @@ fi
  else
     pkg_failed=untried
 fi
-if test -n "$LOCKD_SANLOCK_LIBS"; then
-    pkg_cv_LOCKD_SANLOCK_LIBS="$LOCKD_SANLOCK_LIBS"
+if test -n "$LIBSANLOCKCLIENT_LIBS"; then
+    pkg_cv_LIBSANLOCKCLIENT_LIBS="$LIBSANLOCKCLIENT_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client >= 3.3.0\""; } >&5
@@ -12093,7 +12069,7 @@ if test -n "$LOCKD_SANLOCK_LIBS"; then
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LOCKD_SANLOCK_LIBS=`$PKG_CONFIG --libs "libsanlock_client >= 3.3.0" 2>/dev/null`
+  pkg_cv_LIBSANLOCKCLIENT_LIBS=`$PKG_CONFIG --libs "libsanlock_client >= 3.3.0" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12114,12 +12090,12 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LOCKD_SANLOCK_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsanlock_client >= 3.3.0" 2>&1`
+	        LIBSANLOCKCLIENT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsanlock_client >= 3.3.0" 2>&1`
         else
-	        LOCKD_SANLOCK_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsanlock_client >= 3.3.0" 2>&1`
+	        LIBSANLOCKCLIENT_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsanlock_client >= 3.3.0" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
-	echo "$LOCKD_SANLOCK_PKG_ERRORS" >&5
+	echo "$LIBSANLOCKCLIENT_PKG_ERRORS" >&5
 
 	$bailout
 elif test $pkg_failed = untried; then
@@ -12127,16 +12103,15 @@ elif test $pkg_failed = untried; then
 printf "%s\n" "no" >&6; }
 	$bailout
 else
-	LOCKD_SANLOCK_CFLAGS=$pkg_cv_LOCKD_SANLOCK_CFLAGS
-	LOCKD_SANLOCK_LIBS=$pkg_cv_LOCKD_SANLOCK_LIBS
+	LIBSANLOCKCLIENT_CFLAGS=$pkg_cv_LIBSANLOCKCLIENT_CFLAGS
+	LIBSANLOCKCLIENT_LIBS=$pkg_cv_LIBSANLOCKCLIENT_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	HAVE_LOCKD_SANLOCK="yes"
+	BUILD_LVMLOCKD="yes"
 fi
 
 printf "%s\n" "#define LOCKDSANLOCK_SUPPORT 1" >>confdefs.h
 
-	BUILD_LVMLOCKD=yes
 
 fi
 
@@ -12159,11 +12134,11 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM" >&5
-printf %s "checking for LOCKD_DLM... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LIBDLM" >&5
+printf %s "checking for LIBDLM... " >&6; }
 
-if test -n "$LOCKD_DLM_CFLAGS"; then
-    pkg_cv_LOCKD_DLM_CFLAGS="$LOCKD_DLM_CFLAGS"
+if test -n "$LIBDLM_CFLAGS"; then
+    pkg_cv_LIBDLM_CFLAGS="$LIBDLM_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm\""; } >&5
@@ -12171,7 +12146,7 @@ if test -n "$LOCKD_DLM_CFLAGS"; then
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LOCKD_DLM_CFLAGS=`$PKG_CONFIG --cflags "libdlm" 2>/dev/null`
+  pkg_cv_LIBDLM_CFLAGS=`$PKG_CONFIG --cflags "libdlm" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12179,8 +12154,8 @@ fi
  else
     pkg_failed=untried
 fi
-if test -n "$LOCKD_DLM_LIBS"; then
-    pkg_cv_LOCKD_DLM_LIBS="$LOCKD_DLM_LIBS"
+if test -n "$LIBDLM_LIBS"; then
+    pkg_cv_LIBDLM_LIBS="$LIBDLM_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm\""; } >&5
@@ -12188,7 +12163,7 @@ if test -n "$LOCKD_DLM_LIBS"; then
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LOCKD_DLM_LIBS=`$PKG_CONFIG --libs "libdlm" 2>/dev/null`
+  pkg_cv_LIBDLM_LIBS=`$PKG_CONFIG --libs "libdlm" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12209,12 +12184,12 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LOCKD_DLM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlm" 2>&1`
+	        LIBDLM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlm" 2>&1`
         else
-	        LOCKD_DLM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlm" 2>&1`
+	        LIBDLM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlm" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
-	echo "$LOCKD_DLM_PKG_ERRORS" >&5
+	echo "$LIBDLM_PKG_ERRORS" >&5
 
 	$bailout
 elif test $pkg_failed = untried; then
@@ -12222,16 +12197,15 @@ elif test $pkg_failed = untried; then
 printf "%s\n" "no" >&6; }
 	$bailout
 else
-	LOCKD_DLM_CFLAGS=$pkg_cv_LOCKD_DLM_CFLAGS
-	LOCKD_DLM_LIBS=$pkg_cv_LOCKD_DLM_LIBS
+	LIBDLM_CFLAGS=$pkg_cv_LIBDLM_CFLAGS
+	LIBDLM_LIBS=$pkg_cv_LIBDLM_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	HAVE_LOCKD_DLM="yes"
+	BUILD_LVMLOCKD="yes"
 fi
 
 printf "%s\n" "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
 
-	BUILD_LVMLOCKD=yes
 
 fi
 
@@ -12254,11 +12228,11 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM_CONTROL" >&5
-printf %s "checking for LOCKD_DLM_CONTROL... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LIBDLMCONTROL" >&5
+printf %s "checking for LIBDLMCONTROL... " >&6; }
 
-if test -n "$LOCKD_DLM_CONTROL_CFLAGS"; then
-    pkg_cv_LOCKD_DLM_CONTROL_CFLAGS="$LOCKD_DLM_CONTROL_CFLAGS"
+if test -n "$LIBDLMCONTROL_CFLAGS"; then
+    pkg_cv_LIBDLMCONTROL_CFLAGS="$LIBDLMCONTROL_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlmcontrol >= 3.2\""; } >&5
@@ -12266,7 +12240,7 @@ if test -n "$LOCKD_DLM_CONTROL_CFLAGS"; then
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LOCKD_DLM_CONTROL_CFLAGS=`$PKG_CONFIG --cflags "libdlmcontrol >= 3.2" 2>/dev/null`
+  pkg_cv_LIBDLMCONTROL_CFLAGS=`$PKG_CONFIG --cflags "libdlmcontrol >= 3.2" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12274,8 +12248,8 @@ fi
  else
     pkg_failed=untried
 fi
-if test -n "$LOCKD_DLM_CONTROL_LIBS"; then
-    pkg_cv_LOCKD_DLM_CONTROL_LIBS="$LOCKD_DLM_CONTROL_LIBS"
+if test -n "$LIBDLMCONTROL_LIBS"; then
+    pkg_cv_LIBDLMCONTROL_LIBS="$LIBDLMCONTROL_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlmcontrol >= 3.2\""; } >&5
@@ -12283,7 +12257,7 @@ if test -n "$LOCKD_DLM_CONTROL_LIBS"; then
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LOCKD_DLM_CONTROL_LIBS=`$PKG_CONFIG --libs "libdlmcontrol >= 3.2" 2>/dev/null`
+  pkg_cv_LIBDLMCONTROL_LIBS=`$PKG_CONFIG --libs "libdlmcontrol >= 3.2" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12304,12 +12278,12 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LOCKD_DLM_CONTROL_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlmcontrol >= 3.2" 2>&1`
+	        LIBDLMCONTROL_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlmcontrol >= 3.2" 2>&1`
         else
-	        LOCKD_DLM_CONTROL_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlmcontrol >= 3.2" 2>&1`
+	        LIBDLMCONTROL_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlmcontrol >= 3.2" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
-	echo "$LOCKD_DLM_CONTROL_PKG_ERRORS" >&5
+	echo "$LIBDLMCONTROL_PKG_ERRORS" >&5
 
 	$bailout
 elif test $pkg_failed = untried; then
@@ -12317,16 +12291,15 @@ elif test $pkg_failed = untried; then
 printf "%s\n" "no" >&6; }
 	$bailout
 else
-	LOCKD_DLM_CONTROL_CFLAGS=$pkg_cv_LOCKD_DLM_CONTROL_CFLAGS
-	LOCKD_DLM_CONTROL_LIBS=$pkg_cv_LOCKD_DLM_CONTROL_LIBS
+	LIBDLMCONTROL_CFLAGS=$pkg_cv_LIBDLMCONTROL_CFLAGS
+	LIBDLMCONTROL_LIBS=$pkg_cv_LIBDLMCONTROL_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	HAVE_LOCKD_DLM_CONTROL=yes
+	BUILD_LVMLOCKD="yes"
 fi
 
 printf "%s\n" "#define LOCKDDLM_CONTROL_SUPPORT 1" >>confdefs.h
 
-	BUILD_LVMLOCKD=yes
 
 fi
 
@@ -12347,13 +12320,20 @@ printf "%s\n" "$BUILD_LOCKDIDM" >&6; }
 if test "$BUILD_LOCKDIDM" = "yes"
 then :
 
+	if test -n "$PKG_CONFIG" && \
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_IDM" >&5
-printf %s "checking for LOCKD_IDM... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LIBSEAGATEILM" >&5
+printf %s "checking for LIBSEAGATEILM... " >&6; }
 
-if test -n "$LOCKD_IDM_CFLAGS"; then
-    pkg_cv_LOCKD_IDM_CFLAGS="$LOCKD_IDM_CFLAGS"
+if test -n "$LIBSEAGATEILM_CFLAGS"; then
+    pkg_cv_LIBSEAGATEILM_CFLAGS="$LIBSEAGATEILM_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libseagate_ilm >= 0.1.0\""; } >&5
@@ -12361,7 +12341,7 @@ if test -n "$LOCKD_IDM_CFLAGS"; then
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LOCKD_IDM_CFLAGS=`$PKG_CONFIG --cflags "libseagate_ilm >= 0.1.0" 2>/dev/null`
+  pkg_cv_LIBSEAGATEILM_CFLAGS=`$PKG_CONFIG --cflags "libseagate_ilm >= 0.1.0" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12369,8 +12349,8 @@ fi
  else
     pkg_failed=untried
 fi
-if test -n "$LOCKD_IDM_LIBS"; then
-    pkg_cv_LOCKD_IDM_LIBS="$LOCKD_IDM_LIBS"
+if test -n "$LIBSEAGATEILM_LIBS"; then
+    pkg_cv_LIBSEAGATEILM_LIBS="$LIBSEAGATEILM_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libseagate_ilm >= 0.1.0\""; } >&5
@@ -12378,7 +12358,7 @@ if test -n "$LOCKD_IDM_LIBS"; then
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LOCKD_IDM_LIBS=`$PKG_CONFIG --libs "libseagate_ilm >= 0.1.0" 2>/dev/null`
+  pkg_cv_LIBSEAGATEILM_LIBS=`$PKG_CONFIG --libs "libseagate_ilm >= 0.1.0" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12399,12 +12379,12 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LOCKD_IDM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libseagate_ilm >= 0.1.0" 2>&1`
+	        LIBSEAGATEILM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libseagate_ilm >= 0.1.0" 2>&1`
         else
-	        LOCKD_IDM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libseagate_ilm >= 0.1.0" 2>&1`
+	        LIBSEAGATEILM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libseagate_ilm >= 0.1.0" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
-	echo "$LOCKD_IDM_PKG_ERRORS" >&5
+	echo "$LIBSEAGATEILM_PKG_ERRORS" >&5
 
 	$bailout
 elif test $pkg_failed = untried; then
@@ -12412,26 +12392,19 @@ elif test $pkg_failed = untried; then
 printf "%s\n" "no" >&6; }
 	$bailout
 else
-	LOCKD_IDM_CFLAGS=$pkg_cv_LOCKD_IDM_CFLAGS
-	LOCKD_IDM_LIBS=$pkg_cv_LOCKD_IDM_LIBS
+	LIBSEAGATEILM_CFLAGS=$pkg_cv_LIBSEAGATEILM_CFLAGS
+	LIBSEAGATEILM_LIBS=$pkg_cv_LIBSEAGATEILM_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	HAVE_LOCKD_IDM=yes
-fi
-	if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
-  ac_status=$?
-  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  HAVE_LOCKD_IDM="yes"
-else
-  $bailout
+	BUILD_LVMLOCKD="yes"
 fi
 
 printf "%s\n" "#define LOCKDIDM_SUPPORT 1" >>confdefs.h
 
-	BUILD_LVMLOCKD=yes
+
+else
+  $bailout
+fi
 
 fi
 
@@ -12706,19 +12679,19 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for SYSTEMD" >&5
-printf %s "checking for SYSTEMD... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LIBSYSTEMD" >&5
+printf %s "checking for LIBSYSTEMD... " >&6; }
 
-if test -n "$SYSTEMD_CFLAGS"; then
-    pkg_cv_SYSTEMD_CFLAGS="$SYSTEMD_CFLAGS"
+if test -n "$LIBSYSTEMD_CFLAGS"; then
+    pkg_cv_LIBSYSTEMD_CFLAGS="$LIBSYSTEMD_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd") 2>&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsystemd\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libsystemd") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_SYSTEMD_CFLAGS=`$PKG_CONFIG --cflags "systemd" 2>/dev/null`
+  pkg_cv_LIBSYSTEMD_CFLAGS=`$PKG_CONFIG --cflags "libsystemd" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12726,16 +12699,16 @@ fi
  else
     pkg_failed=untried
 fi
-if test -n "$SYSTEMD_LIBS"; then
-    pkg_cv_SYSTEMD_LIBS="$SYSTEMD_LIBS"
+if test -n "$LIBSYSTEMD_LIBS"; then
+    pkg_cv_LIBSYSTEMD_LIBS="$LIBSYSTEMD_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd") 2>&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsystemd\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libsystemd") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_SYSTEMD_LIBS=`$PKG_CONFIG --libs "systemd" 2>/dev/null`
+  pkg_cv_LIBSYSTEMD_LIBS=`$PKG_CONFIG --libs "libsystemd" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12756,12 +12729,12 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "systemd" 2>&1`
+	        LIBSYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsystemd" 2>&1`
         else
-	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "systemd" 2>&1`
+	        LIBSYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsystemd" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
-	echo "$SYSTEMD_PKG_ERRORS" >&5
+	echo "$LIBSYSTEMD_PKG_ERRORS" >&5
 
 	$bailout
 elif test $pkg_failed = untried; then
@@ -12769,11 +12742,11 @@ elif test $pkg_failed = untried; then
 printf "%s\n" "no" >&6; }
 	$bailout
 else
-	SYSTEMD_CFLAGS=$pkg_cv_SYSTEMD_CFLAGS
-	SYSTEMD_LIBS=$pkg_cv_SYSTEMD_LIBS
+	LIBSYSTEMD_CFLAGS=$pkg_cv_LIBSYSTEMD_CFLAGS
+	LIBSYSTEMD_LIBS=$pkg_cv_LIBSYSTEMD_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	SYSTEMD_LIBS="-lsystemd"
+
 fi
 
 fi
@@ -13387,13 +13360,9 @@ printf "%s\n" "$CMDLIB" >&6; }
 
 if test "$CMDLIB" = "yes"
 then :
-
-	LVM2CMD_LIB="-llvm2cmd"
-
+  LVM2CMD_LIB="-llvm2cmd"
 else $as_nop
-
-	LVM2CMD_LIB=""
-
+  LVM2CMD_LIB=
 fi
 
 ################################################################################
@@ -13409,7 +13378,7 @@ fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMDBUSD" >&5
 printf "%s\n" "$BUILD_LVMDBUSD" >&6; }
-if test "$NOTIFYDBUS_SUPPORT" = "yes" && test "BUILD_LVMDBUSD" = "yes"
+if test "$NOTIFYDBUS_SUPPORT" = "no" && test "$BUILD_LVMDBUSD" = "yes"
 then :
   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Building D-Bus support without D-Bus notifications." >&5
 printf "%s\n" "$as_me: WARNING: Building D-Bus support without D-Bus notifications." >&2;}
@@ -13467,7 +13436,7 @@ then :
   printf %s "(cached) " >&6
 else $as_nop
 
-	for am_cv_pathless_PYTHON in  python3 python2 python 	python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 	python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0  none; do
+	for am_cv_pathless_PYTHON in  python3 python2 python 	python3.12 python3.11 python3.10 python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 	python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0  none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
@@ -13941,14 +13910,10 @@ then :
 		as_fn_error $? "python3 headers are required for --enable-python3_bindings or --enable-dbus-service but cannot be found" "$LINENO" 5
 
 fi
-	PYTHON3_INCDIRS=`"$PYTHON3_CONFIG" --includes`
-	PYTHON3_LIBDIRS=`"$PYTHON3_CONFIG" --libs`
 	PYTHON3DIR=$pythondir
 	if test "$PYTHON3_BINDINGS" = "yes"
 then :
-
-		PYTHON_BINDINGS="yes"
-
+  PYTHON_BINDINGS="yes"
 fi
 
 	# To get this macro, install autoconf-archive package then run autoreconf
@@ -15926,16 +15891,6 @@ printf "%s\n" "#define LVM_CONFIGURE_LINE \"$CONFIGURE_LINE\"" >>confdefs.h
 
 
 
-
-
-
-
-
-
-
-
-
-
 ################################################################################
 
 
@@ -16048,29 +16003,6 @@ printf "%s\n" "#define LVM_CONFIGURE_LINE \"$CONFIGURE_LINE\"" >>confdefs.h
 
 
 
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
 
 
 

