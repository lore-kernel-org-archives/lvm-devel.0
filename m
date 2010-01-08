From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 08 Jan 2010 15:53:27 +0100
Subject: [PATCH 4/4] Show warning message when libudev not found and we're using --enable-udev_sync
Message-ID: <4B4746E7.3000304@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We use libudev to get the udev state and if it's not running, we just disable the udev sync
code. If the library function we need is not found, we just assume that udev is not running.
But that could be misleading if we don't spot the "no" in the configure process. So it's
better to show a warning to emphasize it a little...

Peter

diff --git a/configure.in b/configure.in
index 8db301c..68edb5f 100644
--- a/configure.in
+++ b/configure.in
@@ -669,6 +669,8 @@ if test x$UDEV_SYNC = xyes; then
 			AC_DEFINE([HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE], 1,
 			  [Define to 1 if libudev's udev_queue_get_udev_is_active function is available.])
 			LIBS="-ludev $LIBS"
+		else
+			AC_MSG_WARN(It won't be possible to get udev state. We will assume that udev is not running.)
 		fi
 fi
 


