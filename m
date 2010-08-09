From: thornber@sourceware.org <thornber@sourceware.org>
Date: 9 Aug 2010 10:29:43 -0000
Subject: LVM2/libdm/regex parse_rx.c
Message-ID: <20100809102943.18510.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-08-09 10:29:42

Modified files:
	libdm/regex    : parse_rx.c 

Log message:
	[REGEX] Parse regexes that contain chars with value > 0x80
	
	This is a long standing issue.  Fixed by casting a char value to
	unsigned char before using it as an index into a bitset.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/libdm/regex/parse_rx.c	2010/07/21 11:58:49	1.12
+++ LVM2/libdm/regex/parse_rx.c	2010/08/09 10:29:42	1.13
@@ -271,7 +271,7 @@
 		ps->type = 0;
 		ps->cursor = ptr + 1;
 		dm_bit_clear_all(ps->charset);
-		dm_bit_set(ps->charset, (int) *ptr);
+		dm_bit_set(ps->charset, (int) (unsigned char) *ptr);
 		break;
 	}
 


