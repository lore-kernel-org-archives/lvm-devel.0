From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:59 +0000 (GMT)
Subject: stable-2.02 - configure: update help
Message-ID: <20201016191159.0465D396EC85@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b5d51e821143202742c5ed7b1c57d48fe305913
Commit:        3b5d51e821143202742c5ed7b1c57d48fe305913
Parent:        7d6dfe901984aeeed23299ab3e6271432061f3be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 28 18:51:32 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:54 2020 +0200

configure: update help

Help shows new defaults.
---
 configure    | 6 +++---
 configure.ac | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/configure b/configure
index fe0e8e29c..df27701ab 100755
--- a/configure
+++ b/configure
@@ -1766,11 +1766,11 @@ Optional Packages:
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
   --with-clvmd=TYPE       build cluster LVM Daemon
                           The following cluster manager combinations are valid:
                            * cman                  (RHEL5 or equivalent)
diff --git a/configure.ac b/configure.ac
index 379d37f15..0e9de09f9 100644
--- a/configure.ac
+++ b/configure.ac
@@ -650,7 +650,7 @@ dnl -- Set up pidfile and run directory
 AH_TEMPLATE(DEFAULT_PID_DIR)
 AC_ARG_WITH(default-pid-dir,
 	    AC_HELP_STRING([--with-default-pid-dir=PID_DIR],
-			   [Default directory to keep PID files in. [autodetect]]),
+			   [default directory to keep PID files in [autodetect]]),
 	    DEFAULT_PID_DIR="$withval", DEFAULT_PID_DIR=$RUN_DIR)
 AC_DEFINE_UNQUOTED(DEFAULT_PID_DIR, ["$DEFAULT_PID_DIR"],
 		   [Default directory to keep PID files in.])
@@ -658,7 +658,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_PID_DIR, ["$DEFAULT_PID_DIR"],
 AH_TEMPLATE(DEFAULT_DM_RUN_DIR, [Name of default DM run directory.])
 AC_ARG_WITH(default-dm-run-dir,
 	    AC_HELP_STRING([--with-default-dm-run-dir=DM_RUN_DIR],
-			   [ Default DM run directory. [autodetect]]),
+			   [default DM run directory [autodetect]]),
 	    DEFAULT_DM_RUN_DIR="$withval", DEFAULT_DM_RUN_DIR=$RUN_DIR)
 AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR, ["$DEFAULT_DM_RUN_DIR"],
 		   [Default DM run directory.])
@@ -666,7 +666,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR, ["$DEFAULT_DM_RUN_DIR"],
 AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default LVM run directory.])
 AC_ARG_WITH(default-run-dir,
 	    AC_HELP_STRING([--with-default-run-dir=RUN_DIR],
-			   [Default LVM run directory. [autodetect_run_dir/lvm]]),
+			   [default LVM run directory [autodetect_run_dir/lvm]]),
 	    DEFAULT_RUN_DIR="$withval", DEFAULT_RUN_DIR="$RUN_DIR/lvm")
 AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR, ["$DEFAULT_RUN_DIR"],
 		   [Default LVM run directory.])


