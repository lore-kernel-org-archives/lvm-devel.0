From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 18:22:39 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100325182239.18877.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 18:22:39

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1480&r2=1.1481

--- LVM2/WHATS_NEW	2010/03/25 18:16:54	1.1480
+++ LVM2/WHATS_NEW	2010/03/25 18:22:39	1.1481
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Use INTERNAL_ERROR for internal errors throughout tree.
   Add some assertions to allocation code.
   Introduce pv_area_used into allocation algorithm and add debug messages.
   Add activation/monitoring to lvm.conf.


