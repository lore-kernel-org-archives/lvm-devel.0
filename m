From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Nov 2011 17:32:13 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20111115173213.2500.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-15 17:32:12

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Adjusted mirror region size only for mirrors and raids
	
	Update region_size only for mirror and raid targets.
	This fixes warning messages when vg is using small
	extent size like 1KiB and no mirror/raid is created,
	but the user still got the message:
	
	$> vgcreate -s 1K vg  <pvs>
	$> lvcreate -L10K vg
	Using reduced mirror region size of 4 sectors

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2185&r2=1.2186
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.336&r2=1.337

--- LVM2/WHATS_NEW	2011/11/15 17:27:41	1.2185
+++ LVM2/WHATS_NEW	2011/11/15 17:32:12	1.2186
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Adjusted mirror region size only for mirrors and raids.
   Reorder prompt conditions for removal of active volumes.
   Avoid 'mda inconsistency' by properly registering UNLABELLED_PV flag (2.02.86).
   Fix --enable-static_link unless using --enable-dmeventd / --enable-udev_sync.
--- LVM2/lib/metadata/lv_manip.c	2011/11/15 17:29:52	1.336
+++ LVM2/lib/metadata/lv_manip.c	2011/11/15 17:32:12	1.337
@@ -4197,6 +4197,10 @@
 				 lp->segtype->name);
 			status |= LV_NOTSYNCED;
 		}
+
+		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
+							      lp->extents,
+							      lp->region_size);
 	}
 
 	if (!(lv = lv_create_empty(new_lv_name ? : "lvol%d", NULL,
@@ -4218,10 +4222,6 @@
 
 	dm_list_splice(&lv->tags, &lp->tags);
 
-	lp->region_size = adjusted_mirror_region_size(vg->extent_size,
-						      lp->extents,
-						      lp->region_size);
-
 	if (!lv_extend(lv, lp->segtype,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors,


