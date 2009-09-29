From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Sep 2009 20:33:50 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20090929203350.21775.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-29 20:33:49

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	look up pvmove by pvmove LV when PVMOVE flag is set

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1281&r2=1.1282
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.171&r2=1.172

--- LVM2/WHATS_NEW	2009/09/29 20:22:35	1.1281
+++ LVM2/WHATS_NEW	2009/09/29 20:33:49	1.1282
@@ -1,6 +1,5 @@
 Version 2.02.54 -
 =====================================
-  Don't attempt to restart pvmoves when deactivating LVs in vgchange.
   Restart lvconverts in vgchange by sharing lv_spawn_background_polling.
   Generalise polldaemon code by changing mirror-specific variable names.
   Don't attempt to deactivate an LV if any of its snapshots are in use.
--- LVM2/tools/toollib.c	2009/09/29 20:22:35	1.171
+++ LVM2/tools/toollib.c	2009/09/29 20:33:49	1.172
@@ -1253,7 +1253,12 @@
 {
 	const char *pvname;
 
-	if ((lv->status & LOCKED) &&
+	if ((lv->status & PVMOVE) &&
+	    (pvname = get_pvmove_pvname_from_lv_mirr(lv))) {
+		log_verbose("Spawning background pvmove process for %s",
+			    pvname);
+		pvmove_poll(cmd, pvname, 1);
+	} else if ((lv->status & LOCKED) &&
 	    (pvname = get_pvmove_pvname_from_lv(lv))) {
 		log_verbose("Spawning background pvmove process for %s",
 			    pvname);


