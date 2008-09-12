From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 12 Sep 2008 15:26:46 -0000
Subject: LVM2 ./WHATS_NEW tools/pvresize.c
Message-ID: <20080912152646.21990.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-09-12 15:26:45

Modified files:
	.              : WHATS_NEW 
	tools          : pvresize.c 

Log message:
	Fix pvresize to not allow resize if PV has two metadata areas.
	
	If the PV has two metadata areas, second one is located at the end of the device.
	
	Do not allow resize of PV or second metadata area can be overwritten.
	(The check was active only for orphan PVs.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.950&r2=1.951
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2008/08/29 13:41:21	1.950
+++ LVM2/WHATS_NEW	2008/09/12 15:26:44	1.951
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Fix pvresize to not allow resize if PV has two metadata areas.
   Fix setting of volume limit count if converting to lvm1 format.
   Fix vgconvert logical volume id metadata validation.
   Fix lvmdump metadata gather option (-m) to work correctly.
--- LVM2/tools/pvresize.c	2008/01/30 14:00:02	1.21
+++ LVM2/tools/pvresize.c	2008/09/12 15:26:45	1.22
@@ -35,6 +35,8 @@
 	struct list mdas;
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name;
+	struct lvmcache_info *info;
+	int mda_count = 0;
 
 	list_init(&mdas);
 
@@ -51,13 +53,7 @@
 			return 0;
 		}
 
-		/* FIXME Create function to test compatibility properly */
-		if (list_size(&mdas) > 1) {
-			log_error("%s: too many metadata areas for pvresize",
-				  pv_name);
-			unlock_vg(cmd, vg_name);
-			return 0;
-		}
+		mda_count = list_size(&mdas);
 	} else {
 		vg_name = pv_vg_name(pv);
 
@@ -87,10 +83,26 @@
 
 		pv = pvl->pv;
 
+		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
+			unlock_vg(cmd, vg_name);
+			log_error("Can't get info for PV %s in volume group %s",
+				  pv_name, vg->name);
+			return 0;
+		}
+
+		mda_count = list_size(&info->mdas);
+
 		if (!archive(vg))
 			return 0;
 	}
 
+	/* FIXME Create function to test compatibility properly */
+	if (mda_count > 1) {
+		log_error("%s: too many metadata areas for pvresize", pv_name);
+		unlock_vg(cmd, vg_name);
+		return 0;
+	}
+
 	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
 		log_error("Physical volume %s format does not support resizing.",
 			  pv_name);


