From: thornber@sourceware.org <thornber@sourceware.org>
Date: 21 Jul 2010 12:09:13 -0000
Subject: LVM2/libdm libdevmapper.h regex/matcher.c
Message-ID: <20100721120913.9343.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-21 12:09:13

Modified files:
	libdm          : libdevmapper.h 
	libdm/regex    : matcher.c 

Log message:
	[REGEX] calculate dfa states on demand

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/libdm/libdevmapper.h	2010/07/20 15:32:07	1.122
+++ LVM2/libdm/libdevmapper.h	2010/07/21 12:09:12	1.123
@@ -1012,6 +1012,8 @@
  * fingerprints are different, then the two dfas are certainly not
  * isomorphic.  If two fingerprints _are_ the same then it's very likely
  * that the dfas are isomorphic.
+ *
+ * This function must be called before any matching is done.
  */
 uint32_t dm_regex_fingerprint(struct dm_regex *regex);
 
--- LVM2/libdm/regex/matcher.c	2010/07/21 12:02:51	1.10
+++ LVM2/libdm/regex/matcher.c	2010/07/21 12:09:13	1.11
@@ -209,6 +209,7 @@
 	dfa->bits = dm_bitset_create(mem, bits[0]);	/* first element is the size */
 	dm_bit_copy(dfa->bits, bits);
 	dfa->next = 0;
+        dfa->final = -1;
 	return dfa;
 }
 
@@ -227,7 +228,7 @@
                 set_bits = 1;
         }
 
-        if (set_bits) {         /* FIXME: this is always true */
+        if (set_bits) {
                 struct dfa_state *tmp;
                 struct dfa_state *ldfa = ttree_lookup(m->tt, m->bs + 1);
                 if (!ldfa) {
@@ -285,20 +286,28 @@
 	/* prime the queue */
 	m->h = m->t = _create_state_queue(m->scratch, dfa, rx->firstpos);
         m->dfa_copy = dm_bitset_create(m->scratch, m->num_charsets);
+	return 1;
+}
+
+/*
+ * Forces all the dfa states to be calculated up front, ie. what
+ * _calc_states() used to do before we switched to calculating on demand.
+ */
+static void _force_states(struct dm_regex *m)
+{
+        int a;
 
         /* keep processing until there's nothing in the queue */
         struct dfa_state *s;
-	while ((s = m->h)) {
-		/* pop state off front of the queue */
-		m->h = m->h->next;
-
-		/* iterate through all the inputs for this state */
-		dm_bit_clear_all(m->bs);
-		for (a = 0; a < 256; a++)
-                        _calc_state(m, s, a);
-	}
+        while ((s = m->h)) {
+                /* pop state off front of the queue */
+                m->h = m->h->next;
 
-	return 1;
+                /* iterate through all the inputs for this state */
+                dm_bit_clear_all(m->bs);
+                for (a = 0; a < 256; a++)
+                        _calc_state(m, s, a);
+        }
 }
 
 struct dm_regex *dm_regex_create(struct dm_pool *mem, const char **patterns,
@@ -308,17 +317,12 @@
 	int i;
 	size_t len = 0;
 	struct rx_node *rx;
-	struct dm_pool *scratch = dm_pool_create("regex matcher", 10 * 1024);
 	struct dm_regex *m;
+	struct dm_pool *scratch = mem;
 
-	if (!scratch)
+	if (!(m = dm_pool_alloc(mem, sizeof(*m))))
 		return_NULL;
 
-	if (!(m = dm_pool_alloc(mem, sizeof(*m)))) {
-		dm_pool_destroy(scratch);
-		return_NULL;
-	}
-
 	memset(m, 0, sizeof(*m));
 
 	/* join the regexps together, delimiting with zero */
@@ -359,26 +363,31 @@
 	_create_bitsets(m);
 	_calc_functions(m);
 	_calc_states(m, rx);
-	dm_pool_destroy(scratch);
-	m->scratch = NULL;
-
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
+        struct dfa_state *ns;
+
+        if (!(ns = cs->lookup[(unsigned char) c]))
+                _calc_state(m, cs, c);
+
+	if (!(ns = cs->lookup[(unsigned char) c]))
 		return NULL;
 
-	if (cs->final && (cs->final > *r))
-		*r = cs->final;
+        // yuck, we have to special case the target trans
+        if (ns->final == -1)
+                _calc_state(m, ns, TARGET_TRANS);
 
-	return cs;
+	if (ns->final && (ns->final > *r))
+		*r = ns->final;
+
+	return ns;
 }
 
 int dm_regex_match(struct dm_regex *regex, const char *s)
@@ -386,14 +395,15 @@
 	struct dfa_state *cs = regex->start;
 	int r = 0;
 
-	if (!(cs = _step_matcher(HAT_CHAR, cs, &r)))
+        dm_bit_clear_all(regex->bs);
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
@@ -496,7 +506,7 @@
         struct dfa_state *node;
 
         while ((node = pop_node_(p))) {
-                result = combine_(result, node->final);
+                result = combine_(result, node->final < 0 ? 0 : node->final);
                 for (c = 0; c < 256; c++)
                         result = combine_(result,
                                           push_node_(p, node->lookup[c]));
@@ -511,6 +521,8 @@
         struct printer p;
         struct dm_pool *mem = dm_pool_create("regex fingerprint", 1024);
 
+        _force_states(regex);
+
         assert(mem);
         p.mem = mem;
         p.pending = NULL;


