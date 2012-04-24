From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 24 Apr 2012 20:00:04 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120424200004.12424.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-24 20:00:03

Modified files:
	.              : WHATS_NEW 

Log message:
	Prevent resume from creating error devices that already exist from suspend.
	
	Thanks to agk for providing the patch that prevents resume from attempting
	(and then failing) to create error devices which already exist; having been
	created by a corresponding suspend operation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2389&r2=1.2390

--- LVM2/WHATS_NEW	2012/04/24 12:16:40	1.2389
+++ LVM2/WHATS_NEW	2012/04/24 20:00:03	1.2390
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Prevent resume from creating error devices that already exist from suspend.
   Improve clmvd singlenode locking for better testing.
   Update and correct lvs man page with supported column names.
   Handle replacement of an active device that goes missing with an error device.


