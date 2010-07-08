From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jul 2010 13:31:08 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20100708133108.18517.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-07-08 13:31:07

Modified files:
	tools          : dmsetup.c 

Log message:
	Set return value 0 for 'dmsetup -c -o help'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/tools/dmsetup.c	2010/07/05 22:56:31	1.139
+++ LVM2/tools/dmsetup.c	2010/07/08 13:31:03	1.140
@@ -3341,6 +3341,7 @@
 
 	if (argc == 0) {
 		_usage(stderr);
+		r = 0;
 		goto out;
 	}
 


