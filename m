From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Apr 2010 21:23:02 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/datastruct/bitset.c
Message-ID: <20100419212302.2875.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-19 21:23:02

Modified files:
	.              : WHATS_NEW_DM 
	libdm/datastruct: bitset.c 

Log message:
	Add dm_bit_and. (ejt)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.358&r2=1.359
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/bitset.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW_DM	2010/04/19 21:10:20	1.358
+++ LVM2/WHATS_NEW_DM	2010/04/19 21:23:01	1.359
@@ -1,5 +1,6 @@
 Version 1.02.47 -
 =================================
+  Add dm_bit_and.
   Simplify dm_bitset_create.
   Speed up dm_bit_get_next with ffs().
 
--- LVM2/libdm/datastruct/bitset.c	2010/04/19 21:10:20	1.8
+++ LVM2/libdm/datastruct/bitset.c	2010/04/19 21:23:02	1.9
@@ -42,6 +42,13 @@
 	dm_free(bs);
 }
 
+void dm_bit_and(dm_bitset_t out, dm_bitset_t in1, dm_bitset_t in2)
+{
+	int i;
+
+	for (i = (in1[0] / DM_BITS_PER_INT) + 1; i; i--)
+		out[i] = in1[i] & in2[i];
+}
 void dm_bit_union(dm_bitset_t out, dm_bitset_t in1, dm_bitset_t in2)
 {
 	int i;


