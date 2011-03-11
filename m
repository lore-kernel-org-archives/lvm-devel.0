From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Mar 2011 22:16:39 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20110311221639.8828.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-03-11 22:16:38

Modified files:
	scripts        : gdbinit 

Log message:
	lv_status_r has been fixed-up so that it supports infinite LV stacking
	
	(It does not yet follow 'log_lv' or 'origin' links.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/scripts/gdbinit	2011/03/11 18:22:39	1.2
+++ LVM2/scripts/gdbinit	2011/03/11 22:16:38	1.3
@@ -34,13 +34,35 @@
 
 set follow-fork-mode child
 
+# Conventions:
+# foo     : function named 'foo' available to user
+# __foo   : an internal function
+#
+# External functions should have a corresponding 'document'
+# section.  Internal functions should have leading comments
+
+
+#
+# __first_seg <return> <LV>
+define __first_seg
+	set $arg0 = 0x0
+	set $_lv  = (struct logical_volume *)$arg1
+
+	if ($_lv->segments.n != &$_lv->segments)
+		set $arg0 = (struct lv_segment *)$_lv->segments.n
+	end
+end
+
 define first_seg
-	set $__lv=(struct logical_volume *)$arg0
+	set $_seg = 0
+	set $_lv=(struct logical_volume *)$arg0
 
-	if ($__lv->segments.n == &$__lv->segments)
-		printf "No segments (list empty)\n"
+	__first_seg $_seg $_lv
+
+	if ($_seg)
+		p $_seg
 	else
-		p (struct lv_segment *)$__lv->segments.n
+		printf "No segments (list empty)\n"
 	end
 end
 
@@ -53,23 +75,50 @@
 	 this function will be wrong.
 end
 
-define seg_item
-	set $__seg=(struct lv_segment *)$arg0
-	set $__index=$arg1
-	set $__area=$__seg->areas[$__index]
-	set $__type=$__area.type
+#
+# __seg_item <return> <seg> <index>
+define __seg_type
+	set $arg0  = 0x0
+	set $_seg  = (struct lv_segment *)$arg1
+	set $_index= $arg2
+	set $_area = $_seg->areas[$_index]
+	set $_type = $_area.type
+
+	set $arg0 = $_type
+end
+
+#
+# __seg_item <return> <seg> <index>
+define __seg_item
+	set $arg0  = 0x0
+	set $_seg  = (struct lv_segment *)$arg1
+	set $_index= $arg2
+
+	if ($_index < $_seg->area_count)
+		set $_area = $_seg->areas[$_index]
+		set $_type = $_area.type
 
-	if ($__type == AREA_PV)
-		p $__area.u.pv.pvseg->pv
-	else
-		if ($__type == AREA_LV)
-			p $__area.u.lv.lv
+		if ($_type == AREA_PV)
+			set $arg0 = $_area.u.pv.pvseg->pv
 		else
-			printf "AREA_UNASSIGNED or invalid\n"
+			if ($_type == AREA_LV)
+				set $arg0 = $_area.u.lv.lv
+			end
 		end
 	end
 end
 
+define seg_item
+	set $_item = 0x0
+
+	__seg_item $_item $arg0 $arg1	
+	if ($_item)
+		p $_item
+	else
+		printf "AREA_UNASSIGNED or invalid\n"
+	end
+end
+
 document seg_item
 Returns the pointer to the LV or PV for the indexed area of a segment
 
@@ -165,9 +214,9 @@
 define seg_status
 	set $_seg=(struct lv_segment *)$arg0
 
-	printf "(%s) seg->status:", $_seg->lv->name
+	printf "[ (%s) seg->status:", $_seg->lv->name
 	__status $_seg
-	printf "\n"
+	printf " ]\n"
 end
 
 document seg_status
@@ -176,67 +225,29 @@
         Usage: lv_status <(struct lv_segment *)>
 end
 
-define __lv_status_r
-        set $_lv=(struct logical_volume *)$arg0
-	set $_seg_list_head = &$_lv->segments
-	set $_s = $_lv->segments.n
+#
+# get_only_segment_using_this_lv <return> <LV>
+define __get_only_segment_using_this_lv
+	set $arg0 = 0x0
+	set $_lv=(struct logical_volume *)$arg1
+	set $_seg_list_head = &$_lv->segs_using_this_lv
+	set $_s = $_lv->segs_using_this_lv.n
 	set $_i = 0
 
-	# lv_status $_lv
-	printf "%s%s->status:", $arg1, $_lv->name
-	__status $_lv
-	printf "\n"
+	while (($_s != $_seg_list_head) && ($_i < 100))
+		set $_seg_list = (struct seg_list *)$_s
+		set $_seg = (struct lv_segment *)$_seg_list->seg
 
-	if ($_s == $_seg_list_head)
-		printf "[ No segments for %s ]\n", $_lv->name
-	else
-		set $_seg = (struct lv_segment *)$_s
-		while ($_s != $_seg_list_head)
-			printf "%s[ %s->seg(%d)->status:", $arg1, $_lv->name, $_i
-			__status $_seg
-			printf " ]\n"
-
-			set $_j = 0
-			while ($_j < $_seg->area_count)
-				set $_area=$_seg->areas[$_j]
-				set $_type=$_area.type
-				if ($_type == AREA_LV)
-# Damn it, gdb does not have scoping so functions are not reentrant
-#					__lv_status_r $_area.u.lv.lv "    "
-
-# Next couple lines will get us through a non-stacked mirror...
-printf "*    "
-lv_status $_area.u.lv.lv
-set $barf = (struct lv_segment *)($_area.u.lv.lv)->segments.n
-if ($barf != &($_area.u.lv.lv)->segments)
-printf "*    "
-printf "[ %s->seg(0)->status:", $_lv->name
-__status $barf
-printf " ]\n"
-end
-				end
-				set $_j++
-			end
-			set $_s = $_s->n
-			set $_seg = (struct lv_segment *)$_s
-			set $_i++
-		end
+		set $_i++
+		set $_s = $_s->n
 	end
-	printf "\n"	
-end
-
-define lv_status_r
-	__lv_status_r $arg0 ""
-end
 
-document lv_status_r
-Display the status flags of an LV and its sub_lvs.
-
-	Usage: lv_status_r <LV ptr>
-
-This function is useful for checking that all the LVs that
-compose a logical volume have the correct flags set (and also
-their associated lv_segments)
+	if ($_i > 1)
+		printf "More than %s using %s\n", ($_i > 99) ? "100 segments" : "one segment", $_lv->name
+	end
+	if ($_i == 1)
+		set $arg0 = $_seg
+	end
 end
 
 define segs_using_this_lv
@@ -259,8 +270,8 @@
 		else
 			printf "  [seg found in %s]\n", $_seg->lv->name
 		end
+		set $_i++
 		set $_s = $_s->n
-		set $_i = $_i + 1
 	end
 end
 
@@ -287,6 +298,101 @@
 	  0) seg: 0x92d360  [seg found in lv]
 end
 
