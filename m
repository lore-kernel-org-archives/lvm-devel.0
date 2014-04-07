From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  7 Apr 2014 15:47:18 +0000 (UTC)
Subject: master - autoreconf
Message-ID: <20140407154718.044FF60ECE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f13977e8fe346c0d50fe7f8810ec66c7518c9041
Commit:        f13977e8fe346c0d50fe7f8810ec66c7518c9041
Parent:        eb1602406b8df5eeb01f3d4a05977878381638c7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Apr 7 16:47:07 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Apr 7 16:47:07 2014 +0100

autoreconf

---
 configure |   65 ++++++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 43 insertions(+), 22 deletions(-)

diff --git a/configure b/configure
index 7967449..9b5c2e7 100755
--- a/configure
+++ b/configure
@@ -7218,6 +7218,24 @@ $as_echo "#define THIN_INTERNAL 1" >>confdefs.h
   *) as_fn_error $? "--with-thin parameter invalid ($THIN)" "$LINENO" 5 ;;
 esac
 
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
+$as_echo_n "checking whether thin_check supports the needs-check flag... " >&6; }
+# Check whether --enable-thin_check_needs_check was given.
+if test "${enable_thin_check_needs_check+set}" = set; then :
+  enableval=$enable_thin_check_needs_check; THIN_CHECK_NEEDS_CHECK=$enableval
+else
+  THIN_CHECK_NEEDS_CHECK=yes
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
+$as_echo "$THIN_CHECK_NEEDS_CHECK" >&6; }
+
+if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
+
+$as_echo "#define THIN_CHECK_NEEDS_CHECK 1" >>confdefs.h
+
+fi
+
 # Test if necessary thin tools are available
 # if not - use plain defaults and warn user
 case "$THIN" in
@@ -7322,12 +7340,30 @@ else
   THIN_CHECK_CMD="$ac_cv_path_THIN_CHECK_CMD"
 fi
 
-		test -z "$THIN_CHECK_CMD" && {
+		if test -z "$THIN_CHECK_CMD"; then
 			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_check not found in path $PATH" >&5
 $as_echo "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
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
+					{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Found thin_check version \"$THIN_CHECK_VSN\"" >&5
+$as_echo "$as_me: WARNING: Found thin_check version \"$THIN_CHECK_VSN\"" >&2;}
+					THIN_CHECK_VERSION_WARN=y
+				else
+					if test "$THIN_CHECK_VSN_MAJOR" -eq 0 -a "$THIN_CHECK_VSN_MINOR" -lt 3 ; then
+						{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Found thin_check version \"$THIN_CHECK_VSN\"" >&5
+$as_echo "$as_me: WARNING: Found thin_check version \"$THIN_CHECK_VSN\"" >&2;}
+						THIN_CHECK_VERSION_WARN=y
+					fi
+				fi
+			fi
+		fi
 	fi
 	# Empty means a config way to ignore thin checking
 	if test "$THIN_DUMP_CMD" = "autodetect"; then
@@ -7564,24 +7600,6 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
-$as_echo_n "checking whether thin_check supports the needs-check flag... " >&6; }
-# Check whether --enable-thin_check_needs_check was given.
-if test "${enable_thin_check_needs_check+set}" = set; then :
-  enableval=$enable_thin_check_needs_check; THIN_CHECK_NEEDS_CHECK=$enableval
-else
-  THIN_CHECK_NEEDS_CHECK=yes
-fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
-$as_echo "$THIN_CHECK_NEEDS_CHECK" >&6; }
-
-if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
-
-$as_echo "#define THIN_CHECK_NEEDS_CHECK 1" >>confdefs.h
-
-fi
-
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include cache" >&5
 $as_echo_n "checking whether to include cache... " >&6; }
@@ -12881,7 +12899,10 @@ fi
 test -n "$THIN_CONFIGURE_WARN" && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&5
 $as_echo "$as_me: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&2;}
 
+test -n "$THIN_CHECK_VERSION_WARN" && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&5
+$as_echo "$as_me: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&2;}
+
 if test x$ODIRECT != xyes; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Warning: O_DIRECT disabled: low-memory pvmove may lock up" >&5
-$as_echo "$as_me: WARNING: Warning: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
+$as_echo "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
 fi


