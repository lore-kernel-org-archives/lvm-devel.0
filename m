From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Mar 2010 15:55:53 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100308155553.13375.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-08 15:55:53

Modified files:
	lib/mm         : memlock.c 

Log message:
	Unconditionaly ignore also Virtual Dynamically-linked Shared Object
	(VDSO on 32bit is VSyscall on 64bit)
	It seems it could be locked on 64bit kernels running 32bit binaries,
	but it makes troubles on real 32bit machines where mlock() returns
	error when trying to lock such map area. (0xffffe000)
	Behavior of mlockall() seems to be similar.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/lib/mm/memlock.c	2010/03/05 15:14:03	1.17
+++ LVM2/lib/mm/memlock.c	2010/03/08 15:55:52	1.18
@@ -59,7 +59,8 @@
 
 /* list of maps, that are unconditionaly ignored */
 static const char * const _ignore_maps[] = {
-    "[vsyscall]"
+    "[vdso]",
+    "[vsyscall]",
 };
 
 /* default blacklist for maps */


