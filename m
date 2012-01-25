From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 11:27:43 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120125112743.25946.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 11:27:42

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin clear stacked message for thin pool
	
	Before removing thin pool LV always make sure, stacked message
	for previous run are cleared - but allow to remove any
	device that should have been created
	(i.e. creation of snapshot failed - so the message for snapshot creation
	may be replaced with delete message within unfinished transaction).
	
	Also commit messages after lv remove - so free space is released in pool.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.352&r2=1.353

--- LVM2/lib/metadata/lv_manip.c	2012/01/25 09:15:44	1.352
+++ LVM2/lib/metadata/lv_manip.c	2012/01/25 11:27:42	1.353
@@ -527,10 +527,6 @@
 				return_0;
 
 			if (seg->pool_lv) {
-                                /* For now, clear stacked messages here */
-				if (!update_pool_lv(seg->pool_lv, 1))
-					return_0;
-
 				if (!detach_pool_lv(seg))
 					return_0;
 			}
@@ -3142,6 +3138,7 @@
 	struct logical_volume *format1_origin = NULL;
 	int format1_reload_required = 0;
 	int visible;
+	struct logical_volume *pool_lv = NULL;
 
 	vg = lv->vg;
 
@@ -3176,7 +3173,8 @@
 		log_error("Can't remove logical volume %s used by a thin pool.",
 			  lv->name);
 		return 0;
-	}
+	} else if (lv_is_thin_volume(lv))
+		pool_lv = first_seg(lv)->pool_lv;
 
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
@@ -3222,6 +3220,13 @@
 		return 0;
 	}
 
+	/* Clear thin pool stacked messages */
+	if (pool_lv && !pool_has_message(first_seg(pool_lv), lv, 0) &&
+	    !update_pool_lv(pool_lv, 1)) {
+		log_error("Failed to update thin pool %s.", pool_lv->name);
+		return 0;
+	}
+
 	visible = lv_is_visible(lv);
 
 	log_verbose("Releasing logical volume \"%s\"", lv->name);
@@ -3256,6 +3261,13 @@
 		return 0;
 	}
 
+	/* Release unneeded blocks in thin pool */
+	/* TODO: defer when multiple LVs relased at once */
+	if (pool_lv && !update_pool_lv(pool_lv, 1)) {
+		log_error("Failed to update thin pool %s.", pool_lv->name);
+		return 0;
+	}
+
 	backup(vg);
 
 	if (visible)


