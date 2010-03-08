From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Mar 2010 17:14:22 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100308171422.11487.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-08 17:14:22

Modified files:
	lib/mm         : memlock.c 

Log message:
	Use mlock() only on 'r' memory maps

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/lib/mm/memlock.c	2010/03/08 15:55:52	1.18
+++ LVM2/lib/mm/memlock.c	2010/03/08 17:14:21	1.19
@@ -136,7 +136,7 @@
 	}
 
 	/* skip  ---p,  select with r,w,x */
-	if (fr != 'r' && fw != 'w' && fx != 'x')
+	if (fr != 'r')
 		return 1;
 
 	/* always ignored areas */


