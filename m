From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Mar 2010 14:43:20 -0000
Subject: LVM2 ./WHATS_NEW_DM ./configure.in libdm/libdm ...
Message-ID: <20100323144320.2537.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-03-23 14:43:19

Modified files:
	.              : WHATS_NEW_DM configure.in 
	libdm          : libdm-common.c 
	tools          : dmsetup.c lvmcmdline.c 

Log message:
	Strictly require libudev if udev_sync is used.
	
	This prevents some confusion when libudev was not found so udev_sync was disabled
	automatically. Configure was successful though giving only a tiny warning.
	
	Also, if "dmsetup udevcreatecookie" is used, never return 0x000000 as a result if
	udev is not running and keep the output blank.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.351&r2=1.352
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW_DM	2010/03/23 14:38:37	1.351
+++ LVM2/WHATS_NEW_DM	2010/03/23 14:43:18	1.352
@@ -1,5 +1,6 @@
 Version 1.02.46 - 
 ================================
+  Strictly require libudev if udev_sync is used.
   Add support for ioctl's DM_UEVENT_GENERATED_FLAG.
 
 Version 1.02.45 - 9th March 2010
--- LVM2/configure.in	2010/03/18 09:19:30	1.132
+++ LVM2/configure.in	2010/03/23 14:43:18	1.133
@@ -650,6 +650,7 @@
 AC_MSG_RESULT($UDEV_SYNC)
 
 if test x$UDEV_SYNC = xyes; then
+	AC_CHECK_LIB(udev, udev_queue_get_udev_is_active, UDEV_LIBS="-ludev", AC_MSG_ERROR(bailing out... libudev library is required))
 	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
 fi
 
@@ -660,23 +661,6 @@
 AC_MSG_RESULT($UDEV_RULES)
 
 ################################################################################
-dnl -- Check for libudev's udev_queue_get_udev_is_active function when udev synchronisation is enabled
-
-if test x$UDEV_SYNC = xyes; then
-	AC_CHECK_LIB(udev, udev_queue_get_udev_is_active, HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE=yes,
-		HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE=no)
-
-		if test x$HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE = xyes; then
-			AC_DEFINE([HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE], 1,
-			  [Define to 1 if libudev's udev_queue_get_udev_is_active function is available.])
-			UDEV_LIBS="-ludev"
-		else
-			UDEV_LIBS=
-			AC_MSG_WARN(It won't be possible to get udev state. We will assume that udev is not running.)
-		fi
-fi
-
-################################################################################
 dnl -- Compatibility mode
 AC_ARG_ENABLE(compat,   [  --enable-compat         Enable support for old device-mapper versions],
   DM_COMPAT=$enableval, DM_COMPAT=no)
--- LVM2/libdm/libdm-common.c	2010/02/15 16:21:33	1.93
+++ LVM2/libdm/libdm-common.c	2010/03/23 14:43:18	1.94
@@ -29,11 +29,9 @@
 #  include <sys/types.h>
 #  include <sys/ipc.h>
 #  include <sys/sem.h>
-#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
 #  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
 #  include <libudev.h>
 #endif
-#endif
 
 #ifdef linux
 #  include <linux/fs.h>
@@ -922,16 +920,6 @@
 
 static int _check_udev_is_running(void)
 {
-
-#  ifndef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
-
-	log_debug("Could not get udev state because libudev library "
-		  "was not found and it was not compiled in. "
-		  "Assuming udev is not running.");
-	return 0;
-
-#  else	/* HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE */
-
 	struct udev *udev;
 	struct udev_queue *udev_queue;
 	int r;
@@ -956,9 +944,6 @@
 bad:
 	log_error("Could not get udev state. Assuming udev is not running.");
 	return 0;
-
-#  endif	/* HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE */
-
 }
 
 void dm_udev_set_sync_support(int sync_with_udev)
@@ -1170,8 +1155,10 @@
 {
 	int semid;
 
-	if (!dm_udev_get_sync_support())
+	if (!dm_udev_get_sync_support()) {
+		*cookie = 0;
 		return 1;
+	}
 
 	return _udev_notify_sem_create(cookie, &semid);
 }
--- LVM2/tools/dmsetup.c	2010/03/08 16:05:08	1.135
+++ LVM2/tools/dmsetup.c	2010/03/23 14:43:19	1.136
@@ -45,11 +45,9 @@
 #  include <sys/types.h>
 #  include <sys/ipc.h>
 #  include <sys/sem.h>
-#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
 #  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
 #  include <libudev.h>
 #endif
-#endif
 
 /* FIXME Unused so far */
 #undef HAVE_SYS_STATVFS_H
@@ -931,12 +929,10 @@
 #else	/* UDEV_SYNC_SUPPORT */
 static int _set_up_udev_support(const char *dev_dir)
 {
-#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
 	struct udev *udev;
 	const char *udev_dev_dir;
 	size_t udev_dev_dir_len;
 	int dirs_diff;
-#endif
 	const char *env;
 
 	if (_switches[NOUDEVSYNC_ARG])
@@ -955,7 +951,6 @@
 			  " defined by --udevcookie option.",
 			  _udev_cookie);
 
-#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
 	if (!(udev = udev_new()) ||
 	    !(udev_dev_dir = udev_get_dev_path(udev)) ||
 	    !*udev_dev_dir) {
@@ -995,7 +990,6 @@
 	}
 
 	udev_unref(udev);
-#endif
 	return 1;
 }
 
@@ -1007,7 +1001,8 @@
 	if (!dm_udev_create_cookie(&cookie))
 		return 0;
 
-	printf("0x%08" PRIX32 "\n", cookie);
+	if (cookie)
+		printf("0x%08" PRIX32 "\n", cookie);
 
 	return 1;
 }
--- LVM2/tools/lvmcmdline.c	2010/02/15 16:26:49	1.115
+++ LVM2/tools/lvmcmdline.c	2010/03/23 14:43:19	1.116
@@ -42,7 +42,7 @@
 #  define OPTIND_INIT 1
 #endif
 
-#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+#ifdef UDEV_SYNC_SUPPORT
 #  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
 #  include <libudev.h>
 #endif
@@ -919,7 +919,7 @@
 
 static int _set_udev_checking(struct cmd_context *cmd)
 {
-#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+#ifdef UDEV_SYNC
 	struct udev *udev;
 	const char *udev_dev_dir;
 	size_t udev_dev_dir_len;


