From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 23 Jun 2010 21:01:44 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100623210144.18614.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-06-23 21:01:43

Modified files:
	.              : WHATS_NEW 

Log message:
	update WHATS_NEW file with entry for simultaneous mirror image and
	mirrored log image fault-handling fix.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1633&r2=1.1634

--- LVM2/WHATS_NEW	2010/06/23 19:35:11	1.1633
+++ LVM2/WHATS_NEW	2010/06/23 21:01:42	1.1634
@@ -1,5 +1,6 @@
 Version 2.02.69 - 
 ================================
+  Fix handling of simultaneous mirror image and mirrored log image failure.
 
 Version 2.02.68 - 23rd June 2010
 ================================


