From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Jan 2010 15:51:45 -0000
Subject: LVM2 configure.in
Message-ID: <20100111155145.15738.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-01-11 15:51:44

Modified files:
	.              : configure.in 

Log message:
	Show a warning message when libudev not found and we're using --enable-udev_sync.
	
	Just to emphasize what one can expect - we won't be able to get udev state
	and we will consider that udev is not running at all.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/configure.in	2010/01/11 15:48:49	1.121
+++ LVM2/configure.in	2010/01/11 15:51:44	1.122
@@ -669,6 +669,8 @@
 			AC_DEFINE([HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE], 1,
 			  [Define to 1 if libudev's udev_queue_get_udev_is_active function is available.])
 			LIBS="-ludev $LIBS"
+		else
+			AC_MSG_WARN(It won't be possible to get udev state. We will assume that udev is not running.)
 		fi
 fi
 


