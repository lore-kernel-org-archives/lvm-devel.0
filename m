From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Jun 2010 10:21:00 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100623102100.7590.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-23 10:21:00

Modified files:
	.              : WHATS_NEW 

Log message:
	Better WHATS_NEW message - as we still have not fixed 'make exec_prefix' build

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1626&r2=1.1627

--- LVM2/WHATS_NEW	2010/06/22 21:10:53	1.1626
+++ LVM2/WHATS_NEW	2010/06/23 10:21:00	1.1627
@@ -16,7 +16,7 @@
   Allow use of lvm2app and lvm2cmd headers in C++ code.
   Remove some unused #includes from clvmd files.
   Use #include "" for libdevmapper.h and configure.h throughout tree.
-  Fix 'make exec_prefix' with LVM_PATH / DMEVENTD_PATH. (2.02.67)
+  Fix LVM_PATH expansion when exec_prefix=NONE (2.02.67).
   Fix segfault in clvmd -R if no response from daemon received.
 
 Version 2.02.67 - 4th June 2010


