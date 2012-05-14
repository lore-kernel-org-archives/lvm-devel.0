From: agk@sourceware.org <agk@sourceware.org>
Date: 14 May 2012 16:18:59 -0000
Subject: LVM2 lib/metadata/lv_manip.c ./WHATS_NEW
Message-ID: <20120514161859.14591.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-14 16:18:58

Modified files:
	lib/metadata   : lv_manip.c 
	.              : WHATS_NEW 

Log message:
	Warn of deadlock risk when using snapshots of mirror segment type.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.380&r2=1.381
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2404&r2=1.2405

--- LVM2/lib/metadata/lv_manip.c	2012/05/11 22:53:13	1.380
+++ LVM2/lib/metadata/lv_manip.c	2012/05/14 16:18:57	1.381
@@ -4231,9 +4231,9 @@
 
 			if (lv_is_mirror_type(org) &&
 			    !seg_is_raid(first_seg(org))) {
-				log_error("Snapshots of \"mirror\" segment types"
-					  " are not supported");
-				return NULL;
+				log_warn("WARNING: Snapshots of mirrors can deadlock under rare device failures.");
+				log_warn("WARNING: Consider using the raid1 mirror type to avoid this.");
+				log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
 			}
 
 			if (!lv_info(cmd, org, 0, &info, 0, 0)) {
--- LVM2/WHATS_NEW	2012/05/11 22:53:13	1.2404
+++ LVM2/WHATS_NEW	2012/05/14 16:18:58	1.2405
@@ -9,7 +9,7 @@
   Add initial support for thin pool lvconvert.
   Fix lvrename for thin volumes (regression in for_each_sub_lv() 2.02.89).
   Fix up-convert when mirror activation is controled by volume_list and tags.
-  Disallow snapshots of mirror segment type.
+  Warn of deadlock risk when using snapshots of mirror segment type.
   Fix bug in cmirror that caused incorrect status info to print on some nodes.
   Remove statement that snapshots cannot be tagged from lvm man page.
   Disallow changing cluster attribute of VG while RAID LVs are active.


