From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Apr 2010 17:17:56 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/datastruct/bitset.c
Message-ID: <20100419171756.25085.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-19 17:17:55

Modified files:
	.              : WHATS_NEW_DM 
	libdm/datastruct: bitset.c 

Log message:
	Speed up dm_bit_get_next with ffs().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.356&r2=1.357
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/bitset.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW_DM	2010/04/14 21:47:48	1.356
+++ LVM2/WHATS_NEW_DM	2010/04/19 17:17:55	1.357
@@ -1,5 +1,6 @@
 Version 1.02.47 -
 =================================
+  Speed up dm_bit_get_next with ffs().
 
 Version 1.02.46 - 14th April 2010
 =================================
--- LVM2/libdm/datastruct/bitset.c	2008/11/03 18:59:59	1.5
+++ LVM2/libdm/datastruct/bitset.c	2010/04/19 17:17:55	1.6
@@ -52,18 +52,11 @@
 		out[i] = in1[i] | in2[i];
 }
 
-/*
- * FIXME: slow
- */
-static inline int _test_word(uint32_t test, int bit)
+static int _test_word(uint32_t test, int bit)
 {
-	while (bit < (int) DM_BITS_PER_INT) {
-		if (test & (0x1 << bit))
-			return bit;
-		bit++;
-	}
+	int next_set_bit;
 
-	return -1;
+	return ((next_set_bit = ffs(test >> bit)) ? next_set_bit + bit - 1 : -1);
 }
 
 int dm_bit_get_next(dm_bitset_t bs, int last_bit)


