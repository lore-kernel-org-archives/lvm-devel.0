From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Oct 2011 18:24:49 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111003182449.32146.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-03 18:24:49

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Add preload support for thin and thin_pool

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.234&r2=1.235

--- LVM2/lib/activate/dev_manager.c	2011/09/29 08:56:38	1.234
+++ LVM2/lib/activate/dev_manager.c	2011/10/03 18:24:47	1.235
@@ -1098,6 +1098,16 @@
 	    !_add_partial_replicator_to_dtree(dm, dtree, lv))
 		return_0;
 
+	if (lv_is_thin_pool(lv)) {
+		    if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->pool_metadata_lv, origin_only))
+			    return_0;
+		    if (!_add_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), origin_only))
+			    return_0;
+	} else if (lv_is_thin_volume(lv)) {
+		    if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->pool_lv, origin_only))
+			    return_0;
+	}
+
 	return 1;
 }
 


