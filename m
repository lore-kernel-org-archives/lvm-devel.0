From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Oct 2011 12:39:59 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20111004123959.23312.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-04 12:39:59

Modified files:
	lib/display    : display.c 

Log message:
	Use capital letters

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/lib/display/display.c	2011/10/03 18:31:03	1.120
+++ LVM2/lib/display/display.c	2011/10/04 12:39:59	1.121
@@ -553,13 +553,13 @@
 			  lv->vg->name, first_seg(lv)->pool_lv->name);
 	} else if (lv_is_thin_pool(lv)) {
 		/* FIXME: display thin_pool targets transid for activated LV as well */
-		log_print("LV Thin transaction id %" PRIu64,
+		log_print("LV Thin transaction ID %" PRIu64,
 			  first_seg(lv)->transaction_id);
 		log_print("LV Thin metadata       %s%s/%s", lv->vg->cmd->dev_dir,
 			  lv->vg->name, first_seg(lv)->pool_metadata_lv->name);
 		log_print("LV Thin data pool      %s%s/%s", lv->vg->cmd->dev_dir,
 			  lv->vg->name, seg_lv(first_seg(lv), 0)->name);
-		log_print("LV zero new blocks     %s",
+		log_print("LV Zero new blocks     %s",
 			  first_seg(lv)->zero_new_blocks ? "yes" : "no");
 	}
 