+#
+# __next_area_index <return> <seg> <seg_item>
+define __next_area_index
+	set $arg0 = 0x0
+	set $_seg = (struct lv_segment *)$arg1
+	set $_item = 0x0
+	set $_i = 0
+
+	__seg_item $_item $_seg $_i
+	while ($_item && ($_item != $arg2))
+		set $_i++
+		__seg_item $_item $_seg $_i
+	end
+
+	# $_i points to current, now get next (if there)
+	set $_i++
+	__seg_item $_item $_seg $_i
+
+	if ($_item)
+		set $arg0 = $_i
+	end
+end
+
+#
+# __lv_status_r <LV>
+# Decend tree, printing LV and seg status as we go.  This
+# performs a depth first approach (but can't come up) 
+# or
+# __lv_status_r <sub_lv> <seg using sub_lv>
+# Try continuing decent of tree by first shifting to the
+# next 'area' in the seg ($arg1).  If no more areas, then
+# try going to the next segment.
+define __lv_status_r
+	if ($argc == 1)
+	        set $_lv=(struct logical_volume *)$arg0
+		set $_seg_list_head = &$_lv->segments
+		set $_s = $_lv->segments.n
+		set $_area_index = 0
+
+		printf "\n"
+		lv_status $_lv
+	else
+		set $_seg = (struct lv_segment *)$arg1
+
+		__next_area_index $_area_index $_seg $arg0
+
+		# Don't fuck this up.  We need the next two lines here.
+	        set $_lv=(struct logical_volume *)$_seg->lv
+		set $_seg_list_head = &$_lv->segments
+		set $_s = (struct dm_list *)$_seg
+
+		if (!$_area_index)
+			set $_s = $_s->n
+		end
+	end
+
+	if ($_s == $_seg_list_head)
+		if ($argc == 1)
+			printf "[ No segments for %s ]\n", $_lv->name
+		end
+	else
+		set $_seg = (struct lv_segment *)$_s
+		set $_type = 0x0
+
+		if (!$_area_index)
+			seg_status $_seg
+		end
+
+		__seg_type $_type $_seg $_area_index
+		if ($_type == AREA_LV)
+			__seg_item $_lv $_seg $_area_index
+			__lv_status_r $_lv
+		else
+			__get_only_segment_using_this_lv $_seg $_lv
+			if ($_seg)
+				__lv_status_r $_lv $_seg
+			end
+		end
+	end
+end
+
+define lv_status_r
+	__lv_status_r $arg0
+end
+
+document lv_status_r
+Display the status flags of an LV and its sub_lvs.
+
+	Usage: lv_status_r <LV ptr>
+
+This function is useful for checking that all the LVs that
+compose a logical volume have the correct flags set (and also
+their associated lv_segments)
+end
+
 define lv_is_mirrored
 	set $_lv=(struct logical_volume *)$arg0
 	set $_fs=(struct lv_segment *)$_lv->segments.n


