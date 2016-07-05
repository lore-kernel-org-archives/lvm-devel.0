From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:34:39 +0000 (UTC)
Subject: master - libdm: add dm_bitset_parse_list()
Message-ID: <20160705183439.7061160E42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f883bca41b425d8eed1cbace2b9cdc67331f4e57
Commit:        f883bca41b425d8eed1cbace2b9cdc67331f4e57
Parent:        7145d666fc269f3c808a420883910013e3ed3746
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Feb 18 16:14:43 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:49 2016 +0100

libdm: add dm_bitset_parse_list()

Add a function to parse a list of integer values and ranges into
a dm_bitset representation. Individual values signify that that bit
is set in the resulting mask and ranges are given as a pair of
start and end values, M-N, such that M and N are the first and
last members of the range (inclusive).

The implementation is based on the kernel's __bitmap_parselist()
that is used for cpumasks and other set configuration passed in
string form from user space.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_129 |    1 +
 libdm/datastruct/bitset.c           |   98 +++++++++++++++++++++++++++++++++++
 libdm/libdevmapper.h                |   10 ++++
 4 files changed, 110 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 30d6d82..28999f1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.129 - 
 =================================
+  Add dm_bitset_parse_list() to parse a string representation of a bitset.
   Thin dmeventd plugin umounts lvm2 volume only when pool is 95% or more.
 
 Version 1.02.128 - 25th June 2016
diff --git a/libdm/.exported_symbols.DM_1_02_129 b/libdm/.exported_symbols.DM_1_02_129
new file mode 100644
index 0000000..fbd2a57
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_129
@@ -0,0 +1 @@
+dm_bitset_parse_list
diff --git a/libdm/datastruct/bitset.c b/libdm/datastruct/bitset.c
index 5aaa887..2f84ea4 100644
--- a/libdm/datastruct/bitset.c
+++ b/libdm/datastruct/bitset.c
@@ -15,6 +15,8 @@
 
 #include "dmlib.h"
 
+#include <ctype.h>
+
 /* FIXME: calculate this. */
 #define INT_SHIFT 5
 
@@ -103,3 +105,99 @@ int dm_bit_get_first(dm_bitset_t bs)
 {
 	return dm_bit_get_next(bs, -1);
 }
+
+/*
+ * Based on the Linux kernel __bitmap_parselist from lib/bitmap.c
+ */
+dm_bitset_t dm_bitset_parse_list(const char *str, struct dm_pool *mem)
+{
+	unsigned a, b;
+	int c, old_c, totaldigits, ndigits, nmaskbits;
+	int at_start, in_range;
+	dm_bitset_t mask = NULL;
+	const char *start = str;
+	size_t len;
+
+scan:
+	len = strlen(str);
+	totaldigits = c = 0;
+	nmaskbits = 0;
+	do {
+		at_start = 1;
+		in_range = 0;
+		a = b = 0;
+		ndigits = totaldigits;
+
+		/* Get the next value or range of values */
+		while (len) {
+			old_c = c;
+			c = *str++;
+			len--;
+			if (isspace(c))
+				continue;
+
+			/* A '\0' or a ',' signal the end of a value or range */
+			if (c == '\0' || c == ',')
+				break;
+			/*
+			* whitespaces between digits are not allowed,
+			* but it's ok if whitespaces are on head or tail.
+			* when old_c is whilespace,
+			* if totaldigits == ndigits, whitespace is on head.
+			* if whitespace is on tail, it should not run here.
+			* as c was ',' or '\0',
+			* the last code line has broken the current loop.
+			*/
+			if ((totaldigits != ndigits) && isspace(old_c))
+				goto_bad;
+
+			if (c == '-') {
+				if (at_start || in_range)
+					return_0;
+				b = 0;
+				in_range = 1;
+				at_start = 1;
+				continue;
+			}
+
+			if (!isdigit(c))
+				goto_bad;
+
+			b = b * 10 + (c - '0');
+			if (!in_range)
+				a = b;
+			at_start = 0;
+			totaldigits++;
+		}
+		if (ndigits == totaldigits)
+			continue;
+		/* if no digit is after '-', it's wrong */
+		if (at_start && in_range)
+			goto_bad;
+		if (!(a <= b))
+			goto_bad;
+		if (b >= nmaskbits)
+			nmaskbits = b + 1;
+		while ((a <= b) && mask) {
+			dm_bit_set(mask, a);
+			a++;
+		}
+	} while (len && c == ',');
+
+	if (!mask) {
+		if (!(mask = dm_bitset_create(mem, nmaskbits)))
+			goto_bad;
+		str = start;
+		goto scan;
+	}
+
+	return mask;
+bad:
+	if (mask) {
+		if (mem)
+			dm_pool_free(mem, mask);
+		else
+			dm_bitset_destroy(mask);
+	}
+	return NULL;
+}
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 7fd765c..3668188 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1843,6 +1843,16 @@ int dm_bit_get_next(dm_bitset_t bs, int last_bit);
 #define dm_bit_copy(bs1, bs2) \
    memcpy((bs1) + 1, (bs2) + 1, ((*(bs1) / DM_BITS_PER_INT) + 1) * sizeof(int))
 
+/*
+ * Parse a string representation of a bitset into a dm_bitset_t. The
+ * notation used is identical to the kernel bitmap parser (cpuset etc.)
+ * and supports both lists ("1,2,3") and ranges ("1-2,5-8"). If the mem
+ * parameter is NULL memory for the bitset will be allocated using
+ * dm_malloc(). Otherwise the bitset will be allocated using the supplied
+ * dm_pool.
+ */
+dm_bitset_t dm_bitset_parse_list(const char *str, struct dm_pool *mem);
+
 /* Returns number of set bits */
 static inline unsigned hweight32(uint32_t i)
 {


