From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Jul 2007 13:10:15 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20070703131015.3215.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-03 13:10:15

Modified files:
	.              : WHATS_NEW 

Log message:
	Fix WHATS_NEW for last checkin until further patches for LVM library are ready.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.646&r2=1.647

--- LVM2/WHATS_NEW	2007/07/02 21:48:30	1.646
+++ LVM2/WHATS_NEW	2007/07/03 13:10:14	1.647
@@ -1,6 +1,6 @@
 Version 2.02.27 - 
 ================================
-  Convert _add_pv_to_vg to usable LVM library function.
+  Remove unused parameter 'fid' from _add_pv_to_vg.
   Add kernel and device-mapper targets versions report to lvmdump.
   Don't use index and rindex functions marked by SUSv3 as legacy.
   Fix vgsplit if splitting all PVs from VG.


