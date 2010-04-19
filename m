From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Apr 2010 21:10:20 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/datastruct/bitset.c
Message-ID: <20100419211020.22433.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-19 21:10:20

Modified files:
	.              : WHATS_NEW_DM 
	libdm/datastruct: bitset.c 

Log message:
	fix last commit

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.357&r2=1.358
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/bitset.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW_DM	2010/04/19 17:17:55	1.357
+++ LVM2/WHATS_NEW_DM	2010/04/19 21:10:20	1.358
@@ -1,5 +1,6 @@
 Version 1.02.47 -
 =================================
+  Simplify dm_bitset_create.
   Speed up dm_bit_get_next with ffs().
 
 Version 1.02.46 - 14th April 2010
--- LVM2/libdm/datastruct/bitset.c	2010/04/19 21:08:32	1.7
+++ LVM2/libdm/datastruct/bitset.c	2010/04/19 21:10:20	1.8
@@ -27,7 +27,7 @@
 	if (mem)
 		bs = dm_pool_zalloc(mem, size);
 	else if ((bs = dm_malloc(size)))
-		memset(mem, 0, size);
+		memset(bs, 0, size);
 
 	if (!bs)
 		return NULL;


