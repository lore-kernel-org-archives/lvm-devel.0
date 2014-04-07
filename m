From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  7 Apr 2014 15:45:41 +0000 (UTC)
Subject: master - configure: Warn if old thin_check tool found.
Message-ID: <20140407154541.3E16360DD9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb1602406b8df5eeb01f3d4a05977878381638c7
Commit:        eb1602406b8df5eeb01f3d4a05977878381638c7
Parent:        2fd5c67f329159cfae29e2d0fe98fe2fbb6d9a8f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Apr 7 16:44:29 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Apr 7 16:44:29 2014 +0100

configure: Warn if old thin_check tool found.

If thin_check is auto-detected, issue a warning if the version is older
than 0.3.x.
---
 configure.in |   48 +++++++++++++++++++++++++++++++++---------------
 1 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/configure.in b/configure.in
index d8cbe5c..6b84e47 100644
--- a/configure.in
+++ b/configure.in
@@ -433,6 +433,18 @@ case "$THIN" in
   *) AC_MSG_ERROR([--with-thin parameter invalid ($THIN)]) ;;
 esac
 
+dnl -- thin_check needs-check flag
+AC_MSG_CHECKING(whether thin_check supports the needs-check flag)
+AC_ARG_ENABLE(thin_check_needs_check,
+	      AC_HELP_STRING([--disable-thin_check_needs_check],
+			     [required if thin_check version is < 0.3.0]),
+	      THIN_CHECK_NEEDS_CHECK=$enableval, THIN_CHECK_NEEDS_CHECK=yes)
+AC_MSG_RESULT($THIN_CHECK_NEEDS_CHECK)
+
+if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
+	AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
+fi
+
 # Test if necessary thin tools are available
 # if not - use plain defaults and warn user
 case "$THIN" in
@@ -440,11 +452,27 @@ case "$THIN" in
 	# Empty means a config way to ignore thin checking
 	if test "$THIN_CHECK_CMD" = "autodetect"; then
 		AC_PATH_TOOL(THIN_CHECK_CMD, thin_check)
-		test -z "$THIN_CHECK_CMD" && {
+		if test -z "$THIN_CHECK_CMD"; then
 			AC_MSG_WARN([thin_check not found in path $PATH])
 			THIN_CHECK_CMD=/usr/sbin/thin_check
 			THIN_CONFIGURE_WARN=y
-		}
+		else
+			if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
+				THIN_CHECK_VSN=`"$THIN_CHECK_CMD" -V 2>/dev/null`
+				THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
+				THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
+
+				if test -z "$THIN_CHECK_VSN_MAJOR" -o -z "$THIN_CHECK_VSN_MINOR" ; then
+					AC_MSG_WARN(Found thin_check version "$THIN_CHECK_VSN")
+					THIN_CHECK_VERSION_WARN=y 
+				else
+					if test "$THIN_CHECK_VSN_MAJOR" -eq 0 -a "$THIN_CHECK_VSN_MINOR" -lt 3 ; then
+						AC_MSG_WARN(Found thin_check version "$THIN_CHECK_VSN")
+						THIN_CHECK_VERSION_WARN=y
+					fi
+				fi
+			fi
+		fi
 	fi
 	# Empty means a config way to ignore thin checking
 	if test "$THIN_DUMP_CMD" = "autodetect"; then
@@ -476,18 +504,6 @@ AC_DEFINE_UNQUOTED([THIN_DUMP_CMD], ["$THIN_DUMP_CMD"],
 AC_DEFINE_UNQUOTED([THIN_REPAIR_CMD], ["$THIN_REPAIR_CMD"],
 		   [The path to 'thin_repair', if available.])
 
-dnl -- thin_check needs-check flag
-AC_MSG_CHECKING(whether thin_check supports the needs-check flag)
-AC_ARG_ENABLE(thin_check_needs_check,
-	      AC_HELP_STRING([--disable-thin_check_needs_check],
-			     [required if thin_check version is < 0.3.0]),
-	      THIN_CHECK_NEEDS_CHECK=$enableval, THIN_CHECK_NEEDS_CHECK=yes)
-AC_MSG_RESULT($THIN_CHECK_NEEDS_CHECK)
-
-if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
-	AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
-fi
-
 ################################################################################
 dnl -- cache inclusion type
 AC_MSG_CHECKING(whether to include cache)
@@ -1825,6 +1841,8 @@ AC_OUTPUT
 
 test -n "$THIN_CONFIGURE_WARN" && AC_MSG_WARN([Support for thin provisioning is limited since some thin provisioning tools are missing!])
 
+test -n "$THIN_CHECK_VERSION_WARN" && AC_MSG_WARN(You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning)
+
 if test x$ODIRECT != xyes; then
-  AC_MSG_WARN(Warning: O_DIRECT disabled: low-memory pvmove may lock up)
+  AC_MSG_WARN(O_DIRECT disabled: low-memory pvmove may lock up)
 fi


