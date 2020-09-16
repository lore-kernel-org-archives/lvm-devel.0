From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Sep 2020 20:18:31 +0000 (GMT)
Subject: master - configure: enable integrity by default
Message-ID: <20200916201831.C3827384C007@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=72b931d66407fedc68735324996fa190ebaf1a3f
Commit:        72b931d66407fedc68735324996fa190ebaf1a3f
Parent:        46f43589d00d0bcb74028df602897509db7d93b9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 16 15:14:51 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 16 15:14:51 2020 -0500

configure: enable integrity by default

---
 WHATS_NEW    | 1 +
 configure    | 2 +-
 configure.ac | 2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 15f4d8e6a..0f6412fc5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Configure --with-integrity enabled.
   Restore lost signal blocking while VG lock is held.
   Improve estimation of needed extents when creating thin-pool.
   Use extra 1% when resizing thin-pool metadata LV with --use-policy.
diff --git a/configure b/configure
index 219a3ba2f..f7b681cad 100755
--- a/configure
+++ b/configure
@@ -9771,7 +9771,7 @@ $as_echo_n "checking whether to include integrity... " >&6; }
 if test "${with_integrity+set}" = set; then :
   withval=$with_integrity; INTEGRITY=$withval
 else
-  INTEGRITY="none"
+  INTEGRITY="internal"
 fi
 
 
diff --git a/configure.ac b/configure.ac
index 537dc801c..c2a72abf2 100644
--- a/configure.ac
+++ b/configure.ac
@@ -673,7 +673,7 @@ AC_MSG_CHECKING(whether to include integrity)
 AC_ARG_WITH(integrity,
 	    AC_HELP_STRING([--with-integrity=TYPE],
 			   [integrity support: internal/none [none]]),
-			   INTEGRITY=$withval, INTEGRITY="none")
+			   INTEGRITY=$withval, INTEGRITY="internal")
 
 AC_MSG_RESULT($INTEGRITY)
 


