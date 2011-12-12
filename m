From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Dec 2011 00:08:24 -0000
Subject: LVM2/lib/config config.c
Message-ID: <20111212000824.18539.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-12 00:08:23

Modified files:
	lib/config     : config.c 

Log message:
	Fix a compiler warning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/lib/config/config.c	2011/12/11 23:18:20	1.109
+++ LVM2/lib/config/config.c	2011/12/12 00:08:23	1.110
@@ -364,7 +364,6 @@
 		argv++;
 	}
 
-out:
 	if (fp && dm_fclose(fp)) {
 		stack;
 		r = 0;


