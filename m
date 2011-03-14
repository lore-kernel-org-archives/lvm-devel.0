From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 14 Mar 2011 18:05:57 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20110314180557.10475.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-03-14 18:05:56

Modified files:
	scripts        : gdbinit 

Log message:
	Watch out for collisions in GDB global namespace.
	Better 'lv_status_r' printing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/scripts/gdbinit	2011/03/11 22:25:36	1.4
+++ LVM2/scripts/gdbinit	2011/03/14 18:05:56	1.5
@@ -28,6 +28,8 @@
 printf "\n\n"
 printf "Popular breakpoints:\n"
 printf "break lv_extend\n"
+printf "break check_lv_segments\n"
+printf "break text_import_areas\n"
 printf "run --type raid1 -L 200M -n lv vg\n"
 printf "lv_status_r lv\n"
 printf "\n\n"
@@ -46,10 +48,10 @@
 # __first_seg <return> <LV>
 define __first_seg
 	set $arg0 = 0x0
-	set $_lv  = (struct logical_volume *)$arg1
+	set $_FS_lv  = (struct logical_volume *)$arg1
 
-	if ($_lv->segments.n != &$_lv->segments)
-		set $arg0 = (struct lv_segment *)$_lv->segments.n
+	if ($_FS_lv->segments.n != &$_FS_lv->segments)
+		set $arg0 = (struct lv_segment *)$_FS_lv->segments.n
 	end
 end
 
@@ -79,30 +81,30 @@
 # __seg_item <return> <seg> <index>
 define __seg_type
 	set $arg0  = 0x0
-	set $_seg  = (struct lv_segment *)$arg1
-	set $_index= $arg2
-	set $_area = $_seg->areas[$_index]
-	set $_type = $_area.type
+	set $_ST_seg  = (struct lv_segment *)$arg1
+	set $_ST_index= $arg2
+	set $_ST_area = $_ST_seg->areas[$_ST_index]
+	set $_ST_type = $_ST_area.type
 
-	set $arg0 = $_type
+	set $arg0 = $_ST_type
 end
 
 #
 # __seg_item <return> <seg> <index>
 define __seg_item
 	set $arg0  = 0x0
-	set $_seg  = (struct lv_segment *)$arg1
-	set $_index= $arg2
+	set $_SI_seg  = (struct lv_segment *)$arg1
+	set $_SI_index= $arg2
 
-	if ($_index < $_seg->area_count)
-		set $_area = $_seg->areas[$_index]
-		set $_type = $_area.type
+	if ($_SI_index < $_SI_seg->area_count)
+		set $_SI_area = $_SI_seg->areas[$_SI_index]
+		set $_SI_type = $_SI_area.type
 
-		if ($_type == AREA_PV)
-			set $arg0 = $_area.u.pv.pvseg->pv
+		if ($_SI_type == AREA_PV)
+			set $arg0 = $_SI_area.u.pv.pvseg->pv
 		else
-			if ($_type == AREA_LV)
-				set $arg0 = $_area.u.lv.lv
+			if ($_SI_type == AREA_LV)
+				set $arg0 = $_SI_area.u.lv.lv
 			end
 		end
 	end
@@ -197,10 +199,38 @@
 	end
 end
 
+#
+# __print_indent <num indents> [No marks]
+define __print_indent
+	set $_PI_indent = $arg0
+	set $_PI_lead_mark = 0
+
+	while ($_PI_indent)
+		if ($_PI_indent == 1)
+			if ($argc > 1)
+				if ($_PI_lead_mark)
+					printf "        "
+				else
+					printf "|       "
+				end
+			else
+				printf "|-----> "
+			end
+		else
+			printf "|       "
+			set $_PI_lead_mark = 1
+		end
+		set $_PI_indent--
+	end
+end
+
 define lv_status
 	# Use __lv because we don't want to overwrite higher functions
 	set $__lv = (struct logical_volume *)$arg0
 
+	if ($argc == 2)
+		__print_indent $arg1
+	end
 	printf "%s->status:", $__lv->name
 	__status $__lv
 	printf "\n"
@@ -215,6 +245,9 @@
 define seg_status
 	set $_seg=(struct lv_segment *)$arg0
 
+	if ($argc == 2)
+		__print_indent $arg1 1
+	end
 	printf "[ (%s) seg->status:", $_seg->lv->name
 	__status $_seg
 	printf " ]\n"
@@ -223,7 +256,7 @@
 document seg_status
 Display the flags that are set on an lv_segment.
 
-        Usage: lv_status <(struct lv_segment *)>
+        Usage: seg_status <(struct lv_segment *)>
 end
 
 #
@@ -338,8 +371,8 @@
 		set $_s = $_lv->segments.n
 		set $_area_index = 0
 
-		printf "\n"
-		lv_status $_lv
+#		printf "\n"
+		lv_status $_lv $indent
 	else
 		set $_seg = (struct lv_segment *)$arg1
 
@@ -364,20 +397,28 @@
 		set $_type = 0x0
 
 		if (!$_area_index)
-			seg_status $_seg
+			seg_status $_seg $indent
 		end
 
 		__seg_type $_type $_seg $_area_index
 		if ($_type == AREA_LV)
+			set $indent++
 			__seg_item $_lv $_seg $_area_index
 			__lv_status_r $_lv
 		else
 			if ($_seg->log_lv)
-				printf "[LOG OF %s] ", $_lv->name
-				lv_status $_seg->log_lv
+				set $indent++
+				set $_log_seg = 0x0
+
+				__first_seg $_log_seg $_seg->log_lv
+				lv_status $_seg->log_lv $indent
+				seg_status $_log_seg $indent
+
+				set $indent--
 			end
 			__get_only_segment_using_this_lv $_seg $_lv
 			if ($_seg)
+				set $indent--
 				__lv_status_r $_lv $_seg
 			end
 		end
@@ -385,6 +426,7 @@
 end
 
 define lv_status_r
+	set $indent = 0
 	__lv_status_r $arg0
 end
 


