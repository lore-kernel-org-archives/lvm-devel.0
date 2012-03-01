From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 10:46:39 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20120301104639.20345.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 10:46:39

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Missed ;

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/libdm/ioctl/libdm-iface.c	2012/03/01 10:07:38	1.139
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/03/01 10:46:39	1.140
@@ -479,7 +479,7 @@
 	    (snprintf(version, size, "%u.%u.%u", v[0], v[1], v[2]) < 0)) {
 		log_error("Buffer for version is to short.");
 		if (size > 0)
-			version[0] = '\0'
+			version[0] = '\0';
 		return 0;
 	}
 


