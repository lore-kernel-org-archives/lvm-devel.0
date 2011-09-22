From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Sep 2011 18:00:00 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110922180000.5722.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-22 17:59:59

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Initialize 'retryable' variable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/libdm/ioctl/libdm-iface.c	2011/09/22 17:09:48	1.121
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/09/22 17:59:58	1.122
@@ -1689,7 +1689,7 @@
 	int rely_on_udev;
 	int suspended_counter;
 	unsigned ioctl_retry = 1;
-	int retryable;
+	int retryable = 0;
 
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v4) / sizeof(*_cmd_data_v4))) {


