From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 10:53:32 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c
Message-ID: <20120213105332.7637.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 10:53:32

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 

Log message:
	Release_vg instead of plain free in error path

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2281&r2=1.2282
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/WHATS_NEW	2012/02/13 10:51:52	1.2281
+++ LVM2/WHATS_NEW	2012/02/13 10:53:31	1.2282
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Release vg in error path of _format1_vg_read() instead of just free().
   Report allocation failure for allocation of PV structure.
   Add clvmd init dependency on dlm service when running with new corosync.
 
--- LVM2/lib/format1/format1.c	2012/02/12 23:01:19	1.143
+++ LVM2/lib/format1/format1.c	2012/02/13 10:53:32	1.144
@@ -227,7 +227,7 @@
 	return vg;
 
 bad:
-	free(vg);
+	release_vg(vg);
 
 	return NULL;
 }


