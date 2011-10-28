From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:23:25 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20111028202325.1343.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:23:25

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Improve lv_extend stack reporting
	
	and some code cleanup with setting return value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2175&r2=1.2176
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.307&r2=1.308

--- LVM2/WHATS_NEW	2011/10/28 20:17:55	1.2175
+++ LVM2/WHATS_NEW	2011/10/28 20:23:24	1.2176
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Improve lv_extend stack reporting.
   Increase virtual segment size instead of creating multiple segment list.
   Add last_seg(lv) internal function.
   Support empty string for log/prefix.
--- LVM2/lib/metadata/lv_manip.c	2011/10/28 20:19:26	1.307
+++ LVM2/lib/metadata/lv_manip.c	2011/10/28 20:23:25	1.308
@@ -2571,10 +2571,11 @@
 	if (segtype_is_thin_pool(segtype)) {
 		if (!(r = extend_pool(lv, segtype, ah)))
 			stack;
-	} else if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype))
-		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
-				   stripe_size, 0u, 0);
-	else {
+	} else if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype)) {
+		if (!(r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
+					 stripe_size, 0u, 0)))
+			stack;
+	} else {
 		/*
 		 * For RAID, all the devices are AREA_LV.
 		 * However, for 'mirror on stripe' using non-RAID targets,
@@ -2587,11 +2588,10 @@
 			sub_lv_count = mirrors;
 
 		if (!lv->le_count &&
-		    !_lv_insert_empty_sublvs(lv, segtype, stripe_size,
-					     region_size, sub_lv_count)) {
+		    !(r = _lv_insert_empty_sublvs(lv, segtype, stripe_size,
+						  region_size, sub_lv_count))) {
 			log_error("Failed to insert layer for %s", lv->name);
-			alloc_destroy(ah);
-			return 0;
+			goto out;
 		}
 
 		if (!(r = _lv_extend_layered_lv(ah, lv, extents, 0,
@@ -2620,9 +2620,8 @@
 				goto out;
 			}
 
-			r = 0;
-			if (!lv_mirror_percent(lv->vg->cmd, lv, 0,
-					       &sync_percent, NULL)) {
+			if (!(r = lv_mirror_percent(lv->vg->cmd, lv, 0,
+						    &sync_percent, NULL))) {
 				log_error("Failed to get sync percent for %s/%s",
 					  lv->vg->name, lv->name);
 				goto out;
@@ -2638,7 +2637,6 @@
 					  lv->vg->name, lv->name);
 				goto out;
 			}
-			r = 1;
 		}
 	}
 


