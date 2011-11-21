From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Nov 2011 13:15:48 -0000
Subject: LVM2/test/unit bitset_t.c
Message-ID: <20111121131548.9125.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-21 13:15:45

Modified files:
	test/unit      : bitset_t.c 

Log message:
	Cleanup gcc warning
	
	bitset_t.c:39: warning: 'last' may be used uninitialized in this function
	
	Compiler is not smart enough to see the code path which avoid using
	unitialized 'last'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/bitset_t.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/unit/bitset_t.c	2011/11/20 21:43:20	1.1
+++ LVM2/test/unit/bitset_t.c	2011/11/21 13:15:40	1.2
@@ -36,7 +36,7 @@
 
 static void test_get_next()
 {
-        int i, j, last, first;
+        int i, j, last = 0, first;
         dm_bitset_t bs = dm_bitset_create(mem, NR_BITS);
 
         for (i = 0; i < NR_BITS; i++)


