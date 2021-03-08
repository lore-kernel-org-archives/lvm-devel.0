From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:49 +0000 (GMT)
Subject: main - hash: speed up hash tables
Message-ID: <20210308144649.EC757395206E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d602837b91ceb2a47e6d4d10c34ef90e6f26b17a
Commit:        d602837b91ceb2a47e6d4d10c34ef90e6f26b17a
Parent:        84679d254ffdeab24cc2994d1ef3bc800ca736d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 7 15:33:04 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:33:15 2021 +0100

hash: speed up hash tables

Enhance hash perfomance by remembering the computed
hash value for the hashed node - this allows to speedup
lookup of nodes with the hash collision when
different keys map to the same masked hash value.

For the easier use 'num_slots' become 'mask_slots',
so we only add '1' in rare case of need of the original
num_slots value.

Also add statistic counters for hashes and print stats in
debug build (-DDEBUG) on hash wiping.
(so badly performing hash can be optimized.)
---
 base/data-struct/hash.c | 90 +++++++++++++++++++++++++++++++------------------
 1 file changed, 58 insertions(+), 32 deletions(-)

diff --git a/base/data-struct/hash.c b/base/data-struct/hash.c
index 9f6322733..54f75a5a6 100644
--- a/base/data-struct/hash.c
+++ b/base/data-struct/hash.c
@@ -22,12 +22,18 @@ struct dm_hash_node {
 	void *data;
 	unsigned data_len;
 	unsigned keylen;
+	unsigned hash;
 	char key[];
 };
 
 struct dm_hash_table {
 	unsigned num_nodes;
-	unsigned num_slots;
+	unsigned num_hint;
+	unsigned mask_slots;    /* (slots - 1) -> used as hash mask */
+	unsigned collisions;    /* Collissions of hash keys */
+	unsigned search;        /* How many keys were searched */
+	unsigned found;         /* How many nodes were found */
+	unsigned same_hash;     /* Was there a colision with same masked hash and len ? */
 	struct dm_hash_node **slots;
 };
 
@@ -96,24 +102,26 @@ struct dm_hash_table *dm_hash_create(unsigned size_hint)
 	unsigned new_size = 16u;
 	struct dm_hash_table *hc = zalloc(sizeof(*hc));
 
-	if (!hc)
-		return_0;
+	if (!hc) {
+		log_error("Failed to allocate memory for hash.");
+		return 0;
+	}
+
+	hc->num_hint = size_hint;
 
 	/* round size hint up to a power of two */
 	while (new_size < size_hint)
 		new_size = new_size << 1;
 
-	hc->num_slots = new_size;
+	hc->mask_slots = new_size - 1;
 	len = sizeof(*(hc->slots)) * new_size;
-	if (!(hc->slots = zalloc(len)))
-		goto_bad;
+	if (!(hc->slots = zalloc(len))) {
+		free(hc);
+		log_error("Failed to allocate slots for hash.");
+		return 0;
+	}
 
 	return hc;
-
-      bad:
-	free(hc->slots);
-	free(hc);
-	return 0;
 }
 
 static void _free_nodes(struct dm_hash_table *t)
@@ -121,7 +129,16 @@ static void _free_nodes(struct dm_hash_table *t)
 	struct dm_hash_node *c, *n;
 	unsigned i;
 
-	for (i = 0; i < t->num_slots; i++)
+#ifdef DEBUG
+	log_debug("Free hash hint:%d slots:%d nodes:%d (s:%d f:%d c:%d h:%d)",
+		  t->num_hint, t->mask_slots + 1, t->num_nodes,
+		  t->search, t->found, t->collisions, t->same_hash);
+#endif
+
+	if (!t->num_nodes)
+		return;
+
+	for (i = 0; i <= t->mask_slots; i++)
 		for (c = t->slots[i]; c; c = n) {
 			n = c->next;
 			free(c);
@@ -135,23 +152,32 @@ void dm_hash_destroy(struct dm_hash_table *t)
 	free(t);
 }
 
