From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 12 Apr 2012 03:16:38 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c
Message-ID: <20120412031638.7573.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-12 03:16:37

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 

Log message:
	Fix code that performs RAID device replacement while under snapshot.
	
	The code should have been calling [suspend|resume]_lv_origin() rather than
	[suspend|resume]_lv.
	
	This addresses bug 807069.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2383&r2=1.2384
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2012/04/11 14:20:19	1.2383
+++ LVM2/WHATS_NEW	2012/04/12 03:16:37	1.2384
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix RAID device replacement code so that it works under snapshot.
   Fix inability to split RAID1 image while specifying a particular PV.
   Update man pages to give them same look&feel.
   Fix lvresize of thin pool for stipped devices.
--- LVM2/lib/metadata/raid_manip.c	2012/04/11 14:20:20	1.27
+++ LVM2/lib/metadata/raid_manip.c	2012/04/12 03:16:37	1.28
@@ -1713,7 +1713,7 @@
 		return 0;
 	}
 
-	if (!suspend_lv(lv->vg->cmd, lv)) {
+	if (!suspend_lv_origin(lv->vg->cmd, lv)) {
 		log_error("Failed to suspend %s/%s before committing changes",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -1725,7 +1725,7 @@
 		return 0;
 	}
 
-	if (!resume_lv(lv->vg->cmd, lv)) {
+	if (!resume_lv_origin(lv->vg->cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -1761,7 +1761,7 @@
 		return 0;
 	}
 
-	if (!suspend_lv(lv->vg->cmd, lv)) {
+	if (!suspend_lv_origin(lv->vg->cmd, lv)) {
 		log_error("Failed to suspend %s/%s before committing changes",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -1773,7 +1773,7 @@
 		return 0;
 	}
 
-	if (!resume_lv(lv->vg->cmd, lv)) {
+	if (!resume_lv_origin(lv->vg->cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);
 		return 0;


