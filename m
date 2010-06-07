From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jun 2010 14:39:18 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100607143918.18450.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-07 14:39:18

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW  for last commit

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1610&r2=1.1611

--- LVM2/WHATS_NEW	2010/06/07 13:52:52	1.1610
+++ LVM2/WHATS_NEW	2010/06/07 14:39:18	1.1611
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Fix wrong lvm path creation from configure introduced in previous release.
   Fix segfault in clvmd -R if no response from daemon received.
 
 Version 2.02.67 - 4th June 2010