-static struct dm_hash_node **_find(struct dm_hash_table *t, const void *key,
-				   uint32_t len)
+static struct dm_hash_node **_findh(struct dm_hash_table *t, const void *key,
+				    uint32_t len, unsigned hash)
 {
-	unsigned h = _hash(key, len) & (t->num_slots - 1);
 	struct dm_hash_node **c;
 
-	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
-		if ((*c)->keylen != len)
-			continue;
-
-		if (!memcmp(key, (*c)->key, len))
-			break;
+	++t->search;
+	for (c = &t->slots[hash & t->mask_slots]; *c; c = &((*c)->next)) {
+		if ((*c)->keylen == len && (*c)->hash == hash) {
+			if (!memcmp(key, (*c)->key, len)) {
+				++t->found;
+				break;
+			}
+			++t->same_hash;
+		}
+		++t->collisions;
 	}
 
 	return c;
 }
 
+static struct dm_hash_node **_find(struct dm_hash_table *t, const void *key,
+				   uint32_t len)
+{
+	return _findh(t, key, len, _hash(key, len));
+}
+
 void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key,
 			    uint32_t len)
 {
@@ -163,7 +189,8 @@ void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key,
 int dm_hash_insert_binary(struct dm_hash_table *t, const void *key,
 			  uint32_t len, void *data)
 {
-	struct dm_hash_node **c = _find(t, key, len);
+	unsigned hash = _hash(key, len);
+	struct dm_hash_node **c = _findh(t, key, len, hash);
 
 	if (*c)
 		(*c)->data = data;
@@ -174,6 +201,7 @@ int dm_hash_insert_binary(struct dm_hash_table *t, const void *key,
 			return 0;
 
 		n->data = data;
+		n->hash = hash;
 		n->next = 0;
 		*c = n;
 		t->num_nodes++;
@@ -217,7 +245,7 @@ static struct dm_hash_node **_find_str_with_val(struct dm_hash_table *t,
 	struct dm_hash_node **c;
 	unsigned h;
        
-	h = _hash(key, len) & (t->num_slots - 1);
+	h = _hash(key, len) & t->mask_slots;
 
 	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
 		if ((*c)->keylen != len)
@@ -248,7 +276,7 @@ int dm_hash_insert_allow_multiple(struct dm_hash_table *t, const char *key,
 	n->data = (void *)val;
 	n->data_len = val_len;
 
-	h = _hash(key, len) & (t->num_slots - 1);
+	h = _hash(key, len) & t->mask_slots;
 
 	first = t->slots[h];
 
@@ -316,7 +344,7 @@ void *dm_hash_lookup_with_count(struct dm_hash_table *t, const char *key, int *c
 
 	*count = 0;
 
-	h = _hash(key, len) & (t->num_slots - 1);
+	h = _hash(key, len) & t->mask_slots;
 
 	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
 		if ((*c)->keylen != len)
@@ -345,7 +373,7 @@ void dm_hash_iter(struct dm_hash_table *t, dm_hash_iterate_fn f)
 	struct dm_hash_node *c, *n;
 	unsigned i;
 
-	for (i = 0; i < t->num_slots; i++)
+	for (i = 0; i <= t->mask_slots; i++)
 		for (c = t->slots[i]; c; c = n) {
 			n = c->next;
 			f(c->data);
@@ -355,8 +383,8 @@ void dm_hash_iter(struct dm_hash_table *t, dm_hash_iterate_fn f)
 void dm_hash_wipe(struct dm_hash_table *t)
 {
 	_free_nodes(t);
-	memset(t->slots, 0, sizeof(struct dm_hash_node *) * t->num_slots);
-	t->num_nodes = 0u;
+	memset(t->slots, 0, sizeof(struct dm_hash_node *) * (t->mask_slots + 1));
+	t->num_nodes = t->collisions = t->search = t->same_hash = 0u;
 }
 
 char *dm_hash_get_key(struct dm_hash_table *t __attribute__((unused)),
@@ -376,7 +404,7 @@ static struct dm_hash_node *_next_slot(struct dm_hash_table *t, unsigned s)
 	struct dm_hash_node *c = NULL;
 	unsigned i;
 
-	for (i = s; i < t->num_slots && !c; i++)
+	for (i = s; i <= t->mask_slots && !c; i++)
 		c = t->slots[i];
 
 	return c;
@@ -389,7 +417,5 @@ struct dm_hash_node *dm_hash_get_first(struct dm_hash_table *t)
 
 struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_node *n)
 {
-	unsigned h = _hash(n->key, n->keylen) & (t->num_slots - 1);
-
-	return n->next ? n->next : _next_slot(t, h + 1);
+	return n->next ? n->next : _next_slot(t, (n->hash & t->mask_slots) + 1);
 }


