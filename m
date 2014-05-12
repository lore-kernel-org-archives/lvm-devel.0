From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 May 2014 14:25:44 +0000 (UTC)
Subject: master - configure: improve needs_check thin_check test
Message-ID: <20140512142544.75FC361391@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e1192f6914ddbe1cf560a02158bdb58584efa26
Commit:        2e1192f6914ddbe1cf560a02158bdb58584efa26
Parent:        5b787a24f024d2589583fc356f343bb981c169e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 12 14:51:23 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 12 16:24:39 2014 +0200

configure: improve needs_check thin_check test

Improve testing for needs_check - when old tools are installed,
issue proper warning from configure, but stop sending needs_check
flag to the old tool.
---
 configure    |   55 +++++++++++++++++++++++++++----------------------------
 configure.in |   43 +++++++++++++++++++++----------------------
 2 files changed, 48 insertions(+), 50 deletions(-)

diff --git a/configure b/configure
index 44eab6f..dd5ec64 100755
--- a/configure
+++ b/configure
@@ -7208,8 +7208,6 @@ $as_echo "#define THIN_INTERNAL 1" >>confdefs.h
   *) as_fn_error $? "--with-thin parameter invalid ($THIN)" "$LINENO" 5 ;;
 esac
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
-$as_echo_n "checking whether thin_check supports the needs-check flag... " >&6; }
 # Check whether --enable-thin_check_needs_check was given.
 if test "${enable_thin_check_needs_check+set}" = set; then :
   enableval=$enable_thin_check_needs_check; THIN_CHECK_NEEDS_CHECK=$enableval
@@ -7217,14 +7215,6 @@ else
   THIN_CHECK_NEEDS_CHECK=yes
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
-$as_echo "$THIN_CHECK_NEEDS_CHECK" >&6; }
-
-if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
-
-$as_echo "#define THIN_CHECK_NEEDS_CHECK 1" >>confdefs.h
-
-fi
 
 # Test if necessary thin tools are available
 # if not - use plain defaults and warn user
@@ -7335,24 +7325,23 @@ fi
 $as_echo "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
 			THIN_CHECK_CMD=/usr/sbin/thin_check
 			THIN_CONFIGURE_WARN=y
-		else
-			if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
-				THIN_CHECK_VSN=`"$THIN_CHECK_CMD" -V 2>/dev/null`
-				THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
-				THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
-
-				if test -z "$THIN_CHECK_VSN_MAJOR" -o -z "$THIN_CHECK_VSN_MINOR" ; then
-					{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Found thin_check version \"$THIN_CHECK_VSN\"" >&5
-$as_echo "$as_me: WARNING: Found thin_check version \"$THIN_CHECK_VSN\"" >&2;}
-					THIN_CHECK_VERSION_WARN=y
-				else
-					if test "$THIN_CHECK_VSN_MAJOR" -eq 0 -a "$THIN_CHECK_VSN_MINOR" -lt 3 ; then
-						{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Found thin_check version \"$THIN_CHECK_VSN\"" >&5
-$as_echo "$as_me: WARNING: Found thin_check version \"$THIN_CHECK_VSN\"" >&2;}
-						THIN_CHECK_VERSION_WARN=y
-					fi
-				fi
-			fi
+		fi
+	fi
+	if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
+		THIN_CHECK_VSN=`"$THIN_CHECK_CMD" -V 2>/dev/null`
+		THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
+		THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
+
+		if test -z "$THIN_CHECK_VSN_MAJOR" -o -z "$THIN_CHECK_VSN_MINOR"; then
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $THIN_CHECK_CMD: Bad version \"$THIN_CHECK_VSN\" found" >&5
+$as_echo "$as_me: WARNING: $THIN_CHECK_CMD: Bad version \"$THIN_CHECK_VSN\" found" >&2;}
+			THIN_CHECK_VERSION_WARN=y
+			THIN_CHECK_NEEDS_CHECK=no
+		elif test "$THIN_CHECK_VSN_MAJOR" -eq 0 -a "$THIN_CHECK_VSN_MINOR" -lt 3; then
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $THIN_CHECK_CMD: Old version \"$THIN_CHECK_VSN\" found" >&5
+$as_echo "$as_me: WARNING: $THIN_CHECK_CMD: Old version \"$THIN_CHECK_VSN\" found" >&2;}
+			THIN_CHECK_VERSION_WARN=y
+			THIN_CHECK_NEEDS_CHECK=no
 		fi
 	fi
 	# Empty means a config way to ignore thin checking
