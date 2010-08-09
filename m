From: thornber@sourceware.org <thornber@sourceware.org>
Date: 9 Aug 2010 10:58:27 -0000
Subject: LVM2/libdm/regex ttree.c
Message-ID: <20100809105827.28676.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-08-09 10:58:27

Modified files:
	libdm/regex    : ttree.c 

Log message:
	[REGEX] fix a long standing off-by-one error (found by valgrind-pool)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/ttree.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/libdm/regex/ttree.c	2008/11/03 18:59:59	1.3
+++ LVM2/libdm/regex/ttree.c	2010/08/09 10:58:27	1.4
@@ -91,10 +91,10 @@
 				return 0;
 			}
 
-			k = *key++;
-
-			if (count)
+			if (count) {
+				k = *key++;
 				c = &((*c)->m);
+			}
 		}
 	}
 	(*c)->data = data;


