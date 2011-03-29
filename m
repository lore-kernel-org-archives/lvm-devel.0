From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 29 Mar 2011 12:53:13 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20110329125313.16497.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-03-29 12:53:13

Modified files:
	scripts        : gdbinit 

Log message:
	gdbinit update
	
	When doing lv_status_r on a sub_lv, do not climb the tree up past the
	starting point.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/scripts/gdbinit	2011/03/14 18:05:56	1.5
+++ LVM2/scripts/gdbinit	2011/03/29 12:53:13	1.6
@@ -31,6 +31,7 @@
 printf "break check_lv_segments\n"
 printf "break text_import_areas\n"
 printf "run --type raid1 -L 200M -n lv vg\n"
+printf "run -m1 -L 200M -n lv vg\n"
 printf "lv_status_r lv\n"
 printf "\n\n"
 
@@ -390,8 +391,15 @@
 
 	if ($_s == $_seg_list_head)
 		if ($argc == 1)
+			__print_indent $indent 1
 			printf "[ No segments for %s ]\n", $_lv->name
 		end
+		__get_only_segment_using_this_lv $_seg $_lv
+
+		if ($_seg && $indent)
+			set $indent--
+			__lv_status_r $_lv $_seg
+		end
 	else
 		set $_seg = (struct lv_segment *)$_s
 		set $_type = 0x0


