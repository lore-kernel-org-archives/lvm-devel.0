From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jul 2010 22:22:44 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h
Message-ID: <20100705222244.8013.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-05 22:22:44

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h 

Log message:
	Add parentheses to some libdevmapper.h macro arguments.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.387&r2=1.388
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/WHATS_NEW_DM	2010/07/02 21:16:50	1.387
+++ LVM2/WHATS_NEW_DM	2010/07/05 22:22:43	1.388
@@ -1,5 +1,6 @@
 Version 1.02.52 -
 ================================
+  Add parentheses to some libdevmapper.h macro arguments.
   Add printf format attributes to dm_{sn,as}printf and fix a caller.
   Move dmeventd man page from install_lvm2 to install_device-mapper. (1.02.50)
 
--- LVM2/libdm/libdevmapper.h	2010/07/02 21:16:51	1.118
+++ LVM2/libdm/libdevmapper.h	2010/07/05 22:22:43	1.119
@@ -657,22 +657,22 @@
 #define DM_BITS_PER_INT (sizeof(int) * CHAR_BIT)
 
 #define dm_bit(bs, i) \
-   (bs[(i / DM_BITS_PER_INT) + 1] & (0x1 << (i & (DM_BITS_PER_INT - 1))))
+   ((bs)[((i) / DM_BITS_PER_INT) + 1] & (0x1 << ((i) & (DM_BITS_PER_INT - 1))))
 
 #define dm_bit_set(bs, i) \
-   (bs[(i / DM_BITS_PER_INT) + 1] |= (0x1 << (i & (DM_BITS_PER_INT - 1))))
+   ((bs)[((i) / DM_BITS_PER_INT) + 1] |= (0x1 << ((i) & (DM_BITS_PER_INT - 1))))
 
 #define dm_bit_clear(bs, i) \
-   (bs[(i / DM_BITS_PER_INT) + 1] &= ~(0x1 << (i & (DM_BITS_PER_INT - 1))))
+   ((bs)[((i) / DM_BITS_PER_INT) + 1] &= ~(0x1 << ((i) & (DM_BITS_PER_INT - 1))))
 
 #define dm_bit_set_all(bs) \
-   memset(bs + 1, -1, ((*bs / DM_BITS_PER_INT) + 1) * sizeof(int))
+   memset((bs) + 1, -1, ((*(bs) / DM_BITS_PER_INT) + 1) * sizeof(int))
 
 #define dm_bit_clear_all(bs) \
-   memset(bs + 1, 0, ((*bs / DM_BITS_PER_INT) + 1) * sizeof(int))
+   memset((bs) + 1, 0, ((*(bs) / DM_BITS_PER_INT) + 1) * sizeof(int))
 
 #define dm_bit_copy(bs1, bs2) \
-   memcpy(bs1 + 1, bs2 + 1, ((*bs1 / DM_BITS_PER_INT) + 1) * sizeof(int))
+   memcpy((bs1) + 1, (bs2) + 1, ((*(bs1) / DM_BITS_PER_INT) + 1) * sizeof(int))
 
 /* Returns number of set bits */
 static inline unsigned hweight32(uint32_t i)
@@ -716,8 +716,8 @@
 struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_node *n);
 
 #define dm_hash_iterate(v, h) \
-	for (v = dm_hash_get_first(h); v; \
-	     v = dm_hash_get_next(h, v))
+	for (v = dm_hash_get_first((h)); v; \
+	     v = dm_hash_get_next((h), v))
 
 /****************
  * list functions


