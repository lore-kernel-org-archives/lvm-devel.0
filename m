From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 30 Mar 2012 11:39:53 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120330113953.16300.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-30 11:39:52

Modified files:
	.              : WHATS_NEW 

Log message:
	WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2373&r2=1.2374

--- LVM2/WHATS_NEW	2012/03/30 08:58:02	1.2373
+++ LVM2/WHATS_NEW	2012/03/30 11:39:52	1.2374
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Exit immediately if LISTEN_PID env var incorrect during systemd handover.
   Detect VG name being part of the LV name in lvconvert --splitmirrors -n.
   Fix exclusive lvchange running from other node. (2.02.89)
   Add 'vgscan --cache' functionality for consistency with 'pvscan --cache'.


