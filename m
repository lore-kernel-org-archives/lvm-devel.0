From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 May 2009 13:47:03 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090509134703.15293.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-05-09 13:47:03

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW wrt a recent patch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1097&r2=1.1098

--- LVM2/WHATS_NEW	2009/05/07 12:11:50	1.1097
+++ LVM2/WHATS_NEW	2009/05/09 13:47:03	1.1098
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Reject missing PVs from allocation in toollib.
   Fix PV datalignment for values starting prior to MDA area. (2.02.45)
   Add sparse devices: lvcreate -s --virtualoriginsize (hidden zero origin).
   Add lvs origin_size field.


