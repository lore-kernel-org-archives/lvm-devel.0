From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2011 21:56:53 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20110329215653.26821.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-29 21:56:53

Modified files:
	tools          : dmsetup.c 

Log message:
	Add attribute printf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158

--- LVM2/tools/dmsetup.c	2011/03/29 21:49:18	1.157
+++ LVM2/tools/dmsetup.c	2011/03/29 21:56:53	1.158
@@ -1050,6 +1050,7 @@
 	return dm_udev_wait(_udev_cookie);
 }
 
+__attribute__((format(printf, 1, 2)))
 static char _yes_no_prompt(const char *prompt, ...)
 {
 	int c = 0, ret = 0;


