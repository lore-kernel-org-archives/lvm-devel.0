From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Aug 2009 12:19:30 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090813121930.10054.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-08-13 12:19:30

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1236&r2=1.1237

--- LVM2/WHATS_NEW	2009/08/13 12:04:01	1.1236
+++ LVM2/WHATS_NEW	2009/08/13 12:19:30	1.1237
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Make lvm2app pv_t, lv_t, vg_t handle definitions consistent with lvm_t.
   Fix vgextend error path - if ORPHAN lock fails, unlock / release vg (2.02.49).
   Fix compile warning in clvmd.
   Update lv{convert|create|extend|resize} man pages - clarify use of PE ranges.


