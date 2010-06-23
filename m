From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Jun 2010 12:54:47 -0000
Subject: LVM2 ./WHATS_NEW libdm/ioctl/libdm-iface.c
Message-ID: <20100623125447.21848.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-23 12:54:47

Modified files:
	.              : WHATS_NEW 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix typo: "INTERNAL ERROR" -> "INTERNAL_ERROR"
	
	Author: Xinwei Hu
	xwhu at novell dot com

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1628&r2=1.1629
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/WHATS_NEW	2010/06/23 12:32:08	1.1628
+++ LVM2/WHATS_NEW	2010/06/23 12:54:46	1.1629
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Fix typo "INTERNAL ERROR" -> "INTERNAL_ERROR" in libdm-iface.c.
   Add lv_path to reports to offer full /dev pathname.
   Fix typo in warning message about missing device with allocated data areas.
   Add device name and offset to output of error messages in raw_read_mda_header().
--- LVM2/libdm/ioctl/libdm-iface.c	2010/06/01 16:08:13	1.75
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/06/23 12:54:46	1.76
@@ -777,7 +777,7 @@
 
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v1) / sizeof(*_cmd_data_v1))) {
-		log_error(INTERNAL ERROR "unknown device-mapper task %d",
+		log_error(INTERNAL_ERROR "unknown device-mapper task %d",
 			  dmt->type);
 		goto bad;
 	}


