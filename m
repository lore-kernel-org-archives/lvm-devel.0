From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2010 03:42:07 -0000
Subject: LVM2/old-tests/regex parse_t.c
Message-ID: <20100422034207.6916.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-22 03:42:02

Modified files:
	old-tests/regex: parse_t.c 

Log message:
	isprint

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/regex/parse_t.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/old-tests/regex/parse_t.c	2010/04/22 03:12:01	1.5
+++ LVM2/old-tests/regex/parse_t.c	2010/04/22 03:42:00	1.6
@@ -116,7 +116,7 @@
 			printf("[");
 		for (i = 0; i < 256; i++)
 			if (dm_bit(rx->charset, i)) {
-				if isprint(i)
+				if (isprint(i))
 					printf("%c", (char) i);
 				else if (i == HAT_CHAR)
 					printf("^");


