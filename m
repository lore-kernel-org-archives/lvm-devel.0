From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2009 18:15:51 -0000
Subject: LVM2/tools pvchange.c pvmove.c
Message-ID: <20090708181551.30409.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-08 18:15:51

Modified files:
	tools          : pvchange.c pvmove.c 

Log message:
	Refactor a couple log_error() statements in prep for larger log_error() patch.
	
	Part of twoerner's log_error() patches.
	
	Signed-off-by: Thomas Woerner <twoerner@redhat.com>
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/tools/pvchange.c	2009/07/07 01:18:35	1.71
+++ LVM2/tools/pvchange.c	2009/07/08 18:15:51	1.72
@@ -64,9 +64,8 @@
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			log_error
-			    ("Unable to find \"%s\" in volume group \"%s\"",
-			     pv_name, vg->name);
+			log_error("Unable to find \"%s\" in volume group \"%s\"",
+				  pv_name, vg->name);
 			goto out;
 		}
 		if (tagarg && !(vg->fid->fmt->features & FMT_TAGS)) {
--- LVM2/tools/pvmove.c	2009/07/07 01:18:35	1.65
+++ LVM2/tools/pvmove.c	2009/07/08 18:15:51	1.66
@@ -400,15 +400,13 @@
 			log_error("Ignoring remaining command line arguments");
 
 		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
-			log_error
-			    ("ABORTING: Failed to generate list of moving LVs");
+			log_error("ABORTING: Failed to generate list of moving LVs");
 			goto out;
 		}
 
 		/* Ensure mirror LV is active */
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
-			log_error
-			    ("ABORTING: Temporary mirror activation failed.");
+			log_error("ABORTING: Temporary mirror activation failed.");
 			goto out;
 		}
 


