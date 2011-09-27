From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Sep 2011 12:34:14 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20110927123414.14634.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-27 12:34:14

Modified files:
	lib/display    : display.c 

Log message:
	typo

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/lib/display/display.c	2011/09/26 13:11:02	1.118
+++ LVM2/lib/display/display.c	2011/09/27 12:34:14	1.119
@@ -552,7 +552,7 @@
 		log_print("LV Thin pool           %s%s/%s", lv->vg->cmd->dev_dir,
 			  lv->vg->name, first_seg(lv)->pool_lv->name);
 	} else if (lv_is_thin_pool(lv)) {
-		log_print("LV Thin metadada       %s%s/%s", lv->vg->cmd->dev_dir,
+		log_print("LV Thin metadata       %s%s/%s", lv->vg->cmd->dev_dir,
 			  lv->vg->name, first_seg(lv)->pool_metadata_lv->name);
 		log_print("LV Thin data pool      %s%s/%s", lv->vg->cmd->dev_dir,
 			  lv->vg->name, seg_lv(first_seg(lv), 0)->name);


