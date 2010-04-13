From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Apr 2010 18:18:55 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100413181855.23136.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-13 18:18:54

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1513&r2=1.1514

--- LVM2/WHATS_NEW	2010/04/13 14:36:24	1.1513
+++ LVM2/WHATS_NEW	2010/04/13 18:18:54	1.1514
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Refactor code related to vg->pvs list and add pv->vg link.
   Mask LCK_HOLD flag in cluster VG locks for compatibility reasons.
   Add activation/polling_interval to lvm.conf as --interval default.
   Don't ignore error if resuming any LV fails in resume_lvs.


