From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Aug 2011 13:03:35 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110812130335.14365.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-12 13:03:35

Modified files:
	.              : WHATS_NEW 

Log message:
	makefile fixes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2072&r2=1.2073

--- LVM2/WHATS_NEW	2011/08/12 02:34:08	1.2072
+++ LVM2/WHATS_NEW	2011/08/12 13:03:35	1.2073
@@ -1,8 +1,10 @@
 Version 2.02.88 - 
 ==================================
+  Fix make clean not to remove Makefile.  (2.02.87)
 
 Version 2.02.87 - 12th August 2011
 ==================================
+  Fix make distclean to remove stray dmeventd and exported symbols files.
   Add global/detect_internal_vg_cache_corruption to lvm.conf.
   Use memory pool locking to check for corruption of internal VG structs.
   Cache and share generated VG structs.


