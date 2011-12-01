From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Dec 2011 00:13:17 -0000
Subject: LVM2 ./WHATS_NEW tools/lvresize.c
Message-ID: <20111201001317.24696.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-12-01 00:13:16

Modified files:
	.              : WHATS_NEW 
	tools          : lvresize.c 

Log message:
	Don't allow size change of RAID LV that is tracking changes for a split image
	Don't allow size change of RAID sub-LVs independently

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2201&r2=1.2202
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/WHATS_NEW	2011/12/01 00:09:34	1.2201
+++ LVM2/WHATS_NEW	2011/12/01 00:13:16	1.2202
@@ -1,7 +1,9 @@
 Version 2.02.89 - 
 ==================================
-  Don't allow name change of RAID LV while tracking a split image.
-  Do not allow users to change the name of RAID sub-LVs
+  Don't allow size change of RAID LV that is tracking changes for a split image
+  Don't allow size change of RAID sub-LVs independently
+  Don't allow name change of RAID LV that is tracking changes for a split image
+  Do not allow users to change the name of RAID sub-LVs independently
   Do not allow users to change permissions on RAID sub-LVs
   Support the ability to replace specific devices in a RAID array via lvconvert.
   Add activation/use_linear_target enabled by default.
--- LVM2/tools/lvresize.c	2011/11/08 12:19:53	1.143
+++ LVM2/tools/lvresize.c	2011/12/01 00:13:16	1.144
@@ -361,6 +361,19 @@
 		return ECMD_FAILED;
 	}
 
+	if (lvl->lv->status & (RAID_IMAGE | RAID_META)) {
+		log_error("Cannot resize a RAID %s directly",
+			  (lvl->lv->status & RAID_IMAGE) ? "image" :
+			  "metadata area");
+		return ECMD_FAILED;
+	}
+
+	if (lv_is_raid_with_tracking(lvl->lv)) {
+		log_error("Cannot resize %s while it is tracking a split image",
+			  lvl->lv->name);
+		return ECMD_FAILED;
+	}
+
 	if (arg_count(cmd, stripes_ARG)) {
 		if (vg->fid->fmt->features & FMT_SEGMENTS)
 			lp->stripes = arg_uint_value(cmd, stripes_ARG, 1);


