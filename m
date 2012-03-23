From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Mar 2012 16:28:41 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20120323162841.825.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-23 16:28:41

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix pvmove if LV is activated exclusively but cmirror is not running.
	
	In this case we should allow to use local mirror, check for cmirror
	should apply only for lvconvert/lvcreate.
	
	Introduced in 2.02.86 by removing !(lv->status & ACTIVATE_EXCL).
	
	(Partially workaround, it is minimalistic patch for now.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2366&r2=1.2367
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.179&r2=1.180

--- LVM2/WHATS_NEW	2012/03/23 10:33:26	1.2366
+++ LVM2/WHATS_NEW	2012/03/23 16:28:40	1.2367
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix pvmove for exclusively activated LV pvmove in clustered VG. (2.02.86)
   Always free hash table on update_pvid_to_vgid() in lvmetad.
   Update and fix monitoring of thin pool devices.
   Check hash insert success in lock_vg clvmd.
--- LVM2/lib/metadata/mirror.c	2012/02/23 22:24:47	1.179
+++ LVM2/lib/metadata/mirror.c	2012/03/23 16:28:40	1.180
@@ -2070,7 +2070,10 @@
 
 	if (vg_is_clustered(lv->vg)) {
 		/* FIXME: review check of lv_is_active_remotely */
-		if (!_cluster_mirror_is_available(lv)) {
+		/* FIXME: move this test out of this function */
+		/* Skip test for pvmove mirrors, it can use local mirror */
+		if (!(lv->status & (PVMOVE | LOCKED)) &&
+		    !_cluster_mirror_is_available(lv)) {
 			log_error("Shared cluster mirrors are not available.");
 			return 0;
 		}


