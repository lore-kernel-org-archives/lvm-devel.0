From: thornber@sourceware.org <thornber@sourceware.org>
Date: 20 Jul 2010 15:32:08 -0000
Subject: LVM2 libdm/libdevmapper.h libdm/regex/matcher. ...
Message-ID: <20100720153208.24438.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-20 15:32:07

Modified files:
	libdm          : libdevmapper.h 
	libdm/regex    : matcher.c 
	unit-tests/regex: matcher_t.c matcher_t.expected 

Log message:
	[REGEX] add a fingerprinting facility to allow test code to compare dfas

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/matcher_t.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/matcher_t.expected.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/libdm/libdevmapper.h	2010/07/13 13:51:03	1.121
+++ LVM2/libdm/libdevmapper.h	2010/07/20 15:32:07	1.122
@@ -1007,6 +1007,14 @@
  */
 int dm_regex_match(struct dm_regex *regex, const char *s);
 
+/*
+ * This is useful for regression testing only.  The idea is if two
+ * fingerprints are different, then the two dfas are certainly not
+ * isomorphic.  If two fingerprints _are_ the same then it's very likely
+ * that the dfas are isomorphic.
+ */
+uint32_t dm_regex_fingerprint(struct dm_regex *regex);
+
 /*********************
  * reporting functions
  *********************/
--- LVM2/libdm/regex/matcher.c	2010/04/22 23:09:18	1.6
+++ LVM2/libdm/regex/matcher.c	2010/07/20 15:32:07	1.7
@@ -363,3 +363,126 @@
 	/* subtract 1 to get back to zero index */
 	return r - 1;
 }
+
+/*
+ * The next block of code concerns calculating a fingerprint for the dfa.
+ *
+ * We're not calculating a minimal dfa in _calculate_state (maybe a future
+ * improvement).  As such it's possible that two non-isomorphic dfas
+ * recognise the same language.  This can only really happen if you start
+ * with equivalent, but different regexes (for example the simplifier in
+ * parse_rx.c may have changed).
+ *
+ * The code is inefficient; repeatedly searching a singly linked list for
+ * previously seen nodes.  Not worried since this is test code.
+ */
+struct node_list {
+        unsigned node_id;
+        struct dfa_state *node;
+        struct node_list *next;
+};
+
+struct printer {
+        struct dm_pool *mem;
+        struct node_list *pending;
+        struct node_list *processed;
+        unsigned next_index;
+};
+
+static uint32_t randomise_(uint32_t n)
+{
+        /* 2^32 - 5 */
+        uint32_t const prime = (~0) - 4;
+        return n * prime;
+}
+
+static int seen_(struct node_list *n, struct dfa_state *node, uint32_t *i)
+{
+        while (n) {
+                if (n->node == node) {
+                        *i = n->node_id;
+                        return 1;
+                }
+                n = n->next;
+        }
+
+        return 0;
+}
+
+/*
+ * Push node if it's not been seen before, returning a unique index.
+ */
+static uint32_t push_node_(struct printer *p, struct dfa_state *node)
+{
+        uint32_t i;
+        if (seen_(p->pending, node, &i) ||
+            seen_(p->processed, node, &i))
+                return i;
+        else {
+                struct node_list *n = dm_pool_alloc(p->mem, sizeof(*n));
+                assert(n);
+                n->node_id = p->next_index++;
+                n->node = node;
+                n->next = p->pending;
+                p->pending = n;
+                return n->node_id;
+        }
+}
+
+/*
+ * Pop the front node, and fill out it's previously assigned index.
+ */
+static struct dfa_state *pop_node_(struct printer *p)
+{
+        struct dfa_state *node = NULL;
+
+        if (p->pending) {
+                struct node_list *n = p->pending;
+                p->pending = n->next;
+                n->next = p->processed;
+                p->processed = n;
+
+                node = n->node;
+        }
+
+        return node;
+}
+
+static uint32_t combine_(uint32_t n1, uint32_t n2)
+{
+        return ((n1 << 8) | (n1 >> 24)) ^ randomise_(n2);
+}
+
+static uint32_t fingerprint_(struct printer *p)
+{
+        int c;
+        uint32_t result = 0;
+        struct dfa_state *node;
+
+        while ((node = pop_node_(p))) {
+                result = combine_(result, node->final);
+                for (c = 0; c < 256; c++)
+                        result = combine_(result,
+                                          push_node_(p, node->lookup[c]));
+        }
+
+        return result;
+}
+
+uint32_t dm_regex_fingerprint(struct dm_regex *regex)
+{
+        uint32_t result;
+        struct printer p;
+        struct dm_pool *mem = dm_pool_create("regex fingerprint", 1024);
+
+        assert(mem);
+        p.mem = mem;
+        p.pending = NULL;
+        p.processed = NULL;
+        p.next_index = 0;
+
+        push_node_(&p, regex->start);
+        result = fingerprint_(&p);
+        dm_pool_destroy(mem);
+        return result;
+}
--- LVM2/unit-tests/regex/matcher_t.c	2010/07/20 15:18:57	1.1
+++ LVM2/unit-tests/regex/matcher_t.c	2010/07/20 15:32:07	1.2
@@ -135,6 +135,7 @@
 		goto err;
 	}
 
+        printf("fingerprint: %x\n", dm_regex_fingerprint(scanner));
 	_scan_input(scanner, regex);
 	_free_regex(regex, nregex);
 
--- LVM2/unit-tests/regex/matcher_t.expected	2010/07/20 15:21:33	1.1
+++ LVM2/unit-tests/regex/matcher_t.expected	2010/07/20 15:32:07	1.2
@@ -1,4 +1,5 @@
 Matcher built with 23 dfa states
+fingerprint: 352b6c4f
 /dev/loop/0 : loop/[0-9]+
 /dev/loop/1 : loop/[0-9]+
 /dev/loop/2 : loop/[0-9]+


