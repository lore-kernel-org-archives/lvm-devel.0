From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:14:52 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20111011091452.5185.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:14:52

Modified files:
	.              : WHATS_NEW 

Log message:
	Update whats new

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2156&r2=1.2157

--- LVM2/WHATS_NEW	2011/10/11 09:09:00	1.2156
+++ LVM2/WHATS_NEW	2011/10/11 09:14:51	1.2157
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Reduce default preallocated stack size to 64KiB.
   Add check for access through NULL pointer when refresh_filter() fails.
   Use pthread condition for SINGLENODE lock implementation.
   Improve backtrace reporting for some dev_manager_ functions.


