From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:40:47 +0000 (UTC)
Subject: master - configure: --clear-need-check-flag needs 0.5.4
Message-ID: <20150812124047.7A1CA61086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=664a9f4830925cc3f51934dc09f9e2f3963c0de2
Commit:        664a9f4830925cc3f51934dc09f9e2f3963c0de2
Parent:        3ea396e9d220cec55fd4e139be7ae486cb4ddb91
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 15 16:08:02 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:11:15 2015 +0200

configure: --clear-need-check-flag needs 0.5.4

Require version 5.4 of cache_check tool where this option
will work correctly.
---
 WHATS_NEW    |    1 +
 configure    |   25 ++++++++++++++++---------
 configure.in |   25 ++++++++++++++++---------
 3 files changed, 33 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8241dc1..d28e06c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.128 - 
 ===================================
+  Require cache_check 0.5.4 for use of --clear-needs-check-flag.
   Fix lvmetad udev rules to not override SYSTEMD_WANTS, add the service instead.
 
 Version 2.02.127 - 10th August 2015
diff --git a/configure b/configure
index 07059b8..b17e5a3 100755
--- a/configure
+++ b/configure
@@ -8813,20 +8813,27 @@ $as_echo "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
 		fi
 	fi
 	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
-		CACHE_CHECK_VSN=`"$CACHE_CHECK_CMD" -V 2>/dev/null`
-		CACHE_CHECK_VSN_MAJOR=`echo "$CACHE_CHECK_VSN" | $AWK -F '.' '{print $1}'`
-		CACHE_CHECK_VSN_MINOR=`echo "$CACHE_CHECK_VSN" | $AWK -F '.' '{print $2}'`
-
-		if test -z "$CACHE_CHECK_VSN_MAJOR" -o -z "$CACHE_CHECK_VSN_MINOR"; then
+		$CACHE_CHECK_CMD -V 2>/dev/null >conftest.tmp
+		read -r CACHE_CHECK_VSN < conftest.tmp
+		IFS=. read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH < conftest.tmp
+		rm -f conftest.tmp
+
+		# Require version >= 0.5.4 for --clear-needs-check-flag
+		if test -z "$CACHE_CHECK_VSN_MAJOR" \
+			|| test -z "$CACHE_CHECK_VSN_MINOR" \
+			|| test -z "$CACHE_CHECK_VSN_PATCH"; then
 			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Bad version \"$CACHE_CHECK_VSN\" found" >&5
 $as_echo "$as_me: WARNING: $CACHE_CHECK_CMD: Bad version \"$CACHE_CHECK_VSN\" found" >&2;}
 			CACHE_CHECK_VERSION_WARN=y
 			CACHE_CHECK_NEEDS_CHECK=no
-		elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0 -a "$CACHE_CHECK_VSN_MINOR" -lt 5; then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&5
+		elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0 ; then
+			if test "$CACHE_CHECK_VSN_MINOR" -lt 5 \
+				|| test "$CACHE_CHECK_VSN_MINOR" -eq 5 -a "$CACHE_CHECK_VSN_PATCH" -lt 4; then
+				{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&5
 $as_echo "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&2;}
-			CACHE_CHECK_VERSION_WARN=y
-			CACHE_CHECK_NEEDS_CHECK=no
+				CACHE_CHECK_VERSION_WARN=y
+				CACHE_CHECK_NEEDS_CHECK=no
+			fi
 		fi
 	fi
 	# Empty means a config way to ignore cache dumping
diff --git a/configure.in b/configure.in
index 1825fb7..243b634 100644
--- a/configure.in
+++ b/configure.in
@@ -584,18 +584,25 @@ case "$CACHE" in
 		fi
 	fi
 	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
-		CACHE_CHECK_VSN=`"$CACHE_CHECK_CMD" -V 2>/dev/null`
-		CACHE_CHECK_VSN_MAJOR=`echo "$CACHE_CHECK_VSN" | $AWK -F '.' '{print $1}'`
-		CACHE_CHECK_VSN_MINOR=`echo "$CACHE_CHECK_VSN" | $AWK -F '.' '{print $2}'`
-
-		if test -z "$CACHE_CHECK_VSN_MAJOR" -o -z "$CACHE_CHECK_VSN_MINOR"; then
+		$CACHE_CHECK_CMD -V 2>/dev/null >conftest.tmp
+		read -r CACHE_CHECK_VSN < conftest.tmp
+		IFS=. read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH < conftest.tmp
+		rm -f conftest.tmp
+
+		# Require version >= 0.5.4 for --clear-needs-check-flag
+		if test -z "$CACHE_CHECK_VSN_MAJOR" \
+			|| test -z "$CACHE_CHECK_VSN_MINOR" \
+			|| test -z "$CACHE_CHECK_VSN_PATCH"; then
 			AC_MSG_WARN([$CACHE_CHECK_CMD: Bad version "$CACHE_CHECK_VSN" found])
 			CACHE_CHECK_VERSION_WARN=y
 			CACHE_CHECK_NEEDS_CHECK=no
-		elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0 -a "$CACHE_CHECK_VSN_MINOR" -lt 5; then
-			AC_MSG_WARN([$CACHE_CHECK_CMD: Old version "$CACHE_CHECK_VSN" found])
-			CACHE_CHECK_VERSION_WARN=y
-			CACHE_CHECK_NEEDS_CHECK=no
+		elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0 ; then
+			if test "$CACHE_CHECK_VSN_MINOR" -lt 5 \
+				|| test "$CACHE_CHECK_VSN_MINOR" -eq 5 -a "$CACHE_CHECK_VSN_PATCH" -lt 4; then
+				AC_MSG_WARN([$CACHE_CHECK_CMD: Old version "$CACHE_CHECK_VSN" found])
+				CACHE_CHECK_VERSION_WARN=y
+				CACHE_CHECK_NEEDS_CHECK=no
+			fi
 		fi
 	fi
 	# Empty means a config way to ignore cache dumping


