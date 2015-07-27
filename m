From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 27 Jul 2015 13:45:25 +0000 (UTC)
Subject: master - configure: Enable realtime by default, if present.
Message-ID: <20150727134525.A977761069@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e333e9b5c0fcae2014dcb22f14d288b440b9576
Commit:        3e333e9b5c0fcae2014dcb22f14d288b440b9576
Parent:        1568ed4d20c2ff67e6cf3e17e158d5153e5f48f8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 27 14:44:58 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 27 14:44:58 2015 +0100

configure: Enable realtime by default, if present.

---
 configure    |    6 +++++-
 configure.in |    5 +++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index 070f3a9..97fe8f2 100755
--- a/configure
+++ b/configure
@@ -1641,7 +1641,7 @@ Optional Features:
   --disable-cache_check_needs_check
                           required if cache_check version is < 0.5
   --disable-readline      disable readline support
-  --enable-realtime       enable realtime clock support
+  --disable-realtime      disable realtime clock support
   --enable-ocf            enable Open Cluster Framework (OCF) compliant
                           resource agents
   --enable-cmirrord       enable the cluster mirror log daemon
@@ -9206,6 +9206,8 @@ $as_echo_n "checking whether to enable realtime support... " >&6; }
 # Check whether --enable-realtime was given.
 if test "${enable_realtime+set}" = set; then :
   enableval=$enable_realtime; REALTIME=$enableval
+else
+  REALTIME=yes
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $REALTIME" >&5
@@ -12796,6 +12798,8 @@ $as_echo "#define HAVE_REALTIME 1" >>confdefs.h
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Disabling realtime clock" >&5
 $as_echo "$as_me: WARNING: Disabling realtime clock" >&2;}
 	fi
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $HAVE_REALTIME" >&5
+$as_echo "$HAVE_REALTIME" >&6; }
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for struct stat has st_ctim." >&5
diff --git a/configure.in b/configure.in
index e64baa3..c2cd69a 100644
--- a/configure.in
+++ b/configure.in
@@ -659,8 +659,8 @@ AC_MSG_RESULT($READLINE)
 dnl -- Disable realtime clock support
 AC_MSG_CHECKING(whether to enable realtime support)
 AC_ARG_ENABLE(realtime,
-	      AC_HELP_STRING([--enable-realtime], [enable realtime clock support]),
-	      REALTIME=$enableval)
+	      AC_HELP_STRING([--disable-realtime], [disable realtime clock support]),
+	      REALTIME=$enableval, REALTIME=yes)
 AC_MSG_RESULT($REALTIME)
 
 ################################################################################
@@ -1573,6 +1573,7 @@ if test "$REALTIME" = yes; then
 	else
 		AC_MSG_WARN(Disabling realtime clock)
 	fi
+	AC_MSG_RESULT($HAVE_REALTIME)
 fi
 
 dnl Check if the system has struct stat st_ctim.


