From: thornber@sourceware.org <thornber@sourceware.org>
Date: 21 Jul 2010 12:00:54 -0000
Subject: LVM2 libdm/regex/matcher.c unit-tests/regex/ma ...
Message-ID: <20100721120054.20328.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-21 12:00:53

Modified files:
	libdm/regex    : matcher.c 
	unit-tests/regex: matcher_t.expected matcher_t.expected2 

Log message:
	[REGEX] factor _calc_state() out of _calc_states()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/matcher_t.expected.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/matcher_t.expected2.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/libdm/regex/matcher.c	2010/07/21 11:58:49	1.8
+++ LVM2/libdm/regex/matcher.c	2010/07/21 12:00:53	1.9
@@ -38,6 +38,13 @@
         int charsets_entered;
         struct rx_node **charsets;
 	struct dm_pool *scratch, *mem;
+
+        /* stuff for on the fly dfa calculation */
+        dm_bitset_t charmap[256];
+        dm_bitset_t dfa_copy;
+        struct ttree *tt;
+        dm_bitset_t bs;
+        struct state_queue *h, *t;
 };
 
 static int _count_nodes(struct rx_node *rx)
@@ -217,26 +224,60 @@
 	return r;
 }
 
+static void _calc_state(struct dm_regex *m, struct state_queue *h, int a)
+{
+        int set_bits = 0, i;
+        struct dfa_state *dfa = h->s;
+        dm_bitset_t dfa_bits = h->bits;
+        dm_bit_and(m->dfa_copy, m->charmap[a], dfa_bits);
+
+        /* iterate through all the states in firstpos */
+        for (i = dm_bit_get_first(m->dfa_copy); i >= 0; i = dm_bit_get_next(m->dfa_copy, i)) {
+                if (a == TARGET_TRANS)
+                        dfa->final = m->charsets[i]->final;
+
+                dm_bit_union(m->bs, m->bs, m->charsets[i]->followpos);
+                set_bits = 1;
+        }
+
+        if (set_bits) {         /* FIXME: this is always true */
+                struct state_queue *tmp;
+                struct dfa_state *ldfa = ttree_lookup(m->tt, m->bs + 1);
+                if (!ldfa) {
+                        /* push */
+                        ldfa = _create_dfa_state(m->mem);
+                        ttree_insert(m->tt, m->bs + 1, ldfa);
+                        tmp = _create_state_queue(m->scratch, ldfa, m->bs);
+                        if (!m->h)
+                                m->h = m->t = tmp;
+                        else {
+                                m->t->next = tmp;
+                                m->t = tmp;
+                        }
+                }
+
+                dfa->lookup[a] = ldfa;
+                dm_bit_clear_all(m->bs);
+        }
+}
+
 static int _calc_states(struct dm_regex *m, struct rx_node *rx)
 {
 	unsigned iwidth = (m->num_charsets / DM_BITS_PER_INT) + 1;
-	struct ttree *tt = ttree_create(m->scratch, iwidth);
-	struct state_queue *h, *t, *tmp;
-	struct dfa_state *dfa, *ldfa;
-	int i, a, set_bits = 0, count = 0;
-	dm_bitset_t bs, dfa_bits;
+	struct dfa_state *dfa;
+	int i, a;
 
-	if (!tt)
+	m->tt = ttree_create(m->scratch, iwidth);
+	if (!m->tt)
 		return_0;
 
-	if (!(bs = dm_bitset_create(m->scratch, m->num_charsets)))
+	if (!(m->bs = dm_bitset_create(m->scratch, m->num_charsets)))
 		return_0;
 
         /* build some char maps */
-        dm_bitset_t charmap[256];
         for (a = 0; a < 256; a++) {
-                charmap[a] = dm_bitset_create(m->scratch, m->num_charsets);
-                if (!charmap[a])
+                m->charmap[a] = dm_bitset_create(m->scratch, m->num_charsets);
+                if (!m->charmap[a])
                         return_0;
         }
 
@@ -245,76 +286,31 @@
                 if (n->type == CHARSET) {
                         for (a = dm_bit_get_first(n->charset);
                              a >= 0; a = dm_bit_get_next(n->charset, a))
-                                dm_bit_set(charmap[a], n->charset_index);
+                                dm_bit_set(m->charmap[a], n->charset_index);
                 }
         }
 
 	/* create first state */
 	dfa = _create_dfa_state(m->mem);
 	m->start = dfa;
-	ttree_insert(tt, rx->firstpos + 1, dfa);
+	ttree_insert(m->tt, rx->firstpos + 1, dfa);
 
 	/* prime the queue */
-	h = t = _create_state_queue(m->scratch, dfa, rx->firstpos);
-        dm_bitset_t dfa_copy = dm_bitset_create(m->scratch, m->num_charsets);
-	while (h) {
-		int elems, idx[h->bits[0]];
+	m->h = m->t = _create_state_queue(m->scratch, dfa, rx->firstpos);
+        m->dfa_copy = dm_bitset_create(m->scratch, m->num_charsets);
 
+        /* keep processing until there's nothing in the queue */
+        struct state_queue *s;
+	while ((s = m->h)) {
 		/* pop state off front of the queue */
-		dfa = h->s;
-		dfa_bits = h->bits;
-		h = h->next;
+		m->h = m->h->next;
 
 		/* iterate through all the inputs for this state */
-		dm_bit_clear_all(bs);
-
-		/* Cache list of locations of bits */
-		elems = 0;
-		for (i = dm_bit_get_first(dfa_bits);
-		     i >= 0; i = dm_bit_get_next(dfa_bits, i))
-			idx[elems++] = i;
-
-		for (a = 0; a < 256; a++) {
-                        dm_bit_and(dfa_copy, charmap[a], dfa_bits);
-
-			/* iterate through all the states in firstpos */
-                        for (i = dm_bit_get_first(dfa_copy);
-                             i >= 0; i = dm_bit_get_next(dfa_copy, i)) {
-                                if (a == TARGET_TRANS)
-                                        dfa->final = m->charsets[i]->final;
-
-                                dm_bit_union(bs, bs,
-                                             m->charsets[i]->followpos);
-                                set_bits = 1;
-                        }
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
+		dm_bit_clear_all(m->bs);
+		for (a = 0; a < 256; a++)
+                        _calc_state(m, s, a);
 	}
 
-	log_debug("Matcher built with %d dfa states", count);
 	return 1;
 }
 
--- LVM2/unit-tests/regex/matcher_t.expected	2010/07/20 15:32:07	1.2
+++ LVM2/unit-tests/regex/matcher_t.expected	2010/07/21 12:00:53	1.3
@@ -1,4 +1,3 @@
-Matcher built with 23 dfa states
 fingerprint: 352b6c4f
 /dev/loop/0 : loop/[0-9]+
 /dev/loop/1 : loop/[0-9]+
--- LVM2/unit-tests/regex/matcher_t.expected2	2010/07/21 11:52:46	1.1
+++ LVM2/unit-tests/regex/matcher_t.expected2	2010/07/21 12:00:53	1.2
@@ -1,2 +1 @@
-Matcher built with 447 dfa states
 fingerprint: eed8ceb8


