From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:33 +0100
Subject: [PATCH 10/24] Perf: speed up hash tables
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <84b7fef71e2fc4a13fb5c864ed85408b53d8fe48.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Improve considerably hash perfomance:
Remember calculated hash value for node - allows
to speedup lookup of nodes with same  hash & mask value.

Add statistic counters for hashes and print stats in debug mode on
hash destruction - so bad perfomance of hash can be optimized.

API change:
dm_hash  binary functions takes  void* pointer - so there
is no need to cast other pointers to char*.  This is slight API change,
but presents no change on user side it just allows to write code easier.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/datastruct/hash.c |   84 ++++++++++++++++++++++++++++++-----------------
 libdm/libdevmapper.h    |    6 ++--
 2 files changed, 57 insertions(+), 33 deletions(-)

diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index d4543df..fc19d34 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -19,12 +19,18 @@ struct dm_hash_node {
 	struct dm_hash_node *next;
 	void *data;
 	unsigned keylen;
+	unsigned long hash;
 	char key[0];
 };
 
 struct dm_hash_table {
 	unsigned num_nodes;
+	unsigned num_hint;
 	unsigned num_slots;
+	unsigned collisions;
+	unsigned search;
+	unsigned same_hash;
+	unsigned mask;
 	struct dm_hash_node **slots;
 };
 
@@ -92,26 +98,26 @@ struct dm_hash_table *dm_hash_create(unsigned size_hint)
 	unsigned new_size = 16u;
 	struct dm_hash_table *hc = dm_zalloc(sizeof(*hc));
 
-	if (!hc)
-		return_0;
+	if (!hc) {
+		log_error("Failed to allocate memory for hash.");
+		return 0;
+	}
 
+	hc->num_hint = size_hint;
 	/* round size hint up to a power of two */
 	while (new_size < size_hint)
 		new_size = new_size << 1;
 
 	hc->num_slots = new_size;
+	hc->mask = new_size - 1;
 	len = sizeof(*(hc->slots)) * new_size;
-	if (!(hc->slots = dm_malloc(len))) {
-		stack;
-		goto bad;
+	if (!(hc->slots = dm_zalloc(len))) {
+		dm_free(hc);
+		log_error("Failed to allocate slots for hash.");
+		return 0;
 	}
-	memset(hc->slots, 0, len);
-	return hc;
 
-      bad:
-	dm_free(hc->slots);
-	dm_free(hc);
-	return 0;
+	return hc;
 }
 
 static void _free_nodes(struct dm_hash_table *t)
@@ -119,6 +125,13 @@ static void _free_nodes(struct dm_hash_table *t)
 	struct dm_hash_node *c, *n;
 	unsigned i;
 
+	log_debug("Released hash - used:%d size:%d hint:%d  (c:%d s:%d h:%d)",
+		  t->num_nodes, t->num_slots, t->num_hint,
+		  t->collisions, t->search, t->same_hash);
+
+	if (!t->num_nodes)
+		return;
+
 	for (i = 0; i < t->num_slots; i++)
 		for (c = t->slots[i]; c; c = n) {
 			n = c->next;
@@ -133,45 +146,58 @@ void dm_hash_destroy(struct dm_hash_table *t)
 	dm_free(t);
 }
 
-static struct dm_hash_node **_find(struct dm_hash_table *t, const char *key,
-				   uint32_t len)
+static struct dm_hash_node **_findh(struct dm_hash_table *t, const void *key,
+				    uint32_t len, unsigned long hash)
 {
-	unsigned h = _hash(key, len) & (t->num_slots - 1);
 	struct dm_hash_node **c;
+	unsigned h = hash & t->mask;
 
 	for (c = &t->slots[h]; *c; c = &((*c)->next)) {
-		if ((*c)->keylen != len)
-			continue;
-
-		if (!memcmp(key, (*c)->key, len))
-			break;
+		if ((*c)->keylen == len && (*c)->hash == hash) {
+			if (!memcmp(key, (*c)->key, len)) {
+				++t->search;
+				break;
+			} else
+				++t->same_hash;
+		}
+		++t->collisions;
 	}
 
 	return c;
 }
 
