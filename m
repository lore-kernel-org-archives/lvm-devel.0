From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 21 Mar 2011 15:40:44 +0100
Subject: [PATCH 1/3] Require stable libudev version and remove defines used for former unstable versions
Message-ID: <4D87636C.7090209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Libudev got stabilized in v143. Require that version directly in configure and
remove "define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE" that was needed
for unstable versions of libudev.

Peter
---
 configure.in         |    5 ++---
 libdm/libdm-common.c |    1 -
 tools/dmsetup.c      |    1 -
 tools/lvmcmdline.c   |    1 -
 4 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/configure.in b/configure.in
index c531c8a..cbc839d 100644
--- a/configure.in
+++ b/configure.in
@@ -803,9 +803,8 @@ AC_ARG_ENABLE(udev_sync,
 AC_MSG_RESULT($UDEV_SYNC)
 
 if test x$UDEV_SYNC = xyes; then
-	AC_CHECK_LIB(udev, udev_queue_get_udev_is_active,
-		     [UDEV_PC="libudev"; UDEV_LIBS="-ludev"],
-		     [AC_MSG_ERROR([bailing out... libudev library is required])])
+	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"],
+			  [AC_MSG_ERROR([bailing out... libudev library version >= 143 is required])])
 	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
 fi
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index c5780e7..b13b88a 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -29,7 +29,6 @@
 #  include <sys/types.h>
 #  include <sys/ipc.h>
 #  include <sys/sem.h>
-#  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
 #  include <libudev.h>
 #endif
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index fb71350..7c74ab6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -45,7 +45,6 @@
 #  include <sys/types.h>
 #  include <sys/ipc.h>
 #  include <sys/sem.h>
-#  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
 #  include <libudev.h>
 #endif
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index fe5f08e..45c3703 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -43,7 +43,6 @@ extern char *optarg;
 #endif
 
 #ifdef UDEV_SYNC_SUPPORT
-#  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
 #  include <libudev.h>
 #endif
 


