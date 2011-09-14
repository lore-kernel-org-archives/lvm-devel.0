From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 14 Sep 2011 04:10:27 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20110914041027.18733.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-14 04:10:27

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Additional fixes for lv_mirror_count.
	
	Changing lv_mirror_count to only count the AREA_LVs made the function
	stop working for PVMOVE mirrors.  A conditional has been added to fix
	that problem.  Additionally, when counting the images in a mirror stack,
	we don't need to subtract 1 from the count we get back from the
	lv_mirror_count call on the temporary mirror layer.  (This is because we
	are no falsely counting the top layer of the temporary mirror.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.167&r2=1.168

--- LVM2/lib/metadata/mirror.c	2011/09/14 02:45:37	1.167
+++ LVM2/lib/metadata/mirror.c	2011/09/14 04:10:26	1.168
@@ -114,13 +114,17 @@
 		return 1;
 
 	seg = first_seg(lv);
+
+	if (lv->status & PVMOVE)
+		return seg->area_count;
+
 	mirrors = 0;
 
 	for (s = 0; s < seg->area_count; s++) {
 		if (seg_type(seg, s) != AREA_LV)
 			continue;
 		if (is_temporary_mirror_layer(seg_lv(seg, s)))
-			mirrors += lv_mirror_count(seg_lv(seg, s)) - 1;
+			mirrors += lv_mirror_count(seg_lv(seg, s));
 		else
 			mirrors++;
 	}


