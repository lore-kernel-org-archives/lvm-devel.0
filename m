From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Apr 2010 13:58:25 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/.exported_symbols li ...
Message-ID: <20100420135825.29601.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-20 13:58:23

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : .exported_symbols libdevmapper.h 
	libdm/datastruct: bitset.c 

Log message:
	Add dm_bitset_equal to libdevmapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.359&r2=1.360
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/bitset.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW_DM	2010/04/19 21:23:01	1.359
+++ LVM2/WHATS_NEW_DM	2010/04/20 13:58:22	1.360
@@ -1,6 +1,6 @@
 Version 1.02.47 -
 =================================
-  Add dm_bit_and.
+  Add dm_bit_and and dm_bitset_equal to libdevmapper.
   Simplify dm_bitset_create.
   Speed up dm_bit_get_next with ffs().
 
--- LVM2/libdm/.exported_symbols	2010/04/20 10:58:18	1.50
+++ LVM2/libdm/.exported_symbols	2010/04/20 13:58:22	1.51
@@ -109,6 +109,7 @@
 dm_pool_zalloc
 dm_bitset_create
 dm_bitset_destroy
+dm_bitset_equal
 dm_bit_and
 dm_bit_union
 dm_bit_get_first
--- LVM2/libdm/libdevmapper.h	2010/04/20 10:58:18	1.110
+++ LVM2/libdm/libdevmapper.h	2010/04/20 13:58:22	1.111
@@ -600,6 +600,8 @@
 dm_bitset_t dm_bitset_create(struct dm_pool *mem, unsigned num_bits);
 void dm_bitset_destroy(dm_bitset_t bs);
 
+int dm_bitset_equal(dm_bitset_t in1, dm_bitset_t in2);
+
 void dm_bit_and(dm_bitset_t out, dm_bitset_t in1, dm_bitset_t in2);
 void dm_bit_union(dm_bitset_t out, dm_bitset_t in1, dm_bitset_t in2);
 int dm_bit_get_first(dm_bitset_t bs);
--- LVM2/libdm/datastruct/bitset.c	2010/04/19 21:23:02	1.9
+++ LVM2/libdm/datastruct/bitset.c	2010/04/20 13:58:23	1.10
@@ -42,6 +42,17 @@
 	dm_free(bs);
 }
 
+int dm_bitset_equal(dm_bitset_t in1, dm_bitset_t in2)
+{
+	int i;
+
+	for (i = (in1[0] / DM_BITS_PER_INT) + 1; i; i--)
+		if (in1[i] != in2[i])
+			return 0;
+
+	return 1;
+}
+
 void dm_bit_and(dm_bitset_t out, dm_bitset_t in1, dm_bitset_t in2)
 {
 	int i;


