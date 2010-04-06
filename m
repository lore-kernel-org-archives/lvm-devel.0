From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Apr 2010 14:07:11 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100406140711.447.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-06 14:07:11

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1501&r2=1.1502

--- LVM2/WHATS_NEW	2010/04/06 11:53:53	1.1501
+++ LVM2/WHATS_NEW	2010/04/06 14:07:11	1.1502
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Refactor management of vg->pvs list.
   Fix lcov rules and generate better coverage report.
   Improve vg_validate to detect some loops in lists.
   Change most remaining log_error WARNING messages to log_warn.


