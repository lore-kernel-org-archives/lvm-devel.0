From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 28 Jan 2011 02:58:02 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20110128025802.30997.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2011-01-28 02:58:01

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Improve lvcreate "insufficient extents" errors to "insufficient free space".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1892&r2=1.1893
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.245&r2=1.246

--- LVM2/WHATS_NEW	2011/01/27 00:21:37	1.1892
+++ LVM2/WHATS_NEW	2011/01/28 02:58:00	1.1893
@@ -1,6 +1,7 @@
 Version 2.02.83 - 
 ===================================
   Always use O_DIRECT when opening block devices to check for partitioning.
+  Improve lvcreate "insufficient extents" errors to "insufficient free space".
 
 Version 2.02.82 - 24th January 2011
 ===================================
--- LVM2/lib/metadata/lv_manip.c	2011/01/24 14:19:05	1.245
+++ LVM2/lib/metadata/lv_manip.c	2011/01/28 02:58:01	1.246
@@ -1481,7 +1481,7 @@
 	}
 
 	if (log_needs_allocating) {
-		log_error("Insufficient extents for log allocation "
+		log_error("Insufficient free space for log allocation "
 			  "for logical volume %s.",
 			  lv ? lv->name : "");
 		goto out;
@@ -3232,8 +3232,9 @@
 
 	if (!seg_is_virtual(lp) &&
 	    vg->free_count < lp->extents) {
-		log_error("Insufficient free extents (%u) in volume group %s: "
-			  "%u required", vg->free_count, vg->name, lp->extents);
+		log_error("Volume group \"%s\" has insufficient free space "
+			  "(%u extents): %u required.",
+			  vg->name, vg->free_count, lp->extents);
 		return 0;
 	}
 


