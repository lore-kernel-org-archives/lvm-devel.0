From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 10:31:35 -0000
Subject: LVM2/libdm/mm pool-fast.c
Message-ID: <20120301103135.23148.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 10:31:35

Modified files:
	libdm/mm       : pool-fast.c 

Log message:
	Add cast for ptrdiff_t - cleanup gcc warning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/libdm/mm/pool-fast.c	2011/10/23 15:38:03	1.17
+++ LVM2/libdm/mm/pool-fast.c	2012/03/01 10:31:35	1.18
@@ -258,7 +258,7 @@
 	struct chunk *c;
 
 	if (p->spare_chunk &&
-	    ((p->spare_chunk->end - p->spare_chunk->begin) >= s)) {
+	    ((p->spare_chunk->end - p->spare_chunk->begin) >= (ptrdiff_t)s)) {
 		/* reuse old chunk */
 		c = p->spare_chunk;
 		p->spare_chunk = 0;


