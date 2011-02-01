From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Feb 2011 21:41:31 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110201214131.31240.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2011-02-01 21:41:31

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for lvmdump change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1896&r2=1.1897

--- LVM2/WHATS_NEW	2011/01/31 19:52:40	1.1896
+++ LVM2/WHATS_NEW	2011/02/01 21:41:31	1.1897
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Add "dmsetup ls --tree" output to lvmdump.
   Fix udev synchronization with no-locking --sysinit (2.02.80).
   Updating man pages for pvcreate, pvremove, pvresize, pvscan.
   Avoid rebuilding of uuid validation table.


