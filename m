From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 23:57:15 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20070613235715.26976.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 23:57:15

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for get_pv* conversions

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.630&r2=1.631

--- LVM2/WHATS_NEW	2007/06/13 19:52:48	1.630
+++ LVM2/WHATS_NEW	2007/06/13 23:57:15	1.631
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Convert a lot of code pv dereferences to use get_pv_* functions.
   Suppress a couple benign warnings by adding variable initializations.
   Convert find_pv_in_vg_by_uuid and pv_create to use PV handles.
   Add get_pv_* functions to return PV members (external LVM library).


