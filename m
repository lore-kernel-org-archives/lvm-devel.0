From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Apr 2010 21:08:32 -0000
Subject: LVM2/libdm/datastruct bitset.c
Message-ID: <20100419210832.21773.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-19 21:08:32

Modified files:
	libdm/datastruct: bitset.c 

Log message:
	Simplify dm_bitset_create. (ejt)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/bitset.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/libdm/datastruct/bitset.c	2010/04/19 17:17:55	1.6
+++ LVM2/libdm/datastruct/bitset.c	2010/04/19 21:08:32	1.7
@@ -26,17 +26,14 @@
 	
 	if (mem)
 		bs = dm_pool_zalloc(mem, size);
-	else
-		bs = dm_malloc(size);
+	else if ((bs = dm_malloc(size)))
+		memset(mem, 0, size);
 
 	if (!bs)
 		return NULL;
 
 	*bs = num_bits;
 
-	if (!mem)
-		dm_bit_clear_all(bs);
-
 	return bs;
 }
 


