From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2010 20:15:01 -0000
Subject: LVM2/libdm/regex parse_rx.c
Message-ID: <20100422201501.29657.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-22 20:15:01

Modified files:
	libdm/regex    : parse_rx.c 

Log message:
	avoid ORs rightmost

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/libdm/regex/parse_rx.c	2010/04/22 17:42:38	1.9
+++ LVM2/libdm/regex/parse_rx.c	2010/04/22 20:15:00	1.10
@@ -421,16 +421,10 @@
 static unsigned _depth(struct rx_node *r, unsigned leftmost)
 {
 	int count = 1;
-	int or_count = 0;
 
-	while (r->type != CHARSET && LEFT(r)) {
+	while (r->type != CHARSET && LEFT(r) && (leftmost || r->type != OR)) {
 		count++;
 		r = LEFT(r);
-		/* Stop if we pass another OR */
-		if (or_count)
-			break;
-		if (r->type == OR)
-			or_count++;
 	}
 
 	return count;


