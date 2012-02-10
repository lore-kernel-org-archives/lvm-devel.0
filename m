From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Feb 2012 13:49:32 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/regex/matcher.c test ...
Message-ID: <20120210134932.22907.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-10 13:49:30

Modified files:
	.              : WHATS_NEW_DM 
	libdm/regex    : matcher.c 
	test/unit      : matcher_t.c 

Log message:
	Add test for memory allocation failures
	
	Replace asserts with test for failing memory allocation.
	Add at least stack traces.
	Index counter starts from 1 (0 reserved for error), so replacing fingerprint.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.542&r2=1.543
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/matcher_t.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW_DM	2012/02/08 12:59:19	1.542
+++ LVM2/WHATS_NEW_DM	2012/02/10 13:49:29	1.543
@@ -1,5 +1,6 @@
 Version 1.02.70 - 
 ===================================
+  Add test for memory allocation failures in regex matcher code.
   Simplify dm_task_set_geometry() and use dm_asprintf().
   Set all parameters to 0 for dm_get_next_target() for NULL return.
   Fix fd resource leak in error path for _udev_notify_sem_create().
--- LVM2/libdm/regex/matcher.c	2011/04/08 14:40:21	1.17
+++ LVM2/libdm/regex/matcher.c	2012/02/10 13:49:30	1.18
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -98,16 +98,22 @@
                 m->charsets[m->charsets_entered++] = rx;
 }
 
-static void _create_bitsets(struct dm_regex *m)
+static int _create_bitsets(struct dm_regex *m)
 {
 	unsigned i;
+	struct rx_node *n;
 
 	for (i = 0; i < m->num_nodes; i++) {
-		struct rx_node *n = m->nodes[i];
-		n->firstpos = dm_bitset_create(m->scratch, m->num_charsets);
-		n->lastpos = dm_bitset_create(m->scratch, m->num_charsets);
-		n->followpos = dm_bitset_create(m->scratch, m->num_charsets);
+		n = m->nodes[i];
+		if (!(n->firstpos = dm_bitset_create(m->scratch, m->num_charsets)))
+			return_0;
+		if (!(n->lastpos = dm_bitset_create(m->scratch, m->num_charsets)))
+			return_0;
+		if (!(n->followpos = dm_bitset_create(m->scratch, m->num_charsets)))
+			return_0;
 	}
+
+	return 1;
 }
 
 static void _calc_functions(struct dm_regex *m)
@@ -206,14 +212,17 @@
                                              struct dfa_state *dfa,
                                              dm_bitset_t bits)
 {
-	dfa->bits = dm_bitset_create(mem, bits[0]);	/* first element is the size */
+	if (!(dfa->bits = dm_bitset_create(mem, bits[0])))  /* first element is the size */
+		return_NULL;
+
 	dm_bit_copy(dfa->bits, bits);
 	dfa->next = 0;
-        dfa->final = -1;
+	dfa->final = -1;
+
 	return dfa;
 }
 
