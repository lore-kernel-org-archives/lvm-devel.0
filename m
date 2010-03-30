From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2010 14:44:59 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100330144459.20804.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-30 14:44:58

Modified files:
	.              : WHATS_NEW 

Log message:
	Update for dmeventd changes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1488&r2=1.1489

--- LVM2/WHATS_NEW	2010/03/29 17:59:46	1.1488
+++ LVM2/WHATS_NEW	2010/03/30 14:44:57	1.1489
@@ -1,5 +1,7 @@
 Version 2.02.63 -  
 ================================
+  Fix dso resource leak in error path of dmeventd.
+  Use C locales and use_mlockall for dmeventd.
   Fix --alloc contiguous policy only to allocate one set of parallel areas.
   Do not allow {vg|lv}change --ignoremonitoring if on clustered VG.
   Improved dependency tracking for dmeventd and liblvm2cmd sources.


