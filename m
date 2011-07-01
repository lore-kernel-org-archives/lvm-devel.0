From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Jul 2011 16:15:25 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20110701161525.15355.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-07-01 16:15:25

Modified files:
	scripts        : gdbinit 

Log message:
	RAID updates for gdbinit file

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/scripts/gdbinit	2011/03/29 12:53:13	1.6
+++ LVM2/scripts/gdbinit	2011/07/01 16:15:25	1.7
@@ -27,12 +27,8 @@
 printf "Use 'help <command>' for more info\n"
 printf "\n\n"
 printf "Popular breakpoints:\n"
-printf "break lv_extend\n"
-printf "break check_lv_segments\n"
-printf "break text_import_areas\n"
-printf "run --type raid1 -L 200M -n lv vg\n"
-printf "run -m1 -L 200M -n lv vg\n"
-printf "lv_status_r lv\n"
+printf "break lv_raid_change_image_count\n"
+printf "run -m1 vg/lv\n"
 printf "\n\n"
 
 set follow-fork-mode child
@@ -79,7 +75,7 @@
 end
 
 #
-# __seg_item <return> <seg> <index>
+# __seg_type <return> <seg> <index>
 define __seg_type
 	set $arg0  = 0x0
 	set $_ST_seg  = (struct lv_segment *)$arg1
@@ -111,6 +107,27 @@
 	end
 end
 
+#
+# __seg_metaitem <return> <seg> <index>
+define __seg_metaitem
+	set $arg0  = 0x0
+	set $_SMI_seg  = (struct lv_segment *)$arg1
+	set $_SMI_index= $arg2
+
+	if ($_SMI_index < $_SMI_seg->area_count)
+		set $_SMI_area = $_SMI_seg->meta_areas[$_SMI_index]
+		set $_SMI_type = $_SMI_area.type
+
+		if ($_SMI_type == AREA_PV)
+			set $arg0 = $_SMI_area.u.pv.pvseg->pv
+		else
+			if ($_SMI_type == AREA_LV)
+				set $arg0 = $_SMI_area.u.lv.lv
+			end
+		end
+	end
+end
+
 define seg_item
 	set $_item = 0x0
 
@@ -122,6 +139,17 @@
 	end
 end
 
+define seg_metaitem
+	set $_metaitem = 0x0
+
+	__seg_metaitem $_metaitem $arg0 $arg1	
+	if ($_metaitem)
+		p $_metaitem
+	else
+		printf "AREA_UNASSIGNED or invalid\n"
+	end
+end
+
 document seg_item
 Returns the pointer to the LV or PV for the indexed area of a segment
 
@@ -142,62 +170,91 @@
 end
 
 define __status
+	set $_s_status = $arg0->status
+
 #	Constants defined in metadata-exported.h
 
-#	if ($arg0->status & VISIBLE_LV)
-	if ($arg0->status & 0x00000040U)
+#	if ($_s_status & VISIBLE_LV)
+	if ($_s_status & 0x00000040U)
 		printf " VISIBLE_LV"
+		set $_s_status = $_s_status & ~0x00000040U
 	else
 		printf " *HIDDEN_LV*"
 	end
-#	if ($arg0->status & FIXED_MINOR)
-	if ($arg0->status & 0x00000080U)
+#	if ($_s_status & FIXED_MINOR)
+	if ($_s_status & 0x00000080U)
+		set $_s_status = $_s_status & ~0x00000080U
 		printf " FIXED_MINOR"
 	end
-#	if ($arg0->status & SNAPSHOT)
-	if ($arg0->status & 0x00001000U)
+#	if ($_s_status & SNAPSHOT)
+	if ($_s_status & 0x00001000U)
+		set $_s_status = $_s_status & ~0x00001000U
 		printf " SNAPSHOT"
 	end
-#	if ($arg0->status & PVMOVE)
-	if ($arg0->status & 0x00002000U)
+#	if ($_s_status & PVMOVE)
+	if ($_s_status & 0x00002000U)
+		set $_s_status = $_s_status & ~0x00002000U
 		printf " PVMOVE"
 	end
-#	if ($arg0->status & LOCKED)
-	if ($arg0->status & 0x00004000U)
+#	if ($_s_status & LOCKED)
+	if ($_s_status & 0x00004000U)
+		set $_s_status = $_s_status & ~0x00004000U
 		printf " LOCKED"
 	end
-#	if ($arg0->status & MIRRORED)
-	if ($arg0->status & 0x00008000U)
+#	if ($_s_status & MIRRORED)
+	if ($_s_status & 0x00008000U)
+		set $_s_status = $_s_status & ~0x00008000U
 		printf " MIRRORED"
 	end
-#	if ($arg0->status & MIRROR_LOG)
-	if ($arg0->status & 0x00020000U)
+#	if ($_s_status & MIRROR_LOG)
+	if ($_s_status & 0x00020000U)
+		set $_s_status = $_s_status & ~0x00020000U
 		printf " MIRROR_LOG"
 	end
-#	if ($arg0->status & MIRROR_IMAGE)
-	if ($arg0->status & 0x00040000U)
+#	if ($_s_status & MIRROR_IMAGE)
+	if ($_s_status & 0x00040000U)
+		set $_s_status = $_s_status & ~0x00040000U
 		printf " MIRROR_IMAGE"
 	end
-#	if ($arg0->status & RAID)
-	if ($arg0->status & 0x00000001U)
+#	if ($_s_status & RAID)
+	if ($_s_status & 0x00000001U)
+		set $_s_status = $_s_status & ~0x00000001U
 		printf " RAID"
 	end
-#	if ($arg0->status & RAID_META)
-	if ($arg0->status & 0x00000002U)
+#	if ($_s_status & RAID_META)
+	if ($_s_status & 0x00000002U)
+		set $_s_status = $_s_status & ~0x00000002U
 		printf " RAID_META"
 	end
-#	if ($arg0->status & RAID_IMAGE)
-	if ($arg0->status & 0x00000004U)
+#	if ($_s_status & RAID_IMAGE)
+	if ($_s_status & 0x00000004U)
+		set $_s_status = $_s_status & ~0x00000004U
 		printf " RAID_IMAGE"
 	end
-#	if ($arg0->status & LV_NOTSYNCED)
-	if ($arg0->status & 0x00080000U)
+#	if ($_s_status & LV_NOTSYNCED)
+	if ($_s_status & 0x00080000U)
+		set $_s_status = $_s_status & ~0x00080000U
 		printf " LV_NOTSYNCED"
 	end
-#	if ($arg0->status & CONVERTING)
-	if ($arg0->status & 0x00400000U)
+#	if ($_s_status & CONVERTING)
+	if ($_s_status & 0x00400000U)
+		set $_s_status = $_s_status & ~0x00400000U
 		printf " CONVERTING"
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
+
+	if ($_s_status)
+		printf " 0x%x", $_s_status
+	end
 end
 
 #
@@ -411,6 +468,22 @@
 		__seg_type $_type $_seg $_area_index
 		if ($_type == AREA_LV)
 			set $indent++
+
+			__seg_metaitem $_lv $_seg $_area_index
+			if ($_lv)
+				set $rindent = $indent
+				set $rseg = $_seg
+				set $rarea_index = $_area_index
+				set $rlv = $_lv
+
+				__lv_status_r $_lv
+
+				set $indent = $rindent
+				set $_seg = $rseg
+				set $_area_index = $rarea_index
+				set $_lv = $rlv
+			end
+
 			__seg_item $_lv $_seg $_area_index
 			__lv_status_r $_lv
 		else


