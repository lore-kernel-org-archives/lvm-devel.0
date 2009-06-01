From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 1 Jun 2009 15:55:08 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c test/ ...
Message-ID: <20090601155508.29546.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-01 15:55:07

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 
	test           : t-lvcreate-usage.sh 

Log message:
	Fix rename of active snapshot with virtual origin.
	
	Code must suspend/resume virtual origin too when renaming
	snaphsot otherwise in kernel old name remains.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1137&r2=1.1138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.179&r2=1.180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2009/06/01 14:43:27	1.1137
+++ LVM2/WHATS_NEW	2009/06/01 15:55:06	1.1138
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Fix rename of active snapshot with virtual origin.
   Fix convert polling to ignore LV with different UUID.
   Cache underlying device readahead only before activation calls.
   Fix segfault when calculating readahead on missing device in vgreduce.
--- LVM2/lib/metadata/lv_manip.c	2009/06/01 14:23:38	1.179
+++ LVM2/lib/metadata/lv_manip.c	2009/06/01 15:55:07	1.180
@@ -1765,6 +1765,8 @@
 {
 	struct volume_group *vg = lv->vg;
 	struct lv_names lv_names;
+	DM_LIST_INIT(lvs_changed);
+	struct lv_list lvl, lvl2;
 	int r = 0;
 
 	/* rename is not allowed on sub LVs */
@@ -1799,22 +1801,27 @@
 		return 0;
 	}
 
+	lvl.lv = lv;
+	dm_list_add(&lvs_changed, &lvl.list);
+
+	/* rename active virtual origin too */
+	if (lv_is_cow(lv) && lv_is_virtual_origin(lvl2.lv = origin_from_cow(lv)))
+		dm_list_add(&lvs_changed, &lvl2.list);
+
 	log_verbose("Writing out updated volume group");
 	if (!vg_write(vg))
 		return 0;
 
-	if (!suspend_lv(cmd, lv)) {
+
+	if (!suspend_lvs(cmd, &lvs_changed)) {
 		vg_revert(vg);
 		goto_out;
 	}
 
-	if (!vg_commit(vg)) {
-		resume_lv(cmd, lv);
-		goto_out;
-	}
+	if (!(r = vg_commit(vg)))
+		stack;
 
-	resume_lv(cmd, lv);
-	r = 1;
+	resume_lvs(cmd, &lvs_changed);
 out:
 	backup(vg);
 	return r;
--- LVM2/test/t-lvcreate-usage.sh	2009/05/13 21:29:10	1.13
+++ LVM2/test/t-lvcreate-usage.sh	2009/06/01 15:55:07	1.14
@@ -116,3 +116,10 @@
 check_lv_field_ $vg/$lv regionsize "4.00M"
 lvremove -ff $vg
 
+# snapshot with virtual origin works
+lvcreate -s --virtualoriginsize 64M -L 32M -n $lv1 $vg
+lvrename $vg/$lv1 $vg/$lv2
+lvcreate -s --virtualoriginsize 64M -L 32M -n $lv1 $vg
+lvchange -a n $vg/$lv1
+lvremove $vg/$lv1
+lvremove -ff $vg


