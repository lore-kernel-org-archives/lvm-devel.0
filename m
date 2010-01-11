From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Jan 2010 21:20:20 -0000
Subject: LVM2 lib/metadata/lv_manip.c test/t-mirror-lvc ...
Message-ID: <20100111212020.11101.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-11 21:20:19

Modified files:
	lib/metadata   : lv_manip.c 
	test           : t-mirror-lvconvert.sh 
	tools          : lvconvert.c 

Log message:
	Testsuite updates and fixes for recently added features.
	
	1. Found bug in 'redundant log' implementation that caused
	problems when converting a linear that spanned multiple
	devices to a mirror (wasn't checking for NULL value of
	provided parameter in _alloc_parallel_area)
	
	2. Testsuite was failing to perform tests when 'not' modifier
	was used.  This allowed a couple issues to slip through.
	Added a 'not_sh' modifier that negates tests performed by
	functions defined in the shell source file.
	
	3. Was initializing a variable to far down, which cause
	previously set value to be overridden.  (This was the
	result of the collision of the "redundant log" and
	lvconvert fix patches.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.194&r2=1.195
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108

--- LVM2/lib/metadata/lv_manip.c	2010/01/10 20:44:09	1.194
+++ LVM2/lib/metadata/lv_manip.c	2010/01/11 21:20:19	1.195
@@ -762,7 +762,7 @@
 		consume_pv_area(areas[s], area_len);
 
 	for (i = 0, s = ah->area_count;
-	     (s < ah->area_count + ah->log_count);
+	     log_areas && (s < ah->area_count + ah->log_count);
 	     s++, i++) {
 		aa[s].pv = log_areas[i]->map->pv;
 		aa[s].pe = log_areas[i]->start;
--- LVM2/test/t-mirror-lvconvert.sh	2009/12/10 22:06:15	1.12
+++ LVM2/test/t-mirror-lvconvert.sh	2010/01/11 21:20:19	1.13
@@ -128,6 +128,12 @@
 	fi
 }
 
+not_sh ()
+{
+    "$@" && exit 1 || :;
+}
+
+
 prepare_lvs_
 check_and_cleanup_lvs_
 
@@ -149,6 +155,19 @@
 mirrorlog_is_on_ $vg/$lv1 $dev3
 check_and_cleanup_lvs_
 
+# remove 1 mirror from corelog'ed mirror
+#  should retain 'core' log type
+prepare_lvs_
+lvcreate -l2 -m2 --corelog -n $lv1 $vg
+check_mirror_count_ $vg/$lv1 3
+not_sh check_mirror_log_ $vg/$lv1
+lvconvert -m -1 -i1 $vg/$lv1
+check_no_tmplvs_ $vg/$lv1
+check_mirror_count_ $vg/$lv1 2
+mimages_are_redundant_ $vg $lv1
+not_sh check_mirror_log_ $vg/$lv1
+check_and_cleanup_lvs_
+
 # add 2 mirrors
 prepare_lvs_
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
@@ -161,27 +180,41 @@
 mirrorlog_is_on_ $vg/$lv1 $dev3
 check_and_cleanup_lvs_
 
-# add 1 mirror to core log mirror
+# add 1 mirror to core log mirror,
+#  explicitly keep log as 'core'
 prepare_lvs_
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
 check_mirror_count_ $vg/$lv1 2
-not check_mirror_log_ $vg/$lv1
+not_sh check_mirror_log_ $vg/$lv1
 lvconvert -m+1 -i1 --mirrorlog core $vg/$lv1 $dev4 
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 3 
-not check_mirror_log_ $vg/$lv1
+not_sh check_mirror_log_ $vg/$lv1
 mimages_are_redundant_ $vg $lv1 
 check_and_cleanup_lvs_
 
+# add 1 mirror to core log mirror, but
+#  implicitly keep log as 'core'
+prepare_lvs_
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+check_mirror_count_ $vg/$lv1 2
+not_sh check_mirror_log_ $vg/$lv1
+lvconvert -m +1 -i1 $vg/$lv1
+check_no_tmplvs_ $vg/$lv1
+check_mirror_count_ $vg/$lv1 3
+not_sh check_mirror_log_ $vg/$lv1
+mimages_are_redundant_ $vg $lv1
+check_and_cleanup_lvs_
+
 # add 2 mirrors to core log mirror" 
 prepare_lvs_ 
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
 check_mirror_count_ $vg/$lv1 2 
-not check_mirror_log_ $vg/$lv1 
+not_sh check_mirror_log_ $vg/$lv1 
 lvconvert -m+2 -i1 --mirrorlog core $vg/$lv1 $dev4 $dev5 
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 4 
-not check_mirror_log_ $vg/$lv1
+not_sh check_mirror_log_ $vg/$lv1
 mimages_are_redundant_ $vg $lv1 
 check_and_cleanup_lvs_
 
@@ -208,7 +241,7 @@
 prepare_lvs_ 
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
 check_mirror_count_ $vg/$lv1 2 
-not check_mirror_log_ $vg/$lv1 
+not_sh check_mirror_log_ $vg/$lv1 
 lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0-1 
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 3 
--- LVM2/tools/lvconvert.c	2010/01/11 17:13:45	1.107
+++ LVM2/tools/lvconvert.c	2010/01/11 21:20:19	1.108
@@ -613,7 +613,7 @@
 	struct lv_segment *seg;
 	uint32_t existing_mirrors;
 	const char *mirrorlog;
-	unsigned log_count = 0;
+	unsigned log_count = 1;
 	int r = 0;
 	struct logical_volume *log_lv, *layer_lv;
 	int failed_mirrors = 0, failed_log = 0;
@@ -710,11 +710,6 @@
 		/*
 		 * Adjust log type
 		 */
-		/*
-		 * This param used to be 'corelog' and was initialized to '0'.
-		 * We initially set to '1' here so as not to screw the logic.
-		 */
-		log_count = 1;
 		if (arg_count(cmd, corelog_ARG))
 			log_count = 0;
 


