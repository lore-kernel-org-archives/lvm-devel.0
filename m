From: thornber@sourceware.org <thornber@sourceware.org>
Date: 20 Jul 2010 15:28:22 -0000
Subject: LVM2/unit-tests/datastruct bitset_t.c
Message-ID: <20100720152822.23145.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-20 15:28:22

Modified files:
	unit-tests/datastruct: bitset_t.c 

Log message:
	[UNIT-TEST] test for recent dm_bit_and() function

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/datastruct/bitset_t.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/unit-tests/datastruct/bitset_t.c	2010/07/20 15:26:43	1.2
+++ LVM2/unit-tests/datastruct/bitset_t.c	2010/07/20 15:28:22	1.3
@@ -64,12 +64,46 @@
         }
 }
 
+static void test_and(struct dm_pool *mem)
+{
+        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs3 = dm_bitset_create(mem, NR_BITS);
+
+        int i, j;
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
+                dm_bit_set(bs1, i);
+                dm_bit_set(bs2, i);
+        }
+
+        dm_bit_and(bs3, bs1, bs2);
+
+        assert(dm_bitset_equal(bs1, bs2));
+        assert(dm_bitset_equal(bs1, bs3));
+        assert(dm_bitset_equal(bs2, bs3));
+
+        dm_bit_clear_all(bs1);
+        dm_bit_clear_all(bs2);
+
+        for (i = 0; i < NR_BITS; i++) {
+                if (i % 2)
+                        dm_bit_set(bs1, i);
+                else
+                        dm_bit_set(bs2, i);
+        }
+
+        dm_bit_and(bs3, bs1, bs2);
+        for (i = 0; i < NR_BITS; i++)
+                assert(!dm_bit(bs3, i));
+}
+
 int main(int argc, char **argv)
 {
         typedef void (*test_fn)(struct dm_pool *);
         static test_fn tests[] = {
                 test_get_next,
-                test_equal
+                test_equal,
+                test_and
         };
 
         int i;


