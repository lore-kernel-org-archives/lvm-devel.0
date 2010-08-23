From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Aug 2010 11:34:11 -0000
Subject: LVM2 ./WHATS_NEW tools/polldaemon.c tools/pvmove.c
Message-ID: <20100823113411.4981.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-23 11:34:10

Modified files:
	.              : WHATS_NEW 
	tools          : polldaemon.c pvmove.c 

Log message:
	Fix pvmove --abort to work even for empty pvmove LV
	
	If pvmove crashed and metadata contains pvmove LV
	but without miorrored segments, pvmove --abort
	will not repair the situation (and finish wth success!).
	
	Fix it by allowing metadata update if aborting
	(thus removing pvmove LV) even if no moved LVs detected.
	
	(Tested on real metadata provided by an lvm user:-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1720&r2=1.1721
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/WHATS_NEW	2010/08/21 00:18:05	1.1720
+++ LVM2/WHATS_NEW	2010/08/23 11:34:10	1.1721
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Fix pvmove --abort to remove even for empty pvmove LV.
   Add configure --with-default-data-alignment.
   Update heuristic used for default and detected data alignment.
   Add "devices/default_data_alignment" to lvm.conf.
--- LVM2/tools/polldaemon.c	2010/07/09 15:34:48	1.34
+++ LVM2/tools/polldaemon.c	2010/08/23 11:34:10	1.35
@@ -234,8 +234,10 @@
 		lv = lvl->lv;
 		if (!(lv->status & parms->lv_type))
 			continue;
-		if (!(name = parms->poll_fns->get_copy_name_from_lv(lv)))
+		name = parms->poll_fns->get_copy_name_from_lv(lv);
+		if (!name && !parms->aborting)
 			continue;
+
 		/* FIXME Need to do the activation from _set_up_pvmove here
 		 *       if it's not running and we're not aborting */
 		if (_check_lv_status(cmd, vg, lv, name, parms, &finished) &&
--- LVM2/tools/pvmove.c	2010/07/09 15:34:48	1.78
+++ LVM2/tools/pvmove.c	2010/08/23 11:34:10	1.79
@@ -520,7 +520,8 @@
 {
 	int r = 1;
 
-	if (!_detach_pvmove_mirror(cmd, lv_mirr)) {
+	if (!dm_list_empty(lvs_changed) &&
+	    !_detach_pvmove_mirror(cmd, lv_mirr)) {
 		log_error("ABORTING: Removal of temporary mirror failed");
 		return 0;
 	}