@@ -7572,6 +7561,16 @@ $as_echo "$as_me: WARNING: thin_repair not found in path $PATH" >&2;}
 	;;
 esac
 
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
+$as_echo_n "checking whether thin_check supports the needs-check flag... " >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
+$as_echo "$THIN_CHECK_NEEDS_CHECK" >&6; }
+if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
+
+$as_echo "#define THIN_CHECK_NEEDS_CHECK 1" >>confdefs.h
+
+fi
+
 
 cat >>confdefs.h <<_ACEOF
 #define THIN_CHECK_CMD "$THIN_CHECK_CMD"
diff --git a/configure.in b/configure.in
index 09ca1b5..3a8e5d9 100644
--- a/configure.in
+++ b/configure.in
@@ -433,16 +433,10 @@ case "$THIN" in
 esac
 
 dnl -- thin_check needs-check flag
-AC_MSG_CHECKING(whether thin_check supports the needs-check flag)
 AC_ARG_ENABLE(thin_check_needs_check,
 	      AC_HELP_STRING([--disable-thin_check_needs_check],
 			     [required if thin_check version is < 0.3.0]),
 	      THIN_CHECK_NEEDS_CHECK=$enableval, THIN_CHECK_NEEDS_CHECK=yes)
-AC_MSG_RESULT($THIN_CHECK_NEEDS_CHECK)
-
-if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
-	AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
-fi
 
 # Test if necessary thin tools are available
 # if not - use plain defaults and warn user
@@ -455,22 +449,21 @@ case "$THIN" in
 			AC_MSG_WARN([thin_check not found in path $PATH])
 			THIN_CHECK_CMD=/usr/sbin/thin_check
 			THIN_CONFIGURE_WARN=y
-		else
-			if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
-				THIN_CHECK_VSN=`"$THIN_CHECK_CMD" -V 2>/dev/null`
-				THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
-				THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
-
-				if test -z "$THIN_CHECK_VSN_MAJOR" -o -z "$THIN_CHECK_VSN_MINOR" ; then
-					AC_MSG_WARN(Found thin_check version "$THIN_CHECK_VSN")
-					THIN_CHECK_VERSION_WARN=y 
-				else
-					if test "$THIN_CHECK_VSN_MAJOR" -eq 0 -a "$THIN_CHECK_VSN_MINOR" -lt 3 ; then
-						AC_MSG_WARN(Found thin_check version "$THIN_CHECK_VSN")
-						THIN_CHECK_VERSION_WARN=y
-					fi
-				fi
-			fi
+		fi
+	fi
+	if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
+		THIN_CHECK_VSN=`"$THIN_CHECK_CMD" -V 2>/dev/null`
+		THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
+		THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
+
+		if test -z "$THIN_CHECK_VSN_MAJOR" -o -z "$THIN_CHECK_VSN_MINOR"; then
+			AC_MSG_WARN([$THIN_CHECK_CMD: Bad version "$THIN_CHECK_VSN" found])
+			THIN_CHECK_VERSION_WARN=y
+			THIN_CHECK_NEEDS_CHECK=no
+		elif test "$THIN_CHECK_VSN_MAJOR" -eq 0 -a "$THIN_CHECK_VSN_MINOR" -lt 3; then
+			AC_MSG_WARN([$THIN_CHECK_CMD: Old version "$THIN_CHECK_VSN" found])
+			THIN_CHECK_VERSION_WARN=y
+			THIN_CHECK_NEEDS_CHECK=no
 		fi
 	fi
 	# Empty means a config way to ignore thin checking
@@ -494,6 +487,12 @@ case "$THIN" in
 	;;
 esac
 
+AC_MSG_CHECKING([whether thin_check supports the needs-check flag])
+AC_MSG_RESULT([$THIN_CHECK_NEEDS_CHECK])
+if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
+	AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
+fi
+
 AC_DEFINE_UNQUOTED([THIN_CHECK_CMD], ["$THIN_CHECK_CMD"],
 		   [The path to 'thin_check', if available.])
 


