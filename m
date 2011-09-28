From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 28 Sep 2011 16:32:23 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20110928163223.29878.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-28 16:32:22

Modified files:
	scripts        : gdbinit 

Log message:
	New handy gdb debugging function, "dm_list_size"
	
	Example:
	(gdb) dm_list_size &split_images
	1 list items

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/scripts/gdbinit	2011/09/13 13:57:02	1.10
+++ LVM2/scripts/gdbinit	2011/09/28 16:32:22	1.11
@@ -16,6 +16,7 @@
 
 printf "\n\n"
 printf "Loading commands:\n"
+printf " - dm_list_size <list ptr>\n"
 printf " - first_seg <LV ptr>\n"
 printf " - lv_status <LV ptr>\n"
 printf " - lv_status_r <LV ptr>\n"
@@ -27,8 +28,8 @@
 printf "Use 'help <command>' for more info\n"
 printf "\n\n"
 printf "Popular breakpoints:\n"
-printf "break _raid_add_images\n"
-printf "run --type raid1 -m 1 vg/lv\n"
+printf "break _get_udev_flags\n"
+printf "run --splitmirrors 1 -n split vg/lv\n"
 printf "\n\n"
 
 set follow-fork-mode child
@@ -40,6 +41,24 @@
 # External functions should have a corresponding 'document'
 # section.  Internal functions should have leading comments
 
+define dm_list_size
+	set $_DLS_list_head = (struct dm_list *)$arg0
+	set $_DLS_list = $_DLS_list_head->n
+	set $_DLS_size = 0
+	
+	while (($_DLS_list != $_DLS_list_head) && ($_DLS_size < 100))
+		set $_DLS_list = $_DLS_list->n
+		set $_DLS_size++
+	end
+
+	printf "%d list items\n", $_DLS_size
+end
+
+document dm_list_size
+Returns the number of elements in the dm_list
+
+	Usage: dm_list_size <list ptr>
+end
 
 #
 # __first_seg <return> <LV>


