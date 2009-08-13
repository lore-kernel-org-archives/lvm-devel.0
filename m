From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Aug 2009 16:36:51 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090813163651.8520.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-08-13 16:36:49

Modified files:
	.              : WHATS_NEW 

Log message:
	update WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1239&r2=1.1240

--- LVM2/WHATS_NEW	2009/08/13 14:27:32	1.1239
+++ LVM2/WHATS_NEW	2009/08/13 16:36:49	1.1240
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Added configure --enable-clogd to conditionally build the cluster log daemon.
   Make lvchange --refresh only take a read lock on volume group.
   Fix bug where non-blocking file locks could be granted in error.
   Make lvm2app pv_t, lv_t, vg_t handle definitions consistent with lvm_t.


