From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2010 20:35:25 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/regex/matcher.c
Message-ID: <20100422203525.8828.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-22 20:35:24

Modified files:
	.              : WHATS_NEW_DM 
	libdm/regex    : matcher.c 

Log message:
	Cache bitset locations to speed up _calc_states. (kabi)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.361&r2=1.362
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW_DM	2010/04/20 22:31:36	1.361
+++ LVM2/WHATS_NEW_DM	2010/04/22 20:35:24	1.362
@@ -1,5 +1,6 @@
 Version 1.02.47 -
 =================================
+  Cache bitset locations to speed up _calc_states.
   Add a regex optimisation pass for shared character prefixes.
   Add dm_bit_and and dm_bitset_equal to libdevmapper.
   Simplify dm_bitset_create.
--- LVM2/libdm/regex/matcher.c	2010/03/25 18:22:04	1.4
+++ LVM2/libdm/regex/matcher.c	2010/04/22 20:35:24	1.5
@@ -212,6 +212,8 @@
 	/* prime the queue */
 	h = t = _create_state_queue(m->scratch, dfa, rx->firstpos);
 	while (h) {
+		int elems, j, idx[h->bits[0]];
+
 		/* pop state off front of the queue */
 		dfa = h->s;
 		dfa_bits = h->bits;
@@ -219,10 +221,17 @@
 
 		/* iterate through all the inputs for this state */
 		dm_bit_clear_all(bs);
+
+		/* Cache list of locations of bits */
+		elems = 0;
+		for (i = dm_bit_get_first(dfa_bits);
+		     i >= 0; i = dm_bit_get_next(dfa_bits, i))
+			idx[elems++] = i;
+
 		for (a = 0; a < 256; a++) {
 			/* iterate through all the states in firstpos */
-			for (i = dm_bit_get_first(dfa_bits);
-			     i >= 0; i = dm_bit_get_next(dfa_bits, i)) {
+			for (j = 0; j < elems; j++) {
+				i = idx[j];
 				if (dm_bit(m->nodes[i]->charset, a)) {
 					if (a == TARGET_TRANS)
 						dfa->final = m->nodes[i]->final;


