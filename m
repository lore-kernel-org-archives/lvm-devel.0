From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 18 Mar 2010 17:32:26 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100318173226.27459.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-03-18 17:32:25

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for last checkin.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1469&r2=1.1470

--- LVM2/WHATS_NEW	2010/03/18 13:24:35	1.1469
+++ LVM2/WHATS_NEW	2010/03/18 17:32:25	1.1470
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Avoid scanning all pvs in the system if operating on a device with mdas.
   Add configure --with-clvmd=singlenode to use clvmd w/o cluster infrastructure.
   Get stacktrace if testsuite test drops core and lvm was built with debugging.
   Disable long living process flag in lvm2app.


