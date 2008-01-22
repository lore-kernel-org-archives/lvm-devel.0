From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Jan 2008 15:58:32 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20080122155832.17106.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-22 15:58:32

Modified files:
	.              : WHATS_NEW 

Log message:
	update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.775&r2=1.776

--- LVM2/WHATS_NEW	2008/01/21 14:07:43	1.775
+++ LVM2/WHATS_NEW	2008/01/22 15:58:31	1.776
@@ -1,5 +1,6 @@
 Version 2.02.32 -
 ===================================
+  Fix new parameter validation in vgsplit and test mode. (2.02.30)
   Remove redundant cnxman-socket.h file from clvmd directory.
   Fix pvs, vgs, lvs error exit status on some error paths.
 


