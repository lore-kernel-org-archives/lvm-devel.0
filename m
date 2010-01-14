From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Jan 2010 10:19:43 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100114101943.2519.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-14 10:19:43

Modified files:
	.              : WHATS_NEW 

Log message:
	Update entry for few previous gcc cleanup commits.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1385&r2=1.1386

--- LVM2/WHATS_NEW	2010/01/13 21:48:39	1.1385
+++ LVM2/WHATS_NEW	2010/01/14 10:19:43	1.1386
@@ -1,5 +1,6 @@
 Version 2.02.58 - 
 ===================================
+  Cleanup of some minor gcc warnings.
   Fix clvmd automatic target module loading crash.
   Fix allocation code not to stop at the first area of a PV that fits.
   Add --merge to lvconvert to merge a snapshot into its origin.


