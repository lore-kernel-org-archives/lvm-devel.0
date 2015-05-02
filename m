From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  2 May 2015 22:43:47 +0000 (UTC)
Subject: master - configure: detect /run dir
Message-ID: <20150502224347.4BE55613FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc52f07a8fe0d7a9aa4c0b2fd63109cbd06288b5
Commit:        bc52f07a8fe0d7a9aa4c0b2fd63109cbd06288b5
Parent:        636bcb020ac54ff26e48592f33cbb7853a24e3e6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 2 23:57:52 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun May 3 00:42:07 2015 +0200

configure: detect /run dir

Access /run directly when system supports it.
---
 WHATS_NEW    |    1 +
 configure    |   18 ++++++++++++------
 configure.in |   18 +++++++++++-------
 3 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 43a499e..a21d2b2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  Configure detects /run or /var/run.
   Add missing newline in clvmd --help output.
 
 Version 2.02.119 - 2nd May 2015
diff --git a/configure b/configure
index 34d2a50..51a8f35 100755
--- a/configure
+++ b/configure
@@ -1698,11 +1698,11 @@ Optional Packages:
   --with-ocfdir=DIR       install OCF files in
                           [PREFIX/lib/ocf/resource.d/lvm2]
   --with-default-pid-dir=PID_DIR
-                          Default directory to keep PID files in. [/var/run]
+                          Default directory to keep PID files in. [autodetect]
   --with-default-dm-run-dir=DM_RUN_DIR
-                          Default DM run directory. [/var/run]
+                          Default DM run directory. [autodetect]
   --with-default-run-dir=RUN_DIR
-                          Default LVM run directory. [/var/run/lvm]
+                          Default LVM run directory. [autodetect_run_dir/lvm]
   --with-clvmd=TYPE       build cluster LVM Daemon
                           The following cluster manager combinations are valid:
                            * cman                  (RHEL5 or equivalent)
@@ -8951,13 +8951,19 @@ fi
 }
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for default run directory" >&5
+$as_echo_n "checking for default run directory... " >&6; }
+RUN_DIR="/run"
+test -d "/run" || RUN_DIR="/var/run"
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $RUN_DIR" >&5
+$as_echo "$RUN_DIR" >&6; }
 
 
 # Check whether --with-default-pid-dir was given.
 if test "${with_default_pid_dir+set}" = set; then :
   withval=$with_default_pid_dir; DEFAULT_PID_DIR="$withval"
 else
-  DEFAULT_PID_DIR="/var/run"
+  DEFAULT_PID_DIR=$RUN_DIR
 fi
 
 
@@ -8972,7 +8978,7 @@ _ACEOF
 if test "${with_default_dm_run_dir+set}" = set; then :
   withval=$with_default_dm_run_dir; DEFAULT_DM_RUN_DIR="$withval"
 else
-  DEFAULT_DM_RUN_DIR="/var/run"
+  DEFAULT_DM_RUN_DIR=$RUN_DIR
 fi
 
 
@@ -8987,7 +8993,7 @@ _ACEOF
 if test "${with_default_run_dir+set}" = set; then :
   withval=$with_default_run_dir; DEFAULT_RUN_DIR="$withval"
 else
-  DEFAULT_RUN_DIR="/var/run/lvm"
+  DEFAULT_RUN_DIR="$RUN_DIR/lvm"
 fi
 
 
diff --git a/configure.in b/configure.in
index 38c7b51..a14540f 100644
--- a/configure.in
+++ b/configure.in
@@ -1,6 +1,6 @@
 ###############################################################################
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
@@ -645,28 +645,32 @@ pkg_config_init() {
 }
 
 ################################################################################
+AC_MSG_CHECKING(for default run directory)
+RUN_DIR="/run"
+test -d "/run" || RUN_DIR="/var/run"
+AC_MSG_RESULT($RUN_DIR)
 dnl -- Set up pidfile and run directory
 AH_TEMPLATE(DEFAULT_PID_DIR)
 AC_ARG_WITH(default-pid-dir,
 	    AC_HELP_STRING([--with-default-pid-dir=PID_DIR],
-			   [Default directory to keep PID files in. [/var/run]]),
-	    DEFAULT_PID_DIR="$withval", DEFAULT_PID_DIR="/var/run")
+			   [Default directory to keep PID files in. [autodetect]]),
+	    DEFAULT_PID_DIR="$withval", DEFAULT_PID_DIR=$RUN_DIR)
 AC_DEFINE_UNQUOTED(DEFAULT_PID_DIR, ["$DEFAULT_PID_DIR"],
 		   [Default directory to keep PID files in.])
 
 AH_TEMPLATE(DEFAULT_DM_RUN_DIR, [Name of default DM run directory.])
 AC_ARG_WITH(default-dm-run-dir,
 	    AC_HELP_STRING([--with-default-dm-run-dir=DM_RUN_DIR],
-			   [ Default DM run directory. [/var/run]]),
-	    DEFAULT_DM_RUN_DIR="$withval", DEFAULT_DM_RUN_DIR="/var/run")
+			   [ Default DM run directory. [autodetect]]),
+	    DEFAULT_DM_RUN_DIR="$withval", DEFAULT_DM_RUN_DIR=$RUN_DIR)
 AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR, ["$DEFAULT_DM_RUN_DIR"],
 		   [Default DM run directory.])
 
 AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default LVM run directory.])
 AC_ARG_WITH(default-run-dir,
 	    AC_HELP_STRING([--with-default-run-dir=RUN_DIR],
-			   [Default LVM run directory. [/var/run/lvm]]),
-	    DEFAULT_RUN_DIR="$withval", DEFAULT_RUN_DIR="/var/run/lvm")
+			   [Default LVM run directory. [autodetect_run_dir/lvm]]),
+	    DEFAULT_RUN_DIR="$withval", DEFAULT_RUN_DIR="$RUN_DIR/lvm")
 AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR, ["$DEFAULT_RUN_DIR"],
 		   [Default LVM run directory.])
 


