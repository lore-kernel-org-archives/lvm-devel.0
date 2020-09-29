From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 29 Sep 2020 08:45:18 +0000 (GMT)
Subject: master - configure: update help
Message-ID: <20200929084518.5C6E03844008@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ed11170da87089bbfb263c84b25b53159ae1558
Commit:        3ed11170da87089bbfb263c84b25b53159ae1558
Parent:        655342427da621174f04506fb7002f54af832e07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 28 18:51:32 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 29 10:43:56 2020 +0200

configure: update help

Help shows new defaults.
---
 configure    | 10 +++++-----
 configure.ac | 10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/configure b/configure
index d39ce1b98..c125aade1 100755
--- a/configure
+++ b/configure
@@ -1722,16 +1722,16 @@ Optional Packages:
                           cache_restore tool: [autodetect]
   --with-vdo=TYPE         vdo support: internal/none [internal]
   --with-vdo-format=PATH  vdoformat tool: [autodetect]
-  --with-writecache=TYPE  writecache support: internal/none [none]
-  --with-integrity=TYPE   integrity support: internal/none [none]
+  --with-writecache=TYPE  writecache support: internal/none [internal]
+  --with-integrity=TYPE   integrity support: internal/none [internal]
   --with-ocfdir=DIR       install OCF files in
                           [PREFIX/lib/ocf/resource.d/lvm2]
   --with-default-pid-dir=PID_DIR
-                          Default directory to keep PID files in. [autodetect]
+                          default directory to keep PID files in [autodetect]
   --with-default-dm-run-dir=DM_RUN_DIR
-                          Default DM run directory. [autodetect]
+                          default DM run directory [autodetect]
   --with-default-run-dir=RUN_DIR
-                          Default LVM run directory. [autodetect_run_dir/lvm]
+                          default LVM run directory [autodetect_run_dir/lvm]
   --with-cmirrord-pidfile=PATH
                           cmirrord pidfile [PID_DIR/cmirrord.pid]
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
diff --git a/configure.ac b/configure.ac
index 3b06e472b..148bde426 100644
--- a/configure.ac
+++ b/configure.ac
@@ -654,7 +654,7 @@ dnl -- writecache inclusion type
 AC_MSG_CHECKING(whether to include writecache)
 AC_ARG_WITH(writecache,
 	    AC_HELP_STRING([--with-writecache=TYPE],
-			   [writecache support: internal/none [none]]),
+			   [writecache support: internal/none [internal]]),
 			   WRITECACHE=$withval, WRITECACHE="internal")
 
 AC_MSG_RESULT($WRITECACHE)
@@ -672,7 +672,7 @@ dnl -- integrity inclusion type
 AC_MSG_CHECKING(whether to include integrity)
 AC_ARG_WITH(integrity,
 	    AC_HELP_STRING([--with-integrity=TYPE],
-			   [integrity support: internal/none [none]]),
+			   [integrity support: internal/none [internal]]),
 			   INTEGRITY=$withval, INTEGRITY="internal")
 
 AC_MSG_RESULT($INTEGRITY)
@@ -740,7 +740,7 @@ dnl -- Set up pidfile and run directory
 AH_TEMPLATE(DEFAULT_PID_DIR)
 AC_ARG_WITH(default-pid-dir,
 	    AC_HELP_STRING([--with-default-pid-dir=PID_DIR],
-			   [Default directory to keep PID files in. [autodetect]]),
+			   [default directory to keep PID files in [autodetect]]),
 	    DEFAULT_PID_DIR="$withval", DEFAULT_PID_DIR=$RUN_DIR)
 AC_DEFINE_UNQUOTED(DEFAULT_PID_DIR, ["$DEFAULT_PID_DIR"],
 		   [Default directory to keep PID files in.])
@@ -748,7 +748,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_PID_DIR, ["$DEFAULT_PID_DIR"],
 AH_TEMPLATE(DEFAULT_DM_RUN_DIR, [Name of default DM run directory.])
 AC_ARG_WITH(default-dm-run-dir,
 	    AC_HELP_STRING([--with-default-dm-run-dir=DM_RUN_DIR],
-			   [ Default DM run directory. [autodetect]]),
+			   [default DM run directory [autodetect]]),
 	    DEFAULT_DM_RUN_DIR="$withval", DEFAULT_DM_RUN_DIR=$RUN_DIR)
 AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR, ["$DEFAULT_DM_RUN_DIR"],
 		   [Default DM run directory.])
@@ -756,7 +756,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR, ["$DEFAULT_DM_RUN_DIR"],
 AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default LVM run directory.])
 AC_ARG_WITH(default-run-dir,
 	    AC_HELP_STRING([--with-default-run-dir=RUN_DIR],
-			   [Default LVM run directory. [autodetect_run_dir/lvm]]),
+			   [default LVM run directory [autodetect_run_dir/lvm]]),
 	    DEFAULT_RUN_DIR="$withval", DEFAULT_RUN_DIR="$RUN_DIR/lvm")
 AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR, ["$DEFAULT_RUN_DIR"],
 		   [Default LVM run directory.])


