From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Sep 2009 21:51:26 -0000
Subject: LVM2 libdm/libdm-common.c ./WHATS_NEW_DM
Message-ID: <20090903215126.18797.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-03 21:51:26

Modified files:
	libdm          : libdm-common.c 
	.              : WHATS_NEW_DM 

Log message:
	Restore umask when device node creation fails.
	
	Author: Florian Zumbiehl <florz@florz.de>
	Acked-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.294&r2=1.295

--- LVM2/libdm/libdm-common.c	2009/08/06 15:04:30	1.76
+++ LVM2/libdm/libdm-common.c	2009/09/03 21:51:26	1.77
@@ -360,6 +360,7 @@
 
 	old_mask = umask(0);
 	if (mknod(path, S_IFBLK | mode, dev) < 0) {
+		umask(old_mask);
 		log_error("Unable to make device node for '%s'", dev_name);
 		return 0;
 	}
--- LVM2/WHATS_NEW_DM	2009/08/13 19:36:04	1.294
+++ LVM2/WHATS_NEW_DM	2009/09/03 21:51:26	1.295
@@ -1,5 +1,6 @@
 Version 1.02.37 -
 =================================
+  Restore umask when device node creation fails.
   Fix mirror table CTR code to handle 'block_on_error' and 'cluster' features
 
 Version 1.02.36 - 6th August 2009


