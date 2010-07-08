From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jul 2010 12:16:17 -0000
Subject: LVM2/libdm/datastruct bitset.c
Message-ID: <20100708121617.29258.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-07-08 12:16:16

Modified files:
	libdm/datastruct: bitset.c 

Log message:
	Minor optimalization of _test_word.
	Skip ffs() if  (test >> bit) is 0.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/bitset.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/libdm/datastruct/bitset.c	2010/04/20 13:58:23	1.10
+++ LVM2/libdm/datastruct/bitset.c	2010/07/08 12:16:16	1.11
@@ -69,9 +69,9 @@
 
 static int _test_word(uint32_t test, int bit)
 {
-	int next_set_bit;
+	uint32_t tb = test >> bit;
 
-	return ((next_set_bit = ffs(test >> bit)) ? next_set_bit + bit - 1 : -1);
+	return (tb ? ffs(tb) + bit - 1 : -1);
 }
 
 int dm_bit_get_next(dm_bitset_t bs, int last_bit)


