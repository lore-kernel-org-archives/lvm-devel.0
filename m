From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jun 2011 19:36:16 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/merge.c
Message-ID: <20110609193616.17425.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-09 19:36:16

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : merge.c 

Log message:
	Validate mirror segments size
	
	Currently some operation with striped mirrors lead
	to corrupted metadata, this patch just add detection of such
	situation.
	
	Example:
	# lvcreate -i2 -l10 -n lvs vg_test
	# lvconvert -m1 vg_test/lvs
	
	# lvreduce -f -l1 vg_test/lvs
	Reducing logical volume lvs to 4.00 MiB
	Segment extent reduction 9not divisible by #stripes 2
	Logical volume lvs successfully resized
	
	# lvremove vg_test/lvs
	Segment extent reduction 1not divisible by #stripes 2
	LV segment lvs:0-4294967295 is incorrectly listed as being used by LV lvs_mimage_0
	Internal error: LV segments corrupted in lvs_mimage_0.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2008&r2=1.2009
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/WHATS_NEW	2011/06/09 19:34:49	1.2008
+++ LVM2/WHATS_NEW	2011/06/09 19:36:16	1.2009
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Validate mirror segments size.
   Fix extent rounding for striped volumes (never reduce more than requested).
   Fix create_temp_name to replace any '/' found in the hostname with '?'.
   Always use append to file in lvmdump (selinux policy - no file truncation).
--- LVM2/lib/metadata/merge.c	2010/05/21 12:43:02	1.43
+++ LVM2/lib/metadata/merge.c	2011/06/09 19:36:16	1.44
@@ -204,6 +204,16 @@
 					inc_error_count;
 				}
 			}
+
+			if (complete_vg && seg_is_mirrored(seg) &&
+			    seg_type(seg, s) == AREA_LV &&
+			    seg_lv(seg, s)->le_count != seg->area_len) {
+				log_error("LV %s: mirrored LV segment %u has "
+					  "wrong size %u (should be %u).",
+					  lv->name, s, seg_lv(seg, s)->le_count,
+					  seg->area_len);
+				inc_error_count;
+			}
 		}
 
 		le += seg->len;


