From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 31 Mar 2010 07:43:44 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100331074344.8286.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-31 07:43:42

Modified files:
	.              : WHATS_NEW 

Log message:
	Update for make install.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1489&r2=1.1490

--- LVM2/WHATS_NEW	2010/03/30 14:44:57	1.1489
+++ LVM2/WHATS_NEW	2010/03/31 07:43:41	1.1490
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Fix 'make install' when $(builddir) is different from $(srcdir).
   Fix dso resource leak in error path of dmeventd.
   Use C locales and use_mlockall for dmeventd.
   Fix --alloc contiguous policy only to allocate one set of parallel areas.


