From: thornber@sourceware.org <thornber@sourceware.org>
Date: 21 Jul 2010 11:58:53 -0000
Subject: LVM2/libdm/regex matcher.c parse_rx.c parse_rx.h
Message-ID: <20100721115853.19342.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-21 11:58:50

Modified files:
	libdm/regex    : matcher.c parse_rx.c parse_rx.h 

Log message:
	[REGEX] reduce the number of charset nodes that are produced

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/libdm/regex/matcher.c	2010/07/20 15:32:07	1.7
+++ LVM2/libdm/regex/matcher.c	2010/07/21 11:58:49	1.8
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
@@ -32,8 +32,11 @@
 struct dm_regex {		/* Instance variables for the lexer */
 	struct dfa_state *start;
 	unsigned num_nodes;
+        unsigned num_charsets;
 	int nodes_entered;
 	struct rx_node **nodes;
+        int charsets_entered;
+        struct rx_node **charsets;
 	struct dm_pool *scratch, *mem;
 };
 
@@ -50,6 +53,33 @@
 	return r;
 }
 
+static unsigned _count_charsets(struct rx_node *rx)
+{
+        if (rx->type == CHARSET)
+                return 1;
+
+        return (rx->left ? _count_charsets(rx->left) : 0) +
+                (rx->right ? _count_charsets(rx->right) : 0);
+}
+
+static void _enumerate_charsets_internal(struct rx_node *rx, unsigned *i)
+{
+        if (rx->type == CHARSET)
+                rx->charset_index = (*i)++;
+        else {
+                if (rx->left)
+                        _enumerate_charsets_internal(rx->left, i);
+                if (rx->right)
+                        _enumerate_charsets_internal(rx->right, i);
+        }
+}
+
+static void _enumerate_charsets(struct rx_node *rx)
+{
+        unsigned i = 0;
+        _enumerate_charsets_internal(rx, &i);
+}
+
 static void _fill_table(struct dm_regex *m, struct rx_node *rx)
 {
 	assert((rx->type != OR) || (rx->left && rx->right));
@@ -61,6 +91,8 @@
 		_fill_table(m, rx->right);
 
 	m->nodes[m->nodes_entered++] = rx;
+        if (rx->type == CHARSET)
+                m->charsets[m->charsets_entered++] = rx;
 }
 
 static void _create_bitsets(struct dm_regex *m)
@@ -69,9 +101,9 @@
 
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
 
@@ -85,7 +117,7 @@
 		c1 = rx->left;
 		c2 = rx->right;
 
