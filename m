From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jun 2011 19:34:50 -0000
Subject: LVM2 ./WHATS_NEW test/t-lvextend-percent-exten ...
Message-ID: <20110609193450.15452.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-09 19:34:50

Modified files:
	.              : WHATS_NEW 
	test           : t-lvextend-percent-extents.sh 
	tools          : lvresize.c 

Log message:
	Fix extent rounding for striped segments.
	
	We should never remove more extents than requested by user,
	so round up to next stripe boundary during lvreduce.
	
	Also this fixes round to zero sized LV bug:
	
	# lvcreate -i2 -I 64k -l10 -n lvs vg_test
	# lvreduce -f -l1 vg_test/lvs
	Rounding size (1 extents) down to stripe boundary size for segment (0 extents)
	WARNING: Reducing active logical volume to 0
	THIS MAY DESTROY YOUR DATA (filesystem etc.)
	Reducing logical volume lvs to 0
	Failed to suspend lvs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2007&r2=1.2008
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/WHATS_NEW	2011/06/08 08:49:53	1.2007
+++ LVM2/WHATS_NEW	2011/06/09 19:34:49	1.2008
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Fix extent rounding for striped volumes (never reduce more than requested).
   Fix create_temp_name to replace any '/' found in the hostname with '?'.
   Always use append to file in lvmdump (selinux policy - no file truncation).
   Propagate test mode to clvmd to skip activation and changes to held locks.
--- LVM2/test/t-lvextend-percent-extents.sh	2011/01/05 00:16:20	1.10
+++ LVM2/test/t-lvextend-percent-extents.sh	2011/06/09 19:34:49	1.11
@@ -99,3 +99,8 @@
 lvreduce -f -l -$(( $pe_count * 1 )) $vg/$lv
 check lv_field $vg/$lv seg_count 1
 
+# do not reduce to 0 extents
+lvremove -f $vg/$lv
+lvcreate -i2 -I 64k -l10 -n $lv $vg
+lvreduce -f -l1 $vg/$lv
+check lv_field $vg/$lv lv_size "8.00m"
--- LVM2/tools/lvresize.c	2011/04/06 21:32:21	1.130
+++ LVM2/tools/lvresize.c	2011/06/09 19:34:50	1.131
@@ -575,11 +575,17 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if ((lp->stripes > 1)) {
+	if (lp->stripes > 1) {
 		if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
 			stripesize_extents = 1;
 
-		if ((size_rest = seg_size % (lp->stripes * stripesize_extents))) {
+		size_rest = seg_size % (lp->stripes * stripesize_extents);
+		if (size_rest && lp->resize == LV_REDUCE) {
+			log_print("Rounding size (%d extents) up to stripe "
+				  "boundary size for segment (%d extents)",
+				  lp->extents, lp->extents + size_rest);
+			lp->extents = lp->extents + size_rest;
+		} else if (size_rest) {
 			log_print("Rounding size (%d extents) down to stripe "
 				  "boundary size for segment (%d extents)",
 				  lp->extents, lp->extents - size_rest);


