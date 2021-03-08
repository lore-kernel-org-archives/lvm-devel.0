From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:51 +0000 (GMT)
Subject: main - hash: replace hash with better function
Message-ID: <20210308144651.1BA1D39524B0@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff21723512cb633c741e516381899f70e0d9ef2a
Commit:        ff21723512cb633c741e516381899f70e0d9ef2a
Parent:        d602837b91ceb2a47e6d4d10c34ef90e6f26b17a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 8 15:18:04 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:33:15 2021 +0100

hash: replace hash with better function

Add Bob Jenkins hash function to get better working hash function,
which does genarate way less colisions (especially with similar
strings).

For a comparision also a kernel function used in DM kernel is include.
While it's better then our existing one, it's still far worse,
then Bob Jenkins hash.
---
 base/data-struct/hash.c | 92 +++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 74 insertions(+), 18 deletions(-)

diff --git a/base/data-struct/hash.c b/base/data-struct/hash.c
index 54f75a5a6..5fee9cf85 100644
--- a/base/data-struct/hash.c
+++ b/base/data-struct/hash.c
@@ -37,8 +37,11 @@ struct dm_hash_table {
 	struct dm_hash_node **slots;
 };
 
-/* Permutation of the Integers 0 through 255 */
-static unsigned char _nums[] = {
+#if 0 /* TO BE REMOVED */
+static unsigned _hash(const void *key, unsigned len)
+{
+	/* Permutation of the Integers 0 through 255 */
+	static unsigned char _nums[] = {
 	1, 14, 110, 25, 97, 174, 132, 119, 138, 170, 125, 118, 27, 233, 140, 51,
 	87, 197, 177, 107, 234, 169, 56, 68, 30, 7, 173, 73, 188, 40, 36, 65,
 	49, 213, 104, 190, 57, 211, 148, 223, 48, 115, 15, 2, 67, 186, 210, 28,
@@ -63,23 +66,9 @@ static unsigned char _nums[] = {
 	44, 38, 31, 149, 135, 0, 216, 52, 63, 23, 37, 69, 39, 117, 146, 184,
 	163, 200, 222, 235, 248, 243, 219, 10, 152, 131, 123, 229, 203, 76, 120,
 	209
-};
-
-static struct dm_hash_node *_create_node(const void *key, unsigned len)
-{
-	struct dm_hash_node *n = malloc(sizeof(*n) + len);
-
-	if (n) {
-		memcpy(n->key, key, len);
-		n->keylen = len;
-	}
-
-	return n;
-}
+	};
 
-static unsigned _hash(const void *key, unsigned len)
-{
-	const unsigned char *str = key;
+	const uint8_t *str = key;
 	unsigned h = 0, g;
 	unsigned i;
 
@@ -96,6 +85,73 @@ static unsigned _hash(const void *key, unsigned len)
 	return h;
 }
 
+/* In-kernel DM hashing, still lots of collisions */
+static unsigned _hash_in_kernel(const char *key, unsigned len)
+{
+	const unsigned char *str = (unsigned char *)key;
+	const unsigned hash_mult = 2654435387U;
+	unsigned hash = 0, i;
+
+	for (i = 0; i < len; ++i)
+		hash = (hash + str[i]) * hash_mult;
+
+	return hash;
+}
+#endif
+
+#undef get16bits
+#if (defined(__GNUC__) && (defined(__i386__) || defined(__x86_64__)))
+#define get16bits(d) (*((const uint16_t *) (d)))
+#endif
+
+#if !defined (get16bits)
+#define get16bits(d) ((((uint32_t)(((const uint8_t *)(d))[1])) << 8)\
+                       +(uint32_t)(((const uint8_t *)(d))[0]) )
+#endif
+
+/*
+ * Adapted Bob Jenkins hash to read by 2 bytes if possible.
+ * https://secure.wikimedia.org/wikipedia/en/wiki/Jenkins_hash_function
+ *
+ * Reduces amount of hash collisions
+ */
+static unsigned _hash(const void *key, unsigned len)
+{
+	const uint8_t *str = (uint8_t*) key;
+	unsigned hash = 0, i;
+	unsigned sz = len / 2;
+
+	for(i = 0; i < sz; ++i) {
+		hash += get16bits(str + 2 * i);
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
+
+static struct dm_hash_node *_create_node(const void *key, unsigned len)
+{
+	struct dm_hash_node *n = malloc(sizeof(*n) + len);
+
+	if (n) {
+		memcpy(n->key, key, len);
+		n->keylen = len;
+	}
+
+	return n;
+}
+
 struct dm_hash_table *dm_hash_create(unsigned size_hint)
 {
 	size_t len;


