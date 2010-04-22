From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 22 Apr 2010 15:29:04 +0200
Subject: [PATCH 3/3] New regexp code made by EJT.
In-Reply-To: <cover.1271942633.git.zkabelac@redhat.com>
References: <cover.1271942633.git.zkabelac@redhat.com>
Message-ID: <b3ce780d00e49bd1af62cc00405b08291e4ed39f.1271942633.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It remove  'scratch' buffer usage and avoids expression optimization.
It creates regexp tree differently (and faster) then current algorihtm.

So far not tested deeply, but survived few things.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/regex/matcher.c  |  265 +++++++++++++++++++++++++++---------------------
 libdm/regex/parse_rx.c |    4 +-
 libdm/regex/parse_rx.h |    1 +
 3 files changed, 154 insertions(+), 116 deletions(-)

diff --git a/libdm/regex/matcher.c b/libdm/regex/matcher.c
index d9c2d8a..19f4043 100644
--- a/libdm/regex/matcher.c
+++ b/libdm/regex/matcher.c
@@ -1,6 +1,6 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -19,22 +19,28 @@
 #include "assert.h"
 
 struct dfa_state {
+	struct dfa_state *next;
 	int final;
-	struct dfa_state *lookup[256];
-};
-
-struct state_queue {
-	struct dfa_state *s;
 	dm_bitset_t bits;
-	struct state_queue *next;
+	struct dfa_state *lookup[256];
 };
 
 struct dm_regex {		/* Instance variables for the lexer */
 	struct dfa_state *start;
 	unsigned num_nodes;
+	unsigned num_charsets;
 	int nodes_entered;
 	struct rx_node **nodes;
+	int charsets_entered;
+	struct rx_node **charsets;
 	struct dm_pool *scratch, *mem;
+
+	/* stuff for on the fly dfa calculation */
+	dm_bitset_t charmap[256];
+	dm_bitset_t dfa_copy;
+	struct ttree *tt;
+	dm_bitset_t bs;
+	struct dfa_state *h, *t;
 };
 
 #define TARGET_TRANS '\0'
@@ -52,6 +58,33 @@ static int _count_nodes(struct rx_node *rx)
 	return r;
 }
 
+static unsigned _count_charsets(struct rx_node *rx)
+{
+	if (rx->type == CHARSET)
+		return 1;
+
+	return (rx->left ? _count_charsets(rx->left) : 0) +
+		(rx->right ? _count_charsets(rx->right) : 0);
+}
+
+static void _enumerate_charsets_internal(struct rx_node *rx, unsigned *i)
+{
+	if (rx->type == CHARSET)
+		rx->charset_index = (*i)++;
+	else {
+		if (rx->left)
+			_enumerate_charsets_internal(rx->left, i);
+		if (rx->right)
+			_enumerate_charsets_internal(rx->right, i);
+	}
+}
+
+static void _enumerate_charsets(struct rx_node *rx)
+{
+	unsigned i = 0;
+	_enumerate_charsets_internal(rx, &i);
+}
+
 static void _fill_table(struct dm_regex *m, struct rx_node *rx)
 {
 	assert((rx->type != OR) || (rx->left && rx->right));
@@ -63,6 +96,8 @@ static void _fill_table(struct dm_regex *m, struct rx_node *rx)
 		_fill_table(m, rx->right);
 
 	m->nodes[m->nodes_entered++] = rx;
+	if (rx->type == CHARSET)
+		m->charsets[m->charsets_entered++] = rx;
 }
 
 static void _create_bitsets(struct dm_regex *m)
@@ -71,9 +106,9 @@ static void _create_bitsets(struct dm_regex *m)
 
 	for (i = 0; i < m->num_nodes; i++) {
 		struct rx_node *n = m->nodes[i];
-		n->firstpos = dm_bitset_create(m->scratch, m->num_nodes);
-		n->lastpos = dm_bitset_create(m->scratch, m->num_nodes);
-		n->followpos = dm_bitset_create(m->scratch, m->num_nodes);
+		n->firstpos = dm_bitset_create(m->scratch, m->num_charsets);
+		n->lastpos = dm_bitset_create(m->scratch, m->num_charsets);
+		n->followpos = dm_bitset_create(m->scratch, m->num_charsets);
 	}
 }
 
