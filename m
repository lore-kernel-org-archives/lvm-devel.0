From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 13:00:36 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20101025130036.5712.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 13:00:35

Modified files:
	lib/mm         : memlock.c 

Log message:
	Switch to char* arithmetic from void*

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/mm/memlock.c	2010/10/15 09:48:23	1.31
+++ LVM2/lib/mm/memlock.c	2010/10/25 13:00:35	1.32
@@ -87,8 +87,8 @@
 static void _touch_memory(void *mem, size_t size)
 {
 	size_t pagesize = lvm_getpagesize();
-	void *pos = mem;
-	void *end = mem + size - sizeof(long);
+	char *pos = mem;
+	char *end = pos + size - sizeof(long);
 
 	while (pos < end) {
 		*(long *) pos = 1;


