From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 10 Apr 2012 23:24:01 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20120410232401.1810.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-10 23:24:00

Modified files:
	scripts        : gdbinit 

Log message:
	Add a couple new functions to gdbinit file and decode a couple lv->status flags
	New functions:
	- seg_pvs: Print a list of PVs in a seg_pvs list
	- pv_dev_name: print name of a PV

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/scripts/gdbinit	2011/09/28 16:32:22	1.11
+++ LVM2/scripts/gdbinit	2012/04/10 23:24:00	1.12
@@ -17,6 +17,7 @@
 printf "\n\n"
 printf "Loading commands:\n"
 printf " - dm_list_size <list ptr>\n"
+printf " - pv_dev_name <PV ptr>\n"
 printf " - first_seg <LV ptr>\n"
 printf " - lv_status <LV ptr>\n"
 printf " - lv_status_r <LV ptr>\n"
@@ -24,12 +25,13 @@
 printf " - seg_item <seg ptr> <index>\n"
 printf " - seg_status <seg ptr>\n"
 printf " - segs_using_this_lv <seg ptr>\n"
+printf " - seg_pvs <list ptr>\n"
 printf " - \n"
 printf "Use 'help <command>' for more info\n"
 printf "\n\n"
 printf "Popular breakpoints:\n"
-printf "break _get_udev_flags\n"
-printf "run --splitmirrors 1 -n split vg/lv\n"
+printf "break _alloc_image_components\n"
+printf "run --repair --use-policies vg/lv\n"
 printf "\n\n"
 
 set follow-fork-mode child
@@ -41,6 +43,8 @@
 # External functions should have a corresponding 'document'
 # section.  Internal functions should have leading comments
 
+
+
 define dm_list_size
 	set $_DLS_list_head = (struct dm_list *)$arg0
 	set $_DLS_list = $_DLS_list_head->n
@@ -60,6 +64,41 @@
 	Usage: dm_list_size <list ptr>
 end
 
+define pv_dev_name
+	set $_PDN_pv = (struct physical_volume *)$arg0
+	set $_PDN_dev = $_PDN_pv->dev
+	set $_PDN_strl = (struct str_list *)$_PDN_dev->aliases.n
+
+	printf "%s\n", $_PDN_strl->str
+end
+
+document pv_dev_name
+Print the name of the PV for the given PV pointer
+
+	Usage: pv_dev_name <PV ptr>
+end
+
+define seg_pvs
+	set $_SP_list_head = (struct dm_list *)$arg0
+	set $_SP_list = $_SP_list_head->n
+	
+	while (($_SP_list != $_SP_list_head) && ($_SP_size < 100))
+		set $_SP_spv = (struct seg_pvs *)$_SP_list
+
+		printf "* Can't print PV list\n"
+
+		set $_SP_list = $_SP_list->n
+	end
+
+	printf "%d list items\n", $_SP_size
+end
+
+document seg_pvs
+Print the elements of a seg_pvs list
+
+	Usage: seg_pvs <list ptr>
+end
+
 #
 # __first_seg <return> <LV>
 define __first_seg
@@ -270,6 +309,16 @@
 		set $_s_status = $_s_status & ~0x00400000U
 		printf " CONVERTING"
 	end
+#	if ($_s_status & LV_REBUILD)
+	if ($_s_status & 0x100000U)
+		set $_s_status = $_s_status & ~0x100000U
+		printf " LV_REBUILD"
+	end
+#	if ($_s_status & PARTIAL_LV)
+	if ($_s_status & 0x1000000U)
+		set $_s_status = $_s_status & ~0x1000000U
+		printf " PARTIAL_LV"
+	end
 #	if ($_s_status & MERGING)
 	if ($_s_status & 0x10000000U)
 		set $_s_status = $_s_status & ~0x10000000U


