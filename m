From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 22:09:57 +0000 (GMT)
Subject: main - configure: missed braces
Message-ID: <20211014220957.0284C3858419@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=438408de7dc3be6daed240ec52f0e0a09ae9b2f6
Commit:        438408de7dc3be6daed240ec52f0e0a09ae9b2f6
Parent:        8784211958ee0ea663171e186bd5217b1c7b52c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 00:02:11 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 00:08:29 2021 +0200

configure: missed braces

Missed [] around AS_IF internals,
Also missed to call pkg_config_init prior PKG_CHECK_MODULES().
---
 configure    | 10 ++++++----
 configure.ac |  5 +++--
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/configure b/configure
index 1b3fe7080..7f55569b0 100755
--- a/configure
+++ b/configure
@@ -1856,6 +1856,10 @@ Some influential environment variables:
   BLKID_CFLAGS
               C compiler flags for BLKID, overriding pkg-config
   BLKID_LIBS  linker flags for BLKID, overriding pkg-config
+  SYSTEMD_CFLAGS
+              C compiler flags for SYSTEMD, overriding pkg-config
+  SYSTEMD_LIBS
+              linker flags for SYSTEMD, overriding pkg-config
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
   PYTHON      the Python interpreter
@@ -11643,10 +11647,8 @@ $as_echo "#define APP_MACHINEID_SUPPORT 1" >>confdefs.h
 fi
 
 if test -n "SYSTEMD_MIN_VERSION"; then :
-    SYSTEMD_CFLAGS
-              C compiler flags for SYSTEMD, overriding pkg-config
-  SYSTEMD_LIBS
-              linker flags for SYSTEMD, overriding pkg-config
+
+      pkg_config_init
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for SYSTEMD" >&5
diff --git a/configure.ac b/configure.ac
index 2cff45fdc..0ec8d6b7d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1145,9 +1145,10 @@ AS_IF([test "$APP_MACHINEID_SUPPORT" = yes],
       SYSTEMD_MIN_VERSION=234)
 
 dnl -- Look for libsystemd libraries
-AS_IF([test -n "SYSTEMD_MIN_VERSION"],
+AS_IF([test -n "SYSTEMD_MIN_VERSION"],[
+      pkg_config_init
       PKG_CHECK_MODULES(SYSTEMD, systemd >= "$SYSTEMD_MIN_VERSION", [], $bailout)
-      SYSTEMD_LIBS="-lsystemd")
+      SYSTEMD_LIBS="-lsystemd"])
 
 ################################################################################
 


