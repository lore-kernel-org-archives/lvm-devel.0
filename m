From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:34 +0100
Subject: [PATCH 11/24] Perf: New HASH function
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <218d7b05db3253b968962a886cf3797f6d423b10.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Providing 2 new hash function for selection.

Performance of my modified Bob Jenkins hash function (completely free
code) is reasonably good and in my test is seems to be equal with larger
but slightly more advanced SuperFastHash (LGPL).

Our current hash is producing a lot of hash collisions (i.e. a lot
of strings are hashed to same number) and also requires extra derefernce
during hash calculation.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/datastruct/hash.c |  104 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 104 insertions(+), 0 deletions(-)

diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index fc19d34..5f0d31d 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -34,6 +34,7 @@ struct dm_hash_table {
 	struct dm_hash_node **slots;
 };
 
+#if 0
 /* Permutation of the Integers 0 through 255 */
 static unsigned char _nums[] = {
 	1, 14, 110, 25, 97, 174, 132, 119, 138, 170, 125, 118, 27, 233, 140, 51,
@@ -61,6 +62,7 @@ static unsigned char _nums[] = {
 	163, 200, 222, 235, 248, 243, 219, 10, 152, 131, 123, 229, 203, 76, 120,
 	209
 };
+#endif
 
 static struct dm_hash_node *_create_node(const char *str, unsigned len)
 {
@@ -74,6 +76,7 @@ static struct dm_hash_node *_create_node(const char *str, unsigned len)
 	return n;
 }
 
+#if 0
 static unsigned long _hash(const char *str, unsigned len)
 {
 	unsigned long h = 0, g;
@@ -91,6 +94,107 @@ static unsigned long _hash(const char *str, unsigned len)
 
 	return h;
 }
+#endif
+
+#if 1
+/*
+ * Adapted Bob Jenkins hash to read by 2 bytes if possible.
+ * https://secure.wikimedia.org/wikipedia/en/wiki/Jenkins_hash_function
+ *
+ * reduces amount of hash collisions
+ */
+static unsigned long _hash(const char *str, unsigned len)
+{
+	const uint16_t *str16 = (const uint16_t*)str;
+	uint32_t hash = 0, i;
+	int sz = len / 2;
+
+	//if ((int)str & 1) abort(); // catch odd addresses
+	for(i = 0; i < sz; ++i) {
+		hash += str16[i];
+		hash += (hash << 10);
+		hash ^= (hash >> 6);
+	}
+
+	if (len & 1) {
+		hash += str[len - 1];
+		hash += (hash << 10);
+		hash ^= (hash >> 6);
+	}
+
+	hash += (hash << 3);
+	hash ^= (hash >> 11);
+	hash += (hash << 15);
+
+	return hash;
+}
+#endif
+
+#if 0
+/*
+ * SuperFastHash
+ * http://www.azillionmonkeys.com/qed/hash.html
+ */
+#undef get16bits
+#if (defined(__GNUC__) && defined(__i386__)) || defined(__WATCOMC__) \
+  || defined(_MSC_VER) || defined (__BORLANDC__) || defined (__TURBOC__)
+#define get16bits(d) (*((const uint16_t *) (d)))
+#endif
+
+#if !defined (get16bits)
+#define get16bits(d) ((((uint32_t)(((const uint8_t *)(d))[1])) << 8)\
+                       +(uint32_t)(((const uint8_t *)(d))[0]) )
+#endif
+
+static unsigned long _hash(const char *data, unsigned len)
+{
+	unsigned long hash = len, tmp;
+	int rem;
+
+	if (len <= 0 || data == NULL) return 0;
+
+	rem = len & 3;
+	len >>= 2;
+
+	/* Main loop */
+	for (;len > 0; len--) {
+		hash  += get16bits (data);
+		tmp    = (get16bits (data+2) << 11) ^ hash;
+		hash   = (hash << 16) ^ tmp;
+		data  += 2*sizeof (uint16_t);
+		hash  += hash >> 11;
+	}
+
+	/* Handle end cases */
+	switch (rem) {
+	case 3:
+		hash += get16bits (data);
+		hash ^= hash << 16;
+		hash ^= data[sizeof (uint16_t)] << 18;
+		hash += hash >> 11;
+		break;
+	case 2:
+		hash += get16bits (data);
+		hash ^= hash << 11;
+		hash += hash >> 17;
+		break;
+	case 1:
+		hash += *data;
+		hash ^= hash << 10;
+		hash += hash >> 1;
+	}
+
+	/* Force "avalanching" of final 127 bits */
+	hash ^= hash << 3;
+	hash += hash >> 5;
+	hash ^= hash << 4;
+	hash += hash >> 17;
+	hash ^= hash << 25;
+	hash += hash >> 6;
+
+	return hash;
+}
+#endif
 
 struct dm_hash_table *dm_hash_create(unsigned size_hint)
 {
-- 
1.7.3.5


