From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:02 +0000 (UTC)
Subject: master - configure: better parsing of cache_check version
Message-ID: <20150903213602.DA77360EB9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ce334923f1f82e0ca5dcbd0f5e830109c1f9c0b
Commit:        5ce334923f1f82e0ca5dcbd0f5e830109c1f9c0b
Parent:        49b5022993cd57f7fda416bd62d182cdbe209fb8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 3 22:48:56 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:36 2015 +0200

configure: better parsing of cache_check version

Properly read also version string like  0.5.5-1.fc24
and read just first 3 digits split by '.'

Also remove one extra  $HAVE_REALTIME.
---
 configure    |    4 +---
 configure.in |    3 +--
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/configure b/configure
index f4820c4..c7b7dd5 100755
--- a/configure
+++ b/configure
@@ -8816,7 +8816,7 @@ $as_echo "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
 	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
 		$CACHE_CHECK_CMD -V 2>/dev/null >conftest.tmp
 		read -r CACHE_CHECK_VSN < conftest.tmp
-		IFS=. read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH < conftest.tmp
+		IFS=.- read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH LEFTOVER < conftest.tmp
 		rm -f conftest.tmp
 
 		# Require version >= 0.5.4 for --clear-needs-check-flag
@@ -12852,8 +12852,6 @@ $as_echo "#define HAVE_REALTIME 1" >>confdefs.h
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Disabling realtime clock" >&5
 $as_echo "$as_me: WARNING: Disabling realtime clock" >&2;}
 	fi
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $HAVE_REALTIME" >&5
-$as_echo "$HAVE_REALTIME" >&6; }
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for struct stat has st_ctim." >&5
diff --git a/configure.in b/configure.in
index 3d83af5..868b373 100644
--- a/configure.in
+++ b/configure.in
@@ -586,7 +586,7 @@ case "$CACHE" in
 	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
 		$CACHE_CHECK_CMD -V 2>/dev/null >conftest.tmp
 		read -r CACHE_CHECK_VSN < conftest.tmp
-		IFS=. read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH < conftest.tmp
+		IFS=.- read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH LEFTOVER < conftest.tmp
 		rm -f conftest.tmp
 
 		# Require version >= 0.5.4 for --clear-needs-check-flag
@@ -1585,7 +1585,6 @@ if test "$REALTIME" = yes; then
 	else
 		AC_MSG_WARN(Disabling realtime clock)
 	fi
-	AC_MSG_RESULT($HAVE_REALTIME)
 fi
 
 dnl Check if the system has struct stat st_ctim.


