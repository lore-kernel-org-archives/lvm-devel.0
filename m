From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Apr 2010 10:58:19 -0000
Subject: LVM2/libdm .exported_symbols libdevmapper.h
Message-ID: <20100420105819.4586.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-20 10:58:18

Modified files:
	libdm          : .exported_symbols libdevmapper.h 

Log message:
	missed files from last commit

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/libdm/.exported_symbols	2010/02/15 16:21:33	1.49
+++ LVM2/libdm/.exported_symbols	2010/04/20 10:58:18	1.50
@@ -109,6 +109,7 @@
 dm_pool_zalloc
 dm_bitset_create
 dm_bitset_destroy
+dm_bit_and
 dm_bit_union
 dm_bit_get_first
 dm_bit_get_next
--- LVM2/libdm/libdevmapper.h	2010/02/15 16:21:33	1.109
+++ LVM2/libdm/libdevmapper.h	2010/04/20 10:58:18	1.110
@@ -600,6 +600,7 @@
 dm_bitset_t dm_bitset_create(struct dm_pool *mem, unsigned num_bits);
 void dm_bitset_destroy(dm_bitset_t bs);
 
+void dm_bit_and(dm_bitset_t out, dm_bitset_t in1, dm_bitset_t in2);
 void dm_bit_union(dm_bitset_t out, dm_bitset_t in1, dm_bitset_t in2);
 int dm_bit_get_first(dm_bitset_t bs);
 int dm_bit_get_next(dm_bitset_t bs, int last_bit);


