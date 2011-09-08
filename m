From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 8 Sep 2011 22:19:45 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20110908221945.21769.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-08 22:19:45

Modified files:
	scripts        : gdbinit 

Log message:
	Adjust gdbinit script to new RAID status flag values.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/scripts/gdbinit	2011/09/01 21:01:12	1.8
+++ LVM2/scripts/gdbinit	2011/09/08 22:19:45	1.9
@@ -27,8 +27,8 @@
 printf "Use 'help <command>' for more info\n"
 printf "\n\n"
 printf "Popular breakpoints:\n"
-printf "break _split_mirror_images\n"
-printf "run --splitmirrors 2 -n new vg/lv\n"
+printf "break _raid_add_images\n"
+printf "run --type raid1 -m 1 vg/lv\n"
 printf "\n\n"
 
 set follow-fork-mode child
@@ -175,18 +175,18 @@
 #	Constants defined in metadata-exported.h
 
 #	if ($_s_status & RAID)
-	if ($_s_status & 0x00000001U)
-		set $_s_status = $_s_status & ~0x00000001U
+	if ($_s_status & 0x0000000100000000LU)
+		set $_s_status = $_s_status & ~0x0000000100000000LU
 		printf " RAID"
 	end
 #	if ($_s_status & RAID_META)
-	if ($_s_status & 0x00000002U)
-		set $_s_status = $_s_status & ~0x00000002U
+	if ($_s_status & 0x0000000200000000LU)
+		set $_s_status = $_s_status & ~0x0000000200000000LU
 		printf " RAID_META"
 	end
 #	if ($_s_status & RAID_IMAGE)
-	if ($_s_status & 0x00000004U)
-		set $_s_status = $_s_status & ~0x00000004U
+	if ($_s_status & 0x0000000400000000LU)
+		set $_s_status = $_s_status & ~0x0000000400000000LU
 		printf " RAID_IMAGE"
 	end
 #	if ($_s_status & VISIBLE_LV)


