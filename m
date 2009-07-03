From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Jul 2009 11:04:06 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090703110406.23142.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-03 11:04:06

Modified files:
	.              : WHATS_NEW 

Log message:
	clarification

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1162&r2=1.1163

--- LVM2/WHATS_NEW	2009/07/01 17:23:10	1.1162
+++ LVM2/WHATS_NEW	2009/07/03 11:04:06	1.1163
@@ -28,7 +28,7 @@
   Use lvconvert --repair instead of vgreduce in mirror dmeventd DSO.
   Introduce lvconvert --use_policies (repair policy according to lvm.conf).
   Update clvmd-corosync to match new corosync API.
-  Fix makefile to build also shared libraries when running plain make.
+  Fix lib Makefile to include any shared libraries in default target.
   Fix rename of active snapshot with virtual origin.
   Fix convert polling to ignore LV with different UUID.
   Cache underlying device readahead only before activation calls.


