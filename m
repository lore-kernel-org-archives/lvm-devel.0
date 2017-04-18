From: David Teigland <teigland@sourceware.org>
Date: Tue, 18 Apr 2017 12:22:38 -0400
Subject: master - configure: rename lockd to lvmlockd
Message-ID: <201704181622.v3IGMc1w020065@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a41a8430d6101af83160109f50df052aecc3818b
Commit:        a41a8430d6101af83160109f50df052aecc3818b
Parent:        aa25cfe084adf360c4ab1333a927b49279796f00
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 18 11:02:49 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 18 11:18:07 2017 -0500

configure: rename lockd to lvmlockd

---
 configure.in |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/configure.in b/configure.in
index 7dc3095..33cff4f 100644
--- a/configure.in
+++ b/configure.in
@@ -1150,10 +1150,10 @@ AC_MSG_RESULT($BUILD_LVMPOLLD)
 ################################################################################
 BUILD_LVMLOCKD=no
 
-dnl -- Build lockdsanlock
-AC_MSG_CHECKING(whether to build lockdsanlock)
-AC_ARG_ENABLE(lockd-sanlock,
-	      AC_HELP_STRING([--enable-lockd-sanlock],
+dnl -- Build lvmlockdsanlock
+AC_MSG_CHECKING(whether to build lvmlockdsanlock)
+AC_ARG_ENABLE(lvmlockd-sanlock,
+	      AC_HELP_STRING([--enable-lvmlockd-sanlock],
 			     [enable the LVM lock daemon using sanlock]),
 	      LOCKDSANLOCK=$enableval)
 AC_MSG_RESULT($LOCKDSANLOCK)
@@ -1168,10 +1168,10 @@ if test "$BUILD_LOCKDSANLOCK" = yes; then
 fi
 
 ################################################################################
-dnl -- Build lockddlm
-AC_MSG_CHECKING(whether to build lockddlm)
-AC_ARG_ENABLE(lockd-dlm,
-	      AC_HELP_STRING([--enable-lockd-dlm],
+dnl -- Build lvmlockddlm
+AC_MSG_CHECKING(whether to build lvmlockddlm)
+AC_ARG_ENABLE(lvmlockd-dlm,
+	      AC_HELP_STRING([--enable-lvmlockd-dlm],
 			     [enable the LVM lock daemon using dlm]),
 	      LOCKDDLM=$enableval)
 AC_MSG_RESULT($LOCKDDLM)


