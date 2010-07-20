From: thornber@sourceware.org <thornber@sourceware.org>
Date: 20 Jul 2010 15:26:43 -0000
Subject: LVM2/unit-tests/datastruct bitset_t.c
Message-ID: <20100720152643.22222.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-20 15:26:43

Modified files:
	unit-tests/datastruct: bitset_t.c 

Log message:
	[UNIT-TESTS] add test for the recent dm_bitset_equal() function

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/datastruct/bitset_t.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/unit-tests/datastruct/bitset_t.c	2010/07/20 15:25:39	1.1
+++ LVM2/unit-tests/datastruct/bitset_t.c	2010/07/20 15:26:43	1.2
@@ -6,14 +6,10 @@
         NR_BITS = 137
 };
 
-int main(int argc, char **argv)
+static void test_get_next(struct dm_pool *mem)
 {
         int i, j, last, first;
-        dm_bitset_t bs;
-        struct dm_pool *mem = dm_pool_create("bitset test", 1024);
-
-        assert(mem);
-        bs = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs = dm_bitset_create(mem, NR_BITS);
 
         for (i = 0; i < NR_BITS; i++)
                 assert(!dm_bit(bs, i));
@@ -33,7 +29,56 @@
         }
 
         assert(dm_bit_get_next(bs, last) == -1);
-        dm_pool_destroy(mem);
+}
+
+static void bit_flip(dm_bitset_t bs, int bit)
+{
+        int old = dm_bit(bs, bit);
+        if (old)
+                dm_bit_clear(bs, bit);
+        else
+                dm_bit_set(bs, bit);
+}
+
+static void test_equal(struct dm_pool *mem)
+{
+        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
+
+        int i, j;
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
+                dm_bit_set(bs1, i);
+                dm_bit_set(bs2, i);
+        }
+
+        assert(dm_bitset_equal(bs1, bs2));
+        assert(dm_bitset_equal(bs2, bs1));
+
+        for (i = 0; i < NR_BITS; i++) {
+                bit_flip(bs1, i);
+                assert(!dm_bitset_equal(bs1, bs2));
+                assert(!dm_bitset_equal(bs2, bs1));
+
+                assert(dm_bitset_equal(bs1, bs1)); /* comparing with self */
+                bit_flip(bs1, i);
+        }
+}
+
+int main(int argc, char **argv)
+{
+        typedef void (*test_fn)(struct dm_pool *);
+        static test_fn tests[] = {
+                test_get_next,
+                test_equal
+        };
+
+        int i;
+        for (i = 0; i < sizeof(tests) / sizeof(*tests); i++) {
+                struct dm_pool *mem = dm_pool_create("bitset test", 1024);
+                assert(mem);
+                tests[i](mem);
+                dm_pool_destroy(mem);
+        }
 
         return 0;
 }


