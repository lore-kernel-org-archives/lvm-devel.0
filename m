From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 10 Sep 2020 21:56:15 +0000 (GMT)
Subject: master - configure: compile with vdo and writecache by default
Message-ID: <20200910215615.9F44B3985431@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d392776b0c65c02f53435cbc1adbbb6765dfaa6
Commit:        6d392776b0c65c02f53435cbc1adbbb6765dfaa6
Parent:        1f54129c4ea4cc88571b75b7d093107985913315
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 9 15:56:06 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 23:54:10 2020 +0200

configure: compile with vdo and writecache by default

Enable compilation of vdo and writecache support as internaly
supported segment types by default.

For disabling use:

--with-vdo=none
--with-writcache=none
---
 WHATS_NEW    | 1 +
 configure    | 4 ++--
 configure.ac | 4 ++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8f33c8ae4..1171eb2a9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Configure --with-vdo and --with-writecache as internal segments.
   Improving VDO man page examples.
   Switch code base to use flexible array syntax.
   Fix 64bit math when calculation cachevol size.
diff --git a/configure b/configure
index 716ee9ca7..7fdd20206 100755
--- a/configure
+++ b/configure
@@ -9586,7 +9586,7 @@ $as_echo_n "checking whether to include vdo... " >&6; }
 if test "${with_vdo+set}" = set; then :
   withval=$with_vdo; VDO=$withval
 else
-  VDO="none"
+  VDO="internal"
 fi
 
 
@@ -9746,7 +9746,7 @@ $as_echo_n "checking whether to include writecache... " >&6; }
 if test "${with_writecache+set}" = set; then :
   withval=$with_writecache; WRITECACHE=$withval
 else
-  WRITECACHE="none"
+  WRITECACHE="internal"
 fi
 
 
diff --git a/configure.ac b/configure.ac
index 9a0e41a81..3e9ed25f5 100644
--- a/configure.ac
+++ b/configure.ac
@@ -607,7 +607,7 @@ AC_MSG_CHECKING(whether to include vdo)
 AC_ARG_WITH(vdo,
 	    AC_HELP_STRING([--with-vdo=TYPE],
 			   [vdo support: internal/none [internal]]),
-			   VDO=$withval, VDO="none")
+			   VDO=$withval, VDO="internal")
 
 AC_MSG_RESULT($VDO)
 
@@ -655,7 +655,7 @@ AC_MSG_CHECKING(whether to include writecache)
 AC_ARG_WITH(writecache,
 	    AC_HELP_STRING([--with-writecache=TYPE],
 			   [writecache support: internal/none [none]]),
-			   WRITECACHE=$withval, WRITECACHE="none")
+			   WRITECACHE=$withval, WRITECACHE="internal")
 
 AC_MSG_RESULT($WRITECACHE)
 


