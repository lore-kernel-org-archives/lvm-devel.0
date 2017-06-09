From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 16:56:35 -0400
Subject: master - configure: warn about older version of cache_check
Message-ID: <201706092056.v59KuZka018621@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=358eee15f30778bc20c2723532bffdf1d8176684
Commit:        358eee15f30778bc20c2723532bffdf1d8176684
Parent:        1c916ec5ffd37cfb7be2101b93a2dc91aa2ef7f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 22:30:23 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 22:32:12 2017 +0200

configure: warn about older version of cache_check

For proper usage of Cache kernel metadata format V2,
new cache_check tool is basically mandatory.

Print warning during configure time about this problem.
---
 configure    |   15 +++++++++++++--
 configure.in |   10 +++++++++-
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index 28b0488..9d0d97c 100755
--- a/configure
+++ b/configure
@@ -9256,6 +9256,11 @@ $as_echo "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" fo
 				CACHE_CHECK_VERSION_WARN=y
 				CACHE_CHECK_NEEDS_CHECK=no
 			fi
+			if test "$CACHE_CHECK_VSN_MINOR" -lt 7 ; then
+				{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" does not support new cache format V2" >&5
+$as_echo "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" does not support new cache format V2" >&2;}
+				CACHE_CHECK_VERSION_WARN=y
+			fi
 		fi
 	fi
 	# Empty means a config way to ignore cache dumping
@@ -17044,8 +17049,8 @@ $as_echo "$as_me: WARNING: Support for thin provisioning is limited since some t
 fi
 
 if test -n "$THIN_CHECK_VERSION_WARN"; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&5
-$as_echo "$as_me: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&2;}
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should also install latest thin_check vsn 0.7.0 (or later) for lvm2 thin provisioning" >&5
+$as_echo "$as_me: WARNING: You should also install latest thin_check vsn 0.7.0 (or later) for lvm2 thin provisioning" >&2;}
 fi
 
 if test -n "$CACHE_CONFIGURE_WARN"; then :
@@ -17053,6 +17058,12 @@ if test -n "$CACHE_CONFIGURE_WARN"; then :
 $as_echo "$as_me: WARNING: Support for cache is limited since some cache tools are missing!" >&2;}
 fi
 
+if test -n "$CACHE_CHECK_VERSION_WARN"; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should install latest cache_check vsn 0.7.0 to use lvm2 cache metadata format 2" >&5
+$as_echo "$as_me: WARNING: You should install latest cache_check vsn 0.7.0 to use lvm2 cache metadata format 2" >&2;}
+fi
+
+
 if test "$ODIRECT" != yes; then :
   { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
 $as_echo "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
diff --git a/configure.in b/configure.in
index 8603a12..0ca6b43 100644
--- a/configure.in
+++ b/configure.in
@@ -617,6 +617,10 @@ case "$CACHE" in
 				CACHE_CHECK_VERSION_WARN=y
 				CACHE_CHECK_NEEDS_CHECK=no
 			fi
+			if test "$CACHE_CHECK_VSN_MINOR" -lt 7 ; then
+				AC_MSG_WARN([$CACHE_CHECK_CMD: Old version "$CACHE_CHECK_VSN" does not support new cache format V2])
+				CACHE_CHECK_VERSION_WARN=y
+			fi
 		fi
 	fi
 	# Empty means a config way to ignore cache dumping
@@ -2256,10 +2260,14 @@ AS_IF([test -n "$THIN_CONFIGURE_WARN"],
       [AC_MSG_WARN([Support for thin provisioning is limited since some thin provisioning tools are missing!])])
 
 AS_IF([test -n "$THIN_CHECK_VERSION_WARN"],
-      [AC_MSG_WARN([You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning])])
+      [AC_MSG_WARN([You should also install latest thin_check vsn 0.7.0 (or later) for lvm2 thin provisioning])])
 
 AS_IF([test -n "$CACHE_CONFIGURE_WARN"],
       [AC_MSG_WARN([Support for cache is limited since some cache tools are missing!])])
 
+AS_IF([test -n "$CACHE_CHECK_VERSION_WARN"],
+      [AC_MSG_WARN([You should install latest cache_check vsn 0.7.0 to use lvm2 cache metadata format 2])])
+
+
 AS_IF([test "$ODIRECT" != yes],
       [AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])])


