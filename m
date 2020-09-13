From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 13 Sep 2020 22:16:40 +0000 (GMT)
Subject: master - configure: just upper case start of sentence
Message-ID: <20200913221640.880C43951883@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27383a4b3d621e6c2497c8b1f55e2a700a6ef39a
Commit:        27383a4b3d621e6c2497c8b1f55e2a700a6ef39a
Parent:        2101e324f947d1d9d7c4e19996a18b1c88d82742
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 19:04:22 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 00:15:14 2020 +0200

configure: just upper case start of sentence

---
 configure    | 4 ++--
 configure.ac | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index 7fdd20206..219a3ba2f 100755
--- a/configure
+++ b/configure
@@ -15299,8 +15299,8 @@ $as_echo "$as_me: WARNING: You should install latest cache_check vsn 0.7.0 to us
 fi
 
 if test -n "$VDO_CONFIGURE_WARN"; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&5
-$as_echo "$as_me: WARNING: unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&2;}
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&5
+$as_echo "$as_me: WARNING: Unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!" >&2;}
 fi
 
 
diff --git a/configure.ac b/configure.ac
index 3e9ed25f5..537dc801c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1900,7 +1900,7 @@ AS_IF([test -n "$CACHE_CHECK_VERSION_WARN"],
       [AC_MSG_WARN([You should install latest cache_check vsn 0.7.0 to use lvm2 cache metadata format 2])])
 
 AS_IF([test -n "$VDO_CONFIGURE_WARN"],
-      [AC_MSG_WARN([unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!])])
+      [AC_MSG_WARN([Unrecognized 'vdoformat' tool is REQUIRED for VDO logical volume creation!])])
 
 
 AS_IF([test "$ODIRECT" != yes],