@@ -87,7 +122,7 @@ static void _calc_functions(struct dm_regex *m)
 		c1 = rx->left;
 		c2 = rx->right;
 
-		if (dm_bit(rx->charset, TARGET_TRANS))
+		if (rx->type == CHARSET && dm_bit(rx->charset, TARGET_TRANS))
 			rx->final = final++;
 
 		switch (rx->type) {
@@ -127,8 +162,8 @@ static void _calc_functions(struct dm_regex *m)
 			break;
 
 		case CHARSET:
-			dm_bit_set(rx->firstpos, i);
-			dm_bit_set(rx->lastpos, i);
+			dm_bit_set(rx->firstpos, rx->charset_index);
+			dm_bit_set(rx->lastpos, rx->charset_index);
 			rx->nullable = 0;
 			break;
 
@@ -143,23 +178,21 @@ static void _calc_functions(struct dm_regex *m)
 		 */
 		switch (rx->type) {
 		case CAT:
-			for (j = 0; j < m->num_nodes; j++) {
-				if (dm_bit(c1->lastpos, j)) {
-					struct rx_node *n = m->nodes[j];
+			for (j = 0; j < m->num_charsets; j++) {
+				struct rx_node *n = m->charsets[j];
+				if (dm_bit(c1->lastpos, j))
 					dm_bit_union(n->followpos,
-						  n->followpos, c2->firstpos);
-				}
+						     n->followpos, c2->firstpos);
 			}
 			break;
 
 		case PLUS:
 		case STAR:
-			for (j = 0; j < m->num_nodes; j++) {
-				if (dm_bit(rx->lastpos, j)) {
-					struct rx_node *n = m->nodes[j];
+			for (j = 0; j < m->num_charsets; j++) {
+				struct rx_node *n = m->charsets[j];
+				if (dm_bit(rx->lastpos, j))
 					dm_bit_union(n->followpos,
-						  n->followpos, rx->firstpos);
-				}
+						     n->followpos, rx->firstpos);
 			}
 			break;
 		}
@@ -171,95 +204,91 @@ static struct dfa_state *_create_dfa_state(struct dm_pool *mem)
 	return dm_pool_zalloc(mem, sizeof(struct dfa_state));
 }
 
-static struct state_queue *_create_state_queue(struct dm_pool *mem,
-					       struct dfa_state *dfa,
-					       dm_bitset_t bits)
+static struct dfa_state *_create_state_queue(struct dm_pool *mem,
+                                             struct dfa_state *dfa,
+                                             dm_bitset_t bits)
 {
-	struct state_queue *r = dm_pool_alloc(mem, sizeof(*r));
+	dfa->bits = dm_bitset_create(mem, bits[0]);	/* first element is the size */
+	dm_bit_copy(dfa->bits, bits);
+	dfa->next = 0;
+	dfa->final = -1;
+	return dfa;
+}
 
