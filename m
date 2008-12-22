From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Dec 2008 09:04:35 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20081222090435.3786.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2008-12-22 09:04:35

Modified files:
	.              : WHATS_NEW 

Log message:
	Add "--refresh" functionality to vgchange and vgmknodes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1014&r2=1.1015

--- LVM2/WHATS_NEW	2008/12/19 15:26:01	1.1014
+++ LVM2/WHATS_NEW	2008/12/22 09:04:35	1.1015
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Add "--refresh" functionality to vgchange and vgmknodes.
   Check for maximal LV size when wiping device.
   Calculate mirror log size instead of using 1 extent.
   Check if requested major/minor pair is already used.


