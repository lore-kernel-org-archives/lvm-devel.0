From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2008 12:37:49 -0000
Subject: LVM2 ./WHATS_NEW man/lvmdiskscan.8
Message-ID: <20080325123749.12222.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-03-25 12:37:48

Modified files:
	.              : WHATS_NEW 
	man            : lvmdiskscan.8 

Log message:
	Correct command name in lvmdiskscan man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.805&r2=1.806
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdiskscan.8.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2008/03/25 10:41:59	1.805
+++ LVM2/WHATS_NEW	2008/03/25 12:37:47	1.806
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Correct command name in lvmdiskscan man page.
   clvmd no longer crashes if it sees nodeids over 50.
   Fix potential deadlock in clvmd thread handling.
   Refactor text format initialisation into _init_text_import.
--- LVM2/man/lvmdiskscan.8	2003/11/14 16:17:55	1.1
+++ LVM2/man/lvmdiskscan.8	2008/03/25 12:37:48	1.2
@@ -7,7 +7,7 @@
 [\-l/\-\-lvmpartition]
 [\-v/\-\-verbose]
 .SH DESCRIPTION
-vgscan scans all SCSI, (E)IDE disks, multiple devices and a bunch
+\fBlvmdiskscan\fP scans all SCSI, (E)IDE disks, multiple devices and a bunch
 of other block devices in the system looking for LVM physical volumes.
 The size reported is the real device size.
 Define a filter in \fBlvm.conf\fP(5) to restrict 


