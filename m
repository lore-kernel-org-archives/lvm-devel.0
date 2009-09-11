From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Sep 2009 15:57:52 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20090911155752.11316.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-11 15:57:51

Modified files:
	libdm          : libdm-common.c 

Log message:
	Add one define that is necessary for older (experimental) libudev to work.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/libdm/libdm-common.c	2009/09/11 15:56:07	1.78
+++ LVM2/libdm/libdm-common.c	2009/09/11 15:57:51	1.79
@@ -29,6 +29,7 @@
 #  include <sys/ipc.h>
 #  include <sys/sem.h>
 #ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+#  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
 #  include <libudev.h>
 #endif
 #endif


