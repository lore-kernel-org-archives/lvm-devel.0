From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2011 19:54:30 -0000
Subject: LVM2/libdm/mm pool-debug.c
Message-ID: <20110228195430.9287.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-28 19:54:30

Modified files:
	libdm/mm       : pool-debug.c 

Log message:
	Fix void pointer arithmetic warning in pool debug code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-debug.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/libdm/mm/pool-debug.c	2009/07/15 20:02:48	1.9
+++ LVM2/libdm/mm/pool-debug.c	2011/02/28 19:54:30	1.10
@@ -248,7 +248,7 @@
 	}
 	p->object = new;
 
-	memcpy(new->data + new_size - delta, extra, delta);
+	memcpy((char*)new->data + new_size - delta, extra, delta);
 
 	return 1;
 }


