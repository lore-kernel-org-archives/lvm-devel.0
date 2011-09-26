From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Sep 2011 13:11:04 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20110926131104.5465.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-26 13:11:03

Modified files:
	lib/display    : display.c 

Log message:
	Show some Thin related info in lvdisplay

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/lib/display/display.c	2011/03/01 20:17:56	1.117
+++ LVM2/lib/display/display.c	2011/09/26 13:11:02	1.118
@@ -548,6 +548,18 @@
 			  snap_seg->origin->name);
 	}
 
+	if (lv_is_thin_volume(lv)) {
+		log_print("LV Thin pool           %s%s/%s", lv->vg->cmd->dev_dir,
+			  lv->vg->name, first_seg(lv)->pool_lv->name);
+	} else if (lv_is_thin_pool(lv)) {
+		log_print("LV Thin metadada       %s%s/%s", lv->vg->cmd->dev_dir,
+			  lv->vg->name, first_seg(lv)->pool_metadata_lv->name);
+		log_print("LV Thin data pool      %s%s/%s", lv->vg->cmd->dev_dir,
+			  lv->vg->name, seg_lv(first_seg(lv), 0)->name);
+		log_print("LV zero new blocks     %s",
+			  first_seg(lv)->zero_new_blocks ? "yes" : "no");
+	}
+
 	if (inkernel && info.suspended)
 		log_print("LV Status              suspended");
 	else


