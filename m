From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Sep 2011 21:01:12 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20110901210112.8299.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-01 21:01:12

Modified files:
	scripts        : gdbinit 

Log message:
	Updates to gdbinit file
	
	1) Add more status flags for printing
	2) Fix bug in lv_status_r processing for mirror segment type

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/scripts/gdbinit	2011/07/01 16:15:25	1.7
+++ LVM2/scripts/gdbinit	2011/09/01 21:01:12	1.8
@@ -27,8 +27,8 @@
 printf "Use 'help <command>' for more info\n"
 printf "\n\n"
 printf "Popular breakpoints:\n"
-printf "break lv_raid_change_image_count\n"
-printf "run -m1 vg/lv\n"
+printf "break _split_mirror_images\n"
+printf "run --splitmirrors 2 -n new vg/lv\n"
 printf "\n\n"
 
 set follow-fork-mode child
@@ -114,7 +114,7 @@
 	set $_SMI_seg  = (struct lv_segment *)$arg1
 	set $_SMI_index= $arg2
 
-	if ($_SMI_index < $_SMI_seg->area_count)
+	if (($_SMI_index < $_SMI_seg->area_count) && $_SMI_seg->meta_areas)
 		set $_SMI_area = $_SMI_seg->meta_areas[$_SMI_index]
 		set $_SMI_type = $_SMI_area.type
 
@@ -174,6 +174,21 @@
 
 #	Constants defined in metadata-exported.h
 
+#	if ($_s_status & RAID)
+	if ($_s_status & 0x00000001U)
+		set $_s_status = $_s_status & ~0x00000001U
+		printf " RAID"
+	end
+#	if ($_s_status & RAID_META)
+	if ($_s_status & 0x00000002U)
+		set $_s_status = $_s_status & ~0x00000002U
+		printf " RAID_META"
+	end
+#	if ($_s_status & RAID_IMAGE)
+	if ($_s_status & 0x00000004U)
+		set $_s_status = $_s_status & ~0x00000004U
+		printf " RAID_IMAGE"
+	end
 #	if ($_s_status & VISIBLE_LV)
 	if ($_s_status & 0x00000040U)
 		printf " VISIBLE_LV"
@@ -186,6 +201,16 @@
 		set $_s_status = $_s_status & ~0x00000080U
 		printf " FIXED_MINOR"
 	end
+#	if ($_s_status & LVM_READ)
+	if ($_s_status & 0x00000100U)
+		set $_s_status = $_s_status & ~0x00000100U
+		printf " LVM_READ"
+	end
+#	if ($_s_status & LVM_WRITE)
+	if ($_s_status & 0x00000200U)
+		set $_s_status = $_s_status & ~0x00000200U
+		printf " LVM_WRITE"
+	end
 #	if ($_s_status & SNAPSHOT)
 	if ($_s_status & 0x00001000U)
 		set $_s_status = $_s_status & ~0x00001000U
@@ -216,21 +241,6 @@
 		set $_s_status = $_s_status & ~0x00040000U
 		printf " MIRROR_IMAGE"
 	end
-#	if ($_s_status & RAID)
-	if ($_s_status & 0x00000001U)
-		set $_s_status = $_s_status & ~0x00000001U
-		printf " RAID"
-	end
-#	if ($_s_status & RAID_META)
-	if ($_s_status & 0x00000002U)
-		set $_s_status = $_s_status & ~0x00000002U
-		printf " RAID_META"
-	end
-#	if ($_s_status & RAID_IMAGE)
-	if ($_s_status & 0x00000004U)
-		set $_s_status = $_s_status & ~0x00000004U
-		printf " RAID_IMAGE"
-	end
 #	if ($_s_status & LV_NOTSYNCED)
 	if ($_s_status & 0x00080000U)
 		set $_s_status = $_s_status & ~0x00080000U
@@ -241,15 +251,10 @@
 		set $_s_status = $_s_status & ~0x00400000U
 		printf " CONVERTING"
 	end
-#	if ($_s_status & LVM_READ)
-	if ($_s_status & 0x00000100U)
-		set $_s_status = $_s_status & ~0x00000100U
-		printf " LVM_READ"
-	end
-#	if ($_s_status & LVM_WRITE)
-	if ($_s_status & 0x00000200U)
-		set $_s_status = $_s_status & ~0x00000200U
-		printf " LVM_WRITE"
+#	if ($_s_status & MERGING)
+	if ($_s_status & 0x10000000U)
+		set $_s_status = $_s_status & ~0x10000000U
+		printf " MERGING"
 	end
 
 	if ($_s_status)
@@ -417,7 +422,9 @@
 # __lv_status_r <LV>
 # Decend tree, printing LV and seg status as we go.  This
 # performs a depth first approach (but can't come up) 
+#
 # or
+#
 # __lv_status_r <sub_lv> <seg using sub_lv>
 # Try continuing decent of tree by first shifting to the
 # next 'area' in the seg ($arg1).  If no more areas, then
@@ -464,7 +471,6 @@
 		if (!$_area_index)
 			seg_status $_seg $indent
 		end
-
 		__seg_type $_type $_seg $_area_index
 		if ($_type == AREA_LV)
 			set $indent++


