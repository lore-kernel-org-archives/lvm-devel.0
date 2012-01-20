From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Jan 2012 10:56:30 -0000
Subject: LVM2/lib/metadata lv.c
Message-ID: <20120120105630.2045.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-20 10:56:30

Modified files:
	lib/metadata   : lv.c 

Log message:
	Thin cleanup
	
	Reorder condition so the code is better readable (and shorter).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/lib/metadata/lv.c	2012/01/20 10:55:28	1.33
+++ LVM2/lib/metadata/lv.c	2012/01/20 10:56:30	1.34
@@ -182,11 +182,10 @@
 {
 	struct lv_segment *seg;
 
-	dm_list_iterate_items(seg, &lv->segments) {
-		if (!seg_is_mirrored(seg) || !seg->log_lv)
-			continue;
-		return dm_pool_strdup(mem, seg->log_lv->name);
-	}
+	dm_list_iterate_items(seg, &lv->segments)
+		if (seg_is_mirrored(seg) && seg->log_lv)
+			return dm_pool_strdup(mem, seg->log_lv->name);
+
 	return NULL;
 }
 
@@ -194,11 +193,10 @@
 {
 	struct lv_segment *seg;
 
-	dm_list_iterate_items(seg, &lv->segments) {
-		if (!seg_is_thin_volume(seg) || !seg->pool_lv)
-			continue;
-		return dm_pool_strdup(mem, seg->pool_lv->name);
-	}
+	dm_list_iterate_items(seg, &lv->segments)
+		if (seg_is_thin_volume(seg) && seg->pool_lv)
+			return dm_pool_strdup(mem, seg->pool_lv->name);
+
 	return NULL;
 }
 


