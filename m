From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Nov 2008 09:30:53 -0000
Subject: LVM2/lib/locking file_locking.c
Message-ID: <20081112093053.10947.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-11-12 09:30:53

Modified files:
	lib/locking    : file_locking.c 

Log message:
	* minor compilator warning fix for improper function declaration.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/lib/locking/file_locking.c	2008/11/03 22:14:29	1.40
+++ LVM2/lib/locking/file_locking.c	2008/11/12 09:30:52	1.41
@@ -92,7 +92,7 @@
 	_release_lock(NULL, 0);
 }
 
-static void _remove_ctrl_c_handler()
+static void _remove_ctrl_c_handler(void)
 {
 	siginterrupt(SIGINT, 0);
 	if (!_handler_installed)


