From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:27:06 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20090902212706.12632.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:27:06

Modified files:
	tools          : vgsplit.c 

Log message:
	Refactor vgsplit: _vgsplit_from or _vgsplit_to failure cleanup depends on order.
	
	Should be no functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/tools/vgsplit.c	2009/09/02 21:26:50	1.90
+++ LVM2/tools/vgsplit.c	2009/09/02 21:27:05	1.91
@@ -315,8 +315,11 @@
 	}
 
 	vg_from = _vgsplit_from(cmd, vg_name_from);
-	if (!vg_from)
+	if (!vg_from) {
+		if (!lock_vg_from_first)
+			unlock_and_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
+	}
 
 	/*
 	 * Set metadata format of original VG.
@@ -327,7 +330,8 @@
 
 	vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
 	if (!vg_to) {
-		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+		if (lock_vg_from_first)
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;
 	}
 	if (existing_vg) {


