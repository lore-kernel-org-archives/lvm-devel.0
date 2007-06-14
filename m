From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jun 2007 15:51:36 -0000
Subject: LVM2/tools pvremove.c
Message-ID: <20070614155136.8357.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-14 15:51:36

Modified files:
	tools          : pvremove.c 

Log message:
	Fix inverted logic on last checkin for pvremove

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/tools/pvremove.c	2007/06/14 15:48:04	1.15
+++ LVM2/tools/pvremove.c	2007/06/14 15:51:36	1.16
@@ -43,7 +43,7 @@
 	}
 
 	/* orphan ? */
-	if (!is_orphan(pv))
+	if (is_orphan(pv))
 		return 1;
 
 	/* Allow partial & exported VGs to be destroyed. */


