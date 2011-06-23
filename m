From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Jun 2011 10:53:25 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c test/ ...
Message-ID: <20110623105325.12274.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-23 10:53:24

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 
	test           : t-lvconvert-mirror.sh 

Log message:
	Fail allocation if number of extents not divisible by area count
	
	Allocation should fail early if this condition is not met.
	
	Quick fix for https://bugzilla.redhat.com/show_bug.cgi?id=707779

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2024&r2=1.2025
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.262&r2=1.263
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2011/06/22 21:31:21	1.2024
+++ LVM2/WHATS_NEW	2011/06/23 10:53:24	1.2025
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Reject allocation if number of extents is not divisible by area count.
   Fix issue preventing cluster mirror creation.
   Disable udev fallback by default and add activation/udev_fallback to lvm.conf.
   Call vg_mark_partial_lvs() before VG structure is returned from the cache.
--- LVM2/lib/metadata/lv_manip.c	2011/06/13 22:28:05	1.262
+++ LVM2/lib/metadata/lv_manip.c	2011/06/23 10:53:24	1.263
@@ -1716,6 +1716,13 @@
 		return 1;
 	}
 
+        if (ah->area_multiple > 1 &&
+            (ah->new_extents - alloc_state.allocated) % ah->area_count) {
+		log_error("Number of extents requested (%d) needs to be divisible by %d.",
+			  ah->new_extents - alloc_state.allocated, ah->area_count);
+		return 0;
+	}
+
 	alloc_state.log_area_count_still_needed = ah->log_area_count;
 
 	if (ah->alloc == ALLOC_CONTIGUOUS)
--- LVM2/test/t-lvconvert-mirror.sh	2011/06/09 19:38:56	1.10
+++ LVM2/test/t-lvconvert-mirror.sh	2011/06/23 10:53:24	1.11
@@ -248,3 +248,8 @@
 lvreduce -f -l1 $vg/$lv1
 lvextend -f -l10 $vg/$lv1
 lvremove -ff $vg/$lv1
+
+# extents must be divisible
+lvcreate -l15 -n $lv1 $vg
+not lvconvert -m1 --corelog --stripes 2 $vg/$lv1
+lvremove -ff $vg/$lv1


