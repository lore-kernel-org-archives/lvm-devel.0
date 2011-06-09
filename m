From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jun 2011 19:38:57 -0000
Subject: LVM2 ./WHATS_NEW test/t-lvconvert-mirror.sh to ...
Message-ID: <20110609193857.21015.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-09 19:38:56

Modified files:
	.              : WHATS_NEW 
	test           : t-lvconvert-mirror.sh 
	tools          : lvresize.c 

Log message:
	Fix mirrored stripe reduction.
	
	Patch adds check for stripe not only in direct
	LV segment but also in mirror image segment.
	
	This prevents bugs like:
	
	# lvcreate -i2 -l10 -n lv vg_test
	# lvconvert -m1 -i1 vg_test/lv
	
	# lvreduce -f -l1 vg_test/lv
	WARNING: Reducing active logical volume to 4.00 MiB
	THIS MAY DESTROY YOUR DATA (filesystem etc.)
	Reducing logical volume lv to 4.00 MiB
	Segment extent reduction 9 not divisible by #stripes 2
	Logical volume lv successfully resized
	
	# lvremove -f vg_test
	Segment extent reduction 1 not divisible by #stripes 2
	LV segment lv:0-4294967295 is incorrectly listed as being used by LV lv_mimage_0
	Internal error: LV segments corrupted in lv_mimage_0.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2009&r2=1.2010
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/WHATS_NEW	2011/06/09 19:36:16	1.2009
+++ LVM2/WHATS_NEW	2011/06/09 19:38:56	1.2010
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Fix reduction of mirrors with striped segments to always align to stripe size.
   Validate mirror segments size.
   Fix extent rounding for striped volumes (never reduce more than requested).
   Fix create_temp_name to replace any '/' found in the hostname with '?'.
--- LVM2/test/t-lvconvert-mirror.sh	2011/01/05 00:16:20	1.9
+++ LVM2/test/t-lvconvert-mirror.sh	2011/06/09 19:38:56	1.10
@@ -240,3 +240,11 @@
 check mirror $vg $lv1 $dev3
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
+
+# simple mirrored stripe
+aux prepare_vg 5
+lvcreate -i2 -l10 -n $lv1 $vg
+lvconvert -m1 -i1 $vg/$lv1
+lvreduce -f -l1 $vg/$lv1
+lvextend -f -l10 $vg/$lv1
+lvremove -ff $vg/$lv1
--- LVM2/tools/lvresize.c	2011/06/09 19:34:50	1.131
+++ LVM2/tools/lvresize.c	2011/06/09 19:38:56	1.132
@@ -305,6 +305,34 @@
 	return 1;
 }
 
+static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
+{
+	uint32_t s;
+	struct lv_segment *seg_mirr;
+
+	/* If segment mirrored, check if images are striped */
+	if (seg_is_mirrored(seg))
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_LV)
+				continue;
+			seg_mirr = first_seg(seg_lv(seg, s));
+
+			if (seg_is_striped(seg_mirr)) {
+				seg = seg_mirr;
+				break;
+			}
+		}
+
+
+	if (seg_is_striped(seg)) {
+		*stripesize = seg->stripe_size;
+		return seg->area_count;
+	}
+
+	*stripesize = 0;
+	return 0;
+}
+
 static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvresize_params *lp)
 {
@@ -548,10 +576,8 @@
 		dm_list_iterate_items(seg, &lv->segments) {
 			seg_extents = seg->len;
 
-			if (seg_is_striped(seg)) {
-				seg_stripesize = seg->stripe_size;
-				seg_stripes = seg->area_count;
-			}
+			/* Check for underlying stripe sizes */
+			seg_stripes = lvseg_get_stripes(seg, &seg_stripesize);
 
 			if (seg_is_mirrored(seg))
 				seg_mirrors = lv_mirror_count(seg->lv);


