From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2010 23:09:22 -0000
Subject: LVM2/libdm/regex matcher.c parse_rx.c parse_rx.h
Message-ID: <20100422230922.27702.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-22 23:09:20

Modified files:
	libdm/regex    : matcher.c parse_rx.c parse_rx.h 

Log message:
	don't optimise anything with TARGET_TRANS to avoid intefering with the matcher's counting

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/libdm/regex/matcher.c	2010/04/22 20:35:24	1.5
+++ LVM2/libdm/regex/matcher.c	2010/04/22 23:09:18	1.6
@@ -37,8 +37,6 @@
 	struct dm_pool *scratch, *mem;
 };
 
-#define TARGET_TRANS '\0'
-
 static int _count_nodes(struct rx_node *rx)
 {
 	int r = 1;
--- LVM2/libdm/regex/parse_rx.c	2010/04/22 20:15:00	1.10
+++ LVM2/libdm/regex/parse_rx.c	2010/04/22 23:09:18	1.11
@@ -452,7 +452,12 @@
 		return _nodes_equal(l->left, r->left);
 
 	case CHARSET:
-		return dm_bitset_equal(l->charset, r->charset);
+		/*
+		 * Never change anything containing TARGET_TRANS
+		 * used by matcher as boundary marker between concatenated
+		 * expressions.
+		 */
+		return (!dm_bit(l->charset, TARGET_TRANS) && dm_bitset_equal(l->charset, r->charset));
 	}
 
 	/* NOTREACHED */
--- LVM2/libdm/regex/parse_rx.h	2007/08/21 16:26:07	1.2
+++ LVM2/libdm/regex/parse_rx.h	2010/04/22 23:09:18	1.3
@@ -33,6 +33,8 @@
 #define HAT_CHAR 0x2
 #define DOLLAR_CHAR 0x3
 
+#define TARGET_TRANS '\0'
+
 struct rx_node {
 	int type;
 	dm_bitset_t charset;