-		if (dm_bit(rx->charset, TARGET_TRANS))
+		if (rx->type == CHARSET && dm_bit(rx->charset, TARGET_TRANS))
 			rx->final = final++;
 
 		switch (rx->type) {
@@ -125,8 +157,8 @@
 			break;
 
 		case CHARSET:
-			dm_bit_set(rx->firstpos, i);
-			dm_bit_set(rx->lastpos, i);
+			dm_bit_set(rx->firstpos, rx->charset_index);
+			dm_bit_set(rx->lastpos, rx->charset_index);
 			rx->nullable = 0;
 			break;
 
@@ -141,23 +173,21 @@
 		 */
 		switch (rx->type) {
 		case CAT:
-			for (j = 0; j < m->num_nodes; j++) {
-				if (dm_bit(c1->lastpos, j)) {
-					struct rx_node *n = m->nodes[j];
+			for (j = 0; j < m->num_charsets; j++) {
+                                struct rx_node *n = m->charsets[j];
+				if (dm_bit(c1->lastpos, j))
 					dm_bit_union(n->followpos,
-						  n->followpos, c2->firstpos);
-				}
+                                                     n->followpos, c2->firstpos);
 			}
 			break;
 
 		case PLUS:
 		case STAR:
-			for (j = 0; j < m->num_nodes; j++) {
-				if (dm_bit(rx->lastpos, j)) {
-					struct rx_node *n = m->nodes[j];
+			for (j = 0; j < m->num_charsets; j++) {
+                                struct rx_node *n = m->charsets[j];
+				if (dm_bit(rx->lastpos, j))
 					dm_bit_union(n->followpos,
-						  n->followpos, rx->firstpos);
-				}
+                                                     n->followpos, rx->firstpos);
 			}
 			break;
 		}
@@ -189,7 +219,7 @@
 
 static int _calc_states(struct dm_regex *m, struct rx_node *rx)
 {
-	unsigned iwidth = (m->num_nodes / DM_BITS_PER_INT) + 1;
+	unsigned iwidth = (m->num_charsets / DM_BITS_PER_INT) + 1;
 	struct ttree *tt = ttree_create(m->scratch, iwidth);
 	struct state_queue *h, *t, *tmp;
 	struct dfa_state *dfa, *ldfa;
@@ -199,9 +229,26 @@
 	if (!tt)
 		return_0;
 
-	if (!(bs = dm_bitset_create(m->scratch, m->num_nodes)))
+	if (!(bs = dm_bitset_create(m->scratch, m->num_charsets)))
 		return_0;
 
+        /* build some char maps */
+        dm_bitset_t charmap[256];
+        for (a = 0; a < 256; a++) {
+                charmap[a] = dm_bitset_create(m->scratch, m->num_charsets);
+                if (!charmap[a])
+                        return_0;
+        }
+
+        for (i = 0; i < m->num_nodes; i++) {
+                struct rx_node *n = m->nodes[i];
+                if (n->type == CHARSET) {
+                        for (a = dm_bit_get_first(n->charset);
+                             a >= 0; a = dm_bit_get_next(n->charset, a))
+                                dm_bit_set(charmap[a], n->charset_index);
+                }
+        }
+
 	/* create first state */
 	dfa = _create_dfa_state(m->mem);
 	m->start = dfa;
@@ -209,8 +256,9 @@
 
 	/* prime the queue */
 	h = t = _create_state_queue(m->scratch, dfa, rx->firstpos);
+        dm_bitset_t dfa_copy = dm_bitset_create(m->scratch, m->num_charsets);
 	while (h) {
-		int elems, j, idx[h->bits[0]];
+		int elems, idx[h->bits[0]];
 
 		/* pop state off front of the queue */
 		dfa = h->s;
@@ -227,18 +275,18 @@
 			idx[elems++] = i;
 
 		for (a = 0; a < 256; a++) {
+                        dm_bit_and(dfa_copy, charmap[a], dfa_bits);
+
 			/* iterate through all the states in firstpos */
-			for (j = 0; j < elems; j++) {
-				i = idx[j];
-				if (dm_bit(m->nodes[i]->charset, a)) {
-					if (a == TARGET_TRANS)
-						dfa->final = m->nodes[i]->final;
-
-					dm_bit_union(bs, bs,
-						  m->nodes[i]->followpos);
-					set_bits = 1;
-				}
-			}
+                        for (i = dm_bit_get_first(dfa_copy);
+                             i >= 0; i = dm_bit_get_next(dfa_copy, i)) {
+                                if (a == TARGET_TRANS)
+                                        dfa->final = m->charsets[i]->final;
+
+                                dm_bit_union(bs, bs,
+                                             m->charsets[i]->followpos);
+                                set_bits = 1;
+                        }
 
 			if (set_bits) {
 				ldfa = ttree_lookup(tt, bs + 1);
@@ -314,11 +362,16 @@
 	m->mem = mem;
 	m->scratch = scratch;
 	m->num_nodes = _count_nodes(rx);
+        m->num_charsets = _count_charsets(rx);
+        _enumerate_charsets(rx);
 	m->nodes = dm_pool_alloc(scratch, sizeof(*m->nodes) * m->num_nodes);
-
 	if (!m->nodes)
 		goto_bad;
 
+        m->charsets = dm_pool_alloc(scratch, sizeof(*m->charsets) * m->num_charsets);
+        if (!m->charsets)
+                goto_bad;
+
 	_fill_table(m, rx);
 	_create_bitsets(m);
 	_calc_functions(m);
--- LVM2/libdm/regex/parse_rx.c	2010/04/22 23:09:18	1.11
+++ LVM2/libdm/regex/parse_rx.c	2010/07/21 11:58:49	1.12
@@ -284,7 +284,7 @@
 	struct rx_node *n = dm_pool_zalloc(mem, sizeof(*n));
 
 	if (n) {
-		if (!(n->charset = dm_bitset_create(mem, 256))) {
+		if (type == CHARSET && !(n->charset = dm_bitset_create(mem, 256))) {
 			dm_pool_free(mem, n);
 			return NULL;
 		}
--- LVM2/libdm/regex/parse_rx.h	2010/04/22 23:09:18	1.3
+++ LVM2/libdm/regex/parse_rx.h	2010/07/21 11:58:49	1.4
@@ -41,6 +41,7 @@
 	struct rx_node *left, *right;
 
 	/* used to build the dfa for the toker */
+        unsigned charset_index;
 	int nullable, final;
 	dm_bitset_t firstpos;
 	dm_bitset_t lastpos;


