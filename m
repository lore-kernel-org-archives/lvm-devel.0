From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 4 Aug 2009 15:55:45 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090804155545.31718.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-04 15:55:44

Modified files:
	.              : WHATS_NEW 

Log message:
	Add --noudevsync option for relevant LVM tools.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1230&r2=1.1231

--- LVM2/WHATS_NEW	2009/08/04 15:36:13	1.1230
+++ LVM2/WHATS_NEW	2009/08/04 15:55:43	1.1231
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Add --noudevsync option for relevant LVM tools.
   Add activation/udev_sync to lvm.conf.
   Only change LV symlinks on ACTIVATE not PRELOAD.
   Make lvconvert honour log mirror options combined with downconversion.


