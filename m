From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Oct 2011 18:31:04 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20111003183104.2639.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-03 18:31:04

Modified files:
	lib/display    : display.c 

Log message:
	Display transaction_id for thin_pool

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/lib/display/display.c	2011/09/27 12:34:14	1.119
+++ LVM2/lib/display/display.c	2011/10/03 18:31:03	1.120
@@ -552,6 +552,9 @@
 		log_print("LV Thin pool           %s%s/%s", lv->vg->cmd->dev_dir,
 			  lv->vg->name, first_seg(lv)->pool_lv->name);
 	} else if (lv_is_thin_pool(lv)) {
+		/* FIXME: display thin_pool targets transid for activated LV as well */
+		log_print("LV Thin transaction id %" PRIu64,
+			  first_seg(lv)->transaction_id);
 		log_print("LV Thin metadata       %s%s/%s", lv->vg->cmd->dev_dir,
 			  lv->vg->name, first_seg(lv)->pool_metadata_lv->name);
 		log_print("LV Thin data pool      %s%s/%s", lv->vg->cmd->dev_dir,


