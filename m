From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:26:18 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20090902212618.12224.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:26:18

Modified files:
	tools          : vgsplit.c 

Log message:
	Refactor vgsplit - add 'lock_vg_from_first' flag.
	
	Introduce 'lock_vg_from_first' flag to retain which vg was locked first.
	Should be no functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/tools/vgsplit.c	2009/09/02 21:26:01	1.87
+++ LVM2/tools/vgsplit.c	2009/09/02 21:26:18	1.88
@@ -218,6 +218,7 @@
 	int existing_vg = 0;
 	int r = ECMD_FAILED;
 	const char *lv_name;
+	int lock_vg_from_first = 1;
 
 	if ((arg_count(cmd, name_ARG) + argc) < 3) {
 		log_error("Existing VG, new VG and either physical volumes "
@@ -427,7 +428,12 @@
 	r = ECMD_PROCESSED;
 
 bad:
-	unlock_and_release_vg(cmd, vg_to, vg_name_to);
-	unlock_and_release_vg(cmd, vg_from, vg_name_from);
+	if (lock_vg_from_first) {
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+	} else {
+		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+	}
 	return r;
 }


