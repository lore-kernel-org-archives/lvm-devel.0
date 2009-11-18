From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 18 Nov 2009 16:48:11 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c
Message-ID: <20091118164811.30581.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-18 16:48:10

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 

Log message:
	Fix pvmove region_size overflow for very large PVs.
	
	Fixes problem reported in
	https://www.redhat.com/archives/dm-devel/2009-November/msg00104.html
	
	The region size multiplication can overflow when using 32bit integer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1314&r2=1.1315
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/WHATS_NEW	2009/11/04 14:47:27	1.1314
+++ LVM2/WHATS_NEW	2009/11/18 16:48:10	1.1315
@@ -1,5 +1,6 @@
 Version 2.02.55 -
 ===================================
+  Fix pvmove region_size oveflow for very large PVs.
   Fix lvcreate and lvresize processing of %PVS argument.
   Tidy some uses of arg_count and introduce arg_is_set.
   Export outnl and indent functions for modules.
--- LVM2/lib/mirror/mirrored.c	2009/10/01 00:35:30	1.64
+++ LVM2/lib/mirror/mirrored.c	2009/11/18 16:48:10	1.65
@@ -290,7 +290,7 @@
 	uint32_t area_count = seg->area_count;
 	unsigned start_area = 0u;
 	int mirror_status = MIRR_RUNNING;
-	uint32_t region_size, region_max;
+	uint32_t region_size;
 	int r;
 
 	if (!*target_state)
@@ -333,18 +333,11 @@
 			return 0;
 		}
 		region_size = seg->region_size;
-	} else {
-		/* Find largest power of 2 region size unit we can use */
-		region_max = (1 << (ffs((int)seg->area_len) - 1)) *
-		      seg->lv->vg->extent_size;
-
-		region_size = mirr_state->default_region_size;
-		if (region_max < region_size) {
-			region_size = region_max;
-			log_verbose("Using reduced mirror region size of %u sectors",
-				    region_size);
-		}
-	}
+
+	} else
+		region_size = adjusted_mirror_region_size(seg->lv->vg->extent_size,
+							  seg->area_len,
+							  mirr_state->default_region_size);
 
 	if (!dm_tree_node_add_mirror_target(node, len))
 		return_0;


