From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2009 21:29:11 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20090513212911.30422.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-13 21:29:10

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	test           : t-lvcreate-usage.sh test-utils.sh 
	tools          : lvcreate.c 

Log message:
	Check max_lv on only place and force the check only for new volume.
	
	We can temporarily violate max_lv during mirror conversion etc.
	
	(If the operation fails, orphan mirror images are visible to administrator
	for manual remove for example. Not that this should ever happen:-)
	
	Force limit only for lvcreate (and vg merge) command.
	
	Patch also adds simple max_lv tests into testsuite

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1110&r2=1.1111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.218&r2=1.219
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.187&r2=1.188

--- LVM2/WHATS_NEW	2009/05/13 21:28:31	1.1110
+++ LVM2/WHATS_NEW	2009/05/13 21:29:10	1.1111
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Force max_lv restriction only for newly created LV.
   Remove unneeded import parameter from lv_create_empty.
   Merge lv_is_displayable and lv_is_visible functions.
   Introduce lv_set_visible & lv_set_invisible functions.
--- LVM2/lib/metadata/lv_manip.c	2009/05/13 21:28:31	1.171
+++ LVM2/lib/metadata/lv_manip.c	2009/05/13 21:29:10	1.172
@@ -1804,6 +1804,20 @@
 	return buffer;
 }
 
+int vg_max_lv_reached(struct volume_group *vg)
+{
+	if (!vg->max_lv)
+		return 0;
+
+	if (vg->max_lv > vg_visible_lvs(vg))
+		return 0;
+
+	log_verbose("Maximum number of logical volumes (%u) reached "
+		    "in volume group %s", vg->max_lv, vg->name);
+
+	return 1;
+}
+
 /*
  * Create a new empty LV.
  */
@@ -1817,11 +1831,8 @@
 	struct logical_volume *lv;
 	char dname[NAME_LEN];
 
-	if (vg->max_lv && (vg->max_lv == vg_visible_lvs(vg))) {
-		log_error("Maximum number of logical volumes (%u) reached "
-			  "in volume group %s", vg->max_lv, vg->name);
-		return NULL;
-	}
+	if (vg_max_lv_reached(vg))
+		stack;
 
 	if (strstr(name, "%d") &&
 	    !(name = generate_lv_name(vg, name, dname, sizeof(dname)))) {
@@ -1936,6 +1947,9 @@
 {
 	struct lv_list *lvl;
 
+	if (vg_max_lv_reached(vg))
+		stack;
+
 	if (!(lvl = dm_pool_zalloc(vg->vgmem, sizeof(*lvl))))
 		return_0;
 
--- LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:28:31	1.72
+++ LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:29:10	1.73
@@ -565,6 +565,11 @@
 unsigned vg_visible_lvs(const struct volume_group *vg);
 
 /*
+ * Check if the VG reached maximal LVs count (if set)
+ */
+int vg_max_lv_reached(struct volume_group *vg);
+
+/*
 * Mirroring functions
 */
 struct lv_segment *find_mirror_seg(struct lv_segment *seg);
--- LVM2/lib/metadata/metadata.c	2009/05/13 21:27:43	1.218
+++ LVM2/lib/metadata/metadata.c	2009/05/13 21:29:10	1.219
@@ -1528,12 +1528,8 @@
 		r = 0;
 	}
 
-	if (vg->max_lv && (vg->max_lv < vg_visible_lvs(vg))) {
-		log_error("Internal error: Volume group %s contains %u volumes"
-			  " but the limit is set to %u.",
-			  vg->name, vg_visible_lvs(vg), vg->max_lv);
-		r = 0;
-	}
+	if (vg_max_lv_reached(vg))
+		stack;
 
 	return r;
 }
--- LVM2/test/t-lvcreate-usage.sh	2009/05/08 21:50:20	1.12
+++ LVM2/test/t-lvcreate-usage.sh	2009/05/13 21:29:10	1.13
@@ -55,12 +55,33 @@
 case $(lvdisplay $vg) in "") true ;; *) false ;; esac
 
 # Setting max_lv works. (bz490298)
-vgchange -l 4 $vg
+lvremove -ff $vg
+vgchange -l 3 $vg
 lvcreate -l1 -n $lv1 $vg
 lvcreate -l1 -s -n $lv2 $vg/$lv1
 lvcreate -l1 -n $lv3 $vg
 not lvcreate -l1 -n $lv4 $vg
+
+lvremove -ff $vg/$lv3
+lvcreate -l1 -s -n $lv3 $vg/$lv1
+not lvcreate -l1 -n $lv4 $vg
+not lvcreate -l1 -m1 -n $lv4 $vg
+
+lvremove -ff $vg/$lv3
+lvcreate -l1 -m1 -n $lv3 $vg
+lvs
+vgs -o +max_lv
+not lvcreate -l1 -n $lv4 $vg
+not lvcreate -l1 -m1 -n $lv4 $vg
+
+lvconvert -m0 $vg/$lv3
+lvconvert -m2 -i 1 $vg/$lv3
+lvconvert -m1 $vg/$lv3
+
+not vgchange -l 2
+vgchange -l 4
 vgs $vg
+
 lvremove -ff $vg
 vgchange -l 0 $vg
 
--- LVM2/test/test-utils.sh	2009/05/13 19:18:47	1.12
+++ LVM2/test/test-utils.sh	2009/05/13 21:29:10	1.13
@@ -130,6 +130,7 @@
 	lv1=LV1
 	lv2=LV2
 	lv3=LV3
+	lv4=LV4
 }
 
 disable_dev() {
--- LVM2/tools/lvcreate.c	2009/05/13 21:28:31	1.187
+++ LVM2/tools/lvcreate.c	2009/05/13 21:29:10	1.188
@@ -613,6 +613,12 @@
 		return 0;
 	}
 
+	if (vg_max_lv_reached(vg)) {
+		log_error("Maximum number of logical volumes (%u) reached "
+			  "in volume group %s", vg->max_lv, vg->name);
+		return 0;
+	}
+
 	if (lp->mirrors > 1 && !(vg->fid->fmt->features & FMT_SEGMENTS)) {
 		log_error("Metadata does not support mirroring.");
 		return 0;


