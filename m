From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 30 Aug 2007 18:53:33 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20070830185333.30569.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2007-08-30 18:53:32

Modified files:
	.              : WHATS_NEW 

Log message:
	- I neglected to update this file on last check-in, which fixed
	the MIRROR_NOTSYNCED flag being passed on to a linear lv when
	converting from a mirror.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.698&r2=1.699

--- LVM2/WHATS_NEW	2007/08/28 16:14:48	1.698
+++ LVM2/WHATS_NEW	2007/08/30 18:53:32	1.699
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Clear MIRROR_NOTSYNCED lv flag when converting from mirror to linear.
   Modify lvremove to prompt for removal if LV active on other cluster nodes.
   Add '-f' to vgremove to force removal of VG even if LVs exist.
   


