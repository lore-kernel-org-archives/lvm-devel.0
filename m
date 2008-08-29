From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 29 Aug 2008 13:41:22 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c tools ...
Message-ID: <20080829134122.11013.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-29 13:41:21

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 
	tools          : vgconvert.c 

Log message:
	Fix setting of volume limit count if converting to lvm1 format.
	
	Fixes problem when after downconvert to lvm1 VG is broken:
	
	# lvcreate -n lv1 -l 4 vg_test
	Invalid LV in extent map (PV /dev/sdb1, PE 0, LV 0, LE 0)
	...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.949&r2=1.950
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/WHATS_NEW	2008/08/28 18:41:50	1.949
+++ LVM2/WHATS_NEW	2008/08/29 13:41:21	1.950
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Fix setting of volume limit count if converting to lvm1 format.
   Fix vgconvert logical volume id metadata validation.
   Fix lvmdump metadata gather option (-m) to work correctly.
   Fix allocation bug in text metadata format write error path.
--- LVM2/lib/metadata/metadata.c	2008/08/13 13:42:35	1.186
+++ LVM2/lib/metadata/metadata.c	2008/08/29 13:41:21	1.187
@@ -1255,6 +1255,13 @@
 		}
 	}
 
+	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS) &&
+	    (!vg->max_lv || !vg->max_pv)) {
+		log_error("Internal error: Volume group %s has limited PV/LV count"
+			  " but limit is not set.", vg->name);
+		r = 0;
+	}
+
 	return r;
 }
 
--- LVM2/tools/vgconvert.c	2008/08/28 18:41:51	1.29
+++ LVM2/tools/vgconvert.c	2008/08/29 13:41:21	1.30
@@ -81,6 +81,15 @@
 		return ECMD_FAILED;
 	}
 
+	/* Set PV/LV limit if converting from unlimited metadata format */
+	if (vg->fid->fmt->features & FMT_UNLIMITED_VOLS &&
+	    !(cmd->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!vg->max_lv)
+			vg->max_lv = 255;
+		if (!vg->max_pv)
+			vg->max_pv = 255;
+	}
+
 	/* If converting to restricted lvid, check if lvid is compatible */
 	if (!(vg->fid->fmt->features & FMT_RESTRICTED_LVIDS) &&
 	    cmd->fmt->features & FMT_RESTRICTED_LVIDS)


