From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 14 Sep 2011 02:45:38 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20110914024538.3362.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-14 02:45:37

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix for bug 734252 - problem up converting striped mirror after image failure
	
	lv_mirror_count was not able to handle mirrors of stripes properly.  When a
	failed device is removed, the MIRRORED status flag is removed from the LV
	conditionally based on the results of lv_mirror_count.  However, lv_mirror_count
	trusted the MIRRORED flag - thinking any such LV must be mirrored.  It would
	happily assign first_seg(lv)->area_count as the number of mirrors, but when
	a mirrored striped LV was reduced to a simple striped LV area_count would be
	the number of /stripes/ not the number of /mirrors/.  A result higher than 1
	would be returned from lv_mirror_count, the MIRRORED flag would not be cleared,
	and the LV would fail to be up-converted properly in lvconvert_mirrors_aux
	because of it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2106&r2=1.2107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.166&r2=1.167

--- LVM2/WHATS_NEW	2011/09/13 21:13:33	1.2106
+++ LVM2/WHATS_NEW	2011/09/14 02:45:36	1.2107
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix lv_mirror_count to handle mirrored stripes properly.
   Fix failure to down-convert a mirror to linear due to udev "dev open" conflict
   Fix mirrored log creation when PE size is small - force log_size >= region_size
   Fix improper RAID 64-bit status flag reset when and'ing against 32-bit flag.
--- LVM2/lib/metadata/mirror.c	2011/09/13 21:13:33	1.166
+++ LVM2/lib/metadata/mirror.c	2011/09/14 02:45:37	1.167
@@ -114,16 +114,18 @@
 		return 1;
 
 	seg = first_seg(lv);
-	mirrors = seg->area_count;
+	mirrors = 0;
 
 	for (s = 0; s < seg->area_count; s++) {
 		if (seg_type(seg, s) != AREA_LV)
 			continue;
 		if (is_temporary_mirror_layer(seg_lv(seg, s)))
 			mirrors += lv_mirror_count(seg_lv(seg, s)) - 1;
+		else
+			mirrors++;
 	}
 
-	return mirrors;
+	return mirrors ? mirrors : 1;
 }
 
 struct lv_segment *find_mirror_seg(struct lv_segment *seg)