-void *dm_hash_lookup_binary(struct dm_hash_table *t, const char *key,
-			 uint32_t len)
+static struct dm_hash_node **_find(struct dm_hash_table *t, const void *key,
+				   uint32_t len)
+{
+	return _findh(t, key, len, _hash(key, len));
+}
+
+void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key,
+			    uint32_t len)
 {
 	struct dm_hash_node **c = _find(t, key, len);
 
 	return *c ? (*c)->data : 0;
 }
 
-int dm_hash_insert_binary(struct dm_hash_table *t, const char *key,
+int dm_hash_insert_binary(struct dm_hash_table *t, const void *key,
 			  uint32_t len, void *data)
 {
-	struct dm_hash_node **c = _find(t, key, len);
+	unsigned long hash = _hash(key, len);
+	struct dm_hash_node **c = _findh(t, key, len, hash);
 
 	if (*c)
 		(*c)->data = data;
 	else {
 		struct dm_hash_node *n = _create_node(key, len);
 
-		if (!n)
+		if (!n) {
+			log_error("Failed to allocate new hash node.");
 			return 0;
+		}
 
 		n->data = data;
+		n->hash = hash;
 		n->next = 0;
 		*c = n;
 		t->num_nodes++;
@@ -180,7 +206,7 @@ int dm_hash_insert_binary(struct dm_hash_table *t, const char *key,
 	return 1;
 }
 
-void dm_hash_remove_binary(struct dm_hash_table *t, const char *key,
+void dm_hash_remove_binary(struct dm_hash_table *t, const void *key,
 			uint32_t len)
 {
 	struct dm_hash_node **c = _find(t, key, len);
@@ -229,7 +255,7 @@ void dm_hash_wipe(struct dm_hash_table *t)
 {
 	_free_nodes(t);
 	memset(t->slots, 0, sizeof(struct dm_hash_node *) * t->num_slots);
-	t->num_nodes = 0u;
+	t->num_nodes = t->collisions = t->search = t->same_hash = 0u;
 }
 
 char *dm_hash_get_key(struct dm_hash_table *t __attribute__((unused)),
@@ -262,7 +288,5 @@ struct dm_hash_node *dm_hash_get_first(struct dm_hash_table *t)
 
 struct dm_hash_node *dm_hash_get_next(struct dm_hash_table *t, struct dm_hash_node *n)
 {
-	unsigned h = _hash(n->key, n->keylen) & (t->num_slots - 1);
-
-	return n->next ? n->next : _next_slot(t, h + 1);
+	return n->next ? n->next : _next_slot(t, (n->hash & t->mask) + 1);
 }
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index eea1a6c..2ddcc96 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -707,10 +707,10 @@ void *dm_hash_lookup(struct dm_hash_table *t, const char *key);
 int dm_hash_insert(struct dm_hash_table *t, const char *key, void *data);
 void dm_hash_remove(struct dm_hash_table *t, const char *key);
 
-void *dm_hash_lookup_binary(struct dm_hash_table *t, const char *key, uint32_t len);
-int dm_hash_insert_binary(struct dm_hash_table *t, const char *key, uint32_t len,
+void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key, uint32_t len);
+int dm_hash_insert_binary(struct dm_hash_table *t, const void *key, uint32_t len,
 		       void *data);
-void dm_hash_remove_binary(struct dm_hash_table *t, const char *key, uint32_t len);
+void dm_hash_remove_binary(struct dm_hash_table *t, const void *key, uint32_t len);
 
 unsigned dm_hash_get_num_entries(struct dm_hash_table *t);
 void dm_hash_iter(struct dm_hash_table *t, dm_hash_iterate_fn f);
-- 
1.7.3.5


