From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2010 14:33:16 -0000
Subject: LVM2/libdm/regex parse_rx.c
Message-ID: <20100422143316.3377.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-22 14:33:16

Modified files:
	libdm/regex    : parse_rx.c 

Log message:
	Don't walk rightmost through NULL pointers.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/libdm/regex/parse_rx.c	2010/04/22 13:42:34	1.7
+++ LVM2/libdm/regex/parse_rx.c	2010/04/22 14:33:14	1.8
@@ -16,8 +16,6 @@
 #include "dmlib.h"
 #include "parse_rx.h"
 
-#include <ctype.h>
-
 struct parse_sp {		/* scratch pad for the parsing process */
 	struct dm_pool *mem;
 	int type;		/* token type, 0 indicates a charset */
@@ -345,7 +343,7 @@
 {
 	int count = 1;
 
-	while (r->type != CHARSET) {
+	while (r->type != CHARSET && LEFT(r)) {
 		count++;
 		r = LEFT(r);
 	}


