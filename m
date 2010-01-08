From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 8 Jan 2010 22:28:55 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100108222855.26807.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-08 22:28:55

Modified files:
	.              : WHATS_NEW 

Log message:
	udpate WHATS_NEW file for --splitmirror checkin

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1375&r2=1.1376

--- LVM2/WHATS_NEW	2010/01/08 21:53:07	1.1375
+++ LVM2/WHATS_NEW	2010/01/08 22:28:54	1.1376
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Add capability to split off and keep mirror legs to lvconvert.
   Change background polldaemon's process name to "(lvm2)".
   Allow vgremove of a VG with PVs missing.
   Keep log type consistent when changing mirror image count.


