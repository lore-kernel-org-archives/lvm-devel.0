From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Nov 2009 17:07:10 -0000
Subject: LVM2 ./WHATS_NEW tools/pvdisplay.c tools/repor ...
Message-ID: <20091124170710.13545.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-24 17:07:09

Modified files:
	.              : WHATS_NEW 
	tools          : pvdisplay.c reporter.c 

Log message:
	Add missing vg_release to pvs and pvdisplay to fix memory leak.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1326&r2=1.1327
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2009/11/24 16:13:02	1.1326
+++ LVM2/WHATS_NEW	2009/11/24 17:07:09	1.1327
@@ -1,5 +1,6 @@
 Version 2.02.56 - 
 ====================================
+  Add missing vg_release to pvs and pvdisplay to fix memory leak.
   Do not try to unlock VG which is not locked in _process_one_vg.
   Move persistent filter dump to more appropriate place.
   Refresh device filters before full device rescan in lvmcache.
--- LVM2/tools/pvdisplay.c	2009/07/15 05:50:22	1.53
+++ LVM2/tools/pvdisplay.c	2009/11/24 17:07:09	1.54
@@ -31,10 +31,11 @@
 		vg_name = pv_vg_name(pv);
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
-		 	log_error("Skipping volume group %s", vg_name);
+			log_error("Skipping volume group %s", vg_name);
+			vg_release(vg);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
-		 	return ECMD_FAILED;
-	 	}
+			return ECMD_FAILED;
+		}
 
 	 	/*
 		 * Replace possibly incomplete PV structure with new one
--- LVM2/tools/reporter.c	2009/11/03 15:50:44	1.57
+++ LVM2/tools/reporter.c	2009/11/24 17:07:09	1.58
@@ -143,6 +143,7 @@
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
+			vg_release(vg);
 			return ECMD_FAILED;
 		}
 


