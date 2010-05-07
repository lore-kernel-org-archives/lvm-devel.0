From: agk@sourceware.org <agk@sourceware.org>
Date: 7 May 2010 15:24:19 -0000
Subject: LVM2 ./WHATS_NEW tools/pvscan.c
Message-ID: <20100507152419.4673.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-07 15:24:18

Modified files:
	.              : WHATS_NEW 
	tools          : pvscan.c 

Log message:
	Fix truncated total size displayed by pvscan.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1549&r2=1.1550
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/WHATS_NEW	2010/05/06 11:15:55	1.1549
+++ LVM2/WHATS_NEW	2010/05/07 15:24:17	1.1550
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Fix truncated total size displayed by pvscan.
   Add new --sysinit option for vgchange and lvchange.
   Suppress duplicate error messages about read failures and missing devices.
   Install plugins to $(libdir)/device-mapper and $(libdir)/lvm2.
--- LVM2/tools/pvscan.c	2010/04/01 10:34:11	1.50
+++ LVM2/tools/pvscan.c	2010/05/07 15:24:18	1.51
@@ -166,7 +166,7 @@
 			size_new += pv_size(pv);
 			size_total += pv_size(pv);
 		} else
-			size_total += pv_pe_count(pv) * pv_pe_size(pv);
+			size_total += (uint64_t) pv_pe_count(pv) * pv_pe_size(pv);
 	}
 
 	/* find maximum pv name length */


