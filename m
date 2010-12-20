From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 14:36:12 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20101220143612.19118.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 14:36:12

Modified files:
	tools          : dmsetup.c 

Log message:
	Remove dead assignment
	
	Variable 'r' is never read so remove it and just cast result from
	_error_device function to (void).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151

--- LVM2/tools/dmsetup.c	2010/12/20 13:37:26	1.150
+++ LVM2/tools/dmsetup.c	2010/12/20 14:36:12	1.151
@@ -1386,10 +1386,8 @@
 
 static int _remove(int argc, char **argv, void *data __attribute__((unused)))
 {
-	int r;
-
 	if (_switches[FORCE_ARG] && argc > 1)
-		r = _error_device(argc, argv, NULL);
+		(void) _error_device(argc, argv, NULL);
 
 	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
 }


