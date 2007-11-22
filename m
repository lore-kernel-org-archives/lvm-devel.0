From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Nov 2007 01:25:07 -0000
Subject: LVM2/tools pvcreate.c pvremove.c
Message-ID: <20071122012507.28717.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-22 01:25:06

Modified files:
	tools          : pvcreate.c pvremove.c 

Log message:
	FIXMEs for case where dm itself has device open

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/tools/pvcreate.c	2007/11/14 00:08:25	1.57
+++ LVM2/tools/pvcreate.c	2007/11/22 01:25:06	1.58
@@ -86,6 +86,7 @@
 	}
 
 	if (!dev_test_excl(dev)) {
+		/* FIXME Detect whether device-mapper itself is still using it */
 		log_error("Can't open %s exclusively.  Mounted filesystem?",
 			  name);
 		return 0;
--- LVM2/tools/pvremove.c	2007/11/02 20:40:05	1.20
+++ LVM2/tools/pvremove.c	2007/11/22 01:25:06	1.21
@@ -93,6 +93,7 @@
 	}
 
 	if (!dev_test_excl(dev)) {
+		/* FIXME Detect whether device-mapper is still using the device */
 		log_error("Can't open %s exclusively - not removing. "
 			  "Mounted filesystem?", dev_name(dev));
 		goto error;


