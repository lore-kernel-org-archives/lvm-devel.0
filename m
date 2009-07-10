From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jul 2009 20:16:18 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090710201618.28062.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-10 20:16:16

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for vgremove and ORPAHN_LOCK refactoring

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1175&r2=1.1176

--- LVM2/WHATS_NEW	2009/07/09 22:50:45	1.1175
+++ LVM2/WHATS_NEW	2009/07/10 20:16:15	1.1176
@@ -1,5 +1,7 @@
 Version 2.02.49 - 
 ================================
+  Refactor vg_remove_single for use in liblvm.
+  Make all tools consistent with lock ordering - obtain VG_ORPHAN lock second.
   Check MD devices for a partition table during device scan.
   Add extended device (blkext) and MD partition (mdp) types to filters.
   Fix and precise metadata read errors for segment areas.