-static void _calc_state(struct dm_regex *m, struct dfa_state *dfa, int a)
+static int _calc_state(struct dm_regex *m, struct dfa_state *dfa, int a)
 {
         int set_bits = 0, i;
         dm_bitset_t dfa_bits = dfa->bits;
@@ -233,9 +242,12 @@
                 struct dfa_state *ldfa = ttree_lookup(m->tt, m->bs + 1);
                 if (!ldfa) {
                         /* push */
-                        ldfa = _create_dfa_state(m->mem);
-                        ttree_insert(m->tt, m->bs + 1, ldfa);
-                        tmp = _create_state_queue(m->scratch, ldfa, m->bs);
+			if (!(ldfa = _create_dfa_state(m->mem)))
+				return_0;
+
+			ttree_insert(m->tt, m->bs + 1, ldfa);
+			if (!(tmp = _create_state_queue(m->scratch, ldfa, m->bs)))
+				return_0;
                         if (!m->h)
                                 m->h = m->t = tmp;
                         else {
@@ -247,32 +259,32 @@
                 dfa->lookup[a] = ldfa;
                 dm_bit_clear_all(m->bs);
         }
+
+	return 1;
 }
 
 static int _calc_states(struct dm_regex *m, struct rx_node *rx)
 {
 	unsigned iwidth = (m->num_charsets / DM_BITS_PER_INT) + 1;
 	struct dfa_state *dfa;
+	struct rx_node *n;
 	unsigned i;
 	int a;
 
-	m->tt = ttree_create(m->scratch, iwidth);
-	if (!m->tt)
+	if (!(m->tt = ttree_create(m->scratch, iwidth)))
 		return_0;
 
 	if (!(m->bs = dm_bitset_create(m->scratch, m->num_charsets)))
 		return_0;
 
         /* build some char maps */
-        for (a = 0; a < 256; a++) {
-                m->charmap[a] = dm_bitset_create(m->scratch, m->num_charsets);
-                if (!m->charmap[a])
-                        return_0;
-        }
+        for (a = 0; a < 256; a++)
+		if (!(m->charmap[a] = dm_bitset_create(m->scratch, m->num_charsets)))
+			return_0;
 
         for (i = 0; i < m->num_nodes; i++) {
-                struct rx_node *n = m->nodes[i];
-                if (n->type == CHARSET) {
+		n = m->nodes[i];
+                        if (n->type == CHARSET) {
                         for (a = dm_bit_get_first(n->charset);
                              a >= 0; a = dm_bit_get_next(n->charset, a))
                                 dm_bit_set(m->charmap[a], n->charset_index);
@@ -280,13 +292,19 @@
         }
 
 	/* create first state */
-	dfa = _create_dfa_state(m->mem);
+	if (!(dfa = _create_dfa_state(m->mem)))
+		return_0;
+
 	m->start = dfa;
 	ttree_insert(m->tt, rx->firstpos + 1, dfa);
 
 	/* prime the queue */
-	m->h = m->t = _create_state_queue(m->scratch, dfa, rx->firstpos);
-        m->dfa_copy = dm_bitset_create(m->scratch, m->num_charsets);
+	if (!(m->h = m->t = _create_state_queue(m->scratch, dfa, rx->firstpos)))
+		return_0;
+
+	if (!(m->dfa_copy = dm_bitset_create(m->scratch, m->num_charsets)))
+		return_0;
+
 	return 1;
 }
 
@@ -294,7 +312,7 @@
  * Forces all the dfa states to be calculated up front, ie. what
  * _calc_states() used to do before we switched to calculating on demand.
  */
-static void _force_states(struct dm_regex *m)
+static int _force_states(struct dm_regex *m)
 {
         int a;
 
@@ -307,8 +325,11 @@
                 /* iterate through all the inputs for this state */
                 dm_bit_clear_all(m->bs);
                 for (a = 0; a < 256; a++)
-                        _calc_state(m, s, a);
+			if (!_calc_state(m, s, a))
+				return_0;
         }
+
+        return 1;
 }
 
 struct dm_regex *dm_regex_create(struct dm_pool *mem, const char * const *patterns,
@@ -348,24 +369,29 @@
 	m->mem = mem;
 	m->scratch = scratch;
 	m->num_nodes = _count_nodes(rx);
-        m->num_charsets = _count_charsets(rx);
-        _enumerate_charsets(rx);
-	m->nodes = dm_pool_alloc(scratch, sizeof(*m->nodes) * m->num_nodes);
-	if (!m->nodes)
+	m->num_charsets = _count_charsets(rx);
+	_enumerate_charsets(rx);
+	if (!(m->nodes = dm_pool_alloc(scratch, sizeof(*m->nodes) * m->num_nodes)))
 		goto_bad;
 
-        m->charsets = dm_pool_alloc(scratch, sizeof(*m->charsets) * m->num_charsets);
-        if (!m->charsets)
-                goto_bad;
+	if (!(m->charsets = dm_pool_alloc(scratch, sizeof(*m->charsets) * m->num_charsets)))
+		goto_bad;
 
 	_fill_table(m, rx);
-	_create_bitsets(m);
+
+	if (!_create_bitsets(m))
+		goto_bad;
+
 	_calc_functions(m);
-	_calc_states(m, rx);
+
+	if (!_calc_states(m, rx))
+		goto_bad;
+
 	return m;
 
       bad:
 	dm_pool_free(mem, m);
+
 	return NULL;
 }
 
@@ -374,14 +400,17 @@
         struct dfa_state *ns;
 
 	if (!(ns = cs->lookup[(unsigned char) c])) {
-		_calc_state(m, cs, (unsigned char) c);
+		if (!_calc_state(m, cs, (unsigned char) c))
+                        return_NULL;
+
 		if (!(ns = cs->lookup[(unsigned char) c]))
 			return NULL;
 	}
 
         // yuck, we have to special case the target trans
-        if (ns->final == -1)
-                _calc_state(m, ns, TARGET_TRANS);
+	if ((ns->final == -1) &&
+	    !_calc_state(m, ns, TARGET_TRANS))
+                return_NULL;
 
 	if (ns->final && (ns->final > *r))
 		*r = ns->final;
@@ -434,14 +463,14 @@
         unsigned next_index;
 };
 
-static uint32_t randomise_(uint32_t n)
+static uint32_t _randomise(uint32_t n)
 {
         /* 2^32 - 5 */
         uint32_t const prime = (~0) - 4;
         return n * prime;
 }
 
-static int seen_(struct node_list *n, struct dfa_state *node, uint32_t *i)
+static int _seen(struct node_list *n, struct dfa_state *node, uint32_t *i)
 {
         while (n) {
                 if (n->node == node) {
@@ -457,32 +486,36 @@
 /*
  * Push node if it's not been seen before, returning a unique index.
  */
-static uint32_t push_node_(struct printer *p, struct dfa_state *node)
+static uint32_t _push_node(struct printer *p, struct dfa_state *node)
 {
         uint32_t i;
-        if (seen_(p->pending, node, &i) ||
-            seen_(p->processed, node, &i))
+	struct node_list *n;
+
+        if (_seen(p->pending, node, &i) ||
+            _seen(p->processed, node, &i))
                 return i;
-        else {
-                struct node_list *n = dm_pool_alloc(p->mem, sizeof(*n));
-                assert(n);
-                n->node_id = p->next_index++;
-                n->node = node;
-                n->next = p->pending;
-                p->pending = n;
-                return n->node_id;
-        }
+
+	if (!(n = dm_pool_alloc(p->mem, sizeof(*n))))
+		return_0;
+
+	n->node_id = ++p->next_index; /* start from 1, keep 0 as error code */
+	n->node = node;
+	n->next = p->pending;
+	p->pending = n;
+
+	return n->node_id;
 }
 
 /*
  * Pop the front node, and fill out it's previously assigned index.
  */
-static struct dfa_state *pop_node_(struct printer *p)
+static struct dfa_state *_pop_node(struct printer *p)
 {
         struct dfa_state *node = NULL;
+	struct node_list *n;
 
-        if (p->pending) {
-                struct node_list *n = p->pending;
+	if (p->pending) {
+		n = p->pending;
                 p->pending = n->next;
                 n->next = p->processed;
                 p->processed = n;
@@ -493,22 +526,22 @@
         return node;
 }
 
-static uint32_t combine_(uint32_t n1, uint32_t n2)
+static uint32_t _combine(uint32_t n1, uint32_t n2)
 {
-        return ((n1 << 8) | (n1 >> 24)) ^ randomise_(n2);
+        return ((n1 << 8) | (n1 >> 24)) ^ _randomise(n2);
 }
 
-static uint32_t fingerprint_(struct printer *p)
+static uint32_t _fingerprint(struct printer *p)
 {
         int c;
         uint32_t result = 0;
         struct dfa_state *node;
 
-        while ((node = pop_node_(p))) {
-                result = combine_(result, node->final < 0 ? 0 : node->final);
+        while ((node = _pop_node(p))) {
+                result = _combine(result, (node->final < 0) ? 0 : node->final);
                 for (c = 0; c < 256; c++)
-                        result = combine_(result,
-                                          push_node_(p, node->lookup[c]));
+                        result = _combine(result,
+                                          _push_node(p, node->lookup[c]));
         }
 
         return result;
@@ -516,20 +549,27 @@
 
 uint32_t dm_regex_fingerprint(struct dm_regex *regex)
 {
-        uint32_t result;
         struct printer p;
+        uint32_t result = 0;
         struct dm_pool *mem = dm_pool_create("regex fingerprint", 1024);
 
-        _force_states(regex);
+	if (!mem)
+		return_0;
+
+	if (!_force_states(regex))
+		goto_out;
 
-        assert(mem);
         p.mem = mem;
         p.pending = NULL;
         p.processed = NULL;
         p.next_index = 0;
 
-        push_node_(&p, regex->start);
-        result = fingerprint_(&p);
+	if (!_push_node(&p, regex->start))
+		goto_out;
+
+	result = _fingerprint(&p);
+out:
         dm_pool_destroy(mem);
+
         return result;
 }
--- LVM2/test/unit/matcher_t.c	2011/12/13 12:08:42	1.2
+++ LVM2/test/unit/matcher_t.c	2012/02/10 13:49:30	1.3
@@ -58,10 +58,10 @@
 	struct dm_regex *scanner;
 
 	scanner = make_scanner(dev_patterns);
-	CU_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x352b6c4f);
+	CU_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x7f556c09);
 
 	scanner = make_scanner(random_patterns);
-	CU_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0xeed8ceb8);
+	CU_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x9f11076c);
 }
 
 static void test_matching(void) {


