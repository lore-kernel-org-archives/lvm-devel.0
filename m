From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 14 Sep 2011 14:20:17 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20110914142017.8439.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-09-14 14:20:17

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Activate virtual snapshot origin exclusively (only on local node in cluster).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2108&r2=1.2109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.284&r2=1.285

--- LVM2/WHATS_NEW	2011/09/14 09:57:35	1.2108
+++ LVM2/WHATS_NEW	2011/09/14 14:20:16	1.2109
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Activate virtual snapshot origin exclusively (only on local node in cluster).
   Fix lv_mirror_count to handle mirrored stripes properly.
   Fix failure to down-convert a mirror to linear due to udev "dev open" conflict
   Fix mirrored log creation when PE size is small - force log_size >= region_size
--- LVM2/lib/metadata/lv_manip.c	2011/09/13 18:42:58	1.284
+++ LVM2/lib/metadata/lv_manip.c	2011/09/14 14:20:16	1.285
@@ -4154,7 +4154,7 @@
 		    (!(org = _create_virtual_origin(cmd, vg, lv->name,
 						    lp->permission,
 						    lp->voriginextents)) ||
-		     !activate_lv(cmd, org))) {
+		     !activate_lv_excl(cmd, org))) {
 			log_error("Couldn't create virtual origin for LV %s",
 				  lv->name);
 			if (org && !lv_remove(org))


