From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Apr 2016 22:35:45 +0000 (UTC)
Subject: master - configure: respect --disable-lvmetad/lvmpolld
Message-ID: <20160420223545.90B7361EB2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57f468a53ed8ec425d1087ce06c90862caa19ff1
Commit:        57f468a53ed8ec425d1087ce06c90862caa19ff1
Parent:        600d7ca15f410c8abf41cee0195bc575148253b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 00:31:15 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 21 00:34:01 2016 +0200

configure: respect --disable-lvmetad/lvmpolld

When user requested on cmdline disabling of lvmetad/lvmpoll,
respect it and when lvmlockd requires these daemon,
Error configure with clear message about misconfiguration.
---
 configure    |   28 ++++++++++++++++------------
 configure.in |   20 ++++++++++----------
 2 files changed, 26 insertions(+), 22 deletions(-)

diff --git a/configure b/configure
index c2de9a8..83d5964 100755
--- a/configure
+++ b/configure
@@ -3168,8 +3168,8 @@ case "$host_os" in
 		LDDEPS="$LDDEPS .export.sym"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
-		LVMETAD=no
-		LVMPOLLD=no
+		BUILD_LVMETAD=no
+		BUILD_LVMPOLLD=no
 		LOCKDSANLOCK=no
 		LOCKDDLM=no
 		ODIRECT=yes
@@ -11486,10 +11486,9 @@ if test "${enable_lvmetad+set}" = set; then :
   enableval=$enable_lvmetad; LVMETAD=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVMETAD" >&5
-$as_echo "$LVMETAD" >&6; }
-
-BUILD_LVMETAD=$LVMETAD
+test -n "$LVMETAD" && BUILD_LVMETAD=$LVMETAD
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMETAD" >&5
+$as_echo "$BUILD_LVMETAD" >&6; }
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmpolld" >&5
@@ -11499,10 +11498,9 @@ if test "${enable_lvmpolld+set}" = set; then :
   enableval=$enable_lvmpolld; LVMPOLLD=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVMPOLLD" >&5
-$as_echo "$LVMPOLLD" >&6; }
-
-BUILD_LVMPOLLD=$LVMPOLLD
+test -n "$LVMPOLLD" && BUILD_LVMPOLLD=$LVMPOLLD
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMPOLLD" >&5
+$as_echo "$BUILD_LVMPOLLD" >&6; }
 
 ################################################################################
 BUILD_LVMLOCKD=no
@@ -11695,11 +11693,17 @@ $as_echo_n "checking whether to build lvmlockd... " >&6; }
 $as_echo "$BUILD_LVMLOCKD" >&6; }
 
 if test "$BUILD_LVMLOCKD" = yes; then
-	if test -n "$BUILD_LVMPOLLD"; then :
+	if test "$LVMPOLLD" = no; then :
+  as_fn_error $? "cannot build lvmlockd with --disable-lvmpolld." "$LINENO" 5
+fi
+	if test "$LVMETAD" = no; then :
+  as_fn_error $? "cannot build lvmlockd with --disable-lvmetad." "$LINENO" 5
+fi
+	if test "$BUILD_LVMPOLLD" = no; then :
   BUILD_LVMPOLLD=yes; { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Enabling lvmpolld - required by lvmlockd." >&5
 $as_echo "$as_me: WARNING: Enabling lvmpolld - required by lvmlockd." >&2;}
 fi
-	if test -n "$BUILD_LVMETAD"; then :
+	if test "$BUILD_LVMETAD" = no; then :
   BUILD_LVMETAD=yes; { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Enabling lvmetad - required by lvmlockd." >&5
 $as_echo "$as_me: WARNING: Enabling lvmetad - required by lvmlockd." >&2;}
 fi
diff --git a/configure.in b/configure.in
index 4161df7..b87f8ff 100644
--- a/configure.in
+++ b/configure.in
@@ -37,8 +37,8 @@ case "$host_os" in
 		LDDEPS="$LDDEPS .export.sym"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
-		LVMETAD=no
-		LVMPOLLD=no
+		BUILD_LVMETAD=no
+		BUILD_LVMPOLLD=no
 		LOCKDSANLOCK=no
 		LOCKDDLM=no
 		ODIRECT=yes
@@ -1129,9 +1129,8 @@ AC_ARG_ENABLE(lvmetad,
 	      AC_HELP_STRING([--enable-lvmetad],
 			     [enable the LVM Metadata Daemon]),
 	      LVMETAD=$enableval)
-AC_MSG_RESULT($LVMETAD)
-
-BUILD_LVMETAD=$LVMETAD
+test -n "$LVMETAD" && BUILD_LVMETAD=$LVMETAD
+AC_MSG_RESULT($BUILD_LVMETAD)
 
 ################################################################################
 dnl -- Build lvmpolld
@@ -1140,9 +1139,8 @@ AC_ARG_ENABLE(lvmpolld,
 	      AC_HELP_STRING([--enable-lvmpolld],
 			     [enable the LVM Polling Daemon]),
 	      LVMPOLLD=$enableval)
-AC_MSG_RESULT($LVMPOLLD)
-
-BUILD_LVMPOLLD=$LVMPOLLD
+test -n "$LVMPOLLD" && BUILD_LVMPOLLD=$LVMPOLLD
+AC_MSG_RESULT($BUILD_LVMPOLLD)
 
 ################################################################################
 BUILD_LVMLOCKD=no
@@ -1188,8 +1186,10 @@ AC_MSG_CHECKING(whether to build lvmlockd)
 AC_MSG_RESULT($BUILD_LVMLOCKD)
 
 if test "$BUILD_LVMLOCKD" = yes; then
-	AS_IF([test -n "$BUILD_LVMPOLLD"], [BUILD_LVMPOLLD=yes; AC_MSG_WARN([Enabling lvmpolld - required by lvmlockd.])])
-	AS_IF([test -n "$BUILD_LVMETAD"], [BUILD_LVMETAD=yes; AC_MSG_WARN([Enabling lvmetad - required by lvmlockd.])])
+	AS_IF([test "$LVMPOLLD" = no], [AC_MSG_ERROR([cannot build lvmlockd with --disable-lvmpolld.])])
+	AS_IF([test "$LVMETAD" = no], [AC_MSG_ERROR([cannot build lvmlockd with --disable-lvmetad.])])
+	AS_IF([test "$BUILD_LVMPOLLD" = no], [BUILD_LVMPOLLD=yes; AC_MSG_WARN([Enabling lvmpolld - required by lvmlockd.])])
+	AS_IF([test "$BUILD_LVMETAD" = no], [BUILD_LVMETAD=yes; AC_MSG_WARN([Enabling lvmetad - required by lvmlockd.])])
 	AC_MSG_CHECKING([defaults for use_lvmlockd])
 	AC_ARG_ENABLE(use_lvmlockd,
 		      AC_HELP_STRING([--disable-use-lvmlockd],


