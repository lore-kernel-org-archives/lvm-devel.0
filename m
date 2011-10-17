From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Oct 2011 14:17:31 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20111017141731.25260.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-17 14:17:31

Modified files:
	lib/thin       : thin.c 

Log message:
	Indent debug message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/lib/thin/thin.c	2011/10/17 14:17:09	1.17
+++ LVM2/lib/thin/thin.c	2011/10/17 14:17:30	1.18
@@ -221,12 +221,14 @@
 	struct dm_thin_message dmsg;
 
 	if (!(metadata_dlid = build_dm_uuid(mem, seg->pool_metadata_lv->lvid.s, NULL))) {
-		log_error("Failed to build uuid for metadata LV %s.", seg->pool_metadata_lv->name);
+		log_error("Failed to build uuid for metadata LV %s.",
+			  seg->pool_metadata_lv->name);
 		return 0;
 	}
 
 	if (!(pool_dlid = build_dm_uuid(mem, seg_lv(seg, 0)->lvid.s, NULL))) {
-		log_error("Failed to build uuid for pool LV %s.", seg_lv(seg, 0)->name);
+		log_error("Failed to build uuid for pool LV %s.",
+			  seg_lv(seg, 0)->name);
 		return 0;
 	}
 


