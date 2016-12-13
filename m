From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:04:35 +0000 (UTC)
Subject: master - libdm: add dm_bit_get_last()/dm_bit_get_prev()
Message-ID: <20161213210435.48F3D603B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d1d65e735b6dcc5f02d0e536e3b63617f40ce83
Commit:        5d1d65e735b6dcc5f02d0e536e3b63617f40ce83
Parent:        107bc13db3b0117e32bacede53fbd382feaf4a17
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 11 12:44:45 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 21:01:58 2016 +0000

libdm: add dm_bit_get_last()/dm_bit_get_prev()

It is sometimes convenient to iterate over the set bits in a dm
bitset in reverse order (from the highest set bit toward zero), or
to quickly find the last set bit.

Add dm_bit_get_last() and dm_bit_get_prev(), mirroring the existing
dm_bit_get_first() and dm_bit_get_next().

dm_bit_get_prev() uses __builtin_clz when available to efficiently
test the bitset in reverse.
---
 libdm/.exported_symbols.DM_1_02_138 |    2 +
 libdm/datastruct/bitset.c           |   36 +++++++++++++++++++++++++++++++++++
 libdm/libdevmapper.h                |    2 +
 3 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_138 b/libdm/.exported_symbols.DM_1_02_138
new file mode 100644
index 0000000..63fc2b8
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_138
@@ -0,0 +1,2 @@
+dm_bit_get_last
+dm_bit_get_prev
diff --git a/libdm/datastruct/bitset.c b/libdm/datastruct/bitset.c
index 3fd6a9c..90efec6 100644
--- a/libdm/datastruct/bitset.c
+++ b/libdm/datastruct/bitset.c
@@ -76,6 +76,13 @@ static int _test_word(uint32_t test, int bit)
 	return (tb ? ffs(tb) + bit - 1 : -1);
 }
 
+static int _test_word_rev(uint32_t test, int bit)
+{
+	uint32_t tb = test << (DM_BITS_PER_INT - 1 - bit);
+
+	return (tb ? bit - clz(tb) : -1);
+}
+
 int dm_bit_get_next(dm_bitset_t bs, int last_bit)
 {
 	int bit, word;
@@ -101,11 +108,40 @@ int dm_bit_get_next(dm_bitset_t bs, int last_bit)
 	return -1;
 }
 
+int dm_bit_get_prev(dm_bitset_t bs, int last_bit)
+{
+	int bit, word;
+	uint32_t test;
+
+	last_bit--;		/* otherwise we'll return the same bit again */
+
+	/*
+	 * bs[0] holds number of bits
+	 */
+	while (last_bit >= 0) {
+		word = last_bit >> INT_SHIFT;
+		test = bs[word + 1];
+		bit = last_bit & (DM_BITS_PER_INT - 1);
+
+		if ((bit = _test_word_rev(test, bit)) >= 0)
+			return (word * DM_BITS_PER_INT) + bit;
+
+		last_bit = (last_bit & ~(DM_BITS_PER_INT - 1)) - 1;
+	}
+
+	return -1;
+}
+
 int dm_bit_get_first(dm_bitset_t bs)
 {
 	return dm_bit_get_next(bs, -1);
 }
 
+int dm_bit_get_last(dm_bitset_t bs)
+{
+	return dm_bit_get_prev(bs, bs[0] + 1);
+}
+
 /*
  * Based on the Linux kernel __bitmap_parselist from lib/bitmap.c
  */
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ab69a56..44aa55c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2069,6 +2069,8 @@ void dm_bit_and(dm_bitset_t out, dm_bitset_t in1, dm_bitset_t in2);
 void dm_bit_union(dm_bitset_t out, dm_bitset_t in1, dm_bitset_t in2);
 int dm_bit_get_first(dm_bitset_t bs);
 int dm_bit_get_next(dm_bitset_t bs, int last_bit);
+int dm_bit_get_last(dm_bitset_t bs);
+int dm_bit_get_prev(dm_bitset_t bs, int last_bit);
 
 #define DM_BITS_PER_INT (sizeof(int) * CHAR_BIT)
 


