From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 06:48:49 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20080919064849.17870.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 06:48:49

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.180&r2=1.181
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.961&r2=1.962

--- LVM2/VERSION	2008/06/27 22:35:22	1.180
+++ LVM2/VERSION	2008/09/19 06:48:48	1.181
@@ -1 +1 @@
-2.02.40-cvs (2008-06-27)
+2.02.40-cvs (2008-09-18)
--- LVM2/WHATS_NEW	2008/09/19 06:44:54	1.961
+++ LVM2/WHATS_NEW	2008/09/19 06:48:48	1.962
@@ -1,5 +1,5 @@
-Version 2.02.40 - 
-================================
+Version 2.02.40 - 19th September 2008
+=====================================
   Allow lvremove to remove LVs from VGs with missing PVs.
   In VG with PVs missing, by default allow activation of LVs that are complete.
   Track PARTIAL_LV and MISSING_PV flags internally.


