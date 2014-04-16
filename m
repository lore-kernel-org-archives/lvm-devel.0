From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 16 Apr 2014 09:39:45 +0000 (UTC)
Subject: master - configure: use configure's --enable-udev-systemd-background-jobs by default
Message-ID: <20140416093945.60EED61193@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=702180b30c83183722d36500d05da20966759ecf
Commit:        702180b30c83183722d36500d05da20966759ecf
Parent:        18caa562fe35b2617f5c2d04c2252b2b8fdfd08c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 16 11:33:44 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 16 11:33:44 2014 +0200

configure: use configure's --enable-udev-systemd-background-jobs by default

This should be the preferred way of configuring lvm2 for udev/systemd
since otherwise one can end up with the processes run from udev (the
pvscan we run for lvmetad update on events) to be killed prematurely
and this can end up with LVM volumes not activated in the end.
---
 WHATS_NEW    |    1 +
 configure    |    6 +++---
 configure.in |    6 +++---
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c2cb3be..3efba96 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Configure --enable-udev-systemd-background-jobs if not disabled explicitly.
   Add lvmdump -s to collect system info and context (currently systemd only).
   Refactor allocation code to make A_POSITIONAL_FILL explicit.
   Use thread-safe ctime_r() for clvmd debug logging.
diff --git a/configure b/configure
index 9b5c2e7..2032e15 100755
--- a/configure
+++ b/configure
@@ -1599,8 +1599,8 @@ Optional Features:
   --enable-lvmetad        enable the LVM Metadata Daemon
   --disable-blkid_wiping  disable libblkid detection of signatures when wiping
                           and use native code instead
-  --enable-udev-systemd-background-jobs
-                          enable udev-systemd protocol to instantiate a
+  --disable-udev-systemd-background-jobs
+                          disable udev-systemd protocol to instantiate a
                           service for background job
   --enable-udev_sync      enable synchronisation with udev processing
   --enable-udev_rules     install rule files needed for udev synchronisation
@@ -9689,7 +9689,7 @@ $as_echo_n "checking whether to use udev-systemd protocol for jobs in background
 if test "${enable_udev_systemd_background_jobs+set}" = set; then :
   enableval=$enable_udev_systemd_background_jobs; UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval
 else
-  UDEV_SYSTEMD_BACKGROUND_JOBS=no
+  UDEV_SYSTEMD_BACKGROUND_JOBS=yes
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYSTEMD_BACKGROUND_JOBS" >&5
diff --git a/configure.in b/configure.in
index 6b84e47..f3c3570 100644
--- a/configure.in
+++ b/configure.in
@@ -1048,9 +1048,9 @@ fi
 dnl -- Enable udev-systemd protocol to instantiate a service for background jobs
 AC_MSG_CHECKING(whether to use udev-systemd protocol for jobs in background)
 AC_ARG_ENABLE(udev-systemd-background-jobs,
-	      AC_HELP_STRING([--enable-udev-systemd-background-jobs],
-			     [enable udev-systemd protocol to instantiate a service for background job]),
-	      UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval, UDEV_SYSTEMD_BACKGROUND_JOBS=no)
+	      AC_HELP_STRING([--disable-udev-systemd-background-jobs],
+			     [disable udev-systemd protocol to instantiate a service for background job]),
+	      UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval, UDEV_SYSTEMD_BACKGROUND_JOBS=yes)
 AC_MSG_RESULT($UDEV_SYSTEMD_BACKGROUND_JOBS)
 
 ################################################################################


