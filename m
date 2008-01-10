From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2008 22:21:44 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20080110222144.20476.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-10 22:21:44

Modified files:
	.              : WHATS_NEW 

Log message:
	convert_lv

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.756&r2=1.757

--- LVM2/WHATS_NEW	2008/01/10 19:25:07	1.756
+++ LVM2/WHATS_NEW	2008/01/10 22:21:44	1.757
@@ -1,6 +1,6 @@
 Version 2.02.30 -
 ===================================
-  Add new lv_convert field to lvs output.
+  Add new convert_lv field to lvs output.
   Print warning when lvm tools are running as non-root.
   Add snapshot dmeventd library (enables dmeventd snapshot monitoring).
   Prevent pvcreate from overwriting MDA-less PVs belonging to active VGs.


