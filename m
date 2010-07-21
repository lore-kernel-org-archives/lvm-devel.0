From: thornber@sourceware.org <thornber@sourceware.org>
Date: 21 Jul 2010 12:02:51 -0000
Subject: LVM2/libdm/regex matcher.c
Message-ID: <20100721120251.13584.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-21 12:02:51

Modified files:
	libdm/regex    : matcher.c 

Log message:
	[REGEX] remove the state_queue structure.
	
	Instead we just have a 'next' field in the dfa_state.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/libdm/regex/matcher.c	2010/07/21 12:00:53	1.9
+++ LVM2/libdm/regex/matcher.c	2010/07/21 12:02:51	1.10
@@ -19,14 +19,10 @@
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
@@ -44,7 +40,7 @@
         dm_bitset_t dfa_copy;
         struct ttree *tt;
         dm_bitset_t bs;
-        struct state_queue *h, *t;
+        struct dfa_state *h, *t;
 };
 
 static int _count_nodes(struct rx_node *rx)
@@ -206,29 +202,20 @@
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
-
-	if (!r) {
-		stack;
-		return NULL;
-	}
-
-	r->s = dfa;
-	r->bits = dm_bitset_create(mem, bits[0]);	/* first element is the size */
-	dm_bit_copy(r->bits, bits);
-	r->next = 0;
-	return r;
+	dfa->bits = dm_bitset_create(mem, bits[0]);	/* first element is the size */
+	dm_bit_copy(dfa->bits, bits);
+	dfa->next = 0;
+	return dfa;
 }
 
-static void _calc_state(struct dm_regex *m, struct state_queue *h, int a)
+static void _calc_state(struct dm_regex *m, struct dfa_state *dfa, int a)
 {
         int set_bits = 0, i;
-        struct dfa_state *dfa = h->s;
-        dm_bitset_t dfa_bits = h->bits;
+        dm_bitset_t dfa_bits = dfa->bits;
         dm_bit_and(m->dfa_copy, m->charmap[a], dfa_bits);
 
         /* iterate through all the states in firstpos */
@@ -241,7 +228,7 @@
         }
 
         if (set_bits) {         /* FIXME: this is always true */
-                struct state_queue *tmp;
+                struct dfa_state *tmp;
                 struct dfa_state *ldfa = ttree_lookup(m->tt, m->bs + 1);
                 if (!ldfa) {
                         /* push */
@@ -300,7 +287,7 @@
         m->dfa_copy = dm_bitset_create(m->scratch, m->num_charsets);
 
         /* keep processing until there's nothing in the queue */
-        struct state_queue *s;
+        struct dfa_state *s;
 	while ((s = m->h)) {
 		/* pop state off front of the queue */
 		m->h = m->h->next;


