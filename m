From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Aug 2010 13:04:33 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20100803130433.4922.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-03 13:04:32

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Wait for node creation before displaying debug info in dmsetup.
	
	Readahead check needs to see created node - so wait till udev gets in sync.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.402&r2=1.403
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/WHATS_NEW_DM	2010/08/03 12:56:00	1.402
+++ LVM2/WHATS_NEW_DM	2010/08/03 13:04:32	1.403
@@ -1,5 +1,6 @@
 Version 1.02.54 - 
 ================================
+  Wait for node creation before displaying debug info in dmsetup.
   Fix return status 0 for "dmsetup info -c -o help".
   Add check for kernel semaphore support and disable udev_sync if not available.
 
--- LVM2/tools/dmsetup.c	2010/08/03 12:56:00	1.143
+++ LVM2/tools/dmsetup.c	2010/08/03 13:04:32	1.144
@@ -633,9 +633,16 @@
 
 	r = 1;
 
+	if (!_udev_cookie)
+		(void) dm_udev_wait(cookie);
+
 	if (_switches[VERBOSE_ARG])
 		r = _display_info(dmt);
 
+	dm_task_destroy(dmt);
+
+	return r;
+
       out:
 	if (!_udev_cookie)
 		(void) dm_udev_wait(cookie);


