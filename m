From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jan 2009 22:48:22 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090109224822.3882.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-01-09 22:48:22

Modified files:
	.              : WHATS_NEW 

Log message:
	Add pv_mda_size to pvs and vg_mda_size to vgs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1016&r2=1.1017

--- LVM2/WHATS_NEW	2009/01/06 18:02:57	1.1016
+++ LVM2/WHATS_NEW	2009/01/09 22:48:22	1.1017
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Add pv_mda_size to pvs and vg_mda_size to vgs.
   Fix lvmdump /sys listing to include virtual devices directory.
   Add "--refresh" functionality to vgchange and vgmknodes.
   Check for maximal LV size when wiping device.