-	if (!r) {
-		stack;
-		return NULL;
+static void _calc_state(struct dm_regex *m, struct dfa_state *dfa, int a)
+{
+	int set_bits = 0, i;
+	struct dfa_state *tmp, *ldfa;
+	dm_bitset_t dfa_bits = dfa->bits;
+
+	dm_bit_and(m->dfa_copy, m->charmap[a], dfa_bits);
+
+	/* iterate through all the states in firstpos */
+	for (i = dm_bit_get_first(m->dfa_copy); i >= 0; i = dm_bit_get_next(m->dfa_copy, i)) {
+		if (a == TARGET_TRANS)
+			dfa->final = m->charsets[i]->final;
+
+		dm_bit_union(m->bs, m->bs, m->charsets[i]->followpos);
+		set_bits = 1;
 	}
 
-	r->s = dfa;
-	r->bits = dm_bitset_create(mem, bits[0]);	/* first element is the size */
-	dm_bit_copy(r->bits, bits);
-	r->next = 0;
-	return r;
+	if (set_bits) {
+		ldfa = ttree_lookup(m->tt, m->bs + 1);
+		if (!ldfa) {
+			/* push */
+			ldfa = _create_dfa_state(m->mem);
+			ttree_insert(m->tt, m->bs + 1, ldfa);
+			tmp = _create_state_queue(m->scratch, ldfa, m->bs);
+			if (!m->h)
+				m->h = m->t = tmp;
+			else {
+				m->t->next = tmp;
+				m->t = tmp;
+			}
+		}
+
+		dfa->lookup[a] = ldfa;
+		dm_bit_clear_all(m->bs);
+	}
 }
 
 static int _calc_states(struct dm_regex *m, struct rx_node *rx)
 {
-	unsigned iwidth = (m->num_nodes / DM_BITS_PER_INT) + 1;
-	struct ttree *tt = ttree_create(m->scratch, iwidth);
-	struct state_queue *h, *t, *tmp;
-	struct dfa_state *dfa, *ldfa;
-	int i, a, set_bits = 0, count = 0;
-	dm_bitset_t bs, dfa_bits;
-
-	if (!tt)
+	unsigned iwidth = (m->num_charsets / DM_BITS_PER_INT) + 1;
+	struct dfa_state *dfa;
+	int i, a;
+
+	m->tt = ttree_create(m->scratch, iwidth);
+	if (!m->tt)
 		return_0;
 
-	if (!(bs = dm_bitset_create(m->scratch, m->num_nodes)))
+	if (!(m->bs = dm_bitset_create(m->scratch, m->num_charsets)))
 		return_0;
 
+	/* build some char maps */
+	for (a = 0; a < 256; a++) {
+		m->charmap[a] = dm_bitset_create(m->scratch, m->num_charsets);
+		if (!m->charmap[a])
+			return_0;
+	}
+
+	for (i = 0; i < m->num_nodes; i++) {
+		struct rx_node *n = m->nodes[i];
+		if (n->type == CHARSET) {
+			for (a = dm_bit_get_first(n->charset);
+			      a >= 0; a = dm_bit_get_next(n->charset, a))
+				dm_bit_set(m->charmap[a], n->charset_index);
+		}
+	}
+
 	/* create first state */
 	dfa = _create_dfa_state(m->mem);
 	m->start = dfa;
-	ttree_insert(tt, rx->firstpos + 1, dfa);
+	ttree_insert(m->tt, rx->firstpos + 1, dfa);
 
 	/* prime the queue */
-	h = t = _create_state_queue(m->scratch, dfa, rx->firstpos);
-	while (h) {
-		/* pop state off front of the queue */
-		dfa = h->s;
-		dfa_bits = h->bits;
-		h = h->next;
-
-		/* iterate through all the inputs for this state */
-		dm_bit_clear_all(bs);
-		for (a = 0; a < 256; a++) {
-			/* iterate through all the states in firstpos */
-			for (i = dm_bit_get_first(dfa_bits);
-			     i >= 0; i = dm_bit_get_next(dfa_bits, i)) {
-				if (dm_bit(m->nodes[i]->charset, a)) {
-					if (a == TARGET_TRANS)
-						dfa->final = m->nodes[i]->final;
-
-					dm_bit_union(bs, bs,
-						  m->nodes[i]->followpos);
-					set_bits = 1;
-				}
-			}
-
-			if (set_bits) {
-				ldfa = ttree_lookup(tt, bs + 1);
-				if (!ldfa) {
-					/* push */
-					ldfa = _create_dfa_state(m->mem);
-					ttree_insert(tt, bs + 1, ldfa);
-					tmp =
-					    _create_state_queue(m->scratch,
-								ldfa, bs);
-					if (!h)
-						h = t = tmp;
-					else {
-						t->next = tmp;
-						t = tmp;
-					}
-
-					count++;
-				}
-
-				dfa->lookup[a] = ldfa;
-				set_bits = 0;
-				dm_bit_clear_all(bs);
-			}
-		}
-	}
-
-	log_debug("Matcher built with %d dfa states", count);
+	m->h = m->t = _create_state_queue(m->scratch, dfa, rx->firstpos);
+	m->dfa_copy = dm_bitset_create(m->scratch, m->num_charsets);
 	return 1;
 }
 
@@ -270,16 +299,11 @@ struct dm_regex *dm_regex_create(struct dm_pool *mem, const char **patterns,
 	int i;
 	size_t len = 0;
 	struct rx_node *rx;
-	struct dm_pool *scratch = dm_pool_create("regex matcher", 10 * 1024);
 	struct dm_regex *m;
+	struct dm_pool *scratch = mem;
 
-	if (!scratch)
-		return_NULL;
-
-	if (!(m = dm_pool_alloc(mem, sizeof(*m)))) {
-		dm_pool_destroy(scratch);
+	if (!(m = dm_pool_alloc(mem, sizeof(*m))))
 		return_NULL;
-	}
 
 	memset(m, 0, sizeof(*m));
 
@@ -307,35 +331,47 @@ struct dm_regex *dm_regex_create(struct dm_pool *mem, const char **patterns,
 	m->mem = mem;
 	m->scratch = scratch;
 	m->num_nodes = _count_nodes(rx);
+	m->num_charsets = _count_charsets(rx);
+	_enumerate_charsets(rx);
 	m->nodes = dm_pool_alloc(scratch, sizeof(*m->nodes) * m->num_nodes);
 
 	if (!m->nodes)
 		goto_bad;
 
+	m->charsets = dm_pool_alloc(scratch, sizeof(*m->charsets) * m->num_charsets);
+	if (!m->charsets)
+		goto_bad;
+
 	_fill_table(m, rx);
 	_create_bitsets(m);
 	_calc_functions(m);
 	_calc_states(m, rx);
-	dm_pool_destroy(scratch);
-	m->scratch = NULL;
 
 	return m;
 
       bad:
-	dm_pool_destroy(scratch);
 	dm_pool_free(mem, m);
 	return NULL;
 }
 
-static struct dfa_state *_step_matcher(int c, struct dfa_state *cs, int *r)
+static struct dfa_state *_step_matcher(struct dm_regex *m, int c, struct dfa_state *cs, int *r)
 {
-	if (!(cs = cs->lookup[(unsigned char) c]))
+	struct dfa_state *ns;
+
+	if (!(ns = cs->lookup[(unsigned char) c]))
+		_calc_state(m, cs, c);
+
+	if (!(ns = cs->lookup[(unsigned char) c]))
 		return NULL;
 
-	if (cs->final && (cs->final > *r))
-		*r = cs->final;
+	// Yuck, we have to special case the target trans
+	if (ns->final == -1)
+		_calc_state(m, ns, TARGET_TRANS);
+
+	if (ns->final && (ns->final > *r))
+		*r = ns->final;
 
-	return cs;
+	return ns;
 }
 
 int dm_regex_match(struct dm_regex *regex, const char *s)
@@ -343,14 +379,15 @@ int dm_regex_match(struct dm_regex *regex, const char *s)
 	struct dfa_state *cs = regex->start;
 	int r = 0;
 
-	if (!(cs = _step_matcher(HAT_CHAR, cs, &r)))
+	dm_bit_clear_all(regex->bs);
+	if (!(cs = _step_matcher(regex, HAT_CHAR, cs, &r)))
 		goto out;
 
 	for (; *s; s++)
-		if (!(cs = _step_matcher(*s, cs, &r)))
+		if (!(cs = _step_matcher(regex, *s, cs, &r)))
 			goto out;
 
-	_step_matcher(DOLLAR_CHAR, cs, &r);
+	_step_matcher(regex, DOLLAR_CHAR, cs, &r);
 
       out:
 	/* subtract 1 to get back to zero index */
diff --git a/libdm/regex/parse_rx.c b/libdm/regex/parse_rx.c
index fdea1a3..f9e36ad 100644
--- a/libdm/regex/parse_rx.c
+++ b/libdm/regex/parse_rx.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
@@ -205,7 +205,7 @@ static struct rx_node *_node(struct dm_pool *mem, int type,
 	struct rx_node *n = dm_pool_zalloc(mem, sizeof(*n));
 
 	if (n) {
-		if (!(n->charset = dm_bitset_create(mem, 256))) {
+		if (type == CHARSET && !(n->charset = dm_bitset_create(mem, 256))) {
 			dm_pool_free(mem, n);
 			return NULL;
 		}
diff --git a/libdm/regex/parse_rx.h b/libdm/regex/parse_rx.h
index 1c2393f..a81b774 100644
--- a/libdm/regex/parse_rx.h
+++ b/libdm/regex/parse_rx.h
@@ -39,6 +39,7 @@ struct rx_node {
 	struct rx_node *left, *right;
 
 	/* used to build the dfa for the toker */
+	unsigned charset_index;
 	int nullable, final;
 	dm_bitset_t firstpos;
 	dm_bitset_t lastpos;
-- 
1.7.0.1


